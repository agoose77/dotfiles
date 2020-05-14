# dotfiles
This repo contains my dotfiles (tada)! A new system installation is performed in three steps:

## TLDR
```bash
git clone --recurse-submodules https://github.com/agoose77/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.py stow
```

## Steps

### Clone  
To install the dotfiles, clone this repo and cd
```bash
git clone --recurse-submodules git@github.com:agoose77/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.py stow
./setup.py install -b
git lfs pull
```
Then simply run the stow command
```bash
./setup.py stow
```
or alternatively, run the equivalent bash command
```python
find * -type d -maxdepth 0  -exec stow {} \;
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
### Git LFS  
```bash
git lfs pull
```

## GPG
1. Load subkeys into GPG
2. Extract keygrip for signing key with `gpg -K --with-keygrip`
3. Add keygrip to `~/.gnupg/sshcontrol`
4. Copy SSH key for GitHub from `ssh-add -L`
