FROM alpine:latest

# shadow is required for useradd/usermod
# bash for entrypoint script
# openssh for ssh and sftp
# openjdk21-jre udev for Minecraft 
RUN apk add --no-cache openssh bash shadow openjdk21-jre udev

# gosu for exec as another user
ENV GOSU_VERSION 1.17
RUN set -eux; \
	\
	apk add --no-cache --virtual .gosu-deps \
		ca-certificates \
		dpkg \
		gnupg \
	; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
# clean up fetch dependencies
	apk del --no-network .gosu-deps; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu --version; \
	gosu nobody true

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
# CMD [ "/usr/sbin/sshd", "-D", "-e" ]
