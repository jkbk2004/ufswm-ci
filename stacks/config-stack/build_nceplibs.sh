#!/bin/bash

set -eux

name=$1

var_version="STACK_${name}_version"
var_install_as="STACK_${name}_install_as"
var_openmp="STACK_${name}_openmp"

set +u
s_version=${!var_version}
s_install_as=${!var_install_as}
s_openmp=${!var_openmp}
set -u

version=${2:-$s_version}    # second column of COMPONENTS
install_as=${3:-${s_install_as}} #  third column of COMPONENTS
openmp=${4:-${s_openmp:-"OFF"}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')
python=$(echo $HPC_PYTHON | sed 's/\//-/g')

# ---------- to install thru docker ---------------------
# ---------- generally netcdf loading issue -------------
# ---------- external netcdf recommended ----------------
export HPCMOD_PRE=/opt/hpc-modules
# -------------------------------------------------------
      
if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER

  case $name in
    # The following require MPI
    nemsiogfs | ncio | ncdiag)
      module load hpc-$HPC_MPI
      using_mpi=YES
      ;;
    nemsio)
      #-------------for docker--------------------------------
      export MPI_FC=mpifort
      export MPI_CC=mpicc
      export MPI_CXX=mpicxx

      module use $HPCMOD_PRE/modulefiles/stack
      module load hpc
      module load hpc-gnu
      #-------------for docker--------------------------------
      version_number=$(echo $version | cut -c 2-)
      major_ver=$(echo $version_number | cut -d. -f1)
      minor_ver=$(echo $version_number | cut -d. -f2)
      patch_ver=$(echo $version_number | cut -d. -f3)
      using_mpi=UNKNOWN
      if [[ "$major_ver" -le "2" ]]; then
          if [[ "$minor_ver" -le "5" ]]; then
              if [[ "$patch_ver" -lt "3" ]]; then
                  [[ ! -z $mpi ]] || exit 0
                  module load hpc-$HPC_MPI
                  using_mpi=YES
                  w3dep="w3nco"
              fi
          fi
      fi
      if [[ $using_mpi = "UNKNOWN" ]]; then
        w3dep="w3emc"
        using_mpi=NO
        if [[ ! -z $mpi ]]; then
          module load hpc-$HPC_MPI
          using_mpi=YES
        fi
      fi
      ;;
    w3emc)
      version_number=$(echo $version | cut -c 2-)
      major_ver=$(echo $version_number | cut -d. -f1)
      minor_ver=$(echo $version_number | cut -d. -f2)
      using_mpi=NO
      if [[ "$major_ver" -le "2" ]]; then
          if [[ "$minor_ver" -lt "9" ]]; then
              module load hpc-$HPC_MPI
              using_mpi=YES
          fi
      fi
      ;;
    # The following can use MPI (if available)
    wrf_io | wgrib2)
      #-------------for docker--------------------------------
      export MPI_FC=mpifort
      export MPI_CC=mpicc
      export MPI_CXX=mpicxx

      module use $HPCMOD_PRE/modulefiles/stack
      module load hpc
      module load hpc-gnu
      #-------------for docker--------------------------------
      if [[ ! -z $mpi ]]; then
        module load hpc-$HPC_MPI
        using_mpi=YES
      fi
      #module load netcdf
      ;;
  esac

  # Load dependencies
  case $name in
    wrf_io)
      #-------------for docker--------------------------------
      export MPI_FC=mpifort
      export MPI_CC=mpicc
      export MPI_CXX=mpicxx

      module use $HPCMOD_PRE/modulefiles/stack
      module load hpc
      module load hpc-gnu
      #-------------for docker--------------------------------
      #module load netcdf
      ;;
    wgrib2)
      #-------------for docker--------------------------------
      export MPI_FC=mpifort
      export MPI_CC=mpicc
      export MPI_CXX=mpicxx

      module use $HPCMOD_PRE/modulefiles/stack
      module load hpc
      module load hpc-gnu
      module load jasper
      module load zlib
      module load libpng
      module load w3emc
      module load sp

      export bacio_DIR=$HPCMOD_PRE/gnu-9.3.0/bacio/2.4.1/lib/cmake/bacio
      export w3emc_DIR=$HPCMOD_PRE/gnu-9.3.0/w3emc/2.9.2/lib/cmake/w3emc
      export w3nco_DIR=$HPCMOD_PRE/gnu-9.3.0/w3nco/2.4.1/lib/cmake/w3nco
      export g2_DIR=$HPCMOD_PRE/gnu-9.3.0/g2/3.4.5/lib/cmake/g2
      export ip_DIR=$HPCMOD_PRE/gnu-9.3.0/ip/3.3.3/lib/cmake
      export sp_DIR=$HPCMOD_PRE/gnu-9.3.0/sp/2.3.3/lib/cmake/sp
      export ip2_DIR=$HPCMOD_PRE/gnu-9.3.0/ip2/1.1.2/lib/cmake/ip2
      #-------------for docker--------------------------------
      ;;
    crtm)
      #-------------for docker--------------------------------
      export MPI_FC=mpifort
      export MPI_CC=mpicc
      export MPI_CXX=mpicxx

      module use $HPCMOD_PRE/modulefiles/stack
      module load hpc
      module load hpc-gnu
      module load jasper/2.0.25
      module load libpng/1.6.37
      module load w3emc/2.9.2
      module load sp

      export bacio_DIR=$HPCMOD_PRE/gnu-9.3.0/bacio/2.4.1/lib/cmake/bacio
      export w3emc_DIR=$HPCMOD_PRE/gnu-9.3.0/w3emc/2.9.2/lib/cmake/w3emc
      export w3nco_DIR=$HPCMOD_PRE/gnu-9.3.0/w3nco/2.4.1/lib/cmake/w3nco
      export g2_DIR=$HPCMOD_PRE/gnu-9.3.0/g2/3.4.5/lib/cmake/g2
      export ip_DIR=$HPCMOD_PRE/gnu-9.3.0/ip/3.3.3/lib/cmake
      export sp_DIR=$HPCMOD_PRE/gnu-9.3.0/sp/2.3.3/lib/cmake/sp
      export ip2_DIR=$HPCMOD_PRE/gnu-9.3.0/ip2/1.1.2/lib/cmake/ip2
      #-------------for docker--------------------------------
      ;;
    ip2)
      module load sp
      ;;
    g2)
      module try-load jpeg
      module try-load libpng
      module try-load jasper
      ;;
    g2c)
      module try-load jpeg
      module try-load zlib
      module try-load libpng
      module try-load jasper
      ;;
    nemsio)
      #-------------for docker--------------------------------
      export MPI_FC=mpifort
      export MPI_CC=mpicc
      export MPI_CXX=mpicxx

      module use $HPCMOD_PRE/modulefiles/stack
      module load hpc
      module load hpc-gnu

      export bacio_DIR=$HPCMOD_PRE/gnu-9.3.0/bacio/2.4.1/lib/cmake/bacio
      export w3emc_DIR=$HPCMOD_PRE/gnu-9.3.0/w3emc/2.9.2/lib/cmake/w3emc
      export w3nco_DIR=$HPCMOD_PRE/gnu-9.3.0/w3nco/2.4.1/lib/cmake/w3nco
      export g2_DIR=$HPCMOD_PRE/gnu-9.3.0/g2/3.4.5/lib/cmake/g2
      export ip_DIR=$HPCMOD_PRE/gnu-9.3.0/ip/3.3.3/lib/cmake
      export sp_DIR=$HPCMOD_PRE/gnu-9.3.0/sp/2.3.3/lib/cmake/sp
      export ip2_DIR=$HPCMOD_PRE/gnu-9.3.0/ip2/1.1.2/lib/cmake/ip2
      #-------------for docker--------------------------------
      module load bacio
      module load ${w3dep}
      ;;
    nemsiogfs)
      module load nemsio
      module load w3nco
      ;;
    w3emc)
      module load bacio
      if [[ "$using_mpi" =~ [yYtT] ]]; then
          module load netcdf
          module load sigio
          module load nemsio
      fi
      ;;
    grib_util)
      module try-load jpeg
      module try-load jasper
      module try-load zlib
      module try-load libpng
      module try-load w3emc/2.9.2
      module load bacio
      module load w3nco
      module load g2
      module load ip
      module load sp
      #-------------for docker--------------------------------
      export w3nco_DIR=$HPCMOD_PRE/gnu-9.3.0/w3nco/2.4.1/lib/cmake/w3nco
      export g2_DIR=$HPCMOD_PRE/gnu-9.3.0/g2/3.4.5/lib/cmake/g2
      export bacio_DIR=$HPCMOD_PRE/gnu-9.3.0/bacio/2.4.1/lib/cmake/bacio
      export ip_DIR=$HPCMOD_PRE/gnu-9.3.0/ip/3.3.3/lib/cmake
      #-------------for docker--------------------------------      
      ;;
    prod_util)
      module load w3nco
      #-------------for docker--------------------------------
      export w3nco_DIR=$HPCMOD_PRE/gnu-9.3.0/w3nco/2.4.1/lib/cmake/w3nco
      #-------------for docker--------------------------------
      ;;
    ncio | ncdiag)
      #-------------for docker--------------------------------
      export MPI_FC=mpifort
      export MPI_CC=mpicc
      export MPI_CXX=mpicxx

      module use $HPCMOD_PRE/modulefiles/stack
      module load hpc
      module load hpc-gnu
      module load jasper/2.0.25
      module load libpng/1.6.37
      module load w3emc/2.9.2
      module load sp

      export bacio_DIR=$HPCMOD_PRE/gnu-9.3.0/bacio/2.4.1/lib/cmake/bacio
      export w3emc_DIR=$HPCMOD_PRE/gnu-9.3.0/w3emc/2.9.2/lib/cmake/w3emc
      export w3nco_DIR=$HPCMOD_PRE/gnu-9.3.0/w3nco/2.4.1/lib/cmake/w3nco
      export g2_DIR=$HPCMOD_PRE/gnu-9.3.0/g2/3.4.5/lib/cmake/g2
      export ip_DIR=$HPCMOD_PRE/gnu-9.3.0/ip/3.3.3/lib/cmake
      export sp_DIR=$HPCMOD_PRE/gnu-9.3.0/sp/2.3.3/lib/cmake/sp
      export ip2_DIR=$HPCMOD_PRE/gnu-9.3.0/ip2/1.1.2/lib/cmake/ip2
      #-------------for docker--------------------------------
      ;;
    bufr)
      if [[ ! -z $python ]]; then
        if [[ ${STACK_bufr_python:-} =~ [yYtT] ]]; then
          module load hpc-$HPC_PYTHON
          using_python=YES
        fi
      fi
      ;;
  esac
  module list
  set -x

  if [[ ${using_mpi:-} =~ [yYtT] ]]; then
    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$install_as"
  else
    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$install_as"
  fi
  if [[ -d $prefix ]]; then
      if [[ $OVERWRITE =~ [yYtT] ]]; then
          echo "WARNING: $prefix EXISTS: OVERWRITING!"
          $SUDO rm -rf $prefix
          $SUDO mkdir $prefix
      else
          echo "WARNING: $prefix EXISTS, SKIPPING"
          exit 0
      fi
  fi

