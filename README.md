# minecraft-ssh

Docker image for minecraft with ssh access

<p align="center" style="max-height: 400px">
  <img src="assets/minecraft-ssh.jfif" title="minecraft-ssh image" />
</p>

## Options

### SSH options
- `USERNAME` the ssh username
- `PASSWORD` the ssh password

## How to use

### Ports 
- Port `22` for ssh access
- Port `25565` in tcp/udp for parpermc

### Volumes
We strongly recommend to mount the following volumes:
- `/data` exposed folder for ssh. Contains all minecraft server data
- `/etc/cache_keys` cache for ssh keys. Avoid key generation at each startup

### Example
```
version: '3.7'
services:
  papermc-nico:
    image: nadareyn/minecraft-ssh
    ports:
      - 2244:22
      - 55565:25565/tcp
      - 55565:25565/udp
    volumes:
      - data:/data
      - cache_keys:/etc/cache_keys
    environment:
      USERNAME: '*******'
      PASSWORD: '*******'
```

## TODO
- autorize password encryption
- autorize password from /etc/environment
- multi ssh users ?
- 

## Usefull links
- https://papermc.io
- https://github.com/panubo/docker-sshd
- https://github.com/mickaelperrin/docker-sftp-server
