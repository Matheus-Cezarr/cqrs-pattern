# Estágio 1: Build forçado com Java 21
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .

# O SEGREDO: Forçamos as propriedades do compilador via argumento de linha de comando
RUN POM_PATH=$(find . -name "pom.xml" -print -quit) && \
    DIR_PATH=$(dirname "$POM_PATH") && \
    cd "$DIR_PATH" && \
    mvn clean package -DskipTests \
    -Dmaven.compiler.source=21 \
    -Dmaven.compiler.target=21 \
    -Dmaven.compiler.release=21 && \
    mkdir -p /app/target_build && \
    cp target/*.jar /app/target_build/app.jar

# Estágio 2: Execução estável
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=build /app/target_build/app.jar app.jar
EXPOSE 8080

ENTRYPOINT ["java", "-XX:ActiveProcessorCount=1", "-Xmx300m", "-jar", "app.jar"]
