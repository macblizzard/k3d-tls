# AdGuard Home Setup on a K3D cluster behind Traefik

Make sure that the k3d cluster was started with LoadBalancer port-forwarding for 4443:4443 along with 80 and 443.
If it wasn't then add the port 4443 manually with following command:

```bash
k3d node edit k3d-k3s-default-serverlb --port-add 4443:4443
```

Also, Make sure to start k3d cluster with volume mounts:

```bash
k3d create --name "k3d-cluster" --volume /opt/k3dvol:/opt/k3dvol --publish "80:80" --workers 2
```

Or, add the volume mounts to k3d config file before starting k3d cluster.


## Method 1 - Setup Adguard Home using Helm template

```bash
helm repo add k8s-at-home https://k8s-at-home.com/charts/
helm repo update
```

Changes required on the adguard-helm-values.yaml file:
- Under env, change TZ to your timezone
- Under volumeSpec - secret, put the TLS secret name in place of "local-example-com-tls"
- Under config - users, change user admin to your user and change the password
- Generate password using "htpasswd -B -n -b admin password" format
- If htpasswd is not installed on system, install it by "sudo apt install apache2-utils -y"
- TLS is enabled by default, just change the "server_name" to your adguard domain name


And finally, install the adguard-home helm chart 
```bash
helm install adguard-home k8s-at-home/adguard-home --values adguard-helm-values.yaml
```

Now, update the adguard-ingressroute-helm.yaml as required and apply it to add adguard-home ingressroute:
```bash
kubectl apply -f adguard-ingressroute-helm.yaml
```

To test if doh is working:
```bash
curl --doh-url https://adguard.local.example.com:4443/dns-query/ https://google.com
```


## Method 2 - Setup Adguard Home using Manifest

Assuming the k3d cluster was created with volume mounts to /opt/k3dvol/ - 
Create a directory on host under /opt/k3dvol/adguardhome, and copy the attached AdGuardHome.yaml to that directory.

```bash
sudo mkdir -p /opt/k3dvol/adguardhome/conf
sudo cp AdGuardHome.yaml /opt/k3dvol/adguardhome/conf/
```

Changes required on the AdGuardHome.yaml file:
- Under users, change user admin to your user and change the password
- Generate password using "htpasswd -B -n -b admin password" format
- If htpasswd is not installed on system, install it by "sudo apt install apache2-utils -y"
- TLS is enabled by default, just change the "server_name" to your adguard domain name

Update adguard-deployment.yaml as required and apply to deploy Adguardhome:
```bash
kubectl apply -f adguard-deployment.yaml
```

Update adguard-svc-ingressroute.yaml as required and apply to setup service and ingressroute for Adguardhome deployment:
```bash
kubectl apply -f adguard-svc-ingressroute.yaml
```

To test if doh is working:
```bash
curl --doh-url https://adguard.local.example.com:4443/dns-query/ https://google.com
```

To upgrade Adguard-home version:
1. Modify adguard-deployment.yaml file and change the version number
2. Apply the updated manifest using "kubectl apply -f adguard-deployment.yaml"
3. Apply the service file again using "kubectl apply -f adguard-svc-ingressroute.yaml"

In case of any issue with the update you can use the following command:
```bash
kubectl rollout undo deployment/adguard-home
```


## Extra - For Testing

To find the traefik generated certificate crt file for the adguard subdomain tls.crt and save to /tmp/tls.crt:
```bash
kubectl get secret local-example-com-tls -o jsonpath='{.data}'  | awk -F: '{ print $2 }' | tr -d ',""' | sed 's/tls.key//' | base64 --decode > /tmp/tls.crt
```

To find the traefik generated certificate key file for the adguard subdomain tls.key and save to /tmp/tls.key:
```bash
kubectl get secret local-example-com-tls -o jsonpath='{.data}'  | awk -F: '{ print $3 }' | tr -d '"}' | base64 --decode > /tmp/tls.key
```

Add the tls.crt and tls.key to a configMap:
```bash
kubectl create configmap adguard-tls --from-file=/tmp/tls.crt --from-file=/tmp/tls.key
```

Check cert validity:
```bash
openssl x509 -in /tmp/tls.crt -text -noout
```
