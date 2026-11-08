pipeline {
    agent any

    triggers { pollSCM('H/2 * * * *') }

    options {
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
    }

    environment {
        AWS_REGION           = 'eu-west-1'
        AWS_ACCOUNT_ID       = '553737064319'
        REGISTRY             = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_REPOSITORY       = 'devops-challenge-prod-app'
        CLUSTER_NAME         = 'devops-challenge-prod-eks'
        HELM_CHART           = 'helm/devops-challenge-app'
        KUBERNETES_NAMESPACE = 'app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    def sha = sh(script: 'git rev-parse --short=12 HEAD', returnStdout: true).trim()
                    env.IMAGE_TAG = "${env.BUILD_NUMBER}-${sha}"
                }
            }
        }

        stage('Test') {
            steps {
                sh '''#!/bin/bash
                    set -euo pipefail
                    python3 -m venv .venv
                    . .venv/bin/activate
                    python -m pip install --quiet --upgrade pip
                    python -m pip install --quiet -r app/requirements-prod.txt
                    pytest app/tests --junitxml=test-results.xml
                '''
            }
            post {
                always { junit allowEmptyResults: true, testResults: 'test-results.xml' }
            }
        }

        stage('Build image') {
            steps {
                sh '''#!/bin/bash
                    set -euo pipefail
                    docker build \
                      --tag "$REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" \
                      --build-arg APP_VERSION="$IMAGE_TAG" \
                      app
                '''
            }
        }

        stage('Push image') {
            steps {
                sh '''#!/bin/bash
                    set -euo pipefail
                    aws ecr get-login-password --region "$AWS_REGION" |
                      docker login --username AWS --password-stdin "$REGISTRY"
                    docker push "$REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''#!/bin/bash
                    set -euo pipefail
                    aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"

                    helm upgrade --install app "$HELM_CHART" \
                      --namespace "$KUBERNETES_NAMESPACE" \
                      --create-namespace \
                      --set image.repository="$REGISTRY/$ECR_REPOSITORY" \
                      --set image.tag="$IMAGE_TAG" \
                      --set environment=prod \
                      --wait --timeout 5m

                    URL="$(kubectl get svc app --namespace "$KUBERNETES_NAMESPACE" \
                      --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
                    test -n "$URL"
                    curl --fail --retry 20 --retry-delay 15 --retry-all-errors "http://$URL/health"
                '''
            }
        }
    }

    post {
        always {
            sh 'docker image prune --all --force --filter "until=24h" || true'
            deleteDir()
        }
    }
}