# SSH should use /bin/sh for safety

@events.on_pre_spec_run_ssh
def _on_ssh(spec, **kwargs):
    spec.env = spec.env or {}
    spec.env['SHELL'] = "/bin/sh"
