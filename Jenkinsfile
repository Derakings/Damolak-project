pipeline {
    agent any

    triggers {
        githubPush()
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    environment {
        AWS_REGION = 'eu-west-1'
        AWS_ACCOUNT_ID = '553737064319'
        REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_REPOSITORY = 'devops-challenge-prod-app'
        CLUSTER_NAME = 'devops-challenge-prod-eks'
        TERRAFORM_DIR = 'terraform/envs/production'
        HELM_CHART = 'helm/devops-challenge-app'
        KUBERNETES_NAMESPACE = 'app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.IMAGE_TAG = sh(
                        script: 'git rev-parse --short=12 HEAD',
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Test') {
            steps {
                sh '''
                    set -euo pipefail
                    python3 -m venv .venv
                    . .venv/bin/activate
                    python -m pip install --quiet --upgrade pip
                    python -m pip install --quiet -r app/requirements-prod.txt
                    pytest app/tests --junitxml=test-results.xml
                '''
            }
            post {
                always {
                    junit 'test-results.xml'
                }
            }
        }

        stage('Build image') {
            steps {
                sh '''
                    set -euo pipefail
                    docker build \
                      --tag "$REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" \
                      --build-arg APP_VERSION="$IMAGE_TAG" \
                      app
                '''
            }
        }

        stage('Validate Terraform') {
            steps {
                sh '''
                    set -euo pipefail
                    terraform -chdir="$TERRAFORM_DIR" fmt -check -recursive
                    terraform -chdir="$TERRAFORM_DIR" init -backend=false
                    terraform -chdir="$TERRAFORM_DIR" validate
                '''
            }
        }

        stage('Push image') {
            steps {
                sh '''
                    set -euo pipefail
                    aws ecr get-login-password --region "$AWS_REGION" |
                      docker login --username AWS --password-stdin "$REGISTRY"
                    docker push "$REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    set -euo pipefail
                    aws eks update-kubeconfig \
                      --name "$CLUSTER_NAME" \
                      --region "$AWS_REGION"

                    helm upgrade --install app "$HELM_CHART" \
                      --namespace "$KUBERNETES_NAMESPACE" \
                      --create-namespace \
                      --set image.repository="$REGISTRY/$ECR_REPOSITORY" \
                      --set image.tag="$IMAGE_TAG" \
                      --set environment=prod \
                      --wait \
                      --timeout 5m

                    kubectl rollout status \
                      deployment/app \
                      --namespace "$KUBERNETES_NAMESPACE" \
                      --timeout=5m

                    URL="$(kubectl get svc app \
                      --namespace "$KUBERNETES_NAMESPACE" \
                      --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
                    test -n "$URL"
                    curl --fail --retry 10 --retry-delay 15 \
                      --retry-all-errors "http://$URL/health"
                '''
            }
        }
    }

    post {
        always {
            sh 'docker image prune --force --filter "label=org.opencontainers.image.created" || true'
            deleteDir()
        }
    }
}
