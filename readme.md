# 128-Bit Arithmetic Operations in x390 Assembly

## Overview

This project implements 128-bit signed arithmetic operations (addition, subtraction, multiplication, and division) in IBM x390 assembly language. The program reads three input lines per operation: a 128-bit signed number, an operator, and another 128-bit number. It continues processing until it receives 'q' as input.

## 🛠️ Implementation Details

### Number Representation
- Numbers are stored using two consecutive 64-bit iregisters (high and low parts)
- Uses two's complement representation for negative numbers

### Conversion Process
1. Input strings are converted to BCD (Binary-Coded Decimal) format
2. Sequential division by 2 converts BCD to binary
3. Output conversion uses division by 10¹⁹ to handle the 128-bit number efficiently

### Arithmetic Operations
- **Addition/Subtraction**: Implemented using standard operations with carry propagation between registers
- **Multiplication**: Uses four multiplications (low×low, high×low, low×high) while ignoring high×high (doesn't fit in 128 bits)
- **Division**: Implements long division algorithm with careful shifting between high and low registers

## Usage

The program accepts input in the following format:
128-bit number 1
operator (+, -, *, /)
128-bit number 2


Enter 'q' to quit the program.

## 📝 Requirements

- IBM x390 assembly environment
- Standard C library for I/O operations
- Compatible simulator for execution

## Contributors

- Mohammad Marandi
- Fatemeh Shafi'i
- Hosna Shah Heydari
- Aryana Zalnezhad

**Course Instructor**: Dr. Hossein Asadi  
**University**: Sharif University of Technology, Computer Engineering Department  
**Date**: February 2023

## Licence
This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).


