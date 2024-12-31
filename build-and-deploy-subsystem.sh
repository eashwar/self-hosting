#!/bin/zsh

image_name=placeholder
target_dir=placeholder
deploy_file=placeholder
case $1 in
site)
    image_name="eash-site"
    target_dir=~/src/eash.dev
    deploy_file="site"
    ;;
api)
    image_name="eash-api"
    target_dir=~/src/api.eash.dev
    deploy_file="api"
    ;;
*)
    echo "not found"
    exit 1
    ;;
esac


git -C $target_dir pull

tag=$(echo $(date +%Y.%m.%d.%H%M%S))

fqin="$image_name:$tag"

docker build -t $fqin $target_dir

kind load docker-image $fqin

echo "deploying $fqin"

yq "select(di == 0).spec.template.spec.containers[0].image = \"$fqin\"" ~/local/deployment/$deploy_file.yml | kubectl apply -f -