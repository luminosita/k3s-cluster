# Multipass Setup

##### Create Node

```bash
multipass find
multipass launch -n HOSTNAME -m 2G -d 30G -c 2 jammy
```

Replace HOSTNAME with node's host name

##### Open Shell

```bash
multipass shell HOSTNAME
```

##### Start/Stop Node

```bash
multipass start [HOSTNAME]
multipass stop [HOSTNAME]
```

`HOSTNAME` is optional. If not specified it will start/stop all available instances

# K3s Cluster Setup

##### Basic Setup for Each Node

```bash
sudo apt update
sudo apt upgrade
sudo apt install net-tools
sudo apt install emacs
```
##### Control Node

```bash
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-backend=none --cluster-cidr=10.10.0.0/16 --disable-network-policy --disable=traefik" sh -
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml
watch sudo k3s kubectl get pods --all-namespaces
```

Retrieve node token

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

Use node token to join worker nodes

##### Worker Node

```bash
SERVER_HOST=xxx
```
Replace xxx with Control Node IP

```bash
NODE_TOKEN=xxx
```
Replace xxx with Control Node Token

```bash
NODE_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
curl -sfL https://get.k3s.io | K3S_URL=https://$SERVER_HOST:6443 K3S_TOKEN=$NODE_TOKEN sh -
```

# Control Cluster

##### Control Node

```bash
sudo systemctl start k3s
sudo systemctl stop k3s
```

##### Worker Node

```bash
sudo systemctl start k3s-agent
sudo systemctl stop k3s-agent
```

##### External Client Access

https://docs.k3s.io/cluster-access


# Istio Setup

https://istio.io/latest/docs/setup/getting-started/


# Expose Kiali

https://istio.io/latest/docs/tasks/observability/gateways/


# Dashboard Setup

https://docs.k3s.io/installation/kube-dashboard#:~:text=To%20access%20the%20Dashboard%20you,the%20admin%2Duser%20Bearer%20Token

[Download Dashboard Gateway Manifest](file://dashboard-gateway.yaml "Download Dashboard Gateway Manifest")

```bash
kubectl create -f dashboard-gateway.yaml
```

Set `dashboard.example.com` into `/etc/hosts` file with control node IP



