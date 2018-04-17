#!/bin/sh
echo 'Installing .NET Core...'

# .NET Core 2.1 preview2 SDK packages for Debian / Ubuntu are currently broken, so we install from tarball instead.
sudo apt-get -qq update
sudo apt-get install -y jq libunwind8 liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g libicu52
sudo curl -L -o /usr/share/dotnet-sdk.tar.gz https://download.microsoft.com/download/3/7/C/37C0D2E3-2056-4F9A-A67C-14DEFBD70F06/dotnet-sdk-2.1.300-preview2-008530-linux-x64.tar.gz
sudo mkdir -p /usr/share/dotnet
sudo tar -C /usr/share/dotnet -xvzf /usr/share/dotnet-sdk.tar.gz
sudo rm /usr/share/dotnet-sdk.tar.gz

echo 'Installing kubecl'
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo 'Installing minikube'
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.25.0/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

echo 'Creating the minikube cluster'
sudo minikube start --vm-driver=none --kubernetes-version=v1.9.0 --extra-config=apiserver.Authorization.Mode=RBAC
minikube update-context
minikube addons disable dashboard

echo 'Waiting for the cluster nodes to be ready'
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; \
  until kubectl get nodes -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1; done
