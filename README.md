# dotfiles
This repo contains my dotfiles (tada)! A new system installation is performed in four steps:

## GPG
1. Install gnupg with `sudo apt install gnupg`
1. Load subkeys into GPG
1. Extract keygrip for signing key with `gpg -K --with-keygrip`
1. Add keygrip to `~/.gnupg/sshcontrol`
1. Copy SSH key for GitHub from `ssh-add -L`

## Setup
## TLDR
```bash
sudo apt install git git-lfs && git lfs install
git clone --recurse-submodules git@github.com:agoose77/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.py stow
./setup.py install
```

### Clone  
To install the dotfiles, clone this repo and cd
```bash
sudo apt install git git-lfs && git lfs install
git clone --recurse-submodules git@github.com:agoose77/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```
Then simply run the stow command
```bash
./setup.py stow
```
or alternatively, run the equivalent bash command
```python
find * -type d -maxdepth 0  -exec stow --no-folding {} \;
```
### Install  
The setup script should be idempotent for the same configuration:
```bash
./setup.py install
```
Optionally provide the "batch" argument to load configuration options up front, e.g.
```bash
./setup.py install -b
```
