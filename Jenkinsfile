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
                    java -version || { echo "❌ Java not found!"; exit 1; }
                    /opt/homebrew/Cellar/maven/3.9.10/libexec/bin/mvn -version || { echo "❌ Maven not found!"; exit 1; }
                    /opt/homebrew/Cellar/maven/3.9.10/libexec/bin/mvn clean package -DskipTests -Dcheckstyle.skip=true
                    echo "✅ Build successful!"
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
                        echo "▶️ SonarQube Analysis..."
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

        stage('Run Spring Boot App (for DAST)') {
            steps {
                script {
                    sh '''
                    echo "▶️ Starting Spring Boot app on port 8081..."
                    nohup java -jar target/*.jar --server.port=8081 > app.log 2>&1 &
                    sleep 15
                    curl -I http://localhost:8081 || { echo "❌ App did not start"; exit 1; }
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
                    rm -f "$HOME/Library/Application Support/ZAP/.ZAP_LOCK"

                    sleep 10  # Allow app to stabilize

                    [ -x "/Applications/ZAP.app/Contents/Java/zap.sh" ] || { echo "❌ ZAP CLI not found!"; exit 1; }

                    cd "$WORKSPACE"

                    "/Applications/ZAP.app/Contents/Java/zap.sh" -cmd \
                      -quickurl http://localhost:8081/owners \
                      -quickout "$WORKSPACE/zap_report.html" || echo "⚠️ ZAP returned non-zero exit"

                    echo "✅ ZAP scan completed!"
                    '''
                }
            }
            
            post {
                always {
                    archiveArtifacts artifacts: 'zap_report.html', fingerprint: true
                }
            }
        }
        stage('Docker Build & Push to ECR') {
            environment {
                AWS_REGION = 'us-east-1' // Change if needed
                REPO_NAME  = 'springboot-petclinic' // Change if needed
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'AWS_Credentials'
                ]]) {
                    script {
                        sh '''
                        echo "🐳 Logging into AWS ECR..."
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query "Account" --output text).dkr.ecr.$AWS_REGION.amazonaws.com

                        ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
                        IMAGE_NAME=$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME

                        echo "🐳 Setting up Docker Buildx (multi-platform build)..."
                        docker buildx create --use || true

                        echo "🐳 Building and pushing Docker image for linux/amd64..."
                        docker buildx build --platform linux/amd64 -t $IMAGE_NAME:latest --push .

                        echo "✅ Docker image pushed to ECR: $IMAGE_NAME:latest"
                        '''
                    }
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
            mail to: 'vivekmokkarala09@gmail.com',
                subject: "✅ Jenkins Build Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "The Jenkins build for ${env.JOB_NAME} #${env.BUILD_NUMBER} was successful.\nCheck details at ${env.BUILD_URL}"
        }
        failure {
            echo "❌ Pipeline failed. Check logs!"
            mail to: 'vivekmokkarala09@gmail.com',
                subject: "❌ Jenkins Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "The Jenkins build for ${env.JOB_NAME} #${env.BUILD_NUMBER} has failed.\nCheck details at ${env.BUILD_URL}"
        }
        always {
            echo "📧 Email notification sent"
        }
    }   
}
