# Progetto-Compilatori

The final project for the compiler is in the directory `/compiler`.</br>
To execute use the following commands:
```
bison -d compiler.y
flex scanner.fl
gcc compiler.tab.c lex.yy.c
```
