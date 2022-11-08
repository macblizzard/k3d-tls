# Portainer Setup on a K3D cluster behind Traefik

```bash
helm repo add portainer https://portainer.github.io/k8s/
helm repo update
helm install --create-namespace -n portainer portainer portainer/portainer
```

Apply the portainer-svc-ingressroute.yaml manifest.

To update portainer version:
helm upgrade -n portainer portainer portainer/portainer
