# zprofile should be called on login, but this only occurs for SSH logins
# when running under gdm (which hard-coded to .profile)
. $HOME/.profile
