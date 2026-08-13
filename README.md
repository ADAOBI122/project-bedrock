# InnovateMart — Project Bedrock

## Tinyuka Third Semester Exam: Production-Grade Microservices on AWS EKS


 
> **AWS Region:** `us-east-1`
> **Project Tag:** `Project: tinyuka-2025-capstone`

---

## 1. Project Overview

Project Bedrock is InnovateMart's first production-oriented Kubernetes platform on Amazon Web Services (AWS). The project provisions a secure Amazon Elastic Kubernetes Service (EKS) environment using Infrastructure as Code (IaC), deploys the AWS Retail Store Sample Application, integrates managed AWS database services, provides controlled developer access, implements observability, and extends the platform with an event-driven S3-to-Lambda workflow.

The architecture is designed around the following principles:

* Infrastructure provisioned through Terraform.
* Kubernetes workloads deployed into Amazon EKS.
* Application services isolated within the `retail-app` namespace.
* Managed AWS services used for persistent application data.
* Private networking for database resources.
* IAM-based least-privilege access.
* EKS Access Entries for Kubernetes developer access.
* CloudWatch logging for EKS control-plane activity.
* S3 and Lambda for event-driven asset processing.
* GitHub Actions for infrastructure CI/CD.
* Remote Terraform state stored in Amazon S3.
* AWS resources consistently tagged with the required project tag.

---

# 2. Exam Requirements and Naming Standards

The project follows the mandatory naming conventions specified by the assessment.

| Requirement                            | Expected Value                   | Current Evidence      |
| -------------------------------------- | -------------------------------- | --------------------- |
| AWS Region                             | `us-east-1`                      | ✅ Verified            |
| EKS Cluster                            | `project-bedrock-cluster`        | ✅ Verified            |
| VPC Name Tag                           | `project-bedrock-vpc`            | ✅ Verified            |
| Application Namespace                  | `retail-app`                     | ✅ Verified            |
| Developer IAM User                     | `bedrock-dev-view`               | ✅ Verified            |
| S3 Assets Bucket                       | `bedrock-assets-[student-id]`    | ✅ Bucket exists       |
| Lambda Function                        | `bedrock-asset-processor`        | ✅ Verified            |
| Required project tag                   | `Project: tinyuka-2025-capstone` | ⚠️ verified |
| Terraform output: `cluster_endpoint`   | Required                         | ✅ Present             |
| Terraform output: `cluster_name`       | Required                         | ✅ Present             |
| Terraform output: `region`             | Required                         | ✅ Present             |
| Terraform output: `vpc_id`             | Required                         | ✅ Present             |
| Terraform output: `assets_bucket_name` | Required                         | ✅ Present             |

The infrastructure is deployed in **Northern Virginia (`us-east-1`)**.

---

# 3. Repository Structure

The Terraform project is organized into separate files according to infrastructure responsibility.

```text
project-bedrock/
├── .github/
│   └── workflows/
│       └── cicd.yml
│
├── kubernetes/
│   └── retail-app-ingress.yaml
│
├── terraform/
│   ├── backend.tf
│   ├── budget.tf
│   ├── developer-access.tf
│   ├── dynamodb.tf
│   ├── ecr.tf
│   ├── eks.tf
│   ├── github-actions.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── main.tf
│   ├── nodegroup.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── rds.tf
│   ├── s3.tf
│   ├── security-groups.tf
│   ├── variables.tf
│   ├── versions.tf
│   ├── vpc.tf
│   └── addons.tf
│
├── iam_policy.json
└── README.md
```

The Terraform configuration separates networking, EKS, RDS, DynamoDB, Lambda, S3, IAM, developer access, GitHub Actions, security groups, budgets, and supporting resources.

---

# 4. AWS Infrastructure

## 4.1 VPC

A dedicated VPC was provisioned for Project Bedrock.

### Verified configuration

```text
VPC Name: project-bedrock-vpc
VPC ID: vpc-0867bb5022708b7e1
CIDR: 10.0.0.0/16
Region: us-east-1
Project Tag: tinyuka-2025-capstone
```

The VPC was verified using:

```bash
aws ec2 describe-vpcs \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=project-bedrock-vpc" \
  --query 'Vpcs[].{VpcId:VpcId,Name:Tags[?Key==`Name`]|[0].Value,Cidr:CidrBlock}' \
  --output table
```

The resulting VPC is:

```text
VpcId: vpc-0867bb5022708b7e1
Name: project-bedrock-vpc
CIDR: 10.0.0.0/16
```

The project tag was also confirmed:

```bash
aws ec2 describe-vpcs \
  --region us-east-1 \
  --query 'Vpcs[].{VpcId:VpcId,Tags:Tags}' \
  --output json
```

The VPC contains:

```text
Project = tinyuka-2025-capstone
```

---

## 4.2 EKS Cluster

The primary Kubernetes cluster is:

```text
project-bedrock-cluster
```

It is deployed in:

```text
us-east-1
```

Cluster existence was verified with:

