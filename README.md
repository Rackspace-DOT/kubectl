# kubectl

[![Preview](https://serhiy.s3.eu-central-1.amazonaws.com/Github_repo/kubectl/logo.png)](https://cloud.google.com)

GitHub Action for interacting with kubectl ([k8s](https://kubernetes.io))

## Usage
To use kubectl put this step into your workflow:

### Authorization with config file
```yaml
- uses: andrrax/kubectl@only_kubeconfig
  env:
    KUBE_CONFIG: ${{ secrets.KUBECONFIG }}
  with:
    args: get pods
```

## Environment variables
All these variables need to authorize to kubernetes cluster.  
I recommend using secrets for this.

### KUBECONFIG file
First options its to use [kubeconfig file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/).  

For this method `KUBECONFIG` required.  
You can find it: `cat $HOME/.kube/config | base64 `.

Optionally you can switch the [context](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/) (the cluster) if you have few in kubeconfig file. Passing specific context to `KUBE_CONTEXT`. To see the list of available contexts do: `kubectl config get-contexts`.

| Variable | Type |
| --- | --- |
| KUBE_CONFIG | string (base64) |
| KUBE_CONTEXT | string |


## Example
```yaml
name: Get pods
on: [push]

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1
      - uses: andrrax/kubectl@only_kubeconfig
        env:
          KUBE_CONFIG: ${{ secrets.KUBECONFIG }}
        with:
          args: get pods
```

```yaml
name: Get pods
on: [push]

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1
      - uses: andrrax/kubectl@only_kubeconfig
        env:
          KUBE_CONFIG: ${{ secrets.KUBECONFIG }}

      - uses: andrrax/kubectl@only_kubeconfig
        with:
          args: get pods
```

## Versions
If you need a specific version of kubectl, make a PR with a specific version number.
After accepting PR the new release will be created.   
To use a specific version of kubectl use:

```yaml
- uses: actions-hub/kubectl@1.14.3
  env:
    KUBE_CONFIG: ${{ secrets.KUBECONFIG }}
  with:
    args: get pods
```

## Licence
[MIT License](https://github.com/actions-hub/kubectl/blob/master/LICENSE)