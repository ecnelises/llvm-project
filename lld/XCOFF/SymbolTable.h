//===- SymbolTable.h --------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLD_XCOFF_SYMBOL_TABLE_H
#define LLD_XCOFF_SYMBOL_TABLE_H

#include "Symbols.h"
#include "lld/Common/LLVM.h"
#include "llvm/ADT/CachedHashString.h"
#include "llvm/ADT/DenseSet.h"
#include <optional>

namespace lld::xcoff {

class InputSegment;

class SymbolTable {
public:
  void addFile(InputFile *file, StringRef symName = {});
  Symbol *find(StringRef name);
};

extern SymbolTable *symtab;

} // namespace lld::xcoff

#endif
