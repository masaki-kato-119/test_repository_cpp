CXX = g++
CXXFLAGS = -std=c++17 -Wall -I./src
SRC_DIR = src
OBJ_DIR = obj
TEST_DIR = tests

SRCS = $(wildcard $(SRC_DIR)/*.cpp)
OBJS = $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(SRCS))
TEST_SRCS = $(wildcard $(TEST_DIR)/*.cpp)
TEST_OBJS = $(patsubst $(TEST_DIR)/%.cpp,$(OBJ_DIR)/%.test.o,$(TEST_SRCS))

TARGET = main
TEST_TARGET = test_main

all: $(TARGET)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@

$(OBJ_DIR)/%.test.o: $(TEST_DIR)/%.cpp
	mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(TEST_TARGET): $(OBJS) $(TEST_OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@ -lgtest -lpthread

test: $(TEST_TARGET)
	./$(TEST_TARGET) --gtest_output=xml:test-results.xml

clean:
	rm -rf $(OBJ_DIR) *.o $(TARGET) $(TEST_TARGET) test-results.xml