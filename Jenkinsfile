def registry = 'https://cicdjfrog03.jfrog.io/'
def imageName = 'cicdjfrog03.jfrog.io/valaxy-docker/samtrend'
def version   = '2.1.2'

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
        stage("Jar Publish") {
        steps {
            script {
                    echo '<--------------- Jar Publish Started --------------->'
                     def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"Jfrog-cred"
                     def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                     def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "jarstaging/(*)",
                              "target": "libs-release-local/{1}",
                              "flat": "false",
                              "props" : "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
                     def buildInfo = server.upload(uploadSpec)
                     buildInfo.env.collect()
                     server.publishBuildInfo(buildInfo)
                     echo '<--------------- Jar Publish Ended --------------->'  
                }
                
            }
        }
        stage(" Docker Build ") {
        steps {
            script {
               echo '<--------------- Docker Build Started --------------->'
               app = docker.build(imageName+":"+version)
               echo '<--------------- Docker Build Ends --------------->'
            }
          }
        }
    
        stage (" Docker Publish "){
        steps {
            script {
                echo '<--------------- Docker Publish Started --------------->'  
                docker.withRegistry(registry, 'Jfrog-cred'){
                app.push()
                }    
                echo '<--------------- Docker Publish Ended --------------->'  
                }
            }
        }

    }
}