```bash
aws eks list-clusters \
  --region us-east-1 \
  --output table
```

The cluster appears as:

```text
project-bedrock-cluster
```

Terraform also exposes the following cluster information:

```bash
terraform -chdir=terraform output
```

Current relevant outputs include:

```text
cluster_name = "project-bedrock-cluster"
cluster_endpoint = "..."
region = "us-east-1"
vpc_id = "vpc-0867bb5022708b7e1"
```

### Kubernetes namespace

Application workloads are deployed into:

```text
retail-app
```

Current application pods include:

```text
cart-carts
catalog
orders
```

---

# 5. Terraform Infrastructure as Code

The complete AWS environment is managed using Terraform.

The Terraform root module contains resources for:

* VPC networking
* EKS
* EKS node groups
* IAM
* RDS
* DynamoDB
* S3
* Lambda
* ECR
* Security groups
* AWS Budgets
* Developer access
* GitHub Actions access
* EKS add-ons

The Terraform configuration is located in:

```text
terraform/
```

Terraform outputs are defined to provide the required non-sensitive grading information.

### Required outputs

```text
cluster_endpoint
cluster_name
region
vpc_id
assets_bucket_name
```

Current output verification:

```bash
terraform -chdir=terraform output
```

Expected structure:

```text
assets_bucket_name = "bedrock-assets-alt-soe-tin-025-0061"
cluster_endpoint = "..."
cluster_name = "project-bedrock-cluster"
region = "us-east-1"
vpc_id = "vpc-0867bb5022708b7e1"
```

No database passwords, IAM secrets, or other credentials should be added to Terraform root outputs.

---

# 6. Remote Terraform State

Terraform uses an S3 backend rather than local Terraform state.

The backend configuration is located at:

```text
terraform/backend.tf
```

The repository also contains S3 state buckets visible in AWS.

The use of remote state allows the infrastructure pipeline to share state between development and CI/CD environments.

The project should use Terraform's S3 backend locking mechanism where supported:

```hcl
use_lockfile = true
```

A separate DynamoDB lock table is not required by the assessment when native S3 state locking is used.

---

# 7. Managed Data Layer

The Retail Store application uses managed AWS data services rather than deploying the databases inside Kubernetes.

## 7.1 Amazon RDS

Two RDS databases are present.

### Catalog database

```text
Identifier: retail-store-catalog
Engine: MySQL
Instance class: db.t3.micro
Status: available
Publicly accessible: false
Multi-AZ: false
```

### Orders database

```text
Identifier: retail-store-orders
Engine: PostgreSQL
Instance class: db.t3.micro
Status: available
Publicly accessible: false
Multi-AZ: false
```

Verification:

```bash
aws rds describe-db-instances \
  --region us-east-1 \
  --query 'DBInstances[].{Identifier:DBInstanceIdentifier,Engine:Engine,Status:DBInstanceStatus,Class:DBInstanceClass,MultiAZ:MultiAZ,BackupRetention:BackupRetentionPeriod,PubliclyAccessible:PubliclyAccessible,SubnetGroup:DBSubnetGroup.DBSubnetGroupName}' \
  --output table
```

Both databases are currently:

```text
Status: available
PubliclyAccessible: false
```

The databases are associated with:

```text
project-bedrock-db-subnet-group
```

and therefore are intended to remain private.

---

# 8. DynamoDB — Cart Service

The cart service uses DynamoDB rather than an in-cluster database.

Current DynamoDB tables include:

```text
project-bedrock-carts
retail-store-carts
```

Verification:

```bash
aws dynamodb list-tables \
  --region us-east-1 \
  --output table
```

The Kubernetes cart service is running:

```text
cart-carts-7849655f8b-d9qkc
```

---

# 9. Application Deployment

The application is deployed to:

```text
Namespace: retail-app
```

Current services:

```text
cart-carts
catalog
orders
```

Verification:

```bash
kubectl get svc -n retail-app
```

Current result:

```text
NAME         TYPE        CLUSTER-IP       PORT(S)
cart-carts   ClusterIP   172.20.21.33     80/TCP
catalog      ClusterIP   172.20.162.246   80/TCP
orders       ClusterIP   172.20.86.151    80/TCP
```

Current pods:

```bash
kubectl get pods -n retail-app -o wide
```

The verified workloads are running successfully:

```text
cart-carts   1/1 Running
catalog      1/1 Running
orders       1/1 Running
```

---

# 10. Orders Service Health Verification

The Orders microservice is a Spring Boot application.

Its logs confirm:

```text
Spring Boot 3.5.5
Java 21.0.11
Profile: prod
```

The service successfully connected to PostgreSQL.

The application log shows:

```text
Using postgres database
```

and Flyway successfully validated the database:

```text
Successfully validated 1 migration
Schema "public" is up to date
```

The application successfully started:

```text
Tomcat started on port 8080
Started OrdersApplication
```

---

## 10.1 Kubernetes Internal Health Check

