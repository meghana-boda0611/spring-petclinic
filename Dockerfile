# Use OpenJDK 17 as base image
FROM openjdk:17-jdk-slim

# Set working directory inside the container
WORKDIR /app

# Copy the built Spring Boot JAR
COPY target/spring-petclinic-*.jar spring-petclinic.jar

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "spring-petclinic.jar"]

