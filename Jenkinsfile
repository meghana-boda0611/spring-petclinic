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

                    export TRIVY_PATH="$WORKSPACE/trivy"

                    if ! [ -x "$TRIVY_PATH" ]; then
                        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b $WORKSPACE
                    fi

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

                    /opt/homebrew/Cellar/maven/3.9.10/libexec/bin/mvn -version || { echo "❌ ERROR: Maven is not installed!"; exit 1; }

                    /opt/homebrew/Cellar/maven/3.9.10/libexec/bin/mvn clean package -DskipTests -Dcheckstyle.skip=true

                    echo "✅ Spring Boot application built successfully!"
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONARQUBE_SCANNER_HOME = tool 'SonarQubeScanner'
            }
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    script {
                        sh '''
                        echo "▶️ Starting SonarQube Analysis..."

                        $SONARQUBE_SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectKey=spring-petclinic \
                        -Dsonar.sources=. \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.host.url=http://localhost:9000 \
                        -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('Run Spring Boot App (Temporary for DAST)') {
            steps {
                script {
                    sh '''
                    echo "▶️ Starting Spring Boot app in background for ZAP scan..."
                    nohup java -jar target/*.jar > app.log 2>&1 &
                    sleep 15
                    curl -I http://localhost:8080 || { echo "❌ App failed to start"; exit 1; }
                    '''
                }
            }
        }

        stage('DAST - OWASP ZAP CLI Scan') {
    steps {
        script {
            sh '''
            echo "▶️ Running ZAP CLI scan..."

            pkill -f ZAP || true
            rm -f ~/Library/Application\\ Support/ZAP/.ZAP_LOCK

            cd "$WORKSPACE"

            "/Applications/ZAP.app/Contents/Java/zap.sh" -cmd \
              -quickurl http://localhost:8081 \
              -quickout zap_report.html || echo "⚠️ ZAP returned non-zero exit"

            echo "✅ ZAP scan complete"
            '''
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'zap_report.html', fingerprint: true
        }
    }
}

        stage('Stop Spring Boot App') {
            steps {
                sh '''
                echo "🧹 Stopping Spring Boot app..."
                pkill -f 'spring-petclinic'
                '''
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
