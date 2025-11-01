FROM alpine:latest

RUN apk update && apk add --no-cache openssh-server

RUN adduser -D escape && \
    echo "escape:escape" | chpasswd && \
    mkdir -p /var/run/sshd && \
    ssh-keygen -A && \
    sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 2222
CMD ["/usr/sbin/sshd", "-D"]
