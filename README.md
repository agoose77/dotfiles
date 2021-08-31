# dotfiles
This repo contains my dotfiles (tada)! A new system installation is performed in four steps:

## Structure
There are two `config.d`-like directories used, so that different configurations can be loaded without merging:
- `.profile.d`
- `.zshrc.d`

The `.zprofile` file only sources `.profile`. This is because in an ideal world we'd only have `.zprofile`, but GDM only sources `.profile` explicitly:

[![Diagram of Bash startup sequence](https://www.solipsys.co.uk/images/BashStartupFiles1.png)](http://www.solipsys.co.uk/new/BashInitialisationFiles.html)

So, to ensure that the *system* has access to useful paths, we define `.profile`.

## GPG
1. Install gnupg with `sudo apt install gnupg`
1. Load subkeys into GPG
1. Extract keygrip for signing key with `gpg -K --with-keygrip`
1. Add keygrip to `~/.gnupg/sshcontrol`
1. Copy SSH key for GitHub from `ssh-add -L`

## Setup
To install the dotfiles, clone this repo and `cd`
```bash
sudo apt install git git-lfs && git lfs install
git clone --recurse-submodules git@github.com:agoose77/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```
Then simply run the `stow` command
```python
find * -type d -maxdepth 0  -exec stow --no-folding {} \;
```
