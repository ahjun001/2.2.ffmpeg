#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
. ~/Documents/Github/2.1.linux/1.Install/01_set_env_variables.sh

$DBG $'\n'"${BASH_SOURCE[0]#/home/perubu/Documents/Github/}"

APP=docker
# forcing to install if launched from CLI
# when sourced, exiting if package is already installed
if [[ "$0" == "${BASH_SOURCE[0]}" ]] || ! command -v "$APP"; then

    case $ID in
    fedora)
        $DBG -e "\n$APP not implemented in $ID\n"
        ;;
    linuxmint | ubuntu)
        ENTRY=2
        case $ENTRY in
        1)
            # Install Podman on your system
            sudo apt install docker
            ;&
        2)
            # link source file here
            # [[ -L ./ffmpeg ]] || ln -s ~/.local/share/src/ffmpeg ./ffmpeg
            rsync -a ~/.local/share/src/ffmpeg/ ./ffmpeg
            
            # Create a Podmanfile with build instructions
            cat <<. >Podmanfile
# Stage 1: build FFmpeg
FROM ubuntu:22.04 as build

RUN apt-get update && \
    apt-get install -y \
    autoconf \
    automake \
    build-essential \
    git-core \
    libass-dev \
    libtool \
    pkg-config \
    libx264-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libmp3lame-dev \
    libsdl2-dev \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    meson \
    nasm \
    ninja-build \
    pkg-config \
    texinfo \
    wget \
    yasm \
    zlib1g-dev

COPY ffmpeg /

RUN ./configure \
--disable-everything \
--enable-gpl \
--enable-gnutls \
--enable-libx264 \
--enable-libvpx \
--enable-libfontconfig \
--enable-libfreetype \
--enable-filter=drawtext \
--enable-libass

RUN make distclean
RUN make $(nproc)
RUN sudo make install 

# Stage 2: copy built FFmpeg into clean image
FROM ubuntu:22.04
COPY --from=build /ffmpeg /ffmpeg

# Use compiled FFmpeg
RUN ./ffmpeg -version

.
            ;&
        3)
            echo in step 3
            # Build the Podman image
            docker build -f Podmanfile -t ffmpeg-build .
            ;&
        4)
            # Run the image to start a container
            docker run -it ffmpeg-build bash
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
