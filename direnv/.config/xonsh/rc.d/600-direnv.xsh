xontrib load direnv


def _tmpy():
    pushd $(mktemp -d)
    echo "layout python3" > .envrc
    direnv allow .

aliases['tmpy'] = _tmpy
