ARG DEBIAN_VERSION
FROM debian:${DEBIAN_VERSION}-slim
ENTRYPOINT ["/bin/sh","-c"]
RUN apt update && \
apt --assume-yes upgrade && \
apt --assume-yes install bash-completion python3-pip kiwi-systemdeps-iso-media && \
pip3 install --exists-action=i --break-system-packages kiwi==10.2.* && \
apt autoclean
