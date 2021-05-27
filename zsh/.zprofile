# zprofile should be called on login, but when running under gdm
# it is not as it is  hard-coded to call .profile
# this is sourced for SSH!
. $HOME/.profile
