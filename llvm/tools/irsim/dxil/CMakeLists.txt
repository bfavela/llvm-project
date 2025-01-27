
set(LLVM_LINK_COMPONENTS
    Remarks)

add_llvm_library(LLVMdxil_impl
  SHARED
  INSTALL_WITH_TOOLCHAIN

  dxil_impl.cpp
)
