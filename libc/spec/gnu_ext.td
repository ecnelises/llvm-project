def CpuSetT : NamedType<"cpu_set_t">;
def CpuSetPtr : PtrType<CpuSetT>;
def ConstCpuSetPtr : ConstType<CpuSetPtr>;

def QSortRCompareT : NamedType<"__qsortrcompare_t">;
def StructHsearchData : NamedType<"struct hsearch_data">;
def StructHsearchDataPtr : PtrType<StructHsearchData>;

def GnuExtensions : StandardSpec<"GNUExtensions"> {
  NamedType CookieIOFunctionsT = NamedType<"cookie_io_functions_t">;
  HeaderSpec CType = HeaderSpec<
    "ctype.h",
    [], // Macros
    [], // Types
    [], // Enumerations
    [
        FunctionSpec<
            "toascii",
            RetValSpec<IntType>,
            [ArgSpec<IntType>]
        >,
    ]
  >;

  HeaderSpec Malloc = HeaderSpec<
      "malloc.h",
      [], // Macros
      [], // Types
      [], // Enumerations
      [
          FunctionSpec<"mallopt", RetValSpec<IntType>, [ArgSpec<IntType>, ArgSpec<IntType>]>,
      ]
  >;

  HeaderSpec Math = HeaderSpec<
      "math.h",
      [], // Macros
      [], // Types
      [], // Enumerations
      [
        FunctionSpec<
            "sincosf",
            RetValSpec<VoidType>,
            [ArgSpec<FloatType>, ArgSpec<FloatPtr>, ArgSpec<FloatPtr>]
        >,
        FunctionSpec<
            "lgamma_r",
            RetValSpec<DoubleType>,
            [ArgSpec<DoubleType>, ArgSpec<IntPtr>]
        >,
        FunctionSpec<
            "lgammaf_r",
            RetValSpec<FloatType>,
            [ArgSpec<FloatType>, ArgSpec<IntPtr>]
        >,
        FunctionSpec<
            "lgammal_r",
            RetValSpec<LongDoubleType>,
            [ArgSpec<LongDoubleType>, ArgSpec<IntPtr>]
        >,
      ]
  >;

  HeaderSpec Sched = HeaderSpec<
      "sched.h",
      [], // Macros
      [PidT, SizeTType, CpuSetT], // Types
      [], // Enumerations
      [
        FunctionSpec<
            "sched_getaffinity",
            RetValSpec<IntType>,
            [ArgSpec<PidT>, ArgSpec<SizeTType>, ArgSpec<CpuSetPtr>]
        >,
        FunctionSpec<
            "sched_setaffinity",
            RetValSpec<IntType>,
            [ArgSpec<PidT>, ArgSpec<SizeTType>, ArgSpec<ConstCpuSetPtr>]
        >,
      ]
  >;
  HeaderSpec String = HeaderSpec<
      "string.h",
      [], // Macros
      [], // Types
      [], // Enumerations
      [
         FunctionSpec<
            "memmem",
            RetValSpec<VoidPtr>,
            [ArgSpec<ConstVoidPtr>, ArgSpec<SizeTType>, ArgSpec<ConstVoidPtr>, ArgSpec<SizeTType>]
        >,
        FunctionSpec<
            "memrchr",
            RetValSpec<VoidPtr>,
            [ArgSpec<ConstVoidPtr>, ArgSpec<IntType>, ArgSpec<SizeTType>]
        >,
        FunctionSpec<
            "strerror_r",
            RetValSpec<CharPtr>,
            [ArgSpec<IntType>, ArgSpec<CharPtr>, ArgSpec<SizeTType>]
        >,
        FunctionSpec<
            "strcasestr",
            RetValSpec<CharPtr>,
            [ArgSpec<ConstCharPtr>, ArgSpec<ConstCharPtr>]
        >,
        FunctionSpec<
            "strchrnul",
            RetValSpec<CharPtr>,
            [ArgSpec<ConstCharPtr>, ArgSpec<IntType>]
        >,
      ]
  >;

  HeaderSpec Search = HeaderSpec<
    "search.h",
    [], // Macros
    [
        StructHsearchData
    ],
    [], // Enumerations
    [
        FunctionSpec<
            "hcreate_r",
            RetValSpec<IntType>,
            [
                ArgSpec<SizeTType>,
                ArgSpec<StructHsearchDataPtr>
            ]
        >,
        FunctionSpec<
            "hdestroy_r",
            RetValSpec<VoidType>,
            [
                ArgSpec<StructHsearchDataPtr>
            ]
        >,
        FunctionSpec<
            "hsearch_r",
            RetValSpec<IntType>,
            [
                ArgSpec<EntryType>,
                ArgSpec<ActionType>,
                ArgSpec<EntryTypePtrPtr>,
                ArgSpec<StructHsearchDataPtr>
            ]
        >,
    ]
  >;

  HeaderSpec FEnv = HeaderSpec<
      "fenv.h",
      [], // Macros
      [], // Types
      [], // Enumerations
      [
        FunctionSpec<
            "fedisableexcept",
            RetValSpec<IntType>,
            [ArgSpec<IntType>]
        >,
        FunctionSpec<
            "feenableexcept",
            RetValSpec<IntType>,
            [ArgSpec<IntType>]
        >,
        FunctionSpec<
            "fegetexcept",
            RetValSpec<IntType>,
            []
        >
      ]
  >;

  HeaderSpec StdIO = HeaderSpec<
      "stdio.h",
      [], // Macros
      [CookieIOFunctionsT], // Types
      [], // Enumerations
      [
          FunctionSpec<
              "clearerr_unlocked",
              RetValSpec<VoidType>,
              [ArgSpec<FILEPtr>]
          >,
          FunctionSpec<
              "feof_unlocked",
              RetValSpec<IntType>,
              [ArgSpec<FILEPtr>]
          >,
          FunctionSpec<
              "ferror_unlocked",
              RetValSpec<IntType>,
              [ArgSpec<FILEPtr>]
          >,
          FunctionSpec<
              "fopencookie",
              RetValSpec<FILEPtr>,
              [ArgSpec<VoidPtr>, ArgSpec<ConstCharPtr>, ArgSpec<CookieIOFunctionsT>]
          >,
          FunctionSpec<
              "fread_unlocked",
              RetValSpec<SizeTType>,
              [ArgSpec<VoidRestrictedPtr>,
               ArgSpec<SizeTType>,
               ArgSpec<SizeTType>,
               ArgSpec<FILERestrictedPtr>]
          >,
          FunctionSpec<
              "fwrite_unlocked",
              RetValSpec<SizeTType>,
              [ArgSpec<ConstVoidRestrictedPtr>,
               ArgSpec<SizeTType>,
               ArgSpec<SizeTType>,
               ArgSpec<FILERestrictedPtr>]
          >,
          FunctionSpec<
              "fgetc_unlocked",
              RetValSpec<IntType>,
              [ArgSpec<FILEPtr>]
          >,
      ]
  >;

  HeaderSpec StdLib = HeaderSpec<
      "stdlib.h",
      [], // Macros
      [QSortRCompareT], // Types
      [], // Enumerations
      [
          FunctionSpec<
                "qsort_r",
                RetValSpec<VoidType>,
                [ArgSpec<VoidPtr>, ArgSpec<SizeTType>, ArgSpec<SizeTType>, ArgSpec<QSortRCompareT>, ArgSpec<VoidPtr>]
          >,
      ]
  >;

  HeaderSpec PThread = HeaderSpec<
      "pthread.h",
      [], // Macros
      [], // Types
      [], // Enumerations
      [
          FunctionSpec<
              "pthread_setname_np",
              RetValSpec<IntType>,
              [ArgSpec<PThreadTType>, ArgSpec<ConstCharPtr>]
          >,
          FunctionSpec<
              "pthread_getname_np",
              RetValSpec<IntType>,
              [ArgSpec<PThreadTType>, ArgSpec<CharPtr>, ArgSpec<SizeTType>]
          >,
      ]
  >;

  HeaderSpec SysAuxv = HeaderSpec<
      "sys/auxv.h",
      [], // Macros
      [], // Types
      [], // Enumerations
      [
          FunctionSpec<
              "getauxval",
              RetValSpec<UnsignedLongType>,
              [ArgSpec<UnsignedLongType>]
          >,
      ]  // Functions
  >;

  HeaderSpec SendFile = HeaderSpec<
      "sys/sendfile.h",
      [], // Macros
      [OffTType, SizeTType, SSizeTType,], // Types
      [], // Enumerations
      [
          FunctionSpec<
              "sendfile",
              RetValSpec<SSizeTType>,
              [ArgSpec<IntType>, ArgSpec<IntType>, ArgSpec<OffTPtr>, ArgSpec<SizeTType>]
          >,
      ]
  >;

  HeaderSpec UniStd = HeaderSpec<
    "unistd.h",
    [], // Macros
    [], // Types
    [], // Enumerations
    [
        FunctionSpec<
            "dup2",
            RetValSpec<IntType>,
            [ArgSpec<IntType>, ArgSpec<IntType>, ArgSpec<IntType>]
        >,
    ]
  >;

  let Headers = [
    CType,
    FEnv,
    Malloc,
    Math,
    PThread,
    Sched,
    SendFile,
    SysAuxv,
    StdIO,
    StdLib,
    String,
    Search,
    UniStd,
  ];
}
