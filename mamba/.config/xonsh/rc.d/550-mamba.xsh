import sys as _sys
import os as _os
import shutil as _shutil

from xonsh.built_ins import XSH as _XSH
import xonsh.prompt.env as _prompt_env
from types import ModuleType as _ModuleType

_mamba_path = _shutil.which("mamba")
_mod = _ModuleType("xontrib.mamba",
                   "Autogenerated.")
__xonsh__.execer.exec($(@(_mamba_path) "init" "shell.xonsh" "hook"),
                      glbs=_mod.__dict__,
                      filename="$(@(_mamba_path) shell.xonsh hook)")
_sys.modules["xontrib.mamba"] = _mod
del _sys, _mod, _ModuleType
