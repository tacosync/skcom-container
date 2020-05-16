# 實驗階段用 script

```
docker build -t skbot:sandbox .
docker run --name skbot-0 -p 5900:5900 -it skbot:sandbox
docker start -i skbot-0
docker rm skbot-0
```

# 作業系統選擇問題

Wine 並不是在所有系統都能順利運作, 有些疑難問題需要用特殊手段才排解, 需要消耗大量時間
現階段用 Ubuntu 19.10 是最佳選擇

系統                    | 實際狀況
------------------------|--------------------------------------------------------------------
Ubuntu 19.10 eoan       | 可以順利安裝
Ubuntu 20.04 LTS focal  | PPA 提供的 winehq-stable 只到 4.0.4 版, 後續安裝 mono 與 gecko 會失敗
Ubuntu 18.04 LTS bionic | 需要先自行安裝 libfaudio 套件
Debian 10 buster        | 需要先自行安裝 libfaudio 套件

## Debian, Ubuntu 18 遇到的問題

```
The following packages have unmet dependencies:
 winehq-stable : Depends: wine-stable (= 5.0.0~buster)
E: Unable to correct problems, you have held broken packages.
```

## Ubuntu 20 遇到的問題

安裝 wine-mono 與 wine-gecko 會出現 1603 的錯誤碼, 然後再安裝其他軟體都會意外中斷
