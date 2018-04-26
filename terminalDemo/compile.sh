#!/bin/bash

clang -framework Foundation test.m -o test
clang -framework Foundation test_d.m -o test_d
clang -framework Foundation test_c.m -o test_c

