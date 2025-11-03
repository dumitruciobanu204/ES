## Introduction
ES is an interactive, command-line Linux puzzle game where players SSH into isolated container environments. Players start with a single container and solve puzzles to obtain SSH keys that unlock access to the next container, progressing through a chain of stages. Each player is provisioned with a separate set of containers to ensure independent sessions. This project teaches container security, user isolation, and SSH key management in a safe and educational way, while providing a fun, progressive puzzle experience. SSH keys themselves serve as part of the puzzle progression, integrating gameplay with secure authentication practices.

## Project Justification
This project aims to:
- Showcase Linux system administration, containerization, network isolation, and secure authentication skills.
- Provide a portfolio-ready demo that balances creativity in puzzle design with rigorous security practices.
- Educate players about Linux commands, cryptography fundamentals, and real-world SSH workflows.
- Guarantee security by isolating containers per player, preventing cross-user interference and protecting the host system.
- Follow best practices for container security, including use of trusted base images and regular updates to minimize vulnerabilities.

## Project Purpose
Players will:
- Use unique SSH keys from one stage to access their own dedicated container at the next stage.
- Solve puzzles that increase in complexity, from file discovery to scripting challenges.
- Experience secure, isolated Linux environments with puzzle states preserved per player, ensuring fairness and integrity.
- Run puzzles on containers built from trusted, minimal base images updated regularly to reduce attack surfaces.
- The design is portable, reproducible, and safe to run on local VMs or cloud instances.

## Implementation Plan
Host and Runtime: Run on a single Ubuntu VM with rootless Podman, creating isolated container instances per player.
- Per-player Container Sets: Each player’s containers are fully independent, preventing configuration or puzzle changes from affecting others.
- Container Hardening: Containers have read-only filesystems except for temporary directories; SSH keys and puzzles are preconfigured. Capabilities are dropped, and resource limits (memory, CPU, PIDs) ensure stability and protect the host from denial-of-service.
- Network Isolation: Containers are network-isolated to prevent players from accessing each other’s containers or the host.
- Puzzle Flow: Players progress by solving puzzles inside each container, obtaining SSH keys for the next stage, up to the final challenge.
- Image Management: Base container images are selected from trusted registries, kept minimal, regularly scanned for vulnerabilities, and updated routinely to ensure security.

## Justification of Approach
Rootless Containers: Provide strong isolation without the overhead of full VMs.
- Per-player Container Sets: Prevent multi-user conflicts and maintain fair puzzle states.
- SSH Key Authentication: Aligns with professional security practices, eliminates brute-force risks, and integrates directly with puzzle design.
- Read-only Filesystems and Dropped Capabilities: Prevent unauthorized persistence and privilege escalation.
- Network and User Namespace Isolation: Prevent lateral movement between players’ containers.
- Automated Provisioning: Supports scalability for multiple simultaneous users and easy rebuilds.
- Trusted Base Images and Updates: Using minimal and verified base images reduces vulnerabilities and minimizes attack surfaces, while routine updates keep puzzles secure from emerging threats.
- Resource Limiting: Memory, CPU, and process restrictions prevent denial-of-service scenarios and ensure stable system operation.

## Expected Outcomes
- A secure, multi-session Linux puzzle game that runs efficiently on modest hardware or free cloud tiers.
- An educational, interactive experience focused on real-world Linux and security practices.
- Clear documentation and optional visual diagrams explaining architecture, SSH key flow, and security models.
- A portfolio-ready project demonstrating expertise in container security, DevOps, and puzzle design.

## Conclusion
ES provides a secure, isolated, and scalable environment for players to learn Linux and security fundamentals. By provisioning independent container sets for each player and using trusted, regularly updated base images, the game prevents cross-user interference, preserves puzzle integrity, and keeps the host fully protected. The use of SSH keys as part of the puzzle design demonstrates professional security practices while enhancing the gameplay experience. This combination of technical rigor and creative puzzle design makes the project an ideal addition to a portfolio.

## Current Status
- VCN, subnet, and internet gateway have been successfully configured.
- Default security list with SSH and ICMP rules active, to be refined.
- Ubuntu VM provisioned on Oracle Cloud Free Tier with Podman installed.
- SSH access verified and stable.
- The Escape Level 1 container is now:
  - Publicly accessible on port 2222
  - Securely isolated from host and other containers
  - Resource limited to prevent abuse (512MB RAM, 1 CPU)
  - Ready for puzzle content integration

