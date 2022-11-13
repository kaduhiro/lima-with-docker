# Lima with Docker
use Lima with Docker in macOS

## Demo

1. Create a new Lima instance
```shell
$ make up
? Creating an instance "ubuntu" Proceed with the current configuration
INFO[0004] Attempting to download the image from "https://cloud-images.ubuntu.com/releases/22.04/release-20221018/ubuntu-22.04-server-cloudimg-arm64.img"  digest="sha256:f753d6f9cea84e4f35160b77189c422578fbb007e789b7e66d96edd6d8a3fa34"
613.25 MiB / 613.25 MiB [-----------------------------------] 100.00% 7.15 MiB/s
INFO[0092] Downloaded the image from "https://cloud-images.ubuntu.com/releases/22.04/release-20221018/ubuntu-22.04-server-cloudimg-arm64.img"
INFO[0093] [hostagent] Starting QEMU (hint: to watch the boot progress, see "/Users/user/.lima/ubuntu/serial.log")
...
```

2. List Lima instances
```shell
$ make list
NAME      STATUS     SSH                ARCH       CPUS    MEMORY    DISK      DIR
ubuntu    Running    127.0.0.1:22222    aarch64    4       8GiB      100GiB    /Users/user/.lima/ubuntu
```

3. Add a public key for SSH connection
```shell
$ make ssh-keyadd
Warning: Permanently added '[127.0.0.1]:22222' (ED25519) to the list of known hosts.
```

4. SSH connection with private key
```shell
$ make ssh
...
Last login: Sun Nov 13 02:15:02 2022 from 192.168.5.2
user@lima-ubuntu:~$
```

5. Make sure docker is available from the host
```shell
$ make alpine
3275d7ff8c0bfeb7c3c2a3ca4e2b52c8b1857a1faf6aeab6925559526edb85df

$ docker ps
CONTAINER ID   IMAGE           COMMAND     CREATED         STATUS         PORTS     NAMES
3275d7ff8c0b   alpine:latest   "/bin/sh"   2 seconds ago   Up 2 seconds             charming_jennings

$ docker exec 3275d7ff8c0b date
Sun Nov 13 02:37:47 UTC 2022

$ docker stop 3275d7ff8c0b
3275d7ff8c0b
```

## Requirement

### OS
* macOS

### Command
* make
* docker

## Usage

```
usage: make <target>

targets:
  start             start an instance
  stop              stop an instance
  list              list instances
  shell             execute shell
  up                create a new instance
  alpine            create an alpine container
  ssh-keyadd        add the public key for ssh connection
  ssh               ssh connection with the private key
  help              list available targets and some
```
