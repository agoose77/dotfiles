# dotfiles
This repo contains my dotfiles (tada)!

To install the dotfiles, clone this repo and cd
```bash
git clone git@github.com:agoose77/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```
Then simply run the stow command
```bash
./setup.py stow
```
or alternatively, run the equivalent bash command
```python
find * -type d -maxdepth 0  -exec stow {} \;
```

The setup script should be idempotent for the same configuration:
```bash
./setup.py install
```

Optionally provide the "batch" argument to load configuration options up front, e.g.
```bash
./setup.py install -b
```
