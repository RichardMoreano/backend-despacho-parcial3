
# Springboot-API-REST-DESPACHO - Despliegue EKS (instrucciones en español)

Pequeña guía estilo estudiante para correr local y desplegar en EKS.

1) Pruebas locales (rápido)

En la raíz del workspace:

```bash
docker-compose up --build
```

Comentarios:
- Agrego healthchecks en los Dockerfiles y en docker-compose para que sea fácil detectar si algo falla.
- Frontend: http://localhost
- Backend Ventas: http://localhost:8080
- Backend Despacho: http://localhost:8081

2) Requisitos para EKS y despliegue desde GitHub Actions

Secrets que debes crear en el repo de GitHub (Settings -> Secrets):
- AWS_ROLE_TO_ASSUME: ARN del role que GitHub Actions usará (con permisos ECR/EKS).
- AWS_REGION: ej. us-east-1
- ECR_REPO: URI del repo ECR (ej. 123456789012.dkr.ecr.us-east-1.amazonaws.com/backend-despacho)
- EKS_CLUSTER_NAME: nombre del cluster EKS

Cómo funciona la Action:
- Construye la imagen y la sube a ECR.
- Usa `aws-actions/eks-update-kubeconfig` para configurar kubectl en el runner.
- Actualiza el Deployment con `kubectl set image` o aplica `k8s/deployment.yaml` si no existe.

3) Notas y buenas prácticas

- Uso multi-stage para reducir el tamaño de la imagen.
- Agrego healthcheck para que Kubernetes sepa si el pod está listo.
- No guardes las credenciales de la BD en el repo: usa AWS Secrets Manager y monta secrets en k8s.

