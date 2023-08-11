#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
. ~/Documents/Github/2.1.linux/1.Install/01_set_env_variables.sh

$DBG $'\n'"${BASH_SOURCE[0]#/home/perubu/Documents/Github/}"

# Exit if APP is already installed
APP=ffmpeg
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
        clear
        INDEX=3
        case $INDEX in
        0)
            git clone https://git.ffmpeg.org/ffmpeg.git ~/.local/share/src/ffmpeg
            ;;

        1)
            sudo apt install build-essential git libtool pkg-config autoconf automake \
                nasm yasm \
                x264 libx264-dev \
                libfontconfig1-dev \
                libharfbuzz-dev \
                -y
            ;&

        2)
            pushd ~/.local/share/src/ffmpeg || exit 1
            git pull https://git.ffmpeg.org/ffmpeg.git
            popd
            ;&
        3)
            pushd ~/.local/share/src/ffmpeg || exit 1
            # [[ -f ./tests/Makefile ]] &&
            # make clean # remove object files and executables but keeps configure files and Makefiles.
            # [[ -f ./tests/Makefile ]] &&
            make distclean && echo # will remove everything including configure scripts and Makefiles
            rm -f Makefile && echo 
            git clean -fdx && echo 
            ./configure --prefix=/opt/ffmpeg \
                --enable-libx264 \
                --enable-gpl \
                --enable-libfontconfig \
                --enable-libfreetype \
                --enable-filter=drawtext \
                --enable-libharfbuzz

            # shellcheck disable=SC2046
            # make -j$(nproc)
            make -j1
            sudo make install
            popd
            ;&
        4)
            sudo ln -fs /opt/ffmpeg/bin/ffmpeg /usr/local/sbin/ffmpeg
            sudo ln -fs /opt/ffmpeg/bin/ffprobe /usr/local/sbin/ffmprobe
            ;;
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
