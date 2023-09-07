def _make_scratch(args):
    import re

    assert len(args) < 2
    suffix = args[0] if args else None

    scratch_path_str = ${...}.get("SCRATCH_PATH", f"$XDG_DATA_HOME/scratches")
    scratch_path = pf"{scratch_path_str}"
    scratch_path.mkdir(exist_ok=True)

    paths = scratch_path.glob("scratch-*.md")
    indices = (m[1] for m in (re.match(r"scratch-(\d+).*", p.name) for p in paths) if m)
    index = max(indices, key=int, default=0)

    if suffix:
        name = f"scratch-{index+1}.{suffix}"
    else:
        name = f"scratch-{index+1}"

    $EDITOR @(scratch_path / name)

aliases['scratch'] = _make_scratch
