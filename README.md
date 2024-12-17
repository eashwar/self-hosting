# Eash's Self Hosted Server

Currently I run an M4 Mac Mini as a home server for hosting various projects.

I deploy projects to a kubernetes cluster and use Cloudflare Tunnels to make this available to the public internet. I use `kind` as my cluster solution as it runs well on Darwin machines and is lightweight.


## Prerequisites

- Docker
- Kind
- Kubectl
- YQ