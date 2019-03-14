# Build environment for LibreOffice Android Viewer

Configuration to build a docker image with a build environment
for LibreOffice Android Viewer.

The image is based on Debian and allows access by a regular user
with sudo rights through SSH via RSA public key authentication.


## How to login into the container with SSH

To run an SSH daemon in a new Debian "stretch" container:

    docker run -d -p 2222:22 -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" MOLO17/libreoffice-android-build-environment

This requires a public key in `~/.ssh/id_rsa.pub`.

Two users exist in the container: `root` (superuser) and `docker` (a regular user
with passwordless `sudo`). SSH access using your key will be allowed for both
`root` and `docker` users.

To connect to this container as regular user:

    ssh -p 2222 docker@localhost


To connect to this container as root:

    ssh -p 2222 root@localhost


Change `2222` to any local port number of your choice.


## How to build LibreOffice for Android

Login in as `docker` user with SSH; Run the `get-libreoffice-core.sh` script
to clone the latest 100 commits from `master` branch and get a default 
`autogen.input` configuration.

Just run `make` within the project folder to launch a build.


## Credits

* [Kirill Müller](https://github.com/krlmlr/debian-ssh)
* [Bitrise's Android Docker image](https://github.com/bitrise-docker/android)
* [Bitrise's NDK Android Docker image](https://github.com/bitrise-docker/android-ndk)
