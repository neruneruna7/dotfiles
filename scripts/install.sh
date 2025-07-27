#!/usr/bin/env bash
# スクリプトがエラーに遭遇したときに終了し、未定義の変数があるとエラーを出力します。
set -ue

# ヘルプメッセージを表示する関数
helpmsg() {
  command echo "Usage: $0 [--help | -h]" 0>&2
  command echo ""
}

# ホームディレクトリにドットファイルをリンクする関数
link_to_homedir() {
  command echo "backup old dotfiles..."

  # バックアップディレクトリが存在しない場合、作成します。
  if [ ! -d "$HOME/.dotbackup" ];then
    command echo "$HOME/.dotbackup not found. Auto Make it"
    command mkdir "$HOME/.dotbackup"
  fi

  # スクリプトのディレクトリを取得します。
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

  # ドットファイルのディレクトリを取得します。
  local dotdir=$(dirname ${script_dir})

  # ホームディレクトリとドットファイルのディレクトリが異なる場合、リンクを作成します。
  if [[ "$HOME" != "$dotdir" ]];then
    for f in $dotdir/.??*; do
      # .gitは除外します。
      [[ `basename $f` == ".git" ]] && continue
      # .DS_Storeは除外します。
      [[ `basename $f` == ".DS_Store" ]] && continue
      # .githubは除外します。
      [[ `basename $f` == ".github" ]] && continue
      # 既存のリンクがある場合、削除します。
      if [[ -L "$HOME/`basename $f`" ]];then
        command rm -f "$HOME/`basename $f`"
      fi
      # 既存のファイルがある場合、バックアップします。
      if [[ -e "$HOME/`basename $f`" ]];then
        command mv "$HOME/`basename $f`" "$HOME/.dotbackup"
      fi
      # 新しいリンクを作成します。
      command ln -snf $f $HOME
    done
  else
    command echo "same install src dest"
  fi
}

 # コマンドライン引数を解析します。
while [ $# -gt 0 ];do
  case ${1} in
    --debug|-d)
      # デバッグモードを有効にします。
      set -uex
      ;;
    --help|-h)
      # ヘルプメッセージを表示します。 
      helpmsg
      exit 1
      ;;
    *)
      ;;
  esac
  shift
done

# ドットファイルのリンクを作成します。
link_to_homedir
git config --global include.path "~/.gitconfig_shared"
command echo -e "\e[1;36m Install completed!!!! \e[m"