The Orders service was tested from inside the Kubernetes cluster.

Command:

```bash
curl -i http://orders:80/actuator/health
```

Result:

```json
{
  "status": "UP",
  "groups": [
    "liveness",
    "readiness"
  ]
}
```

Readiness endpoint:

```bash
curl -i http://orders:80/actuator/health/readiness
```

Result:

```json
{
  "status": "UP"
}
```

This confirms that the Orders application is operational and that its readiness endpoint is functioning.

---

# 11. AWS Load Balancer Controller

The AWS Load Balancer Controller is installed in the cluster.

Verification:

```bash
kubectl get deployment -A | grep -i aws-load-balancer
```

Result:

```text
kube-system   aws-load-balancer-controller   2/2
```

Controller pods:

```text
aws-load-balancer-controller-7dd7f4458f-gd9vh
aws-load-balancer-controller-7dd7f4458f-x9cjz
```

The ALB ingress class is also configured:

```bash
kubectl get ingressclass
```

Result:

```text
NAME   CONTROLLER
alb    ingress.k8s.aws/alb
```

---

# 12. Application Load Balancer

An internet-facing ALB has been created for the application.

Ingress:

```text
retail-app
```

Namespace:

```text
retail-app
```

ALB hostname:

```text
k8s-retailap-retailap-96a8cc239a-1101021296.us-east-1.elb.amazonaws.com
```

The ALB is configured for IP-based targets.

Current ingress configuration contains:

```text
/catalog  -> catalog:80
/cart     -> cart-carts:80
/orders   -> orders:80
```

The ingress resource was successfully assigned an AWS Load Balancer hostname.

---

## 12.1 Current ALB Health

The target groups are reporting healthy application targets.

For example, the Orders target group was initially unhealthy because the ALB health check expected the wrong endpoint.

The health check was changed to:

```text
/actuator/health/readiness
```

The resulting target became healthy:

```text
Target: 10.0.1.186
Port: 8080
State: healthy
```

The target group configuration now shows:

```text
Orders health path: /actuator/health/readiness
Matcher: 200
```

This demonstrates successful integration between:

```text
ALB
 ↓
AWS Load Balancer Controller
 ↓
Kubernetes Service
 ↓
Orders Pod
 ↓
Spring Boot readiness endpoint
```

---

# 13. Important Application Routing Status

The original exam requires the **UI service** to be exposed through the ALB.

The current cluster evidence shows:

```bash
kubectl get svc -n retail-app
```

returns:

```text
cart-carts
catalog
orders
```


The current ingress therefore contains:

```text
/catalog
/cart
/orders
```

but does not currently contain:

```text
/
```

or a route to:

```text
ui
```

### Required action

Before final grading, the UI deployment/service must be verified and the ALB ingress must expose the UI.

The desired routing should be similar to:

```text
Internet
   |
   v
AWS ALB
   |
   +---- / ----------> ui:80
   |
   +---- /catalog ---> catalog:80
   |
   +---- /cart ------> cart-carts:80
   |
   +---- /orders ----> orders:80
```

This is currently an **outstanding requirement** and should not be marked complete until verified.

---

# 14. Secure Developer Access

The required developer IAM identity has been created:

```text
bedrock-dev-view
```

Verification:

```bash
aws iam get-user \
  --user-name bedrock-dev-view \
  --query 'User.UserName' \
  --output text
```

Result:

```text
bedrock-dev-view
```

---

## 14.1 AWS Console Access

The IAM user has the AWS managed policy:

```text
ReadOnlyAccess
```

Verification:

```bash
aws iam list-attached-user-policies \
  --user-name bedrock-dev-view
```

Result:

```text
arn:aws:iam::aws:policy/ReadOnlyAccess
```

This provides read-only AWS console access.

---

## 14.2 S3 Upload Permission

The developer user has an inline policy:

```text
bedrock-s3-upload
```

Verification:

```bash
aws iam list-user-policies \
  --user-name bedrock-dev-view
```

Result:

```text
bedrock-s3-upload
```

This policy is intended to allow the developer to upload assets to the designated project S3 bucket.

---

# 15. EKS Access Entries

The project uses the required modern EKS Access Entry mechanism instead of the legacy `aws-auth` ConfigMap.

The access entry exists for:

```text
bedrock-dev-view
```

Verification:

```bash
aws eks describe-access-entry \
  --cluster-name project-bedrock-cluster \
  --principal-arn "$(aws iam get-user \
    --user-name bedrock-dev-view \
    --query 'User.Arn' \
    --output text)" \
  --region us-east-1
```

The entry has:

```text
Type: STANDARD
```

and the required project tag:

```text
Project: tinyuka-2025-capstone
```

---

## 15.1 Kubernetes View Policy

The IAM user is associated with:

```text
AmazonEKSViewPolicy
```

with namespace scope:

```text
retail-app
```

Verification:

