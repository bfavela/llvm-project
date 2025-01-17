;
; Resource Bindings:
;
; Name                                 Type  Format         Dim      ID      HLSL Bind     Count
; ------------------------------ ---------- ------- ----------- ------- -------------- ---------
;
; ModuleID = '/app/example.hlsl'
source_filename = "/app/example.hlsl"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
;target datalayout = "e-m:e-p:32:32-i1:32-i8:8-i16:16-i32:32-i64:64-f16:16-f32:32-f64:64-n8:16:32:64"
target triple = "dxilv1.6-unknown-shadermodel6.6-compute"

%"class.hlsl::RWBuffer" = type { target("dx.TypedBuffer", <4 x i32>, 1, 0, 0) }
%dx.types.ResRet.i32 = type { i32, i32, i32, i32, i32 }
%dx.types.Handle = type { ptr }

@blarp = local_unnamed_addr global %"class.hlsl::RWBuffer" zeroinitializer, align 4, !dbg !0

; Function Attrs: noinline nounwind memory(readwrite, inaccessiblemem: none)
define i32 @foo_body() local_unnamed_addr #0 {
  %1 = call i32 @dx.op.threadId.i32(i32 93, i32 0)
  %2 = call i32 @dx.op.threadId.i32(i32 93, i32 1)
    #dbg_value(<3 x i32> poison, !50, !DIExpression(DW_OP_LLVM_fragment, 0, 96), !62)
    #dbg_value(ptr @blarp, !63, !DIExpression(), !68)
    #dbg_value(i32 %2, !66, !DIExpression(), !68)
  %3 = bitcast ptr @blarp to ptr, !dbg !68
  %4 = load target("dx.TypedBuffer", <4 x i32>, 1, 0, 0), ptr %3, align 4, !dbg !68
  %5 = call %dx.types.ResRet.i32 @dx.op.bufferLoad.i32(i32 68, ptr @blarp, i32 %2, i32 undef), !dbg !70
  %6 = extractvalue %dx.types.ResRet.i32 %5, 0, !dbg !70
  %7 = extractvalue %dx.types.ResRet.i32 %5, 1, !dbg !70
  %8 = extractvalue %dx.types.ResRet.i32 %5, 2, !dbg !70
  %9 = extractvalue %dx.types.ResRet.i32 %5, 3, !dbg !70
    #dbg_value(ptr @blarp, !63, !DIExpression(), !71)
    #dbg_value(i32 %1, !66, !DIExpression(), !71)
  call void @dx.op.bufferStore.i32(i32 69, ptr @blarp, i32 %1, i32 undef, i32 %6, i32 %7, i32 %8, i32 %9, i8 15), !dbg !73
  ret i32 %2
}

declare i32 @dx.op.threadId.i32(i32, i32)

declare %dx.types.ResRet.i32 @dx.op.bufferLoad.i32(i32, %dx.types.Handle, i32, i32)

declare void @dx.op.bufferStore.i32(i32, %dx.types.Handle, i32, i32, i32, i32, i32, i32, i8)

; uselistorder directives
uselistorder ptr @blarp, { 1, 2, 0 }
uselistorder i32 93, { 1, 0 }

attributes #0 = { noinline nounwind memory(readwrite, inaccessiblemem: none) }

