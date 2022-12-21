# Create K3s Installation

##### Requirements

- Ansible
- Terraform
- Multipass

# Create Multipass Hosts

##### Create Host

```bash
$ multipass find
$ multipass launch -n HOSTNAME -m 2G -d 30G -c 2 jammy
```

Replace HOSTNAME with unique host name

##### Open Shell

```bash
$ multipass shell HOSTNAME
```

##### Start/Stop Host

```bash
$ multipass start [HOSTNAME]
$ multipass stop [HOSTNAME]
```

`HOSTNAME` is optional. If not specified it will start/stop all available instances

# SSH Keys
Append `~.ssh/id_rsa.pub` from controller host to each host's `~/.ssh/authorized_keys`

```bash
$ tee -a .ssh/authorized_keys <<EOF
....... (content of .ssh/id_rsa.pub)
EOF
```

Verify SSH Access for each host by opening ssh connection
```bash
$ ssh ubuntu@<<HOST_IP>>
```

In case of connection issues verify `.ssh/known_hosts` on controller's host

# K3s Cluster Setup

```bash
$ cd ansible
```

Set IP addresses for server and agent hosts in `inventory.yaml`

Verify Ansible Ping

```bash
$ ansible all -i inventory.yaml -m ping
```

### Deploy K3s Server

```bash
$ ansible-playbook -i inventory.yaml playbook-k3s-server.yaml
```

Upon successful server installation copy `k3s.yaml` to kubectl config location on controller's host
```bash
$ cp /tmp/k3s.yaml ~/.kube/config
```
### Deploy K3s Agents

```bash
$ ansible-playbook -i inventory.yaml playbook-k3s-agent.yaml
```

### Deploy Istio

```bash
$ ansible-playbook -i inventory.yaml playbook-k3s-istio.yaml
```

##### Verify K3s Cluster

```bash
$ watch kubectl get node
NAME             STATUS   ROLES                  AGE     VERSION
k3s-test         Ready    control-plane,master   29m     v1.25.4+k3s1
k3s-test-agent   Ready    <none>                 2m17s   v1.25.4+k3s1
```
Wait until all nodes are in Ready status

# Configure K3s Cluster

### Configure K8s Dashboard
```bash
$ cd terraform/k8s-dashboard
```
Dashboard default ingress domain is `k3s.local` as defined in terraform `variables.tf` file

Run Terraform
```bash
$ terraform init
...
$ terraform plan
...
$ terraform apply
...
```

Add entries to `/etc/hosts` on controller host
```bash
<<SERVER_HOST_IP>> dashboard.k3s.local
```

Create access token for dashboard login. Needs to be executed on server host

```bash
$ kubectl -n kubernetes-dashboard create token admin-user
```

### Configure Istio

```bash
$ cd terraform/istio
```

Istio default ingress domain is `k3s.local` as defined in terraform `variables.tf` file

Run Terraform
```bash
$ terraform init
...
$ terraform plan
...
$ terraform apply
...
```

Add entries to `/etc/hosts` on controller host
```bash
<<SERVER_HOST_IP>> kiali.k3s.local
<<SERVER_HOST_IP>> grafana.k3s.local
<<SERVER_HOST_IP>> prometheus.k3s.local
<<SERVER_HOST_IP>> tracking.k3s.local
```
# Access Dashboards

Open Kubernetes API proxy

```bash
$ kubectl proxy
Starting to serve on 127.0.0.1:8001
```
[Access Kubernetes Dashboard via Proxy](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login)

[Access Kubernetes Dashboard Direct Link](https://dashboard.k3s.local)

[Access Kiali Dashboard Link via Proxy](http://localhost:8001/api/v1/namespaces/istio-system/services/kiali:20001/proxy/kiali)

[Access Kiali Dashboard Direct Link](https://kiali.k3s.local)