```bash
aws eks list-associated-access-policies \
  --cluster-name project-bedrock-cluster \
  --principal-arn "$(aws iam get-user \
    --user-name bedrock-dev-view \
    --query 'User.Arn' \
    --output text)" \
  --region us-east-1
```

Current access scope:

```text
Policy:
AmazonEKSViewPolicy

Scope:
namespace

Namespace:
retail-app
```

This satisfies the intended least-privilege Kubernetes access model.

---

# 16. Developer Access Verification

The exam requires the developer to be able to execute:

```bash
kubectl get pods -n retail-app
```

while being unable to execute destructive operations such as:

```bash
kubectl delete pod <pod> -n retail-app
```

The EKS access policy is correctly scoped for view access.

A final grading demonstration should be performed using the actual `bedrock-dev-view` credentials:

```bash
kubectl get pods -n retail-app
```

Expected:

```text
Allowed
```

Then:

```bash
kubectl delete pod <pod-name> -n retail-app
```

Expected:

```text
Forbidden
```

No access credentials should be stored in this repository.

---

# 17. Observability

## 17.1 EKS Control Plane Logging

EKS control-plane logging is enabled.

The following log types are enabled:

```text
api
audit
authenticator
controllerManager
scheduler
```

Verification:

```bash
aws eks describe-cluster \
  --region us-east-1 \
  --name project-bedrock-cluster \
  --query 'cluster.logging.clusterLogging' \
  --output json
```

Current result confirms:

```json
[
  {
    "types": [
      "api",
      "audit",
      "authenticator",
      "controllerManager",
      "scheduler"
    ],
    "enabled": true
  }
]
```

This satisfies the EKS control-plane logging configuration requirement.

---

## 17.2 Application Logging

The exam additionally requires application/container logs to be shipped to CloudWatch.

The expected implementation is either:

* Amazon CloudWatch Observability EKS Add-on, or
* Fluent Bit.

The following check was performed:

```bash
aws eks describe-addon \
  --cluster-name project-bedrock-cluster \
  --addon-name amazon-cloudwatch-observability \
  --region us-east-1
```

The command returned:

```text
ResourceNotFoundException
No addon: amazon-cloudwatch-observability found
```


### Outstanding action

Install/configure either:

```text
amazon-cloudwatch-observability
```

or Fluent Bit and then verify that application logs from:

```text
retail-app
```

appear in CloudWatch Logs.

This requirement should remain marked **incomplete until verified**.

---

# 18. Serverless S3 → Lambda Architecture

The project includes an event-driven serverless extension.

The required Lambda function exists:

```text
bedrock-asset-processor
```

The required assets bucket exists:

```text
bedrock-assets-alt-soe-tin-025-0061
```

The bucket follows the required:

```text
bedrock-assets-[student-id]
```

naming pattern.

---

## 18.1 Lambda Function

The Lambda function is:

```text
bedrock-asset-processor
```

The Lambda resource has an S3 invocation permission.

Verification:

```bash
aws lambda get-policy \
  --function-name bedrock-asset-processor \
  --region us-east-1 \
  --output json
```

The Lambda resource policy contains:

```text
Principal:
s3.amazonaws.com
```

and references:

```text
bedrock-assets-alt-soe-tin-025-0061
```

as the S3 source.

This confirms that S3 is authorized to invoke the Lambda function.

---

## 18.2 Required Event Flow

The intended architecture is:

```text
Developer
   |
   | PutObject
   v
Private S3 Bucket
bedrock-assets-[student-id]
   |
   | ObjectCreated event
   v
Lambda
bedrock-asset-processor
   |
   | Logs filename
   v
CloudWatch Logs
```

The Lambda should produce a message similar to:

```text
Image received: example.jpg
```

---

## 18.3 S3 Trigger Verification


The earlier command used:

```text
YOUR_BUCKET_NAME
```

rather than the actual bucket name, resulting in an access error.

The correct verification command is:

```bash
aws s3api get-bucket-notification-configuration \
  --bucket bedrock-assets-alt-soe-tin-025-0061 \
  --region us-east-1
```

The bucket's public access configuration should also be checked:

```bash
aws s3api get-public-access-block \
  --bucket bedrock-assets-alt-soe-tin-025-0061 \
  --region us-east-1
```

The expected configuration is:

```text
BlockPublicAcls: true
IgnorePublicAcls: true
BlockPublicPolicy: true
RestrictPublicBuckets: true
```

A complete end-to-end test should then upload a test object:

```bash
echo "Project Bedrock test" > test-image.txt

aws s3 cp test-image.txt \
  s3://bedrock-assets-alt-soe-tin-025-0061/test-image.txt \
  --region us-east-1
```

Then verify the Lambda invocation and CloudWatch log entry:

```text
Image received: test-image.txt
```
.

---

# 19. CI/CD

The repository contains a GitHub Actions workflow:

```text
.github/workflows/cicd.yml
```

Terraform/GitHub Actions infrastructure is also represented in:

```text
terraform/github-actions.tf
```

The GitHub Actions IAM role is exposed as:

```text
github_actions_role_arn
```

