@Library('myLibraryName@myBranch') _
pipeline {
    agent {
        label 'linux'
    }
    options {
        timestamps()
        timeout(time: 15, unit: 'MINUTES')
        ansiColor('xterm')
    }

    environment {
        SKIP_STAGES = "${params.REFRESH_PARAMETERS}"
    }
    stages {
        stage('Setup Parameters') {
            //run only if refresh_parameters checked
            when {
                environment (name: 'SKIP_STAGES', value: 'true') 
            }
            steps {
                script {
                    println('INFO: This run will not run other stages')
                    currentBuild.description = "REFRESH PARAMETERS"
                    properties([
                        parameters([
                            sharedParameters.refreshParameters(),
                            sharedParameters.branchName('main'),
                            sharedParameters.userSeparator('color: whitesmoke; background: PaleVioletRed; text-align: center; font-weight: bold;'),
                            sharedParameters.username(),
                            string(name: 'NAMESPACE'),
                            paramValidator.unhideBuild()
                        ].flatten())
                    ])
                    jenkinsGeneric.haltBuildWithSuccess('Refreshed parameters and quit')
			    }            
            }
        }

        stage('Run Python') {
            steps {
                script {
                  generalFunctions.runPython('jenkins/Jenkinsfiles/python_demo.py', params)
                }
            }
        }
    }

    post {
        always {
            println('Cleaning up')
            cleanWs()
        }   
    }
}
