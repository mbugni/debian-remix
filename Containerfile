ARG DEBIAN_VERSION
ARG IMAGE_REGISTRY=docker.io
FROM ${IMAGE_REGISTRY}/debian:${DEBIAN_VERSION}-slim
ENTRYPOINT ["/bin/sh","-c"]
RUN apt update && \
apt --assume-yes upgrade && \
apt --assume-yes install bash-completion dosfstools e2fsprogs mtools squashfs-tools \
 qemu-utils rsync xorriso grub-pc-bin python3-pip && \
pip3 install --exists-action=i kiwi==10.2.* && \
apt autoclean
