export PIPX_HOME="$HOME/.pipx"
export PIPX_BIN_DIR="$PIPX_HOME/bin"
export PATH="$PIPX_BIN_DIR:$PATH"

if [[ ! -d "$PIPX_HOME" ]]; then
    mkdir --parents "$PIPX_HOME" "$PIPX_BIN_DIR"
fi
