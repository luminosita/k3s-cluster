# Create K3s Installation

##### Requirements

- Ansible 
- Vagrant
- Terraform
- Vagrant VMWare plugin

```bash
$ brew install ansible
$ brew install vagrant
$ brew install terraform

$ vagrant plugin install vagrant-vmware-desktop
```

### Create Cluster Nodes

Define cluster nodes in `host_vars/localhost.yaml`

Initialise Vagrant environment

```bash
$ sh start.sh vg-init staging
```
It will create `hosts.yaml` file in `vagrant/.vagrant` folder and `k3s-cluster-inventory.yaml` in `inventory` folder. `inventory/k3s-cluster-inventory.yaml` drives the rest of Ansible installations of hosts

For VirtualBox:
```bash
$ cd vagrant
$ vagrant up
```

For VMWare Fusion:

Create Vagrant VMs without provisioning. Shell provisioner causes some issues with `vmware_fusion` Vagrant provider. Creation of `.vagrant/output` is important

```bash
$ cd vagrant
$ vagrant up > .vagrant/output | tail -f .vagrant/output
```

Bootstrap VMs. Solves the issue with `vmware_fusion` Vagrant provider and static IP addresses for VMs. It creates provisioning scripts to configure static IP addresses.

```bash
$ sh start.sh vg-bootstrap staging

$ cd vagrant/.vagrant/scripts
$ sh upload-staging.sh
$ sh bootstrap-hosts-staging.sh
```

For testing new static IP addresses use the following script

```bash
$ sh test-hosts-staging.sh
```

### Install K3s Componentes

Bootstrap all cluster nodes

```bash
$ sh start.sh k3s-bootstrap staging
```

Install K3s Server on control nodes

```bash
$ sh start.sh k3s-server staging
```

Install K3s Agent on worker nodes

```bash
$ sh start.sh k3s-agent staging
```

Install K3s Istio components on control nodes

```bash
$ sh start.sh k3s-istio staging
```

Upon successful server installation copy `k3s.yaml` to kubectl config location on controller's host

#### Verify K3s installation

```bash
$ cp /tmp/k3s.yaml ~/.kube/config
```

Verify connection to K3s cluster

```bash
$ watch kubectl get node
NAME             STATUS   ROLES                  AGE     VERSION
k3s-test         Ready    control-plane,master   29m     v1.25.4+k3s1
k3s-test-agent   Ready    <none>                 2m17s   v1.25.4+k3s1
```
Wait until all nodes are in Ready status

### Configure K3s Cluster

Initialise Terraform environment

```bash
$ sh start.sh tf-init staging
```

Install Modules (K8s Dashboard, Istio Cert Manager certificate, Istio Addons, Istio Book Info samples application)

```bash
$ sh start.sh tf-plan staging "k8s-dashboard,istio-cert-manager,istio-addons,istio-bookinfo"

$ sh start.sh tf-apply staging
```
Add entries to `/etc/hosts` on controller host
```bash
[SERVER_HOST_IP] dashboard.k3s.local

[SERVER_HOST_IP] kiali.k3s.local
[SERVER_HOST_IP] grafana.k3s.local
[SERVER_HOST_IP] prometheus.k3s.local
[SERVER_HOST_IP] tracking.k3s.local
```

Create access token for dashboard login. Needs to be executed on server host

```bash
$ kubectl -n kubernetes-dashboard create token admin-user
```

### Access Dashboards

Open Kubernetes API proxy

```bash
$ kubectl proxy
Starting to serve on 127.0.0.1:8001
```
[Access Kubernetes Dashboard via Proxy](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login)

[Access Kubernetes Dashboard Direct Link](https://dashboard.k3s.local)

[Access Kiali Dashboard Link via Proxy](http://localhost:8001/api/v1/namespaces/istio-system/services/kiali:20001/proxy/kiali)

[Access Kiali Dashboard Direct Link](https://kiali.k3s.local)

[Access Istio Book Info Sample App](http://k3s.local/productpage)