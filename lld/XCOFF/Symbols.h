//===- Symbols.h ------------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLD_XCOFF_SYMBOLS_H
#define LLD_XCOFF_SYMBOLS_H

#include "Config.h"
#include "lld/Common/LLVM.h"
#include "llvm/Object/Archive.h"
#include <optional>

#define INVALID_INDEX UINT32_MAX

namespace lld {
namespace xcoff {
class InputChunk;

class Symbol {
public:
  enum Kind : uint8_t {
    DefinedFunctionKind,
    DefinedDataKind,
    DefinedGlobalKind,
    DefinedTagKind,
    DefinedTableKind,
    SectionKind,
    OutputSectionKind,
    UndefinedFunctionKind,
    UndefinedDataKind,
    UndefinedGlobalKind,
    UndefinedTableKind,
    UndefinedTagKind,
    LazyKind,
  };

  Kind kind() const { return symbolKind; }

  bool isDefined() const { return !isLazy() && !isUndefined(); }

  bool isUndefined() const {
    return symbolKind == UndefinedFunctionKind ||
           symbolKind == UndefinedDataKind ||
           symbolKind == UndefinedGlobalKind ||
           symbolKind == UndefinedTableKind || symbolKind == UndefinedTagKind;
  }

  bool isLazy() const { return symbolKind == LazyKind; }

  bool isLocal() const;
  bool isWeak() const;
  bool isHidden() const;
  bool isTLS() const;

  // True if this is an undefined weak symbol. This only works once
  // all input files have been added.
  bool isUndefWeak() const {
    // See comment on lazy symbols for details.
    return isWeak() && (isUndefined() || isLazy());
  }

  // Returns the symbol name.
  StringRef getName() const { return name; }

  // Returns the file from which this symbol was created.
  InputFile *getFile() const { return file; }

  InputChunk *getChunk() const;

  // Indicates that the section or import for this symbol will be included in
  // the final image.
  bool isLive() const;

  // Marks the symbol's InputChunk as Live, so that it will be included in the
  // final image.
  void markLive();

  // Get/set the index in the output symbol table.  This is only used for
  // relocatable output.
  uint32_t getOutputSymbolIndex() const;
  void setOutputSymbolIndex(uint32_t index);

  llvm::XCOFF::SymbolType getWasmType() const;
  bool isImported() const;
  bool isExported() const;
  bool isExportedExplicit() const;

  // Indicates that the symbol is used in an __attribute__((used)) directive
  // or similar.
  bool isNoStrip() const;

  const WasmSignature *getSignature() const;

  uint32_t getGOTIndex() const {
    assert(gotIndex != INVALID_INDEX);
    return gotIndex;
  }

  void setGOTIndex(uint32_t index);
  bool hasGOTIndex() const { return gotIndex != INVALID_INDEX; }

protected:
  Symbol(StringRef name, Kind k, uint32_t flags, InputFile *f)
      : name(name), file(f), symbolKind(k), referenced(!config->gcSections),
        requiresGOT(false), isUsedInRegularObj(false), forceExport(false),
        forceImport(false), canInline(false), traced(false), isStub(false),
        flags(flags) {}

  StringRef name;
  InputFile *file;
  uint32_t outputSymbolIndex = INVALID_INDEX;
  uint32_t gotIndex = INVALID_INDEX;
  Kind symbolKind;

public:
  bool referenced : 1;

  // True for data symbols that needs a dummy GOT entry.  Used for static
  // linking of GOT accesses.
  bool requiresGOT : 1;

  // True if the symbol was used for linking and thus need to be added to the
  // output file's symbol table. This is true for all symbols except for
  // unreferenced DSO symbols, lazy (archive) symbols, and bitcode symbols that
  // are unreferenced except by other bitcode objects.
  bool isUsedInRegularObj : 1;

  // True if this symbol is explicitly marked for export (i.e. via the
  // -e/--export command line flag)
  bool forceExport : 1;

  bool forceImport : 1;

  // False if LTO shouldn't inline whatever this symbol points to. If a symbol
  // is overwritten after LTO, LTO shouldn't inline the symbol because it
  // doesn't know the final contents of the symbol.
  bool canInline : 1;

  // True if this symbol is specified by --trace-symbol option.
  bool traced : 1;

  // True if this symbol is a linker-synthesized stub function (traps when
  // called) and should otherwise be treated as missing/undefined.  See
  // SymbolTable::replaceWithUndefined.
  // These stubs never appear in the table and any table index relocations
  // against them will produce address 0 (The table index representing
  // the null function pointer).
  bool isStub : 1;

  uint32_t flags;

  std::optional<StringRef> importName;
  std::optional<StringRef> importModule;
};

// The default module name to use for symbol imports.
extern const char *defaultModule;
extern const char *functionTableName;
extern const char *memoryName;

class InputFile;
class InputChunk;
class InputSegment;
class InputFunction;
class InputGlobal;
class InputTag;
class InputSection;
class InputTable;
class OutputSection;

} // namespace xcoff
} // namespace lld

#endif
