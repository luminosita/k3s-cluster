case $1 in
"init")
    ansible-playbook deploy.yaml -e env=$2 -e operation=init
    ;;
"destroy")
    ansible-playbook deploy.yaml -e env=$2 -e operation=destroy
    ;;
"create")
    ansible-playbook deploy.yaml -e env=$2 -e operation=create
    ;;
"create-plan")
    ansible-playbook deploy.yaml -e env=$2 -e operation=create-plan
    if [ ! -f "/tf/tmp/plan.tfplan" ]; then
        (
            cd tf
            terraform show tmp/plan.tfplan
        )
    fi
    ;;
"bootstrap")
    ansible-playbook k3s-all.yaml -e env=$2 -e operation=bootstrap -i inventory/inventory.yaml
    ;;
"k3s-server")
    ansible-playbook k3s-control.yaml -e env=$2 -e operation=k3s-server -i inventory/inventory.yaml
    ;;
"k3s-agent")
    ansible-playbook k3s-worker.yaml -e env=$2 -e operation=k3s-agent -i inventory/inventory.yaml
    ;;
"k3s-istio")
    ansible-playbook k3s-control.yaml -e env=$2 -e operation=k3s-istio -i inventory/inventory.yaml
    ;;
esac
