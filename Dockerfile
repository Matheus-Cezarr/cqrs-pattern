# Estágio 1: Build usando o JDK 25 da Eclipse Temurin (Ubuntu Jammy)
FROM eclipse-temurin:25-jdk-jammy AS build
WORKDIR /app

# Instala o Maven dentro do container
RUN apt-get update && apt-get install -y maven

COPY . .

# Localiza o pom.xml, entra na pasta e faz o build com o JDK 25 correto
RUN POM_PATH=$(find . -name "pom.xml" -print -quit) && \
    DIR_PATH=$(dirname "$POM_PATH") && \
    cd "$DIR_PATH" && \
    mvn clean package -DskipTests && \
    mkdir -p /app/target_build && \
    cp target/*.jar /app/target_build/app.jar

# Estágio 2: Execução otimizada usando o JRE do Java 25 da Temurin
FROM eclipse-temurin:25-jre-jammy
WORKDIR /app
COPY --from=build /app/target_build/app.jar app.jar
EXPOSE 8080

# Restrições de memória para não estourar a cota gratuita do Render
ENTRYPOINT ["java", "-XX:ActiveProcessorCount=1", "-Xmx300m", "-jar", "app.jar"]
