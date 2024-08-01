section .data
	sock_addr:
		dw 2
		dw 0x5000
      		dd 0x0100007f
      		dq 0
	msg db "HTTP/1.0 200 OK",13,10,13,10
	len equ $-msg

section .bss
	request: resb 256
	file_content: resb 1256
section .text

process_path:
	xor rax, rax
	xor rdx, rdx 
	xor rbx, rbx
	mov eax, request 
l1:
	cmp byte [eax], 0
	je el1 
	cmp byte [eax], 32
	je el1
continue_l1:
	inc eax
	jmp l1
el1:
	inc eax
	mov edx, eax
l2:
	cmp byte [edx], 0
	je el2 
	cmp byte [edx], 32
	je el2 
continue_l2:
	inc edx
	inc ebx
	jmp l2
el2:
	mov byte [eax+ebx], 0
	ret

global _start
_start:
;socket
	mov rax, 41
	mov rdi, 2
	mov rsi, 1
	mov rdx, 0
	syscall 

	mov r10, rax ;r10 = sock fd
;bind
	mov rdi, r10
   	mov rax, 49 
   	mov rsi, sock_addr
   	mov rdx, 16
   	syscall

;listen
	mov rax, 50
	mov rdi, r10
	mov rsi, 0
	syscall 


;accept
accept_request:
	mov rax, 43
	mov rdi, r10
	mov rsi, 0
	mov rdx, 0
	syscall

	mov r12, rax ;r12 = accept id
;fork
	mov rax, 57
	syscall 
	cmp rax, 0
	je serve_request
;close the connection if this is not a parent
	mov rax, 3
	mov rdi, r12
	syscall 
	jmp accept_request

serve_request:
;read the request
	mov rdi, r12
	mov rax, 0
	mov rsi, request
	mov rdx, 256
	syscall 


;process request
	call process_path
	;remember to remove this
	inc rax
	mov rdi, rax
	mov rax, 2
	mov rsi,0
	syscall
	
;read the response file
	mov rdi, rax
	mov rax, 0
	mov rsi, file_content
	mov rdx, 1256
	syscall
	mov rbx, rax

;close the file 
	mov rax, 3
	syscall 

;write the response
	mov rax, 1
	mov rdi, r12
	mov rsi, msg
	mov rdx, len
	syscall

;write the file file content
	mov rdx, rbx
	mov rax, 1 
	mov rdi, r12
	mov rsi, file_content 
	syscall
;close the connection
	mov rax, 3
	mov rdi, r12
	syscall

;exit
   	mov rax, 60
   	mov rdi, 0
   	syscall

