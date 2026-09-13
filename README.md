# End-to-End AWS DevOps Project

An end-to-end DevOps project demonstrating **Infrastructure as Code, CI/CD, code quality analysis, security scanning, containerization, application deployment, and AWS monitoring** using Terraform, Jenkins, SonarQube, Docker, Trivy, CloudWatch, and SNS.

## Project Overview

This project automates the deployment of a containerized Swiggy application on AWS.

Infrastructure is provisioned using **Terraform**, while Jenkins implements the CI/CD pipeline. The pipeline retrieves the application source code from GitHub, performs SonarQube code analysis and a Quality Gate check, scans the project and Docker image using Trivy, builds and pushes the Docker image to DockerHub, and finally deploys the application to an AWS EC2 instance using SSH.

AWS CloudWatch monitors the application EC2 instance and triggers an SNS notification when CPU utilization exceeds the configured threshold.

---

## Architecture

```text
                         GitHub
                            |
                            v
                  +-------------------+
                  |   DevOps EC2      |
                  |                   |
                  | Jenkins           |
                  | SonarQube         |
                  | Docker            |
                  | Trivy             |
                  +---------+---------+
                            |
                     CI/CD Pipeline
                            |
                 +----------+----------+
                 |                     |
                 v                     v
            SonarQube              DockerHub
          Quality Gate                 |
                                       |
                                       v
                              SSH Deployment
                                       |
                                       v
                              +----------------+
                              |    App EC2     |
                              |                |
                              | Docker         |
                              | Swiggy App     |
                              +-------+--------+
                                      |
                              CPU Utilization
                                      |
                                      v
                              +---------------+
                              |  CloudWatch   |
                              |     Alarm     |
                              +-------+-------+
                                      |
                                      v
                              +---------------+
                              |      SNS      |
                              +-------+-------+
                                      |
                                      v
                                  Email Alert


                    +-------------------------+
                    |     Monitoring EC2      |
                    |                         |
                    | AWS CLI + IAM Role      |
                    |                         |
                    | EC2 / CloudWatch / SNS  |
                    +-------------------------+
```

---

## AWS Infrastructure

The infrastructure is provisioned using **Terraform** in the `ap-south-1` region.

### EC2 Instances

| EC2            | Purpose                                           |
| -------------- | ------------------------------------------------- |
| DevOps EC2     | Jenkins, SonarQube, Docker, Trivy and CI/CD tools |
| App EC2        | Hosts the Dockerized Swiggy application           |
| Monitoring EC2 | Dedicated monitoring/control server using AWS CLI |

### AWS Services

* Amazon EC2
* Amazon VPC
* Internet Gateway
* Security Groups
* Amazon CloudWatch
* Amazon SNS
* IAM
* AWS Key Pair

---

## DevOps Tools

| Tool       | Purpose                                               |
| ---------- | ----------------------------------------------------- |
| GitHub     | Source code management                                |
| Terraform  | Infrastructure as Code                                |
| Jenkins    | CI/CD automation                                      |
| SonarQube  | Static code analysis and Quality Gate                 |
| Docker     | Application containerization                          |
| DockerHub  | Container image registry                              |
| Trivy      | Filesystem and container image vulnerability scanning |
| CloudWatch | EC2 monitoring and alarms                             |
| SNS        | Email notifications                                   |

---

## CI/CD Pipeline

The Jenkins pipeline performs the following stages:

```text
1. Clean Workspace
        ↓
2. Checkout Source Code
        ↓
3. SonarQube Analysis
        ↓
4. Quality Gate
        ↓
5. Install Dependencies
        ↓
6. Trivy Filesystem Scan
        ↓
7. Docker Build & Push
        ↓
8. Trivy Docker Image Scan
        ↓
9. Deploy to App EC2
```

### 1. Source Code Checkout

Jenkins retrieves the application source code from GitHub.

### 2. SonarQube Analysis

SonarQube analyzes the application source code for code quality issues.

### 3. Quality Gate

The pipeline waits for the SonarQube Quality Gate result.

If the Quality Gate fails, the pipeline stops.

### 4. Dependency Installation

The required Node.js dependencies are installed using:

```bash
npm install
```

### 5. Trivy Filesystem Scan

Trivy scans the application filesystem for vulnerabilities.

The scan report is archived as a Jenkins build artifact.

### 6. Docker Build

The application is packaged into a Docker image.

### 7. DockerHub Push

The Docker image is pushed to the DockerHub repository:

```text
vdhilpe007/swiggy
```

### 8. Trivy Image Scan

