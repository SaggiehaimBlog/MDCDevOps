# MDCDevOps

A repository showcasing Microsoft Defender for Cloud DevOps capabilities and integration scenarios.

## Overview

This repository demonstrates how to implement security scanning and protection in your DevOps pipelines using Microsoft Defender for Cloud. It provides examples and best practices for securing your development lifecycle.

## Features

- Pipeline security scanning
- Container image vulnerability assessment
- Infrastructure as Code (IaC) security validation
- Supply chain security monitoring
- Security misconfigurations detection

## Prerequisites

- Azure subscription
- Microsoft Defender for Cloud enabled
- Azure DevOps organization or GitHub account
- Permissions to configure security policies

## Setup

1. Enable Microsoft Defender for Cloud in your Azure subscription
2. Connect your DevOps platform (Azure DevOps/GitHub)
3. Configure security policies
4. Set up pipeline scanning

## Usage

### Pipeline Integration

Add the security scanning task to your pipeline:

```yaml
steps:
- task: MicrosoftSecurityDevOps@1
  displayName: 'Microsoft Security DevOps'
```

### Security Policies

Configure security policies through:

1. Azure Portal
2. Infrastructure as Code
3. CI/CD pipelines

## Best Practices

- Enable continuous scanning
- Set up automated remediation
- Configure security notifications
- Review security findings regularly

## Infrastructure as Code (Terraform)

### YOR Integration

[YOR](https://github.com/bridgecrewio/yor) is an automatic IaC tag and trace tool that helps maintain consistent resource tagging across your infrastructure. This repository implements YOR tagging for:

- Resource ownership tracking
- Cost allocation
- Security compliance
- Change management

### Terraform Resources

This repository deploys the following Azure resources:

- Virtual Network
- Network Security Groups
- Azure Container Registry
- Azure Kubernetes Service
- Key Vault

### Required Terraform Changes

Before deploying, update the following in your Terraform files:

1. In `variables.tf`:
   - Set your desired `region`
   - Update `resource_group_name`
   - Modify `environment` tag


### YOR Tags Example

After YOR processing, your resources will include these tags:

```hcl
tags = {
  git_commit           = "abc123..."
  git_file            = "main.tf"
  git_last_modified   = "2023-01-01-12:00:00"
  git_org             = "your-org"
  git_repo            = "MDCDevOps"
  yor_trace           = "12345-abcd-..."
}
```

### Required Secrets

Configure repository secrets under Settings > Secrets and variables > Actions:


## Contributing

Feel free to contribute by submitting issues or pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