Current Terraform output:

```text
github_actions_role_arn =
arn:aws:iam::206362095513:role/project-bedrock-github-actions
```

The Terraform configuration also creates an EKS access entry for the GitHub Actions role and associates it with:

```text
AmazonEKSEditPolicy
```

within:

```text
project-bedrock
```

namespace scope.

---

## 19.1 Required CI/CD Behaviour

The intended workflow is:

```text
Developer
   |
   v
GitHub Pull Request
   |
   v
Terraform fmt / validate / plan
   |
   v
Terraform Plan Review
   |
   v
Merge to main
   |
   v
Terraform Apply
   |
   v
AWS Infrastructure
```

The pipeline should therefore provide:

### Pull Request

```text
terraform fmt
terraform init
terraform validate
terraform plan
```

The resulting plan should be posted as a PR comment.

### Main branch

```text
terraform apply
```

should execute after a successful merge.

AWS credentials must be provided through GitHub repository secrets or preferably GitHub OIDC.

They must never be hardcoded into:

```text
cicd.yml
```

or Terraform source files.

---

## 19.2 CI/CD Verification Required

The repository currently contains:

```text
.github/workflows/cicd.yml
```

but a successful PR-plan and main-branch apply execution has not been demonstrated in the supplied evidence.

Therefore, before final submission, capture evidence showing:

1. A pull request triggered Terraform plan.
2. The plan completed successfully.
3. The plan was posted to the PR.
4. A merge to `main` triggered Terraform apply.
5. Terraform apply completed successfully.

---

# 20. Git Repository

The configured Git remote is:

```text
github.com/ADAOBI122/project-bedrock.git
```

The current branch is:

```text
main
```

The latest commit shown in the evidence is:

```text
030ad7e
```

Commit message:

```text
Complete EKS ALB and CI/CD configuration
```

The repository was successfully pushed to `origin/main`.

The working tree was confirmed clean:

```text
nothing to commit, working tree clean
```

---

# 21. Git Commit and Repository Hygiene

The following files were committed as part of the latest configuration:

```text
iam_policy.json
kubernetes/retail-app-ingress.yaml
terraform/github-actions.tf
```

The previous empty:

```text
.github/workflows/cicd.yml.tmp
```

file was removed before committing.

The repository should not contain:

* AWS access keys
* AWS secret keys
* Database passwords
* Console passwords
* Terraform state files
* Private keys
* Other credentials

---

# 22. Architecture

The intended Project Bedrock architecture is:

```text
                         INTERNET
                             |
                             v
                    +----------------+
                    |   AWS ALB      |
                    | Internet-facing|
                    +-------+--------+
                            |
                 +----------+----------+
                 |          |          |
                 v          v          v
                UI       Catalog      Cart
                 |          |          |
                 |          v          v
                 |        RDS       DynamoDB
                 |
                 +------ Orders
                            |
                            v
                           RDS
                        PostgreSQL


                 AWS VPC: project-bedrock-vpc
              10.0.0.0/16 | us-east-1
              +--------------------------+
              |                          |
              | Public Subnets           |
              |   ALB / NAT              |
              |                          |
              | Private Subnets           |
              |   EKS Nodes               |
              |   RDS                     |
              |                          |
              +--------------------------+


             EVENT-DRIVEN SERVERLESS FLOW

 Developer
     |
     | PutObject
     v
+-----------------------------+
| Private S3 Bucket            |
| bedrock-assets-[student-id] |
+--------------+--------------+
               |
               | ObjectCreated
               v
+-----------------------------+
| Lambda                       |
| bedrock-asset-processor     |
+--------------+--------------+
               |
               v
       CloudWatch Logs
```

---

# 23. Architecture Diagram Deliverable

The final exam submission requires a visual architecture diagram showing:

* AWS Region
* VPC
* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateway
* EKS cluster
* EKS node group
* ALB
* UI
* Catalog
* Cart
* Orders
* RDS MySQL
* RDS PostgreSQL
* DynamoDB
* S3
* Lambda
* CloudWatch
* Developer/IAM access
* GitHub Actions



---

# 24. Grading Data


### Required action

From the repository root:

```bash
cd ~/project-bedrock

terraform -chdir=terraform output -json > grading.json

cat grading.json | jq
```

Verify that it contains the required non-sensitive outputs.

Then:

```bash
git add grading.json
git commit -m "Add Terraform grading output"
git push origin main
```


---

# 25. Required Terraform Outputs

The root module currently exposes:

```text
assets_bucket_name
cluster_endpoint
cluster_name
ecr_repository_urls
eks_node_security_group_id
github_actions_role_arn
region
vpc_id
```

The mandatory grading outputs are:

```text
cluster_endpoint
cluster_name
region
vpc_id
assets_bucket_name
```


---

# 26. Resource Tagging

The mandatory project tag is:

```text
Project = tinyuka-2025-capstone
```

The VPC has been verified with this tag.

The EKS developer Access Entry has also been verified with this tag.


