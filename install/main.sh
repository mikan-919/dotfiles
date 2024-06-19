cd $(dirname $0)

scripts= $(find . -type f -not -name "main.sh")

for script in $scripts; do
  if [ -f "$script" ]; then
    . $script
    echo "Sourced: $script"
  fi
done

exit
