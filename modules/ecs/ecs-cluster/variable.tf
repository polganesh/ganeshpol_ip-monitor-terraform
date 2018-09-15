variable "additional_user_data_script" {
  default = ""
}

variable "allowed_cidr_blocks" {
  default     = ["0.0.0.0/0"]
  type        = "list"
  description = "List of subnets to allow into the ECS Security Group. Defaults to ['0.0.0.0/0']"
}

variable "ami" {
  default = ""
}

variable "ami_version" {
  default = "*"
}


variable "consul_image" {
  description = "Image to use when deploying consul, defaults to the hashicorp consul image"
  default     = "consul:latest"
}

variable "consul_memory_reservation" {
  description = "The soft limit (in MiB) of memory to reserve for the container, defaults 20"
  default     = "32"
}

variable "docker_storage_size" {
  default     = "100"
  description = "EBS Volume size in Gib that the ECS Instance uses for Docker images and metadata "
}

variable "dockerhub_email" {
  default     = ""
  description = "Email Address used to authenticate to dockerhub. http://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html"
}

variable "dockerhub_token" {
  default     = ""
  description = "Auth Token used for dockerhub. http://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html"
}

variable "enable_agents" {
  default     = false
  description = "Enable Consul Agent and Registrator tasks on each ECS Instance"
}

variable "ebs_block_device" {
  default     = "/dev/xvdcz"
  description = "EBS block devices to attach to the instance. (default: /dev/xvdcz)"
}

variable "extra_tags" {
  default = []
}

variable "heartbeat_timeout" {
  description = "Heartbeat Timeout setting for how long it takes for the graceful shutodwn hook takes to timeout. This is useful when deploying clustered applications like consul that benifit from having a deploy between autoscaling create/destroy actions. Defaults to 180"
  default     = "180"
}

variable "iam_path" {
  default     = "/"
  description = "IAM path, this is useful when creating resources with the same name across multiple regions. Defaults to /"
}

variable "custom_iam_policy" {
  default     = ""
  description = "Custom IAM policy (JSON). If set will overwrite the default one"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
}

variable "min_servers" {
  description = "Minimum number of ECS servers to run."
  default     = 1
}

variable "max_servers" {
  description = "Maximum number of ECS servers to run."
  default     = 10
}

/**
variable "name" {
  description = "AWS ECS Cluster Name"
}*/

variable "name_prefix" {
  default = ""
}


variable "registrator_image" {
  default     = "gliderlabs/registrator:latest"
  description = "Image to use when deploying registrator agent, defaults to the gliderlabs registrator:latest image"
}

variable "registrator_memory_reservation" {
  description = "The soft limit (in MiB) of memory to reserve for the container, defaults 20"
  default     = "32"
}

variable "security_group_ids" {
  type        = "list"
  description = "A list of Security group IDs to apply to the launch configuration"
  default     = []
}

variable "servers" {
  default     = "1"
  description = "The number of servers to launch."
}

/**
variable "subnet_id" {
  type        = "list"
  description = "The AWS Subnet ID in which you want to delpoy your instances"
}*/

variable "tagName" {
  default     = "ECS Node"
  description = "Name tag for the servers"
}

variable "user_data" {
  default = ""
}

#variable "vpc_id" {
#  description = "The AWS VPC ID which you want to deploy your instances"
#}

# ---------------------------
variable "environment"{
	description="indicates name of our environment. possible values dev,cit,sit,uat,pprod,prod,n"
	default="dev"
}

variable "cost_centre"{
	description="A part of an organization to which costs may be charged.e.g. finance/it/hr/wholesale/retail/investment etc..."
	default=""
}

variable "region_id"{
	default="euw1"
}

variable "region"{
	description="region in which resource is created."
	default="eu-west-1"
}

variable "version_id"{
	description="version of this component.everytime when we are updating this component we need to increment it."
	default=""
}

variable "build_date"{
	description="date on which this component built/modified. format ddmmyyyy e.g. 27122017"
	default=""
}

variable "vpc_seq_id"{
}

variable "seq_id"{}

variable "project"{}
variable "image_id"{}
# variable "instance_type"{}
# variable "key_name"{}
variable "launch_config_sec_group_id"{}
variable "root_volume_size"{}
variable "docker_ebs_volume_size"{}
# we want ec2 instance must be created in private subnet
variable "associate_public_ip_address"{default="false"}
variable "max_size"{}
variable "min_size"{}
variable "desired_capacity"{}
# provide better performance in terms of IO
variable "ebs_optimized"{default="true"}
variable "app_service" {}
variable "access_key" {}
variable "secret_key" {}
variable "maintenance_time" {}
variable "maintenance_day"{}
# variable "security_group_id"{}
variable "instance_ebs_optimized"{}
