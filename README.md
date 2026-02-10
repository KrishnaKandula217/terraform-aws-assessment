# Terraform AWS Cloud Infrastructure Assessment

This repository contains a production-ready Terraform configuration for deploying AWS infrastructure with best practices for security, reusability, and maintainability.
---

## 🏗️ Architecture Overview

This infrastructure deploys a secure, scalable foundation with the following architecture:

### Network Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      AWS Account (us-east-1)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                VPC (10.0.0.0/16)                         │  │
│  │                                                           │  │
│  │  ┌────────────────┐         ┌────────────────┐          │  │
│  │  │  AZ: us-east-1a        │  AZ: us-east-1b│          │  │
│  │  │                         │                 │          │  │
│  │  │ ┌──────────────────┐   │ ┌──────────────┐│          │  │
│  │  │ │Public Subnet     │   │ │Public Subnet ││          │  │
│  │  │ │10.0.1.0/24       │   │ │10.0.2.0/24  ││          │  │
│  │  │ └──────────────────┘   │ └──────────────┘│          │  │
│  │  │                         │                 │          │  │
│  │  │ ┌──────────────────┐   │ ┌──────────────┐│          │  │
│  │  │ │Private Subnet    │   │ │Private Subnet││          │  │
│  │  │ │10.0.11.0/24      │   │ │10.0.12.0/24 ││          │  │
│  │  │ │                  │   │ │              ││          │  │
│  │  │ │  ┌────────────┐  │   │ │  ┌────────┐ ││          │  │
│  │  │ │  │EC2 Instance│  │   │ │  │(backup)│ ││          │  │
│  │  │ │  │AL2023      │  │   │ │  │        │ ││          │  │
│  │  │ │  │t3.micro/lg │  │   │ │  │        │ ││          │  │
│  │  │ │  └────────────┘  │   │ │  └────────┘ ││          │  │
│  │  │ │  (with IAM role) │   │ │             ││          │  │
│  │  │ └──────────────────┘   │ └──────────────┘│          │  │
│  │  │                         │                 │          │  │
│  │  └─────────────────────────┴─────────────────┘          │  │
│  │          ▲                                               │  │
│  │          │ (Internet Access)                            │  │
│  │    [Internet Gateway]                                   │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │            S3 Bucket (terraform-logs-dev-*)              │  │
│  │                                                           │  │
│  │  Features:                                               │  │
│  │  • Versioning enabled                                     │  │
│  │  • Server-side encryption (AES256)                       │  │
│  │  • Public access blocked                                 │  │
│  │  • SSL-only policy enforced                              │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘

