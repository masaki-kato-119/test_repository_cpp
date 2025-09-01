#include <iostream>

int add(int a, int b) {
    return a + b;
}

int main() {
    int total = add(1, 2);
    std::cout << "1 + 2 = " << total << std::endl;
    return 0;
}