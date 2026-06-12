# Estágio 1: Build leve com Maven
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .
# A mágica está aqui: mandamos o Maven rodar apontando para o arquivo pom.xml da pasta correta
RUN mvn -f cqrs-pattern/pom.xml clean package -DskipTests

# Estágio 2: Execução otimizada para servidores pequenos
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
# Ajustamos o caminho de onde o arquivo .jar gerado será copiado
COPY --from=build /app/cqrs-pattern/target/*.jar app.jar
EXPOSE 8080

ENTRYPOINT ["java", "-XX:ActiveProcessorCount=1", "-Xmx300m", "-jar", "app.jar"]
