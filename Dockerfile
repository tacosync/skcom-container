FROM ubuntu:eoan

# 套件庫切換到國網中心

RUN sed -i 's/\(security\|archive\).ubuntu.com/free.nchc.org.tw/' /etc/apt/sources.list && \
    dpkg --add-architecture i386 && \
    apt-get update

# 設定時區

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# 安裝 Wine 以外的套件

RUN apt-get install -y \
    wget gnupg2 supervisor software-properties-common \
    xvfb x11vnc xdotool icewm \
    cabextract vim

# 安裝 Wine Stable

RUN wget -nv -O - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ eoan main' && \
    apt-get update && \
    apt-get install -y winehq-stable

# skbot 使用者設定

RUN useradd -m -r -p "" -s /bin/bash skbot && \
    su -l skbot -c 'wget -nv https://dl.winehq.org/wine/wine-mono/4.9.4/wine-mono-4.9.4.msi' && \
    su -l skbot -c 'wget -nv https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86.msi' && \
    su -l skbot -c 'wget -nv https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' && \
    su -l skbot -c 'mkdir -p .cache/wine' && \
    su -l skbot -c 'mv *.msi .cache/wine' && \
    su -l skbot -c 'chmod +x winetricks' && \
    su -l skbot -c 'mkdir .vnc' && \
    su -l skbot -c 'x11vnc -storepasswd 0000 .vnc/passwd'

# 置入設定檔與工具腳本

ADD supervisord-bg.conf /root/supervisord-bg.conf
ADD supervisord-fg.conf /root/supervisord-fg.conf
ADD waitproc.sh /root/waitproc.sh
ADD dot_profile_skcom /home/skbot/.profile_skcom
RUN chmod +x /root/waitproc.sh && \
    chmod 644 /home/skbot/.profile_skcom && \
    chown skbot:skbot /home/skbot/.profile_skcom && \
    su -l skbot -c 'echo source $HOME/.profile_skcom >> .profile'

# 建置 wine 環境
# 注意!! wineboot --init 執行完後, 需要等 wineserver 關閉, 之後才能正常運作

RUN supervisord -c /root/supervisord-bg.conf && \
    /root/waitproc.sh icewm started 1 && \
    echo "Initialize wine environment for user skbot ..." && \
    su -l skbot -c 'wineboot --init' 2> /dev/null && \
    /root/waitproc.sh wineserver terminated 3 && \
    su -l skbot -c 'wget -nv https://www.python.org/ftp/python/3.8.3/python-3.8.3.exe' && \
    su -l skbot -c 'wine python-3.8.3.exe /passive' 2> /dev/null && \
    kill `cat /root/supervisord.pid` && \
    /root/waitproc.sh supervisord terminated 1
