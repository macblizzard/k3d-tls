# K3D Setup with MetalLB, Traefik and Cert-Manager

## Install Prerequisites
```bash
./env-setup.sh
```

## Setup k3d cluster with Kubectl and Helm
```bash
./run-k3d.sh
```

## Run the metallb+traefik+cm.sh script to install and configure MetalLB, Traefik and Cert-Manager
```bash
./metallb+traefik+cm.sh
```

## Final steps for activating Letsencrypt Staging/Production Certificates
- Update secret-cf-token.yaml from inside Cert-Manager/issuers and apply that"
- Then update letsencrypt-staging.yaml from inside Cert-Manager/issuers and apply that"
- Finally rename and update local-example-com.yaml from inside Cert-Manager/certificates/staging and apply that"
- Check status of validation by - watch kubectl get challenges - wait till it shows valid"
- After that try applying some manifests from manifests directory. Remember to update the Host and secretName"
- To find the secretName use - kubectl get secrets"
- Once the staging certificate is tested to be working, use Cert-Manager/certificates/production and proceed"

## To check the generated certificate use the following command
```bash
echo | openssl s_client -showcerts -servername nginx.example.com -connect nginx.example.com:443 2>/dev/null | openssl x509 -inform pem -noout -text
```
