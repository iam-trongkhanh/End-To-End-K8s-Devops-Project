#!/bin/bash
# ============================
# Jenkins Server Setup (EC2 User Data)
# ============================

# Update & install dependencies
apt update -y
apt install -y gnupg software-properties-common curl unzip ca-certificates wget lsb-release fontconfig openjdk-21-jre

# -------------------------
# Install Jenkins
# -------------------------
mkdir -p /etc/apt/keyrings
wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt update -y
apt install -y jenkins

# -------------------------
# Install Docker
# -------------------------
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add users to docker group
usermod -aG docker jenkins
usermod -aG docker ubuntu

systemctl restart jenkins

# -------------------------
# Install Terraform
# -------------------------
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
apt update -y
apt install -y terraform

# -------------------------
# Install AWS CLI
# -------------------------
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# -------------------------
# Install Trivy
# -------------------------
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor > /usr/share/keyrings/trivy.gpg
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" > /etc/apt/sources.list.d/trivy.list
apt update -y
apt install -y trivy

# -------------------------
# Install eksctl
# -------------------------
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

# -------------------------
# Install kubectl
# -------------------------
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# -------------------------
# Run sonarqube scan
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  sonarqube:community
