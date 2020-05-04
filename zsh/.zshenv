# get-texat libs
export PKG_CONFIG_PATH="/opt/get-texat/lib/pkgconfig:$PKG_CONFIG_PATH"
# Singularity
export PATH="/opt/go/bin:/opt/singularity/bin:$PATH"
# TexAtSim / Response
export PATH="/opt/texat-sim/bin:/opt/texat-response/bin:$PATH"
# Texlive
export PATH="/usr/local/texlive/2020/bin/x86_64-linux:$PATH"
# ROOT
cd /opt/geant4/bin; source geant4.sh;  cd - >/dev/null
. /opt/root/bin/thisroot.sh
