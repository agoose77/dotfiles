xontrib load powerline2

# If we are connected over SSH 
def _ssh(sample=False):
    if "SSH_CLIENT" in ${...}:
        name, _, _ = ${...}.get("HOSTNAME", "").partition(".")
        return [f"  {name}", "BLACK", "PURPLE"]
$PL_EXTRA_SEC['ssh'] = _ssh

$PL_TOOLBAR="ssh>cwd>branch>virtualenv>full_proc"
$PL_COLORS['short_cwd'] = ("#333", "BLUE")     
$PL_COLORS['cwd'] = ("#333", "BLUE")     

pl_build_prompt
