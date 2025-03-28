; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -S --mtriple=loongarch64 --mattr=+d,+lamcas %s | FileCheck %s --check-prefix=NO-EXPAND
; RUN: opt -S --mtriple=loongarch64 --passes=atomic-expand --mattr=+d,+lamcas %s | FileCheck %s --check-prefix=EXPAND

; When -mlamcas is enabled, all atomicrmw and/or/xor ptr %a,a i8/i16 %b ordering 
; will be expanded to am{and/or/xo}[_db].w by LoongArchTargetLowering::emitExpandAtomicRMW

define i8 @atomicrmw_and_i8_acquire(ptr %a, i8 %b) nounwind {
; NO-EXPAND-LABEL: define i8 @atomicrmw_and_i8_acquire(
; NO-EXPAND-SAME: ptr [[A:%.*]], i8 [[B:%.*]]) #[[ATTR0:[0-9]+]] {
; NO-EXPAND-NEXT:    [[TMP1:%.*]] = atomicrmw and ptr [[A]], i8 [[B]] acquire, align 1
; NO-EXPAND-NEXT:    ret i8 [[TMP1]]
;
; EXPAND-LABEL: define i8 @atomicrmw_and_i8_acquire(
; EXPAND-SAME: ptr [[A:%.*]], i8 [[B:%.*]]) #[[ATTR0:[0-9]+]] {
; EXPAND-NEXT:    [[ALIGNEDADDR:%.*]] = call ptr @llvm.ptrmask.p0.i64(ptr [[A]], i64 -4)
; EXPAND-NEXT:    [[TMP1:%.*]] = ptrtoint ptr [[A]] to i64
; EXPAND-NEXT:    [[PTRLSB:%.*]] = and i64 [[TMP1]], 3
; EXPAND-NEXT:    [[TMP2:%.*]] = shl i64 [[PTRLSB]], 3
; EXPAND-NEXT:    [[SHIFTAMT:%.*]] = trunc i64 [[TMP2]] to i32
; EXPAND-NEXT:    [[MASK:%.*]] = shl i32 255, [[SHIFTAMT]]
; EXPAND-NEXT:    [[INV_MASK:%.*]] = xor i32 [[MASK]], -1
; EXPAND-NEXT:    [[TMP3:%.*]] = zext i8 [[B]] to i32
; EXPAND-NEXT:    [[VALOPERAND_SHIFTED:%.*]] = shl i32 [[TMP3]], [[SHIFTAMT]]
; EXPAND-NEXT:    [[ANDOPERAND:%.*]] = or i32 [[VALOPERAND_SHIFTED]], [[INV_MASK]]
; EXPAND-NEXT:    [[TMP4:%.*]] = atomicrmw and ptr [[ALIGNEDADDR]], i32 [[ANDOPERAND]] acquire, align 4
; EXPAND-NEXT:    [[SHIFTED:%.*]] = lshr i32 [[TMP4]], [[SHIFTAMT]]
; EXPAND-NEXT:    [[EXTRACTED:%.*]] = trunc i32 [[SHIFTED]] to i8
; EXPAND-NEXT:    ret i8 [[EXTRACTED]]
;
  %1 = atomicrmw and ptr %a, i8 %b acquire
  ret i8 %1
}

