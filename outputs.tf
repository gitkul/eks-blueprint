#-------------------------------
# EKS Cluster Module Outputs
#-------------------------------
output "eks_cluster_id" {
  description = "Amazon EKS Cluster Name"
  value       = try(module.aws_eks.cluster_id, "EKS Cluster not enabled")
}

output "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = try(split("//", module.aws_eks.cluster_oidc_issuer_url)[1], "EKS Cluster not enabled")
}

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = try(module.aws_eks.oidc_provider, "EKS Cluster not enabled")
}

output "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = try(module.aws_eks.oidc_provider_arn, "EKS Cluster not enabled")
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = try("aws eks --region ${local.context.aws_region_name} update-kubeconfig --name ${module.aws_eks.cluster_id}", "EKS Cluster not enabled")
}

output "eks_cluster_status" {
  description = "Amazon EKS Cluster Name"
  value       = try(module.aws_eks.cluster_status, "EKS Cluster not enabled")
}


#-------------------------------
# Cluster Security Group
#-------------------------------
output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = try(module.aws_eks.cluster_primary_security_group_id, "EKS Cluster not enabled")
}

output "cluster_security_group_id" {
  description = "EKS Control Plane Security Group ID"
  value       = try(module.aws_eks.cluster_security_group_id, "EKS Cluster not enabled")
}

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = try(module.aws_eks.cluster_security_group_arn, "EKS Cluster not enabled")
}

#-------------------------------
# EKS Worker Security Group
#-------------------------------
output "worker_node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the worker node shared security group"
  value       = try(module.aws_eks.node_security_group_arn, "EKS Node groups not enabled")
}

output "worker_node_security_group_id" {
  description = "ID of the worker node shared security group"
  value       = try(module.aws_eks.node_security_group_id, "EKS Node groups not enabled")
}


#-------------------------------
# Managed Node Groups Outputs
#-------------------------------
output "managed_node_groups" {
  description = "Outputs from EKS Managed node groups "
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? module.aws_eks_managed_node_groups.* : []
}

output "managed_node_groups_id" {
  description = "EKS Managed node groups id"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_id) }) : []
}

output "managed_node_groups_status" {
  description = "EKS Managed node groups status"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_status) }) : []
}

output "managed_node_group_arn" {
  description = "Managed node group arn"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_arn) }) : []
}

output "managed_node_group_iam_role_names" {
  description = "IAM role names of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_role_name) }) : []
}

output "managed_node_group_iam_role_arns" {
  description = "IAM role arn's of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_role_arn) }) : []
}

output "managed_node_group_iam_instance_profile_id" {
  description = "IAM instance profile id of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_instance_profile_id) }) : []
}

output "managed_node_group_iam_instance_profile_arns" {
  description = "IAM instance profile arn's of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_instance_profile_arn) }) : []
}

output "managed_node_group_aws_auth_config_map" {
  description = "Managed node groups AWS auth map"
  value       = local.managed_node_group_aws_auth_config_map.*
}



#-------------------------------
# Teams(Soft Multi-tenancy) Outputs
#-------------------------------
output "teams" {
  description = "Outputs from EKS Fargate profiles groups "
  value       = var.create_eks && (length(var.platform_teams) > 0 || length(var.application_teams) > 0) ? module.aws_eks_teams.* : []
}
