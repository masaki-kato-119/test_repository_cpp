# Makefile

CXX = g++
CXXFLAGS = -std=c++17 -Wall --coverage
TARGET = main
SRCS = src/main.cpp src/add.cpp
TEST_SRCS = tests/test_main.cpp src/add.cpp

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRCS)

test_main: tests/test_main.cpp
	$(CXX) $(CXXFLAGS) -isystem /usr/include/gtest -pthread $(TEST_SRCS) -lgtest -lgtest_main -o test_main
test: test_main
	./test_main

clean:
	rm -f $(TARGET) test_main *.gcda *.gcno *.gcov coverage.info