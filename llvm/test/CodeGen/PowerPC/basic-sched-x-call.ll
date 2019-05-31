; RUN: llc -misched-x-call -ignore-call-boundary -verify-machineinstrs < %s | FileCheck %s

;target datalayout = "E-m:e-i64:64-n32:64"
target triple = "powerpc64le-unknown-linux-gnu"

define dso_local void @foo() #0 {
entry:
  ret void
}

define dso_local signext i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  store i32 2, i32* %a, align 4
  call void @foo()
  %0 = load i32, i32* %a, align 4
  %mul = mul nsw i32 %0, 18
  store i32 %mul, i32* %b, align 4
  ret i32 0
}

; CHECK: main
; CHECK: lwz {{[0-9]+}}, {{[0-9]+}}({{[0-9]+}})
; CHECK: mulli {{[0-9]+}}, {{[0-9+]}}, {{[0-9]+}}
; CHECK: bl foo


attributes #0 = { noinline nounwind }
