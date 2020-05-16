# 實驗階段用 script

```
docker build -t skbot:sandbox .
docker run --name skbot-0 -p 5900:5900 -it skbot:sandbox
docker start -i skbot-0
docker rm skbot-0
```

# 作業系統選擇

安裝發生問題時, 要留意是不是發生缺版問題,
例如在 2020-05-15 的時候, Ubuntu 20.04 LTS 提供的 stable 版本就有點舊
導致 mono 和 gecko 安裝失敗, 反而是 19.10 可以正常運作

### Debian

https://dl.winehq.org/wine-builds/ubuntu/dists/focal/main/binary-i386/

winehq-stable 5.0.0 2020-01-21

https://wiki.debian.org/Wine

```
The following packages have unmet dependencies:
 winehq-stable : Depends: wine-stable (= 5.0.0~buster)
E: Unable to correct problems, you have held broken packages.
```

### Ubuntu 20.04 LTS focal

https://dl.winehq.org/wine-builds/ubuntu/dists/focal/main/binary-i386/

winehq-stable 4.0.4 2020-04-24

### Ubuntu 19.10 eoan

https://dl.winehq.org/wine-builds/ubuntu/dists/eoan/main/binary-i386/

winehq-stable 5.0.0 2020-01-21

### Ubuntu 18.04 LTS bionic

https://dl.winehq.org/wine-builds/ubuntu/dists/eoan/main/binary-i386/

winehq-stable 5.0.0 2020-01-21

```
The following packages have unmet dependencies:
 winehq-stable : Depends: wine-stable (= 5.0.0~bionic)
E: Unable to correct problems, you have held broken packages.
```
