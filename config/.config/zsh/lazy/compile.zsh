for file in ~/.zshenv ~/.config/zsh/.zprofile ~/.config/zsh/.zshrc ~/.config/zsh/**/*.zsh ~/.local/share/sheldon/**/*.zsh
do
  echo "zcompile $file"
  zcompile "$file"
done