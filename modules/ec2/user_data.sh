#!/bin/bash
# User Data Script for EC2 Instance

set -e

# Update system
yum update -y

# Install common tools
yum install -y \
    aws-cli \
    git \
    htop \
    vim \
    wget \
    curl

# Install CloudWatch agent (optional)
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Create application directory
mkdir -p /opt/app
mkdir -p /var/log/app

# Set up log rotation
cat > /etc/logrotate.d/app << 'EOF'
/var/log/app/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
EOF

# Create a simple application log
cat > /opt/app/app.sh << 'EOF'
#!/bin/bash
while true; do
    echo "$(date) - Application running on ${environment} environment" >> /var/log/app/application.log
    sleep 60
done
EOF

# Create a script to sync logs to S3 (runs via cron)
cat > /opt/app/sync-logs.sh << 'EOF'
#!/bin/bash
BUCKET=$(aws s3 ls | grep ${project_name}-logs | awk '{print $3}' | head -1)
if [ ! -z "$BUCKET" ]; then
    aws s3 sync /var/log/app/ s3://$BUCKET/logs/$(hostname)/$(date +%Y-%m-%d)/ --exclude "*" --include "*.log"
fi
EOF

chmod +x /opt/app/sync-logs.sh

# Add cron job to sync logs every hour
echo "0 * * * * /opt/app/sync-logs.sh" | crontab -

echo "User data script completed successfully at $(date)" > /var/log/user-data-completion.log
