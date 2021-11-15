# Reflect environ changes in os.environ
$UPDATE_OS_ENVIRON = True

if $XONSH_LOGIN and "HAS_PROFILE" not in ${...}:
    source-bash $HOME/.profile
