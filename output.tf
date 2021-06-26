output "asg_arn" {
  value = "${aws_autoscaling_group.asg.arn}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.asg.name}"
}