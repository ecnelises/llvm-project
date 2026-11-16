//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// REQUIRES: linux
// UNSUPPORTED: no-random-device

// RUN: %{cxx} %{flags} %{compile_flags} -DTEST_GLIBC_MINOR=24 -fsyntax-only %s
// RUN: %{cxx} %{flags} %{compile_flags} -DTEST_GLIBC_MINOR=25 -fsyntax-only %s
// RUN: %{cxx} %{flags} %{compile_flags} -DTEST_GLIBC_MINOR=36 -fsyntax-only %s

// Changing the client's glibc version must not change the installed backend.
#include <__configuration/platform.h>

#undef _LIBCPP_GLIBC_PREREQ
#define _LIBCPP_GLIBC_PREREQ(major, minor) ((major) < 2 || ((major) == 2 && (minor) <= TEST_GLIBC_MINOR))

#include <__config>

#if defined(__BIONIC__) || _LIBCPP_RANDOM_DEVICE_USE_ARC4_RANDOM
#  if !defined(_LIBCPP_USING_ARC4_RANDOM)
#    error Expected the arc4random backend
#  endif
#elif _LIBCPP_RANDOM_DEVICE_USE_GETENTROPY
#  if !defined(_LIBCPP_USING_GETENTROPY)
#    error Expected the getentropy backend
#  endif
#else
#  if !defined(_LIBCPP_USING_DEV_RANDOM)
#    error Expected the file backend
#  endif
#endif

#if (defined(_LIBCPP_USING_ARC4_RANDOM) + defined(_LIBCPP_USING_GETENTROPY) + defined(_LIBCPP_USING_DEV_RANDOM)) != 1
#  error Expected exactly one random_device backend
#endif
