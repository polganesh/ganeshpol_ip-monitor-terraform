module "ecscluster"{
	source="../../../modules/ecs/ecs-cluster"
	vpc_seq_id="001"
	seq_id="001"
	image_id="ami-0e24fdb28d910051a"
	instance_type="m4.large"
	key_name="deutschefin-cloud-platform"
	instance_ebs_optimized=false #it will provide better performance. not available for small ec2 instances hence selected it as false
	launch_config_sec_group_id="sg-058abfe76997d9a73" # enable traffic only from ALB in cluster

	root_volume_size=50
	docker_ebs_volume_size=100
	max_size=4
	min_size=2
	desired_capacity=2

	
	region="eu-central-1"
	region_id="euc1"
	environment="dev"
	cost_centre="deutschefin"
	build_date="15082018"
	version_id="001"
	project="deutschefin"
	app_service="ipmon"
	app_role="compute"
	access_key="${var.aws-access-key}"
	secret_key="${var.aws-secret-key}"
	maintenance_time="00:00"
	maintenance_day="Sun"
	
	
	

	# ecr_repos=["avc","vfvfg"]
}
