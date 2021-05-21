export PIPX_BIN_DIR="$HOME/.pipx-bin"
export PATH="$PIPX_BIN_DIR:$PATH"

if [[ ! -d "$PIPX_BIN_DIR" ]]; then
    mkdir --parents "$PIPX_BIN_DIR"
fi
