#!/bin/bash
set -e

# Redirect all output to log file for debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting TeleDoc App Server Initialization..."

# Update system
dnf update -y

# Install Docker
dnf install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install Docker Compose v2
DOCKER_CONFIG=/usr/local/lib/docker/cli-plugins
mkdir -p $DOCKER_CONFIG
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o $DOCKER_CONFIG/docker-compose
chmod +x $DOCKER_CONFIG/docker-compose
ln -sf $DOCKER_CONFIG/docker-compose /usr/local/bin/docker-compose

# Create app directory
APP_DIR=/home/ec2-user/teledoc
mkdir -p $APP_DIR
cd $APP_DIR

# Decode docker-compose.prod.yml (passed securely via Terraform base64)
echo "${docker_compose_b64}" | base64 -d > docker-compose.prod.yml

# Fetch secrets from AWS SSM Parameter Store
REGION="${aws_region}"
DB_PASSWORD=$(aws ssm get-parameter --name "/teledoc/prod/db_password" --with-decryption --query "Parameter.Value" --output text --region $REGION)
APP_KEY=$(aws ssm get-parameter --name "/teledoc/prod/app_key" --with-decryption --query "Parameter.Value" --output text --region $REGION)
IMAGE_TAG=$(aws ssm get-parameter --name "/teledoc/prod/image_tag" --query "Parameter.Value" --output text --region $REGION)

# ECR login
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REG="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
su - ec2-user -c "aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REG"

# Create .env file dynamically
cat <<EOF > .env
APP_NAME=TeleDoc
APP_ENV=production
APP_KEY=$APP_KEY
APP_DEBUG=false
APP_URL=http://${alb_dns_name}

DB_CONNECTION=mysql
DB_HOST=${db_address}
DB_PORT=3306
DB_DATABASE=${db_name}
DB_USERNAME=${db_username}
DB_PASSWORD=$DB_PASSWORD

ECR_REGISTRY=$ECR_REG
IMAGE_TAG=$IMAGE_TAG
EOF

# Ensure ec2-user owns everything
chown -R ec2-user:ec2-user $APP_DIR

# Pull latest Docker images
su - ec2-user -c "cd $APP_DIR && docker-compose -f docker-compose.prod.yml pull"

# Start application containers
su - ec2-user -c "cd $APP_DIR && docker-compose -f docker-compose.prod.yml up -d"

# Wait for containers to start, then run migrations automatically
sleep 15
su - ec2-user -c "docker exec teledoc-backend php artisan migrate --force || true"

echo "Initialization Complete!"
