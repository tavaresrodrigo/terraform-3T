# EKS WEB cluster with Terraform

In Kubernetes environments usually we use Terraform or any other IaC tool for provisioning the Infrastructure components and services, however the K8s resources are maintained by other tools like kubectl, helm the Kubernetes API etc. 

We are already familiarized with the benefits and advantages of using Terraform as IaC tool, by writing our infrastructure using Terraform we **prevent configuration drifts** managing the lifecycle of our infrastructure using declarative configuration files. We have gains with **flexibility** being able to manage resources in multiple cloud providers and **collaboration** using the terraform registry that allows us to reuse public templates contributed by the community or have our own private templates, however we will take another approach for this project. Terraform will be used to managed both, the infrastructure and the Kubernetes Lifecycle. 

## Architecture

As we can see from the image below, the infrastructure was provisioned in two different VPCs, the EKS VPC and the RDS VPC (Default), ideally you should not share the EKS Cluster VPC with other resources as [recommended by AWS[(https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html)], in addition to the eventual security issues, the L-IPAM daemon responsible for creating network interfaces and attaching the network interfaces to Amazon EC2 instances, assigns secondary IP addresses to network interfaces, and maintains a warm pool of IP addresses on each node for assignment to Kubernetes pods when they are scheduled, by sharing the same subnet with other AWS services you eventually can run out of IPs. 

The resources were configured as below:

* [2 X VPCs](vpc.tf)
* [1 X EKS Cluster](cluster.tf)
* [1 X Worker Node Group with 3 nodes](cluster.tf)
* [3 X Security Groups (EKS Cluster, Worker Nodes and RDS)](security-groups.tf)
* [Kubernetes resources (1 Deployment and 1 Service Type LoadBalancer)](kubernetes.tf)

![arqhitecture](https://github.com/tavaresrodrigo/terraform-3T/blob/master/jmiro.jpg)
## Requirements

Make sure you install and configure all the tools required before the infrastructure and Kubernetes deploy.

### Terraform

* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Kubernetes
It's expected that you have the **AWS CLI**, the **AWS IAM Authenticator** and **kubectl** already installed in your workstation, but don't worry if you don't have it yet, you can easily install and configure them following the links below. 

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
* [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html) 
* [wget](https://stackoverflow.com/questions/33886917/how-to-install-wget-in-macos) [required for the EKS module](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/829))

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

In our scenario Terraform was used to deploy all the infrastructure components and services required to run the architecture above as the EKS cluster, the 3 worker nodes and the RDS instance and also the Kubernetes resources (Nginx Deployment, Service and the ELB) as we will see in the next session. 

## Managing Kubernetes Resources via Terraform

In May 26, 2020 HashiCorp has announced their [Kubernetes provider for Terraform](https://github.com/hashicorp/terraform-provider-kubernetes-alpha), which is still in alpha as of the date of this commit. This provider allows you to describe any Kubernetes resource using HCL and can be really useful to perform dry-run changes and distribute multiple Kubernetes resources, such as Kubernetes Operators and Terraform Modules. 

You are still able to use kubectl or similar CLI-based tools to manage your Kubernetes resources communicating with the Kubernetes API, however by using Terraform we benefit from **Unified Workflow**, since we are already provisioning the EKS Kubernetes cluster with Terraform, we can use the same configuration language to deploy our K8s resources. **Full Lifecycle Management** by creating resources, it updates, and deleting tracked resources without requiring ous to inspect the API. **Graph of Relationships**, if a Persistent Volume Claim claims space from a particular Persistent Volume, Terraform won't attempt to create the PVC if it fails to create the PV.

Have a look at the [kubernetes.tf](/kubernetes.tf) file for more details about the K8s resources being created. 

## Installing the cluster

### Cloning this repository

```
$ git clone https://github.com/tavaresrodrigo/terraform-3T
```
### 
```
$ terraform init 
$ terraform apply
```

You will be presented to the summary of resources that will be provisioned, the whole process can take up to 15 minutes. 

As explained above, you will be managing the kubernetes resources using Terraform, however you might want to see your pods, deployments and services using kubectl, for that you just need to create a kubeconfig profile as below:
```
$ aws eks --region eu-west-1 update-kubeconfig --name eks-web
```

If you run a kubectl get pods you must be able to see the 3 replicas that we have configured in our [kubernetes.tf](kubernetes.tf):

```
kubectl get pods 
NAME                                READY   STATUS    RESTARTS   AGE
deployment-nginx-5fccf4655f-2dxcz   1/1     Running   0          3h2m
deployment-nginx-5fccf4655f-5qcbh   1/1     Running   0          3h2m
deployment-nginx-5fccf4655f-ghmz6   1/1     Running   0          3h2m
```
## Checking the application

You must be able access the application from the ELB DNS Name that in the terraform output or from your AWS Console. 

## Destroying the environment

Now you can run a terraform destroy to clean up your account and prevent you to expend extra-money on this environment. 

```
$terraform destroy 
```