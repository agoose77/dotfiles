import itertools as _itertools


def _git_main_branch(cmd):
    if not !(git rev-parse --git-dir):
        return 

    branch_names = "master", "main", "trunk"
    inner_refs = "heads", "remotes/origin", "remotes/upstream"
    
    for inner_ref, branch in _itertools.product(inner_refs, branch_names):
        if !(git show-ref -q --verify @(f"refs/{inner_ref}/{branch}")):
            return branch
            
    return "master-fail"


aliases['git_main_branch'] = _git_main_branch


def _git_develop_branch(cmd):
    if not !(git rev-parse --git-dir):
        return

    for branch in "dev", "devel", "development":
        if !(git show-ref -q --verify @(f"refs/heads/{branch}")):
            return branch
            
    return "develop"


aliases['git_develop_branch'] = _git_develop_branch


def _git_current_branch(cmd):
    result = !(git symbolic-ref --quiet HEAD)
    if result.returncode != 0:
        # No repo
        if result.returncode == 128:
            return
        # Try git rev-parse
        result = !(git rev-parse --short HEAD)
        if not result:
            return
    return result.out.removeprefix("refs/heads/")


aliases['git_current_branch'] = _git_current_branch

_git_abbrevs = ({
    "g": "git",
    "ga": "git add",
    "gaa": "git add --all",
    "gam": "git am",
    "gama": "git am --abort",
    "gamc": "git am --continue",
    "gams": "git am --skip",
    "gamscp": "git am --show-current-patch",
    "gap": "git apply",
    "gapa": "git add --patch",
    "gapt": "git apply --3way",
    "gau": "git add --update",
    "gav": "git add --verbose",
    "gb": "git branch",
    "gbD": "git branch -D",
    "gba": "git branch -a",
    "gbd": "git branch -d",
    "gbda": 'git branch --no-color --merged | command grep -vE "^(\\+|\\*|\\s*($(git_main_branch)|development|develop|devel|dev)\\s*$)" | command xargs -n 1 git branch -d',
    "gbl": "git blame -b -w",
    "gbnm": "git branch --no-merged",
    "gbr": "git branch --remote",
    "gbs": "git bisect",
    "gbsb": "git bisect bad",
    "gbsg": "git bisect good",
    "gbsr": "git bisect reset",
    "gbss": "git bisect start",
    "gc": "git commit -v",
    "gc!": "git commit -v --amend",
    "gca": "git commit -v -a",
    "gca!": "git commit -v -a --amend",
    "gcam": "git commit -a -m",
    "gcan!": "git commit -v -a --no-edit --amend",
    "gcans!": "git commit -v -a -s --no-edit --amend",
    "gcas": "git commit -a -s",
    "gcasm": "git commit -a -s -m",
    "gcb": "git checkout -b",
    "gcd": "git checkout $(git config gitflow.branch.develop)",
    "gcf": "git config --list",
    "gch": "git checkout $(git config gitflow.prefix.hotfix)",
    "gcl": "git clone --recurse-submodules",
    "gclean": "git clean -id",
    "gcm": "git checkout $(git_main_branch)",
    "gcmsg": "git commit -m",
    "gcn!": "git commit -v --no-edit --amend",
    "gco": "git checkout",
    "gcor": "git checkout --recurse-submodules",
    "gcount": "git shortlog -sn",
    "gcp": "git cherry-pick",
    "gcpa": "git cherry-pick --abort",
    "gcpc": "git cherry-pick --continue",
    "gcr": "git checkout $(git config gitflow.prefix.release)",
    "gcs": "git commit -S",
    "gcsm": "git commit -s -m",
    "gcss": "git commit -S -s",
    "gcssm": "git commit -S -s -m",
    "gd": "git diff",
    "gdca": "git diff --cached",
    "gdct": "git describe --tags $(git rev-list --tags --max-count=1)",
    "gdcw": "git diff --cached --word-diff",
    "gds": "git diff --staged",
    "gdt": "git diff-tree --no-commit-id --name-only -r",
    "gdw": "git diff --word-diff",
    "gf": "git fetch",
    "gfa": "git fetch --all --prune --jobs=10",
    "gfg": "git ls-files | grep",
    "gfl": "git flow",
    "gflf": "git flow feature",
    "gflff": "git flow feature finish",
    "gflfp": "git flow feature publish",
    "gflfpll": "git flow feature pull",
    "gflfs": "git flow feature start",
    "gflh": "git flow hotfix",
    "gflhf": "git flow hotfix finish",
    "gflhp": "git flow hotfix publish",
    "gflhs": "git flow hotfix start",
    "gfli": "git flow init",
    "gflr": "git flow release",
    "gflrf": "git flow release finish",
    "gflrp": "git flow release publish",
    "gflrs": "git flow release start",
    "gfo": "git fetch origin",
    "gg": "git gui citool",
    "gga": "git gui citool --amend",
    "ggpull": 'git pull origin "$(git_current_branch)"',
    "ggpush": 'git push origin "$(git_current_branch)"',
    "ggsup": "git branch --set-upstream-to=origin/$(git_current_branch)",
    "ghh": "git help",
    "gignore": "git update-index --assume-unchanged",
    "gignored": 'git ls-files -v | grep "^[[:lower:]]"',
    "git-svn-dcommit-push": "git svn dcommit && git push github $(git_main_branch):svntrunk",
    "gk": "gitk --all --branches",
    "gke": "gitk --all $(git log -g --pretty=%h)",
    "gl": "git pull",
    "glg": "git log --stat",
    "glgg": "git log --graph",
    "glgga": "git log --graph --decorate --all",
    "glgm": "git log --graph --max-count=10",
    "glgp": "git log --stat -p",
    "glo": "git log --oneline --decorate",
    "glod": "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'",
    "glods": "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short",
    "glog": "git log --oneline --decorate --graph",
    "gloga": "git log --oneline --decorate --graph --all",
    "glol": "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'",
    "glola": "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --all",
    "glols": "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --stat",
    "glum": "git pull upstream $(git_main_branch)",
    "gm": "git merge",
    "gma": "git merge --abort",
    "gmom": "git merge origin/$(git_main_branch)",
    "gmt": "git mergetool --no-prompt",
    "gmtvim": "git mergetool --no-prompt --tool=vimdiff",
    "gmum": "git merge upstream/$(git_main_branch)",
    "gp": "git push",
    "gpd": "git push --dry-run",
    "gpf": "git push --force-with-lease",
    "gpf!": "git push --force",
    "gpoat": "git push origin --all && git push origin --tags",
    "gpr": "git pull --rebase",
    "gpristine": "git reset --hard && git clean -dffx",
    "gpsup": "git push --set-upstream origin $(git_current_branch)",
    "gpu": "git push upstream",
    "gpv": "git push -v",
    "gr": "git remote",
    "gra": "git remote add",
    "grb": "git rebase",
    "grba": "git rebase --abort",
    "grbc": "git rebase --continue",
    "grbd": "git rebase develop",
    "grbi": "git rebase -i",
    "grbm": "git rebase $(git_main_branch)",
    "grbo": "git rebase --onto",
    "grbs": "git rebase --skip",
    "grev": "git revert",
    "grh": "git reset",
    "grhh": "git reset --hard",
    "grm": "git rm",
    "grmc": "git rm --cached",
    "grmv": "git remote rename",
    "groh": "git reset origin/$(git_current_branch) --hard",
    "grrm": "git remote remove",
    "grs": "git restore",
    "grset": "git remote set-url",
    "grss": "git restore --source",
    "grst": "git restore --staged",
    "grt": 'cd "$(git rev-parse --show-toplevel || echo .)"',
    "gru": "git reset --",
    "grup": "git remote update",
    "grv": "git remote -v",
    "gsb": "git status -sb",
    "gsd": "git svn dcommit",
    "gsh": "git show",
    "gsi": "git submodule init",
    "gsps": "git show --pretty=short --show-signature",
    "gsr": "git svn rebase",
    "gss": "git status -s",
    "gst": "git status",
    "gsta": "git stash push",
    "gstaa": "git stash apply",
    "gstall": "git stash --all",
    "gstc": "git stash clear",
    "gstd": "git stash drop",
    "gstl": "git stash list",
    "gstp": "git stash pop",
    "gsts": "git stash show --text",
    "gsu": "git submodule update",
    "gsw": "git switch",
    "gswc": "git switch -c",
    "gtl": 'gtl(){ git tag --sort=-v:refname -n -l "${1}*" }; noglob gtl',
    "gts": "git tag -s",
    "gtv": "git tag | sort -V",
    "gunignore": "git update-index --no-assume-unchanged",
    "gunwip": 'git log -n 1 | grep -q -c "\\-\\-wip\\-\\-" && git reset HEAD~1',
    "gup": "git pull --rebase",
    "gupa": "git pull --rebase --autostash",
    "gupav": "git pull --rebase --autostash -v",
    "gupv": "git pull --rebase -v",
    "gwch": "git whatchanged -p --abbrev-commit --pretty=medium",
    "gwip": 'git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"',
    "todo": 'git grep -EI "TODO|FIXME"',
    "gfi": "$EDITOR @$(git diff --name-only | uniq)"
})
abbrevs.update(_git_abbrevs)
aliases.update({
    "egrep": "egrep --color=auto --exclude-dir=.git --exclude-dir=.idea",
    "fgrep": "fgrep --color=auto --exclude-dir=.git --exclude-dir=.idea",
    "grep": "grep --color=auto --exclude-dir=.git --exclude-dir=.idea",
})
