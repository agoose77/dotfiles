@events.on_pre_spec_run_ssh
def on_ssh(spec, **kwargs):
    spec.env = spec.env or {}
    spec.env['SHELL'] = "/bin/sh"