echo " "
echo "-------------------------------------------------"
echo ">> Make sure to configure k3d.yaml file properly"
echo "-------------------------------------------------"
echo " "

sudo mkdir -p /opt/k3dvol
k3d cluster create mycluster --config k3d.yaml --wait

echo "-------------------------------------------------"
echo ">> Exporting KUBECONFIG"
echo "-------------------------------------------------"
echo " "

sleep 10
export KUBECONFIG=$(k3d kubeconfig write mycluster)
echo "export KUBECONFIG=$(k3d kubeconfig write mycluster)" >> ~/.bashrc
source ~/.bashrc
