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
  6rd \
  zsh \
  vim \
  tmux \
  git \
  tcpdump \
  nmap \
  mtr \
  rsync \
  shadow \
  sudo \
  bind-dig \
  python \
  block-mount \
  kmod-usb-storage \
  kmod-fs-ext4 \
  curl \
  wget \
  wol \
  etherwake \
  less \
  zsh \
  openssh-client \
  openssh-server \
  openssh-keygen \
  openssh-sftp-server \
  openssh-client-utils \
  ca-certificates \
  python-openssl \