Key Security Features:
✅ EC2 in private subnet (no direct internet exposure)
✅ IMDSv2 enforced (credential protection)
✅ Encrypted EBS root volume
✅ Security group with least privilege
✅ IAM role with minimal S3 access
✅ S3 with encryption, versioning, and public block
```

### Resource Summary

| Component | Type | Count | Purpose |
|-----------|------|-------|---------|
| VPC | Network | 1 | Main network container |
| Public Subnets | Network | 2 | For NAT/future bastion |
| Private Subnets | Network | 2 | For EC2 instances |
| Internet Gateway | Network | 1 | Public internet access |
| Route Tables | Network | 3 | Traffic routing |
| EC2 Instance | Compute | 1 | Application server |
| Security Group | Network | 1 | EC2 access control |
| IAM Role | Security | 1 | EC2 permissions |
| IAM Policy | Security | 1 | S3 access |
| S3 Bucket | Storage | 1 | Application logs |
| EBS Volume | Storage | 1 | EC2 root filesystem |



---

## ✅ Prerequisites

Before you begin, ensure you have:

1. **AWS Account** with appropriate permissions
   - EC2 full access
   - S3 full access
   - IAM role/policy management
   - VPC management

2. **Terraform** >= 1.6.0 installed
   ```bash
   terraform --version
   # Terraform v1.6.0 or later
   ```

3. **AWS CLI** v2 configured with credentials
   ```bash
   aws configure
   aws sts get-caller-identity  # Verify credentials work
   ```

4. **(Optional)** EC2 Key Pair created in target region
   ```bash
   aws ec2 describe-key-pairs --region us-east-1
   ```

---

## 🚀 Implementation Checklist

Follow these steps to deploy successfully:

### Phase 1: Prerequisites 
- [ ] Verify AWS account access (`aws sts get-caller-identity` succeeds)
- [ ] Verify Terraform installed (`terraform version`)
- [ ] Clone/download repository
- [ ] Review this README for assumptions
- [ ] Set AWS region to us-east-1 (`export AWS_REGION=us-east-1`)

### Phase 2: Backend Setup 
- [ ] Navigate to `backend-setup/` directory
- [ ] Run `terraform init`
- [ ] Run `terraform apply` (creates S3 + DynamoDB)
- [ ] Note the S3 bucket name from outputs
- [ ] Return to root directory

### Phase 3: Configuration 
- [ ] Uncomment backend block in `main.tf` (lines 11-19)
- [ ] Update S3 bucket name in backend block (if using custom name)
- [ ] Select environment: `export ENV=dev` or `export ENV=prod`
- [ ] Review `environments/${ENV}.tfvars` for your needs

### Phase 4: Deployment
- [ ] Run `terraform init` (initialize working directory)
- [ ] Run `terraform plan -var-file="environments/dev.tfvars"` (dry-run)
- [ ] Review plan output for expected resources
- [ ] Run `terraform apply -var-file="environments/dev.tfvars"` (deploy)
- [ ] Confirm "yes" when prompted
- [ ] Wait for completion 

### Phase 5: Verification 
- [ ] Run `terraform output` (see deployment outputs)
- [ ] Note EC2 instance ID: `terraform output ec2_instance_id`
- [ ] Note S3 bucket name: `terraform output s3_bucket_name`
- [ ] Verify in AWS Console:
  - [ ] VPC exists with correct CIDR
  - [ ] Subnets visible across 2 AZs
  - [ ] EC2 running in private subnet
  - [ ] S3 bucket exists with correct name


### Phase 6: Cleanup 
- [ ] Run `terraform destroy -var-file="environments/dev.tfvars"`
- [ ] Confirm "yes" to delete all resources
- [ ] Wait for completion
- [ ] (Optional) Destroy backend: `cd backend-setup && terraform destroy`



## 📁 Project Structure

```
terraform-aws-assessment/
│
├── main.tf                      # Main orchestration file
├── variables.tf                 # Variable definitions
├── outputs.tf                   # Output definitions
├── .gitignore                   # Git ignore rules
├── README.md                    # This file
│
├── environments/                # Environment-specific configurations
│   ├── dev.tfvars              # Development environment
│   └── prod.tfvars             # Production environment
│
├── modules/                     # Reusable Terraform modules
│   ├── vpc/
│   ├── ec2/
│   ├── s3/
│   └── iam/
│
└── backend-setup/              # Backend infrastructure
    └── backend.tf              # S3 + DynamoDB for state management
```

---

## 🚀 Quick Start

### Step 1: Set Up Remote Backend

```bash
cd backend-setup
terraform init
terraform apply
cd ..
```

### Step 2: Update Backend Configuration

Uncomment the backend block in `main.tf` and update with your bucket name.

### Step 3: Deploy Infrastructure

```bash
terraform init
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

---

## 🔧 Detailed Setup

See complete documentation sections below for:
- Module documentation
- Multi-environment support
- Scenario responses
- Production readiness considerations

---

## �️ Module Documentation

### Overview

Each module encapsulates a logical unit of infrastructure with clear input/output boundaries.

