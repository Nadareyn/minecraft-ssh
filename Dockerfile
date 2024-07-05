FROM alpine:latest

# bash for entrypoint script
# openssh for ssh and sftp
# openjdk21-jre for papermc
RUN apk add --no-cache openssh bash openjdk21-jre

# SSH Server configuration file
ADD sshd_config /etc/ssh/sshd_config
RUN addgroup sftp

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN mkdir /data
RUN mkdir /etc/cache_keys

EXPOSE 22
ENTRYPOINT [ "/entrypoint.sh" ]

# RUN SSH in no daemon and expose errors to stdout
CMD [ "/usr/sbin/sshd", "-D", "-e" ]
