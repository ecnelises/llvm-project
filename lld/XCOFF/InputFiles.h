//===- InputFiles.h ---------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLD_XCOFF_INPUT_FILES_H
#define LLD_XCOFF_INPUT_FILES_H

#include "Symbols.h"
#include "lld/Common/LLVM.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/LTO/LTO.h"
#include "llvm/Object/XCOFFObjectFile.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/TargetParser/Triple.h"
#include <optional>
#include <vector>

namespace llvm {
class TarWriter;
}

namespace lld {
namespace xcoff {

class InputChunk;
class InputFunction;
class InputSegment;
class InputGlobal;
class InputTag;
class InputTable;
class InputSection;

extern std::unique_ptr<llvm::TarWriter> tar;

class InputFile {
public:
  enum Kind {
    ObjectKind,
    SharedKind,
    BitcodeKind,
    StubKind,
  };

  virtual ~InputFile() {}

  Kind kind() const { return fileKind; }

  StringRef getName() const { return mb.getBufferIdentifier(); }

  std::string archiveName;

  void markLive() { live = true; }
  bool isLive() const { return live; }

  // TODO(sbc): Use this to implement --start-lib/--end-lib.
  bool lazy = false;

protected:
  MemoryBufferRef mb;
  std::vector<Symbol *> symbols;
  InputFile(Kind k, MemoryBufferRef m)
    : mb(m), fileKind(k), live(!config->gcSections) {}

  void checkArch(llvm::Triple::ArchType arch) const;

private:
  const Kind fileKind;
  bool live;
};

class ObjFile : public InputFile {
public:
  ObjFile(MemoryBufferRef m, StringRef archiveName, bool lazy = false);
  static bool classof(const InputFile *f) { return f->kind() == ObjectKind; }

  void parse();
  void parseLazy();

  Symbol *createDefined(const llvm::object::XCOFFSymbolRef &sym);

  // Maps input type indices to output type indices
  std::vector<uint32_t> typeMap;
  std::vector<bool> typeIsUsed;
  // Maps function indices to table indices
  std::vector<uint32_t> tableEntries;
  std::vector<uint32_t> tableEntriesRel;
  std::vector<InputChunk *> segments;
  std::vector<InputFunction *> functions;
  std::vector<InputGlobal *> globals;
  std::vector<InputTag *> tags;
  std::vector<InputTable *> tables;
  std::vector<InputChunk *> customSections;
  llvm::DenseMap<uint32_t, InputChunk *> customSectionsByIndex;

private:
  std::unique_ptr<llvm::object::XCOFFObjectFile> xcoffObj;
};

// .so file.
class SharedFile : public InputFile {
public:
  // explicit SharedFile(MemoryBufferRef m) : InputFile(SharedKind, m) {}
  static bool classof(const InputFile *f) { return f->kind() == SharedKind; }
};

// .bc file
class BitcodeFile : public InputFile {
public:
  BitcodeFile(MemoryBufferRef m, StringRef archiveName,
              uint64_t offsetInArchive, bool lazy);
  static bool classof(const InputFile *f) { return f->kind() == BitcodeKind; }

  void parse(StringRef symName);
  void parseLazy();
  std::unique_ptr<llvm::lto::InputFile> obj;

  // Set to true once LTO is complete in order prevent further bitcode objects
  // being added.
  static bool doneLTO;
};

// Stub library (See docs/WebAssembly.rst)
class StubFile : public InputFile {
public:
  // explicit StubFile(MemoryBufferRef m) : InputFile(StubKind, m) {}

  static bool classof(const InputFile *f) { return f->kind() == StubKind; }

  void parse();

  llvm::DenseMap<StringRef, std::vector<StringRef>> symbolDependencies;
};

InputFile *createObjectFile(MemoryBufferRef mb, StringRef archiveName = "",
                            uint64_t offsetInArchive = 0, bool lazy = false);

// Opens a given file.
std::optional<MemoryBufferRef> readFile(StringRef path);
} // namespace xcoff

std::string toString(const xcoff::InputFile *file);

} // namespace lld

#endif