```
                        ┌─────────────────────┐
                        │   main.tf           │
                        │  (Orchestrator)     │
                        └─────────────────────┘
                                  │
                 ┌────────────────┼────────────────┐
                 │                │                │
         ┌───────▼──────┐ ┌──────▼──────┐ ┌─────▼────────┐
         │   VPC Module │ │  IAM Module │ │  S3 Module   │
         └───────┬──────┘ └──────┬──────┘ └─────┬────────┘
                 │                │              │
         ┌───────▼──────────────────────────────▼────┐
         │     EC2 Module                            │
         │  (Depends on VPC, IAM, S3)                │
         └──────────────────────────────────────────┘
```

---

### VPC Module (`modules/vpc/`)

**Purpose:** Create network infrastructure with multi-AZ resilience

**Key Resources:**
- `aws_vpc` - VPC with DNS enabled
- `aws_internet_gateway` - Public internet access
- `aws_subnet` (public/private) - Separate network segments
- `aws_route_table` - Traffic routing rules
- `aws_route_table_association` - Route table to subnet mapping

**Design Decisions:**

1. **Multi-AZ Subnets**
   - 2 public subnets (1 per AZ)
   - 2 private subnets (1 per AZ)
   - **Trade-off:** 4 subnets vs. simplicity trade-off accepted for resilience

2. **Separate Route Tables**
   - Public RT with IGW route
   - Private RTs per AZ (NAT disabled by default)
   - **Rationale:** Allows future NAT Gateway addition without refactoring

3. **DNS Configuration**
   ```hcl
   enable_dns_hostnames = true
   enable_dns_support   = true
   ```
   - **Reason:** Required for ECS, VPC endpoints, other AWS services

**Inputs Customizable:**
- `vpc_cidr` - CIDR block (default: 10.0.0.0/16)
- `availability_zones` - AZs to use (default: us-east-1a, us-east-1b)
- `public_subnet_cidrs` - Public subnet ranges
- `private_subnet_cidrs` - Private subnet ranges

**Outputs Provided:**
- `vpc_id` - VPC identifier
- `public_subnet_ids` - For EC2 placement in public (not used currently)
- `private_subnet_ids` - For EC2 placement in private
- `internet_gateway_id` - For custom routing

---

### EC2 Module (`modules/ec2/`)

**Purpose:** Launch application server with security hardening

**Key Resources:**
- `aws_ami` (data source) - Fetch latest Amazon Linux 2023
- `aws_instance` - EC2 instance with hardened configuration
- `aws_security_group` - Inbound/outbound rules
- `aws_ebs_encryption` - Volume encryption

**Design Decisions:**

1. **Dynamic AMI Selection**
   ```hcl
   data "aws_ami" "amazon_linux" {
     most_recent = true
     owners      = ["amazon"]
     filter {
       name   = "name"
       values = ["al2023-ami-*-x86_64"]
     }
   }
   ```
   - **Benefit:** Automatic patching via latest AMI
   - **Risk:** Could break compatibility with custom apps
   - **Mitigation:** Pin to specific AMI in production

2. **IMDSv2 Enforcement**
   ```hcl
   metadata_options {
     http_endpoint               = "enabled"
     http_tokens                 = "required"  # IMDSv2 only
     http_put_response_hop_limit = 1
   }
   ```
   - **Security:** Prevents SSRF credential theft
   - **Compatibility:** Modern SDKs support IMDSv2

3. **User Data Script**
   ```hcl
   user_data = base64encode(templatefile("${path.module}/user_data.sh", {...}))
   ```
   - **Note:** Template variables injected at launch time
   - **Security:** Not sensitive data (encrypted on disk)

4. **Security Group Rules**
   - **SSH:** Restricted to VPC CIDR (10.0.0.0/16)
   - **Rationale:** Use SSM Session Manager instead of SSH
   - **Egress:** Allow all (for package downloads if NAT added)

**Parameters Customizable:**
- `instance_type` - t3.micro (dev) or t3.large (prod)
- `key_name` - For SSH access (optional)
- `subnet_id` - Private subnet placement
- `iam_instance_profile` - From IAM module

