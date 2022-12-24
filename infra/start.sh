case $1 in
"help")
    echo "usage: start.sh operation environment [vm_count|module]"
    echo "positional arguments:"
    echo "  operation"
    echo "    cleanup               deletes all temporary and working folders"
    echo "    vg-init               init Vagrant environment"
    echo "    vg-inventory          creates Ansible inventory from Vagrant ssh_config"
    echo "    tf-init               initializes Terraform environment"
    echo "    tf-plan               creates plan for Terraform resources"
    echo "    tf-apply              applies changes to Terraform resources"
    echo "    tf-destroys           destroys Terraform resources"
    echo "    k3s-bootstrap         bootstraps K3s VMs"
    echo "    k3s-server            deployes K3s Server"
    echo "    k3s-agent             deployes K3s Agent"
    echo "    k3s-istio             deployes K3s Istio"
    echo "  "
    echo "  environment"
    echo "    development           development environment"
    echo "    staging               staging environment"
    echo "    production            production environment"
    echo "  "
    echo "  vm_count                number of VMs to create"
    echo "  "
    echo "  module"
    echo "    k8s-dashboard         Kubernetes Dashboard"
    echo "    istio-cert-manager    Cert Manager"
    echo "    istio-addons          Istio Addons (kiali, prometheus, grafana, jaeger)"
    echo "    istio-bookinfo        Istio Bookinfo example application"
    ;;
"cleanup")
    if [ -f terraform/terraform.tfstate.d ]; then rm -rf terraform/terraform.tfstate.d; fi
    if [ -e terraform/.terraform ]; then rm -rf terraform/.terraform; fi
    if [ -e terraform/.terraform.lock.hcl ]; then rm  terraform/.terraform.lock.hcl; fi
    if [ -f terraform/tmp ]; then rm -rf terraform/tmp; fi
    if [ -e vagrant/.vagrant ]; then rm -rf vagrant/.vagrant; fi
    if [ -f roles/vagrant/vars/main.yaml ]; then rm -rf roles/vagrant/vars/main.yaml; fi
    if [ -f inventory/k3s-cluster-inventory.yaml ]; then rm -rf inventory/k3s-cluster-inventory.yaml; fi
    ;;
"vg-init")
    ansible-playbook vagrant.yaml -e env=$2 -e operation=init -e vm_count=$3
    ;;
"vg-inventory")
    ansible-playbook vagrant.yaml -e env=$2 -e operation=inventory-vars
    ansible-playbook vagrant.yaml -e env=$2 -e operation=inventory
    ;;
"tf-init")
    ansible-playbook terraform.yaml -e env=$2 -e operation=init
    ;;
"tf-destroy")
    ansible-playbook terraform.yaml -e env=$2 -e operation=destroy
    ;;
"tf-apply")
    ansible-playbook terraform.yaml -e env=$2 -e operation=apply
    ;;
"tf-plan")
    ansible-playbook terraform.yaml -e env=$2 -e operation=plan -e module=$3

    if [ ! -f "/terraform/tmp/plan.tfplan" ]; then
        (
            cd terraform
            terraform show tmp/plan.tfplan
        )
    fi
    ;;
"k3s-bootstrap")
    ansible-playbook k3s-all.yaml -e env=$2 -e operation=bootstrap -i inventory/k3s-cluster-inventory.yaml
    ;;
"k3s-server")
    ansible-playbook k3s-control.yaml -e env=$2 -e operation=server -i inventory/k3s-cluster-inventory.yaml
    ;;
"k3s-agent")
    ansible-playbook k3s-worker.yaml -e env=$2 -e operation=agent -i inventory/k3s-cluster-inventory.yaml
    ;;
"k3s-istio")
    ansible-playbook k3s-control.yaml -e env=$2 -e operation=istio -i inventory/k3s-cluster-inventory.yaml
    ;;
esac