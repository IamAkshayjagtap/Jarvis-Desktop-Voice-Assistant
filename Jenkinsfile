pipeline {
  agent any
  environment {
    REMOTE_USER = "ubuntu"
    REMOTE_HOST = "13.203.74.115"
    REMOTE_DIR  = "/home/ubuntu/jarvis"
    CRED_ID     = "jarvis_key"
  }
  
  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/IamAkshayjagtap/Jarvis-Desktop-Voice-Assistant.git'
       }
     }

    stage('Package & Transfer') {
      steps {
        sshagent(credentials: ["${CRED_ID}"]) {
          sh '''
            ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${REMOTE_DIR}"
            rsync -avz --delete --exclude='.git' ./ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/
          '''
         }
       }
     }

     stages {
        stage('Install Nginx & Create Webpage') {
            steps {
                sshagent (credentials: ['ec2-ssh']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@YOUR_SERVER_IP "
                            sudo apt update &&
                            sudo apt install -y nginx &&
                            echo '<h1>Hello from Jenkins - NGINX Deployment!</h1>' | sudo tee /var/www/html/index.html
                        "
                    """
                 }
             }
         }
     }

     stage('Remote: Setup & Restart') {
      steps {
       sshagent(['jarvis_key']) {
      sh """
        ssh -o StrictHostKeyChecking=no ubuntu@13.203.74.115 'cat > /home/ubuntu/jarvis/setup_and_restart.sh <<EOF
             #!/bin/bash
             cd /home/ubuntu/jarvis
             sudo systemctl restart jarvis.service
        EOF'
          ssh -o StrictHostKeyChecking=no ubuntu@13.203.74.115 'chmod +x /home/ubuntu/jarvis/setup_and_restart.sh'
      """
          }
         }
       }
     }
   }

