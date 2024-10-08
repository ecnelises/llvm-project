//===-- Unittests for stdc_leading_zeros_ui -------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/__support/CPP/limits.h"
#include "src/stdbit/stdc_leading_zeros_ui.h"
#include "test/UnitTest/Test.h"
#include <stddef.h>

TEST(LlvmLibcStdcLeadingZerosUiTest, Zero) {
  EXPECT_EQ(LIBC_NAMESPACE::stdc_leading_zeros_ui(0U),
            static_cast<unsigned>(
                LIBC_NAMESPACE::cpp::numeric_limits<unsigned int>::digits));
}

TEST(LlvmLibcStdcLeadingZerosUiTest, OneHot) {
  for (unsigned i = 0U;
       i != LIBC_NAMESPACE::cpp::numeric_limits<unsigned int>::digits; ++i)
    EXPECT_EQ(LIBC_NAMESPACE::stdc_leading_zeros_ui(1U << i),
              LIBC_NAMESPACE::cpp::numeric_limits<unsigned int>::digits - i -
                  1);
}
