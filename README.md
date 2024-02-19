# WireGuard Infrastructure Provisioning for AWS

This project provides scripts for provisioning WireGuard VPN infrastructure on Amazon Web Services (AWS).

- **Author:** PaperCloud Developers
- **Created on:** 29/12/2023

## Getting Started

To get started, ensure you have your credentials downladed from AWS Management Console to access the services. The credentials are usually located in the `~/.aws/` directory. Once that is done, change the directories that point to the credentials and config in the `providers.tf` file.

## Important

- AWS doesn't allow its VM images to configured very much out of the box. But they do provide a cool mechanism to run BASH scripts as `root` during the initialization of the VM image.
- AWS doesn't allow the use of passwords to log-in into the VMs as the enforce the use of key pairs. To overcome this behavior, additional scripting has been written to enable password based authentication for SSH. The default username and password to log-in to the VM is given below.
- **It is suggested to change the password immediately once logged-in.**

## Log-in Credentials

- **Username:** ubuntu
- **Password:** ec2-user@12345

## Changing Log-in Credentials

```bash
# Change Password
sudo passwd

# Disable Password-based Authentication
sudo sed -i "s/^PasswordAuthentication yes/PasswordAuthentication no/" "/etc/ssh/sshd_config"
```

## System Information

- **AMI:** Ubuntu 22.04 LTS (jammy)
- **Machine Type:** `t2.micro`
