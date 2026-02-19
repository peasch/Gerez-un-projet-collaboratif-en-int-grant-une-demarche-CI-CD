# --- ÉTAPE 1 : Build du Frontend ---
FROM node:18 AS build-front
WORKDIR /app/front
COPY front/package*.json ./
RUN npm install
COPY front/ ./
RUN npm run build --configuration=production

# --- ÉTAPE 2 : Build du Backend ---
FROM maven:3.9.6-eclipse-temurin-17 AS build-back
WORKDIR /app/back
COPY back/pom.xml ./
RUN mvn dependency:go-offline
COPY back/src ./src
RUN mvn clean package -DskipTests

# --- ÉTAPE 3 : Image Finale (Exécution) ---
# Utilisation d'une image maintenue et sécurisée
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# On récupère le JAR (vérifiez bien que le chemin /target/*.jar est correct)
COPY --from=build-back /app/back/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]