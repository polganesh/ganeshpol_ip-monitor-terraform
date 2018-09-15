#!/bin/bash

# update/install aws-cli ecs init etc to latest version
yum -y install aws-cli ecs-init nfs-utils awslogs jq

# EFS Mount
mkdir -p /data/efs/generic
echo "${efs_target}.efs.eu-central-1.amazonaws.com:/ /data/efs/generic nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0" >> /etc/fstab
mount /data/efs/generic
# anyone can read and write need to check how to improve this security further
# sudo chmod 666 -r /data/efs/generic
sudo chmod 777  /data/efs/generic
echo "${efs_target}.efs.eu-central-1.amazonaws.com:/ /data/efs/generic" >> /tmp/config.log


# echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

# ECS Agent Configuration

echo "ECS_CLUSTER=${cluster_name}
ECS_ENGINE_AUTH_TYPE=docker
ECS_LOGLEVEL=warn
ECS_RESERVED_MEMORY=512
ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=5m
ECS_IMAGE_CLEANUP_INTERVAL=10m
ECS_IMAGE_MINIMUM_CLEANUP_AGE=30m" > /etc/ecs/ecs.config



# Docker Configuration
echo 'OPTIONS="$${OPTIONS} --storage-opt dm.basesize=${docker_storage_size}G"' >> /etc/sysconfig/docker
echo 'OPTIONS="$${OPTIONS} --storage-opt dm.basesize=10G"' >> /tmp/config.log

stop ecs
start ecs


# Append addition user-data script
${additional_user_data_script}