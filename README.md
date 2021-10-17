[![MagicMirror²: The open source modular smart mirror platform. ](https://github.com/MichMich/MagicMirror/raw/master/.github/header.png)](https://github.com/MichMich/MagicMirror)

**MagicMirror²** is an open source modular smart mirror platform. With a growing list of installable modules, the **MagicMirror²** allows you to convert your hallway or bathroom mirror into your personal assistant.

# Forked container
This is a forked project from the original container [bastilimbach/docker-MagicMirror](https://github.com/bastilimbach/docker-MagicMirror)

# What is new in this repository?
Compared to other forks, this repository indeed adds some extra to the container. 

The extra feature added are as follows:
 - Upgraded to a newer *node* base image from *v12* to *v16-slim*
 - Added some extra networking packages to let some home network modules to run properly (e.g., net-tools, ping for MMM-Yeelight)
 - Added capabilities to install extra packages and modules during running the container
    - the original `docker-entrypoint.sh` is modified to be able to:
        - download and install further thirdparty MMM modules from github by defining them via docker ENV variable
        - redefine 'npm install' command for these extra modules if needed
        - install further system packages from the repo if needed, e.g., libraries for development
- For development purposes, not only `config` and `modules` are used as *volume* but `css` and `js`, too
 - Added `docker-compose.yml` for docker-compose and easy install
    - `docker-compose.yml` template already contains a lot of extra things you can configure, e.g., give the right credentials to the container without elevating it into privileged mode.
- Added nice BASH prompt if attaching to the container


## Install additional modules
You can install additional modules by defining a docker environment variable and separating the modules via ';'
```
-e DOCKER_MODULE_INSTALL_GIT="https://github.com/slametps/MMM-Yeelight;https://github.com/Kreshnik/MMM-JokeAPI"
```

Redefine install script of 'npm install' if you need something more special
```
-e DOCKER_MODULE_INSTALL_CMD="npm install"
```

Install additional libraries from the system repository, e.g., `ping` utility
```
-e DOCKER_MODULE_ADDITIONAL_DEPS="iputils-ping"
```

## Start container
### via docker
```
docker run  -dit \
	--publish 80:8080 \
	--restart always \
	--volume $PWD/config:/opt/magic_mirror/config \
	--volume $PWD/modules:/opt/magic_mirror/modules \
	--volume $PWD/css:/opt/magic_mirror/css \
	--volume $PWD/js:/opt/magic_mirror/js \
	-e DOCKER_MODULE_INSTALL_GIT="https://github.com/slametps/MMM-Yeelight;https://github.com/Kreshnik/MMM-JokeAPI" \
	-e DOCKER_MODULE_INSTALL_CMD="npm install"\
	-e DOCKER_MODULE_ADDITIONAL_DEPS="iputils-ping"\
	--name magicmirror \
	cslev/magicmirror:latest
```
Use further options if needed, e.g., privileged, cap_add.

### via docker-compose
Check `docker-compose.yml` for all details. Use specialized networking and bridging to let modules to access your local network.

Also, give the right credentials to the contaier to do so via `cap_add` instead of `privileged`. However, if you are unsure about the required capabilities, just use `privileged:true` at the beginning.

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


# More info
Visit the original repository for more basic information that is you did not find here.

[bastilimbach/docker-MagicMirror](https://github.com/bastilimbach/docker-MagicMirror)
