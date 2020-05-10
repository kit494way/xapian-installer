#!/bin/sh
set -eu

xapian_version=${1:-1.4.15}
xapian_root=${HOME}/xapian

xapian_core_tar="xapian-core-${xapian_version}.tar.xz"
xapian_bindings_tar="xapian-bindings-${xapian_version}.tar.xz"

xapian_core_url="https://oligarchy.co.uk/xapian/${xapian_version}/${xapian_core_tar}"
xapian_bindings_url="https://oligarchy.co.uk/xapian/${xapian_version}/${xapian_bindings_tar}"

xapian_core_src_dir="${xapian_root}/src/xapian-core-${xapian_version}"
xapian_bindings_src_dir="${xapian_root}/src/xapian-bindings-${xapian_version}"

# Install directories
xapian_core_dir="${xapian_root}/xapian-core-${xapian_version}"
xapian_bindings_dir="${xapian_root}/xapian-bindings-${xapian_version}"

python_version=$(python -c 'from sys import version_info as v;print("%d.%d.%d" % (v.major, v.minor, v.micro))')
python_path=$(python -c 'import sys;print(sys.executable)')

# Only support Python 3+
if [ "${python_version%%.*}" != "3" ]; then
  echo "Detected Python version is '${python_version}'."
  echo "This script only support Python 3+."
  exit 1
fi

# Create xapian install directory
mkdir -p ${xapian_root}/src


# Download source files
if [ ! -e "${xapian_root}/src/${xapian_core_tar}" ]; then
  echo "Download ${xapian_core_url}"
  curl -sSfL "${xapian_core_url}" -o "${xapian_root}/src/${xapian_core_tar}"
else
  echo "${xapian_root}/src/${xapian_core_tar} already exists."
fi

if [ ! -e "${xapian_root}/src/${xapian_bindings_tar}" ]; then
  echo "Download ${xapian_bindings_url}"
  curl -sSfL "${xapian_bindings_url}" -o "${xapian_root}/src/${xapian_bindings_tar}"
else
  echo "${xapian_root}/src/${xapian_bindings_tar} already exists."
fi


cd "${xapian_root}/src"
if [ ! -d "${xapian_core_src_dir}" ]; then
  tar xvf "${xapian_core_tar}"
fi
cd "${xapian_core_src_dir}"

# Create xapian-core install directory
mkdir -p ${xapian_core_dir}

if [ -e "${xapian_core_dir}/bin/xapian-config" ]; then
  echo "xapian-core is already installed."
else
  ./configure --prefix=${xapian_core_dir}
  make -j 4
  make install
fi


cd "${xapian_root}/src"
if [ ! -d "${xapian_bindings_src_dir}" ]; then
  tar xvf "${xapian_bindings_tar}"
fi
cd "${xapian_bindings_src_dir}"

# Create Python binding install directories
mkdir -p ${xapian_bindings_dir}/python/${python_version}/{lib,install}

# sphinx is required to build documents
python -m pip install sphinx

make clean || true
./configure --with-python3 --prefix=${xapian_bindings_dir}/python/${python_version}/install \
  XAPIAN_CONFIG=${xapian_core_dir}/bin/xapian-config \
  PYTHON3=${python_path} \
  PYTHON3_LIB=${xapian_bindings_dir}/python/${python_version}/lib # Path to install xapian-binding for Python
make -j 4
make install


system_site_packages_path=$(python -c "import site; print(site.getsitepackages()[0])")
user_site_packages_path=$(python -c "import site; print(site.getusersitepackages())")
cat <<EOD

Add Python binding path to site-packages.
For example,

    echo "${xapian_bindings_dir}/python/${python_version}/lib" >> ${system_site_packages_path}/additional.pth

or

    echo "${xapian_bindings_dir}/python/${python_version}/lib" >> ${user_site_packages_path}/additional.pth

EOD
