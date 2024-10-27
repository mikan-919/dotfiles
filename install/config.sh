#!/bin/zsh
PATH_DIR_PARENT="$(dirname "$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)")"
cd $PATH_DIR_PARENT

# $HOME/.configディレクトリが存在しない場合は作成
if [[ ! -d "$HOME/.config" ]]; then
    echo "$HOME/.configディレクトリを作成します。"
    mkdir -p "$HOME/.config"
fi

CONFIG_DIR="$PATH_DIR_PARENT/config"
if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "Error: $CONFIG_DIRディレクトリが見つかりません。"
    exit 1
fi
# バックアップディレクトリを作成
backup_dir="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

pattern="$CONFIG_DIR/**/*"
setopt globdots
# 対象フォルダ内のすべてのファイルやフォルダを再帰的に処理
for file in $~pattern; do
    if [[ -f "$file" ]]; then
        relative_path=$(realpath --relative-to=$CONFIG_DIR $file)
        target_path="$HOME/$relative_path"
        # echo $target_path
        if [ -f $target_path ]; then
            rm -rf $target_path
        fi
        echo "[Link] $target_path"
        ln -s $file $target_path
        elif [[ -d "$file" ]]; then
        relative_path=$(realpath --relative-to=$CONFIG_DIR $file)
        target_path="$HOME/$relative_path"
        if [ ! -d $target_path ]; then
            echo "[Create] $target_path"
            mkdir -p $target_path
        fi
    fi
done
