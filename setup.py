#!/usr/bin/python3
import argparse
import code
import json
import logging
import inspect
import os
import re
import sys
import shlex
import tempfile
import pexpect
from contextlib import contextmanager
from functools import wraps
from pathlib import Path
from subprocess import check_output
from typing import NamedTuple, List, Dict, Any, Union


#  Bootstrap ###########################################################################################################
check_output(["sudo", "apt", "install", "-y", "python3-pip", "stow"], shell=False)
check_output([sys.executable, "-m", "pip", "install", "plumbum"], shell=False)

import site
sys.path.append(site.getusersitepackages())

# Import modules
import plumbum
from plumbum import cmd, local
import plumbum.colors
########################################################################################################################


logger = logging.getLogger(__name__)
logger.setLevel(os.environ.get("LOGLEVEL", "INFO"))

ch = logging.StreamHandler()
ch.setLevel(logging.INFO)

formatter = logging.Formatter("{prefix}{message}", style="{")
ch.setFormatter(formatter)

logger.addHandler(ch)

HOME_PATH = Path.home()
THIS_DIR = Path(__file__).parent
ZSHRC_PATH = HOME_PATH / ".zshrc"
ZPROFILE_PATH = HOME_PATH / ".zprofile"
ZSHENV_PATH = HOME_PATH / ".zshenv"
GPG_HOME_PATH = HOME_PATH / ".gnupg"
GEANT4_CPACK_PATCH_URL = (
    "https://gist.github.com/agoose77/fba2fc5504933b7fb2c5b8c3cfd93529/raw"
)
TMUX_CONF_URL = (
    "https://gist.githubusercontent.com/agoose77/3e3b273cbfdb8a870c97ebb346beef8e/raw"
)
EXPORT_OS_ENVIRON_SOURCE = f"""
import os, json, sys
with open(sys.argv[1], 'w') as f:
    json.dump(dict(os.environ), f)
"""


class GitTag(NamedTuple):
    name: str
    tarball_url: str


class SysconfigData(NamedTuple):
    paths: List[str]
    config_vars: Dict[str, str]
    executable: str


_depth = 0


# Logging and utilities ################################################################################################
@contextmanager
def install_context():
    global _depth
    _depth += 1
    yield
    _depth -= 1


def prefix():
    return "   " * _depth


def log(message, level=logging.INFO):
    try:
        colors = plumbum.colors
    except NameError:
        pass
    else:
        log_level_to_colour = {
            logging.DEBUG: colors.fg,
            logging.INFO: colors.info,
            logging.WARN: colors.warn,
            logging.ERROR: colors.fatal,
            logging.CRITICAL: colors.fatal & colors.bold,
        }
        message = log_level_to_colour[level] | message
    logger.log(level, message, extra={"prefix": prefix()})


def is_installed(executable_or_test, bound_arguments):
    from plumbum.commands import BaseCommand
    if isinstance(executable_or_test, str):
        return executable_or_test in local

    if isinstance(executable_or_test, BaseCommand):
        return executable_or_test & plumbum.TF

    if callable(executable_or_test):
        return executable_or_test(bound_arguments)

    raise ValueError


def installs(executable_or_test: Any = None):
    def decorator(func):
        signature = inspect.signature(func)

        @wraps(func)
        def installer(*args, **kwargs):
            bound_arguments = signature.bind(*args, **kwargs)
            bound_arguments.apply_defaults()

            log(f"Running {func.__qualname__} with {bound_arguments}")

            if executable_or_test and is_installed(executable_or_test, bound_arguments.arguments):
                log(f"{func.__qualname__} is already installed!")
                return

            with install_context():
                try:
                    func(*args, **kwargs)
                except Exception:
                    log(f"Execution of {func.__qualname__} with {bound_arguments} failed", level=logging.ERROR)
                    raise

            log(f"Finished running {func.__qualname__} with {bound_arguments}")

        return installer

    return decorator


@contextmanager
def detect_changed_files(directory):
    path = Path(directory).expanduser()
    before_files = set(path.iterdir())
    changed_files = set()
    yield changed_files
    changed_files |= set(path.iterdir()) - before_files


def reload_plumbum_env() -> Dict[str, Any]:
    """Reloads `local.env` after re-sourcing .zshrc"""
    fd, temp_path = tempfile.mkstemp()

    with local.env(ZINIT_WAIT=""):
        (
            cmd.zsh["-s"]
            << f"{sys.executable} -c {shlex.quote(EXPORT_OS_ENVIRON_SOURCE)} {temp_path}"
        )()

    with open(fd) as f:
        env = json.load(f)
    local.env.update(**env)
    return env


