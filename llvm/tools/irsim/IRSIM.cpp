//===--- LLJITWithLazyReexports.cpp - LLJIT example with custom laziness --===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// In this example we will use the lazy re-exports utility to lazily compile
// IR modules. We will do this in seven steps:
//
// 1. Create an LLJIT instance.
// 2. Install a transform so that we can see what is being compiled.
// 3. Create an indirect stubs manager and lazy call-through manager.
// 4. Add two modules that will be conditionally compiled, plus a main module.
// 5. Add lazy-rexports of the symbols in the conditionally compiled modules.
// 6. Dump the ExecutionSession state to see the symbol table prior to
//    executing any code.
// 7. Verify that only modules containing executed code are compiled.
//
//===----------------------------------------------------------------------===//

#include "llvm/ADT/StringMap.h"
#include "llvm/ExecutionEngine/JITLink/JITLinkMemoryManager.h"
#include "llvm/ExecutionEngine/Orc/LLJIT.h"
#include "llvm/ExecutionEngine/Orc/ObjectLinkingLayer.h"
#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ExecutionEngine/Orc/ThreadSafeModule.h"

#include "llvm/ADT/StringRef.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Error.h"
#include "llvm/Support/SourceMgr.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/Scalar.h"

using namespace llvm;

#define DEBUG_TYPE "dxil_parsing"

namespace llvm {
void initializeDxilParsingPass(PassRegistry &);
}

namespace {
  struct DxilParsing : public FunctionPass {
    const TargetTransformInfo *TTI;

    static char ID; // Pass identification, replacement for typeid
    DxilParsing() : FunctionPass(ID) {
      initializeDxilParsingPass(*PassRegistry::getPassRegistry());
    }

    void getAnalysisUsage(AnalysisUsage &AU) const override {}

    bool runOnFunction(Function &F) override;
  };
}

#include "llvm/IR/InstVisitor.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/InstIterator.h"
#include <iostream>
//#include ""


namespace {
class DxilVisitor : public InstVisitor<DxilVisitor> {
public:
  bool processFunction(Function &F) {
    for (auto &I : instructions(F)) {
      visit(I);
    }
    return true;
  }
  void visit(Instruction &I) {
    I.print(dbgs());
    std::cout << "\n";
    if (LoadInst *load = dyn_cast<LoadInst>(&I)) {
      printf("It's a load!\n");
      if (load->getType()->isTargetExtTy()) {
        load->mutateType(Type::getInt32Ty(I.getContext()));
      }
      load->print(dbgs());
      std::cout << "\n";
//      exit(0);
    }
  };
};
}

bool DxilParsing::runOnFunction(Function &F) {
  DxilVisitor V;
  return V.processFunction(F);
}

char DxilParsing::ID = 0;

INITIALIZE_PASS(DxilParsing, "DxilParsing",
                      "DXIL Parsing", false, false)

namespace llvm {
// Public interface to the TailCallElimination pass
FunctionPass *createDxilParsingPass() {
  return new DxilParsing();
}
}

using namespace llvm::orc;

ExitOnError ExitOnErr;

inline llvm::Error createSMDiagnosticError(llvm::SMDiagnostic &Diag) {
  using namespace llvm;
  std::string Msg;
  {
    raw_string_ostream OS(Msg);
    Diag.print("", OS);
  }
  return make_error<StringError>(std::move(Msg), inconvertibleErrorCode());
}
inline llvm::Expected<llvm::orc::ThreadSafeModule>
parseExampleModule(llvm::StringRef Source, llvm::StringRef Name) {
  using namespace llvm;
  auto Ctx = std::make_unique<LLVMContext>();
  SMDiagnostic Err;
  if (auto M = parseIR(MemoryBufferRef(Source, Name), Err, *Ctx))
    return orc::ThreadSafeModule(std::move(M), std::move(Ctx));

  return createSMDiagnosticError(Err);
}

inline llvm::Expected<llvm::orc::ThreadSafeModule>
parseExampleModuleFromFile(llvm::StringRef FileName) {
  using namespace llvm;
  auto Ctx = std::make_unique<LLVMContext>();
  SMDiagnostic Err;

  if (auto M = parseIRFile(FileName, Err, *Ctx))
    return orc::ThreadSafeModule(std::move(M), std::move(Ctx));

  return createSMDiagnosticError(Err);
}

// Example IR modules.
//
// Note that in the conditionally compiled modules, FooMod and BarMod, functions
// have been given an _body suffix. This is to ensure that their names do not
// clash with their lazy-reexports.
// For clients who do not wish to rename function bodies (e.g. because they want
// to re-use cached objects between static and JIT compiles) techniques exist to
// avoid renaming. See the lazy-reexports section of the ORCv2 design doc.

const llvm::StringRef FooMod =
    R"(
  define i32 @foo_body() {
  entry:
    ret i32 1
  }
)";

const llvm::StringRef TargetMod =
    R"(
  define i32 @target_body() {
  entry:
    ret i32 1
  }
)";

const llvm::StringRef BarMod =
    R"(
  define i32 @bar_body() {
  entry:
    ret i32 2
  }
)";

const llvm::StringRef ThreadIDMod =
    R"(
  define i32 @threadid_body(i32 %op, i32 %channel) {
  entry:
    ret i32 %channel
  }
)";

const llvm::StringRef MainMod =
    R"(

  define i32 @entry(i32 %argc) {
    %call = tail call i32 @foo() #2
    ret i32 %call
  }

  declare i32 @foo()
  declare i32 @bar()
)";

