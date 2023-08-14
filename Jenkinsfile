def getCommitSha() {
  sh "git rev-parse HEAD > .git/current-commit"
  return readFile(".git/current-commit").trim()
}

def setBuildStatus(String message, String context, String state) {
  commitSha = getCommitSha()
  // add a Github access token as a global 'secret text' credential on Jenkins with the id 'github-commit-status-token'
    withCredentials([usernamePassword(credentialsId: 'jenkinsci_github_app', usernameVariable: 'GITHUB_APP', passwordVariable: 'GHAPP_PASSWORD')]) {
      // 'set -x' for debugging. Don't worry the access token won't be actually logged
      // Also, the sh command actually executed is not properly logged, it will be further escaped when written to the log
        sh """
          set +x
          curl -L \
                -X POST \
                -H \"Accept: application/vnd.github+json\" \
                -H \"Authorization: Bearer $GHAPP_PASSWORD\" \
                -H \"X-GitHub-Api-Version: 2022-11-28\" \
                \"https://api.github.com/repos/HungBNDev/TTO/statuses/$commitSha\" \
                -d \"{\\\"description\\\": \\\"$message\\\", \\\"state\\\": \\\"$state\\\", \\\"context\\\": \\\"$context\\\", \\\"target_url\\\": \\\"$BUILD_URL\\\"}\"
        """
    }
}

pipeline {
  agent any

  triggers {
    githubPush()
  }

  options {
    throttleJobProperty categories: ['simpleThrottleCatagory'],
                        limitOneJobWithMatchingParams: false,
                        maxConcurrentPerNode: 1,
                        maxConcurrentTotal: 0,
                        throttleEnabled: true,
                        throttleOption: 'project'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scmGit(
          branches: [
            [name: '*/main'],
            [name: '**']
          ],
          extensions: [],
          userRemoteConfigs: [
            [
              credentialsId: 'jenkinsci_github_app',
              url: 'https://github.com/HungBNDev/TTO.git'
            ]
          ]
        )
      }
    }

    stage('Running') {
      steps {
        setBuildStatus("Compiling", "JenkinsCI", "pending");
        sh "docker compose up --build --abort-on-container-exit --exit-code-from test"
      }
    }

    stage('Deploy To Demo ENV') {
      // We already had config Capfile and deploy/demo.rb for capistrano deployment over pem file.
      steps {
        sh 'BRANCH=develop bundle exec cap demo deploy'
      }
    }
  }

  post {
    always {
      sh "docker compose down"
      sh "docker compose rm --force --volumes --stop"
    }
    success {
      setBuildStatus("Build complete", "JenkinsCI", "success");
    }
    failure {
      setBuildStatus("Failed", "JenkinsCI", "failure");
    }
  }
}
