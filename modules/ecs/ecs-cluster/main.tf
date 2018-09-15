
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
    dockerhub_token             = "${var.dockerhub_token}"
    dockerhub_email             = "${var.dockerhub_email}"
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

resource "aws_ecs_cluster" "cluster" {
  name = "ecs-${var.region_id}-${var.environment}-${var.cost_centre}-vpc${var.vpc_seq_id}-${var.app_service}-${var.seq_id}"
}








/**
resource "aws_autoscaling_group" "main" {
  name = "asg-${var.region_id}-${var.environment}-${var.cost_centre}-vpc${var.vpc_seq_id}-${var.app_service}Ecs-${var.seq_id}"

  availability_zones   = ["${data.aws_availability_zones.main.names}"]
  vpc_zone_identifier  = ["${data.aws_subnet_ids.private_app_subnets.ids}"]
  launch_configuration = "${aws_launch_configuration.main.id}"
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  desired_capacity     = "${var.desired_capacity}"
  enabled_metrics      = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]




resource "aws_launch_configuration" "main" {
  name = "lcg-${var.region_id}-${var.environment}-${var.cost_centre}-vpc${var.vpc_seq_id}-${var.app_service}Ecs-${var.seq_id}"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  ebs_optimized               = "${var.instance_ebs_optimized}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs.id}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.security_group_id}"]
  user_data                   = "${data.template_file.ecs_cloud_config.rendered}"
  associate_public_ip_address = "${var.associate_public_ip_address}"

  # Volume tags is not available for launch configuration #14558
  # root
  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.root_volume_size}"
  }

  # docker
  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_type = "gp2"
    volume_size = "${var.docker_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}


data "aws_ami" "ecs_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-${var.ami_version}-amazon-ecs-optimized"]
  }
}
data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}







resource "aws_security_group" "ecs" {
  name        = "ecs-sg-${var.name}"
  description = "Container Instance Allowed Ports"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ecs-sg-${var.name}"
  }
}
*/

# Make this a var that an get passed in?
