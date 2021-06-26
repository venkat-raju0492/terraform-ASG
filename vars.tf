variable "common_tags" {
  description = "Common tags to apply to all resources"
  type = "map"
}

variable "env" {
  description = "The name of the environment"
}

variable "project" {
  description = "The name of the project"
}

variable "instance_type" {
  default     = "t2.small"
  description = "AWS instance type to use"
}

variable "max_size" {
  default     = 2
  description = "Maximum size of the nodes in the cluster"
}

variable "min_size" {
  default     = 1
  description = "Minimum size of the nodes in the cluster"
}

#For more explenation see http://docs.aws.amazon.com/autoscaling/latest/userguide/WhatIsAutoScaling.html
variable "desired_capacity" {
  default     = 2
  description = "The desired capacity of the cluster"
}


variable "subnet_ids" {
  type        = "list"
  description = "The list of subnets to place the instances in"
}

variable "key_name" {
  description = "SSH key name to be used"
}

variable "asg_security_group" {
  description = "ASG Security Group"
}

variable "iam_instance_profile" {
  description = "EC2 ASG Instance Profile"
}

variable "ec2_ami_name_regex" {
  description = "EC2 AMI name used to lookup image id"
  default = ".+-amazon-ecs-optimized$"
}

variable "ec2_volume_size" {
  description = "EC2 Volume size"
  default = 40
}

variable "ec2_volume_type" {
  description = "EC2 Volume type"
  default = "gp3"
}

variable "rendered_launch_configuration_user_data" {
  description = "Rendered launch configuration user data"
}


variable "target_scaling_cpu_threshold" {
  description = "CPU percentage threshold to scale up"
  default     = 40.0
}

variable "target_scaling_instance_warmup" {
  description = "ASG scaling cool down period"
  default     = 300
}

variable "recycle_schedule_recurrence_scaleup" {
  description = "Schedule recurrence time to double the cluster size to recycle old instances"
  default = "00 10 * * FRI"
}

variable "recycle_schedule_recurrence_scaleback" {
  description = "Schedule recurrence time to set the cluster size to normal values to terminate old instances"
  default = "30 10 * * FRI"
}

variable "enable_recycle_schedule" {
  description = "Enable Schedule recurrence"
  default = true
}

variable "ec2_ami_owners" {
  description = "List of AMI owners to limit search"
  default = ["amazon"]
}

variable "target_group_arns" {
  description = "(Optional) list of Target Group ARNs that apply to this AutoScaling Group"
  default= null
}


