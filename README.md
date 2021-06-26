# Overview

This module will do the following:
- Setup Auto-scaling group
- Setup EC2 launch configuration
- Setup target scaling policy
- Schedule recycle for EC2 instances on configurable schedule

## Usage

```terraform
terraform {
  backend "s3" {}
}

provider "aws" {
  region = "${var.region}"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Project = "${var.project}"
    Environment = "${var.env}"
    CreatedBy = "Terraform"
  }
}

data "template_file" "ec2_user_data" {
  template = "${file("<PATH_TO_TEMPLATES>/user-data.sh")}"
}

module "Instances" {
  source = "git@github.levi-site.com:LSCO/terraform-ASG.git?ref=RELEASE_VERSION"
  subnet_ids = "${var.subnet_ids}"
  instance_type = "${var.asg_instance_type}"
  env = "${var.env}"
  project = "${var.project}"
  key_name = "${var.key_pair}"
  ec2_ami_owners = "${var.ec2_ami_owners}"
  ec2_ami_name_regex = "${var.ec2_ami_name_regex}"
  min_size = "${var.asg_ec2_min_count}"
  max_size = "${var.asg_ec2_max_count}"
  desired_capacity = "${var.asg_ec2_desired_count}"
  rendered_launch_configuration_user_data = "${data.template_file.ec2_user_data.rendered}"
  iam_instance_profile = "<ASG_INSTANCE_PROFILE>"
  asg_security_group = "<ASG_SECURITY_GROUP_ID>"
  common_tags = "${local.common_tags}"
}
```
