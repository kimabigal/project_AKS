template = '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: docker
  name: docker
spec:
  containers:
  - name: docker
    image: docker:24-dind
    tty: true
    securityContext:
      privileged: true
  volumes:
  - name: docker
    emptyDir: {}
'''

podTemplate(cloud: 'kubernetes', label: 'docker', yaml: template) {
  node('docker') {
    container('docker') {

      stage('Checkout SCM') {
        git branch: 'main', url: 'https://github.com/<your-user>/<your-repo>.git'
      }

      withCredentials([usernamePassword(credentialsId: 'acr-creds',
                                        passwordVariable: 'ACR_PASS',
                                        usernameVariable: 'ACR_USER')]) {

        stage('Docker Login') {
          sh 'docker login myacr12067.azurecr.io -u $ACR_USER -p $ACR_PASS'
        }

        stage('Build & Push API') {
          sh '''
          docker build -t myacr12067.azurecr.io/api-app:1.0.0 -f app-api/api/Dockerfile .
          docker push myacr12067.azurecr.io/api-app:1.0.0
          '''
        }

        stage('Build & Push Web') {
          sh '''
          docker build -t myacr12067.azurecr.io/web-app:1.0.0 -f app-web/web/Dockerfile .
          docker push myacr12067.azurecr.io/web-app:1.0.0
          '''
        }
      }
    }
  }
}
