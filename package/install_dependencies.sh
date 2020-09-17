#!/bin/bash

set -e

cd /tmp

if [ ! -d eigen3 ]; then
  curl -L "https://gitlab.com/libeigen/eigen/-/archive/3.3.7/eigen-3.3.7.tar.gz" -o eigen.tar.gz 
  tar xzf eigen.tar.gz
  rm eigen.tar.gz
  mkdir eigen3_build
  pushd eigen3_build
  /usr/bin/scl enable devtoolset-8 -- cmake ../eigen-3.3.7 -DCMAKE_INSTALL_PREFIX=/tmp/eigen3
  /usr/bin/scl enable devtoolset-8 -- cmake --build . --target install -- -j4
  popd
  rm -r eigen3_build eigen-3.3.7
fi

if [ ! -d spectra ]; then
  curl -L "https://github.com/yixuan/spectra/archive/v0.9.0.tar.gz" -o spectra.tar.gz
  tar xzf spectra.tar.gz
  rm spectra.tar.gz
  mkdir spectra_build
  pushd spectra_build
  /usr/bin/scl enable devtoolset-8 -- cmake ../spectra-0.9.0 -DEigen3_DIR=/tmp/eigen3/share/eigen3/cmake -DCMAKE_INSTALL_PREFIX=/tmp/spectra
  /usr/bin/scl enable devtoolset-8 -- cmake --build . --target install -- -j4
  popd
  rm -r spectra_build spectra-0.9.0
fi

