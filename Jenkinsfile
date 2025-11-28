pipeline {
    agent any

    environment {
        REMOTE_USER = "ubuntu"
        REMOTE_HOST = "15.206.151.106"
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

        stage('Install Nginx & Create Webpage') {
            steps {
                sshagent(credentials: ["${CRED_ID}"]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} '
                            sudo apt update &&
                            sudo apt install -y nginx &&
                            echo "<h1>Hello from Jenkins - NGINX Deployment!</h1>" | sudo tee /var/www/html/index.html
                        '
                    """
                }
            }
        }

        stage('Remote: Setup & Restart Service') {
            steps {
                sshagent(credentials: ["${CRED_ID}"]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} 'cat > ${REMOTE_DIR}/setup_and_restart.sh <<EOF
#!/bin/bash
cd ${REMOTE_DIR}
sudo systemctl restart jarvis.service
EOF'
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} 'chmod +x ${REMOTE_DIR}/setup_and_restart.sh'
                    """
                }
            }
        }

    }
}
