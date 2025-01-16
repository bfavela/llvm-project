set(LLVM_LINK_COMPONENTS
  AllTargetsAsmParsers
  AllTargetsCodeGens
  AllTargetsDescs
  AllTargetsInfos
  Analysis
  BitWriter
  CodeGen
  Extensions
  Core
  IPO
  IRReader
  Passes
  AggressiveInstCombine
  InstCombine
  Instrumentation
  Linker
  ObjCARCOpts
  ScalarOpts
  Support
  Target
  TargetParser
  TransformUtils
  Vectorize

  ExecutionEngine
  IRReader
  OrcJIT
  nativecodegen
  )

add_llvm_tool(irsim
  IRSIM.cpp

  DEPENDS
  intrinsics_gen
  SUPPORT_PLUGINS
  )

export_executable_symbols_for_plugins(irsim)
