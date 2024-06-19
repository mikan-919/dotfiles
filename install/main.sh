cd $(dirname $0)

scripts= $(find . -type f -not -name "main.sh" | sk -m)

for script in $scripts; do
  if [ -f "$script" ]; then
    . $script
    echo "Sourced: $script"
  else
    echo "File not found: $script"
  fi
done

exit