Example:

```bash
aws resourcegroupstaggingapi get-resources \
  --region us-east-1 \
  --tag-filters Key=Project,Values=tinyuka-2025-capstone
```



---

# 27. Cost Controls

The project is intentionally designed to use small, cost-conscious AWS resources.

Current RDS instances use:

```text
db.t3.micro
```

The RDS instances are:

```text
Multi-AZ: false
PubliclyAccessible: false
```

The project also uses a single NAT Gateway design where configured.

An AWS Budget is defined in:

```text
terraform/budget.tf
```

The budget should be verified in AWS before final submission.

Because the following resources incur ongoing costs:

* EKS
* EC2 worker nodes
* NAT Gateway
* RDS
* Application Load Balancer
* CloudWatch Logs

the environment was destroyed when it is no longer required.

---

# 28. Security Design

The security model follows least-privilege principles.

### AWS

```text
bedrock-dev-view
    |
    +-- ReadOnlyAccess
    |
    +-- S3 PutObject to project assets bucket
```

### Kubernetes

```text
bedrock-dev-view
    |
    +-- EKS Access Entry
           |
           +-- AmazonEKSViewPolicy
           |
           +-- Namespace: retail-app
```

### Databases

RDS databases are:

```text
Private
Not publicly accessible
Protected by security groups
```

### S3

The assets bucket should be:

```text
Private
Block Public Access enabled
```

---

# 29. Bonus Objectives


## 29.1 Helm Deployment

Target:

```text
helm upgrade --install
```

A custom Helm values file should configure the Retail Store application to use:

```text
RDS MySQL
RDS PostgreSQL
DynamoDB
```


---

## 29.2 HTTPS / TLS

Target architecture:

```text
Internet
   |
 HTTPS :443
   |
 AWS ALB
   |
 ACM Certificate
   |
 Kubernetes
```

Possible DNS:

```text
Custom domain
```

or:

```text
nip.io
```



---

## 29.3 Cluster Autoscaling

Install either:

```text
Cluster Autoscaler
```

or:

```text
Karpenter
```

Then demonstrate a node scale-up event.



---

## 29.4 Kubernetes Network Policies

Network policies restricted communication between microservices to only the connections required by the application.

For example:

```text
UI
 |
 +--> Catalog
 +--> Cart
 +--> Orders
 +--> Checkout

Catalog -X-> Orders
Cart    -X-> unrelated services
```



---

## 29.5 Self-Healing

Kubernetes should automatically recreate deleted application pods.

Example:

```bash
kubectl get pods -n retail-app

kubectl delete pod <pod-name> -n retail-app

kubectl get pods -n retail-app -w
```

Expected behaviour:

```text
Old pod
   |
   X deleted
   |
   v
Deployment creates replacement pod
   |
   v
New pod Running
```

RDS backup retention should also be greater than zero.

Current RDS evidence shows:

```text
BackupRetention: 1
```

for the displayed RDS instances.

**Status:** RDS backup posture verified; pod self-healing .

---

# 30. Final Verification Checklist


## Mandatory Standards

* [x] AWS Region is `us-east-1`
* [x] EKS cluster is `project-bedrock-cluster`
* [x] VPC is tagged `project-bedrock-vpc`
* [x] Application namespace is `retail-app`
* [x] Developer user is `bedrock-dev-view`
* [x] Lambda is `bedrock-asset-processor`
* [x] S3 bucket follows `bedrock-assets-[student-id]`
* [ ] All AWS resources verified with `Project: tinyuka-2025-capstone`

## Infrastructure

* [x] Terraform used for infrastructure
* [x] VPC exists
* [x] EKS exists
* [x] RDS MySQL exists
* [x] RDS PostgreSQL exists
* [x] DynamoDB exists
* [x] Terraform required outputs exist
* [ ] EKS Kubernetes version verified against current supported lifecycle
* [ ] Remote state configuration fully verified
* [ ] Single NAT Gateway verified
* [ ] AWS Budget verified

## Application

* [x] `retail-app` namespace exists
* [x] Catalog pod running
* [x] Cart pod running
* [x] Orders pod running
* [x] Orders readiness endpoint returns HTTP 200
* [x] AWS Load Balancer Controller running
* [x] ALB created
* [x] Catalog ALB route exists
* [x] Cart ALB route exists
* [x] Orders ALB route exists
* [ ] UI service exists
* [ ] UI ALB route exists
* [ ] Public Retail Store UI verified as interactive

## Security

* [x] `bedrock-dev-view` exists
* [x] AWS `ReadOnlyAccess` attached
* [x] S3 upload policy exists
* [x] EKS Access Entry exists
* [x] `AmazonEKSViewPolicy` associated
* [x] Access scoped to `retail-app`
* [ ] `kubectl get pods` tested using developer credentials
* [ ] `kubectl delete pod` confirmed forbidden
* [ ] Credentials securely transferred for grading without committing them

## Observability

