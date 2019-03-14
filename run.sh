#!/bin/bash

set -e

/set_root_pw.sh
exec /usr/sbin/sshd -D
