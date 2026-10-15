<h1 align="center">SPAASM · ASCII Analyzer</h1>

<p align="center">
  <strong>Character statistics, written in x86-64 assembly.</strong>
</p>

<p align="center">
  Count digits, letters, and other ASCII characters with a native Linux command-line program.
</p>

<p align="center">
  <a href="#getting-started">Getting started</a> ·
  <a href="#usage">Usage</a> ·
  <a href="#development">Development</a> ·
  <a href="#limitations">Limitations</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/NASM-x86--64-3178C6?style=flat-square" alt="NASM · x86-64">
  <img src="https://img.shields.io/badge/Platform-Linux-FCC624?style=flat-square" alt="Platform: Linux">
  <img src="https://img.shields.io/badge/FIIT_STU-SPAASM-555555?style=flat-square" alt="FIIT STU · SPAASM">
  <img src="https://img.shields.io/badge/Assignment-1-555555?style=flat-square" alt="Assignment 1">
</p>

---

## Overview

This is the first assignment for the **SPAASM course at FIIT STU**. It uses **NASM and the Linux syscall interface** to analyze ASCII text without a C runtime.

| Feature | What you can do |
| :--- | :--- |
| Character counts | Count digits, lowercase letters, uppercase letters, and other characters. |
| Line statistics | Inspect each line and totals across input files. |
| Reverse order | Read line statistics from last to first with `-r`. |
| Pagination | Pause after every 10 lines with `-p`. |

## Getting started

Requires **Linux x86-64**, **NASM**, and **GNU ld** (Binutils). Run these commands from the repository root:

```sh
for unit in main lib data utils strlen analyze_line print_number; do
    nasm -f elf64 "$unit.asm" -o "$unit.o" || exit 1
done
ld main.o lib.o data.o analyze_line.o utils.o strlen.o print_number.o -o program

./program -h
```

## Usage

```sh
printf 'Ab1!\nz9\n' > /tmp/ascii-sample.txt
./program /tmp/ascii-sample.txt
```

```text
Line number #1: Digits = 1, small letters = 1, capital letters = 1, other = 1
Line number #2: Digits = 1, small letters = 1, capital letters = 0, other = 0

Total across all lines: Digits = 2, small letters = 2, capital letters = 1, other = 1
```

### Options

| Option | Behavior |
| :--- | :--- |
| `-h` | Print usage information |
| `-r` | Print line statistics in reverse order |
| `-p` | Pause after every 10 lines of output |

```sh
./program /tmp/ascii-sample.txt -r
./program first.txt second.txt -p
```

## Development

| File | Responsibility |
| :--- | :--- |
| [`main.asm`](main.asm) | Process entry point and top-level flow |
| [`lib.asm`](lib.asm) | Argument parsing, file processing, and result output |
| [`analyze_line.asm`](analyze_line.asm) | Character classification and per-line counters |
| [`print_number.asm`](print_number.asm) | Integer-to-text conversion and output |
| [`utils.asm`](utils.asm), [`strlen.asm`](strlen.asm) | Output helpers and string length |
| [`data.asm`](data.asm), [`macros.inc`](macros.inc) | Messages, constants, and formatting macros |

The implementation brings together register-level string processing, ELF64 object files, manual integer formatting, and the Linux syscall interface.

## Limitations

This is an educational ASCII text processor. Input uses LF (`\n`) line endings; Unicode character classification is outside its scope. The original assignment documents limits of 4,096 lines across input files and 4,095 characters per line. Use small ASCII files for demonstrations; these limits are not a guarantee of robust handling of oversized or malformed input.

## Author

**Kostiantyn Zaitsev · [@Gh0st3r0k](https://github.com/Gh0st3r0k)**

FIIT STU · SPAASM · Assignment 1 · Summer semester 2024/2025

AIS ID: 123101

Part of a pair of systems programming assignments. Continue with **[Socket Shell](https://github.com/Gh0st3r0k/FIIt-STU-SPAASM-Zadanie2)** to explore processes and TCP communication in C.
