# minecraft-ssh

Docker image for minecraft with ssh access

<p align="center" style="max-height: 400px">
  <img src="assets/minecraft-ssh.jfif" title="minecraft-ssh image" />
</p>

## Options

### SSH options
- `USERNAME` the ssh username
- `PASSWORD` the ssh password

### Minecraft options
- `JAR_PATH` path to the minecraft jar. It should be `/data/$JAR_PATH`

### Other options
- `KEEP_ALIVE` set to `1` to avoid container ending if minecraft server is stopped. Set it if you need ssh access without minecraft installed yet. 

## How to use

### Ports 
- Port `22` for ssh access. We strongly recommend to expose another port on internet network. 22 should be used by docker server itself.
- Port `25565` in tcp/udp for parpermc

### Volumes
We strongly recommend to mount the following volumes:
- `/data` exposed folder for ssh. Contains all minecraft server data
- `/etc/cache_keys` cache for ssh keys. Avoid key generation at each startup

### Example
```
version: '3.7'
services:
  minecraft-ssh:
    image: nadareyn/minecraft-ssh
    ports:
      - 2244:22
      - 25565:25565/tcp
      - 25565:25565/udp
    volumes:
      - data:/data
      - cache_keys:/etc/cache_keys
    environment:
      USERNAME: '*******'
      PASSWORD: '*******'
      JAR_PATH: 'server/minecraft.jar'
      KEEP_ALIVE: 0
```

## TODO
- autorize password encryption
- autorize password from /etc/environment 

## Usefull links
- https://papermc.io
- https://github.com/panubo/docker-sshd
- https://github.com/mickaelperrin/docker-sftp-server
