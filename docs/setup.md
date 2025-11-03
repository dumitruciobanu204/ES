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

# Container Setup: Escape Environment
This section covers the creation and deployment of the ES container environment on the previously provisioned VM. It details the container image preparation, user creation, SSH configuration, security hardening, and public accessibility considerations. This establishes the functional puzzle environment that players will connect to, while maintaining isolation from the host and other containers.

## Container User and Workspace
**Host-side user:**
- Created `escape` user to administer the game environment
- Granted temporary sudo for package installs (Podman, network tools, etc.), but production gameplay does **not** require container users to be sudoers

**Justification:**
- Host-level isolation: separating game management from root reduces risk
- Workspace Directory: `/home/escape/escape-level1` dedicated to Dockerfiles, container build artifacts, and game files for Level 1. Each level will have its own directory under `/home/escape/` (e.g., `/home/escape/escape-level2`), ensuring isolation of files and containers per level
- Maintains organizational clarity and reproducibility for future levels

## First Container: Escape Level 1

### Image Selection and Preparation
- **Base image:** `alpine:latest` (optimized for minimal resource usage)
- **Installed in image:** `openssh-server` (for SSH access)

**Justification:**
- Alpine provides a lightweight runtime, ideal for public-access puzzle containers
- SSH enables interactive remote gameplay/testing without host exposure

### Container User Configuration
- **User inside container:** Created dedicated `escape` user with password "escape"
- **Privileges:** Not a sudoer; designed for gameplay isolation

**Justification:**
- Prevents escalation risks and enforces container boundaries
- Simple password authentication for initial level access

### Dockerfile Configuration
- Uses `alpine:latest` as the lightweight base image
- Updates APK package index and installs `openssh-server` without cache to keep image size minimal
- Creates a non-root user `escape` with password `escape` for gameplay access
- Prepares SSH by:
  - Creating `/var/run/sshd` directory
  - Generating SSH host keys using `ssh-keygen -A`
  - Configuring SSH daemon to:
    - Listen on port `2222` instead of default `22`
    - Disable root login (`PermitRootLogin no`)
    - Enable password authentication (`PasswordAuthentication yes`)
    - Restrict access to `escape` user only (`AllowUsers escape`)
    - Limit authentication attempts (`MaxAuthTries 3`)
- Exposes port `2222` for SSH access
- Sets container command to run SSH daemon in the foreground (`/usr/sbin/sshd -D`)

### Security Hardening
**Runtime Restrictions**
- `--security-opt=no-new-privileges` — blocks processes from getting elevated privileges even if binaries contain setuid bits.
- `--memory=512m` — caps total memory usage, preventing exhaustion or denial-of-service on the host.
- `--cpus=1.0` — isolates CPU access to a single core, ensuring predictable performance and eliminating cross-container contention.
- `--publish 0.0.0.0:2222:2222` — explicitly exposes a single port (2222) for controlled external access; no other ports are reachable.

**SSH Daemon Constraints**
- `PermitRootLogin no` — disables root authentication, removing the highest-privilege attack vector.
- `AllowUsers escape` — enforces a single allowed login identity; no other users permitted to authenticate.
- `MaxAuthTries 3` — limits repeated login attempts, mitigating brute-force attacks.
- `PasswordAuthentication yes` — retained intentionally for gameplay mechanics; future iterations may migrate to key-based auth for admin channels only.
- `Port 2222` — segregates container-level SSH from host SSH (default 22), preventing accidental interference or exposure.

**Filesystem and Image-Level Controls**
- Base image: `alpine:latest` — minimal footprint reduces available binaries and libraries for exploitation.
- `apk add --no-cache` — prevents cached package persistence, minimizing attack surface and image bloat.
- `/var/run/sshd` isolated runtime directory — ensures no host file system mounts are involved.
- No volume mounts or privileged flags used — the container operates entirely within its namespace.

**Operational Practices**
- Clean rebuild enforced by `start-docker.sh` through `podman stop` and `podman rm` before launch — guarantees no state carryover or residual sessions.
- Detached mode `(-d)` ensures background execution under isolated context.
- Non-sudo user `escape` inside container restricts filesystem modification and command execution scope.

### Security Validation
- SSH Access: login as `escape` works; root login blocked.
- Privileges: no `sudo`, `NoNewPrivs=1`, seccomp enabled.
- Filesystem: container cannot write to `/etc`, `/bin`, `/usr`; host FS inaccessible.
- Package Management: `apk update` denied.
- Resources: CPU and memory limits enforced; process spawning constrained.
- Network: only container-internal interfaces reachable; external LAN blocked.
- Mounts: overlay filesystem; no host mounts, tmpfs for `/dev` and `/proc`.

