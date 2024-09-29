FROM debian:12.7-slim
RUN apt update && \
apt --assume-yes upgrade && \
apt --assume-yes install bash-completion python3-pip debootstrap kiwi-systemdeps-iso-media && \
pip3 install kiwi==10.0.27 --break-system-packages && \
apt autoclean
