FROM debian:stretch

# https://github.com/MOLO17/libreoffice-android-build-environment
MAINTAINER Michelangelo Altamore <michelangelo.altamore@molo17.com>


# SSH

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server sudo
ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config \
  && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && touch /root/.Xauthority \
  && true

## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory, but also be able to sudo
RUN useradd docker \
        && passwd -d docker \
        && mkdir /home/docker \
        && chown docker:docker /home/docker \
        && addgroup docker staff \
        && addgroup docker sudo \
        && true

EXPOSE 22
CMD ["/run.sh"]


# LibreOffice

# Add source list for apt (needed for build-dep)
ADD sources.list /etc/apt/sources.list
# Update software repos
RUN apt-get update
# Ugrade software
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils && apt-get -y upgrade

# Install essential packages and build tools
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential git graphviz wget vim #libkrb5-dev

# Install LibreOffice dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get -y build-dep libreoffice


# Android

# Set env var
ENV ANDROID_HOME /opt/android-sdk

# Install Android required tools
RUN apt-get update -qq

# Base (non android specific) tools
#...

# Dependencies to execute Android builds
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk ant libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1

# Download Android SDK tools into $ANDROID_HOME
RUN cd /opt && wget -q https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz -O android-sdk.tgz
RUN cd /opt && tar -xvzf android-sdk.tgz
RUN cd /opt && rm -f android-sdk.tgz

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin

# Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  android list sdk --no-ui --all --extended --use-sdk-wrapper
RUN echo y | android update sdk --no-ui --all --filter \
  platform-tools,extra-android-support

# google apis
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter \
  addon-google_apis-google-24,addon-google_apis-google-23,addon-google_apis-google-22,addon-google_apis-google-21

# SDKs
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter \
  android-24,android-23,android-22,android-21,android-20,android-19,android-17,android-15,android-10

# build tools
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter \
  build-tools-24.0.2,build-tools-23.0.2,build-tools-23.0.1,build-tools-22.0.1,build-tools-21.1.2,build-tools-20.0.0,build-tools-19.1.0,build-tools-17.0.0

# Install Gradle from PPA

# Gradle PPA
RUN add-apt-repository ppa:cwchien/gradle
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install gradle
RUN gradle -v

# Install Maven 3 from PPA
RUN apt-get purge maven maven2
RUN add-apt-repository ppa:andrei-pozolotin/maven3
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install maven3
RUN mvn --version


# Android NDK

# Download
RUN mkdir /opt/android-ndk-tmp
RUN cd /opt/android-ndk-tmp && wget -q https://dl.google.com/android/repository/android-ndk-r16b-linux-x86_64.zip
# Uncompress
RUN cd /opt/android-ndk-tmp && unzip android-ndk-r16b-linux-x86_64.zip
# Move to it's final location
RUN cd /opt/android-ndk-tmp && mv ./android-ndk-r16b /opt/android-ndk
# Remove temp dir
RUN rm -rf /opt/android-ndk-tmp
# Add env var
ENV ANDROID_NDK_HOME /opt/android-ndk
# Add to PATH
ENV PATH ${PATH}:${ANDROID_NDK_HOME}


# Get LibreOffice core
ENV LO_CORE libreoffice-core

ADD autogen.input.example /home/docker/autogen.input.example
RUN chown docker:docker /home/docker/autogen.input.example

ADD LibreOfficeAndroidCustom.conf /home/docker/LibreOfficeAndroidCustom.conf
RUN chown docker:docker /home/docker/LibreOfficeAndroidCustom.conf

ADD get-libreoffice-core.sh /home/docker/get-libreoffice-core.sh
RUN chown docker:docker /home/docker/get-libreoffice-core.sh
RUN chmod ug+x /home/docker/get-libreoffice-core.sh


# Purge apt-get cache
RUN rm -rf /var/lib/apt/lists/*

# Cleaning
RUN apt-get clean

