# Build environment for LibreOffice Android Viewer

Configuration to build a docker image with a build environment
for LibreOffice Android Viewer.

The image is based on Debian and allows access by a regular user
with sudo rights through SSH via RSA public key authentication.

## How to build the docker container

You need [Docker](https://www.docker.com/get-started) and 
[Git](https://www.git-scm.com/download) to be installed on your platform.

From within a suitable directory of your choice (for example `~/projects/libreoffice`),
run from the command line:

	git clone https://github.com/MOLO17/libreoffice-android-build-environment.git

then:

	docker build --tag=libreoffice-android-build-environment ./libreoffice-android-build-environment


and go for a coffee break :)


## How to build LibreOffice for Android

Login in as `docker` user with SSH (more below) or either with:

	docker run -it libreoffice-android-build-environment su docker -l

Just run `make` within the `libreoffice-core` project folder to start a build.


## How to login into the container with SSH

To run an SSH daemon in a new container:

    docker run -d -p 2222:22 -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" libreoffice-android-build-environment

That implies a public key in `~/.ssh/id_rsa.pub`.

SSH access using your key will be allowed for `docker`
(a regular user with passwordless `sudo`) and
`root` (superuser).

To connect to this container as regular user:

    ssh -p 2222 docker@localhost


To connect to this container as root:

    ssh -p 2222 root@localhost


You can change `2222` to any local port number of your choice.


## Credits

* [Muhammet Kara](https://github.com/mrkara/libreoffice-build-environment)
* [Kirill Müller](https://github.com/krlmlr/debian-ssh)
* [Bitrise's Android Docker image](https://github.com/bitrise-docker/android)
* [Bitrise's NDK Android Docker image](https://github.com/bitrise-docker/android-ndk)
