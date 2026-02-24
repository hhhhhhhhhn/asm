=== ASM ===
This repository contains:
- A compiler for a Forth-like programming language called North written in
  assembly (targetting assembly)
- A compiler for a C-like programming language called hlang written in North
  (targetting assembly)
- A simple software renderer written in hlang, showing a simple animation.

There are also miscellaneous library files including some utilities.

More information about this project is in the Paged Out! Issue #8
https://pagedout.institute/webview.php?issue=8&page=51

=== DEPENDENCIES ===
The only real dependency is the NASM assembler, and an operating system
compatible with Linux syscalls. The rendering program also uses the framebuffer
at /dev/fb0, and assuming a 1920x1080 resolution. You can change the variables
at the start of the main.hlang file to change this.

=== RUNNING THE CODE ===
Just use ./run.sh in the Linux framebuffer terminal and it should work.

=== FILES ===
Note that the file names are horrible and due for some refactoring.

./run.sh
    Compiles and executes everything, from scratch. Good starting point to
    understand the code

./lib.asm
    Auxiliar assembly functions used by the North compiler.

./north.asm
    The entrypoint and bulk of the North compiler.

./northlib.asm
    A "standard library" for the North programming language, including the most
    basic operations and builtins. Meant to be linked with the North programs.

./northlib2.north
    Second part of the North "standard library", this time written in North
    itself using parts of the northlib.asm

./hlang.north
    Entrypoint and bulk of the hlang compiler.

./hlib.asm
	The "standard library" of hlang, in great part copy and pasted from that of
	North.

./main.hlang
	The framebuffer renderer.
