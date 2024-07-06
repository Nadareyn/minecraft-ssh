# papermc-nico

Docker image for papermc with ssh access

<p align="center" style="max-height: 400px">
  <img src="assets/papermc-nico.jfif" title="papermc-nico image" />
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
- `/data` exposed folder for ssh. Contains all papermc server data
- `/etc/cache_keys` cache for ssh keys. Avoid key generation at each startup

### Example
```
version: '3.7'
services:
  papermc-nico:
    image: nadareyn/papermc-nico:main
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
- multi ssh users
- tag image with "latest" tag
- download papermc server
- start papermc server at startup

## Usefull links
- https://papermc.io
- https://github.com/panubo/docker-sshd
- https://github.com/mickaelperrin/docker-sftp-server
