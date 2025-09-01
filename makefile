# Makefile

CXX = g++
CXXFLAGS = -std=c++17 -Wall
TARGET = main
SRCS = src/main.cpp

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRCS)

test: tests/test_main.cpp
	$(CXX) $(CXXFLAGS) -isystem /usr/include/gtest -pthread tests/test_main.cpp -lgtest -lgtest_main -o test_main
	./test_main

clean:
	rm -f $(TARGET) test_main