#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
. ~/Documents/Github/2.1.linux/1.Install/01_set_env_variables.sh

$DBG $'\n'"${BASH_SOURCE[0]#/home/perubu/Documents/Github/}"

# Exit if APP is already installed
APP=podman
# if command -v "$APP" >/dev/null; then
#     $DBG $'\t'"$APP" is already installed
#     [[ "$0" == "${BASH_SOURCE[0]}" ]] && exit 0 || return 0
# fi

# forcing to install if launched from CLI
# when sourced, exiting if package is already installed
if [[ "$0" == "${BASH_SOURCE[0]}" ]] || ! command -v "$APP"; then

    case $ID in
    fedora)
        $DBG -e "\n$APP not implemented in $ID\n"
        ;;
    linuxmint | ubuntu)
        ENTRY=1
        case $ENTRY in
        1)
            # Install Podman on your system
            sudo apt install podman
            ;&
        2)
            # Create a Podmanfile with build instructions
            cat <<. >Podmanfile
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
       git \
       build-essential \
       cmake \
       libtool \
       pkg-config

RUN git clone https://git.ffmpeg.org/ffmpeg.git

WORKDIR /ffmpeg
RUN ./configure --disable-everything --enable-gpl --enable-libass && \
    make -j$(nproc) && \
    make install
.
            ;&
        3)
            # Build the Podman image
            podman build -f Podmanfile -t ffmpeg-build .
            ;&
        4)
            # Run the image to start a container
            podman run -it ffmpeg-build bash
            printf "%s\n" 'The package binary will be available inside at /usr/local/bin/ffmpeg'
            ;;
        *) echo "$APP" 'install done' ;;
        esac
        ;;
    *)
        echo "Distribution $ID not recognized, exiting ..."
        exit 1
        ;;
    esac

    LINKS="${0#/*}"/links_pj.sh
    [[ -f $LINKS ]] && $LINKS

    $RUN "$APP"

fi
