# 16-Bit Hardware & Software Stack

A complete, working 16-bit computer architecture built entirely from the ground up, starting from basic logic gates. This repository contains the hardware description for the Hack CPU and a custom assembler written in OCaml to translate symbolic assembly into executable binary.

## Architecture Overview

*   **Hardware Layer (HDL):** Custom implementations of elementary logic gates, a fully functional Arithmetic Logic Unit (ALU), memory registers, and the central processing unit (CPU).
*   **Software Layer (OCaml):** A custom two-pass assembler that parses symbolic Hack assembly language, resolves memory addresses via a symbol table, and outputs 16-bit machine code.

## Tech Stack
*   **Hardware Description:** HDL
*   **Assembler:** OCaml

## Key Implementations
*   **ALU Design:** Computes arithmetic and logical operations in a single clock cycle.
*   **CPU Architecture:** Integrates the ALU, program counter, and A/D registers to execute the 16-bit instruction set.
*   **Two-Pass Assembly:** Efficiently handles forward references and variable allocations before generating the final binary file.

## How to Run the Assembler

Navigate to the assembler directory and compile the OCaml source:

    cd assembler
    ocamlopt -o assembler main.ml

Run the compiled executable against any Hack assembly file (.asm):

    ./assembler program.asm

This will output a program.hack file containing the translated 16-bit binary instructions.