**Security Hardening Applied:**
✅ Running in private subnet (no internet exposure)
✅ IMDSv2 enforced (no SSRF attacks)
✅ Root volume encrypted (AES-256)
✅ Security group with least privilege
✅ SSM Session Manager enabled (instead of SSH)

---

### S3 Module (`modules/s3/`)

**Purpose:** Create secure, compliant S3 bucket for application logs

**Key Resources:**
- `aws_s3_bucket` - Object storage
- `aws_s3_bucket_public_access_block` - Prevent public exposure
- `aws_s3_bucket_versioning` - Enable data recovery
- `aws_s3_bucket_server_side_encryption_configuration` - Encryption
- `aws_s3_bucket_policy` - Enforce SSL-only access

**Design Decisions:**

1. **Server-Side Encryption (SSE-S3)**
   ```hcl
   apply_server_side_encryption_by_default {
     sse_algorithm = "AES256"
   }
   ```
   - **Choice:** AES256 (default) vs. KMS
   - **Pro:** AES256 is free, automatic
   - **Con:** KMS allows more granular key control
   - **Recommendation for Production:** Use KMS for better audit trail

2. **Versioning Enabled**
   ```hcl
   versioning_configuration {
     status = "Enabled"
   }
   ```
   - **Purpose:** Recover from accidental deletion/corruption
   - **Cost Impact:** Storage increases ~2-3x for incremental changes
   - **Retention:** No automatic cleanup (manual or lifecycle policy needed)

3. **Public Access Block (All Enabled)**
   ```hcl
   block_public_acls       = true
   block_public_policy     = true
   ignore_public_acls      = true
   restrict_public_buckets = true
   ```
   - **Belt & Suspenders:** Multiple layers prevent public exposure
   - **Override Risk:** Any permission granted overrides these

4. **SSL-Only Policy**
   ```json
   {
     "Sid": "EnforceSSLOnly",
     "Effect": "Deny",
     "Action": "s3:*",
     "Condition": {"Bool": {"aws:SecureTransport": "false"}}
   }
   ```
   - **Purpose:** Prevent data interception in transit
   - **Affects:** Tools like S3 sync, AWS CLI (must use HTTPS)
   - **Exception:** CloudFront origin access (uses HTTPS)

**Parameters Customizable:**
- `bucket_name` - Globally unique name (auto-generated: `{project}-logs-{env}-{account_id}`)
- `environment` - For tagging
- `project_name` - For resource naming

**Security Posture:**
✅ Encryption at rest (AES-256)
✅ Encryption in transit (SSL enforced)
✅ Versioning (disaster recovery)
✅ Public access blocked (defense-in-depth)
✅ Audit-ready (all operations loggable)

**Missing (For Production):**
- ❌ S3 access logging (who accessed bucket)
- ❌ CloudTrail logging (API calls)
- ❌ Lifecycle policies (old versions cleanup)
- ❌ MFA delete protection (prevent accidental deletion)

---

### IAM Module (`modules/iam/`)

**Purpose:** Create least-privilege role for EC2 instance

**Key Resources:**
- `aws_iam_role` - Trust policy allowing EC2 service
- `aws_iam_policy` - Custom S3 access policy
- `aws_iam_role_policy_attachment` - Attach policies to role
- `aws_iam_instance_profile` - Attach role to EC2

**Design Decisions:**

1. **Least Privilege S3 Access**
   ```json
   {
     "Effect": "Allow",
     "Action": [
       "s3:PutObject",
       "s3:PutObjectAcl",
       "s3:GetObject",
       "s3:ListBucket"
     ],
     "Resource": [
       "arn:aws:s3:::bucket",
       "arn:aws:s3:::bucket/*"
     ]
   }
   ```
   - **Scope:** Only specified bucket, not all buckets
   - **Actions:** Only necessary actions (not DeleteObject, etc.)
   - **Audit:** Easy to review what EC2 can do

