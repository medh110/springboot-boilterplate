# Stage 1: Build the application
FROM openjdk:17-jdk-alpine AS build

WORKDIR /app

COPY gradlew /app/
COPY gradle /app/gradle
COPY build.gradle settings.gradle /app/
COPY src /app/src
COPY config /app/config

RUN chmod +x gradlew && ./gradlew build


# Stage 2: Create the final runtime image
FROM openjdk:17-jdk-alpine

WORKDIR /app

COPY --from=build /app/build/libs/*.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
