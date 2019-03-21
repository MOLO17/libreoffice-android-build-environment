#!/bin/bash

set -e

LO_CORE=${LO_CORE:=libreoffice-core} 

git clone https://github.com/MOLO17/${LO_CORE} --depth 100 \
&& cp autogen.input.example ${LO_CORE}/autogen.input \
&& cp LibreOfficeAndroidCustom.conf ${LO_CORE}/distro-configs/
&& cd ${LO_CORE}
&& ./autogen.sh
&& true
