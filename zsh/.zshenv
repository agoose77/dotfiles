# add code to source all script files in .zshenv.d
 for file in "${HOME}/.zshenv.d/"*; do
   source "${file}"
 done
