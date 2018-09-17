
#!/bin/bash
{
yum -y install aws-cli ecs-init nfs-utils awslogs jq
sudo yum install -y amazon-efs-utils
# yum update -y ecs-init

# sleep 180

# AWS-CLI Access Details

export AWS_ACCESS_KEY_ID=${access_key}
export AWS_SECRET_ACCESS_KEY=${secret_key}
export AWS_DEFAULT_REGION=${region}

echo 'AWS_ACCESS_KEY_ID=${access_key}' > /tmp/config.log
echo 'AWS_SECRET_ACCESS_KEY=${secret_key}' >> /tmp/config.log
echo 'AWS_DEFAULT_REGION=${region}' >> /tmp/config.log

# EFS Mount
#Create variables for source and target
#DIR_SRC=${efs_target}.efs.eu-central-1.amazonaws.com
#DIR_TGT=/data/efs/generic
#Mount EFS file system
# mount -t nfs4 $DIR_SRC:/ $DIR_TGT



mkdir -p efs
echo "${efs_target}.efs.eu-west-1.amazonaws.com:/ /data/efs/generic nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0" >> /etc/fstab
#mount /data/efs/generic
#efs mount helper and encryption of data in transit
sudo mount -t efs  $efs_target:/ efs
echo "${efs_target}.efs.eu-west-1.amazonaws.com:/ /data/efs/generic" >> /tmp/config.log

# ECS Agent Configuration

echo "ECS_CLUSTER=${cluster_name}
ECS_ENGINE_AUTH_TYPE=docker
ECS_LOGLEVEL=warn
ECS_RESERVED_MEMORY=512
ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=5m
ECS_IMAGE_CLEANUP_INTERVAL=10m
ECS_IMAGE_MINIMUM_CLEANUP_AGE=30m" > /etc/ecs/ecs.config


# Docker Configuration
echo 'OPTIONS="$${OPTIONS} --storage-opt dm.basesize=10G"' >> /etc/sysconfig/docker
echo 'OPTIONS="$${OPTIONS} --storage-opt dm.basesize=10G"' >> /tmp/config.log

# echo 'docker ps -aq --filter status=dead| xargs -l docker docker rm' > /etc/cron.hourly/docker_kill_dead && chmod 755 /etc/cron.hourly/docker_kill_dead

stop ecs
start ecs


} > /var/log/ecs.log




