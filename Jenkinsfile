pipeline {
    agent any

    environment {
        AWS_REGION = "ap-southeast-2"
        ECR_REPOSITORY = "springboot"
        ECR_IMAGE_TAG = "latest"
        CONTAINER_NAME = "springboot-app"
        SPRINGBOOT_PORT = "8080"
        SSM_PARAMETER_NAME = "/jenkins/aws_account_id"
    }

    stages {
        stage('Retrieve AWS Account ID from SSM') {
            steps {
                script {
                    // Retrieve AWS Account ID from SSM Parameter Store
                    def accountId = sh(
                        script: "aws ssm get-parameter --name $SSM_PARAMETER_NAME --region $AWS_REGION --query Parameter.Value --output text",
                        returnStdout: true
                    ).trim()
                    env.AWS_ACCOUNT_ID = accountId
                }
            }
        }

        stage('Checkout') {
            steps {
                git 'https://github.com/medh110/springboot-boilterplate.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t $CONTAINER_NAME ."
                }
            }
        }

        stage('Tag Docker Image') {
            steps {
                script {
                    sh "docker tag $CONTAINER_NAME $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$ECR_IMAGE_TAG"
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                script {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    sh "docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$ECR_IMAGE_TAG"
                }
            }
        }

        stage('Deploy Docker Container') {
            steps {
                script {
                    sh """
                    docker stop $CONTAINER_NAME || true
                    docker rm $CONTAINER_NAME || true
                    """
                    sh """
                    docker run -d --name $CONTAINER_NAME -p $SPRINGBOOT_PORT:$SPRINGBOOT_PORT $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$ECR_IMAGE_TAG
                    """
                }
            }
        }
    }
}

//note:this is jenkinsfile to deploy to EC2 instance
