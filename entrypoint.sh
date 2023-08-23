#!/bin/sh

set -e

echo "/usr/local/bin/kubectl" >> $GITHUB_PATH

if [ ! -d "$HOME/.kube" ]; then
    mkdir -p $HOME/.kube
fi


config=$(echo "$KUBE_CONFIG" | base64 -d)
echo "KUBE_CONFIG: ${config}"
echo "KUBE_CONTEXT: ${KUBE_CONTEXT}"
echo "KUBE_CERTIFICATE: ${KUBE_CERTIFICATE}"
echo "KUBE_HOST: ${KUBE_HOST}"

# version=$(kubectl version)
# echo "kubectl version: ${version}"

echo "Using config file: ${HOME}/.kube/config"

config=$(cat ${HOME}/.kube/config)
echo "Using the following config: ${config}"

echo "Checking for existing config file ..."
if [ ! -f "$HOME/.kube/config" ]; then
    echo "Existing config not found."
    if [ ! -z "${KUBE_CONFIG}" ]; then
        echo "Writing provided config to ${HOME}/.kube/config"
        echo "$KUBE_CONFIG" | base64 -d > $HOME/.kube/config

        if [ ! -z "${KUBE_CONTEXT}" ]; then
            echo "Switching context to ${KUBE_CONTEXT}."
            kubectl config use-context $KUBE_CONTEXT
        fi
    elif [ ! -z "${KUBE_HOST}" ]; then
        echo "Config file not provided, building our own ..."
        echo "$KUBE_CERTIFICATE" | base64 -d > $HOME/.kube/certificate
        kubectl config set-cluster default --server=https://$KUBE_HOST --certificate-authority=$HOME/.kube/certificate > /dev/null

        if [ ! -z "${KUBE_PASSWORD}" ]; then
            kubectl config set-credentials cluster-admin --username=$KUBE_USERNAME --password=$KUBE_PASSWORD > /dev/null
        elif [ ! -z "${KUBE_TOKEN}" ]; then
            kubectl config set-credentials cluster-admin --token="${KUBE_TOKEN}" > /dev/null
        else
            echo "No credentials found. Please provide KUBE_TOKEN, or KUBE_USERNAME and KUBE_PASSWORD. Exiting..."
            exit 1
        fi

        kubectl config set-context default --cluster=default --namespace=default --user=cluster-admin > /dev/null
        kubectl config use-context default > /dev/null
    elif [[ $* == "kustomize" ]]; then :;
    else
        echo "No authorization data found. Please provide KUBE_CONFIG or KUBE_HOST variables. Exiting..."
        exit 1
    fi
fi

config=$(cat ${HOME}/.kube/config)
echo "Using the following config: ${config}"

echo "Running kubectl ..."
if [ -z "$dest" ]; then
    kubectl $*
else
    echo "$dest<<EOF" >> $GITHUB_ENV
    kubectl $* >> $GITHUB_ENV
    echo "EOF" >> $GITHUB_ENV
    
    echo "::add-mask::$dest"
fi
