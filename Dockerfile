FROM alpine:latest

# shadow is required for useradd/usermod
# bash for entrypoint script
# openssh for ssh and sftp
# openjdk21-jre udev for papermc
RUN apk add --no-cache openssh bash shadow openjdk21-jre udev

# optional packages
RUN apk add --no-cache nano

# SSH Server configuration file
ADD sshd_config /etc/ssh/sshd_config
RUN addgroup sftp

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN mkdir /data
RUN mkdir /etc/cache_keys

# 22 for ssh
EXPOSE 22
# 25565 for papermc
EXPOSE 25565/tcp
EXPOSE 25565/udp

ENTRYPOINT [ "/entrypoint.sh" ]

# RUN SSH in no daemon and expose errors to stdout
CMD [ "/usr/sbin/sshd", "-D", "-e" ]
