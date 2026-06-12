# Estágio 1: Build completo com Maven e Java 21 (Estável e suportado por padrão)
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .

# Comando robusto que entra na pasta interna onde está o código e compila
RUN cd cqrs-pattern && mvn clean package -DskipTests

# Estágio 2: Execução leve e otimizada para o plano Free
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=build /app/cqrs-pattern/target/*.jar app.jar
EXPOSE 8080

ENTRYPOINT ["java", "-XX:ActiveProcessorCount=1", "-Xmx300m", "-jar", "app.jar"]
