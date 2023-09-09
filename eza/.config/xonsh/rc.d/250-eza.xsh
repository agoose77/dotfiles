# general use
aliases['ls']='exa'                                                         # ls
aliases['l']='exa -lbF --git'                                               # list, size, type, git
aliases['ll']='exa -lbGF --git'                                             # long list
aliases['llm']='exa -lbGF --git --sort=modified'                            # long list, modified date sort
aliases['la']='exa -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
aliases['lx']='exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list

# speciality views
aliases['lS']='exa -1'			                                                  # one column, just names
aliases['lt']='exa --tree --level=2'                                         # tree