2. **SSM Managed Instance Core**
   ```hcl
   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
   ```
   - **Enables:** Session Manager (shell access without SSH)
   - **Benefits:** No key management, audit trail in CloudTrail
   - **Alternative:** Remove if SSH preferred

3. **No Wildcard Permissions**
   - ❌ NOT using "s3:*"  (would allow DeleteObject)
   - ✅ ONLY using specific needed actions
   - **Rationale:** Comply with compliance requirements

**Parameters Customizable:**
- `s3_bucket_arn` - ARN of bucket to grant access to
- `environment` - For resource naming
- `project_name` - For resource naming

**Compliance Alignment:**
✅ Principle of least privilege
✅ Resource-scoped permissions (not account-wide)
✅ Audit trail via CloudTrail
✅ No hardcoded credentials (instance assumes role)
✅ Separates concerns (EC2 role separate from user roles)

---

### Module Dependencies & Data Flow

```
main.tf orchestrates modules:

1. VPC created first (foundation)
   └─> Outputs: vpc_id, subnet_ids

2. S3 module (independent)
   ├─> Outputs: bucket_arn, bucket_name
   └─> Used by IAM module

3. IAM module created (references S3 ARN)
   ├─> Inputs: s3_bucket_arn
   └─> Outputs: instance_profile_name, role_arn

4. EC2 module created last (depends on all)
   ├─> Inputs: subnet_id (from VPC)
   ├─> Inputs: iam_instance_profile (from IAM)
   ├─> Inputs: vpc_id (from VPC)
   └─> Outputs: instance_id, private_ip
```

---

## 🌎 Multi-Environment Support

This configuration supports multiple environments (dev, prod, staging) using the same Terraform code with different variable files.

### Environment Variables

**Development (`environments/dev.tfvars`):**
```hcl
environment          = "dev"
ec2_instance_type    = "t3.micro"      # Small instance
ec2_key_name         = "devadmin-key"
common_tags = {
  Environment = "dev"
  CostCenter  = "Development"
}
```

**Production (`environments/prod.tfvars`):**
```hcl
environment          = "prod"
ec2_instance_type    = "t3.large"      # Larger instance
ec2_key_name         = "prodadmin-key"
common_tags = {
  Environment = "prod"
  CostCenter  = "Production"
}
```

### Deploying to Different Environments

**Deploy Development:**
```bash
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

**Deploy Production:**
```bash
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

---



---

## 💡 Design Decisions & Trade-offs

### 1. Module-Based Architecture
**Decision:** Organize infrastructure into separate, reusable modules (VPC, EC2, S3, IAM)  
**Design Choice Rationale:**
- **Modularity:** Each module is self-contained with explicit inputs/outputs
- **Reusability:** Modules can be used across multiple projects
- **Team Collaboration:** Teams can own different modules
- **Testing:** Easier to unit test individual modules

**Trade-offs:**
- ✅ **Pro:** Better code organization, maintainability, and team scaling
- ✅ **Pro:** Easy to version and share modules across projects
- ❌ **Con:** Slight overhead for simple single-deployment projects
- ❌ **Con:** Requires discipline in maintaining module boundaries

---

### 2. No NAT Gateway (Disabled by Default)
**Decision:** Private EC2 instance has no egress route by default  
**Design Choice Rationale:**
- **Cost Optimization:** NAT Gateway costs $32-45/month per AZ
- **Assessment Project:** Suitable for learning/testing purposes
- **Security Posture:** Restricted outbound reduces attack surface

**Trade-offs:**
- ✅ **Pro:** Reduces infrastructure cost by ~$40/month
- ✅ **Pro:** Implements least privilege network principles
- ❌ **Con:** EC2 cannot initiate outbound connections
- ❌ **Con:** Cannot download packages or patches from internet
- ❌ **Con:** Limited to SSM Session Manager for remote access

