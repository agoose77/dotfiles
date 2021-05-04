#!/usr/bin/env zsh
# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-

# Copyright (c) 2021 Angus Hollands

# Rename i3 workspace
rename-workspace () {
	num=$(i3-msg -t get_workspaces | jq ".[] | select(.focused).num")
	name="$(xrescat i3-wm.workspace.${num}.name || xrescat i3-wm.workspace.0${num}.name) $1"
	i3-msg "rename workspace to \"$name\"" >/dev/null
}
alias rnw='rename-workspace'
