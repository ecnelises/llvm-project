//===- SymbolTable.cpp ----------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "SymbolTable.h"
#include "Config.h"
#include "InputFiles.h"
#include "lld/Common/CommonLinkerContext.h"

#define DEBUG_TYPE "lld"

using namespace llvm;
using namespace llvm::object;

namespace lld::xcoff {
SymbolTable *symtab;

void SymbolTable::addFile(InputFile *file, StringRef symName) {
  log("Processing: " + toString(file));

  // Lazy object file
  if (file->lazy) {
    if (auto *f = dyn_cast<BitcodeFile>(file)) {
      f->parseLazy();
    } else {
      cast<ObjFile>(file)->parseLazy();
    }
    return;
  }

  // .so file
  if (auto *f = dyn_cast<SharedFile>(file)) {
    ctx.sharedFiles.push_back(f);
    return;
  }

  // stub file
  if (auto *f = dyn_cast<StubFile>(file)) {
    f->parse();
    ctx.stubFiles.push_back(f);
    return;
  }

  if (config->trace)
    message(toString(file));

  // LLVM bitcode file
  if (auto *f = dyn_cast<BitcodeFile>(file)) {
    // This order, first adding to `bitcodeFiles` and then parsing is necessary.
    // See https://github.com/llvm/llvm-project/pull/73095
    ctx.bitcodeFiles.push_back(f);
    f->parse(symName);
    return;
  }

  // Regular object file
  auto *f = cast<ObjFile>(file);
  f->parse();
  ctx.objectFiles.push_back(f);
}

Symbol *SymbolTable::find(StringRef name) { return nullptr; }
} // namespace lld::xcoff
