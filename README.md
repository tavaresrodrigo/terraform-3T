# EKS WEB cluster with Terraform

Manage the Cloud infrastructure and the Kubernetes life cycles with Terraform.

## Architecture

As we can see from the image below, the infrastructure was provisioned in two different VPCs, the EKS VPC and the RDS VPC (Default), ideally you should not share the EKS Cluster VPC with other resources as [recommended by AWS](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html).

In addition to the eventual security issues that you might face by sharing the cluster VPC, the L-IPAM daemon assigns secondary IP addresses to network interfaces, and maintains a warm pool of IP addresses on each node for assignment to Kubernetes pods when they are scheduled, by sharing the same subnet with other AWS services you eventually will run out of IPs depending on the CIDR of the subnets.

The resources were configured as below:

* [2 X VPCs](vpc.tf)
* [1 X EKS Cluster](cluster.tf)
* [1 X Worker Node Group with 3 nodes](cluster.tf)
* [3 X Security Groups (EKS Cluster, Worker Nodes and RDS)](security-groups.tf)
* [Kubernetes resources (1 Deployment and 1 Service Type LoadBalancer)](kubernetes.tf)

![arqhitecture](https://github.com/tavaresrodrigo/terraform-3T/blob/master/jmiro.jpg)

## Prerequisites

Make sure you install and configure all the tools required. 

### Terraform

* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Kubernetes

It's expected that you have the **AWS CLI**, the **AWS IAM Authenticator** and **kubectl** already installed in your workstation:

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
* [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html) 
* [wget](https://stackoverflow.com/questions/33886917/how-to-install-wget-in-macos) [required for the EKS module](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/829))

### Container image build

* [Docker](https://docs.docker.com/get-docker/)

### Database

For security reasons I have created a secret using AWS Secrets Manager ["db-creds"], so before you apply the repository files you must create your "db-creds" secret as below. 

```json
{
  "username": "YOURUSER",
  "password": "YOURPASSWORD"
}
```

You can also use **environment variables**, **encrypted files**, or another secret store as **HashiCorp Vault** or **AWS Param Store** to securely pass secrets into your Terraform code.


## Managing Kubernetes Resources via Terraform

In May 26, 2020 HashiCorp announced their [Kubernetes provider for Terraform](https://github.com/hashicorp/terraform-provider-kubernetes-alpha), which is still in alpha as of the date of this commit. This provider allows you to perform dry-run changes and distribute multiple Kubernetes resources, such as Kubernetes Operators and Terraform Modules. 

You are still able to use kubectl or similar CLI-based tools to manage your Kubernetes resources communicating with the Kubernetes API, however by using Terraform we benefit from:
* **Unified Workflow**, since we are already provisioning the EKS Kubernetes cluster with Terraform, we can use the same configuration language to deploy our K8s resources. 
* **Full Lifecycle Management** by creating K8s resources with Terraform, it updates and deletes tracked resources without requiring ous to inspect the API. 
* **Graph of Relationships**, Terraform will keep track of the dependence between the resources, for instance if a Persistent Volume Claim claims space from a particular Persistent Volume, Terraform won't attempt to create the PVC if it fails to create the PV.

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
