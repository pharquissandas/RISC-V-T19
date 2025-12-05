.text
.globl main

main:
    li x1, -1
    li x0, -1           # Try 2 different ways of writing to x0
    mv x0, x1
    mv a0, x0           # Pass x0 to a0 to check it is still 0
