
#!/usr/bin/env bash
#
# This is the script we use to   build  SWI-Prolog and all its packages.
# Copy the script to  `build',  edit   to  suit  the  local installation
# requirements and run it. Once correct, upgrading   to a new release is
# now limited to getting the new sources and run ./build.

# [EDIT] Prefix location of the installation. It is _not_ adviced to use
# a    versioned    prefix.    The    system      will     install    in
# $PREFIX/lib/swipl-<version> and create symlinks   from $PREFIX/bin for
# the main programs. Users can  always   use  older  versions by running
# $PREFIX/lib/swipl-<version>/bin/<arch>/pl
#
# If you change PREFIX such that the system  is installed in a place for
# which you have no write access, set  SUDO   to  the command to run the
# remainder of the commandline as privilaged   user. E.g., if you change
# PREFIX to /usr/local you typically must change SUDO to "sudo"

PREFIX=/usr
#SUDO=
#SUDO="sudo"

# [EDIT] Version of make to use.  This   must  be GNU-make. On many Unix
# systems this is installed as 'gmake'. On most GNU-based systems (e.g.,
# linux), the default make is GNU-make.  You can use 'make --jobs=<max>'
# to build the system faster using  all   your  cores. The optimal value
# depends a lot on your hardware.   Unfortunately,  not all dependencies
# are covered by the Makefiles. If your build   fails on what might be a
# missing dependency, try  re-running  without   --jobs  and  report the
# issue.

# MAKE=make
MAKE='make --jobs=4'

# [EDIT] Compiler and options.
#
#       CC:      Which C-compiler to use
#       COFLAGS: Flags for the optimizer such as "-O3" or "-g"
#       CMFLAGS: Machine flags such as "-m64" (64-bits on gcc)
#       CIFLAGS: Include-path such as "-I/opt/include"
#       LDFLAGS: Link flags such as "-L/opt/lib"
#
# Leaving an option blank leaves the  choice to configure. The commented
# values below enable much better C-level debugging with almost the same
# performance on GCC based systems (the default is to compile using -O3)
# For optiomal performance, see also --enable-useprofile below.

# export CC=
# export COFLAGS="-O2 -gdwarf-2 -g3"
# export CMFLAGS=
# export CIFLAGS=
# export LDFLAGS="-O2 -g"

################################################################
# Package (add-ons) selection
################################################################

# [EDIT] Packages to configure. Leaving it   blank  compiles all default
# packages. The final set of packages is
#
#       ${PKG-<default>} + $EXTRA_PKGS - $DISABLE_PKGS

# export PKG=

# [EDIT] Packages to skip.  Leaving it blank compiles all default packages.
# export DISABLE_PKGS="jpl ssl odbc utf8proc"

# [EDIT] Packages to add.
# export EXTRA_PKGS="db ltx2htm space"

# [EDIT] Where to find the jar for Junit 3.8.  Needed to test jpl
# export JUNIT=/opt/local/share/java/junit.jar

################################################################
# Misc stuff
################################################################

# [EDIT] Extra options to pass to the toplevel configure.

#--link
# Using --link, the system is installed using symbolic links. This means
# you cannot remove or clean  the   sources,  but  it largely simplifies
# editing the system Prolog files during development.
#
#--enable-useprofile
# The config --enable-useprofile exploits GCC  -fprofile-use option. The
# system  is  compiled,  profiled   and    re-compiled   to  get  better
# branch-prediction. This makes the system approx.   10%  faster. Do not
# use this for developing the kernel because it complicates maintenance.
#
#--disable-libdirversion
# By default, the system is  installed in $libdir/swipl-<version>. Using
# this option drops <version>. Using versions,  you can install multiple
# versions side-by-site and run old  versions   at  any time by starting
# $libdir/swipl-<version>/bin/$arch/swipl. Without, the system is always
# at a nice stable place, so external foreign objects linked against the
# binary need not be updated with a Prolog update.
#
#--enable-shared
# Use this to create a shared object  for the Prolog kernel. The default
# depends on the platform. Creating a shared   object  is the default on
# most platforms, either because it is  needed   or  because  it does no
# harm. The only exception to this rule  is Linux on x86 (Intel 32-bit).
# It is not needed on this platform  and Linux shared object model costs
# a CPU register. Given the limited number   of CPU registers on the x86
# platform, this results in a performance degradation of about 10%.

 EXTRACFG+=" --link"
 EXTRACFG+=" --enable-useprofile"
 EXTRACFG+=" --disable-libdirversion"
 EXTRACFG+=" --enable-shared"
export EXTRACFG

# One possiblity to make relocatable executables   on  Linux is by using
# the RPATH mechanism. See  ld.so(1)   and  chrpath(1). However, chrpath
# cannot enlarge the path. Uncommenting the   line below adds :xxx... to
# the RPATH, where the given count is the number of x-s.
#
# export RPATH_RESERVE=70

################################################################
# No edit should be needed below this line
################################################################

V=`cat VERSION`
config=true
make=true
install=true
done=false
setvars=false

while test "$done" = false; do
case "$1" in
   --config)    make=false
                install=false
                shift
                ;;
   --make)      config=false
                install=false
                shift
                ;;
   --install)   config=false
                make=false
                shift
                ;;
   --prefix=*)  PREFIX=`echo "$1" | sed 's/--prefix=//'`
                shift
                ;;
   --setvars)   setvars=true
                shift
                ;;
   *)           done=true
                ;;
esac
done

if [ "$setvars" = "false" ]; then
  rm -f packages/.failed.*

  if [ "$config" = "true" ]; then
    ./configure --prefix=$PREFIX --with-world $EXTRACFG $@ 2>&1 | tee configure.out
    if [ "${PIPESTATUS[0]}" != 0 ]; then exit 1; fi
  fi

  if [ "$make" = "true" ]; then
    $MAKE $@ 2>&1 | tee make.out
    if [ "${PIPESTATUS[0]}" != 0 ]; then exit 1; fi
  fi

  if [ "$install" = "true" ]; then
    $SUDO $MAKE install $@ 2>&1 | tee make-install.out
    if [ "${PIPESTATUS[0]}" != 0 ]; then exit 1; fi
  fi

  if [ -z "$DESTDIR" ]; then
    make check-installation
  fi

  # Parse build log for warnings that may indicate serious runtime issues
  if [ "$make" = "true" ]; then
    [ -f make.out ] && scripts/check_build_log.sh make.out
  fi

  # See whether any package failed to build
  ./packages/report-failed || exit 1
fi # setvars
