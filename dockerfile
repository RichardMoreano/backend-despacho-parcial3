# Igual que el anterior, solo cambia el puerto
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /app

# Uso multi-stage para reducir el tamaño final de la imagen.
# Primero copio el pom y el código para construir el JAR.
COPY pom.xml .
COPY src ./src

# Compilo la aplicación sin tests para acelerar iteraciones locales.
RUN mvn clean package -DskipTests -U

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Agrego un usuario no-root por seguridad y curl para healthchecks locales.
RUN addgroup -S spring && adduser -S spring -G spring && apk add --no-cache curl
USER spring

# Metadatos: reemplazar con tu repo/autor.
LABEL org.opencontainers.image.source="https://github.com/RichardMoreano/backend-despacho-parcial3"
LABEL org.opencontainers.image.maintainer="tu-email@ejemplo.com"

# Copio el artefacto construido desde el stage builder.
COPY --from=builder /app/target/*.jar app.jar

# Variables de entorno útiles para producción y ajustes de memoria.
ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xms256m -Xmx512m"

# Exponemos el puerto que usa Spring Boot en este proyecto.
EXPOSE 8081

# Agrego un healthcheck para que Kubernetes sepa si el pod está listo.
# Primero intento el endpoint /actuator/health (si está habilitado),
# si no, caigo al root /.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
	CMD curl -f http://localhost:8081/actuator/health || curl -f http://localhost:8081/ || exit 1

# ENTRYPOINT usando JAVA_OPTS para permitir ajustes desde la ejecución.
ENTRYPOINT ["sh","-c","exec java $JAVA_OPTS -jar /app/app.jar"]