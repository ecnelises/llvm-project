include "llvm/Option/OptParser.td"

multiclass BB<string name, string help1, string help2> {
  def NAME: JoinedOrSeparate<["-b"], name>, HelpText<help1>;
  def no # NAME: JoinedOrSeparate<["-b"], "no" # name>, HelpText<help2>;
}

def dy: Flag<["-"], "dy">, HelpText<"Enable dynamic linking">;
def dn: Flag<["-"], "dn">, HelpText<"Disable dynamic linking">;
def D: JoinedOrSeparate<["-"], "D">, HelpText<"Starting address of data section">;
def e: JoinedOrSeparate<["-"], "e">, HelpText<"Name of entry point symbol">;
def f: JoinedOrSeparate<["-"], "f">, HelpText<"Input file list">;
def G: Flag<["-"], "G">, HelpText<"Enable use for runtime linker">;

def b32: Flag<["-"], "b32">, HelpText<"Specify 32-bit linking mode">;
def b64: Flag<["-"], "b64">, HelpText<"Specify 64-bit linking mode">;
def basis: Flag<["-"], "basis">, HelpText<"Processes all external symbols in mixed case">;
def bautoexp: Flag<["-"], "bautoexp">, HelpText<"Automatically exports some symbols from the output module">;

def O: JoinedOrSeparate<["-"], "O">, HelpText<"Optimize output file size">;

def V: Flag<["-"], "V">, HelpText<"Write version to stderr">;
