FROM debian:12.9-slim
RUN apt update && \
apt --assume-yes upgrade && \
apt --assume-yes install bash-completion python3-pip kiwi-systemdeps-iso-media && \
pip3 install --exists-action=i --break-system-packages kiwi==v10.2.6 && \
apt autoclean
