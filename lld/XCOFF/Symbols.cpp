//===- Symbols.cpp --------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Symbols.h"
#include "Driver.h"
#include "InputFiles.h"
#include "Writer.h"
#include "lld/Common/ErrorHandler.h"
#include "llvm/Demangle/Demangle.h"
#include "llvm/Support/Compiler.h"
#include <cstring>

using namespace llvm;
using namespace llvm::object;
using namespace llvm::XCOFF;
using namespace lld;
using namespace lld::xcoff;