**Production Recommendations:**
- For production with internet access needs, enable NAT Gateway:

  # Uncomment lines 72-90 in modules/vpc/main.tf
  # Cost: ~$40/month + data transfer charges

- Alternative: VPC endpoints for AWS services (S3, CloudWatch)

---

### 3. Amazon Linux 2023 (Latest Gen)
**Decision:** Use Amazon Linux 2023 instead of Amazon Linux 2  
**Design Choice Rationale:**
- **Long-term Support:** 5-year support lifecycle (vs 2 years for AL2)
- **Modern Tooling:** Updated packages and runtime environments
- **AWS Optimization:** Purpose-built for AWS workloads
- **Compliance:** Better alignment with current security standards

**Trade-offs:**
- ✅ **Pro:** Extended 5-year support window
- ✅ **Pro:** Better performance with modern kernel
- ✅ **Pro:** Continuously updated security patches
- ❌ **Con:** Less community third-party support (vs Ubuntu)
- ❌ **Con:** Fewer forum posts/examples online
- ❌ **Con:** Application compatibility requires testing

---

### 4. IMDSv2 Enforcement
**Decision:** Require IMDSv2 exclusively (token-based authentication)  
**Design Choice Rationale:**
- **Security:** Prevents Server-Side Request Forgery (SSRF) attacks
- **Compliance:** Required by AWS security best practices and compliance frameworks
- **No Disruption:** Modern AWS SDKs default to IMDSv2
- **Audit-Ready:** Aligns with CIS AWS Foundations Benchmark

**Trade-offs:**
- ✅ **Pro:** Adds security without complexity
- ✅ **Pro:** No performance impact
- ✅ **Pro:** Prevents SSRF-based credential theft
- ❌ **Con:** Breaks old applications using IMDSv1
- ❌ **Con:** Requires SDK updates for legacy code

**Security Comparison:**
```
IMDSv1 (Deprecated)
- Vulnerable to SSRF attacks: curl http://169.254.169.254/latest/meta-data/...
- Attacker could steal IAM credentials

IMDSv2 (Current, Required)
- Requires token: Must fetch token first, then use it
- SSRF attacks cannot work (no direct metadata access)
- Industry standard (AWS, Azure, GCP all recommend)
```

---

### 5. State Management Strategy
**Decision:** Remote S3 backend with DynamoDB state locking  
**Design Choice Rationale:**
- **Team Collaboration:** MutualExclusion prevents concurrent modifications
- **Disaster Recovery:** State backed up and versioned
- **Security:** Encrypted in transit and at rest
- **Auditability:** All state changes logged via CloudTrail

**Implementation Details:**
```hcl
backend "s3" {
  bucket         = "terraform-state-bucket"
  key            = "assessment/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-lock"
  encrypt        = true
}
```

**Trade-offs:**
- ✅ **Pro:** Safe for team environments
- ✅ **Pro:** Disaster recovery capabilities
- ✅ **Pro:** Full audit trail
- ❌ **Con:** Requires backend infrastructure setup
- ❌ **Con:** S3 access costs ($~0.02/request)
- ❌ **Con:** DynamoDB provisioning needed


### 6. Multi-Environment Strategy (dev.tfvars, prod.tfvars)
**Decision:** Single codebase, environment-specific .tfvars files  
**Design Choice Rationale:**
- **DRY Principle:** Code reuse, no duplication
- **Consistency:** Guaranteed identical infrastructure
- **Easy Validation:** Single code path to test
- **Team Alignment:** One source of truth

**Implementation:**
```bash
# Development deployment
terraform apply -var-file="environments/dev.tfvars"

# Production deployment  
terraform apply -var-file="environments/prod.tfvars"
```

**Key Differences:**
```hcl
# dev.tfvars
ec2_instance_type = "t3.medium"     

# prod.tfvars  
ec2_instance_type = "t3.large"     
```

