//===- Writer.cpp ---------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Writer.h"
#include "Config.h"
#include "SymbolTable.h"
#include <cstdarg>
#include <map>
#include <optional>

#define DEBUG_TYPE "lld"

using namespace llvm;

namespace lld::xcoff {
namespace {
class Writer {
public:
  void run() {}
};
} // namespace

void writeResult() { Writer().run(); }
} // namespace lld::xcoff