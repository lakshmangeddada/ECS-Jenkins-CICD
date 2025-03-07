if(env.BRANCH_NAME == "dev"){
env.CRON_STRING = "H/5 * * * *"
}
if(env.BRANCH_NAME == "qa"){
env.CRON_STRING = "H/10 * * * *"
}
if(env.BRANCH_NAME == "prd"){
env.CRON_STRING = "H/15 * * * *"
}
pipeline {
    agent { label 'Linux1' }

    triggers {cron(env.CRON_STRING)}
        options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    stages {
        stage('Getting source code from dev') {
            when {
                branch 'dev'
            }
            steps {
                echo 'Getting source code from dev'
                echo '[INFO] BRANCH: dev'
                git branch: 'dev',
                credentialsId: 'git-credentials',
                url: 'https://github.com/lakshmangeddada/ECS-Jenkins-CICD.git'
            }
        }
        stage(Trigger deploy.sh file for dev'){
            when {
                branch 'dev'
            }
            steps {
                echo 'Trigger deploy.sh file for dev'
                sh 'sh deploy.sh dev'
            }
        }
    }

```post {
        always {
            script {
                env.CODE_AUTHOR = sh (script: "git log -1 --no-merges --format='%ae' ${GIT_COMMIT}", returnStdout: true).trim()

                env.CODE_MERGED = sh (script: "git log -1 --merges --format='%ae' ${GIT_COMMIT}", returnStdout: true).trim()

                println "============================================="

                println "CODE_AUTHOR : " + env.CODE_AUTHOR

                println "CODE_MERGED  : " + env.CODE_MERGED

                println "============================================="

            mail body:"""${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}""", subject: "Jenkins build ${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}", to:"${env.CODE_AUTHOR},${env.CODE_MERGED}"
        }
        cleanWs()
        sh 'docker system prune -f'
    }    
    }
}
