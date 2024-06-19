cd $(dirname $0)

function config_link() {
  TARGET=~/$1                   #リンクするファイル
  TARGET_DIR=$(dirname $TARGET) #リンクするファイルのあるディレクトリ
  FROM=$(realpath ../config/$1) #リンク元のファイル

  rm -rf $TARGET
  mkdir -p $TARGET_DIR
  ln -s $FROM $TARGET
}

config_link .zshrc
config_link .gitconfig
config_link .gitmessage
config_link .config/starship.toml
config_link .config/sheldon/plugins.toml
