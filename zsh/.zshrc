# Source .zshrc.d
for file in "${HOME}/.zshrc.d/"*; do
    source "${file}"
done