def modifies_environment(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        result = f(*args, **kwargs)
        reload_plumbum_env()
        return result

    return wrapper

#  Installers ##########################################################################################################
@installs()
def install_with_pip(*packages):
    return check_output([sys.executable, "-m", "pip", "install", *packages])


@installs()
def install_with_apt(*packages):
    return (cmd.sudo[cmd.apt[("install", "-y", *packages)]] << "\n")()


@installs()
def install_with_snap(
    *packages: str, classic: bool = False, beta: bool = False, edge: bool = False
):
    """Install package on the snap platform.

    :param packages: tuple of package names
    :param classic: whether package is considered unsafe
    :return:
    """
    if classic:
        packages += ("--classic",)
    if beta:
        packages += ("--beta",)
    if edge:
        packages += ("--edge",)

    (cmd.sudo[cmd.snap[("install", *packages)]] << "\n")()


class TokenInvalidError(ValueError):
    pass


def graphql_errors_to_string(errors):
    messages = []
    for error in errors:
        locations = [
            f'(line {p["line"]}, column {p["column"]})' for p in error["locations"]
        ]
        messages.append(f'{error["message"]} on {", ".join(locations)}')
    return "\n".join(messages)


def execute_github_graphql_query(token: str, query: str) -> dict:
    import urllib.request as request
    import urllib.error as error

    req = request.Request(
        "https://api.github.com/graphql",
        method="POST",
        data=json.dumps({"query": query}).encode(),
        headers={"Authorization": f"token {token}"},
    )

    try:
        resp = request.urlopen(req)
    except error.HTTPError as err:
        if err.code == 401:
            raise TokenInvalidError(f"Token {token!r} was invalid!") from err
        raise

    result = json.loads(resp.read())
    if "errors" in result:
        raise ValueError(graphql_errors_to_string(result["errors"]))
    return result


def validate_github_token(token: str) -> str:
    """
    Test GitHub token to ensure it is valid.

    :param token: GitHub personal access token
    :return: GitHub personal access token
    """
    test_query = """
    {
          repository(owner:"root-project", name: "root") {
            name
          }
    }
    """
    execute_github_graphql_query(token, test_query)
    return token


def find_latest_github_tag(token: str, owner: str, name: str) -> GitTag:
    """
    Find latest Tag object from GitHub repo using GraphQL

    :param token: GitHub personal authentication token
    :param owner: Repository owner
    :param name: Repository name
    :return:
    """
    from string import Template

    query_template = """
{
    repository(owner:"$owner", name: "$name") {
        refs(refPrefix: "refs/tags/", first: 1, orderBy: {field: ALPHABETICAL, direction: DESC}) {
          edges {
            node {
              name
              target {
                __typename
                ... on Tag {
                  name
                  target {
                    ... on Commit {
                      tarballUrl
                    }
                  }
                }
                ... on Commit {
                  tarballUrl
                }
              }
            }
          }
        }
    }
}
    """
    query = Template(query_template).substitute(owner=owner, name=name)
    result = execute_github_graphql_query(token, query)

    (edge,) = result["data"]["repository"]["refs"]["edges"]
    obj = edge["node"]
    tag = obj["name"]

    while "target" in obj:
        obj = obj["target"]
    url = obj["tarballUrl"]
    return GitTag(name=tag, tarball_url=url)


@modifies_environment
def append_to_zshrc(*scripts: str):
    ZSHRC_PATH.touch()
    zshrc_contents = ZSHRC_PATH.read_text()
    if not zshrc_contents.endswith("\n"):
        zshrc_contents += "\n"
    zshrc_contents += "\n".join(scripts)
    ZSHRC_PATH.write_text(zshrc_contents)


@modifies_environment
def prepend_to_zshrc(*scripts: str):
    zshrc_contents = "\n".join(scripts)
    if not zshrc_contents.endswith("\n"):
        zshrc_contents += "\n"
    ZSHRC_PATH.write_text(zshrc_contents + ZSHRC_PATH.read_text())


@installs('zsh')
def install_zsh():
    install_with_apt("zsh")
    cmd.sudo[cmd.chsh["-s", local.which("zsh"), os.environ["USER"]]]()


@installs('tmux')
def install_tmux():
    install_with_apt("tmux")


@installs('google-chrome')
def install_chrome():
    deb_name = "google-chrome-stable_current_amd64.deb"
    with local.cwd("/tmp"):
        cmd.wget(f"https://dl.google.com/linux/direct/{deb_name}")
        cmd.sudo[cmd.dpkg["-i", deb_name]]()


@installs('gnome-tweaks')
def install_gnome_tweak_tool():
    (cmd.sudo[cmd.apt["install", "gnome-tweak-tool"]] << "\n")()


@installs('pandoc')
def install_pandoc(github_token: str):
    query = """
{
  repository(owner: "jgm", name: "pandoc") {
    releases(first: 1, orderBy: {field: CREATED_AT, direction: DESC}) {
      nodes {
        name
        releaseAssets(first: 10) {
          nodes{
            name
            contentType
            downloadUrl
          }
        }
      }
    }
  }
}
  """
    result = execute_github_graphql_query(github_token, query)
    (release,) = result["data"]["repository"]["releases"]["nodes"]

    node = next(
        n
        for n in release["releaseAssets"]["nodes"]
        if n["name"].endswith(".deb")
    )
    deb_url = node['downloadUrl']
    
    log(f"Found {release['name']}, downloading deb from {deb_url}")

    with local.cwd("/tmp"):
        cmd.aria2c(deb_url, "-j", "10", "-x", "10")
        install_with_apt(local.path(node['name']))


@installs('latex')
def install_tex():
    with local.cwd("/tmp"):
        cmd.wget("mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz")
        cmd.tar("-xvf", "install-tl-unx.tar.gz")

        directory = next((p for p in (local.cwd // "install-tl*") if p.is_dir()))

        path_component = None
        pattern = re.compile(r"Most importantly, add (.*)")

        with local.cwd(directory):
            proc = (cmd.sudo[local[local.cwd / "install-tl"]] << "I\n").popen()
            for out, err in proc:
                if err:
                    log(err, logging.ERROR)
                if out:
                    log(out, logging.INFO)
                    match = pattern.match(out)
                    if match:
                        path_component = match.group(1)

    texlive_env_path = next((HOME_PATH / ".zshenv.d").glob("*-texlive"))
    if path_component is not None:
        texlive_env_path.write_text(texlive_env_path.read_text() + """
export PATH="/usr/local/texlive/2020/bin/x86_64-linux:$PATH"
        """)


def get_system_python_version() -> str:
    from sys import version_info

    return f"{version_info.major}.{version_info.minor}.{version_info.micro}"


@installs(lambda _: cmd.pyenv('global').strip() == _['system_venv_name'])
def install_pyenv_sys_python(system_venv_name: str):
    """
    Install the system Python into pyenv's versions directory using venv
    """
    install_with_apt("python3-venv")

    # Create venv
    pyenv_root = local.env.home / ".pyenv"
    pyenv_versions_dir = pyenv_root / "versions"
    venv_path = pyenv_versions_dir / system_venv_name
    local[sys.executable]("-m", "venv", venv_path, "--system-site-packages")

    # Set as system
    cmd.pyenv("global", system_venv_name)

    # Produce shims for pip, python (required when they don't exist and we dont call into pyenv init)
    cmd.pyenv("rehash")

    with local.env(PYENV_VERSION=system_venv_name):
        # Install some utilities
        cmd.pip(
            "install", "nbdime", "jupyter", "jupyterlab", "jupyter-console", "makey"
        )

        # Setup nbdime as git diff engine
        cmd.nbdime("config-git", "--enable", "--global")


@modifies_environment
@installs('pyenv')
def install_pyenv():
    """
    Install PyEnv for managing Python versions & virtualenvs
    :return:
    """
    # Install pyenv
    (
        cmd.wget[
            "-O",
            "-",
            "https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer",
        ]
        | cmd.bash
    )()

@installs(
    lambda _: (cmd.pyenv['versions'] | cmd.grep[_['virtualenv_name']]) & plumbum.TF
)
def install_development_virtualenv(python_version: str, virtualenv_name: str = None):
    """
    Install Jupyter within a new virtual environment

    :param python_version: Python interpreter version string
    :param virtualenv_name: Name of virtual environment
    :return:
    """
    # Install npm
    install_with_apt("npm") # Is this already installed?

    if not python_version:
        python_version = get_system_python_version()

    # Install a particular interpreter (from source)
    if python_version != get_system_python_version():
        log("Installing Python version")
        cmd.pyenv["install", python_version].with_env(
            PYTHON_CONFIGURE_OPTS="--enable-shared"
        )()

    # Create virtualenv
    log("Creating virtualenv")
    cmd.pyenv("virtualenv", python_version, virtualenv_name)

    # Install packages
    with local.env(PYENV_VERSION=virtualenv_name):
        log("Installing jupyter packages with pip")
        cmd.pip(
            "install",
            "jupyter",
            "jupyterlab",
            "matplotlib",
            "ipympl",
            "numpy-html",
            "jupytex",
            "numba",
        )

        # Conda for scientific libraries
        try:
            conda = get_conda(virtualenv_name)
        except FileNotFoundError:
            cmd.pip("install", "scipy", "numpy")
        else:
            conda("install", "scipy", "numpy")

        # Install labextensions
        log("Installing lab extensions")
        cmd.jupyter(
            "labextension",
            "install",
            "@jupyter-widgets/jupyterlab-manager",
            "jupyter-matplotlib",
            # "bqplot",
            "@agoose77/jupyterlab-markup",
            # "@telamonian/theme-darcula",
            "@jupyterlab/katex-extension",
        )


@installs('micro')
def install_micro():
    """
    Install the micro editor
    :return:
    """
    # Set default editor in ZSH
    with local.cwd("/tmp"):
        (cmd.curl["https://getmic.ro"] | cmd.bash)()
        cmd.sudo[cmd.mv["micro", "/usr/local/bin"]]()


def create_gpg_key(name, email_address, key_length):
    import gnupg

    gpg = gnupg.GPG(homedir=str(GPG_HOME_PATH))
    input_data = gpg.gen_key_input(
        key_type="RSA", key_length=key_length, name_real=name, name_email=email_address
    )
    log("Generating GPG key")
    key = gpg.gen_key(input_data)
    log("Exporting GPG key")
    key_data = next(k for k in gpg.list_keys() if k["fingerprint"] == str(key))
    signing_key = key_data["keyid"]
    return gpg.export_keys(signing_key), signing_key


@installs()
def install_git(name, email_address):
    install_with_apt("git", "git-lfs")

    cmd.git("config", "--global", "user.email", email_address)
    cmd.git("config", "--global", "user.name", name)

    make_or_find_git_dir()


@installs('gpg')
def install_gnupg(name, email_address, key_length):
    install_with_apt("gnupg")
    install_with_pip("gnupg")
    # Create public key and copy to clipboard
    public_key, signing_key = create_gpg_key(name, email_address, key_length)
    (cmd.echo[public_key] | cmd.xclip["-sel", "clip"]) & plumbum.BG

    # Add key to GitHub & GitLab
    cmd.google_chrome("https://github.com/settings/gpg/new")
    cmd.google_chrome("https://gitlab.com/profile/gpg_keys")

    cmd.git("config", "--global", "commit.gpgsign", "true")
    cmd.git("config", "--global", "user.signingkey", signing_key)

    # Create SSH key
    ssh_private_key_path = Path("~/.ssh/id_ed25519").expanduser()
    cmd.ssh_keygen["-t", "ed25519", "-C", email_address] & plumbum.FG
    (
        cmd.cat[ssh_private_key_path.with_suffix(".pub")] | cmd.xclip["-sel", "clip"]
    ) & plumbum.BG
    cmd.google_chrome("https://github.com/settings/ssh/new")
    cmd.google_chrome("https://gitlab.com/profile/keys")


def make_or_find_sources_dir():
    sources = Path("~/Sources").expanduser()
    if not sources.exists():
        sources.mkdir()
    return sources


def make_or_find_libraries_dir():
    libraries = Path("~/Libraries").expanduser()
    if not libraries.exists():
        libraries.mkdir()
    return libraries


def make_or_find_git_dir():
    libraries = Path("~/Git").expanduser()
    if not libraries.exists():
        libraries.mkdir()
    return libraries


def get_pyenv_sysconfig_data(virtualenv_name: str,) -> SysconfigData:
    """
    Return the results of `sysconfig.get_paths()` and `sysconfig.get_config_vars()` from the required virtualenv

    :param virtualenv_name: Name of virtual environment
    :return:
    """
    result = json.loads(
        cmd.python.with_env(PYENV_VERSION=virtualenv_name)(
            "-c",
            """
import sysconfig, json, sys
print(json.dumps({'paths':sysconfig.get_paths(),
                  'config_vars':sysconfig.get_config_vars(),
                  'executable': sys.executable}))
            """,
        )
    )
    return SysconfigData(**result)


def get_conda(virtualenv_name=None):
    try:
        shim = cmd.conda
    except AttributeError:
        raise FileNotFoundError

    if virtualenv_name is not None:
        shim = shim.with_env(PYENV_VERSION=virtualenv_name)

    if not shim & plumbum.TF:
        raise FileNotFoundError
    return shim


def add_apt_repository(repo):
    cmd.sudo[cmd.add_apt_repository[repo]]()


@installs('regolith-look')
def install_regolith():
    add_apt_repository("ppa:regolith-linux/release")
    install_with_apt("regolith-desktop", "regolith-look-ayu-mirage")
    install_with_pip('i3ipc')

    # Copy blocks to local install
    for block_path in local.path("/etc/regolith/i3xrocks/conf.d").iterdir():
       cmd.cp(block_path, local.path("~/.config/regolith/i3xrocks/conf.d"))

    # Don't theme, handled by dotfiles
    # cmd.regolith_look("set", "ayu-mirage")
    # cmd.regolith_look("refresh")


@installs('alacritty')
def install_alacritty():
    add_apt_repository("ppa:mmstick76/alacritty")
    install_with_apt("alacritty")
    # Install terminfo - https://github.com/alacritty/alacritty/blob/master/INSTALL.md#terminfo
    with local.cwd("/tmp"):
        cmd.wget(
            "https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info"
        )
        cmd.sudo["tic", "-xe", "alacritty,alacritty-direct", "alacritty.info"]()

    # Set default terminal
    cmd.sudo[
        "update-alternatives", "--set", "x-terminal-emulator", local.which("alacritty")
    ]()


@installs('singularity')
def install_singularity(singularity_version='3.5.3'):
    install_with_apt('golang-go')
    install_with_apt('build-essential', 'libssl-dev', 'uuid-dev', 'libgpgme11-dev', 'squashfs-tools', 'libseccomp-dev', 'pkg-config')
    
    with local.cwd(make_or_find_libraries_dir()):
        cmd.wget(f'https://github.com/sylabs/singularity/releases/download/v{singularity_version}/singularity-{singularity_version}.tar.gz')
        cmd.tar('-xzf', f'singularity-{singularity_version}.tar.gz')

        with local.cwd('singularity'):
            local['./mconfig']('--prefix=/opt/singularity')
            cmd.make('-C', './builddir')
            cmd.sudo[cmd.make['-C', './builddir', 'install']]()

NO_DEFAULT = object()


def get_user_input(prompt: str, default=NO_DEFAULT, converter=None):
    """Get the name of the main virtual environment"""
    while True:
        if default is NO_DEFAULT:
            value = input(f"{prompt}: ")
            if not value:
                log(f"A value is required! Try again.", level=logging.ERROR)
                continue
        else:
            value = input(f"{prompt} [{default}]: ")
            if not value:
                value = default

        if converter is not None:
            try:
                value = converter(value)
            except ValueError:
                log(f"Invalid value {value!r}! Try again.", level=logging.ERROR)
                continue

        return value


def get_max_system_threads() -> int:
    """Return the number of threads available on the system."""
    return int(check_output(["grep", "-c", "cores", "/proc/cpuinfo"]).decode().strip())


def convert_number_threads(n_total_threads: int, n_threads_str: str) -> int:
    """Validate and clamp requested number of threads string to those available.

    :param n_total_threads: number of total threads
    :param n_threads_str: string of requested number of threads
    :return:
    """
    n_threads = int(n_threads_str)
    if not 0 < n_threads <= n_total_threads:
        raise ValueError(f"Invalid number of threads {n_threads}!")
    return n_threads


def yes_no_to_bool(answer: str) -> bool:
    """Convert prompt-like yes/no response to a bool.

    :param answer: yes/no response
    :return:
    """
    return answer.lower().strip() in {"y", "yes", "1"}


class Config:
    """Configuration holder class.

    Defers evaluation of 'Deferred' configuration getters until they are looked up.
    """

    def _resolve_attribute(self, name, value):
        if isinstance(value, DeferredValueFactory):
            value = value()
            setattr(self, name, value)
        return value
        
    def __getattribute__(self, item):
        if item.startswith("_"):
            return super().__getattribute__(item)
            
        value = object.__getattribute__(self, item)
        return self._resolve_attribute(item, value)

    def set(self, func):
        assert callable(func)
        setattr(self, func.__name__, deferred(func))

    def resolve(self):
        for name, value in vars(self).items():
            self._resolve_attribute(name, value)


class DeferredValueFactory:
    """Wrapper class which represents a deferred configuration value"""

    def __init__(self, func):
        self.func = func

    def __call__(self):
        return self.func()


deferred = DeferredValueFactory


def deferred_user_input(prompt: str, default=NO_DEFAULT, converter=None):
    @deferred
    def user_input():
        return get_user_input(prompt, default, converter)

    return user_input


def create_user_config() -> Config:
    config = Config()
    config.N_MAX_SYSTEM_THREADS = get_max_system_threads()
    config.N_BUILD_THREADS = deferred_user_input(
        "Enter number of build threads",
        config.N_MAX_SYSTEM_THREADS,
        lambda s: convert_number_threads(config.N_MAX_SYSTEM_THREADS, s),
    )
    config.DEVELOPMENT_VIRTUALENV_NAME = deferred_user_input(
        "Enter virtualenv name", "sci"
    )
    config.DEVELOPMENT_PYTHON_VERSION = deferred_user_input(
        "Enter Python version string", "miniconda3-latest", lambda s: s.strip().lower()
    )
    config.GIT_USER_NAME = deferred_user_input("Enter git user-name", "Angus Hollands")
    config.GIT_EMAIL_ADDRESS = deferred_user_input(
        "Enter git email-address", "goosey15@gmail.com"
    )
    config.GIT_KEY_LENGTH = deferred_user_input("Enter git key length", 4096, int)
    config.GITHUB_TOKEN = deferred_user_input(
        "Enter GitHub personal token", converter=validate_github_token
    )
    config.SYSTEM_VENV_NAME = f"{get_system_python_version()}-system"
    config.ROOT_USE_CONDA = deferred_user_input(
        "Use Conda package for ROOT?", "y", yes_no_to_bool
    )

    # Install ROOT
    @config.set
    def CONDA_CMD():
        # If conda is installed at all
        try:
            return get_conda(config.DEVELOPMENT_VIRTUALENV_NAME)
        except FileNotFoundError:
            return None

    return config


def install_all(config: Config):
    install_with_apt(
        "cmake",
        "curl",
        "wget",
        "cmake-gui",
        "build-essential",
        "aria2",
        "openssh-server",
        "checkinstall",
        "htop",
        "lm-sensors",
        "flameshot",
        "libreadline-dev",
        "libffi-dev",
        "libsqlite3-dev",
        "xclip",
        "libbz2-dev",
    )
    install_git(config.GIT_USER_NAME, config.GIT_EMAIL_ADDRESS)
    install_zsh()

    install_regolith()
    install_alacritty()

    install_chrome()
    install_with_apt("fd-find")
    install_tmux()

    install_pyenv()
    install_pyenv_sys_python(config.SYSTEM_VENV_NAME)
    install_development_virtualenv(
        config.DEVELOPMENT_PYTHON_VERSION, config.DEVELOPMENT_VIRTUALENV_NAME
    )

    install_micro()
    install_with_snap("thunderbird", beta=True)
    install_with_snap("spotify")
    install_with_snap("mathpix-snipping-tool")
    install_with_snap("atom", classic=True)
    install_with_apt("polari")
    install_with_apt("vlc")
    install_with_apt("fzf")
    install_with_snap("gimp")
    install_with_apt("ripgrep")
    install_gnome_tweak_tool()

    install_singularity()

    for package in ("pycharm-professional", "clion", "webstorm"):
        install_with_snap(package, classic=True)

    install_pandoc(config.GITHUB_TOKEN)
    install_tex()


def stow_dotfiles():
    with local.cwd(THIS_DIR):
        for path in THIS_DIR.iterdir():
            if not path.is_dir():
                continue

            if path.name.startswith("."):
                continue

            cmd.stow(path.name, "--no-folding")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    stow_parser = subparsers.add_parser("stow")
    stow_parser.set_defaults(stow=True)

    install_parser = subparsers.add_parser("install")
    install_parser.add_argument('-b', '--batch', action='store_true', help="load configuration options up front rather than during installation")
    install_parser.set_defaults(install=True)

    args = parser.parse_args()
    config = create_user_config()

    if hasattr(args, "install"):
        if args.batch:
            config.resolve()
        install_all(config)
    elif hasattr(args, "stow"):
        stow_dotfiles()
    else:
        code.interact(local=locals())
