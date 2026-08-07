pipeline {

agent any

environment {
    IMAGE_NAME = "vighnesh003/devops-app"
    IMAGE_TAG = "${BUILD_NUMBER}"
    RELEASE_NAME = "devops-app"
    NAMESPACE = "default"
}

stages {

    stage('Checkout') {
        steps {
            checkout scm
        }
    }

    stage('Build Docker Image') {
        steps {
            sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
        }
    }

    stage('Docker Login') {
        steps {
            withCredentials([usernamePassword(
                credentialsId: 'dockerhub-creds',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            )]) {
                sh '''
                echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                '''
            }
        }
    }

    stage('Push Docker Image') {
        steps {
            sh 'docker push $IMAGE_NAME:$IMAGE_TAG'
        }
    }

    stage('Deploy using Helm') {
        steps {
            sh '''
            helm upgrade --install $RELEASE_NAME ./devops-app \
            --namespace $NAMESPACE \
            --set image.repository=$IMAGE_NAME \
            --set image.tag=$IMAGE_TAG
            '''
        }
    }
}

post {

    success {
        echo 'Docker image pushed and deployed successfully.'
    }

    failure {
        echo 'Pipeline failed.'
    }
}

}