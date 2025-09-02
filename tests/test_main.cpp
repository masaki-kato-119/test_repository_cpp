#include <gtest/gtest.h>
#include "../src/add.h"

// テストケース
TEST(AddTest, HandlesPositiveInput) {
    EXPECT_EQ(add(1, 2), 3);
    EXPECT_EQ(add(0, 0), 0);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}