# Makefile for "writer" application

# Compiler settings
CC := ${CROSS_COMPILE}gcc
CFLAGS := -Wall -Wextra

# Default target: build the "writer" application
writer: writer.o
	$(CC) $(CFLAGS) -o $@ $^

# Clean target: remove "writer" application and .o files
clean:
	rm -f writer writer.o

.PHONY: clean
