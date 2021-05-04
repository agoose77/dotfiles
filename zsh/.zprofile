for file in "${HOME}/.zprofile.d/"*; do
    source "${file}"
done
