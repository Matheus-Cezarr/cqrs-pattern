# Estágio 1: Build com Maven e Java 22
FROM maven:3.9.8-eclipse-temurin-22 AS build
WORKDIR /app
COPY . .

# Procura o pom.xml dinamicamente e compila
RUN POM_PATH=$(find . -name "pom.xml" -print -quit) && \
    DIR_PATH=$(dirname "$POM_PATH") && \
    cd "$DIR_PATH" && \
    mvn clean package -DskipTests && \
    mkdir -p /app/target_build && \
    cp target/*.jar /app/target_build/app.jar

# Estágio 2: Execução com JRE 22
FROM eclipse-temurin:22-jre-jammy
WORKDIR /app
COPY --from=build /app/target_build/app.jar app.jar
EXPOSE 8080

ENTRYPOINT ["java", "-XX:ActiveProcessorCount=1", "-Xmx300m", "-jar", "app.jar"]
