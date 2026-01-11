#!/bin/bash

set -ouex pipefail

shopt -s nullglob

packages=(
  python3
  python3-pip
  python3-setuptools
  python3-gobject
  gobject-introspection
  cairo-devel
  gcc
  gtk3-devel
)
dnf5 -y install "${packages[@]}"

TMPDIR=$(mktemp -d)
pushd "$TMPDIR"

git clone https://github.com/AdnanHodzic/auto-cpufreq.git "$TMPDIR/auto-cpufreq"
cd "$TMPDIR/auto-cpufreq"

APPLICATIONS_PATH="/usr/share/applications"
VENV_PATH="/opt/auto-cpufreq"

SHARE_DIR="/usr/local/share/auto-cpufreq/"

AUTO_CPUFREQ_FILE="/usr/local/bin/auto-cpufreq"
AUTO_CPUFREQ_GTK_FILE=$AUTO_CPUFREQ_FILE-gtk
AUTO_CPUFREQ_GTK_DESKTOP_FILE="$(basename $AUTO_CPUFREQ_GTK_FILE).desktop"

IMG_FILE="/usr/share/pixmaps/auto-cpufreq.png"
ORG_FILE="/usr/share/polkit-1/actions/org.auto-cpufreq.pkexec.policy"

echo "Installing necessary Python packages"

venv_dir=$VENV_PATH/venv
mkdir -p "$venv_dir"
python3 -m venv --system-site-packages "$venv_dir"

source "$venv_dir/bin/activate"
python3 -m pip install --upgrade pip wheel


# debian specific PyGObject Installation
if [ -f /etc/debian_version ]; then
  VERSION=$(cat /etc/debian_version | cut -d'.' -f1)

  if [[ "$VERSION" =~ ^12(\.[0-9]+)?$ ]]; then
      python3 -m pip install PyGObject==3.50.0
  fi
fi
python3 -m pip install PyGObject

git config --global --add safe.directory $(pwd)
python -m pip install .

mkdir -p $SHARE_DIR
cp -r scripts/ $SHARE_DIR
cp -r images/ $SHARE_DIR
cp images/icon.png $IMG_FILE
cp scripts/$(basename $ORG_FILE) $(dirname $ORG_FILE)

cp scripts/auto-cpufreq-venv-wrapper $AUTO_CPUFREQ_FILE
chmod a+x $AUTO_CPUFREQ_FILE
cp scripts/start_app $AUTO_CPUFREQ_GTK_FILE
chmod a+x $AUTO_CPUFREQ_GTK_FILE

cp scripts/$AUTO_CPUFREQ_GTK_DESKTOP_FILE $APPLICATIONS_PATH

popd
rm -rf "$TMPDIR"

cp /usr/local/share/auto-cpufreq/scripts/auto-cpufreq.service /etc/systemd/system/auto-cpufreq.service
