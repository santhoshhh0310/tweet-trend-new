def registry = 'https://cicdjfrog03.jfrog.io/'
def imageName = 'cicdjfrog03.jfrog.io/valaxy-docker-local/samimage'
def version = '2.1.2'

pipeline {
    agent { label 'maven' }

    environment {
        PATH = "/opt/apache-maven-3.9.5/bin:$PATH"
        IMAGE_NAME = "${imageName}:${version}"
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
                     def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"Jfrog"
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
               app = docker.build(env.IMAGE_NAME)
               echo '<--------------- Docker Build Ends --------------->'
            }
          }
        }
    
        stage("Docker Publish") {
            steps {
                 script {
                     echo '<--------------- Docker Publish Started --------------->'  

                      // Use withDockerRegistry and provide credentials securely
                      withDockerRegistry(credentialsId: 'jenkins11', url: registry) {
                          // Use --password-stdin for improved security
                          docker.image(imageName + ":" + version).withRun { c ->
                            sh "docker push ${imageName}:${version}"
                        }
                    }    

                      echo '<--------------- Docker Publish Ended --------------->'  
                }
             }
        }
        stage("Deploy") {
            steps {
                 script {
                    echo '<--------------Helm Deploy Started-------------->'
                    sh 'helm install santrende /home/ubuntu/santrend-0.1.0.tgz'
                    echo '<--------------Helm Deploy Ends----------------->'
                 }
            }
        }
    }
}





