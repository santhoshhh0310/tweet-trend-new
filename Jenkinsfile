pipeline {
    agent { label 'maven' }

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
            environment {
                scannerHome = tool 'sonarqube-scanner' // Sonar Scanner name should match the tool definition.
            }
            steps {
                script {
                    // Use withSonarQubeEnv to configure the SonarQube environment
                    withSonarQubeEnv('sonarqube-server') {
                        // Run SonarQube analysis
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }
        stage("Quality Gate") {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
    }
}
