FROM alpine:latest

RUN apk update && apk add --no-cache openssh-server

# Add user 'escape' with password 'escape'
RUN adduser -D escape && \
    echo "escape:escape" | chpasswd

# Prepare sshd runtime directories and host keys
RUN mkdir -p /var/run/sshd && \
    ssh-keygen -A

# Configure sshd to listen on port 2222 and disable root login but enable password login
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "AllowUsers escape" >> /etc/ssh/sshd_config && \
    echo "MaxAuthTries 3" >> /etc/ssh/sshd_config

EXPOSE 2222
CMD ["/usr/sbin/sshd", "-D"]
