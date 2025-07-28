# Auto Scaling Group for Worker Nodes
resource "aws_autoscaling_group" "worker_nodes_asg" {
  name                = "${local.cluster_name}-asg"
  vpc_zone_identifier = var.public_subnet_ids
  min_size            = var.workers_min
  max_size            = var.workers_max
  desired_capacity    = var.workers_desired

  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 20
      on_demand_base_capacity                  = 0
      spot_allocation_strategy                 = "lowest-price"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.worker_nodes_launch_template.id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = var.ec2_types
        content {
          instance_type = override.value
        }
      }
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.cluster_name}-worker-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${local.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = var.environment
    propagate_at_launch = true
  }

  depends_on = [aws_launch_template.worker_nodes_launch_template]
}