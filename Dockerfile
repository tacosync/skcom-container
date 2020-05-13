FROM ubuntu:20.04

# 先把套件庫切換到國網中心加速
RUN sed -i 's/\(archive\|security\).ubuntu.com/free.nchc.org.tw/' /etc/apt/sources.list && \
    dpkg --add-architecture i386 && \
    apt-get update

# 搞定時區問題
# 如果沒處理, 安裝 software-properties-common 可能會弄爛
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# 安裝相依套件
# 注意!! 安裝 software-properties-common 的時候可能會需要互動式輸入時區而卡住
RUN apt-get install -y \
    wget gnupg2 software-properties-common \
    xvfb x11vnc xdotool fluxbox

# 這裡需要用到 wget gnupg2
RUN wget -O - https://dl.winehq.org/wine-builds/winehq.key | apt-key add -

# 這裡需要用到 software-properties-common
RUN add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' && \
    apt-get update && \
    apt-get install -y --install-recommends winehq-stable

# 建立 skcom 使用者
RUN useradd -m -p 0000 -s /bin/bash skcom

# 複製啟動程式 (改用 supervisord)
# COPY start.py /
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