define i16 @atomicrmw_and_i16_acquire(ptr %a, i16 %b) nounwind {
; NO-EXPAND-LABEL: define i16 @atomicrmw_and_i16_acquire(
; NO-EXPAND-SAME: ptr [[A:%.*]], i16 [[B:%.*]]) #[[ATTR0]] {
; NO-EXPAND-NEXT:    [[TMP1:%.*]] = atomicrmw and ptr [[A]], i16 [[B]] acquire, align 2
; NO-EXPAND-NEXT:    ret i16 [[TMP1]]
;
; EXPAND-LABEL: define i16 @atomicrmw_and_i16_acquire(
; EXPAND-SAME: ptr [[A:%.*]], i16 [[B:%.*]]) #[[ATTR0]] {
; EXPAND-NEXT:    [[ALIGNEDADDR:%.*]] = call ptr @llvm.ptrmask.p0.i64(ptr [[A]], i64 -4)
; EXPAND-NEXT:    [[TMP1:%.*]] = ptrtoint ptr [[A]] to i64
; EXPAND-NEXT:    [[PTRLSB:%.*]] = and i64 [[TMP1]], 3
; EXPAND-NEXT:    [[TMP2:%.*]] = shl i64 [[PTRLSB]], 3
; EXPAND-NEXT:    [[SHIFTAMT:%.*]] = trunc i64 [[TMP2]] to i32
; EXPAND-NEXT:    [[MASK:%.*]] = shl i32 65535, [[SHIFTAMT]]
; EXPAND-NEXT:    [[INV_MASK:%.*]] = xor i32 [[MASK]], -1
; EXPAND-NEXT:    [[TMP3:%.*]] = zext i16 [[B]] to i32
; EXPAND-NEXT:    [[VALOPERAND_SHIFTED:%.*]] = shl i32 [[TMP3]], [[SHIFTAMT]]
; EXPAND-NEXT:    [[ANDOPERAND:%.*]] = or i32 [[VALOPERAND_SHIFTED]], [[INV_MASK]]
; EXPAND-NEXT:    [[TMP4:%.*]] = atomicrmw and ptr [[ALIGNEDADDR]], i32 [[ANDOPERAND]] acquire, align 4
; EXPAND-NEXT:    [[SHIFTED:%.*]] = lshr i32 [[TMP4]], [[SHIFTAMT]]
; EXPAND-NEXT:    [[EXTRACTED:%.*]] = trunc i32 [[SHIFTED]] to i16
; EXPAND-NEXT:    ret i16 [[EXTRACTED]]
;
  %1 = atomicrmw and ptr %a, i16 %b acquire
  ret i16 %1

}

define i8 @atomicrmw_or_i8_acquire(ptr %a, i8 %b) nounwind {
; NO-EXPAND-LABEL: define i8 @atomicrmw_or_i8_acquire(
; NO-EXPAND-SAME: ptr [[A:%.*]], i8 [[B:%.*]]) #[[ATTR0]] {
; NO-EXPAND-NEXT:    [[TMP1:%.*]] = atomicrmw or ptr [[A]], i8 [[B]] acquire, align 1
; NO-EXPAND-NEXT:    ret i8 [[TMP1]]
;
; EXPAND-LABEL: define i8 @atomicrmw_or_i8_acquire(
; EXPAND-SAME: ptr [[A:%.*]], i8 [[B:%.*]]) #[[ATTR0]] {
; EXPAND-NEXT:    [[ALIGNEDADDR:%.*]] = call ptr @llvm.ptrmask.p0.i64(ptr [[A]], i64 -4)
; EXPAND-NEXT:    [[TMP1:%.*]] = ptrtoint ptr [[A]] to i64
; EXPAND-NEXT:    [[PTRLSB:%.*]] = and i64 [[TMP1]], 3
; EXPAND-NEXT:    [[TMP2:%.*]] = shl i64 [[PTRLSB]], 3
; EXPAND-NEXT:    [[SHIFTAMT:%.*]] = trunc i64 [[TMP2]] to i32
; EXPAND-NEXT:    [[MASK:%.*]] = shl i32 255, [[SHIFTAMT]]
; EXPAND-NEXT:    [[INV_MASK:%.*]] = xor i32 [[MASK]], -1
; EXPAND-NEXT:    [[TMP3:%.*]] = zext i8 [[B]] to i32
; EXPAND-NEXT:    [[VALOPERAND_SHIFTED:%.*]] = shl i32 [[TMP3]], [[SHIFTAMT]]
; EXPAND-NEXT:    [[TMP4:%.*]] = atomicrmw or ptr [[ALIGNEDADDR]], i32 [[VALOPERAND_SHIFTED]] acquire, align 4
; EXPAND-NEXT:    [[SHIFTED:%.*]] = lshr i32 [[TMP4]], [[SHIFTAMT]]
; EXPAND-NEXT:    [[EXTRACTED:%.*]] = trunc i32 [[SHIFTED]] to i8
; EXPAND-NEXT:    ret i8 [[EXTRACTED]]
;
  %1 = atomicrmw or ptr %a, i8 %b acquire
  ret i8 %1
}

