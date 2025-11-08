podTemplate(cloud: 'kubernetes', label: 'docker',
  yaml: '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: dind
    image: docker:24-dind
    securityContext:
      privileged: true
    args: ["--host=tcp://0.0.0.0:2375","--tls=false"]
  - name: docker
    image: docker:24-cli
    env:
    - name: DOCKER_HOST
      value: tcp://localhost:2375
    tty: true
  volumes:
  - name: docker-graph
    emptyDir: {}
''') {

  node('docker') {
    stage('Checkout SCM') {
      git branch: 'main', url: 'https://github.com/kimabigal/project_AKS.git'
    }

    withCredentials([usernamePassword(credentialsId: 'acr-creds',
                                      usernameVariable: 'ACR_USER',
                                      passwordVariable: 'ACR_PASS')]) {
      container('docker') {

        stage('Login to ACR') {
          sh '''
            echo "$ACR_PASS" | docker login myacr12067.azurecr.io -u "$ACR_USER" --password-stdin
          '''
        }

        stage('Build & Push API') {
          sh '''
            docker build -t myacr12067.azurecr.io/api-app:latest \
              -f app-api/api/Dockerfile app-api/api
            docker push myacr12067.azurecr.io/api-app:latest
          '''
        }

        stage('Build & Push Web') {
          sh '''
            docker build -t myacr12067.azurecr.io/web-app:latest \
              -f app-web/web/Dockerfile app-web/web
            docker push myacr12067.azurecr.io/web-app:latest
          '''
        }
      }
    }
  }
}
