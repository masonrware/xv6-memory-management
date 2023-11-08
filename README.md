# xv6-memory-management

Codebase for Project 5 - XV6 memory management for CS 537 @ UW Madison.

### GROUP 61: Ben Brandl & Mason Ware

***

# Table of Contents
- [xv6-memory-management](#xv6-memory-management)
    - [GROUP 61: Ben Brandl \& Mason Ware](#group-61-ben-brandl--mason-ware)
- [Table of Contents](#table-of-contents)
- [Overview](#overview)

***

# Overview

Files we touched:

Aside form syscall files (`usys.S, user.h, etc...`), we modified the following files in our implementation
1. `sysfile.c`
2. `proc.c`
3. `proc.h`
4. `trap.c`

Moreover, we copied code from vm.c and pasted it raw into both `sysfile.c` and `proc.c`. Specifically, we copied the functions `mappages()` and `walkpgdir()`.

`mmap()` and `munmap()` are defined in `sysfile.c` (at the very bottom of the file). 

**WE DID NOT IMPLEMENT LAZY ALLOCATION**

## General Pipeline

When a user calls mmap, because we are not using lazy allocation, the memory allocation happens immediately. There are two main cases that mmap executed: one for MAP_FIXED and another otherwise. Both seek to identify a valid starting address and use that to map page chunks of the users requested memory. Moreover, both cases provide file-backed mapping, making use of the functions `fileread()` in `mmap()` and the corresponding `filewrite()` in `munmap()` to do the file-write-back execution.

We maintain a linkedlist of virtual memory areas (recordings of calls to mmap) for each process. These VMAs hold information (copies of the arguments passed to mmap) as well as the generated start and ending virtual addresses of the requests. 

Everything else that is performed is standard per the spec of this project. This implementation passes all tests and works as expected.
