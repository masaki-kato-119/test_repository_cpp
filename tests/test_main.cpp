#include <gtest/gtest.h>

// テスト対象関数の宣言
int add(int a, int b);

// テストケース
TEST(AddTest, HandlesPositiveInput) {
    EXPECT_EQ(add(1, 2), 3);
    EXPECT_EQ(add(0, 0), 0);
}

// main.cppの関数をリンクするために定義
int add(int a, int b) {
    return a + b;
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}