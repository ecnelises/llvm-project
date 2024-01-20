//===- InputFiles.cpp -----------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "InputFiles.h"
#include "Config.h"
#include "SymbolTable.h"
#include "lld/Common/Args.h"
#include "lld/Common/CommonLinkerContext.h"
#include "lld/Common/Reproduce.h"
#include "llvm/Object/Binary.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/TarWriter.h"
#include "llvm/Support/raw_ostream.h"
#include <optional>

#define DEBUG_TYPE "lld"

using namespace llvm;
using namespace llvm::object;
using namespace llvm::sys;

namespace {
bool isUndefined(const XCOFFSymbolRef &sym) {
  return sym.getSectionNumber() == XCOFF::N_UNDEF;
}

bool isDefined(const XCOFFSymbolRef &sym) {
  return !isUndefined(sym);
}
} // namespace

namespace lld {

std::string toString(const xcoff::InputFile *file) {
  if (!file)
    return "<internal>";

  return "";
}

namespace xcoff {

void InputFile::checkArch(Triple::ArchType arch) const {
  bool is64 = arch == Triple::ppc64;
  if (is64 && !config->is64) {
    fatal(toString(this) +
          ": must specify -b64 to process XCOFF64 object files");
  } else if (config->is64.value_or(false) != is64) {
    fatal(toString(this) +
          ": XCOFF32 object file can't be linked in XCOFF64 mode");
  }
}

ObjFile::ObjFile(MemoryBufferRef m, StringRef archiveName, bool lazy) : InputFile(ObjectKind, m) {
  this->lazy = lazy;
  this->archiveName = std::string(archiveName);

  if (archiveName.empty())
    markLive();

  std::unique_ptr<Binary> bin = CHECK(createBinary(mb), toString(this));

  auto *obj = dyn_cast<XCOFFObjectFile>(bin.get());
  if (!obj)
    fatal(toString(this) + ": not a XCOFF file");
  if (!obj->isRelocatableObject())
    fatal(toString(this) + ": not a relocatable XCOFF file");

  bin.release();
  xcoffObj.reset(obj);

  checkArch(obj->getArch());
}

Symbol *ObjFile::createDefined(const XCOFFSymbolRef &sym) {
  return nullptr;
}

void ObjFile::parse() {
  LLVM_DEBUG(dbgs() << "ObjFile::parse: " << toString(this) << "\n");
  for (const SymbolRef &sym : xcoffObj->symbols()) {
    XCOFFSymbolRef symRef(sym.getRawDataRefImpl(), xcoffObj.get());
    if (isDefined(symRef)) {
      if (Symbol *d = createDefined(symRef)) {
        symbols.push_back(d);
        continue;
      }
    }
  }
}

void ObjFile::parseLazy() {}

void BitcodeFile::parse(StringRef symName) {}

void BitcodeFile::parseLazy() {}

void StubFile::parse() {}

std::unique_ptr<llvm::TarWriter> tar;

StringRef strip(StringRef s) { return s.trim(' '); }

bool BitcodeFile::doneLTO = false;

} // namespace xcoff
} // namespace lld
