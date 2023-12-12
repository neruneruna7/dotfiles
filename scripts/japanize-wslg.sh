#!/bin/bash
# Copyright (c) 2021 astherier
# This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php
#
#japanize-wslg.sh
#WSL2/WSLgを日本語環境にし、Fcitx＋Mozcをインストールします
#最終更新：2021/07/11
#https://astherier.com/blog/2021/07/windows11-wsl2-wslg-japanese/

#Ubuntuの各アプリをアップデート
sudo apt update
sudo apt upgrade -y

#Ubuntu側から、Windows側にあるフォントを扱えるようにする
cat << 'EOS' | sudo tee /etc/fonts/local.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <dir>/mnt/c/Windows/Fonts</dir>
</fontconfig>
<!-- Created by bash script from https://astherier.com/blog/2021/07/windows11-wsl2-wslg-japanese/ -->
EOS

#日本語パックを入れて、ロケールをja_jpにする
#これ以降、コマンドラインのエラー表示なども日本語になります。
sudo apt -y install language-pack-ja
sudo update-locale LANG=ja_JP.UTF8

#FcitxとMozcをインストールし、関連の設定をします。
sudo apt install -y fcitx-mozc dbus-x11
sudo sh -c "dbus-uuidgen > /var/lib/dbus/machine-id"
cat << 'EOS' | tee -a ~/.profile
#Added by bash script from https://astherier.com/blog/2021/07/windows11-wsl2-wslg-japanese/
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIMModule=fcitx
if [ $SHLVL = 1 ] ; then
  (fcitx-autostart > /dev/null 2>&1 &)
  xset -r 49  > /dev/null 2>&1
fi
#Added by bash script: end
EOS

echo "
一旦、WSL2を終了してください。コマンド：wsl.exe -t ディストリ名
もう一度WSL2を起動して、fcitx-config-gtk3で設定の確認をしてください。
  ・Input Method（入力メソッド）にMozcを足す
  ・Global Config（全体の設定）のTrigger Input MethodにZenkakuhankakuもセットする
"
