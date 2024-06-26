; RUN: opt -passes=print-alias-sets -S -o - < %s 2>&1 | FileCheck %s --implicit-check-not="Unknown instructions"

; CHECK: Alias sets for function 'test1':
; CHECK: Alias Set Tracker: 2 alias sets for 2 pointer values.
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Memory locations: (ptr %a, LocationSize::precise(1))
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Memory locations: (ptr %b, LocationSize::precise(1))
define void @test1(i32 %c) {
entry:
  %a = alloca i8, align 1
  %b = alloca i8, align 1
  store i8 1, ptr %a, align 1
  %cond1 = icmp ne i32 %c, 0
  call void @llvm.assume(i1 %cond1)
  store i8 1, ptr %b, align 1
  ret void
}

; CHECK: Alias sets for function 'test2':
; CHECK: Alias Set Tracker: 3 alias sets for 2 pointer values.
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Memory locations: (ptr %a, LocationSize::precise(1))
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] may alias, Ref
; CHECK:     1 Unknown instructions:   call void (i1, ...) @llvm.experimental.guard(i1 %cond1) [ "deopt"() ]
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Memory locations: (ptr %b, LocationSize::precise(1))
define void @test2(i32 %c) {
entry:
  %a = alloca i8, align 1
  %b = alloca i8, align 1
  store i8 1, ptr %a, align 1
  %cond1 = icmp ne i32 %c, 0
  call void (i1, ...) @llvm.experimental.guard(i1 %cond1)["deopt"()]
  store i8 1, ptr %b, align 1
  ret void
}

; CHECK: Alias sets for function 'test3':
; CHECK: Alias Set Tracker: 1 alias sets for 2 pointer values.
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 3] may alias, Mod/Ref   Memory locations: (ptr %a, LocationSize::precise(1)), (ptr %b, LocationSize::precise(1))
; CHECK:     1 Unknown instructions:   call void (i1, ...) @llvm.experimental.guard(i1 %cond1) [ "deopt"() ]
define void @test3(i32 %c, ptr %a, ptr %b) {
entry:
  store i8 1, ptr %a, align 1
  %cond1 = icmp ne i32 %c, 0
  call void (i1, ...) @llvm.experimental.guard(i1 %cond1)["deopt"()]
  store i8 1, ptr %b, align 1
  ret void
}

; CHECK: Alias sets for function 'test4':
; CHECK: Alias Set Tracker: 2 alias sets for 2 pointer values.
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 2] may alias, Mod/Ref   Memory locations: (ptr %a, LocationSize::precise(1))
; CHECK:     1 Unknown instructions:   call void (i1, ...) @llvm.experimental.guard(i1 %cond1) [ "deopt"() ]
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Memory locations: (ptr %b, LocationSize::precise(1))
define void @test4(i32 %c, ptr %a) {
entry:
  %b = alloca i8, align 1
  store i8 1, ptr %a, align 1
  %cond1 = icmp ne i32 %c, 0
  call void (i1, ...) @llvm.experimental.guard(i1 %cond1)["deopt"()]
  store i8 1, ptr %b, align 1
  ret void
}

; CHECK: Alias sets for function 'test5':
; CHECK: Alias Set Tracker: 2 alias sets for 2 pointer values.
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Memory locations: (ptr %a, LocationSize::precise(1))
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Memory locations: (ptr %b, LocationSize::precise(1))
define void @test5() {
entry:
  %a = alloca i8, align 1
  %b = alloca i8, align 1
  store i8 1, ptr %a, align 1
  call void @llvm.experimental.noalias.scope.decl(metadata !0)
  store i8 1, ptr %b, align 1
  ret void
}

; CHECK: Alias sets for function 'test_runtime':
; CHECK: Alias Set Tracker: 2 alias sets for 2 pointer values.
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Memory locations: (ptr %a, LocationSize::precise(1))
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Memory locations: (ptr %b, LocationSize::precise(1))
define i1 @test_runtime() local_unnamed_addr {
entry:
  %a = alloca i8, align 1
  %b = alloca i8, align 1
  store i8 1, ptr %a, align 1
  %allow = call i1 @llvm.allow.runtime.check(metadata !"test_check")
  store i8 1, ptr %b, align 1
  ret i1 %allow
}

; CHECK: Alias sets for function 'test_ubsan':
; CHECK: Alias Set Tracker: 2 alias sets for 2 pointer values.
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Memory locations: (ptr %a, LocationSize::precise(1))
; CHECK:   AliasSet[0x{{[0-9a-f]+}}, 1] must alias, Mod       Memory locations: (ptr %b, LocationSize::precise(1))
define i1 @test_ubsan() local_unnamed_addr {
entry:
  %a = alloca i8, align 1
  %b = alloca i8, align 1
  store i8 1, ptr %a, align 1
  %allow = call i1 @llvm.allow.ubsan.check(i8 7)
  store i8 1, ptr %b, align 1
  ret i1 %allow
}

declare i1 @llvm.allow.ubsan.check(i8)
declare i1 @llvm.allow.runtime.check(metadata)
declare void @llvm.assume(i1)
declare void @llvm.experimental.guard(i1, ...)
declare void @llvm.experimental.noalias.scope.decl(metadata)

!0 = !{ !1 }
!1 = distinct !{ !1, !2, !"test5: var" }
!2 = distinct !{ !2, !"test5" }
