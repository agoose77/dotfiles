# dotfiles
This repo contains my dotfiles (tada)!

To install the dotfiles, 
```bash
git clone git@github.com:agoose77/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
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
