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

ENV ANDROID_HOME /opt/android-sdk-linux


# Install required tools
RUN apt-get update -qq


# Dependencies to execute Android builds
RUN dpkg --add-architecture i386
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386


# Download Android SDK tools into $ANDROID_HOME

RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O android-sdk-tools.zip \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} \
    && rm android-sdk-tools.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  sdkmanager --list

# Accept licenses before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file
# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and Android Google TV require separate licenses, not accepted there
RUN yes | sdkmanager --licenses

# Platform tools (excluding "emulator")
RUN sdkmanager "tools" "platform-tools" 

# SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.

# Please keep all sections in descending order!
RUN yes | sdkmanager \
    "platforms;android-28" \
    "platforms;android-27" \
    "platforms;android-26" \
    "platforms;android-25" \
    "build-tools;28.0.3" \
    "build-tools;28.0.2" \
    "build-tools;28.0.1" \
    "build-tools;28.0.0" \
    "build-tools;27.0.3" \
    "build-tools;27.0.2" \
    "build-tools;27.0.1" \
    "build-tools;27.0.0" \
    "build-tools;26.0.2" \
    "build-tools;26.0.1" \
    "build-tools;25.0.3" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1"
    
# Install Gradle from PPA

# Gradle PPA
RUN apt-get update \
 && apt-get -y install gradle \
 && gradle -v

# Install Maven 3 from PPA

RUN apt-get purge maven maven2 \
 && apt-get update \
 && apt-get -y install maven \
 && mvn --version


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


# GCC 8
RUN echo 'deb http://ftp.us.debian.org/debian testing main contrib non-free' >> /etc/apt/sources.list
RUN apt-get update \
 && apt-get -y -t testing install gcc-8 \
 && apt remove -y gcc-6

# Gperf
RUN apt-get install -t testing gperf


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