// A function object that creates a simple pass pipeline to apply to each
// module as it passes through the IRTransformLayer.
class MyOptimizationTransform {
public:
  MyOptimizationTransform() : PM(std::make_unique<legacy::PassManager>()) {
    PM->add(createTailCallEliminationPass());
    PM->add(createCFGSimplificationPass());
    PM->add(createDxilParsingPass());
  }

  Expected<ThreadSafeModule> operator()(ThreadSafeModule TSM,
                                        MaterializationResponsibility &R) {
    TSM.withModuleDo([this](Module &M) {
      dbgs() << "--- BEFORE OPTIMIZATION ---\n" << M << "\n";
      PM->run(M);
      dbgs() << "--- AFTER OPTIMIZATION ---\n" << M << "\n";
    });
    return std::move(TSM);
  }

//private:
  std::unique_ptr<legacy::PassManager> PM;
};


cl::list<std::string> InputArgv(cl::Positional,
                                cl::desc("<program arguments>..."));

int dx_bufferload_impl(int index)
{
  return index * 2;
}

const llvm::StringRef BufferLoadMod =
    R"(
  define i32 @dx_bufferload_body(i32 %op, %dx.types.Handle ptr, i32 %a, i32 %b) {
  entry:
    ret i32 dx_bufferload_impl(%index)
  }
)";

int main(int argc, char *argv[]) {
  // Initialize LLVM.
  InitLLVM X(argc, argv);

  InitializeNativeTarget();
  InitializeNativeTargetAsmPrinter();

  cl::ParseCommandLineOptions(argc, argv, "LLJITWithLazyReexports");
  ExitOnErr.setBanner(std::string(argv[0]) + ": ");

  // (1) Create LLJIT instance.
  auto J = ExitOnErr(LLJITBuilder().create());

  // (2) Install transform to optimize modules when they're materialized.
  J->getIRTransformLayer().setTransform(MyOptimizationTransform());

  // (2) Install transform to print modules as they are compiled:
  // J->getIRTransformLayer().setTransform(
  //     [](ThreadSafeModule TSM,
  //        const MaterializationResponsibility &R) -> Expected<ThreadSafeModule> {
  //       TSM.withModuleDo([](Module &M) { dbgs() << "---Compiling---\n" << M; });
  //       return std::move(TSM); // Not a redundant move: fix build on gcc-7.5
  //     });

  // (3) Create stubs and call-through managers:
  std::unique_ptr<IndirectStubsManager> ISM;
  {
    auto ISMBuilder =
        createLocalIndirectStubsManagerBuilder(J->getTargetTriple());
    if (!ISMBuilder())
      ExitOnErr(make_error<StringError>("Could not create stubs manager for " +
                                            J->getTargetTriple().str(),
                                        inconvertibleErrorCode()));
    ISM = ISMBuilder();
  }
  auto LCTM = ExitOnErr(createLocalLazyCallThroughManager(
      J->getTargetTriple(), J->getExecutionSession(), ExecutorAddr()));

  // (4) Add modules.
  ExitOnErr(J->addIRModule(
      ExitOnErr(parseExampleModuleFromFile(argv[1]))));
  ExitOnErr(J->addIRModule(ExitOnErr(parseExampleModule(BarMod, "bar-mod"))));
  ExitOnErr(J->addIRModule(ExitOnErr(parseExampleModule(MainMod, "main-mod"))));
  ExitOnErr(
      J->addIRModule(ExitOnErr(parseExampleModule(TargetMod, "target-mod"))));
  ExitOnErr(J->addIRModule(ExitOnErr(parseExampleModuleFromFile("dxil_bufferload.ll"))));
  ExitOnErr(J->addIRModule(
      ExitOnErr(parseExampleModule(ThreadIDMod, "threadid-mod"))));

  // (5) Add lazy reexports.
  MangleAndInterner Mangle(J->getExecutionSession(), J->getDataLayout());
  SymbolAliasMap ReExports(
      {{Mangle("dx.op.threadId.i32"),
        {Mangle("threadid_body"),
         JITSymbolFlags::Exported | JITSymbolFlags::Callable}},
      {Mangle("dx.op.bufferLoad.i32"),
       {Mangle("dx_bufferload_body"),
        JITSymbolFlags::Exported | JITSymbolFlags::Callable}},
      {Mangle("dx.op.bufferStore.i32"),
       {Mangle("dx_bufferstore_body"),
        JITSymbolFlags::Exported | JITSymbolFlags::Callable}},
       {Mangle("foo"),
        {Mangle("foo_body"),
         JITSymbolFlags::Exported | JITSymbolFlags::Callable}},
       {Mangle("bar"),
        {Mangle("bar_body"),
         JITSymbolFlags::Exported | JITSymbolFlags::Callable}},
      {Mangle("target"),
       {Mangle("target_body"),
        JITSymbolFlags::Exported | JITSymbolFlags::Callable}},
  }
  );
  ExitOnErr(J->getMainJITDylib().define(
      lazyReexports(*LCTM, *ISM, J->getMainJITDylib(), std::move(ReExports))));

  // (6) Dump the ExecutionSession state.
  dbgs() << "---Session state---\n";
  J->getExecutionSession().dump(dbgs());
  dbgs() << "\n";

  // (7) Execute the JIT'd main function and pass the example's command line
  // arguments unmodified. This should cause either ExampleMod1 or ExampleMod2
  // to be compiled, and either "1" or "2" returned depending on the number of
  // arguments passed.

  // Look up the JIT'd function, cast it to a function pointer, then call it.
  auto EntryAddr = ExitOnErr(J->lookup("entry"));
  auto *Entry = EntryAddr.toPtr<int(int)>();

  int Result = Entry(argc);
  outs() << "---Result---\n"
         << "entry(" << argc << ") = " << Result << "\n";

  return 0;
}
