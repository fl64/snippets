#!/usr/bin/env bash
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc


echo 'set et sw=2 ts=2 sts=2' >>~/.vimrc

curl -L https://github.com/derailed/k9s/releases/download/v0.26.7/k9s_Linux_x86_64.tar.gz | tar -xz
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

echo 'source <(helm completion bash)' >>~/.bashrc
echo 'source <(kustomize completion bash)' >>~/.bashrc

source ~/.bashrc