else

  nameUpper=$(echo $name | tr [a-z] [A-Z])
  eval prefix="\${${nameUpper}_ROOT:-'/usr/local'}"
  case $name in
    # The following require MPI
    nemsio | nemsiogfs | ncio | ncdiag )
        #-------------for docker--------------------------------
        export MPI_FC=mpifort
	export MPI_CC=mpicc
	export MPI_CXX=mpicxx

	module use $HPCMOD_PRE/modulefiles/stack
	module load hpc
	module load hpc-gnu
	module load netcdf/4.7.4
        #-------------for docker--------------------------------
        using_mpi=YES
      ;;
    # The following can use MPI (if available)
    wrf_io | wgrib2)
      #-------------for docker--------------------------------
      export MPI_FC=mpifort
      export MPI_CC=mpicc
      export MPI_CXX=mpicxx

      module use $HPCMOD_PRE/modulefiles/stack
      module load hpc
      module load hpc-gnu
      #-------------for docker--------------------------------
      [[ ! -z $mpi ]] && using_mpi=YES
      module load netcdf
      #-------------------------------------------------------
      ;;
  esac

fi

if [[ ${using_mpi:-} =~ [yYtT] ]]; then
  export FC=$MPI_FC
  export CC=$MPI_CC
  export CXX=$MPI_CXX
