# --- ÉTAPE 1 : Build du Frontend ---
# On utilise votre Dockerfile situé dans /front
FROM node:18 AS frontend-build
WORKDIR /app/front
COPY front/package*.json ./
RUN npm install
COPY front/ ./
RUN npm run build --configuration=production

# --- ÉTAPE 2 : Build du Backend ---
# On utilise votre Dockerfile situé dans /back
FROM maven:3.8.5-openjdk-17 AS backend-build
WORKDIR /app/back
COPY back/pom.xml ./
RUN mvn dependency:go-offline
COPY back/src ./src
RUN mvn clean package -DskipTests

# --- ÉTAPE 3 : Image Finale ---
# On assemble le tout dans une image légère
FROM openjdk:17-jdk-slim
WORKDIR /app
# On récupère le JAR du back
COPY --from=backend-build /app/back/target/*.jar app.jar
# (Optionnel) On récupère le build du front si Java doit le servir
# COPY --from=frontend-build /app/front/dist/votre-app /app/static

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]