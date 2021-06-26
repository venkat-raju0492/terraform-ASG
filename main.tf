data "aws_ami" "ec2_instance_ami" {
  most_recent = true
  owners = "${var.ec2_ami_owners}"

  name_regex = "${var.ec2_ami_name_regex}"
}

data "null_data_source" "asg-tags" {
  count = "${length(keys(var.common_tags))}"
  inputs = {
    key                 = "${element(keys(var.common_tags), count.index)}"
    value               = "${element(values(var.common_tags), count.index)}"
    propagate_at_launch = "true"
  }
}

locals {
  asg_tags = [
    {
      key                 = "Name"
      value               = "${var.project}-asg-${var.env}"
      propagate_at_launch = "true"
    }
  ]
}

resource "aws_launch_configuration" "lc" {
  name_prefix          = "${var.project}-lc-${var.env}"
  image_id             = "${data.aws_ami.ec2_instance_ami.id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${var.asg_security_group}"]
  user_data            = "${var.rendered_launch_configuration_user_data}"
  iam_instance_profile = "${var.iam_instance_profile}"
  key_name             = "${var.key_name}"
  associate_public_ip_address = false
  root_block_device {
    volume_size = "${var.ec2_volume_size}"
    volume_type = "${var.ec2_volume_type}"
    delete_on_termination = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${aws_launch_configuration.lc.name}-asg-${var.env}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.lc.id}"
  vpc_zone_identifier  = "${var.subnet_ids}"
  enabled_metrics      = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  termination_policies = ["OldestInstance"]
  target_group_arns    = "${var.target_group_arns}"

  tags = "${concat(data.null_data_source.asg-tags.*.outputs, local.asg_tags)}"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_policy" "asg-cpu-target-scaling-policy" {
  count = "${var.target_scaling_cpu_threshold != 0? 1 : 0}"
  name                      = "${var.project}-cpu-scaling-policy-${var.env}"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = "${aws_autoscaling_group.asg.name}"
  estimated_instance_warmup = "${var.target_scaling_instance_warmup}"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "${var.target_scaling_cpu_threshold}"
  }
}

resource "aws_autoscaling_schedule" "recycle-schedule-scaleup" {
  count = "${var.enable_recycle_schedule? 1 : 0}"
  scheduled_action_name = "${var.project}-weekly-recycle-schedule-scaleup-${var.env}"
  min_size = "${var.max_size * 2}"
  max_size = "${var.max_size * 2}"
  desired_capacity = "${var.max_size * 2}"
  recurrence = "${var.recycle_schedule_recurrence_scaleup}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_autoscaling_schedule" "recycle-schedule-scaleback" {
  count = "${var.enable_recycle_schedule? 1 : 0}"
  scheduled_action_name = "${var.project}-weekly-recycle-schedule-scaleback-${var.env}"
  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  desired_capacity = "${var.desired_capacity}"
  recurrence = "${var.recycle_schedule_recurrence_scaleback}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}