define i16 @atomicrmw_or_i16_acquire(ptr %a, i16 %b) nounwind {
; NO-EXPAND-LABEL: define i16 @atomicrmw_or_i16_acquire(
; NO-EXPAND-SAME: ptr [[A:%.*]], i16 [[B:%.*]]) #[[ATTR0]] {
; NO-EXPAND-NEXT:    [[TMP1:%.*]] = atomicrmw or ptr [[A]], i16 [[B]] acquire, align 2
; NO-EXPAND-NEXT:    ret i16 [[TMP1]]
;
; EXPAND-LABEL: define i16 @atomicrmw_or_i16_acquire(
; EXPAND-SAME: ptr [[A:%.*]], i16 [[B:%.*]]) #[[ATTR0]] {
; EXPAND-NEXT:    [[ALIGNEDADDR:%.*]] = call ptr @llvm.ptrmask.p0.i64(ptr [[A]], i64 -4)
; EXPAND-NEXT:    [[TMP1:%.*]] = ptrtoint ptr [[A]] to i64
; EXPAND-NEXT:    [[PTRLSB:%.*]] = and i64 [[TMP1]], 3
; EXPAND-NEXT:    [[TMP2:%.*]] = shl i64 [[PTRLSB]], 3
; EXPAND-NEXT:    [[SHIFTAMT:%.*]] = trunc i64 [[TMP2]] to i32
; EXPAND-NEXT:    [[MASK:%.*]] = shl i32 65535, [[SHIFTAMT]]
; EXPAND-NEXT:    [[INV_MASK:%.*]] = xor i32 [[MASK]], -1
; EXPAND-NEXT:    [[TMP3:%.*]] = zext i16 [[B]] to i32
; EXPAND-NEXT:    [[VALOPERAND_SHIFTED:%.*]] = shl i32 [[TMP3]], [[SHIFTAMT]]
; EXPAND-NEXT:    [[TMP4:%.*]] = atomicrmw or ptr [[ALIGNEDADDR]], i32 [[VALOPERAND_SHIFTED]] acquire, align 4
; EXPAND-NEXT:    [[SHIFTED:%.*]] = lshr i32 [[TMP4]], [[SHIFTAMT]]
; EXPAND-NEXT:    [[EXTRACTED:%.*]] = trunc i32 [[SHIFTED]] to i16
; EXPAND-NEXT:    ret i16 [[EXTRACTED]]
;
  %1 = atomicrmw or ptr %a, i16 %b acquire
  ret i16 %1
}

