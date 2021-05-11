echo "~profile"
for file in "${HOME}/.profile.d/"*; do
    source "${file}"
done
