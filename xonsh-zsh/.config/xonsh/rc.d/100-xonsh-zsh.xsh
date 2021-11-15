# `tkdir /tmp/test` -> mkdir /tmp/test && cd /tmp/test
aliases['tkdir'] = "mkdir -p $arg0 && cd $arg0"        

# Automatically CD when entering directory name
$AUTO_CD = True

# Allow cd with ...
xontrib load zsh_cd_dot   

# Make $() strip trailing newlines
if not "_subproc_captured_stdout" in globals():
    _subproc_captured_stdout = __xonsh__.subproc_captured_stdout
    def __subproc_captured_stdout(*cmds, envs=None):
        result = _subproc_captured_stdout(*cmds, envs=envs)
        return result.rstrip("\n")
    __xonsh__.subproc_captured_stdout = __subproc_captured_stdout
