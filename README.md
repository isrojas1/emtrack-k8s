# emtrack-k8s

Este repositorio contiene los scripts, documentación, y ficheros complementarios
necesarios para poder realizar el despliegue del trabajo de fin de grado.

## Requisitos

Necesitaremos un cluster kubernetes, este repositorio asume que se utiliza
k3s, el cual puede ser instalado siguiendo su
[documentación oficial](https://docs.k3s.io/installation).
Hasta el momento, solo se ha probado a desplegar en un cluster de un solo
nodo.

La máquina encargada de desplegar, necesitará instalado:
- Kubectl
- Helm
- Docker

Además, debe tener acceso al cluster teniendo su respectivo archivo kube config.

Deberán existir las siguientes imágenes compiladas:
- EMTScraper Buslocation v0.2.2: `IP_NODO_CLUSTER:30002/library/buslocation:0.2.2 `
- EMTScraper Routes v0.2.3: `IP_NODO_CLUSTER:30002/library/routes:0.2.3`
- EMTMetrics v0.2.0: `IP_NODO_CLUSTER:30002/library/emtmetrics:0.2.0`

Estas imágenes se pueden generar a partir de los repositorios (ver su README para instrucciones):
- https://github.com/isrojas1/EMTScraper
- https://github.com/isrojas1/EMTMetrics

## Despliegue

- IMPORTANTE: Asegurarse de que el cluster configurado en el kubeconfig es el que queremos.

- Copiar .env.template y editar con nuestros valores

- Opcional: Ejecutar `bash scripts/harbor-deploy.sh <ENV_FILE>` para desplegar harbor, un
registro de contenedores local de codigo abierto que se ejecutará en nuestro
cluster. De esta forma podremos alojar las imágenes docker de nuestros
contenedores. También es posible obviar este paso y usar un registro de nuestra
preferencia, ya sea local o en la nube. Este script asume que se usa k3s y requiere acceso
ssh al nodo del cluster. Es necesario acceso ssh para su ejecución (recomendado acceso mediante clave privada)

- Ejecutar `bash scripts/tfg-deploy.sh <ENV_FILE>`.

- Iniciar sesión en Grafana (usuario: admin, contraseña: admin). Establecer nueva contraseña, aquella usada en el archivo de entorno como GRAFANA_API_PASSWORD. Configurar en Plugins -> Opentwins los ajustes pertinentes.
![alt text](docs/images/grafana-ditto-config.png)

- Ejecutar `bash scripts/import-resources.sh <ENV_FILE>`.

## Actualización

- Ejecutar `bash scripts/tfg-deploy.sh <ENV_FILE>`.
- Ejecutar `bash scripts/import-resources.sh <ENV_FILE>`.
