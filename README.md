[![MagicMirror²: The open source modular smart mirror platform. ](https://github.com/MichMich/MagicMirror/raw/master/.github/header.png)](https://github.com/MichMich/MagicMirror)

**MagicMirror²** is an open source modular smart mirror platform. With a growing list of installable modules, the **MagicMirror²** allows you to convert your hallway or bathroom mirror into your personal assistant.

# Forked container
This is a forked project from the original container [bastilimbach/docker-MagicMirror](https://github.com/bastilimbach/docker-MagicMirror)

# What is new in this repository?
Compared to other forks, this repository indeed adds some extra to the container but also changes it its base architecture.
**For now, only aarch64, arm32, and x86_32/64 are supported. aarch64 is actively tested, let me know if others do not work!**

The extra feature added are as follows:
 - Upgraded to a newer *node* base image from *v12* to *v16-slim*
 - Added proper loldht_22 and wiringpi modules to let the container use DHT22 sensor properly straight away
 - For development purposes, not only `config` and `modules` are used as *volume* but `css` and `js`, too
 - Added `docker-compose.yml` for docker-compose and easy install
    - `docker-compose.yml` template already contains a lot of extra things you can configure, e.g., give the right credentials to the container without elevating it into privileged mode.
- Added nice BASH prompt if attaching to the container

# Before heading towards
Specify the architecture you are going to work with, and rename files accordingly.
## x86 (64-bit)
```
mv Dockerfile_amd64 Dockerfile
mv docker-compose_amd64.yml docker-compose.yml
```
## x86 (32-bit)
Check `Dockerfile_amd64` and `docker-compose_amd64` files and adapt them to i386.
## Raspberry PI/Arm 32-bit
```
mv Dockerfile_armhf Dockerfile
mv docker-compose_armhf.yml docker-compose.yml
```
## Raspberry PI/Arm 64-bit
```
mv Dockerfile_aarch64 Dockerfile
mv docker-compose_aarch64.yml docker-compose.yml
```

# Compile the container on your own
Use the corresponding built-in `test-build_[ARCH].sh` to create your container. The script will also delete and recreate directories, and removes old docker image with the same name. Please, check `test-build_[ARCH].sh` first before blindly running it.

Once you run the script you will have the image built on your system.

Docker images will be uploaded to the docker hub soon.


## Start container
### via docker
Substitute `[ARCH]` with your architecture
```
docker run  -dit \
	--publish 80:8080 \
	--restart always \
	--volume $PWD/config:/opt/magic_mirror/config \
	--volume $PWD/modules:/opt/magic_mirror/modules \
	--volume $PWD/css:/opt/magic_mirror/css \
	--volume $PWD/js:/opt/magic_mirror/js \
	--name magicmirror \
	cslev/magicmirror:[ARCH]
```
Use further options if needed, e.g., privileged, cap_add.

### via docker-compose (arch specific)
Check the `docker-compose.yml` according to you architecture for all details. 
Use specialized networking and bridging to let modules to access your local network.
You can run with the default settings as well if there is no specific requirement. 

Also, give the right credentials to the contaier to do so via `cap_add` instead of `privileged`. However, if you are unsure about the required capabilities, just use `privileged:true` at the beginning. 
(This is mostly required for raspberry pi + gpio, but who know what modules you will use, e.g., MMM-Yeelight requires proper networking access.)

If you want to bridge the container to your local network, first create a `macvlan` docker network. The example below assumes your home LAN is in the `192.168.22.0/24` subnet and your router is at `192.168.22.1`. Adopt it to your network. Also, `parent` defines your physical interface on the host network connected to the network. Use wired connection in this case...wireless was never working in my case.
```
docker network create -d macvlan \
   --subnet=192.168.22.0/24 \
   --gateway=192.168.22.1 \
   -o parent=eth0 priv_lan
```

Then, uncomment the related parts in `docker-compose.yml`:
```
...
networks:
      priv_lan: #bridge container directly to our home LAN
        ipv4_address: 192.168.22.15 #visit your router's admin page to avoid IP collision and add a fixed IP for the container there
...
priv_lan:
    external:
      name: priv_lan
...
```

### Privileged vs. cap_add
This is a real debate among docker users and masters. Normally, *privileged* can be considered as running something as *root* with access to all system-level components. *cap_add* is something like *sudo* + *proper access control*. I personally like *cap_add* better because I am in control of what my container can do (you never know what a MagicMirror module might have hidden). To find out what you need, just check what capabilties are available [here](https://docs.docker.com/engine/reference/run/)

### Networking-related modules
[Docker-compose bug?]: If you want to run modules that interact with elements in your local network (e.g., MMM-Yeelight), you have to assure that the primary interface inside the container is not the NAT'd docker interface but the one that have access to the LAN (e.g., the `priv_lan` above).
Easiest way to do so is to not 

# More info
Visit the original repository for more basic information that is you did not find here.

[bastilimbach/docker-MagicMirror](https://github.com/bastilimbach/docker-MagicMirror)