else
  export FC=$SERIAL_FC
  export CC=$SERIAL_CC
  export CXX=$SERIAL_CXX
fi

eval fflags="\${STACK_${name}_FFLAGS:-}"
eval cflags="\${STACK_${name}_CFLAGS:-}"
eval cxxflags="\${STACK_${name}_CXXFLAGS:-}"

export F9X=$FC
export FFLAGS="${STACK_FFLAGS:-} $fflags -fPIC -w"
export CFLAGS="${STACK_CFLAGS:-} $cflags -fPIC -w"
export CXXFLAGS="${STACK_CXXFLAGS:-} $cxxflags -fPIC -w"
export FCFLAGS="$FFLAGS"

# Set properties based on library name
URL="https://github.com/noaa-emc/nceplibs-$name"
extraCMakeFlags=""
case $name in
  crtm)
    URL="https://github.com/NOAA-EMC/crtm.git"
    ;;
  wgrib2)
    extraCMakeFlags="${STACK_wgrib2_cmake_opts:-}"
    ;;
  bufr)
    if [[ ${using_python:-} =~ [yYtT] ]]; then
      extraCMakeFlags="-DENABLE_PYTHON=ON "
    fi
    if [[ $MAKE_CHECK =~ [yYtT] ]]; then
        extraCMakeFlags+="-DBUILD_TESTS=ON"
    else
        extraCMakeFlags+="-DBUILD_TESTS=OFF"
    fi
    ;;
  nemsio)
    #-------------for docker--------------------------------
    export MPI_FC=mpifort
    export MPI_CC=mpicc
    export MPI_CXX=mpicxx
      
    module use $HPCMOD_PRE/modulefiles/stack
    module load hpc
    module load hpc-gnu
    #-------------for docker--------------------------------
    if [[ ${using_mpi:-} =~ [yYtT] ]]; then
      extraCMakeFlags="-DENABLE_MPI=ON"
    else
      extraCMakeFlags="-DENABLE_MPI=OFF"
    fi
    ;;
  ncdiag)
    URL="https://github.com/NOAA-EMC/GSI-ncdiag"
    ;;
