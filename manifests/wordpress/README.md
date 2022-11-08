# Wordpress Setup on a K3D cluster behind Traefik

## Method 1 - Using Helm Chart

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

Setting up wordpress directly from helm along with mariadb is always giving error.
So, best way is setting up mariadb and wordpress separately.

First, save the helm values for mariadb:
```bash
helm show values bitnami/mariadb > /tmp/mariadb-values.yaml
```

Change the following and save:
```ini
auth:
  rootPassword: "ROOTPASSWORD"
  database: wp_db
  username: "USERNAME"
  password: "PASSWORD"
```

Now, install mariadb with the modified helm values:
```bash
helm install mariadb bitnami/mariadb --values /tmp/mariadb-values.yaml
```

Now, save the helm values for wordpress:
```bash
helm show values bitnami/wordpress > /tmp/wp-values.yaml
```

Change the following and save:
```ini
wordpressUsername: USERNAME
wordpressPassword: "PASSWORD"
allowEmptyPassword: false

mariadb:
  enabled: false

externalDatabase:
  host: mariadb
  port: 3306
  user: USERNAME
  password: "PASSWORD"
  database: wp_db
```

Now, install wordpress with modified helm values:
```bash
helm install wordpress bitnami/wordpress --values /tmp/wp-values.yaml
```

Finally, apply the wordpress-ingressroute.yaml manifest.

## Method 2 - Using Manifest

Modify the mariadb.yaml file as required and apply to install MariaDB:
```bash
kubectl apply -f mariadb.yaml
```

Modify the wordpress-net.yaml file as required and apply to install wordpress:
```bash
kubectl apply -f wordpress-net.yaml
```