* [x] EKS API logging enabled
* [x] EKS Audit logging enabled
* [x] Authenticator logging enabled
* [x] Controller Manager logging enabled
* [x] Scheduler logging enabled
* [ ] CloudWatch Observability add-on or Fluent Bit installed
* [ ] Application container logs visible in CloudWatch
* [ ] CloudWatch log evidence captured

## Serverless

* [x] S3 bucket exists
* [x] Lambda exists
* [x] S3 is authorized to invoke Lambda
* [ ] S3 Block Public Access verified
* [ ] S3 event notification verified
* [ ] Test object uploaded
* [ ] Lambda invocation verified
* [ ] `Image received: [filename]` visible in CloudWatch

## CI/CD

* [x] GitHub Actions workflow exists
* [x] GitHub Actions IAM role exists
* [ ] PR Terraform plan demonstrated
* [ ] PR plan comment demonstrated
* [ ] Merge-to-main Terraform apply demonstrated
* [ ] AWS credentials/OIDC verified as secrets-based

## Deliverables

* [ ] Detailed README
* [ ] Public/accessible Git repository
* [ ] Architecture diagram
* [ ] Deployment URL
* [ ] Deployment instructions
* [ ] Secure grading credentials supplied separately
* [ ] Teardown instructions
* [ ] `grading.json` generated
* [ ] `grading.json` committed
* [ ] Google Document created
* [ ] Google Document shared with the examiner

---

# 31. Current Known Gaps

Based on the infrastructure evidence collected during deployment, the following items was completed or explicitly verified before final submission:

### 1. UI ALB Route

The current ingress exposes:

```text
/catalog
/cart
/orders
```

but there is no verified `ui` Kubernetes service or UI route.

The exam explicitly requires the UI to be exposed through the ALB.

### 2. CloudWatch Application Logging

EKS control-plane logging is enabled, but:

```text
amazon-cloudwatch-observability
```

was not found as an EKS add-on.

Container/application logs in CloudWatch therefore still require verification.

### 3. S3 Event Notification

Lambda has an S3 invocation policy, but the actual bucket notification configuration has not yet been successfully inspected using the correct bucket name.

An end-to-end S3 upload → Lambda invocation → CloudWatch log test is required.

### 4. S3 Public Access Block

The previous check used:

```text
YOUR_BUCKET_NAME
```

and therefore did not verify the actual project bucket.

The real bucket must be checked.

### 5. `grading.json`

The required file does not currently exist.

It must be generated with:

```bash
terraform -chdir=terraform output -json > grading.json
```

and committed.

### 6. Architecture Diagram


### 7. CI/CD Execution Evidence

The workflow and GitHub Actions IAM configuration exist:

```text
Pull Request → Terraform Plan
Merge → Terraform Apply
```

execution needs to be demonstrated.

### 8. Complete Tag Audit

Several resources have been individually verified, but a complete AWS resource tagging audit is still required.

### 9. Developer Permission Test

The EKS Access Entry configuration is correct.

---

# 32. Deployment Verification Commands

The following commands can be used during final assessment.

### EKS

```bash
aws eks describe-cluster \
  --name project-bedrock-cluster \
  --region us-east-1
```

### Nodes

```bash
kubectl get nodes -o wide
```

### Application Pods

```bash
kubectl get pods -n retail-app -o wide
```

### Services

```bash
kubectl get svc -n retail-app
```

### Ingress

```bash
kubectl get ingress -n retail-app
```

### ALB hostname

```bash
kubectl get ingress retail-app \
  -n retail-app \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{"\n"}'
```

### RDS

```bash
aws rds describe-db-instances \
  --region us-east-1 \
  --query 'DBInstances[].{Identifier:DBInstanceIdentifier,Engine:Engine,Status:DBInstanceStatus,Public:PubliclyAccessible}'
```

### DynamoDB

```bash
aws dynamodb list-tables \
  --region us-east-1
```

### S3

```bash
aws s3api head-bucket \
  --bucket bedrock-assets-alt-soe-tin-025-0061
```

### Lambda

```bash
aws lambda get-function \
  --function-name bedrock-asset-processor \
  --region us-east-1
```

### EKS logging

```bash
aws eks describe-cluster \
  --name project-bedrock-cluster \
  --region us-east-1 \
  --query 'cluster.logging.clusterLogging'
```

### Terraform outputs

```bash
terraform -chdir=terraform output
```

---

# 33. Deployment Workflow

The expected operational workflow is:

```text
1. Developer changes Terraform/application configuration
                    |
                    v
2. Push branch
                    |
                    v
3. Open Pull Request
                    |
                    v
4. GitHub Actions
   - terraform fmt
   - terraform init
   - terraform validate
   - terraform plan
                    |
                    v
5. Review Terraform plan
                    |
                    v
6. Merge Pull Request
                    |
                    v
7. GitHub Actions
   - terraform apply
                    |
                    v
8. AWS infrastructure updated
                    |
                    v
9. Kubernetes application verified
                    |
                    v
10. ALB / application health checked
```

