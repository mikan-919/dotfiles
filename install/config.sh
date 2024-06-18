cd $(dirname $0)
# ファイルを作成する関数
makedir() {
  local file_path="$1"

  # ディレクトリ部分を取得
  local directory
  directory=$(dirname "$file_path")

  # ディレクトリが存在するか確認し、存在しない場合は作成
  if [ ! -d "$directory" ]; then
    mkdir -p "$directory"
    echo "Create '$directory' dir "
  fi
}

function config_link() {
  TARGET=$(realpath ~/$1)
  rm -rf $TARGET
  makedir $TARGET
  ln -s $(realpath ../config/$1) $TARGET
}

config_link .zshrc
config_link .gitconfig
config_link .gitmessage
config_link .config/starship.toml
config_link .config/sheldon/plugins.toml
