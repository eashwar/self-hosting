#!/bin/zsh

usage() {echo "Usage: $0 [-k - if specified, redeploys k8s cluster as well; -h - displays this message]" 1>&2; exit 1;}


zparseopts -D -E -F - k=rebuild_cluster h=should_help

rebuild_cluster=${#rebuild_cluster}
should_help=${#should_help}

if [[ $should_help -eq 1 ]]; then
    usage
fi 

if [[ $rebuild_cluster -eq 1 ]]; then
    # cleanup any existing cluster gunk
    kind delete cluster

    # create new cluster with the default name
    kind create cluster --config kind-config/kind-config.kind.yml

    # add cloudflare tunnel. ASSUMPTION: credentials are in this path.
    kubectl create secret generic tunnel-credentials --from-file=credentials.json=/Users/eash/.cloudflared/733f7f2e-c7df-4d14-8c54-475c29bb9e0c.json
    kubectl apply -f deployment/tunnel.yml
fi


# add build from source and add the docker images into the cluster, and modify k8s specs to use them
./build-and-deploy-subsystem.sh site
./build-and-deploy-subsystem.sh api
