pipeline {
    agent {label 'maven'}


environment {
    PATH = "/opt/apache-maven-3.9.5/bin:$PATH"
}
    stages {
        stage("Build") {
            steps {
                echo "------- Build started --------"
                sh 'mvn clean deploy -Dmaven.test.skip=true'
                echo "------- Build completed --------"
            }
        }

        stage("Test") {
            steps {
                echo "------- Unit test started --------"
                sh 'mvn surefire-report:report'
                echo "------- Unit test completed --------"
            }
        }

        stage("SonarQube-analysis") {
            steps { 
                environment {
                    scannerHome = tool 'sonarqube-scanner' // Sonar Scanner name should match the tool definition.
                }
            }
        }
    }
}
