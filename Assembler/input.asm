// Simple loop that decrements a counter from 10 to 0
@10
D=A
@counter
M=D            // counter = 10

(LOOP)
  @counter
  D=M
  @END
  D;JEQ        // if counter == 0, jump to END
  @counter
  M=M-1        // counter = counter - 1
  @LOOP
  0;JMP        // go back to LOOP

(END)
  @END
  0;JMP        // infinite loop at END

