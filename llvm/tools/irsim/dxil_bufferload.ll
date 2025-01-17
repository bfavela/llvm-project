
%dx.types.Handle = type { ptr }
%dx.types.ResRet.i32 = type { i32, i32, i32, i32, i32 }

  define %dx.types.ResRet.i32 @dx_bufferload_body(i32 %op, %dx.types.Handle %ptr, i32 %a, i32 %b) {
  entry:
    %bar = call i32 (i32) @dx_bufferload_impl(i32 4)
    %foo = insertvalue %dx.types.ResRet.i32 poison, i32 %bar, 0
    ret %dx.types.ResRet.i32 %foo
  }

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

  define void @dx_bufferstore_body(i32 %op, %dx.types.Handle %ptr, i32 %a, i32 %b, i32 %c, i32 %d, i32 %e, i32 %f, i8 %index) {
  entry:
    %call = call i32 (ptr, ...) @printf(ptr noundef @.str, i32 noundef %c)
    ret void
  }


declare i32 @printf(ptr noundef, ...) #1
declare i32 @dx_bufferload_impl(i32) #2
