# EKS WEB cluster with Terraform

## Architecture

! [arquitecture](jmiro.jpg)
## Requirements

### Terraform

https://learn.hashicorp.com/tutorials/terraform/install-cli

### Kubernetes
It's expected that you have the **AWS CLI**, the **AWS IAM Authenticator** and **kubectl** already installed in your workstation, but don't worry if you don't have it yet, you can easily install and configure them following the links below. 

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
* [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html) 
* wget ([required for the EKS module](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/829))

### Docker container

Docker 

### Database
For security reasons I have created manually a secret using AWS Secrets Manager ["db-creds"], so before you apply the repository files you must create your "db-creds" secret as below. 

```json
{
  "username": "YOURUSER",
  "password": "YOURPASSWORD"
}
```

You can also use **environment variables**, **encrypted files**, or another secret store as **HashiCorp Vault** or **AWS Param Store** to securely pass secrets into your Terraform code.

## Why Terraform
We already familiarized with the benefits and advantages of using Terraform as IaC tool, by writing our infrastructure using Terraform we **prevent configuration drifts** managing the lifecycle of our infrastructure using declarative configuration files. We have gains with **flexibility** being able to manage resources in multiple cloud providers and **collaboration** using the terraform registry that allows us to reuse public templates contributed by the community or have our own private templates.

In our scenario Terraform was used to deploy all the infrastructure components and services required to run the architecture above as the EKS cluster, the 3 worker nodes and the RDS instance and also the Kubernetes resources (Nginx Deployment, Service and the ELB) as we will see in the next session. 

## Managing Kubernetes Resources via Terraform

In May 26, 2020 HashiCorp has announced their [Kubernetes provider for Terraform](https://github.com/hashicorp/terraform-provider-kubernetes-alpha), which is still in alpha as of the date of this commit. This provider allows you to describe any Kubernetes resource using HCL and can be really useful to perform dry-run changes and distribute multiple Kubernetes resources, such as Kubernetes Operators and Terraform Modules. 

You are still able to use kubectl or similar CLI-based tools to manage your Kubernetes resources communicating with the Kubernetes API, however by using Terraform we benefit from **Unified Workflow**, since we are already provisioning the EKS Kubernetes cluster with Terraform, we can use the same configuration language to deploy our K8s resources. **Full Lifecycle Management** by creating resources, it updates, and deleting tracked resources without requiring ous to inspect the API. **Graph of Relationships**, if a Persistent Volume Claim claims space from a particular Persistent Volume, Terraform won't attempt to create the PVC if it fails to create the PV.

Have a look at the [kubernetes.tf](/kubernetes.tf) file for more details about the K8s resources being created. 

## Installing the cluster

### Cloning this repository

```
git clone 
```


I assume you already have kubectl and aws config installed, in case you don't have it yet, go ahead 
terraform init

kubernetes default CIDR 172 and 10 

Configure kubectl 


terraform init 

## Managing Kubernetes Resources via Terraform


aws eks --region eu-west-1 update-kubeconfig --name eks-web