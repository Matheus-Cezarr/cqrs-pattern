# Estágio 1: Build leve com Maven
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .

# O SEGREDO: Procura onde está o pom.xml dinamicamente, entra na pasta e faz o build
RUN POM_PATH=$(find . -name "pom.xml" -print -quit) && \
    DIR_PATH=$(dirname "$POM_PATH") && \
    cd "$DIR_PATH" && \
    mvn clean package -DskipTests && \
    mkdir -p /app/target_build && \
    cp target/*.jar /app/target_build/app.jar

# Estágio 2: Execução otimizada para servidores pequenos
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
# Copia o jar final que centralizamos no estágio anterior
COPY --from=build /app/target_build/app.jar app.jar
EXPOSE 8080

ENTRYPOINT ["java", "-XX:ActiveProcessorCount=1", "-Xmx300m", "-jar", "app.jar"]
