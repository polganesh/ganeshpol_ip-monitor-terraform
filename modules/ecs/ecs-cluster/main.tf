
##################################
# Data
##################################

data "aws_vpc" "vpc" {
   filter {
    name   = "tag:Name"
    values = ["*-${var.cost_centre}-${var.vpc_seq_id}"]
  }
}

data "aws_availability_zones" "main" {}

data "aws_subnet_ids" "private_app_subnets" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags {
    Name = "*-privApp-*"
  }
}


data "template_file" "user_data" {
  template = "${file("${path.root}/bootstrap/ecs-bootstrap.sh")}"
  vars {
    additional_user_data_script = "${var.additional_user_data_script}"
    cluster_name                = "ecs-${var.region_id}-${var.environment}-${var.cost_centre}-vpc${var.vpc_seq_id}-${var.app_service}-${var.seq_id}"
    docker_storage_size         = "${var.docker_storage_size}"
    efs_target       = "${aws_efs_file_system.main.id}"
  }
}

resource "aws_launch_configuration" "ecs" {
  name = "lcg-${var.region_id}-${var.environment}-${var.cost_centre}-vpc${var.vpc_seq_id}-${var.app_service}Ecs-${var.seq_id}"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  ebs_optimized               = "${var.instance_ebs_optimized}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs_profile.name}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.launch_config_sec_group_id}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"

  ebs_block_device {
    device_name           = "${var.ebs_block_device}"
    volume_size           = "${var.docker_storage_size}"
    volume_type           = "gp2"
    delete_on_termination = true
  }
  
  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.root_volume_size}"
  }

  user_data = "${coalesce(var.user_data, data.template_file.user_data.rendered)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs" {
  name = "asg-${var.region_id}-${var.environment}-${var.cost_centre}-vpc${var.vpc_seq_id}-${var.app_service}Ecs-${var.seq_id}"
  availability_zones   = ["${data.aws_availability_zones.main.names}"]
  vpc_zone_identifier  = ["${data.aws_subnet_ids.private_app_subnets.ids}"]
  launch_configuration = "${aws_launch_configuration.ecs.name}"

  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  desired_capacity     = "${var.desired_capacity}"
  enabled_metrics      = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  termination_policies = ["OldestLaunchConfiguration", "ClosestToNextInstanceHour", "Default"]

    tag {
		key                 = "Name"
		value               = "ec2-${var.region_id}-${var.environment}-${var.cost_centre}-vpc${var.vpc_seq_id}-${var.app_service}Ecs-${var.seq_id}"
		propagate_at_launch = true
	}

	tag {
		key                 = "AppService"
		value               = "${var.app_service}"
		propagate_at_launch = true
	}
  
	tag {
		key                 = "Environment"
		value               = "${var.environment}"
		propagate_at_launch = true
	}

	tag {
		key                 = "BuildDate"
		value               = "${var.build_date}"
		propagate_at_launch = true
	}

  tag {
		key                 = "MaintenanceDay"
		value               = "${var.maintenance_day}"
		propagate_at_launch = true
	}

  tag {
		key                 = "MaintenanceTime"
		value               = "${var.maintenance_time}"
		propagate_at_launch = true
	}

	tag {
		key                 = "Version"
		value               = "${var.seq_id}"
		propagate_at_launch = true
	}



  lifecycle {
    create_before_destroy = true
  }
}

########-------Policy------##########
# create auto scaling policy for both scale up and scale down and attach it to auto scaling group
######################################
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "asp-${var.region_id}-${var.environment}-${var.cost_centre}-${var.app_service}EcsScaleUp-${var.seq_id}"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "asp-${var.region_id}-${var.environment}-${var.cost_centre}-${var.app_service}EcsScaleDown-${var.seq_id}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs.name}"

  lifecycle {
    create_before_destroy = true
  }
}

########-------metric alarm------##########
# scale up/down based on CPU/Memory utilization 
######################################
resource "aws_cloudwatch_metric_alarm" "asg_cpu_high" {
  alarm_name          = "cla-${var.region_id}-${var.environment}-${var.cost_centre}-${var.app_service}EcsAsgCPUUtilizationHigh-${var.seq_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"   #GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold.
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization" #CPUReservation CPUUtilization MemoryReservation MemoryUtilization
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "80"

  dimensions {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }

  alarm_description = "Scale up if the cpu reservation is above 80% for 5 minutes"
  alarm_actions     = ["${aws_autoscaling_policy.scale_up.arn}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_low" {
  alarm_name          = "cla-${var.region_id}-${var.environment}-${var.cost_centre}-${var.app_service}EcsAsgCPUUtilizationLow-${var.seq_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "30"

  dimensions {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }

  alarm_description = "Scale down if the cpu reservation is below 30% for 5 minutes"
  alarm_actions     = ["${aws_autoscaling_policy.scale_down.arn}"]

  lifecycle {
    create_before_destroy = true
  }
}

#############################################
# EFS
##############################################
resource "aws_security_group" "efs" {
  name        = "sgr-${var.region_id}-${var.environment}-${var.cost_centre}-vpc${var.vpc_seq_id}-${var.app_service}EcsEfs-${var.seq_id}"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "EFS Security Group"


  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
  }

  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "sgr-${var.region_id}-${var.environment}-${var.cost_centre}-vpc${var.vpc_seq_id}-${var.app_service}EcsEfs-${var.seq_id}"
    	RegionId	="${var.region_id}"
		Environment = "${var.environment}"
		CostCentre	="${var.cost_centre}"
		VPCSeqId	="${var.vpc_seq_id}"
		VersionId	="${var.version_id}" 
		BuildDate	="${var.build_date}"
		AppRole		="${var.app_role}"
  }
}

resource "random_id" "creation_token" {
  byte_length   = 8
  prefix        = "${var.cost_centre}-"
}

resource "aws_efs_file_system" "main" {
  creation_token = "${random_id.creation_token.hex}"
  
   tags {
    Name = "efs-${var.region_id}-${var.environment}-${var.cost_centre}-vpc${var.vpc_seq_id}-${var.app_service}-${var.seq_id}"
    	RegionId	="${var.region_id}"
		Environment = "${var.environment}"
		CostCentre	="${var.cost_centre}"
		VPCSeqId	="${var.vpc_seq_id}"
		VersionId	="${var.version_id}" 
		BuildDate	="${var.build_date}"
		AppRole		="${var.app_role}"
  }
  
}	



# mount it in private sub net AZ and assign it security group
resource "aws_efs_mount_target" "main" {
  count = "${length(data.aws_subnet_ids.private_app_subnets.ids)}"
  file_system_id = "${aws_efs_file_system.main.id}"
  subnet_id      = "${element(split(",", element(data.aws_subnet_ids.private_app_subnets.ids, count.index)), 2)}"
  security_groups = ["${aws_security_group.efs.id}"]
}





resource "aws_ecs_cluster" "cluster" {
  name = "ecs-${var.region_id}-${var.environment}-${var.cost_centre}-vpc${var.vpc_seq_id}-${var.app_service}-${var.seq_id}"
}