The final Docker image is scanned for HIGH and CRITICAL vulnerabilities.

### 9. Deployment

Jenkins connects to the App EC2 using SSH and executes Docker deployment commands.

The application container is started on port `3000`.

---

## Terraform Structure

The Terraform configuration uses reusable modules.

```text
terraform/
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── keypair.tf
├── .terraform.lock.hcl
│
└── modules/
    │
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── security/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── ec2/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Terraform provisions

* Custom VPC
* Public subnet
* Internet Gateway
* Route table
* Route table association
* Security Group
* SSH key pair
* Ubuntu EC2 instances
* DevOps EC2
* App EC2
* Monitoring EC2

The Ubuntu AMI is dynamically selected using an AWS AMI data source.

---

## Monitoring

The App EC2 is monitored using Amazon CloudWatch.

### CloudWatch Alarm

**Alarm:** `Swiggy-App-High-CPU`

Configuration:

* Metric: `CPUUtilization`
* Namespace: `AWS/EC2`
* Statistic: Average
* Period: 5 minutes
* Threshold: Greater than 70%
* Evaluation periods: 2
* Datapoints to alarm: 2

When the application EC2 maintains CPU utilization above the configured threshold, CloudWatch changes the alarm state and sends a notification through SNS.

### SNS

SNS topic:

```text
devops-ec2-alerts
```

The SNS topic has an email subscription for receiving CloudWatch alarm notifications.

---

## Monitoring EC2

The dedicated Monitoring EC2 uses an IAM role to securely access AWS services without storing AWS access keys on the server.

The Monitoring EC2 can query:

```text
EC2
CloudWatch
SNS
```

Example:

```bash
aws ec2 describe-instances --region ap-south-1
```

Check the CloudWatch alarm:

```bash
aws cloudwatch describe-alarms \
  --alarm-names Swiggy-App-High-CPU \
  --region ap-south-1
```

Check SNS topics:

```bash
aws sns list-topics --region ap-south-1
```

Check the SNS subscription:

```bash
aws sns list-subscriptions-by-topic \
  --topic-arn <SNS_TOPIC_ARN> \
  --region ap-south-1
```

---

## Security

The project follows several security practices:

* Infrastructure is provisioned using Terraform.
* EC2 access uses SSH key-based authentication.
* Jenkins uses a dedicated SSH credential for application deployment.
* AWS access from the Monitoring EC2 uses an IAM role instead of hard-coded AWS access keys.
* Terraform state files are excluded from Git.
* Terraform variable files containing potentially sensitive values are excluded from Git.
* SSH private keys are excluded from Git.
* Docker images are scanned using Trivy.
* Application source code is analyzed using SonarQube.

Sensitive files are excluded through `.gitignore`.

---

## Git Repository Structure

```text
aws-devops-end-to-end-project/
│
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── keypair.tf
│   └── modules/
│
├── Jenkinsfile
├── README.md
└── .gitignore
```

---

## Key Concepts Demonstrated

This project demonstrates practical knowledge of:

* Infrastructure as Code
* Terraform modules
* AWS VPC networking
* EC2 provisioning
* IAM roles
* SSH authentication
* Jenkins CI/CD
* GitHub integration
* SonarQube
* Quality Gates
* Docker
* DockerHub
* Trivy security scanning
* Automated application deployment
* CloudWatch monitoring
* CloudWatch alarms
* SNS notifications
* AWS CLI
* Linux administration

---

## End-to-End Flow

```text
Developer
    |
    v
GitHub
    |
    v
Jenkins
    |
    +----> SonarQube Analysis
    |            |
    |       Quality Gate
    |            |
    +<-----------+
    |
    +----> Trivy Filesystem Scan
    |
    +----> Docker Build
    |
    +----> Trivy Image Scan
    |
    +----> DockerHub
    |
    +----> SSH
             |
             v
          App EC2
             |
             v
       Docker Container
             |
             v
       Running Application

App EC2
   |
   v
CloudWatch
   |
   v
CPU Alarm
   |
   v
SNS
   |
   v
Email Notification
```

---

## Outcome

The project provides an automated DevOps workflow where infrastructure, application deployment, security scanning, code quality analysis, and monitoring are integrated into a single AWS-based solution.

The complete workflow demonstrates how code can move from **GitHub → Jenkins → quality/security checks → DockerHub → EC2 deployment → CloudWatch monitoring → SNS notification** with minimal manual intervention.

---

## Author

**Vishal Dhilpe**

AWS | DevOps | Terraform | Jenkins | Docker | Kubernetes | CI/CD
