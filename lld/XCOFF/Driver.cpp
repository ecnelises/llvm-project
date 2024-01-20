//===- Driver.cpp ---------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//===----------------------------------------------------------------------===//

#include "Driver.h"
#include "Config.h"
#include "InputFiles.h"
#include "SymbolTable.h"
#include "Writer.h"
#include "lld/Common/Args.h"
#include "lld/Common/CommonLinkerContext.h"
#include "lld/Common/Driver.h"
#include "lld/Common/ErrorHandler.h"
#include "lld/Common/Filesystem.h"
#include "lld/Common/Memory.h"
#include "lld/Common/Version.h"
#include "llvm/Object/IRObjectFile.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/TarWriter.h"
#include "llvm/Support/TargetSelect.h"

using namespace llvm;
using namespace llvm::object;
using namespace llvm::opt;
using namespace llvm::sys;
using namespace llvm::support;
using namespace lld;
using namespace lld::xcoff;

namespace lld {
namespace xcoff {
Configuration *config;
Ctx ctx;

namespace {
enum {
  OPT_INVALID = 0,
#define OPTION(...) LLVM_MAKE_OPT_ID(__VA_ARGS__),
#include "Options.inc"

#undef OPTION
};

class LinkerDriver {
public:
  void linkerMain(ArrayRef<const char *> args);

private:
  void createFiles(opt::InputArgList &args);
  void addFile(StringRef path);
  void addLibrary(StringRef name);
  std::vector<InputFile *> files;
};

#define PREFIX(NAME, VALUE)                                                    \
  static constexpr StringLiteral NAME##_init[] = VALUE;                        \
  static constexpr ArrayRef<StringLiteral> NAME(NAME##_init,                   \
                                                std::size(NAME##_init) - 1);
#include "Options.inc"
#undef PREFIX

static constexpr opt::OptTable::Info optInfo[] = {
#define OPTION(PREFIX, NAME, ID, KIND, GROUP, ALIAS, ALIASARGS, FLAGS,         \
               VISIBILITY, PARAM, HELPTEXT, METAVAR, VALUES)                   \
  {PREFIX,      NAME,        HELPTEXT,                                         \
   METAVAR,     OPT_##ID,    opt::Option::KIND##Class,                         \
   PARAM,       FLAGS,       VISIBILITY,                                       \
   OPT_##GROUP, OPT_##ALIAS, ALIASARGS,                                        \
   VALUES},
#include "Options.inc"

#undef OPTION
};

class XCOFFOptTable : public opt::GenericOptTable {
public:
  XCOFFOptTable() : opt::GenericOptTable(optInfo) {}
  opt::InputArgList parse(ArrayRef<const char *> argv);
};
} // namespace

opt::InputArgList XCOFFOptTable::parse(ArrayRef<const char *> argv) {
  SmallVector<const char *, 256> vec(argv.data(), argv.data() + argv.size());

  unsigned missingIndex;
  unsigned missingCount;

  // We need to get the quoting style for response files before parsing all
  // options so we parse here before and ignore all the options but
  // --rsp-quoting.
  opt::InputArgList args = this->ParseArgs(vec, missingIndex, missingCount);

  // Expand response files (arguments in the form of @<filename>)
  // and then parse the argument again.
  cl::ExpandResponseFiles(saver(), cl::TokenizeGNUCommandLine, vec);
  args = this->ParseArgs(vec, missingIndex, missingCount);

  // handleColorDiagnostics(args);
  if (missingCount)
    error(Twine(args.getArgString(missingIndex)) + ": missing argument");

  for (auto *arg : args.filtered(OPT_UNKNOWN))
    error("unknown argument: " + arg->getAsString(args));
  return args;
}

bool link(ArrayRef<const char *> args, llvm::raw_ostream &stdoutOS,
          llvm::raw_ostream &stderrOS, bool exitEarly, bool disableOutput) {
  // This driver-specific context will be freed later by unsafeLldMain().
  auto *ctx = new CommonLinkerContext;

  ctx->e.initialize(stdoutOS, stderrOS, exitEarly, disableOutput);
  ctx->e.logName = args::getFilenameWithoutExe(args[0]);
  ctx->e.errorLimitExceededMsg = "too many errors emitted, stopping now (use "
                                 "-error-limit=0 to see all errors)";

  config = make<Configuration>();
  symtab = make<SymbolTable>();

  InitializeAllTargets();
  InitializeAllTargetMCs();
  InitializeAllAsmPrinters();
  InitializeAllAsmParsers();
  LinkerDriver().linkerMain(args);

  return errorCount() == 0;
}

static void checkZOptions(opt::InputArgList &args) {}

static const char *getReproduceOption(opt::InputArgList &args) {
  // if (auto *arg = args.getLastArg(OPT_reproduce))
  //   return arg->getValue();
  return getenv("LLD_REPRODUCE");
}

static std::string createResponseFile(const opt::InputArgList &args) {
  SmallString<0> data;
  raw_svector_ostream os(data);

  // Copy the command line to the output while rewriting paths.
  for (auto *arg : args) {
    switch (arg->getOption().getID()) {
    // case OPT_reproduce:
    //   break;
    case OPT_INPUT:
      // TODO
    // case OPT_o:
    //   // TODO
    default:
      // os << toString(*arg) << "\n";
      break;
    }
  }
  return std::string(data.str());
}

static void checkOptions(opt::InputArgList &args) {}

static void readConfigs(opt::InputArgList &args) {
  {
    auto *arg = args.getLastArg(OPT_e);
    if (!arg)
      config->entry = "";
    else
      config->entry = arg->getValue();
  }
}

static void setConfigs() {}

static void readImportFile(StringRef filename) {}

void LinkerDriver::addFile(StringRef path) {}

void LinkerDriver::addLibrary(StringRef name) {}

void LinkerDriver::createFiles(opt::InputArgList &args) {
  for (auto *arg : args) {
    switch (arg->getOption().getID()) {
    // case OPT_library:
    //   addLibrary(arg->getValue());
    //   break;
    case OPT_INPUT:
      addFile(arg->getValue());
      break;
    case OPT_dn:
      config->isStatic = true;
      break;
    case OPT_dy:
      config->isStatic = false;
      break;
    }
  }
  if (files.empty() && errorCount() == 0)
    error("no input files");
}

void LinkerDriver::linkerMain(ArrayRef<const char *> argsArr) {
  XCOFFOptTable parser;
  opt::InputArgList args = parser.parse(argsArr.slice(1));

  // errorHandler().errorLimit = args::getInteger(args, OPT_error_limit, 20);
  // errorHandler().fatalWarnings =
  //     args.hasFlag(OPT_fatal_warnings, OPT_no_fatal_warnings, false);
  // checkZOptions(args);

  // if (args.hasArg(OPT_help)) {
  //   parser.printHelp(lld::outs(),
  //                    (std::string(argsArr[0]) + " [options]
  //                    file...").c_str(), "LLVM Linker", false);
  //   return;
  // }

  if (args.hasArg(OPT_V)) {
    lld::outs() << getLLDVersion() << "\n";
    return;
  }

  readConfigs(args);
  setConfigs();

  createFiles(args);
  if (errorCount())
    return;

  checkOptions(args);
  if (errorCount())
    return;

  Symbol *entrySym = nullptr;
  if (!config->relocatable && !config->entry.empty()) {
    entrySym = symtab->find(config->entry);
    if (entrySym && entrySym->isDefined())
      entrySym->forceExport = true;
    else
      error("entry symbol not defined (pass --no-entry to suppress): " +
            config->entry);
  }

  // if (auto *arg = args.getLastArg(OPT_allow_undefined_file))
  //   readImportFile(arg->getValue());

  if (auto e = tryCreateFile(config->outputFile))
    error("cannot open output file " + config->outputFile + ": " + e.message());
  if (auto e = tryCreateFile(config->mapFile))
    error("cannot open map file " + config->mapFile + ": " + e.message());
  if (errorCount())
    return;

  for (InputFile *f : files)
    symtab->addFile(f);
  if (errorCount())
    return;

  for (auto &iter : config->exportedSymbols) {
    Symbol *sym = symtab->find(iter.first());
    if (sym && sym->isDefined())
      sym->forceExport = true;
  }

  if (errorCount())
    return;

  writeResult();
}
} // namespace xcoff
} // namespace lld