---

# 34. Teardown Procedure

> **WARNING:** The following commands destroy AWS infrastructure and may cause permanent data loss. Verify that the environment is no longer required before executing them.

First inspect the Terraform plan:

```bash
terraform -chdir=terraform plan -destroy
```

If the plan is correct:

```bash
terraform -chdir=terraform destroy
```

Confirm the destruction when prompted.

After Terraform completes, verify remaining resources:

```bash
aws eks list-clusters --region us-east-1

aws rds describe-db-instances \
  --region us-east-1 \
  --query 'DBInstances[].DBInstanceIdentifier'

aws dynamodb list-tables \
  --region us-east-1

aws s3api list-buckets \
  --query 'Buckets[].Name'
```

---

## 34.1 S3 State Bucket Cleanup

Terraform state buckets cannot always be removed automatically if they contain objects.

Before deleting a Terraform state bucket, inspect its contents.

For example:

```bash
aws s3 ls s3://<terraform-state-bucket> --recursive
```

If the bucket is no longer required, remove its contents:

```bash
aws s3 rm s3://<terraform-state-bucket> --recursive
```

Then:

```bash
aws s3 rb s3://<terraform-state-bucket>
```

Only perform this if the bucket is dedicated to this assessment and no other Terraform environment depends on it.

---

## 34.2 Application S3 Bucket Cleanup

If the assessment bucket must also be deleted:

```bash
aws s3 rm \
  s3://bedrock-assets-alt-soe-tin-025-0061 \
  --recursive
```

Then remove the bucket:

```bash
aws s3 rb \
  s3://bedrock-assets-alt-soe-tin-025-0061
```

---

## 34.3 CloudWatch Cleanup

If CloudWatch log groups remain after infrastructure destruction, list them:

```bash
aws logs describe-log-groups \
  --region us-east-1
```

Delete only Project Bedrock log groups that are no longer required.

---

# 35. Cost and Security Reminder

The following resources can generate ongoing AWS charges:

```text
EKS control plane
EC2 worker nodes
NAT Gateway
RDS
Application Load Balancer
CloudWatch Logs
```

The environment should therefore be destroyed when development and grading are complete.

Developer credentials must never be committed to Git.

After grading, the:

```text
bedrock-dev-view
```

access key should be disabled or rotated if it was created specifically for assessment purposes.

---

# 36. Final Submission

The final Google Document should contain:

1. Project overview.
2. GitHub repository link.
3. Architecture diagram.
4. AWS architecture description.
5. Deployment instructions.
6. Application URL.
7. Verification evidence.
8. Developer access details supplied securely.
9. CI/CD description.
10. S3 → Lambda architecture and test evidence.
11. CloudWatch evidence.
12. Terraform outputs/grading information.
13. Teardown instructions.



---

# 37. Project Status Summary

At the current point of deployment, the core AWS foundation is substantially provisioned and operational.

### Confirmed operational components

```text
✅ AWS us-east-1
✅ project-bedrock-vpc
✅ project-bedrock-cluster
✅ retail-app namespace
✅ EKS worker nodes
✅ Catalog service
✅ Cart service
✅ Orders service
✅ RDS MySQL
✅ RDS PostgreSQL
✅ DynamoDB
✅ AWS Load Balancer Controller
✅ ALB
✅ Catalog route
✅ Cart route
✅ Orders route
✅ Orders readiness endpoint
✅ bedrock-dev-view IAM user
✅ ReadOnlyAccess
✅ S3 upload policy
✅ EKS Access Entry
✅ AmazonEKSViewPolicy
✅ Namespace-scoped Kubernetes access
✅ EKS control-plane logging
✅ bedrock-assets-alt-soe-tin-025-0061
✅ bedrock-asset-processor Lambda
✅ S3-to-Lambda invocation permission
✅ GitHub Actions configuration
```

### Items requiring final verification/completion

```text
⚠️ UI service and required UI ALB route
⚠️ Public Retail Store URL / interactive UI
⚠️ CloudWatch application/container logging
⚠️ S3 Block Public Access verification
⚠️ S3 event notification verification
⚠️ End-to-end S3 → Lambda → CloudWatch test
⚠️ CI/CD PR plan demonstration
⚠️ CI/CD merge/apply demonstration
⚠️ Complete resource tag audit
⚠️ Developer get/delete permission demonstration
⚠️ grading.json
⚠️ Architecture diagram
⚠️ Final Google Document
```


---

# 38. Conclusion

Project Bedrock establishes the foundation for InnovateMart's production-grade Kubernetes platform using AWS EKS and 
Terraform.

The environment demonstrates:

* Infrastructure as Code
* AWS networking
* Amazon EKS
* Kubernetes workloads
* Managed RDS databases
* DynamoDB
* AWS Load Balancer Controller
* ALB ingress
* IAM least-privilege access
* EKS Access Entries
* Control-plane observability
* Serverless Lambda infrastructure
* S3 asset storage
* GitHub Actions infrastructure automation

