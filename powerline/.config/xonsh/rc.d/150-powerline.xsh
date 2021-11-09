xontrib load powerline2

# If we are connected over SSH 
$PL_EXTRA_SEC['ssh'] = lambda sample=False: ["  ", "BLACK", "PURPLE"] if "SSH_CLIENT" in ${...} else None

$PL_TOOLBAR="ssh>cwd>branch>virtualenv>full_proc"
$PL_COLORS['short_cwd'] = ("#333", "BLUE")     
$PL_COLORS['cwd'] = ("#333", "BLUE")     

pl_build_prompt
