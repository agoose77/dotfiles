def _rename_workspace(args):
    import json
    name, = args
    workspaces = json.loads($(i3-msg -t get_workspaces))
    num = next(w['num'] for w in workspaces if w['focused'])
    head = $(xrescat i3-wm.workspace.@(num).name) or $(xrescat i3-wm.workspace.0@(num).name)
    new_name = f"{head} {name}".replace('"', "'")
    i3-msg @(f'rename workspace to "{new_name}"')

aliases['rename-workspace'] = _rename_workspace
aliases['rnw'] = _rename_workspace
