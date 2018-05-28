#!/bin/sh

##################################################
# Install packages:
#   use case:
#     - you don't have python installed device (no management possible through
#       ansible opkg module)
#      - don't want to install python (takes lot of room and may not have an
#        extroot available"
##################################################
opkg update && opkg install \
  zsh \
  vim \
  tmux \
  git \
  tcpdump \
  nmap \
  mtr \
  rsync \
  bind-dig \
  block-mount \
  kmod-usb-storage \
  kmod-fs-ext4 \
  curl \
  wget \
  less \
  luci-ssl-openssl \
  ca-certificates \
  openssl-util \
  sudo \
  shadow-useradd
  shadow \

#   6rd \
#   python \
#   python-openssl \
#   wol \
#   etherwake \
#   openssh-client \
#   openssh-server \
#   openssh-keygen \
#   openssh-sftp-server \
#   openssh-client-utils \

opkg install  \
  zsh \
  vim \
  tmux \
  git \
  tcpdump \
  nmap \
  mtr \
  rsync \
  bind-dig \
  block-mount \
  kmod-usb-storage \
  kmod-fs-ext4 \
  curl \
  wget \
  less \
  luci-ssl-openssl \
  ca-certificates \
  openssl-util \
  sudo \
  shadow-useradd
  shadow \
