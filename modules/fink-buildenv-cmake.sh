#!/bin/sh
# Copyright (c) 2013, Hanspeter Niederstrasser
# All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Usage:
# Source this script file within any of {Patch,Compile,Install,Test}Script
# in your .info file in order to set environment variables for use in a 
# cmake based build.
#
# The calculated variables are concatenated as -D defines in $CMAKE_ARGS.
# Then, you can run cmake like so:
#     cmake $CMAKE_ARGS .
# If you wish to unset a variable, simply undefine it:
#     cmake $FINK_CMAKE_ARGS -UCMAKE_VERBOSE_MAKEFILE .
#
# TODO:
# Set up a way to NOT include a variable in FINK_CMAKE_ARGS is passed from the
# command line: eg. . %p/sbin/fink-buildenv-cmake.sh --noset=CMAKE_INSTALL_PREFIX
# would neither define $CMAKE_INSTALL_PREFIX nor add it to $FINK_CMAKE_ARGS.

set +v || :

# Fink Settings
export FINK_PREFIX=@FINK_PREFIX@
export FINK_ARCH=@FINK_ARCH@

if [ -x $FINK_PREFIX/bin/cmake ]; then
	CMAKE_COMMAND=$FINK_PREFIX/bin/cmake
else
	echo "No cmake command was found."
	echo "Please make sure cmake is added to the BuildDepends for this package."
	echo "Exiting..."
	exit 1
fi

export CMAKE_VERBOSE_MAKEFILE=ON
export CMAKE_COLOR_MAKEFILE=ON
export CMAKE_BUILD_TYPE=Release
export CMAKE_INSTALL_PREFIX=$FINK_PREFIX
export CMAKE_INSTALL_NAME_DIR=${FINK_PREFIX}/lib
export CMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET

if [ "$SDK_PATH" != "" ]; then
	export CMAKE_OSX_SYSROOT=$SDK_PATH
else
	export CMAKE_OSX_SYSROOT=/
	export CMAKE_OSX_DEPLOYMENT_TARGET=""
fi	

export FINK_CMAKE_ARGS="-DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE} \
-DCMAKE_COLOR_MAKEFILE=${CMAKE_COLOR_MAKEFILE} \
-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \
-DCMAKE_INSTALL_NAME_DIR=${CMAKE_INSTALL_NAME_DIR} \
-DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT} \
-DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}"

echo "--------------------"
echo "Common System Values"
echo "--------------------"
echo ""
echo "  FINK_PREFIX:          $FINK_PREFIX"
echo "  FINK_ARCH:            $FINK_ARCH"
echo "  CMAKE_COMMAND:        $CMAKE_COMMAND"
echo ""
echo "Cmake Settings:"
echo ""
echo "  CMAKE_VERBOSE_MAKEFILE:      $CMAKE_VERBOSE_MAKEFILE"
echo "  CMAKE_COLOR_MAKEFILE:        $CMAKE_COLOR_MAKEFILE"
echo "  CMAKE_BUILD_TYPE:            $CMAKE_BUILD_TYPE"
echo "  CMAKE_INSTALL_PREFIX:        $CMAKE_INSTALL_PREFIX"
echo "  CMAKE_INSTALL_NAME_DIR:      $CMAKE_INSTALL_NAME_DIR"
echo "  CMAKE_OSX_SYSROOT:           $CMAKE_OSX_SYSROOT"
echo "  CMAKE_OSX_DEPLOYMENT_TARGET: $CMAKE_OSX_DEPLOYMENT_TARGET"
echo ""
