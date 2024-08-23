# ---------------------------------------------------------------------------------------------------------------------
# COntrol plain
# ---------------------------------------------------------------------------------------------------------------------
module "aws_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "v18.17.0"
  create  = var.create_eks

  cluster_name     = var.cluster_name == "" ? module.eks_tags.id : var.cluster_name
  cluster_version  = var.cluster_version
  cluster_timeouts = var.cluster_timeouts

  # IAM Role
  iam_role_use_name_prefix      = false
  iam_role_name                 = local.cluster_iam_role_name
  iam_role_path                 = var.iam_role_path
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  iam_role_additional_policies  = var.iam_role_additional_policies
  # EKS Cluster VPC Config
  subnet_ids                           = var.private_subnet_ids
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Kubernetes Network Config
  cluster_ip_family         = var.cluster_ip_family
  cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr

  # Cluster Security Group
  create_cluster_security_group           = true
  vpc_id                                  = var.vpc_id
  cluster_additional_security_group_ids   = var.cluster_additional_security_group_ids
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules

  # Worker Node Security Group
  create_node_security_group           = var.create_node_security_group
  node_security_group_additional_rules = var.node_security_group_additional_rules

  # IRSA
  enable_irsa              = var.enable_irsa # no change
  openid_connect_audiences = var.openid_connect_audiences
  custom_oidc_thumbprints  = var.custom_oidc_thumbprints

  # TAGS
  tags = module.eks_tags.tags

  # CLUSTER LOGGING
  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cluster_enabled_log_types              = var.cluster_enabled_log_types # no change
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id

  # CLUSTER ENCRYPTION
  attach_cluster_encryption_policy = false
  cluster_encryption_config = length(var.cluster_encryption_config) == 0 ? [
    {
      provider_key_arn = try(module.kms[0].key_arn, var.cluster_kms_key_arn)
      resources        = ["secrets"]
    }
  ] : var.cluster_encryption_config

  cluster_identity_providers = var.cluster_identity_providers
}

# ---------------------------------------------------------------------------------------------------------------------
# Worker nodes
# ---------------------------------------------------------------------------------------------------------------------
module "aws_eks_managed_node_groups" {
  source = "./modules/aws-eks-managed-node-groups"

  for_each = { for key, value in var.managed_node_groups : key => value
    if length(var.managed_node_groups) > 0
  }

  managed_ng = each.value
  context    = local.node_group_context

  depends_on = [kubernetes_config_map.aws_auth]
}

# ---------------------------------------------------------------------------------------------------------------------
# Teams
# ---------------------------------------------------------------------------------------------------------------------

module "aws_eks_teams" {
  count  = length(var.application_teams) > 0 || length(var.platform_teams) > 0 ? 1 : 0
  source = "./modules/aws-eks-teams"

  application_teams = var.application_teams
  platform_teams    = var.platform_teams
  environment       = var.environment
  tenant            = var.tenant
  zone              = var.zone
  eks_cluster_id    = module.aws_eks.cluster_id
  tags              = module.eks_tags.tags
}


#--------------------------------------------
# Deploy Kubernetes Add-ons with sub module
#--------------------------------------------
module "eks-blueprints-kubernetes-addons" {
    source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"

    eks_cluster_id                        = module.eks-blueprints.eks_cluster_id

    # EKS Addons
    enable_amazon_eks_vpc_cni             = true
    enable_amazon_eks_coredns             = true
    enable_amazon_eks_kube_proxy          = true
    enable_amazon_eks_aws_ebs_csi_driver  = true

    #K8s Add-ons
    enable_aws_load_balancer_controller   = true
    enable_metrics_server                 = true
    enable_cluster_autoscaler             = true
    enable_aws_for_fluentbit              = true
    enable_argocd                         = true
    enable_ingress_nginx                  = true

    depends_on = [module.eks-blueprints.managed_node_groups]
}
