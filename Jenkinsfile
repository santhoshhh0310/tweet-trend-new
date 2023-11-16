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
            environment {
                scannerHome = tool 'sonarqube-scanner' // Sonar Scanner name should match the tool definition.
            }
            steps {                                 // in the steps we are adding our sonar cube server that is with Sonar Cube environment.
            withSonarQubeEnv('sonarqube-server') {
                sh "${scannerHome}/bin/sonar-scanner" // This is going to communicate with our sonar cube server and send the analysis report.
            }
        }
    }
}
}
