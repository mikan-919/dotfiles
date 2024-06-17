cd `dirname $0`

function config_link(){
rm -rf ~/$1
ln -s $(realpath ../config/$1) $(realpath ~/$1)
}

config_link .zshrc
config_link .gitconfig
config_link .gitmessage
config_link .config/starship.toml
config_link .config/sheldon/plugins.toml