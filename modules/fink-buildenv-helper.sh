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
# Source this script file within {Patch,Compile,Install,Test}Script in
# your .info file in order to set environment variables calculated for the 
# buildtime system.
#
# These variables can then be used for patch token replacement or in 
# shell conditionals, among other uses, without reinventing the wheel.
# Example 1: Provide the proper SDK location in a patch
#			 Patch any hardcoded SDK locations in the source tree and replace
#				with the string @SDK_PATH@.
#			 In PatchScript, replace the token with the variable containing the 
#			 	SDK location, and apply the patch:
#			 sed "s|@SDK_PATH@|$SDK_PATH|g" < %{PatchFile} | patch -p1
# Example 2: Use in a conditional to determine if a flag is needed
#			 if [ "$OSX_MAJOR_VERSION" >  "10.7" ]; then ...

set +v || :

# System version
export DARWIN_VERSION=`uname -r | cut -d. -f1-2`
export DARWIN_MAJOR_VERSION=`printenv DARWIN_VERSION | cut -d. -f1`
export DARWIN_MINOR_VERSION=`printenv DARWIN_VERSION | cut -d. -f2`

export OSX_VERSION=`sw_vers -productVersion`
export OSX_MAJOR_VERSION=`printenv OSX_VERSION | cut -d. -f1-2`

if [ x"$OSX_MAJOR_VERSION" != x"$MACOSX_DEPLOYMENT_TARGET" ]; then
	echo "OSX_MAJOR_VERSION is set to: $OSX_MAJOR_VERSION"
	echo "MACOSX_DEPLOYMENT_TARGET is set to: $MACOSX_DEPLOYMENT_TARGET"
	echo "Please fix this mismatch. Exiting..."
	exit 1
fi

# Xcode
if [ -x /usr/bin/xcodebuild ] && [ -x /usr/bin/xcode-select ]; then
	export XCODE_VERSION=`xcodebuild -version | head -n 1 | cut -f 2 -d ' '`
	export XCODE_PREFIX=`xcode-select -print-path`
	export SDK_PATH=`xcodebuild -version -sdk macosx${OSX_MAJOR_VERSION} | grep ^Path: | cut -d\  -f2`
	export SDK_VERSION=`xcodebuild -version -sdk macosx${OSX_MAJOR_VERSION} | grep ^SDKVersion: | cut -d\  -f2`
fi

# Do SDK_PATH and MACOSX_DEPLOYMENT_TARGET match?
if [ "$SDK_PATH" ] && [ x"$SDK_VERSION" != x"$MACOSX_DEPLOYMENT_TARGET" ]; then
	echo "SDK Version is: $SDK_VERSION"
	echo "MACOSX_DEPLOYMENT_TARGET is set to: $MACOSX_DEPLOYMENT_TARGET"
	echo "Please fix this mismatch. Exiting..."
	exit 1
fi

# Fink Settings
export FINK_PREFIX=@FINK_PREFIX@
export FINK_ARCH=@FINK_ARCH@

echo "--------------------"
echo "Common System Values"
echo "--------------------"
echo ""
echo "  FINK_PREFIX:          $FINK_PREFIX"
echo "  FINK_ARCH:            $FINK_ARCH"
echo ""
echo "System Determined Variables:"
echo ""
echo "  DARWIN_VERSION:           $DARWIN_VERSION"
echo "  DARWIN_MAJOR_VERSION:     $DARWIN_MAJOR_VERSION"
echo "  DARWIN_MINOR_VERSION:     $DARWIN_MINOR_VERSION"
echo "  MACOSX_DEPLOYMENT_TARGET: $MACOSX_DEPLOYMENT_TARGET"
echo "  OSX_VERSION:              $OSX_VERSION"
echo "  OSX_MAJOR_VERSION:        $OSX_MAJOR_VERSION"
echo "  XCODE_VERSION:            $XCODE_VERSION"
echo "  XCODE_PREFIX:             $XCODE_PREFIX"
echo "  SDK_PATH:                 $SDK_PATH"
echo "  SDK_VERSION :             $SDK_VERSION"
echo ""
