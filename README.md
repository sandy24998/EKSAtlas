# EKSAtlas

**EKSAtlas** – Provision a production-ready Amazon EKS (Elastic Kubernetes Service) cluster using Terraform Infrastructure as Code.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Outputs](#outputs)
- [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🎯 Overview

EKSAtlas is an Infrastructure as Code (IaC) solution that automates the provisioning of a complete Amazon EKS cluster with worker nodes on AWS. It uses Terraform to manage all infrastructure resources, ensuring consistency, repeatability, and ease of maintenance across environments.

## ✨ Features

- **Automated EKS Cluster Provisioning** - Create a fully functional Kubernetes cluster with a single command
- **Modular VPC** - Custom VPC with public/private subnets across multiple availability zones
- **Managed Worker Nodes** - Auto-scaling node groups with configurable instance types
- **Enterprise-Grade Security** - IAM roles, security groups, and network policies
- **State Management** - Remote S3 backend with DynamoDB locking for team collaboration
- **Terraform Modules** - Uses official AWS modules for best practices and maintainability
- **Production-Ready** - CloudWatch logging, tagging, environment-specific configurations
- **Version Control** - Compatible with Terraform >= 1.4.0 and AWS provider ~> 5.0

## 📋 Prerequisites

Before you begin, ensure you have the following installed and configured:

- **Terraform** >= 1.4.0 - [Install Terraform](https://www.terraform.io/downloads.html)
- **AWS CLI** >= 2.0 - [Install AWS CLI](https://aws.amazon.com/cli/)
- **kubectl** >= 1.24 - [Install kubectl](https://kubernetes.io/docs/tasks/tools/)
- **AWS Account** with appropriate permissions (EKS, EC2, IAM, VPC, S3, DynamoDB access)
- **AWS Credentials** configured locally via `aws configure`
- **S3 Bucket** for Terraform state (optional but recommended for production)

## 📁 Project Structure

```
EKSAtlas/
├── versions.tf           # Terraform and provider version requirements
├── providers.tf          # AWS provider configuration
├── variables.tf          # Input variables for cluster customization
├── main.tf               # Main configuration with VPC and EKS modules
├── outputs.tf            # Output values for cluster information
├── backend.tf            # S3 backend with DynamoDB locking for state management
├── terraform.tfvars      # Environment-specific variables
├── .gitignore            # Git ignore patterns for Terraform files
└── README.md             # This file
```

## 🚀 Getting Started

### Step 1: Clone or Create the Project

```bash
cd EKSAtlas
```

### Step 2: Initialize Terraform

Initialize the Terraform working directory to download required providers and modules:

```bash
terraform init
```

### Step 3: Review the Configuration

Review the configuration files and update `terraform.tfvars` with your values:

```hcl
# terraform.tfvars
region          = "ap-south-1"
cluster_name    = "sandeep-cluster-1"
cluster_version = "1.28"
vpc_cidr        = "10.0.0.0/16"

tags = {
  ManagedBy = "Terraform"
  Project   = "EKSAtlas"
  Owner     = "DevOps-Team"
}
```

Key variables:
- `cluster_name` - EKS cluster name
- `region` - AWS region
- `cluster_version` - Kubernetes version (default: 1.28)
- `vpc_cidr` - VPC CIDR block (default: 10.0.0.0/16)
- `tags` - Common tags for all resources

### Step 4: Validate Configuration

Validate your Terraform configuration:

```bash
terraform validate
```

## ⚙️ Configuration

### Prerequisites for Remote State (Production)

For production environments, configure S3 backend:

1. Create S3 bucket and DynamoDB table:
```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket eks-terraform-state-prod \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket eks-terraform-state-prod \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region ap-south-1
```

2. Update `backend.tf` with your bucket name (if using different naming)

### Customizing Variables

You can customize variables in `terraform.tfvars` or via CLI:

**Option 1: Update terraform.tfvars**
```hcl
region          = "ap-south-1"
cluster_name    = "my-custom-cluster"
cluster_version = "1.28"
vpc_cidr        = "10.0.0.0/16"

tags = {
  ManagedBy = "Terraform"
  Project   = "EKSAtlas"
  Owner     = "Your-Name"
}
```

**Option 2: Using CLI Arguments**
```bash
terraform apply \
  -var="cluster_name=my-cluster" \
  -var="cluster_version=1.28" \
  -var="vpc_cidr=10.1.0.0/16"
```

### Key Components

- **VPC Module** - Custom VPC with public/private subnets, NAT gateways, and DNS configuration
- **EKS Module** - Managed Kubernetes control plane with cluster logging enabled
- **IAM Roles** - Service roles for EKS cluster, node groups, and OIDC provider
- **Node Groups** - Managed EC2 instances with auto-scaling and health checks
- **Security** - Security groups for cluster and nodes with proper ingress/egress rules
- **Monitoring** - CloudWatch log groups for audit, API, and authenticator logs

## 📦 Deployment

### Plan the Infrastructure

See what resources will be created:

```bash
terraform plan
```

Review the output carefully to ensure all resources match your expectations.

### Apply the Configuration

Deploy the EKS cluster and associated resources:

```bash
terraform apply
```

When prompted, type `yes` to confirm and proceed with resource creation.

**⏱️ Time to Deploy**: Typically 15-20 minutes for EKS cluster and node group creation.

### Configure kubectl

After deployment, configure kubectl to access your cluster:

```bash
aws eks update-kubeconfig --region ap-south-1 --name sandeep-cluster-1
```

Verify cluster access:

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## 📤 Outputs

The `outputs.tf` file exports important cluster information:

```hcl
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}
```

Retrieve outputs after deployment:
```bash
terraform output

# Or get specific output
terraform output cluster_endpoint
```

## 🧹 Cleanup

To destroy all resources and avoid unnecessary AWS charges:

```bash
terraform destroy
```

When prompted, type `yes` to confirm destruction. This will:
- Terminate the EKS cluster
- Remove the node group and EC2 instances
- Delete IAM roles and policies
- Release associated resources

## 🔧 Troubleshooting

### Common Issues

**Issue: Terraform initialization fails with backend errors**
```bash
# Solution: Verify S3 bucket exists and is accessible
aws s3 ls eks-terraform-state-prod/

# If bucket doesn't exist, remove backend configuration temporarily
rm backend.tf
terraform init

# Then recreate the S3 bucket and re-add backend.tf
```

**Issue: Module source errors**
```bash
# Clear module cache and reinitialize
rm -rf .terraform/modules/
terraform init
```

**Issue: EKS cluster creation fails**
- Check IAM permissions for EKS, EC2, VPC operations
- Verify AWS account limits haven't been reached
- Check CloudWatch logs for detailed error messages

**Issue: kubectl cannot connect to cluster**
```bash
# Update kubeconfig
aws eks update-kubeconfig --region ap-south-1 --name sandeep-cluster-1

# Verify cluster access
kubectl cluster-info
kubectl auth can-i list nodes
```

**Issue: Nodes not joining cluster**
- Verify security group rules allow node communication
- Check IAM role permissions for EC2 nodes
- Review node group logs in CloudWatch

**Issue: Terraform state lock is stuck**
```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>

# Check DynamoDB table
aws dynamodb scan --table-name terraform-locks --region ap-south-1
```

## 📚 Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform AWS VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [Terraform AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Terraform Remote State Management](https://www.terraform.io/language/state/remote)

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues, questions, or suggestions, please open an issue in the repository or contact the maintainers.

---

**Happy Kubernetes Clustering! 🎉**
