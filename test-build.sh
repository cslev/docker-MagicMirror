rm -rf ./config
rm -rf ./modules
rm -rf ./css
rm -rf ./js

mkdir config
mkdir modules
mkdir css
mkdir js

docker rm -f magicmirror
docker rmi cslev/magicmirror:latest
docker build -t cslev/magicmirror:latest .
docker run  -dit \
	--publish 80:8080 \
	--restart always \
	--volume $PWD/config:/opt/magic_mirror/config \
	--volume $PWD/modules:/opt/magic_mirror/modules \
	--volume $PWD/css:/opt/magic_mirror/css \
	--volume $PWD/js:/opt/magic_mirror/js \
	-e DOCKER_MODULE_INSTALL_GIT="https://github.com/slametps/MMM-Yeelight;https://github.com/Kreshnik/MMM-JokeAPI" \
	-e DOCKER_MODULE_INSTALL_CMD="npm install"\
	--name magicmirror \
	cslev/magicmirror:latest