!llvm.dbg.cu = !{!2}
!dx.valver = !{!38}
!llvm.ident = !{!39}
!dx.shaderModel = !{!40}
!dx.version = !{!41}
!dx.entryPoints = !{!42}
!llvm.module.flags = !{!45, !46, !47, !48, !49}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "blarp", scope: !2, file: !9, line: 2, type: !5, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_11, file: !3, producer: "clang version 20.0.0git (https://github.com/llvm/llvm-project.git a6aa9365f75c6f28c3d281c662dcdb6fb5222601)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, retainedTypes: !4, globals: !37, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "/app/example.hlsl", directory: "/app")
!4 = !{!5}
!5 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "RWBuffer<vector<int, 4> >", scope: !6, size: 32, flags: DIFlagTypePassByValue | DIFlagNonTrivial, elements: !7, templateParams: !35, identifier: "_ZTSN4hlsl8RWBufferIDv4_iEE")
!6 = !DINamespace(name: "hlsl", scope: null)
!7 = !{!8, !12, !16, !28, !32}
!8 = !DIDerivedType(tag: DW_TAG_member, name: "__handle", scope: !5, file: !9, line: 7, baseType: !10, size: 32)
!9 = !DIFile(filename: "example.hlsl", directory: "/app")
!10 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !11, size: 32)
!11 = !DICompositeType(tag: DW_TAG_structure_type, name: "__hlsl_resource_t", file: !3, flags: DIFlagFwdDecl)
!12 = !DISubprogram(name: "RWBuffer", scope: !5, file: !9, type: !13, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!13 = !DISubroutineType(types: !14)
!14 = !{null, !15}
!15 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !5, size: 32, flags: DIFlagArtificial | DIFlagObjectPointer)
!16 = !DISubprogram(name: "operator[]", linkageName: "_ZNK4hlsl8RWBufferIDv4_iEixEj", scope: !5, file: !9, type: !17, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!17 = !DISubroutineType(types: !18)
!18 = !{!19, !25, !27}
!19 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !20, size: 32)
!20 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !21)
!21 = !DICompositeType(tag: DW_TAG_array_type, baseType: !22, size: 128, flags: DIFlagVector, elements: !23)
!22 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!23 = !{!24}
!24 = !DISubrange(count: 4)
!25 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !26, size: 32, flags: DIFlagArtificial | DIFlagObjectPointer)
!26 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !5)
!27 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!28 = !DISubprogram(name: "operator[]", linkageName: "_ZN4hlsl8RWBufferIDv4_iEixEj", scope: !5, file: !9, type: !29, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!29 = !DISubroutineType(types: !30)
!30 = !{!31, !15, !27}
!31 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !21, size: 32)
!32 = !DISubprogram(name: "Load", linkageName: "_ZN4hlsl8RWBufferIDv4_iE4LoadEj", scope: !5, file: !9, type: !33, flags: DIFlagPublic | DIFlagPrototyped, spFlags: DISPFlagOptimized)
!33 = !DISubroutineType(types: !34)
!34 = !{!21, !15, !27}
!35 = !{!36}
!36 = !DITemplateTypeParameter(name: "element_type", type: !21)
!37 = !{!0}
!38 = !{i32 1, i32 8}
!39 = !{!"clang version 20.0.0git (https://github.com/llvm/llvm-project.git a6aa9365f75c6f28c3d281c662dcdb6fb5222601)"}
!40 = !{!"cs", i32 6, i32 6}
!41 = !{i32 1, i32 6}
!42 = !{ptr @foo_body, !"foo_body", null, null, !43}
!43 = !{i32 0, i64 8192, i32 4, !44}
!44 = !{i32 1, i32 1, i32 1}
!45 = !{i32 2, !"Dwarf Version", i32 4}
!46 = !{i32 2, !"Debug Info Version", i32 3}
!47 = !{i32 1, !"wchar_size", i32 4}
!48 = !{i32 2, !"frame-pointer", i32 2}
!49 = !{i32 2, !"debug-info-assignment-tracking", i1 true}
!50 = !DILocalVariable(name: "a", arg: 1, scope: !51, file: !9, line: 5, type: !54)
!51 = distinct !DISubprogram(name: "foo_body", linkageName: "_Z8foo_bodyDv3_j", scope: !9, file: !9, line: 5, type: !52, scopeLine: 5, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !61)
!52 = !DISubroutineType(types: !53)
!53 = !{null, !54}
!54 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint3", scope: !6, file: !55, line: 70, baseType: !56)
!55 = !DIFile(filename: "/opt/compiler-explorer/clang-trunk-20250110/lib/clang/20/include/hlsl/hlsl_basic_types.h", directory: "")
!56 = !DIDerivedType(tag: DW_TAG_typedef, name: "vector<unsigned int, 3>", scope: !6, file: !9, baseType: !57)
!57 = !DICompositeType(tag: DW_TAG_array_type, baseType: !58, size: 128, flags: DIFlagVector, elements: !59)
!58 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint", scope: !6, file: !55, line: 35, baseType: !27)
!59 = !{!60}
!60 = !DISubrange(count: 3)
!61 = !{!50}
!62 = !DILocation(line: 0, scope: !51)
!63 = !DILocalVariable(name: "this", arg: 1, scope: !64, type: !67, flags: DIFlagArtificial | DIFlagObjectPointer)
!64 = distinct !DISubprogram(name: "operator[]", linkageName: "_ZN4hlsl8RWBufferIDv4_iEixEj", scope: !5, file: !9, line: 7, type: !29, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, declaration: !28, retainedNodes: !65)
!65 = !{!63, !66}
!66 = !DILocalVariable(name: "Index", arg: 2, scope: !64, file: !9, type: !27)
!67 = !DIDerivedType(tag: DW_TAG_reference_type, baseType: !5, size: 32)
!68 = !DILocation(line: 0, scope: !64, inlinedAt: !69)
!69 = distinct !DILocation(line: 6, column: 18, scope: !51)
!70 = !DILocation(line: 6, column: 18, scope: !51)
!71 = !DILocation(line: 0, scope: !64, inlinedAt: !72)
!72 = distinct !DILocation(line: 6, column: 5, scope: !51)
!73 = !DILocation(line: 6, column: 16, scope: !51)