**Trade-offs:**
- ✅ **Pro:** Code reuse reduces bugs
- ✅ **Pro:** Consistent infrastructure baseline
- ✅ **Pro:** Easy to add environments
- ❌ **Con:** Separate AWS accounts recommended for prod (not done here)
- ❌ **Con:** Requires manual tfvars file management
- ❌ **Con:** No automatic prod promotion workflow

**Production Recommendation:**
```
├── aws-account-dev/
│   └── terraform/
│       ├── main.tf
│       └── environments/dev.tfvars
│
└── aws-account-prod/
    └── terraform/
        ├── main.tf
        └── environments/prod.tfvars
```
Separate AWS accounts prevent accidental cross-environment damage.

---

### 10. AZ Distribution
**Decision:** 2 Availability Zones for public & private subnets  
**Design Choice Rationale:**
- **High Availability:** Failure of one AZ doesn't impact service
- **AWS Recommendation:** HA architectures use minimum 2 AZs
- **Cost:** Minimal additional cost for critical resilience
- **Flexibility:** Easy to add 3rd AZ for larger deployments

**Trade-offs:**
- ✅ **Pro:** Resilient to single AZ failure
- ✅ **Pro:** Minimal cost increase
- ✅ **Pro:** Meets AWS best practices
- ❌ **Con:** Single EC2 instance still has single point of failure
- ❌ **Con:** NAT Gateway per AZ would cost more ($80-90/month)

**To Achieve Full HA:**
```hcl
# Add Auto Scaling Group
module "asg" {
  desired_capacity = 2
  # Spreads instances across both AZs
}

# Add Load Balancer
module "nlb" {
  # Health checks, auto-failover
}
```

---

## ✨ Best Practices Implemented

### Security
✅ No hardcoded credentials  
✅ IAM roles over access keys  
✅ Encrypted storage (S3, EBS)  
✅ IMDSv2 enforced  
✅ Public access blocked  
✅ SSL-only policies  
✅ Least privilege security groups  

### Reliability
✅ Multi-AZ deployment  
✅ State locking  
✅ Remote state  
✅ Resource tagging  
✅ Lifecycle protection  

### Cost Optimization
✅ S3 lifecycle policies  
✅ Right-sized instances  
✅ No NAT by default  
✅ gp3 volumes  

### Operational Excellence
✅ Modular structure  
✅ Comprehensive docs  
✅ Environment separation  
✅ Consistent naming  
✅ Automation (user data)  

---

---

##  Detailed Assumptions

### AWS Account & Permissions
**Assumption:** User has AWS account with following IAM permissions
- EC2 full access (ec2:*)
- S3 full access (s3:*)
- IAM role/policy creation (iam:*)
- VPC full access (ec2:DescribeVpcs, ec2:CreateVpc, etc.)

**If this assumption breaks:**
```
Contact AWS account administrator or use root credentials for initial setup
Then restrict to IAM user with minimal permissions
```

**Verification:**
```bash
aws iam get-user  # Should succeed
aws ec2 describe-vpcs  # Should succeed
```

---

### AWS Region: us-east-1
**Assumption:** All resources deployed to us-east-1 region  
**Rationale:** 
- First AWS region (most stable)
- Cheapest pricing tier
- Home region for many AWS services

**If Different Region Needed:**
```bash
# Option 1: Change variable
terraform apply -var="aws_region=eu-west-1" --var-file=""

# Option 2: Update variables.tf default
variable "aws_region" {
  default = "eu-west-1"  # Change this
}
```

**Availability Zone Impact:**
```hcl
# Current AZs: us-east-1a, us-east-1b
# eu-west-1: eu-west-1a, eu-west-1b, eu-west-1c
# Must be updated in environments/*.tfvars if region changes
```

---



### VPC CIDR Block Assumptions
**Assumption:** CIDR blocks don't conflict with existing VPCs/networks
```
10.0.0.0/16   (VPC)
├── 10.0.1.0/24, 10.0.2.0/24     (Public)
└── 10.0.11.0/24, 10.0.12.0/24   (Private)
```

