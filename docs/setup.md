# Setup: Cloud Infrastructure and VM Provisioning

This section covers the foundational cloud infrastructure setup required to run the Escape the Shell project. It details the creation and configuration of the Virtual Cloud Network (VCN), internet gateway, subnet, security lists, and the initial virtual machine provisioning on Oracle Cloud. This groundwork establishes the necessary network segmentation, connectivity, and security postures for running containerized puzzle environments securely and efficiently.

## Virtual Cloud Network (VCN) Setup
- Name: es-vcn
- Compartment: ciobanudumitru204 (root)  
- IPv4 CIDR Block: 10.10.0.0/16  
- DNS Domain: [esvcn.oraclevcn.com](http://esvcn.oraclevcn.com/)
    
Decisions & Justifications:
- A separate VCN per project isolates infrastructure from other cloud resources, preventing accidental interference or exposure.
- The large CIDR block (10.10.0.0/16) supports multiple subnets for public/private segmentation and scalability.  
- DNS hostnames enabled for smoother internal hostname resolution simplifying container and SSH access.
    
## Internet Gateway
- Name: es-ig  
- Attached to VCN: es-vcn
    
Justification:
- Required to enable both outbound and inbound internet connectivity.
- Allows SSH connections from external IPs to the host and containers as configured.
    
## Subnet Setup
- Name: es-subnet-public  
- Type: Public  
- IPv4 CIDR: 10.10.1.0/24  
- Route Table: Default route table of es-vcn  
- DNS Resolution: Enabled
    
Ingress Rules:
- TCP 22 — SSH access currently open to 0.0.0.0/0 (to be restricted later using Oracle Cloud security rules).
- ICMP 3,4 from 0.0.0.0/0 — for network diagnostics (optional).
    
Egress Rules:
- Allow all protocols out to 0.0.0.0/0 for simplicity and to allow container updates.
    
Decisions & Justifications:
- A public subnet is required for players to access the instance hosting containers via exposed container ports.
- SSH ingress on port 22 is temporarily open for initial connectivity but is planned to be tightly restricted to admin IPs only.  
- ICMP rules facilitate basic network diagnostics.
-  Open egress enables package updates and internet access for containers and host.
    
## Security List
- Name: Default Security List for es-vcn — controls inbound and outbound traffic.
    
Ingress and Egress Summary (provisional):
- The default security list currently allows minimal rules for SSH and ICMP to support initial setup.
- SSH access (TCP port 22) will be refined later to restrict connections to specific admin IPs or bastion hosts leveraging Oracle Cloud ingress rules or Network Security Groups.
- ICMP is allowed for internal diagnostics.
- Egress remains open to permit host and container outbound traffic for updates.
    
Justification:
This baseline ensures essential network connectivity during setup, with plans to implement stricter ingress control as administrative workflows mature for improved security.
    
## Instance Creation
- Name: es-host
- Operating System: Canonical Ubuntu 24.04
- Shape Configuration:
- Shape: VM.Standard.E2.1.Micro (Oracle Cloud Free Tier)
- OCPU count: 1
- Network bandwidth (Gbps): 0.5
- Memory (GB): 1
- Local disk: Block storage only   

Decisions & Justifications:
- The selected VM shape provides 1 OCPU and 1 GB RAM aligning with free tier resource constraints.
- This configuration is suitable for demo or limited single-user testing of containerized puzzles.
- For multi-user scaling or more demanding loads, upgrading to a larger shape with more CPU and memory is recommended.
- Ubuntu 24.04 remains a solid and secure base OS choice, fully compatible with rootless Podman.