define i8 @atomicrmw_xor_i8_acquire(ptr %a, i8 %b) nounwind {
; NO-EXPAND-LABEL: define i8 @atomicrmw_xor_i8_acquire(
; NO-EXPAND-SAME: ptr [[A:%.*]], i8 [[B:%.*]]) #[[ATTR0]] {
; NO-EXPAND-NEXT:    [[TMP1:%.*]] = atomicrmw xor ptr [[A]], i8 [[B]] acquire, align 1
; NO-EXPAND-NEXT:    ret i8 [[TMP1]]
;
; EXPAND-LABEL: define i8 @atomicrmw_xor_i8_acquire(
; EXPAND-SAME: ptr [[A:%.*]], i8 [[B:%.*]]) #[[ATTR0]] {
; EXPAND-NEXT:    [[ALIGNEDADDR:%.*]] = call ptr @llvm.ptrmask.p0.i64(ptr [[A]], i64 -4)
; EXPAND-NEXT:    [[TMP1:%.*]] = ptrtoint ptr [[A]] to i64
; EXPAND-NEXT:    [[PTRLSB:%.*]] = and i64 [[TMP1]], 3
; EXPAND-NEXT:    [[TMP2:%.*]] = shl i64 [[PTRLSB]], 3
; EXPAND-NEXT:    [[SHIFTAMT:%.*]] = trunc i64 [[TMP2]] to i32
; EXPAND-NEXT:    [[MASK:%.*]] = shl i32 255, [[SHIFTAMT]]
; EXPAND-NEXT:    [[INV_MASK:%.*]] = xor i32 [[MASK]], -1
; EXPAND-NEXT:    [[TMP3:%.*]] = zext i8 [[B]] to i32
; EXPAND-NEXT:    [[VALOPERAND_SHIFTED:%.*]] = shl i32 [[TMP3]], [[SHIFTAMT]]
; EXPAND-NEXT:    [[TMP4:%.*]] = atomicrmw xor ptr [[ALIGNEDADDR]], i32 [[VALOPERAND_SHIFTED]] acquire, align 4
; EXPAND-NEXT:    [[SHIFTED:%.*]] = lshr i32 [[TMP4]], [[SHIFTAMT]]
; EXPAND-NEXT:    [[EXTRACTED:%.*]] = trunc i32 [[SHIFTED]] to i8
; EXPAND-NEXT:    ret i8 [[EXTRACTED]]
;
  %1 = atomicrmw xor ptr %a, i8 %b acquire
  ret i8 %1
}

define i16 @atomicrmw_xor_i16_acquire(ptr %a, i16 %b) nounwind {
; NO-EXPAND-LABEL: define i16 @atomicrmw_xor_i16_acquire(
; NO-EXPAND-SAME: ptr [[A:%.*]], i16 [[B:%.*]]) #[[ATTR0]] {
; NO-EXPAND-NEXT:    [[TMP1:%.*]] = atomicrmw xor ptr [[A]], i16 [[B]] acquire, align 2
; NO-EXPAND-NEXT:    ret i16 [[TMP1]]
;
; EXPAND-LABEL: define i16 @atomicrmw_xor_i16_acquire(
; EXPAND-SAME: ptr [[A:%.*]], i16 [[B:%.*]]) #[[ATTR0]] {
; EXPAND-NEXT:    [[ALIGNEDADDR:%.*]] = call ptr @llvm.ptrmask.p0.i64(ptr [[A]], i64 -4)
; EXPAND-NEXT:    [[TMP1:%.*]] = ptrtoint ptr [[A]] to i64
; EXPAND-NEXT:    [[PTRLSB:%.*]] = and i64 [[TMP1]], 3
; EXPAND-NEXT:    [[TMP2:%.*]] = shl i64 [[PTRLSB]], 3
; EXPAND-NEXT:    [[SHIFTAMT:%.*]] = trunc i64 [[TMP2]] to i32
; EXPAND-NEXT:    [[MASK:%.*]] = shl i32 65535, [[SHIFTAMT]]
; EXPAND-NEXT:    [[INV_MASK:%.*]] = xor i32 [[MASK]], -1
; EXPAND-NEXT:    [[TMP3:%.*]] = zext i16 [[B]] to i32
; EXPAND-NEXT:    [[VALOPERAND_SHIFTED:%.*]] = shl i32 [[TMP3]], [[SHIFTAMT]]
; EXPAND-NEXT:    [[TMP4:%.*]] = atomicrmw xor ptr [[ALIGNEDADDR]], i32 [[VALOPERAND_SHIFTED]] acquire, align 4
; EXPAND-NEXT:    [[SHIFTED:%.*]] = lshr i32 [[TMP4]], [[SHIFTAMT]]
; EXPAND-NEXT:    [[EXTRACTED:%.*]] = trunc i32 [[SHIFTED]] to i16
; EXPAND-NEXT:    ret i16 [[EXTRACTED]]
;
  %1 = atomicrmw xor ptr %a, i16 %b acquire
  ret i16 %1
}