**If Corporate Network Uses 10.x.x.x:**
```hcl
# Update variables.tf
variable "vpc_cidr" {
  default = "172.16.0.0/16"  # Different range
}

# Then update subnet ranges accordingly
public_subnet_cidrs  = ["172.16.1.0/24", "172.16.2.0/24"]
private_subnet_cidrs = ["172.16.11.0/24", "172.16.12.0/24"]
```

---

### EC2 Key Pair Exists
**Assumption:** If EC2 instance needs SSH access, key pair must pre-exist in AWS
```bash
# Check if key pair exists:
aws ec2 describe-key-pairs --key-names "devadmin-key"

# If not, create one:
aws ec2 create-key-pair --key-name "devadmin-key" \
  --query 'KeyMaterial' --output text > devadmin-key.pem
chmod 400 devadmin-key.pem
```

**Why This Assumption:**
- Terraform cannot securely generate SSH keys
- Keys must be managed separately
- Prevents exposure of private keys in state files

**If No SSH Access Needed:**
```hcl
# In environments/*.tfvars
ec2_key_name = ""  # Leave blank, SSM Session Manager used instead
```

---

### Backend Infrastructure Pre-exists
**Assumption:** S3 bucket and DynamoDB table for Terraform state already created
```
S3 Bucket:      terraform-state-bucket
DynamoDB Table: terraform-state-lock
```

**Setup Script Provided:**
```bash
cd backend-setup
terraform apply
# Creates necessary backend resources
```

**If Backend Not Created:**
```
Error: error reading S3 Bucket "terraform-state-bucket": 
  NotFound: Not Found
```

---

### Terraform Version >= 1.6.0
**Assumption:** Terraform CLI version 1.6 or newer installed locally
```bash
terraform version
# Terraform v1.6.0+
```

**Why This Version:**
- Stable API for all used resources
- Cloud variable validation features
- Better error messages

**For Older Versions:**
```
Unsupported Terraform Version error
```

---

### AWS Provider ~> 5.0
**Assumption:** AWS provider version 5.x used (5.0 through 5.x)
```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"  # Allows 5.0, 5.1, ..., 5.99
  }
}
```

**Breaking Changes with Provider 4.x:**
- `rule` → `rules` in S3 encryption config
- Different IAM policy syntax in some cases

**Checking Current Provider:**
```bash
terraform version -json | jq '.provider_selections.["registry.terraform.io/hashicorp/aws"]'
```

--

### Network Architecture Assumptions
**Assumption:** Current architecture suitable for assessment/learning purposes
- Single EC2 instance (no redundancy)
- No load balancer (no traffic distribution)
- Simple VPC (no VPN, Direct Connect, multi-region)

**Production Requirements Would Need:**
- Auto Scaling Group (min 2 instances)
- Network Load Balancer / Application Load Balancer
- Health checks and failover
- Multi-region if global reach needed

---

### Terraform State Accessibility
**Assumption:** Terraform state stored in S3 is accessible and secure
- Only authorized team members can read state
- State contains sensitive data (passwords, API keys)
- Unauthorized access = infrastructure compromise

**Security Best Practices:**
```hcl
# S3 bucket for state should have:
- Private access (no public read)
- Versioning enabled (restore deleted state)
- Encryption enabled (AES-256)
- MFA delete (prevent accidental deletion)
- Access logging (audit who accessed)
- Bucket policy restricting to team only
```

---

### No Existing Resources Named identically
**Assumption:** AWS account doesn't have existing resources with same names
```
Resource naming pattern: {project_name}-{service}-{environment}
Example: terraform-assessment-ec2-dev
```

**If Naming Conflict Occurs:**
```
Error: service does not support creation of this resource type

# Solution: Change project_name variable
terraform apply -var="project_name=tf-assessment-v2" ...
```

---