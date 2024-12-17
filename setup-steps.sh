#!/bin/zsh

## ASSUMPTION: projects are in the ~/src directory
build_and_deploy () {
    image_name=placeholder
    target_dir=placeholder
    case $1 in
    site)
        image_name="eash-site"
        target_dir="eash.dev"
        ;;
    api)
        image_name="eash-api"
        target_dir="api.eash.dev"
        ;;
    *)
        echo "not found"
        exit 1
        ;;
    esac

    tag=$(echo $(date +%Y.%m.%d))

    docker build -t $image_name:$tag ~/src/$target_dir

    kind load docker-image $image_name:$tag

    echo "$image_name:$tag"
}


# cleanup any existing cluster gunk
kind delete cluster

# create new cluster with the default name
kind create cluster --config kind-config/kind-config.kind.yml

# add build from source and add the docker images into the cluster, and modify k8s specs to use them
site_fqin="$(build_and_deploy site)"
echo "deploying $site_fqin"
yq "select(di == 0).spec.template.spec.containers[0].image = \"$site_fqin\"" deployment/site.yml | kubectl apply -f -

api_fqin="$(build_and_deploy api)"
echo "deploying $api_fqin"
yq "select(di == 0).spec.template.spec.containers[0].image = \"$api_fqin\"" deployment/api.yml | kubectl apply -f -

# wait
sleep 5

# add cloudflare tunnel. ASSUMPTION: credentials are in this path.
kubectl create secret generic tunnel-credentials --from-file=credentials.json=/Users/eash/.cloudflared/733f7f2e-c7df-4d14-8c54-475c29bb9e0c.json
kubectl apply -f deployment/tunnel.yml
