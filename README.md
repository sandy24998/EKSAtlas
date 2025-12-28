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
- **Worker Node Management** - Automatic scaling configuration with managed node groups
- **IAM Integration** - Proper IAM roles and policies for secure cluster and node operations
- **VPC Configuration** - Leverages your default VPC and subnets for simplified networking
- **Terraform Best Practices** - Modular, scalable, and maintainable infrastructure code
- **Version Control** - Compatible with Terraform >= 1.3.0 and AWS provider ~> 5.0
- **Production-Ready** - Includes security policies and proper dependency management

## 📋 Prerequisites

Before you begin, ensure you have the following installed and configured:

- **Terraform** >= 1.3.0 - [Install Terraform](https://www.terraform.io/downloads.html)
- **AWS CLI** >= 2.0 - [Install AWS CLI](https://aws.amazon.com/cli/)
- **kubectl** >= 1.24 - [Install kubectl](https://kubernetes.io/docs/tasks/tools/)
- **AWS Account** with appropriate permissions (EKS, EC2, IAM, VPC access)
- **AWS Credentials** configured locally via `aws configure`

## 📁 Project Structure

```
EKSAtlas/
├── providers.tf          # AWS provider configuration and Terraform version requirements
├── variables.tf          # Input variables for cluster customization
├── vpc.tf                # Data sources for VPC and subnets
├── iam.tf                # IAM roles and policy attachments
├── eks.tf                # EKS cluster and node group resources
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

Review the default values in `variables.tf`. Key variables:

- `cluster_name` - EKS cluster name (default: `sandeep-cluster-1`)
- `region` - AWS region (default: `ap-south-1`)
- `node_instance_type` - EC2 instance type for nodes (default: `t3.medium`)
- `desired_size` - Number of worker nodes (default: `2`)

### Step 4: Validate Configuration

Validate your Terraform configuration:

```bash
terraform validate
```

## ⚙️ Configuration

### Customizing Variables

You can override default variables in multiple ways:

**Option 1: Using CLI Arguments**
```bash
terraform apply -var="cluster_name=my-cluster" -var="desired_size=3"
```

**Option 2: Using a `.tfvars` File**

Create a `terraform.tfvars` file:
```hcl
cluster_name    = "my-custom-cluster"
region          = "ap-south-1"
node_instance_type = "t3.large"
desired_size    = 3
```

Then apply:
```bash
terraform apply
```

### Key Components

- **IAM Roles**: Separate roles for the EKS control plane and worker nodes
- **EKS Cluster**: Managed Kubernetes control plane in your default VPC
- **Node Group**: Managed EC2 instances for running your workloads
- **VPC Configuration**: Uses default VPC for simplified setup

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

Add an `outputs.tf` file (optional) to retrieve important cluster information:

```hcl
output "cluster_id" {
  value = aws_eks_cluster.eks.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "node_group_id" {
  value = aws_eks_node_group.nodegroup.id
}
```

Retrieve outputs:
```bash
terraform output
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

**Issue: Terraform initialization fails**
```bash
# Solution: Check AWS credentials
aws sts get-caller-identity

# Ensure AWS CLI is properly configured
aws configure
```

**Issue: EKS cluster creation fails with IAM errors**
- Verify IAM permissions for the AWS user/role
- Ensure trust relationships are properly configured
- Check CloudWatch logs for more details

**Issue: Nodes not joining the cluster**
- Verify VPC and subnet configuration
- Check security groups for proper ingress/egress rules
- Review node IAM role policies

**Issue: kubectl cannot connect to cluster**
```bash
# Update kubeconfig with correct cluster name and region
aws eks update-kubeconfig --region ap-south-1 --name <your-cluster-name>
```

## 📚 Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

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