esac

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
if [[ ! -d $software ]]; then
  export GIT_LFS_SKIP_SMUDGE=1
  git clone $URL $software
  cd $software
  if [[ "$name" == "crtm" ]]; then
    version=release/REL-${install_as}_emc
  fi
  git checkout $version
  git submodule update --init --recursive
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

# Download CRTM fix files
if [[ "$name" == "crtm" ]]; then
  if [[ ${STACK_crtm_install_fix:-} =~ [yYtT] ]]; then
    if [[ ! -d crtm_fix-${install_as} ]]; then
      crtm_tarball=fix_REL-${install_as}_emc.tgz
     [[ -f $crtm_tarball ]] || ( $WGET ftp://ftp.ucar.edu/pub/cpaess/bjohns/$crtm_tarball )
      tar xzf $crtm_tarball
      mv fix crtm_fix-${install_as}
#      rm -f $crtm_tarball
    fi
    if [[ "${install_as}" == "2.3.0" ]]; then
     if [[ ! -f link_crtm_coeffs.sh ]]; then
       $WGET https://raw.githubusercontent.com/NOAA-EMC/GSI/master/ush/link_crtm_coeffs.sh
       sed -i'.backup' -e 's/LINK="ln -sf"/LINK="cp"/g' link_crtm_coeffs.sh
       chmod +x link_crtm_coeffs.sh
       rm -f link_crtm_coeffs.sh.backup
     fi
    fi
  fi
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake .. \
  -DCMAKE_INSTALL_PREFIX=$prefix \
  -DENABLE_TESTS=OFF -DOPENMP=${openmp} ${extraCMakeFlags:-}

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
[[ $USE_SUDO =~ [yYtT] ]] && sudo -- bash -c "export PATH=$PATH; make install" \
                          || make install

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

# Install CRTM fix files
if [[ "$name" == "crtm" ]]; then
  if [[ ${STACK_crtm_install_fix:-} =~ [yYtT] ]]; then
    if [[ -d crtm_fix-${install_as} ]]; then
     if [[ "${install_as}" == "2.3.0" ]]; then
       ./link_crtm_coeffs.sh ./crtm_fix-${install_as} $prefix/fix
     else
       mkdir -p $prefix/fix
       cp ./crtm_fix-${install_as}/ACCoeff/netcdf/* $prefix/fix
       cp ./crtm_fix-${install_as}/AerosolCoeff/Big_Endian/* $prefix/fix
       cp ./crtm_fix-${install_as}/AerosolCoeff/netCDF/* $prefix/fix
       cp ./crtm_fix-${install_as}/CloudCoeff/Big_Endian/* $prefix/fix
       cp ./crtm_fix-${install_as}/CloudCoeff/netCDF/* $prefix/fix
       cp ./crtm_fix-${install_as}/EmisCoeff/*/Big_Endian/* $prefix/fix
       cp ./crtm_fix-${install_as}/EmisCoeff/*/*/Big_Endian/* $prefix/fix
       cp ./crtm_fix-${install_as}/SpcCoeff/Big_Endian/* $prefix/fix
       cp ./crtm_fix-${install_as}/SpcCoeff/netcdf/* $prefix/fix
       cp ./crtm_fix-${install_as}/TauCoeff/ODPS/Big_Endian/* $prefix/fix
       mv $prefix/fix/amsua_metop-c.SpcCoeff.bin $prefix/fix/amsua_metop-c.SpcCoeff.noACC.bin
       cp ./crtm_fix-${install_as}/SpcCoeff/Little_Endian/amsua_metop-c_v2.SpcCoeff.bin $prefix/fix/amsua_metop-c.SpcCoeff.bin
     fi
    fi
  fi
fi

# generate modulefile from template
[[ ${using_mpi:-} =~ [yYtT] ]] && modpath=mpi || modpath=compiler
[[ ${using_python:-} =~ [yYtT] ]] && py_version="$(python3 --version | cut -d " " -f2 | cut -d. -f1-2)"
$MODULES && update_modules $modpath $name $install_as ${py_version:-}
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
