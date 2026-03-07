ARG DEBIAN_VERSION
FROM debian:${DEBIAN_VERSION}-slim
ENTRYPOINT ["/bin/sh","-c"]
RUN apt update && \
apt --assume-yes upgrade && \
apt --assume-yes install bash-completion dosfstools e2fsprogs mtools squashfs-tools \
 qemu-utils rsync xorriso python3-pip && \
pip3 install --exists-action=i --break-system-packages kiwi==10.2.* && \
apt autoclean
