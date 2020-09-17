#!/bin/bash
#
# Usage: superbuild.sh [ -egl | -osmesa ]
#   Set ParaView version by environment variable PARAVIEW_VERSION
#   Example: $ PARAVIEW_VERSION="5.8.0" ./superbuild.sh
#

set -e

if [[ -z "${PARAVIEW_VERSION}" ]]; then
  readonly paraview_version="5.8.0$1"
else
  readonly paraview_version="${PARAVIEW_VERSION}$1"
fi
readonly paraview_ver=${paraview_version:0:3}
# readonly image=lhofmann/paraview-extra:${paraview_version}
readonly image=lhofmann/paraview-superbuild:${paraview_version}
readonly container=build-ttk-${paraview_version}
readonly cwd="$(dirname "$(readlink -f "$0")")"

readonly paraview_name="ParaView-${paraview_version}-MPI-Linux-Python3.7-64bit"

if [[ "$(docker images -q ${image} 2> /dev/null)" == "" ]]; then
  docker pull "${image}" || \
  docker build --rm --network=host -t "${image}" --build-arg paraview_version="${paraview_version}" -f "${cwd}/Dockerfile.superbuild" "${cwd}"
fi

docker top ${container} >/dev/null 2>&1 || \
docker start ${container} >/dev/null 2>&1 || \
docker run -itd \
    --net=host \
    --user "$(id -u ${USER}):$(id -g ${USER})" \
    --name ${container} \
    --volume="${cwd}/..:/mnt/shared:rw" \
    ${image}

docker exec ${container} /usr/bin/scl enable devtoolset-8 -- cmake \
    -B/tmp/superbuild \
    -H/mnt/shared/ \
    -DCMAKE_BUILD_TYPE=Release \
    -DTTK_ENABLE_CPU_OPTIMIZATION=OFF \
    -DTTK_ENABLE_64BIT_IDS=OFF \
    -DTTK_ENABLE_KAMIKAZE=OFF \
    -DTTK_BUILD_STANDALONE_APPS=ON \
    -DCMAKE_INSTALL_PREFIX=/tmp/package/${paraview_name} \
    -DTTK_INSTALL_PLUGIN_DIR=/tmp/package/${paraview_name}/bin/plugins \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DMili_INCLUDE_DIR=/home/paraview/buildbuildbuildbuildbuildbuildbuildbuildbuildbuildbuildbuildbuildbuild/install/include

docker exec ${container} cmake --build /tmp/superbuild --target install -- -j4

docker cp "${container}:/tmp/package/${paraview_name}" .
