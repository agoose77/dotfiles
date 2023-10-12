# general use
aliases['ls']='eza'                                                         # ls
aliases['l']='eza -lbF --git'                                               # list, size, type, git
aliases['ll']='eza -lbGF --git'                                             # long list
aliases['llm']='eza -lbGF --git --sort=modified'                            # long list, modified date sort
aliases['la']='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
aliases['lx']='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list

# speciality views
aliases['lS']='eza -1'			                                                  # one column, just names
aliases['lt']='eza --tree --level=2'                                         # tree
