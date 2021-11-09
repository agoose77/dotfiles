# `tkdir /tmp/test` -> mkdir /tmp/test && cd /tmp/test
aliases['tkdir'] = "mkdir -p $arg0 && cd $arg0"        

# Allow cd with ...
xontrib load zsh_cd_dot   
