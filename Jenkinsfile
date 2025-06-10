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
                    java -version || { echo "❌ ERROR: Java is not installed!"; exit 1; }

                    # Use full path to Maven
                    /opt/homebrew/Cellar/maven/3.9.10/libexec/bin/mvn -version || { echo "❌ ERROR: Maven is not installed!"; exit 1; }

                    /opt/homebrew/Cellar/maven/3.9.10/libexec/bin/mvn clean package -DskipTests -Dcheckstyle.skip=true

                    echo "✅ Spring Boot application built successfully!"
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONARQUBE_SCANNER_HOME = tool 'SonarQubeScanner''  // Name of your SonarQube scanner tool configured in Jenkins
            }
            steps {
                script {
                    sh '''
                    echo "▶️ Starting SonarQube Analysis..."

                    $SONARQUBE_SCANNER_HOME/bin/sonar-scanner \
                      -Dsonar.projectKey=spring-petclinic \
                      -Dsonar.sources=. \
                      -Dsonar.host.url=http://localhost:9000 \
                      -Dsonar.login=$SONAR_TOKEN

                    echo "✅ SonarQube analysis completed!"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs!"
        }
    }
}
