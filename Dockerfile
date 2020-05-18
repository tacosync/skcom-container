FROM ubuntu:eoan

# 先把套件庫切換到國網中心加速
# ==========================
# 注意!! 如果這一段在 DockerDesktop for Windows 發生下列問題
#
# E: Release file for http://free.nchc.org.tw/ubuntu/dists/focal-updates/InRelease
#    is not valid yet (invalid for another 7h 52min 41s).
#    Updates for this repository will not be applied.
#
# 表示用於跑 Docker 的虛擬機器沒有校正時間, 需要調整 Hyper-V 的設定修正這個問題
#
# Get-VMIntegrationService -VMName "DockerDesktopVM" -Name "時間同步化"
# Disable-VMIntegrationService -VMName "DockerDesktopVM" -Name "時間同步化"
# Enable-VMIntegrationService -VMName "DockerDesktopVM" -Name "時間同步化"
#
# 注意大部分文件寫的參數是 "Time Synchronization",
# 但是在中文 Windows 務必要用中文參數名稱 "時間同步化" (幹! 又是正版軟體受害者)
#
# 參考文件: https://thorsten-hans.com/docker-on-windows-fix-time-synchronization-issue

RUN sed -i 's/\(security\|archive\).ubuntu.com/free.nchc.org.tw/' /etc/apt/sources.list && \
    dpkg --add-architecture i386 && \
    apt-get update

# 設定時區

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# 安裝相依套件

RUN apt-get install -y \
    wget gnupg2 supervisor software-properties-common \
    xvfb x11vnc xdotool \
    cabextract vim

# 安裝 Wine Stable

RUN wget -O - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ eoan main' && \
    apt-get update && \
    apt-get install -y winehq-stable

# 安裝 IceWM Window Manager

RUN apt-get install -y icewm

# skbot 使用者設定

RUN useradd -m -r -p "" -s /bin/bash skbot && \
    su -l skbot -c 'echo "" >> .bashrc' && \
    su -l skbot -c 'echo "export DISPLAY=:0" >> .profile' && \
    su -l skbot -c 'echo "export WINEARCH=win32" >> .profile' && \
    su -l skbot -c 'echo "export PATH=\$PATH:/opt/wine-stable/bin" >> .profile' && \
    su -l skbot -c 'wget -nv https://dl.winehq.org/wine/wine-mono/4.9.4/wine-mono-4.9.4.msi' && \
    su -l skbot -c 'wget -nv https://dl.winehq.org/wine/wine-gecko/2.47.1/wine-gecko-2.47.1-x86.msi' && \
    su -l skbot -c 'wget -nv https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' && \
    su -l skbot -c 'mkdir -p .cache/wine' && \
    su -l skbot -c 'mv *.msi .cache/wine' && \
    su -l skbot -c 'chmod +x winetricks' && \
    su -l skbot -c 'mkdir .vnc' && \
    su -l skbot -c 'x11vnc -storepasswd 0000 .vnc/passwd'

# supervisord 設定
ADD supervisord-bg.conf /root/supervisord-bg.conf
ADD supervisord-fg.conf /root/supervisord-fg.conf
ADD waitproc.sh /root/waitproc.sh
RUN chmod +x /root/waitproc.sh

# 建置 wine 環境
# 注意!! wineboot --init 執行完後, 需要等 wineserver 關閉, 之後才能正常運作

RUN supervisord -c /root/supervisord-bg.conf && \
    /root/waitproc.sh icewm started && \
    echo "Initialize wine environment for user skbot ..." && \
    su -l skbot -c 'wineboot --init' && \
    /root/waitproc.sh wineserver terminated && \
    su -l skbot -c 'wget -nv https://www.python.org/ftp/python/3.8.3/python-3.8.3.exe' && \
    su -l skbot -c 'wine python-3.8.3.exe /passive' && \
    kill `cat /root/supervisord.pid` && \
    /root/waitproc.sh supervisord terminated
