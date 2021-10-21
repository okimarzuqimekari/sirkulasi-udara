#!/bin/bash

# Set Variable

# Set ECS Cluster name 
echo ECS_CLUSTER=CLUSTER-NAME >> /etc/ecs/ecs.config

# Set instance to Spot
echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=true >> /etc/ecs/ecs.config

echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config

export AWS_ACCESS_KEY_ID=CHANGE-ME
export AWS_SECRET_ACCESS_KEY=CHANGE-ME
export AWS_DEFAULT_REGION=ap-southeast-1

# PACKAGES FOR DEFAULT INSTALLED
PACKAGES=(
    wget 
    curl 
    unzip 
    cloud-init 
    vim 
    nano 
    screen 
    rsync 
    htop 
    bash-completion 
    perl-libwww-perl 
    perl-DateTime 
    net-tools 
    aws-cli 
    perl-Switch 
    perl-DateTime 
    perl-Sys-Syslog 
    perl-LWP-Protocol-https 
    perl-Digest-SHA.x86_64
)

# Get Hostname Variable
export EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone` 
export EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
export ec2id=$(curl http://169.254.169.254/latest/meta-data/instance-id )

# Update & Upgrade
yum update -y
for vars in ${PACKAGES[@]}
do
    yum install -y $vars
done
yum upgrade -y

# Set timezone
timedatectl set-timezone Asia/Jakarta 

# Set Hostname 
export ec2name=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$ec2id" "Name=key,Values=Name" --region $EC2_REGION | awk '/"Value":/ {print $2}' | tr -d '",')
hostnamectl set-hostname $ec2name

# Set crontab
# docker image prune (each day at 01:00)
echo -e '0 1 * * * root docker image prune -f; \n' > /etc/cron.d/docker-image-prune

# Set user & github username as public key
groupadd devops
echo "%devops ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-cloud-init-users

# Engineer User
ENGINEER=(
    #UserNameServer-GithubUserName
)

for user in ${ENGINEER[@]}
do
    uname=`echo $user | cut -d- -f1`
    keys=`echo $user | cut -d- -f2`
    adduser $uname --group wheel,devops --shell /bin/bash
    mkdir /home/$uname/.ssh
    wget -O - https://github.com/$keys.keys | sudo tee -a /home/$uname/.ssh/authorized_keys
    chown -R $uname:devops /home/$uname/.ssh
    chmod 0700 /home/$uname/.ssh
    chmod 600 -R /home/$uname/.ssh/authorized_keys
    echo "$uname ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-cloud-init-users
done

# Tweak network
MODULES=(
    tcp_bbr
    sch_fq
)

CONFIG=(
    net.ipv4.tcp_congestion_control=bbr
    net.ipv4.tcp_syncookies=0
    net.core.somaxconn=4096
)

for vars in ${MODULES[@]}
do
    modprobe $vars
done

for vars in ${CONFIG[@]}
do
    sysctl -w $vars
done
