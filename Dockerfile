# Estágio 1: Build usando JDK 25 oficial e instalando o Maven manualmente
FROM openjdk:25-jdk-slim AS build
WORKDIR /app

# Instala o Maven dentro do container com OpenJDK 25
RUN apt-get update && apt-get install -y maven findutils

COPY . .

# Localiza o pom.xml, entra na pasta e força o build com o JDK 25 correto
RUN POM_PATH=$(find . -name "pom.xml" -print -quit) && \
    DIR_PATH=$(dirname "$POM_PATH") && \
    cd "$DIR_PATH" && \
    mvn clean package -DskipTests && \
    mkdir -p /app/target_build && \
    cp target/*.jar /app/target_build/app.jar

# Estágio 2: Execução otimizada usando o JRE do OpenJDK 25
FROM openjdk:25-jdk-slim
WORKDIR /app
COPY --from=build /app/target_build/app.jar app.jar
EXPOSE 8080

# Restrições de memória para não estourar a cota gratuita do Render
ENTRYPOINT ["java", "-XX:ActiveProcessorCount=1", "-Xmx300m", "-jar", "app.jar"]
