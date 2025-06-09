pipeline {
    agent any


    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/meghana-boda0611/spring-petclinic.git'
            }
        }

        stage('SCA Security Scan') {
            steps {
                script {
                    sh '''
                    echo "▶️ Running Security Scan with Trivy..."

                    # Define a user-writable directory for Trivy installation
                    export TRIVY_PATH="$WORKSPACE/trivy"
                    
                    # Install Trivy if not already installed
                    if ! [ -x "$TRIVY_PATH" ]; then
                        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b $WORKSPACE
                    fi

                    # Run security scan using the local Trivy binary
                    $TRIVY_PATH fs --exit-code 0 --severity HIGH,CRITICAL .
                    '''
                }
            }
        }


        stage('Build Spring Boot Application') {
            steps {
                script {
                    sh '''
                    echo "▶️ Building Spring Boot Application..."
                    # Ensure Java and Maven are available
                    java -version || { echo "❌ ERROR: Java is not installed!"; exit 1; }
                    mvn -version || { echo "❌ ERROR: Maven is not installed!"; exit 1; }

                    # Build Spring Boot JAR (skip Checkstyle validation)
                    mvn clean package -DskipTests -Dcheckstyle.skip=true

                    echo "✅ Spring Boot application built successfully!"
                    '''
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_Credentials']]) {
                        sh '''
                        echo "▶️ Ensuring Docker Buildx is enabled..."
                        docker buildx create --use || true

                        echo "▶️ Building Multi-Platform Docker Image..."
                        docker buildx build --platform linux/amd64 -t $ECR_REPO:$IMAGE_TAG --push .

                        echo "✅ Docker image pushed successfully!"
                        '''
                    }
                }
            }
        }

    }

    post {
        success {
            echo "✅ Push successful!"
        }
        failure {
            echo "❌ Push failed. Check logs!"
        }
    }
}
