set(LLVM_TARGET_DEFINITIONS Options.td)
tablegen(LLVM Options.inc -gen-opt-parser-defs)
add_public_tablegen_target(XCOFFOptionsTableGen)

add_lld_library(lldXCOFF
  Driver.cpp
  InputFiles.cpp
  Symbols.cpp
  SymbolTable.cpp
  Writer.cpp

  LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  BinaryFormat
  Core
  Demangle
  LTO
  MC
  Object
  Option
  Passes
  Support
  TargetParser

  LINK_LIBS
  lldCommon

  DEPENDS
  XCOFFOptionsTableGen
  intrinsics_gen
  )
