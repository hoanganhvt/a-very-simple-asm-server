# a-very-simple-asm-server
## Compile 
```bash
nasm -felf64 main.asm && ld main.o -o main
```
##Test request
```bash
127.0.0.1:80/index.html
```
