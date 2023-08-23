#!/bin/sh

set -e

echo "/usr/local/bin/kubectl" >> $GITHUB_PATH

if [ ! -d "$HOME/.kube" ]; then
    mkdir -p $HOME/.kube
fi

if [ ! -z "${KUBE_CONFIG}" ]; then
    echo "Writing provided config to ${HOME}/.kube/config"
    echo "$KUBE_CONFIG" | base64 -d > $HOME/.kube/config

    if [ ! -z "${KUBE_CONTEXT}" ]; then
        echo "Using context ${KUBE_CONTEXT}."
        kubectl config use-context $KUBE_CONTEXT
    fi
else
    echo "KUBE_CONFIG was not defined. Please provide a KUBE_CONFIG variable. Exiting..."
    exit 1
fi

echo "Running kubectl ..."
if [ -z "$dest" ]; then
    kubectl $*
else
    echo "$dest<<EOF" >> $GITHUB_ENV
    kubectl $* >> $GITHUB_ENV
    echo "EOF" >> $GITHUB_ENV
    
    echo "::add-mask::$dest"
fi
