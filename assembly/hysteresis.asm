0000000000401b4b <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&) [clone .cold.60]>:
  401b4b:	mov    0x88(%rsp),%rdi
  401b53:	vzeroupper 
  401b56:	callq  401770 <operator delete(void*)@plt>
  401b5b:	mov    %rbx,%rdi
  401b5e:	callq  401910 <_Unwind_Resume@plt>

0000000000401b78 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&) [clone .cold.62]>:
  401b78:	mov    0x88(%rsp),%rdi
  401b80:	vzeroupper 
  401b83:	callq  401770 <operator delete(void*)@plt>
  401b88:	mov    %rbx,%rdi
  401b8b:	callq  401910 <_Unwind_Resume@plt>

000000000040a6e0 <seed_mask_row(unsigned char const*, unsigned char*, int, int, unsigned long, std::vector<unsigned long, std::allocator<unsigned long> >&)>:
  40a6e0:	test   %ecx,%ecx
  40a6e2:	jle    40a85b <seed_mask_row(unsigned char const*, unsigned char*, int, int, unsigned long, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x17b>
  40a6e8:	push   %rbp
  40a6e9:	lea    -0x1(%rcx),%eax
  40a6ec:	shr    $0x5,%eax
  40a6ef:	mov    %rsp,%rbp
  40a6f2:	push   %r15
  40a6f4:	shl    $0x5,%rax
  40a6f8:	lea    0x21(%r8,%rax,1),%rax
  40a6fd:	push   %r14
  40a6ff:	movslq %edx,%r10
  40a702:	mov    %r10,%r11
  40a705:	push   %r13
  40a707:	mov    %r9,%r15
  40a70a:	neg    %r11
  40a70d:	push   %r12
  40a70f:	lea    (%rdi,%r10,1),%r14
  40a713:	mov    %rdi,%r12
  40a716:	push   %rbx
  40a717:	lea    0x1(%r8),%r13
  40a71b:	and    $0xffffffffffffffe0,%rsp
  40a71f:	sub    $0x40,%rsp
  40a723:	mov    %r8,0x10(%rsp)
  40a728:	mov    %rsi,0x18(%rsp)
  40a72d:	mov    %rax,0x20(%rsp)
  40a732:	nopw   0x0(%rax,%rax,1)
  40a738:	vmovdqu64 0x1(%r12),%ymm1
  40a743:	vmovdqu32 (%r14),%ymm3
  40a749:	vmovdqu32 0x1(%r14),%ymm4
  40a753:	vmovdqu32 (%r12),%ymm2
  40a75a:	vmovdqu32 (%r12,%r11,1),%ymm0
  40a761:	vmovdqu32 0x1(%r12,%r11,1),%ymm5
  40a76c:	vpternlogd $0xfe,0x2(%r12),%ymm1,%ymm2
  40a778:	vpternlogd $0xfe,0x2(%r14),%ymm4,%ymm3
  40a783:	vpternlogd $0xfe,0x2(%r12,%r11,1),%ymm5,%ymm0
  40a78f:	vpternlogd $0xfe,%ymm3,%ymm2,%ymm0
  40a796:	vpand  0x3c02(%rip),%ymm0,%ymm0        # 40e3a0 <__dso_handle+0x3b8>
  40a79e:	vpcmpeqb 0x3c1a(%rip),%ymm1,%ymm2        # 40e3c0 <__dso_handle+0x3d8>
  40a7a6:	vpcmpeqb 0x3bf2(%rip),%ymm0,%ymm0        # 40e3a0 <__dso_handle+0x3b8>
  40a7ae:	vpcmpeqb 0x3bea(%rip),%ymm1,%ymm1        # 40e3a0 <__dso_handle+0x3b8>
  40a7b6:	mov    0x18(%rsp),%rax
  40a7bb:	vpand  %ymm2,%ymm0,%ymm0
  40a7bf:	vpor   %ymm1,%ymm0,%ymm1
  40a7c3:	sub    0x10(%rsp),%rax
  40a7c8:	vpmovmskb %ymm0,%ebx
  40a7cc:	vmovdqu64 %ymm1,(%rax,%r13,1)
  40a7d3:	test   %ebx,%ebx
  40a7d5:	je     40a809 <seed_mask_row(unsigned char const*, unsigned char*, int, int, unsigned long, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x129>
  40a7d7:	nopw   0x0(%rax,%rax,1)
  40a7e0:	bsf    %ebx,%eax
  40a7e3:	cltq   
  40a7e5:	mov    0x8(%r15),%rsi
  40a7e9:	add    %r13,%rax
  40a7ec:	mov    %rax,0x38(%rsp)
  40a7f1:	cmp    0x10(%r15),%rsi
  40a7f5:	je     40a838 <seed_mask_row(unsigned char const*, unsigned char*, int, int, unsigned long, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x158>
  40a7f7:	mov    %rax,(%rsi)
  40a7fa:	add    $0x8,%rsi
  40a7fe:	lea    -0x1(%rbx),%eax
  40a801:	mov    %rsi,0x8(%r15)
  40a805:	and    %eax,%ebx
  40a807:	jne    40a7e0 <seed_mask_row(unsigned char const*, unsigned char*, int, int, unsigned long, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x100>
  40a809:	add    $0x20,%r13
  40a80d:	add    $0x20,%r12
  40a811:	add    $0x20,%r14
  40a815:	cmp    %r13,0x20(%rsp)
  40a81a:	jne    40a738 <seed_mask_row(unsigned char const*, unsigned char*, int, int, unsigned long, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x58>
  40a820:	vzeroupper 
  40a823:	lea    -0x28(%rbp),%rsp
  40a827:	pop    %rbx
  40a828:	pop    %r12
  40a82a:	pop    %r13
  40a82c:	pop    %r14
  40a82e:	pop    %r15
  40a830:	pop    %rbp
  40a831:	retq   
  40a832:	nopw   0x0(%rax,%rax,1)
  40a838:	lea    0x38(%rsp),%rdx
  40a83d:	mov    %r15,%rdi
  40a840:	mov    %r11,0x28(%rsp)
  40a845:	vzeroupper 
  40a848:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40a84d:	lea    -0x1(%rbx),%eax
  40a850:	and    %eax,%ebx
  40a852:	mov    0x28(%rsp),%r11
  40a857:	jne    40a7e0 <seed_mask_row(unsigned char const*, unsigned char*, int, int, unsigned long, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x100>
  40a859:	jmp    40a809 <seed_mask_row(unsigned char const*, unsigned char*, int, int, unsigned long, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x129>
  40a85b:	retq   
  40a85c:	nopl   0x0(%rax)

000000000040a860 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)>:
  40a860:	push   %r15
  40a862:	push   %r14
  40a864:	push   %r13
  40a866:	push   %r12
  40a868:	push   %rbp
  40a869:	push   %rbx
  40a86a:	sub    $0xe8,%rsp
  40a871:	mov    (%r8),%rax
  40a874:	mov    %edi,0x98(%rsp)
  40a87b:	mov    %esi,0x9c(%rsp)
  40a882:	mov    %rdx,0xa0(%rsp)
  40a88a:	mov    %rcx,0xa8(%rsp)
  40a892:	cmp    0x8(%r8),%rax
  40a896:	je     40a89c <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3c>
  40a898:	mov    %rax,0x8(%r8)
  40a89c:	test   %esi,%esi
  40a89e:	jle    40a9dd <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x17d>
  40a8a4:	test   %edi,%edi
  40a8a6:	jle    40a9dd <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x17d>
  40a8ac:	cmp    $0x2,%esi
  40a8af:	jle    40a8ba <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5a>
  40a8b1:	cmp    $0x21,%edi
  40a8b4:	jg     40b5d8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xd78>
  40a8ba:	movl   $0x0,0x4c(%rsp)
  40a8c2:	mov    $0x1,%ebp
  40a8c7:	mov    $0x4,%eax
  40a8cc:	mov    %edi,%r14d
  40a8cf:	mov    %edi,0x8(%rsp)
  40a8d3:	mov    %rax,%rdi
  40a8d6:	mov    %rdx,%rbx
  40a8d9:	mov    %r8,0x18(%rsp)
  40a8de:	mov    %rcx,0x20(%rsp)
  40a8e3:	mov    %esi,%r13d
  40a8e6:	callq  4017a0 <operator new(unsigned long)@plt>
  40a8eb:	mov    %rax,%rdi
  40a8ee:	lea    0x0(,%rbp,4),%rdx
  40a8f6:	xor    %esi,%esi
  40a8f8:	mov    %rax,0x88(%rsp)
  40a900:	callq  401720 <memset@plt>
  40a905:	movslq %r14d,%rax
  40a908:	mov    %rax,0x10(%rsp)
  40a90d:	lea    (%rbx,%rax,1),%r12
  40a911:	xor    %ebp,%ebp
  40a913:	jmp    40a928 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xc8>
  40a915:	nopl   (%rax)
  40a918:	inc    %rbp
  40a91b:	inc    %r12
  40a91e:	cmp    %ebp,0x8(%rsp)
  40a922:	jle    40aa10 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x1b0>
  40a928:	cmpb   $0x2,(%rbx,%rbp,1)
  40a92c:	sete   %al
  40a92f:	mov    0x20(%rsp),%rsi
  40a934:	neg    %eax
  40a936:	mov    %al,(%rsi,%rbp,1)
  40a939:	cmpb   $0x1,(%rbx,%rbp,1)
  40a93d:	jne    40a918 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40a93f:	lea    -0x1(%rbp),%edx
  40a942:	mov    0x8(%rsp),%ecx
  40a946:	cmp    $0xffffffff,%edx
  40a949:	sete   %al
  40a94c:	cmp    %edx,%ecx
  40a94e:	setle  %dl
  40a951:	or     %edx,%eax
  40a953:	lea    0x1(%rbp),%edx
  40a956:	cmp    %edx,%ecx
  40a958:	jle    40a9f0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x190>
  40a95e:	test   %al,%al
  40a960:	jne    40b510 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xcb0>
  40a966:	cmpb   $0x2,-0x1(%rbx,%rbp,1)
  40a96b:	je     40a998 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40a96d:	cmpb   $0x2,0x1(%rbx,%rbp,1)
  40a972:	je     40a998 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40a974:	cmp    $0x1,%r13d
  40a978:	jle    40a918 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40a97a:	cmpb   $0x2,-0x1(%r12)
  40a980:	je     40a998 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40a982:	cmpb   $0x2,(%r12)
  40a987:	je     40a998 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40a989:	cmpb   $0x2,0x1(%r12)
  40a98f:	jne    40a918 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40a991:	nopl   0x0(%rax)
  40a998:	mov    0x20(%rsp),%rax
  40a99d:	mov    %rbp,0xb0(%rsp)
  40a9a5:	movb   $0xff,(%rax,%rbp,1)
  40a9a9:	mov    0x18(%rsp),%rax
  40a9ae:	mov    0x8(%rax),%rsi
  40a9b2:	cmp    0x10(%rax),%rsi
  40a9b6:	je     40b6c8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xe68>
  40a9bc:	mov    %rbp,(%rsi)
  40a9bf:	add    $0x8,%rsi
  40a9c3:	mov    %rsi,0x8(%rax)
  40a9c7:	jmpq   40a918 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40a9cc:	nopl   0x0(%rax)
  40a9d0:	mov    0x88(%rsp),%rdi
  40a9d8:	callq  401770 <operator delete(void*)@plt>
  40a9dd:	add    $0xe8,%rsp
  40a9e4:	pop    %rbx
  40a9e5:	pop    %rbp
  40a9e6:	pop    %r12
  40a9e8:	pop    %r13
  40a9ea:	pop    %r14
  40a9ec:	pop    %r15
  40a9ee:	retq   
  40a9ef:	nop
  40a9f0:	test   %al,%al
  40a9f2:	je     40b570 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xd10>
  40a9f8:	cmp    $0x1,%r13d
  40a9fc:	jle    40a918 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40aa02:	cmpb   $0x2,(%r12)
  40aa07:	je     40a998 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40aa09:	nopl   0x0(%rax)
  40aa10:	lea    -0x1(%r13),%eax
  40aa14:	mov    %eax,0x6c(%rsp)
  40aa18:	cmp    $0x4,%eax
  40aa1b:	jle    40b6a0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xe40>
  40aa21:	mov    0x10(%rsp),%rdi
  40aa26:	mov    0x4c(%rsp),%eax
  40aa2a:	lea    0x0(,%rdi,4),%rsi
  40aa32:	lea    0x1(%rax),%edx
  40aa35:	mov    %rdi,%rax
  40aa38:	add    %rdx,%rax
  40aa3b:	add    %rbx,%rax
  40aa3e:	mov    %rax,0x60(%rsp)
  40aa43:	lea    -0x6(%r13),%eax
  40aa47:	and    $0xfffffffc,%eax
  40aa4a:	add    $0x5,%eax
  40aa4d:	mov    %edx,0x68(%rsp)
  40aa51:	mov    %rsi,0x78(%rsp)
  40aa56:	mov    %rdx,0x80(%rsp)
  40aa5e:	mov    %eax,0x38(%rsp)
  40aa62:	mov    %rdi,0x50(%rsp)
  40aa67:	movl   $0x1,0x48(%rsp)
  40aa6f:	cmpl   $0x1,0x8(%rsp)
  40aa74:	sete   0x77(%rsp)
  40aa79:	nopl   0x0(%rax)
  40aa80:	mov    0x50(%rsp),%rbp
  40aa85:	mov    $0x4,%r12d
  40aa8b:	nopl   0x0(%rax,%rax,1)
  40aa90:	mov    0x20(%rsp),%rax
  40aa95:	mov    0x18(%rsp),%r9
  40aa9a:	mov    0x4c(%rsp),%ecx
  40aa9e:	mov    0x8(%rsp),%edx
  40aaa2:	lea    (%rax,%rbp,1),%rsi
  40aaa6:	lea    (%rbx,%rbp,1),%rdi
  40aaaa:	mov    %rbp,%r8
  40aaad:	callq  40a6e0 <seed_mask_row(unsigned char const*, unsigned char*, int, int, unsigned long, std::vector<unsigned long, std::allocator<unsigned long> >&)>
  40aab2:	add    0x10(%rsp),%rbp
  40aab7:	dec    %r12d
  40aaba:	jne    40aa90 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x230>
  40aabc:	mov    0x48(%rsp),%eax
  40aac0:	mov    0x60(%rsp),%rdi
  40aac5:	lea    -0x1(%rax),%ecx
  40aac8:	lea    0x1(%rax),%esi
  40aacb:	mov    %ecx,0x30(%rsp)
  40aacf:	mov    %esi,0x28(%rsp)
  40aad3:	mov    %rdi,0x58(%rsp)
  40aad8:	mov    %eax,0x3c(%rsp)
  40aadc:	mov    0x50(%rsp),%r15
  40aae1:	nopl   0x0(%rax)
  40aae8:	cmpb   $0x2,(%rbx,%r15,1)
  40aaed:	sete   %al
  40aaf0:	mov    0x20(%rsp),%rcx
  40aaf5:	neg    %eax
  40aaf7:	mov    %al,(%rcx,%r15,1)
  40aafb:	cmpb   $0x1,(%rbx,%r15,1)
  40ab00:	je     40b1e0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x980>
  40ab06:	mov    0x68(%rsp),%edi
  40ab0a:	cmp    %edi,0x8(%rsp)
  40ab0e:	jle    40ad10 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x4b0>
  40ab14:	mov    0x10(%rsp),%rcx
  40ab19:	movslq 0x30(%rsp),%rbp
  40ab1e:	movslq 0x28(%rsp),%r14
  40ab23:	imul   %rcx,%rbp
  40ab27:	mov    0x80(%rsp),%rax
  40ab2f:	imul   %rcx,%r14
  40ab33:	add    %rax,%rbp
  40ab36:	lea    (%rbx,%rbp,1),%rcx
  40ab3a:	add    %rax,%r14
  40ab3d:	lea    (%r15,%rax,1),%r12
  40ab41:	add    %rbx,%r14
  40ab44:	mov    %rcx,0x40(%rsp)
  40ab49:	mov    0x58(%rsp),%rbp
  40ab4e:	mov    0x68(%rsp),%eax
  40ab52:	jmp    40ab74 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x314>
  40ab54:	nopl   0x0(%rax)
  40ab58:	mov    0x70(%rsp),%eax
  40ab5c:	inc    %r14
  40ab5f:	inc    %rbp
  40ab62:	incq   0x40(%rsp)
  40ab67:	inc    %r12
  40ab6a:	cmp    %eax,0x8(%rsp)
  40ab6e:	jle    40ad10 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x4b0>
  40ab74:	cmpb   $0x2,(%rbx,%r12,1)
  40ab79:	sete   %dl
  40ab7c:	mov    0x20(%rsp),%rsi
  40ab81:	neg    %edx
  40ab83:	mov    %dl,(%rsi,%r12,1)
  40ab87:	lea    0x1(%rax),%edi
  40ab8a:	mov    %edi,0x70(%rsp)
  40ab8e:	cmpb   $0x1,(%rbx,%r12,1)
  40ab93:	jne    40ab58 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2f8>
  40ab95:	mov    0x8(%rsp),%ecx
  40ab99:	cmp    %edi,%ecx
  40ab9b:	jle    40aca0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x440>
  40aba1:	cmp    %eax,%ecx
  40aba3:	jl     40ac50 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3f0>
  40aba9:	cmp    0x30(%rsp),%r13d
  40abae:	jle    40abd0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x370>
  40abb0:	mov    0x40(%rsp),%rax
  40abb5:	cmpb   $0x2,-0x1(%rax)
  40abb9:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40abbb:	cmpb   $0x2,(%rax)
  40abbe:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40abc0:	cmpb   $0x2,0x1(%rax)
  40abc4:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40abc6:	nopw   %cs:0x0(%rax,%rax,1)
  40abd0:	cmp    0x3c(%rsp),%r13d
  40abd5:	jle    40abf0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x390>
  40abd7:	cmpb   $0x2,-0x1(%rbp)
  40abdb:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40abdd:	cmpb   $0x2,0x0(%rbp)
  40abe1:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40abe3:	cmpb   $0x2,0x1(%rbp)
  40abe7:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40abe9:	nopl   0x0(%rax)
  40abf0:	cmp    0x28(%rsp),%r13d
  40abf5:	jle    40ab58 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2f8>
  40abfb:	cmpb   $0x2,-0x1(%r14)
  40ac00:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40ac02:	cmpb   $0x2,(%r14)
  40ac06:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40ac08:	cmpb   $0x2,0x1(%r14)
  40ac0d:	jne    40ab58 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2f8>
  40ac13:	nopl   0x0(%rax,%rax,1)
  40ac18:	mov    0x20(%rsp),%rax
  40ac1d:	mov    %r12,0xc0(%rsp)
  40ac25:	movb   $0xff,(%rax,%r12,1)
  40ac2a:	mov    0x18(%rsp),%rax
  40ac2f:	mov    0x8(%rax),%rsi
  40ac33:	cmp    0x10(%rax),%rsi
  40ac37:	je     40b2c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa60>
  40ac3d:	mov    %r12,(%rsi)
  40ac40:	add    $0x8,%rsi
  40ac44:	mov    %rsi,0x8(%rax)
  40ac48:	jmpq   40ab58 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2f8>
  40ac4d:	nopl   (%rax)
  40ac50:	cmp    0x30(%rsp),%r13d
  40ac55:	jle    40ac70 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x410>
  40ac57:	mov    0x40(%rsp),%rax
  40ac5c:	cmpb   $0x2,(%rax)
  40ac5f:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40ac61:	cmpb   $0x2,0x1(%rax)
  40ac65:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40ac67:	nopw   0x0(%rax,%rax,1)
  40ac70:	cmp    0x3c(%rsp),%r13d
  40ac75:	jle    40ac88 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x428>
  40ac77:	cmpb   $0x2,0x0(%rbp)
  40ac7b:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40ac7d:	cmpb   $0x2,0x1(%rbp)
  40ac81:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40ac83:	nopl   0x0(%rax,%rax,1)
  40ac88:	cmp    0x28(%rsp),%r13d
  40ac8d:	jg     40ac02 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3a2>
  40ac93:	jmpq   40ab58 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2f8>
  40ac98:	nopl   0x0(%rax,%rax,1)
  40aca0:	cmp    %eax,0x8(%rsp)
  40aca4:	jl     40b288 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa28>
  40acaa:	cmp    0x30(%rsp),%r13d
  40acaf:	jle    40acd0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x470>
  40acb1:	mov    0x40(%rsp),%rax
  40acb6:	cmpb   $0x2,-0x1(%rax)
  40acba:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40acc0:	cmpb   $0x2,(%rax)
  40acc3:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40acc9:	nopl   0x0(%rax)
  40acd0:	cmp    0x3c(%rsp),%r13d
  40acd5:	jle    40acf0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x490>
  40acd7:	cmpb   $0x2,-0x1(%rbp)
  40acdb:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40ace1:	cmpb   $0x2,0x0(%rbp)
  40ace5:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40aceb:	nopl   0x0(%rax,%rax,1)
  40acf0:	cmp    0x28(%rsp),%r13d
  40acf5:	jle    40ab58 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2f8>
  40acfb:	cmpb   $0x2,-0x1(%r14)
  40ad00:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40ad06:	cmpb   $0x2,(%r14)
  40ad0a:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40ad10:	incl   0x28(%rsp)
  40ad14:	mov    0x48(%rsp),%eax
  40ad18:	mov    0x10(%rsp),%rdi
  40ad1d:	add    $0x5,%eax
  40ad20:	mov    0x28(%rsp),%ecx
  40ad24:	incl   0x3c(%rsp)
  40ad28:	incl   0x30(%rsp)
  40ad2c:	add    %rdi,0x58(%rsp)
  40ad31:	add    %rdi,%r15
  40ad34:	cmp    %eax,%ecx
  40ad36:	jne    40aae8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x288>
  40ad3c:	addl   $0x4,0x48(%rsp)
  40ad41:	mov    0x78(%rsp),%rcx
  40ad46:	add    %rcx,0x60(%rsp)
  40ad4b:	mov    0x48(%rsp),%eax
  40ad4f:	add    %rcx,0x50(%rsp)
  40ad54:	cmp    0x38(%rsp),%eax
  40ad58:	jne    40aa80 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x220>
  40ad5e:	mov    0x6c(%rsp),%esi
  40ad62:	cmp    %esi,0x38(%rsp)
  40ad66:	jge    40b00f <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x7af>
  40ad6c:	movslq 0x38(%rsp),%rbp
  40ad71:	mov    0x4c(%rsp),%eax
  40ad75:	mov    %rbp,%rdi
  40ad78:	lea    0x1(%rax),%esi
  40ad7b:	lea    0x1(%rbp),%eax
  40ad7e:	imul   0x10(%rsp),%rbp
  40ad84:	cltq   
  40ad86:	mov    %rax,0x40(%rsp)
  40ad8b:	mov    %esi,%eax
  40ad8d:	mov    %rax,0x60(%rsp)
  40ad92:	add    %rbp,%rax
  40ad95:	add    %rbx,%rax
  40ad98:	mov    %esi,0x48(%rsp)
  40ad9c:	mov    %rax,0x50(%rsp)
  40ada1:	cmpl   $0x1,0x8(%rsp)
  40ada6:	lea    -0x1(%rdi),%r14d
  40adaa:	sete   0x68(%rsp)
  40adaf:	nop
  40adb0:	mov    0x20(%rsp),%r15
  40adb5:	mov    0x18(%rsp),%r9
  40adba:	mov    0x4c(%rsp),%ecx
  40adbe:	mov    0x8(%rsp),%edx
  40adc2:	lea    (%r15,%rbp,1),%rsi
  40adc6:	lea    (%rbx,%rbp,1),%rdi
  40adca:	mov    %rbp,%r8
  40adcd:	callq  40a6e0 <seed_mask_row(unsigned char const*, unsigned char*, int, int, unsigned long, std::vector<unsigned long, std::allocator<unsigned long> >&)>
  40add2:	cmpb   $0x2,(%rbx,%rbp,1)
  40add6:	sete   %al
  40add9:	neg    %eax
  40addb:	mov    %al,(%r15,%rbp,1)
  40addf:	cmpb   $0x1,(%rbx,%rbp,1)
  40ade3:	je     40b0f8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x898>
  40ade9:	mov    0x48(%rsp),%edx
  40aded:	cmp    %edx,0x8(%rsp)
  40adf1:	jle    40afe8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x788>
  40adf7:	mov    0x40(%rsp),%rdi
  40adfc:	mov    0x10(%rsp),%rcx
  40ae01:	movslq %edi,%r15
  40ae04:	movslq %r14d,%r12
  40ae07:	imul   %rcx,%r15
  40ae0b:	imul   %rcx,%r12
  40ae0f:	mov    0x60(%rsp),%rax
  40ae14:	mov    %edi,0x3c(%rsp)
  40ae18:	add    %rax,%r15
  40ae1b:	add    %rax,%r12
  40ae1e:	lea    (%rbx,%r15,1),%rdx
  40ae22:	lea    (%rbx,%r12,1),%rcx
  40ae26:	mov    %rdx,0x28(%rsp)
  40ae2b:	lea    0x0(%rbp,%rax,1),%r12
  40ae30:	mov    %rcx,0x30(%rsp)
  40ae35:	mov    0x50(%rsp),%r15
  40ae3a:	mov    0x48(%rsp),%eax
  40ae3e:	jmp    40ae5e <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5fe>
  40ae40:	mov    0x58(%rsp),%eax
  40ae44:	incq   0x28(%rsp)
  40ae49:	inc    %r15
  40ae4c:	incq   0x30(%rsp)
  40ae51:	inc    %r12
  40ae54:	cmp    %eax,0x8(%rsp)
  40ae58:	jle    40afe8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x788>
  40ae5e:	cmpb   $0x2,(%rbx,%r12,1)
  40ae63:	sete   %dl
  40ae66:	mov    0x20(%rsp),%rdi
  40ae6b:	neg    %edx
  40ae6d:	mov    %dl,(%rdi,%r12,1)
  40ae71:	lea    0x1(%rax),%esi
  40ae74:	mov    %esi,0x58(%rsp)
  40ae78:	cmpb   $0x1,(%rbx,%r12,1)
  40ae7d:	jne    40ae40 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5e0>
  40ae7f:	mov    0x8(%rsp),%edi
  40ae83:	cmp    %esi,%edi
  40ae85:	jle    40af78 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x718>
  40ae8b:	cmp    %eax,%edi
  40ae8d:	jl     40af30 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6d0>
  40ae93:	cmp    %r14d,%r13d
  40ae96:	jle    40aeb0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x650>
  40ae98:	mov    0x30(%rsp),%rax
  40ae9d:	cmpb   $0x2,-0x1(%rax)
  40aea1:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40aea3:	cmpb   $0x2,(%rax)
  40aea6:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40aea8:	cmpb   $0x2,0x1(%rax)
  40aeac:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40aeae:	xchg   %ax,%ax
  40aeb0:	cmp    0x38(%rsp),%r13d
  40aeb5:	jle    40aed0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x670>
  40aeb7:	cmpb   $0x2,-0x1(%r15)
  40aebc:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40aebe:	cmpb   $0x2,(%r15)
  40aec2:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40aec4:	cmpb   $0x2,0x1(%r15)
  40aec9:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40aecb:	nopl   0x0(%rax,%rax,1)
  40aed0:	cmp    0x3c(%rsp),%r13d
  40aed5:	jle    40ae40 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5e0>
  40aedb:	mov    0x28(%rsp),%rax
  40aee0:	cmpb   $0x2,-0x1(%rax)
  40aee4:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40aee6:	cmpb   $0x2,(%rax)
  40aee9:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40aeeb:	cmpb   $0x2,0x1(%rax)
  40aeef:	jne    40ae40 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5e0>
  40aef5:	nopl   (%rax)
  40aef8:	mov    0x20(%rsp),%rax
  40aefd:	mov    %r12,0xd0(%rsp)
  40af05:	movb   $0xff,(%rax,%r12,1)
  40af0a:	mov    0x18(%rsp),%rax
  40af0f:	mov    0x8(%rax),%rsi
  40af13:	cmp    0x10(%rax),%rsi
  40af17:	je     40b2d8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa78>
  40af1d:	mov    %r12,(%rsi)
  40af20:	add    $0x8,%rsi
  40af24:	mov    %rsi,0x8(%rax)
  40af28:	jmpq   40ae40 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5e0>
  40af2d:	nopl   (%rax)
  40af30:	cmp    %r14d,%r13d
  40af33:	jle    40af48 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6e8>
  40af35:	mov    0x30(%rsp),%rax
  40af3a:	cmpb   $0x2,(%rax)
  40af3d:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40af3f:	cmpb   $0x2,0x1(%rax)
  40af43:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40af45:	nopl   (%rax)
  40af48:	cmp    0x38(%rsp),%r13d
  40af4d:	jle    40af60 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x700>
  40af4f:	cmpb   $0x2,(%r15)
  40af53:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40af55:	cmpb   $0x2,0x1(%r15)
  40af5a:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40af5c:	nopl   0x0(%rax)
  40af60:	cmp    0x3c(%rsp),%r13d
  40af65:	jle    40ae40 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5e0>
  40af6b:	mov    0x28(%rsp),%rax
  40af70:	jmpq   40aee6 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x686>
  40af75:	nopl   (%rax)
  40af78:	cmp    %eax,0x8(%rsp)
  40af7c:	jl     40b1a0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x940>
  40af82:	cmp    %r14d,%r13d
  40af85:	jle    40afa0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x740>
  40af87:	mov    0x30(%rsp),%rax
  40af8c:	cmpb   $0x2,-0x1(%rax)
  40af90:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40af96:	cmpb   $0x2,(%rax)
  40af99:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40af9f:	nop
  40afa0:	cmp    0x38(%rsp),%r13d
  40afa5:	jle    40afc0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x760>
  40afa7:	cmpb   $0x2,-0x1(%r15)
  40afac:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40afb2:	cmpb   $0x2,(%r15)
  40afb6:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40afbc:	nopl   0x0(%rax)
  40afc0:	cmp    0x3c(%rsp),%r13d
  40afc5:	jle    40ae40 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5e0>
  40afcb:	mov    0x28(%rsp),%rax
  40afd0:	cmpb   $0x2,-0x1(%rax)
  40afd4:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40afda:	cmpb   $0x2,(%rax)
  40afdd:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40afe3:	nopl   0x0(%rax,%rax,1)
  40afe8:	incl   0x38(%rsp)
  40afec:	mov    0x10(%rsp),%rdi
  40aff1:	incq   0x40(%rsp)
  40aff6:	add    %rdi,%rbp
  40aff9:	mov    0x38(%rsp),%eax
  40affd:	inc    %r14d
  40b000:	add    %rdi,0x50(%rsp)
  40b005:	cmp    0x6c(%rsp),%eax
  40b009:	jne    40adb0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x550>
  40b00f:	cmp    $0x1,%r13d
  40b013:	je     40b2f0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa90>
  40b019:	mov    0x10(%rsp),%rax
  40b01e:	movslq 0x6c(%rsp),%rbp
  40b023:	lea    -0x2(%r13),%r12d
  40b027:	imul   %rax,%rbp
  40b02b:	mov    %r12d,0x28(%rsp)
  40b030:	imul   %rax,%r12
  40b034:	lea    (%rbx,%rbp,1),%r15
  40b038:	xor    %eax,%eax
  40b03a:	add    %rbx,%r12
  40b03d:	jmp    40b057 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x7f7>
  40b03f:	nop
  40b040:	mov    %r14d,%eax
  40b043:	inc    %r15
  40b046:	inc    %r12
  40b049:	inc    %rbp
  40b04c:	cmp    %r14d,0x8(%rsp)
  40b051:	jle    40b2f0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa90>
  40b057:	cmpb   $0x2,(%rbx,%rbp,1)
  40b05b:	sete   %dl
  40b05e:	mov    0x20(%rsp),%rdi
  40b063:	neg    %edx
  40b065:	mov    %dl,(%rdi,%rbp,1)
  40b068:	lea    0x1(%rax),%r14d
  40b06c:	cmpb   $0x1,(%rbx,%rbp,1)
  40b070:	jne    40b040 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x7e0>
  40b072:	dec    %eax
  40b074:	mov    0x8(%rsp),%ecx
  40b078:	cmp    $0xffffffff,%eax
  40b07b:	sete   %dl
  40b07e:	cmp    %eax,%ecx
  40b080:	setle  %al
  40b083:	or     %eax,%edx
  40b085:	cmp    %r14d,%ecx
  40b088:	jle    40b5a0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xd40>
  40b08e:	test   %dl,%dl
  40b090:	je     40b530 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xcd0>
  40b096:	cmp    0x28(%rsp),%r13d
  40b09b:	jle    40b0ac <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x84c>
  40b09d:	cmpb   $0x2,(%r12)
  40b0a2:	je     40b0c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x860>
  40b0a4:	cmpb   $0x2,0x1(%r12)
  40b0aa:	je     40b0c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x860>
  40b0ac:	cmpb   $0x2,(%r15)
  40b0b0:	je     40b0c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x860>
  40b0b2:	cmpb   $0x2,0x1(%r15)
  40b0b7:	jne    40b040 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x7e0>
  40b0b9:	nopl   0x0(%rax)
  40b0c0:	mov    0x20(%rsp),%rax
  40b0c5:	mov    %rbp,0xd8(%rsp)
  40b0cd:	movb   $0xff,(%rax,%rbp,1)
  40b0d1:	mov    0x18(%rsp),%rax
  40b0d6:	mov    0x8(%rax),%rsi
  40b0da:	cmp    0x10(%rax),%rsi
  40b0de:	je     40b6ad <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xe4d>
  40b0e4:	mov    %rbp,(%rsi)
  40b0e7:	add    $0x8,%rsi
  40b0eb:	mov    %rsi,0x8(%rax)
  40b0ef:	jmpq   40b040 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x7e0>
  40b0f4:	nopl   0x0(%rax)
  40b0f8:	cmp    %r14d,%r13d
  40b0fb:	jle    40b11a <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x8ba>
  40b0fd:	movslq %r14d,%rax
  40b100:	imul   0x10(%rsp),%rax
  40b106:	cmpb   $0x2,(%rbx,%rax,1)
  40b10a:	je     40b168 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x908>
  40b10c:	cmpl   $0x1,0x8(%rsp)
  40b111:	je     40b12f <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x8cf>
  40b113:	cmpb   $0x2,0x1(%rbx,%rax,1)
  40b118:	je     40b168 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x908>
  40b11a:	cmp    0x38(%rsp),%r13d
  40b11f:	jle    40b12f <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x8cf>
  40b121:	cmpb   $0x0,0x68(%rsp)
  40b126:	jne    40b12f <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x8cf>
  40b128:	cmpb   $0x2,0x1(%rbx,%rbp,1)
  40b12d:	je     40b168 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x908>
  40b12f:	cmp    0x40(%rsp),%r13d
  40b134:	jle    40ade9 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x589>
  40b13a:	movslq 0x40(%rsp),%rax
  40b13f:	imul   0x10(%rsp),%rax
  40b145:	cmpb   $0x2,(%rbx,%rax,1)
  40b149:	je     40b168 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x908>
  40b14b:	cmpl   $0x1,0x8(%rsp)
  40b150:	je     40afe8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x788>
  40b156:	cmpb   $0x2,0x1(%rbx,%rax,1)
  40b15b:	jne    40ade9 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x589>
  40b161:	nopl   0x0(%rax)
  40b168:	mov    0x20(%rsp),%rax
  40b16d:	mov    %rbp,0xc8(%rsp)
  40b175:	movb   $0xff,(%rax,%rbp,1)
  40b179:	mov    0x18(%rsp),%rax
  40b17e:	mov    0x8(%rax),%rsi
  40b182:	cmp    0x10(%rax),%rsi
  40b186:	je     40b618 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xdb8>
  40b18c:	mov    %rbp,(%rsi)
  40b18f:	add    $0x8,%rsi
  40b193:	mov    %rsi,0x8(%rax)
  40b197:	jmpq   40ade9 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x589>
  40b19c:	nopl   0x0(%rax)
  40b1a0:	cmp    %r14d,%r13d
  40b1a3:	jle    40b1b3 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x953>
  40b1a5:	mov    0x30(%rsp),%rax
  40b1aa:	cmpb   $0x2,(%rax)
  40b1ad:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40b1b3:	cmp    0x38(%rsp),%r13d
  40b1b8:	jle    40b1c4 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x964>
  40b1ba:	cmpb   $0x2,(%r15)
  40b1be:	je     40aef8 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x698>
  40b1c4:	cmp    0x3c(%rsp),%r13d
  40b1c9:	jle    40ae40 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5e0>
  40b1cf:	mov    0x28(%rsp),%rax
  40b1d4:	jmpq   40afda <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x77a>
  40b1d9:	nopl   0x0(%rax)
  40b1e0:	cmp    0x30(%rsp),%r13d
  40b1e5:	jle    40b206 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9a6>
  40b1e7:	movslq 0x30(%rsp),%rax
  40b1ec:	imul   0x10(%rsp),%rax
  40b1f2:	cmpb   $0x2,(%rbx,%rax,1)
  40b1f6:	je     40b250 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9f0>
  40b1f8:	cmpl   $0x1,0x8(%rsp)
  40b1fd:	je     40b21c <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9bc>
  40b1ff:	cmpb   $0x2,0x1(%rbx,%rax,1)
  40b204:	je     40b250 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9f0>
  40b206:	cmp    0x3c(%rsp),%r13d
  40b20b:	jle    40b21c <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9bc>
  40b20d:	cmpb   $0x0,0x77(%rsp)
  40b212:	jne    40b21c <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9bc>
  40b214:	cmpb   $0x2,0x1(%rbx,%r15,1)
  40b21a:	je     40b250 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9f0>
  40b21c:	cmp    0x28(%rsp),%r13d
  40b221:	jle    40ab06 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2a6>
  40b227:	movslq 0x28(%rsp),%rax
  40b22c:	imul   0x10(%rsp),%rax
  40b232:	cmpb   $0x2,(%rbx,%rax,1)
  40b236:	je     40b250 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9f0>
  40b238:	cmpl   $0x1,0x8(%rsp)
  40b23d:	je     40ad10 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x4b0>
  40b243:	cmpb   $0x2,0x1(%rbx,%rax,1)
  40b248:	jne    40ab06 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2a6>
  40b24e:	xchg   %ax,%ax
  40b250:	mov    0x20(%rsp),%rax
  40b255:	mov    %r15,0xb8(%rsp)
  40b25d:	movb   $0xff,(%rax,%r15,1)
  40b262:	mov    0x18(%rsp),%rax
  40b267:	mov    0x8(%rax),%rsi
  40b26b:	cmp    0x10(%rax),%rsi
  40b26f:	je     40b600 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xda0>
  40b275:	mov    %r15,(%rsi)
  40b278:	add    $0x8,%rsi
  40b27c:	mov    %rsi,0x8(%rax)
  40b280:	jmpq   40ab06 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2a6>
  40b285:	nopl   (%rax)
  40b288:	cmp    0x30(%rsp),%r13d
  40b28d:	jle    40b29d <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa3d>
  40b28f:	mov    0x40(%rsp),%rax
  40b294:	cmpb   $0x2,(%rax)
  40b297:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40b29d:	cmp    0x3c(%rsp),%r13d
  40b2a2:	jle    40b2ae <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa4e>
  40b2a4:	cmpb   $0x2,0x0(%rbp)
  40b2a8:	je     40ac18 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40b2ae:	cmp    0x28(%rsp),%r13d
  40b2b3:	jg     40ad06 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x4a6>
  40b2b9:	jmpq   40ab58 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2f8>
  40b2be:	xchg   %ax,%ax
  40b2c0:	mov    %rax,%rdi
  40b2c3:	lea    0xc0(%rsp),%rdx
  40b2cb:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40b2d0:	jmpq   40ab58 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2f8>
  40b2d5:	nopl   (%rax)
  40b2d8:	mov    %rax,%rdi
  40b2db:	lea    0xd0(%rsp),%rdx
  40b2e3:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40b2e8:	jmpq   40ae40 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5e0>
  40b2ed:	nopl   (%rax)
  40b2f0:	mov    0x18(%rsp),%rax
  40b2f5:	xor    %r12d,%r12d
  40b2f8:	mov    (%rax),%rdx
  40b2fb:	cmp    %rdx,0x8(%rax)
  40b2ff:	je     40a9d0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x170>
  40b305:	nopl   (%rax)
  40b308:	mov    (%rdx,%r12,8),%rax
  40b30c:	xor    %edx,%edx
  40b30e:	divq   0x10(%rsp)
  40b313:	lea    0x1(%rdx),%ebx
  40b316:	movslq %edx,%r14
  40b319:	mov    %ebx,0x10(%rsp)
  40b31d:	lea    -0x1(%rax),%ebp
  40b320:	movslq %eax,%rbx
  40b323:	add    $0x2,%eax
  40b326:	mov    %eax,0x8(%rsp)
  40b32a:	lea    0x1(%r14),%rax
  40b32e:	mov    %rax,0x20(%rsp)
  40b333:	lea    -0x1(%r14),%rax
  40b337:	mov    %rax,0x28(%rsp)
  40b33c:	mov    %r14,%r13
  40b33f:	lea    -0x1(%rdx),%r15d
  40b343:	dec    %rbx
  40b346:	test   %ebp,%ebp
  40b348:	js     40b400 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xba0>
  40b34e:	cmp    0x9c(%rsp),%ebp
  40b355:	jge    40b400 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xba0>
  40b35b:	test   %r15d,%r15d
  40b35e:	js     40b390 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb30>
  40b360:	movslq 0x98(%rsp),%rax
  40b368:	cmp    %eax,%r15d
  40b36b:	jge    40b390 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb30>
  40b36d:	imul   %rbx,%rax
  40b371:	mov    0xa0(%rsp),%rdx
  40b379:	add    0x28(%rsp),%rax
  40b37e:	cmpb   $0x1,(%rdx,%rax,1)
  40b382:	mov    %rax,0xd8(%rsp)
  40b38a:	je     40b4d0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xc70>
  40b390:	test   %r13d,%r13d
  40b393:	js     40b3c3 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb63>
  40b395:	movslq 0x98(%rsp),%rax
  40b39d:	cmp    %eax,%r13d
  40b3a0:	jge    40b3c3 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb63>
  40b3a2:	imul   %rbx,%rax
  40b3a6:	mov    0xa0(%rsp),%rdx
  40b3ae:	add    %r14,%rax
  40b3b1:	cmpb   $0x1,(%rdx,%rax,1)
  40b3b5:	mov    %rax,0xd8(%rsp)
  40b3bd:	je     40b448 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xbe8>
  40b3c3:	mov    0x10(%rsp),%esi
  40b3c7:	test   %esi,%esi
  40b3c9:	js     40b400 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xba0>
  40b3cb:	movslq 0x98(%rsp),%rax
  40b3d3:	cmp    %eax,%esi
  40b3d5:	jge    40b400 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xba0>
  40b3d7:	imul   %rbx,%rax
  40b3db:	mov    0xa0(%rsp),%rdx
  40b3e3:	add    0x20(%rsp),%rax
  40b3e8:	cmpb   $0x1,(%rdx,%rax,1)
  40b3ec:	mov    %rax,0xd8(%rsp)
  40b3f4:	je     40b490 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xc30>
  40b3fa:	nopw   0x0(%rax,%rax,1)
  40b400:	inc    %ebp
  40b402:	inc    %rbx
  40b405:	cmp    %ebp,0x8(%rsp)
  40b409:	jne    40b346 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xae6>
  40b40f:	mov    0x18(%rsp),%rax
  40b414:	inc    %r12
  40b417:	mov    (%rax),%rdx
  40b41a:	mov    0x8(%rax),%rax
  40b41e:	mov    %rax,0x8(%rsp)
  40b423:	sub    %rdx,%rax
  40b426:	sar    $0x3,%rax
  40b42a:	cmp    %r12,%rax
  40b42d:	jbe    40a9d0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x170>
  40b433:	movslq 0x98(%rsp),%rax
  40b43b:	mov    %rax,0x10(%rsp)
  40b440:	jmpq   40b308 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xaa8>
  40b445:	nopl   (%rax)
  40b448:	mov    0xa8(%rsp),%rdx
  40b450:	add    %rax,%rdx
  40b453:	cmpb   $0x0,(%rdx)
  40b456:	jne    40b3c3 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb63>
  40b45c:	movb   $0xff,(%rdx)
  40b45f:	mov    0x18(%rsp),%rdx
  40b464:	mov    0x8(%rdx),%rsi
  40b468:	cmp    0x10(%rdx),%rsi
  40b46c:	je     40b688 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xe28>
  40b472:	mov    %rax,(%rsi)
  40b475:	mov    0x18(%rsp),%rax
  40b47a:	add    $0x8,%rsi
  40b47e:	mov    %rsi,0x8(%rax)
  40b482:	jmpq   40b3c3 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb63>
  40b487:	nopw   0x0(%rax,%rax,1)
  40b490:	mov    0xa8(%rsp),%rdx
  40b498:	add    %rax,%rdx
  40b49b:	cmpb   $0x0,(%rdx)
  40b49e:	jne    40b400 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xba0>
  40b4a4:	movb   $0xff,(%rdx)
  40b4a7:	mov    0x18(%rsp),%rdi
  40b4ac:	mov    0x8(%rdi),%rsi
  40b4b0:	cmp    0x10(%rdi),%rsi
  40b4b4:	je     40b670 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xe10>
  40b4ba:	mov    %rax,(%rsi)
  40b4bd:	mov    0x18(%rsp),%rax
  40b4c2:	add    $0x8,%rsi
  40b4c6:	mov    %rsi,0x8(%rax)
  40b4ca:	jmpq   40b400 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xba0>
  40b4cf:	nop
  40b4d0:	mov    0xa8(%rsp),%rdx
  40b4d8:	add    %rax,%rdx
  40b4db:	cmpb   $0x0,(%rdx)
  40b4de:	jne    40b390 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb30>
  40b4e4:	movb   $0xff,(%rdx)
  40b4e7:	mov    0x18(%rsp),%rcx
  40b4ec:	mov    0x8(%rcx),%rsi
  40b4f0:	cmp    0x10(%rcx),%rsi
  40b4f4:	je     40b658 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xdf8>
  40b4fa:	mov    %rax,(%rsi)
  40b4fd:	mov    0x18(%rsp),%rax
  40b502:	add    $0x8,%rsi
  40b506:	mov    %rsi,0x8(%rax)
  40b50a:	jmpq   40b390 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb30>
  40b50f:	nop
  40b510:	cmpb   $0x2,0x1(%rbx,%rbp,1)
  40b515:	je     40a998 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40b51b:	cmp    $0x1,%r13d
  40b51f:	jle    40a918 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40b525:	jmpq   40a982 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x122>
  40b52a:	nopw   0x0(%rax,%rax,1)
  40b530:	cmp    0x28(%rsp),%r13d
  40b535:	jle    40b55a <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xcfa>
  40b537:	cmpb   $0x2,-0x1(%r12)
  40b53d:	je     40b0c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x860>
  40b543:	cmpb   $0x2,(%r12)
  40b548:	je     40b0c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x860>
  40b54e:	cmpb   $0x2,0x1(%r12)
  40b554:	je     40b0c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x860>
  40b55a:	cmpb   $0x2,-0x1(%r15)
  40b55f:	jne    40b0ac <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x84c>
  40b565:	jmpq   40b0c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x860>
  40b56a:	nopw   0x0(%rax,%rax,1)
  40b570:	cmpb   $0x2,-0x1(%rbx,%rbp,1)
  40b575:	je     40a998 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40b57b:	cmp    $0x1,%r13d
  40b57f:	jle    40a918 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40b585:	cmpb   $0x2,-0x1(%r12)
  40b58b:	jne    40aa02 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x1a2>
  40b591:	jmpq   40a998 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40b596:	nopw   %cs:0x0(%rax,%rax,1)
  40b5a0:	test   %dl,%dl
  40b5a2:	jne    40b630 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xdd0>
  40b5a8:	cmp    0x28(%rsp),%r13d
  40b5ad:	jle    40b5c6 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xd66>
  40b5af:	cmpb   $0x2,-0x1(%r12)
  40b5b5:	je     40b0c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x860>
  40b5bb:	cmpb   $0x2,(%r12)
  40b5c0:	je     40b0c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x860>
  40b5c6:	cmpb   $0x2,-0x1(%r15)
  40b5cb:	jne    40b642 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xde2>
  40b5cd:	jmpq   40b0c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x860>
  40b5d2:	nopw   0x0(%rax,%rax,1)
  40b5d8:	lea    -0x2(%rdi),%eax
  40b5db:	and    $0xffffffe0,%eax
  40b5de:	mov    %eax,%ebp
  40b5e0:	sar    $0x5,%ebp
  40b5e3:	inc    %ebp
  40b5e5:	movslq %ebp,%rbp
  40b5e8:	mov    %eax,0x4c(%rsp)
  40b5ec:	lea    0x0(,%rbp,4),%rax
  40b5f4:	jmpq   40a8cc <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6c>
  40b5f9:	nopl   0x0(%rax)
  40b600:	mov    %rax,%rdi
  40b603:	lea    0xb8(%rsp),%rdx
  40b60b:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40b610:	jmpq   40ab06 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2a6>
  40b615:	nopl   (%rax)
  40b618:	mov    %rax,%rdi
  40b61b:	lea    0xc8(%rsp),%rdx
  40b623:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40b628:	jmpq   40ade9 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x589>
  40b62d:	nopl   (%rax)
  40b630:	cmp    0x28(%rsp),%r13d
  40b635:	jle    40b642 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xde2>
  40b637:	cmpb   $0x2,(%r12)
  40b63c:	je     40b0c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x860>
  40b642:	cmpb   $0x2,(%r15)
  40b646:	jne    40b040 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x7e0>
  40b64c:	jmpq   40b0c0 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x860>
  40b651:	nopl   0x0(%rax)
  40b658:	lea    0xd8(%rsp),%rdx
  40b660:	mov    %rcx,%rdi
  40b663:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40b668:	jmpq   40b390 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb30>
  40b66d:	nopl   (%rax)
  40b670:	lea    0xd8(%rsp),%rdx
  40b678:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40b67d:	jmpq   40b400 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xba0>
  40b682:	nopw   0x0(%rax,%rax,1)
  40b688:	mov    %rdx,%rdi
  40b68b:	lea    0xd8(%rsp),%rdx
  40b693:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40b698:	jmpq   40b3c3 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb63>
  40b69d:	nopl   (%rax)
  40b6a0:	movl   $0x1,0x38(%rsp)
  40b6a8:	jmpq   40ad5e <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x4fe>
  40b6ad:	mov    %rax,%rdi
  40b6b0:	lea    0xd8(%rsp),%rdx
  40b6b8:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40b6bd:	jmpq   40b040 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x7e0>
  40b6c2:	nopw   0x0(%rax,%rax,1)
  40b6c8:	mov    %rax,%rdi
  40b6cb:	lea    0xb0(%rsp),%rdx
  40b6d3:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40b6d8:	jmpq   40a918 <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40b6dd:	mov    %rax,%rbx
  40b6e0:	jmpq   401b4b <hysteresis_mask_kernel(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&) [clone .cold.60]>
  40b6e5:	data16 nopw %cs:0x0(%rax,%rax,1)

000000000040ce10 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)>:
  40ce10:	push   %r15
  40ce12:	push   %r14
  40ce14:	push   %r13
  40ce16:	push   %r12
  40ce18:	push   %rbp
  40ce19:	push   %rbx
  40ce1a:	sub    $0x128,%rsp
  40ce21:	mov    (%r8),%rax
  40ce24:	mov    %edi,0x98(%rsp)
  40ce2b:	mov    %esi,0x9c(%rsp)
  40ce32:	mov    %rdx,0xa0(%rsp)
  40ce3a:	mov    %rcx,0xa8(%rsp)
  40ce42:	cmp    0x8(%r8),%rax
  40ce46:	je     40ce4c <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3c>
  40ce48:	mov    %rax,0x8(%r8)
  40ce4c:	test   %esi,%esi
  40ce4e:	jle    40cf8d <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x17d>
  40ce54:	test   %edi,%edi
  40ce56:	jle    40cf8d <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x17d>
  40ce5c:	cmp    $0x2,%esi
  40ce5f:	jle    40ce6a <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5a>
  40ce61:	cmp    $0x21,%edi
  40ce64:	jg     40dc70 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xe60>
  40ce6a:	movl   $0x0,0x4c(%rsp)
  40ce72:	mov    $0x1,%ebp
  40ce77:	mov    $0x4,%eax
  40ce7c:	mov    %edi,%r14d
  40ce7f:	mov    %edi,0x20(%rsp)
  40ce83:	mov    %rax,%rdi
  40ce86:	mov    %rdx,%rbx
  40ce89:	mov    %r8,%r15
  40ce8c:	mov    %rcx,0x8(%rsp)
  40ce91:	mov    %esi,%r13d
  40ce94:	callq  4017a0 <operator new(unsigned long)@plt>
  40ce99:	mov    %rax,%rdi
  40ce9c:	lea    0x0(,%rbp,4),%rdx
  40cea4:	xor    %esi,%esi
  40cea6:	mov    %rax,0x88(%rsp)
  40ceae:	callq  401720 <memset@plt>
  40ceb3:	movslq %r14d,%rax
  40ceb6:	mov    %rax,0x10(%rsp)
  40cebb:	lea    (%rbx,%rax,1),%r12
  40cebf:	xor    %ebp,%ebp
  40cec1:	jmp    40ced8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xc8>
  40cec3:	nopl   0x0(%rax,%rax,1)
  40cec8:	inc    %rbp
  40cecb:	inc    %r12
  40cece:	cmp    %ebp,0x20(%rsp)
  40ced2:	jle    40cfc0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x1b0>
  40ced8:	cmpb   $0x2,(%rbx,%rbp,1)
  40cedc:	sete   %al
  40cedf:	mov    0x8(%rsp),%rdx
  40cee4:	neg    %eax
  40cee6:	mov    %al,(%rdx,%rbp,1)
  40cee9:	cmpb   $0x1,(%rbx,%rbp,1)
  40ceed:	jne    40cec8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40ceef:	lea    -0x1(%rbp),%edx
  40cef2:	mov    0x20(%rsp),%ecx
  40cef6:	cmp    $0xffffffff,%edx
  40cef9:	sete   %al
  40cefc:	cmp    %edx,%ecx
  40cefe:	setle  %dl
  40cf01:	or     %edx,%eax
  40cf03:	lea    0x1(%rbp),%edx
  40cf06:	cmp    %edx,%ecx
  40cf08:	jle    40cfa0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x190>
  40cf0e:	test   %al,%al
  40cf10:	jne    40dba0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xd90>
  40cf16:	cmpb   $0x2,-0x1(%rbx,%rbp,1)
  40cf1b:	je     40cf48 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40cf1d:	cmpb   $0x2,0x1(%rbx,%rbp,1)
  40cf22:	je     40cf48 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40cf24:	cmp    $0x1,%r13d
  40cf28:	jle    40cec8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40cf2a:	cmpb   $0x2,-0x1(%r12)
  40cf30:	je     40cf48 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40cf32:	cmpb   $0x2,(%r12)
  40cf37:	je     40cf48 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40cf39:	cmpb   $0x2,0x1(%r12)
  40cf3f:	jne    40cec8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40cf41:	nopl   0x0(%rax)
  40cf48:	mov    0x8(%rsp),%rax
  40cf4d:	mov    %rbp,0xb0(%rsp)
  40cf55:	movb   $0xff,(%rax,%rbp,1)
  40cf59:	mov    0x8(%r15),%rsi
  40cf5d:	cmp    0x10(%r15),%rsi
  40cf61:	je     40ddd8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xfc8>
  40cf67:	mov    %rbp,(%rsi)
  40cf6a:	add    $0x8,%rsi
  40cf6e:	mov    %rsi,0x8(%r15)
  40cf72:	jmpq   40cec8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40cf77:	nopw   0x0(%rax,%rax,1)
  40cf80:	mov    0x88(%rsp),%rdi
  40cf88:	callq  401770 <operator delete(void*)@plt>
  40cf8d:	add    $0x128,%rsp
  40cf94:	pop    %rbx
  40cf95:	pop    %rbp
  40cf96:	pop    %r12
  40cf98:	pop    %r13
  40cf9a:	pop    %r14
  40cf9c:	pop    %r15
  40cf9e:	retq   
  40cf9f:	nop
  40cfa0:	test   %al,%al
  40cfa2:	je     40dc00 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xdf0>
  40cfa8:	cmp    $0x1,%r13d
  40cfac:	jle    40cec8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40cfb2:	cmpb   $0x2,(%r12)
  40cfb7:	je     40cf48 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40cfb9:	nopl   0x0(%rax)
  40cfc0:	lea    -0x1(%r13),%eax
  40cfc4:	mov    %eax,0x60(%rsp)
  40cfc8:	cmp    $0x4,%eax
  40cfcb:	jle    40dd20 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xf10>
  40cfd1:	mov    0x10(%rsp),%rsi
  40cfd6:	mov    0x4c(%rsp),%eax
  40cfda:	lea    0x0(,%rsi,4),%rdx
  40cfe2:	inc    %eax
  40cfe4:	mov    %eax,0x64(%rsp)
  40cfe8:	mov    %rdx,0x78(%rsp)
  40cfed:	mov    %eax,%edx
  40cfef:	mov    %rsi,%rax
  40cff2:	add    %rdx,%rax
  40cff5:	add    %rbx,%rax
  40cff8:	mov    %rax,0x68(%rsp)
  40cffd:	lea    -0x6(%r13),%eax
  40d001:	and    $0xfffffffc,%eax
  40d004:	add    $0x5,%eax
  40d007:	mov    %rdx,0x80(%rsp)
  40d00f:	mov    %eax,0x24(%rsp)
  40d013:	mov    %rsi,0x50(%rsp)
  40d018:	movl   $0x1,0x48(%rsp)
  40d020:	cmpl   $0x1,0x20(%rsp)
  40d025:	sete   0x77(%rsp)
  40d02a:	nopw   0x0(%rax,%rax,1)
  40d030:	mov    0x50(%rsp),%rbp
  40d035:	mov    $0x4,%r12d
  40d03b:	nopl   0x0(%rax,%rax,1)
  40d040:	mov    0x8(%rsp),%rax
  40d045:	mov    0x4c(%rsp),%ecx
  40d049:	mov    0x20(%rsp),%edx
  40d04d:	lea    (%rax,%rbp,1),%rsi
  40d051:	lea    (%rbx,%rbp,1),%rdi
  40d055:	mov    %r15,%r9
  40d058:	mov    %rbp,%r8
  40d05b:	callq  40a6e0 <seed_mask_row(unsigned char const*, unsigned char*, int, int, unsigned long, std::vector<unsigned long, std::allocator<unsigned long> >&)>
  40d060:	add    0x10(%rsp),%rbp
  40d065:	dec    %r12d
  40d068:	jne    40d040 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x230>
  40d06a:	mov    0x48(%rsp),%eax
  40d06e:	lea    -0x1(%rax),%edx
  40d071:	lea    0x1(%rax),%edi
  40d074:	mov    %edx,0x28(%rsp)
  40d078:	mov    %edi,0x18(%rsp)
  40d07c:	mov    0x50(%rsp),%rdx
  40d081:	mov    0x68(%rsp),%rdi
  40d086:	mov    %rdx,0x40(%rsp)
  40d08b:	mov    %rdi,0x58(%rsp)
  40d090:	mov    %eax,0x30(%rsp)
  40d094:	nopl   0x0(%rax)
  40d098:	mov    0x40(%rsp),%rcx
  40d09d:	mov    0x8(%rsp),%rsi
  40d0a2:	cmpb   $0x2,(%rbx,%rcx,1)
  40d0a6:	sete   %al
  40d0a9:	neg    %eax
  40d0ab:	mov    %al,(%rsi,%rcx,1)
  40d0ae:	cmpb   $0x1,(%rbx,%rcx,1)
  40d0b2:	je     40d7b0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9a0>
  40d0b8:	mov    0x64(%rsp),%ecx
  40d0bc:	cmp    %ecx,0x20(%rsp)
  40d0c0:	jle    40d2c0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x4b0>
  40d0c6:	mov    0x10(%rsp),%rdi
  40d0cb:	movslq 0x28(%rsp),%rbp
  40d0d0:	movslq 0x18(%rsp),%r14
  40d0d5:	imul   %rdi,%rbp
  40d0d9:	mov    0x80(%rsp),%rax
  40d0e1:	imul   %rdi,%r14
  40d0e5:	add    %rax,%rbp
  40d0e8:	mov    0x40(%rsp),%r12
  40d0ed:	add    %rax,%r14
  40d0f0:	lea    (%rbx,%rbp,1),%rdi
  40d0f4:	add    %rax,%r12
  40d0f7:	add    %rbx,%r14
  40d0fa:	mov    %rdi,0x38(%rsp)
  40d0ff:	mov    0x58(%rsp),%rbp
  40d104:	mov    0x64(%rsp),%eax
  40d108:	jmp    40d12c <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x31c>
  40d10a:	nopw   0x0(%rax,%rax,1)
  40d110:	mov    0x70(%rsp),%eax
  40d114:	inc    %r14
  40d117:	inc    %rbp
  40d11a:	incq   0x38(%rsp)
  40d11f:	inc    %r12
  40d122:	cmp    %eax,0x20(%rsp)
  40d126:	jle    40d2c0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x4b0>
  40d12c:	cmpb   $0x2,(%rbx,%r12,1)
  40d131:	sete   %dl
  40d134:	mov    0x8(%rsp),%rsi
  40d139:	neg    %edx
  40d13b:	mov    %dl,(%rsi,%r12,1)
  40d13f:	lea    0x1(%rax),%ecx
  40d142:	mov    %ecx,0x70(%rsp)
  40d146:	cmpb   $0x1,(%rbx,%r12,1)
  40d14b:	jne    40d110 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x300>
  40d14d:	mov    0x20(%rsp),%edi
  40d151:	cmp    %ecx,%edi
  40d153:	jle    40d250 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x440>
  40d159:	cmp    %eax,%edi
  40d15b:	jl     40d200 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3f0>
  40d161:	cmp    0x28(%rsp),%r13d
  40d166:	jle    40d180 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x370>
  40d168:	mov    0x38(%rsp),%rax
  40d16d:	cmpb   $0x2,-0x1(%rax)
  40d171:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d173:	cmpb   $0x2,(%rax)
  40d176:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d178:	cmpb   $0x2,0x1(%rax)
  40d17c:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d17e:	xchg   %ax,%ax
  40d180:	cmp    0x30(%rsp),%r13d
  40d185:	jle    40d1a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x390>
  40d187:	cmpb   $0x2,-0x1(%rbp)
  40d18b:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d18d:	cmpb   $0x2,0x0(%rbp)
  40d191:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d193:	cmpb   $0x2,0x1(%rbp)
  40d197:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d199:	nopl   0x0(%rax)
  40d1a0:	cmp    0x18(%rsp),%r13d
  40d1a5:	jle    40d110 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x300>
  40d1ab:	cmpb   $0x2,-0x1(%r14)
  40d1b0:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d1b2:	cmpb   $0x2,(%r14)
  40d1b6:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d1b8:	cmpb   $0x2,0x1(%r14)
  40d1bd:	jne    40d110 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x300>
  40d1c3:	nopl   0x0(%rax,%rax,1)
  40d1c8:	mov    0x8(%rsp),%rax
  40d1cd:	mov    %r12,0xc0(%rsp)
  40d1d5:	movb   $0xff,(%rax,%r12,1)
  40d1da:	mov    0x8(%r15),%rsi
  40d1de:	cmp    0x10(%r15),%rsi
  40d1e2:	je     40d8a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa90>
  40d1e8:	mov    %r12,(%rsi)
  40d1eb:	add    $0x8,%rsi
  40d1ef:	mov    %rsi,0x8(%r15)
  40d1f3:	jmpq   40d110 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x300>
  40d1f8:	nopl   0x0(%rax,%rax,1)
  40d200:	cmp    0x28(%rsp),%r13d
  40d205:	jle    40d220 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x410>
  40d207:	mov    0x38(%rsp),%rax
  40d20c:	cmpb   $0x2,(%rax)
  40d20f:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d211:	cmpb   $0x2,0x1(%rax)
  40d215:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d217:	nopw   0x0(%rax,%rax,1)
  40d220:	cmp    0x30(%rsp),%r13d
  40d225:	jle    40d238 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x428>
  40d227:	cmpb   $0x2,0x0(%rbp)
  40d22b:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d22d:	cmpb   $0x2,0x1(%rbp)
  40d231:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d233:	nopl   0x0(%rax,%rax,1)
  40d238:	cmp    0x18(%rsp),%r13d
  40d23d:	jg     40d1b2 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3a2>
  40d243:	jmpq   40d110 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x300>
  40d248:	nopl   0x0(%rax,%rax,1)
  40d250:	cmp    %eax,0x20(%rsp)
  40d254:	jl     40d860 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa50>
  40d25a:	cmp    0x28(%rsp),%r13d
  40d25f:	jle    40d280 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x470>
  40d261:	mov    0x38(%rsp),%rax
  40d266:	cmpb   $0x2,-0x1(%rax)
  40d26a:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d270:	cmpb   $0x2,(%rax)
  40d273:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d279:	nopl   0x0(%rax)
  40d280:	cmp    0x30(%rsp),%r13d
  40d285:	jle    40d2a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x490>
  40d287:	cmpb   $0x2,-0x1(%rbp)
  40d28b:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d291:	cmpb   $0x2,0x0(%rbp)
  40d295:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d29b:	nopl   0x0(%rax,%rax,1)
  40d2a0:	cmp    0x18(%rsp),%r13d
  40d2a5:	jle    40d110 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x300>
  40d2ab:	cmpb   $0x2,-0x1(%r14)
  40d2b0:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d2b6:	cmpb   $0x2,(%r14)
  40d2ba:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d2c0:	incl   0x18(%rsp)
  40d2c4:	mov    0x48(%rsp),%eax
  40d2c8:	mov    0x10(%rsp),%rcx
  40d2cd:	add    $0x5,%eax
  40d2d0:	mov    0x18(%rsp),%edi
  40d2d4:	incl   0x30(%rsp)
  40d2d8:	incl   0x28(%rsp)
  40d2dc:	add    %rcx,0x58(%rsp)
  40d2e1:	add    %rcx,0x40(%rsp)
  40d2e6:	cmp    %eax,%edi
  40d2e8:	jne    40d098 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x288>
  40d2ee:	addl   $0x4,0x48(%rsp)
  40d2f3:	mov    0x78(%rsp),%rcx
  40d2f8:	add    %rcx,0x68(%rsp)
  40d2fd:	mov    0x48(%rsp),%eax
  40d301:	add    %rcx,0x50(%rsp)
  40d306:	cmp    0x24(%rsp),%eax
  40d30a:	jne    40d030 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x220>
  40d310:	mov    0x60(%rsp),%ecx
  40d314:	cmp    %ecx,0x24(%rsp)
  40d318:	jge    40d5e0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x7d0>
  40d31e:	movslq 0x24(%rsp),%rbp
  40d323:	mov    0x4c(%rsp),%eax
  40d327:	mov    %rbp,%rdi
  40d32a:	lea    0x1(%rax),%esi
  40d32d:	lea    0x1(%rbp),%eax
  40d330:	cltq   
  40d332:	imul   0x10(%rsp),%rbp
  40d338:	mov    %rax,0x40(%rsp)
  40d33d:	lea    -0x1(%rdi),%eax
  40d340:	mov    %eax,0x18(%rsp)
  40d344:	mov    %esi,%eax
  40d346:	mov    %rax,0x68(%rsp)
  40d34b:	add    %rbp,%rax
  40d34e:	add    %rbx,%rax
  40d351:	mov    %esi,0x48(%rsp)
  40d355:	mov    %rax,0x50(%rsp)
  40d35a:	cmpl   $0x1,0x20(%rsp)
  40d35f:	sete   0x64(%rsp)
  40d364:	nopl   0x0(%rax)
  40d368:	mov    0x8(%rsp),%r14
  40d36d:	mov    0x4c(%rsp),%ecx
  40d371:	mov    0x20(%rsp),%edx
  40d375:	lea    (%r14,%rbp,1),%rsi
  40d379:	lea    (%rbx,%rbp,1),%rdi
  40d37d:	mov    %r15,%r9
  40d380:	mov    %rbp,%r8
  40d383:	callq  40a6e0 <seed_mask_row(unsigned char const*, unsigned char*, int, int, unsigned long, std::vector<unsigned long, std::allocator<unsigned long> >&)>
  40d388:	cmpb   $0x2,(%rbx,%rbp,1)
  40d38c:	sete   %al
  40d38f:	neg    %eax
  40d391:	mov    %al,(%r14,%rbp,1)
  40d395:	cmpb   $0x1,(%rbx,%rbp,1)
  40d399:	je     40d6d0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x8c0>
  40d39f:	mov    0x48(%rsp),%edi
  40d3a3:	cmp    %edi,0x20(%rsp)
  40d3a7:	jle    40d5b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x7a8>
  40d3ad:	mov    0x40(%rsp),%rdi
  40d3b2:	mov    0x10(%rsp),%rdx
  40d3b7:	movslq %edi,%rax
  40d3ba:	movslq 0x18(%rsp),%r14
  40d3bf:	imul   %rdx,%rax
  40d3c3:	mov    0x68(%rsp),%rcx
  40d3c8:	imul   %rdx,%r14
  40d3cc:	add    %rcx,%rax
  40d3cf:	add    %rbx,%rax
  40d3d2:	add    %rcx,%r14
  40d3d5:	mov    %rax,0x28(%rsp)
  40d3da:	lea    (%rbx,%r14,1),%rax
  40d3de:	mov    %rax,0x30(%rsp)
  40d3e3:	lea    0x0(%rbp,%rcx,1),%r12
  40d3e8:	mov    %edi,0x38(%rsp)
  40d3ec:	mov    0x50(%rsp),%r14
  40d3f1:	mov    0x48(%rsp),%eax
  40d3f5:	jmp    40d41e <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x60e>
  40d3f7:	nopw   0x0(%rax,%rax,1)
  40d400:	mov    0x58(%rsp),%eax
  40d404:	incq   0x28(%rsp)
  40d409:	inc    %r14
  40d40c:	incq   0x30(%rsp)
  40d411:	inc    %r12
  40d414:	cmp    %eax,0x20(%rsp)
  40d418:	jle    40d5b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x7a8>
  40d41e:	cmpb   $0x2,(%rbx,%r12,1)
  40d423:	sete   %dl
  40d426:	mov    0x8(%rsp),%rcx
  40d42b:	neg    %edx
  40d42d:	mov    %dl,(%rcx,%r12,1)
  40d431:	lea    0x1(%rax),%edx
  40d434:	mov    %edx,0x58(%rsp)
  40d438:	cmpb   $0x1,(%rbx,%r12,1)
  40d43d:	jne    40d400 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5f0>
  40d43f:	mov    0x20(%rsp),%ecx
  40d443:	cmp    %edx,%ecx
  40d445:	jle    40d540 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x730>
  40d44b:	cmp    %eax,%ecx
  40d44d:	jl     40d4f0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6e0>
  40d453:	cmp    0x18(%rsp),%r13d
  40d458:	jle    40d470 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x660>
  40d45a:	mov    0x30(%rsp),%rax
  40d45f:	cmpb   $0x2,-0x1(%rax)
  40d463:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d465:	cmpb   $0x2,(%rax)
  40d468:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d46a:	cmpb   $0x2,0x1(%rax)
  40d46e:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d470:	cmp    0x24(%rsp),%r13d
  40d475:	jle    40d490 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x680>
  40d477:	cmpb   $0x2,-0x1(%r14)
  40d47c:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d47e:	cmpb   $0x2,(%r14)
  40d482:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d484:	cmpb   $0x2,0x1(%r14)
  40d489:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d48b:	nopl   0x0(%rax,%rax,1)
  40d490:	cmp    0x38(%rsp),%r13d
  40d495:	jle    40d400 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5f0>
  40d49b:	mov    0x28(%rsp),%rax
  40d4a0:	cmpb   $0x2,-0x1(%rax)
  40d4a4:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d4a6:	cmpb   $0x2,(%rax)
  40d4a9:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d4ab:	cmpb   $0x2,0x1(%rax)
  40d4af:	jne    40d400 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5f0>
  40d4b5:	nopl   (%rax)
  40d4b8:	mov    0x8(%rsp),%rax
  40d4bd:	mov    %r12,0xd0(%rsp)
  40d4c5:	movb   $0xff,(%rax,%r12,1)
  40d4ca:	mov    0x8(%r15),%rsi
  40d4ce:	cmp    0x10(%r15),%rsi
  40d4d2:	je     40d8b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xaa8>
  40d4d8:	mov    %r12,(%rsi)
  40d4db:	add    $0x8,%rsi
  40d4df:	mov    %rsi,0x8(%r15)
  40d4e3:	jmpq   40d400 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5f0>
  40d4e8:	nopl   0x0(%rax,%rax,1)
  40d4f0:	cmp    0x18(%rsp),%r13d
  40d4f5:	jle    40d510 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x700>
  40d4f7:	mov    0x30(%rsp),%rax
  40d4fc:	cmpb   $0x2,(%rax)
  40d4ff:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d501:	cmpb   $0x2,0x1(%rax)
  40d505:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d507:	nopw   0x0(%rax,%rax,1)
  40d510:	cmp    0x24(%rsp),%r13d
  40d515:	jle    40d528 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x718>
  40d517:	cmpb   $0x2,(%r14)
  40d51b:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d51d:	cmpb   $0x2,0x1(%r14)
  40d522:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d524:	nopl   0x0(%rax)
  40d528:	cmp    0x38(%rsp),%r13d
  40d52d:	jle    40d400 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5f0>
  40d533:	mov    0x28(%rsp),%rax
  40d538:	jmpq   40d4a6 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x696>
  40d53d:	nopl   (%rax)
  40d540:	cmp    %eax,0x20(%rsp)
  40d544:	jl     40d770 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x960>
  40d54a:	cmp    0x18(%rsp),%r13d
  40d54f:	jle    40d570 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x760>
  40d551:	mov    0x30(%rsp),%rax
  40d556:	cmpb   $0x2,-0x1(%rax)
  40d55a:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d560:	cmpb   $0x2,(%rax)
  40d563:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d569:	nopl   0x0(%rax)
  40d570:	cmp    0x24(%rsp),%r13d
  40d575:	jle    40d590 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x780>
  40d577:	cmpb   $0x2,-0x1(%r14)
  40d57c:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d582:	cmpb   $0x2,(%r14)
  40d586:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d58c:	nopl   0x0(%rax)
  40d590:	cmp    0x38(%rsp),%r13d
  40d595:	jle    40d400 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5f0>
  40d59b:	mov    0x28(%rsp),%rax
  40d5a0:	cmpb   $0x2,-0x1(%rax)
  40d5a4:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d5aa:	cmpb   $0x2,(%rax)
  40d5ad:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d5b3:	nopl   0x0(%rax,%rax,1)
  40d5b8:	incl   0x24(%rsp)
  40d5bc:	mov    0x10(%rsp),%rdi
  40d5c1:	incq   0x40(%rsp)
  40d5c6:	add    %rdi,%rbp
  40d5c9:	mov    0x24(%rsp),%eax
  40d5cd:	incl   0x18(%rsp)
  40d5d1:	add    %rdi,0x50(%rsp)
  40d5d6:	cmp    0x60(%rsp),%eax
  40d5da:	jne    40d368 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x558>
  40d5e0:	cmp    $0x1,%r13d
  40d5e4:	je     40d8d0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xac0>
  40d5ea:	mov    0x10(%rsp),%rax
  40d5ef:	movslq 0x60(%rsp),%rbp
  40d5f4:	lea    -0x2(%r13),%r12d
  40d5f8:	imul   %rax,%rbp
  40d5fc:	mov    %r12d,0x24(%rsp)
  40d601:	imul   %rax,%r12
  40d605:	lea    (%rbx,%rbp,1),%rdx
  40d609:	mov    %rdx,0x18(%rsp)
  40d60e:	add    %rbx,%r12
  40d611:	xor    %eax,%eax
  40d613:	jmp    40d631 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x821>
  40d615:	nopl   (%rax)
  40d618:	mov    %r14d,%eax
  40d61b:	incq   0x18(%rsp)
  40d620:	inc    %r12
  40d623:	inc    %rbp
  40d626:	cmp    %r14d,0x20(%rsp)
  40d62b:	jle    40d8d0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xac0>
  40d631:	cmpb   $0x2,(%rbx,%rbp,1)
  40d635:	sete   %dl
  40d638:	mov    0x8(%rsp),%rdi
  40d63d:	neg    %edx
  40d63f:	mov    %dl,(%rdi,%rbp,1)
  40d642:	lea    0x1(%rax),%r14d
  40d646:	cmpb   $0x1,(%rbx,%rbp,1)
  40d64a:	jne    40d618 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x808>
  40d64c:	mov    0x20(%rsp),%esi
  40d650:	dec    %eax
  40d652:	cmp    %eax,%esi
  40d654:	setle  %dl
  40d657:	cmp    $0xffffffff,%eax
  40d65a:	sete   %al
  40d65d:	or     %eax,%edx
  40d65f:	cmp    %r14d,%esi
  40d662:	jle    40dc30 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xe20>
  40d668:	test   %dl,%dl
  40d66a:	je     40dbc0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xdb0>
  40d670:	cmp    0x24(%rsp),%r13d
  40d675:	jle    40d686 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x876>
  40d677:	cmpb   $0x2,(%r12)
  40d67c:	je     40d6a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x890>
  40d67e:	cmpb   $0x2,0x1(%r12)
  40d684:	je     40d6a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x890>
  40d686:	mov    0x18(%rsp),%rax
  40d68b:	cmpb   $0x2,(%rax)
  40d68e:	je     40d6a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x890>
  40d690:	cmpb   $0x2,0x1(%rax)
  40d694:	jne    40d618 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x808>
  40d696:	nopw   %cs:0x0(%rax,%rax,1)
  40d6a0:	mov    0x8(%rsp),%rax
  40d6a5:	mov    %rbp,0xd8(%rsp)
  40d6ad:	movb   $0xff,(%rax,%rbp,1)
  40d6b1:	mov    0x8(%r15),%rsi
  40d6b5:	cmp    0x10(%r15),%rsi
  40d6b9:	je     40dd2d <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xf1d>
  40d6bf:	mov    %rbp,(%rsi)
  40d6c2:	add    $0x8,%rsi
  40d6c6:	mov    %rsi,0x8(%r15)
  40d6ca:	jmpq   40d618 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x808>
  40d6cf:	nop
  40d6d0:	cmp    0x18(%rsp),%r13d
  40d6d5:	jle    40d6f6 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x8e6>
  40d6d7:	movslq 0x18(%rsp),%rax
  40d6dc:	imul   0x10(%rsp),%rax
  40d6e2:	cmpb   $0x2,(%rbx,%rax,1)
  40d6e6:	je     40d740 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x930>
  40d6e8:	cmpl   $0x1,0x20(%rsp)
  40d6ed:	je     40d70b <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x8fb>
  40d6ef:	cmpb   $0x2,0x1(%rbx,%rax,1)
  40d6f4:	je     40d740 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x930>
  40d6f6:	cmp    0x24(%rsp),%r13d
  40d6fb:	jle    40d70b <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x8fb>
  40d6fd:	cmpb   $0x0,0x64(%rsp)
  40d702:	jne    40d70b <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x8fb>
  40d704:	cmpb   $0x2,0x1(%rbx,%rbp,1)
  40d709:	je     40d740 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x930>
  40d70b:	cmp    0x40(%rsp),%r13d
  40d710:	jle    40d39f <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x58f>
  40d716:	movslq 0x40(%rsp),%rax
  40d71b:	imul   0x10(%rsp),%rax
  40d721:	cmpb   $0x2,(%rbx,%rax,1)
  40d725:	je     40d740 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x930>
  40d727:	cmpl   $0x1,0x20(%rsp)
  40d72c:	je     40d5b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x7a8>
  40d732:	cmpb   $0x2,0x1(%rbx,%rax,1)
  40d737:	jne    40d39f <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x58f>
  40d73d:	nopl   (%rax)
  40d740:	mov    0x8(%rsp),%rax
  40d745:	mov    %rbp,0xc8(%rsp)
  40d74d:	movb   $0xff,(%rax,%rbp,1)
  40d751:	mov    0x8(%r15),%rsi
  40d755:	cmp    0x10(%r15),%rsi
  40d759:	je     40dcb0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xea0>
  40d75f:	mov    %rbp,(%rsi)
  40d762:	add    $0x8,%rsi
  40d766:	mov    %rsi,0x8(%r15)
  40d76a:	jmpq   40d39f <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x58f>
  40d76f:	nop
  40d770:	cmp    0x18(%rsp),%r13d
  40d775:	jle    40d785 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x975>
  40d777:	mov    0x30(%rsp),%rax
  40d77c:	cmpb   $0x2,(%rax)
  40d77f:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d785:	cmp    0x24(%rsp),%r13d
  40d78a:	jle    40d796 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x986>
  40d78c:	cmpb   $0x2,(%r14)
  40d790:	je     40d4b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6a8>
  40d796:	cmp    0x38(%rsp),%r13d
  40d79b:	jle    40d400 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5f0>
  40d7a1:	mov    0x28(%rsp),%rax
  40d7a6:	jmpq   40d5aa <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x79a>
  40d7ab:	nopl   0x0(%rax,%rax,1)
  40d7b0:	cmp    0x28(%rsp),%r13d
  40d7b5:	jle    40d7d6 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9c6>
  40d7b7:	movslq 0x28(%rsp),%rax
  40d7bc:	imul   0x10(%rsp),%rax
  40d7c2:	cmpb   $0x2,(%rbx,%rax,1)
  40d7c6:	je     40d828 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa18>
  40d7c8:	cmpl   $0x1,0x20(%rsp)
  40d7cd:	je     40d7f0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9e0>
  40d7cf:	cmpb   $0x2,0x1(%rbx,%rax,1)
  40d7d4:	je     40d828 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa18>
  40d7d6:	cmp    0x30(%rsp),%r13d
  40d7db:	jle    40d7f0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9e0>
  40d7dd:	cmpb   $0x0,0x77(%rsp)
  40d7e2:	jne    40d7f0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x9e0>
  40d7e4:	mov    0x40(%rsp),%rax
  40d7e9:	cmpb   $0x2,0x1(%rbx,%rax,1)
  40d7ee:	je     40d828 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa18>
  40d7f0:	cmp    0x18(%rsp),%r13d
  40d7f5:	jle    40d0b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2a8>
  40d7fb:	movslq 0x18(%rsp),%rax
  40d800:	imul   0x10(%rsp),%rax
  40d806:	cmpb   $0x2,(%rbx,%rax,1)
  40d80a:	je     40d828 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa18>
  40d80c:	cmpl   $0x1,0x20(%rsp)
  40d811:	je     40d2c0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x4b0>
  40d817:	cmpb   $0x2,0x1(%rbx,%rax,1)
  40d81c:	jne    40d0b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2a8>
  40d822:	nopw   0x0(%rax,%rax,1)
  40d828:	mov    0x40(%rsp),%rax
  40d82d:	mov    0x8(%rsp),%rcx
  40d832:	mov    %rax,0xb8(%rsp)
  40d83a:	movb   $0xff,(%rcx,%rax,1)
  40d83e:	mov    0x8(%r15),%rsi
  40d842:	cmp    0x10(%r15),%rsi
  40d846:	je     40dc98 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xe88>
  40d84c:	mov    %rax,(%rsi)
  40d84f:	add    $0x8,%rsi
  40d853:	mov    %rsi,0x8(%r15)
  40d857:	jmpq   40d0b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2a8>
  40d85c:	nopl   0x0(%rax)
  40d860:	cmp    0x28(%rsp),%r13d
  40d865:	jle    40d875 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa65>
  40d867:	mov    0x38(%rsp),%rax
  40d86c:	cmpb   $0x2,(%rax)
  40d86f:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d875:	cmp    0x30(%rsp),%r13d
  40d87a:	jle    40d886 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xa76>
  40d87c:	cmpb   $0x2,0x0(%rbp)
  40d880:	je     40d1c8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x3b8>
  40d886:	cmp    0x18(%rsp),%r13d
  40d88b:	jg     40d2b6 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x4a6>
  40d891:	jmpq   40d110 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x300>
  40d896:	nopw   %cs:0x0(%rax,%rax,1)
  40d8a0:	lea    0xc0(%rsp),%rdx
  40d8a8:	mov    %r15,%rdi
  40d8ab:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40d8b0:	jmpq   40d110 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x300>
  40d8b5:	nopl   (%rax)
  40d8b8:	lea    0xd0(%rsp),%rdx
  40d8c0:	mov    %r15,%rdi
  40d8c3:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40d8c8:	jmpq   40d400 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x5f0>
  40d8cd:	nopl   (%rax)
  40d8d0:	mov    (%r15),%rax
  40d8d3:	cmp    %rax,0x8(%r15)
  40d8d7:	je     40cf80 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x170>
  40d8dd:	movslq 0x60(%rsp),%r14
  40d8e2:	xor    %r13d,%r13d
  40d8e5:	imul   0x10(%rsp),%r14
  40d8eb:	jmp    40d92a <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb1a>
  40d8ed:	nopl   (%rax)
  40d8f0:	lea    0x1(%rbp),%rax
  40d8f4:	cmpb   $0x1,0x1(%rbx,%rbp,1)
  40d8f9:	mov    %rax,0x100(%rsp)
  40d901:	je     40da50 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xc40>
  40d907:	cmp    %r14,%rbp
  40d90a:	jb     40d9d0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xbc0>
  40d910:	mov    0x8(%r15),%rsi
  40d914:	mov    (%r15),%rax
  40d917:	inc    %r13
  40d91a:	sub    %rax,%rsi
  40d91d:	sar    $0x3,%rsi
  40d921:	cmp    %r13,%rsi
  40d924:	jbe    40cf80 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x170>
  40d92a:	mov    (%rax,%r13,8),%rbp
  40d92e:	mov    0x10(%rsp),%rax
  40d933:	cmp    %rax,%rbp
  40d936:	jb     40d983 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb73>
  40d938:	mov    %rbp,%r12
  40d93b:	sub    %rax,%r12
  40d93e:	lea    -0x1(%r12),%rax
  40d943:	cmpb   $0x1,-0x1(%rbx,%r12,1)
  40d949:	mov    %rax,0xe0(%rsp)
  40d951:	je     40daf8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xce8>
  40d957:	cmpb   $0x1,(%rbx,%r12,1)
  40d95c:	mov    %r12,0xe8(%rsp)
  40d964:	je     40dac0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xcb0>
  40d96a:	lea    0x1(%r12),%rax
  40d96f:	cmpb   $0x1,0x1(%rbx,%r12,1)
  40d975:	mov    %rax,0xf0(%rsp)
  40d97d:	je     40da88 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xc78>
  40d983:	lea    -0x1(%rbp),%rax
  40d987:	cmpb   $0x1,-0x1(%rbx,%rbp,1)
  40d98c:	mov    %rax,0xf8(%rsp)
  40d994:	jne    40d8f0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xae0>
  40d99a:	mov    0x8(%rsp),%rcx
  40d99f:	lea    (%rcx,%rax,1),%rdx
  40d9a3:	cmpb   $0x0,(%rdx)
  40d9a6:	jne    40d8f0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xae0>
  40d9ac:	movb   $0xff,(%rdx)
  40d9af:	mov    0x8(%r15),%rsi
  40d9b3:	cmp    0x10(%r15),%rsi
  40d9b7:	je     40dcc8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xeb8>
  40d9bd:	mov    %rax,(%rsi)
  40d9c0:	add    $0x8,%rsi
  40d9c4:	mov    %rsi,0x8(%r15)
  40d9c8:	jmpq   40d8f0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xae0>
  40d9cd:	nopl   (%rax)
  40d9d0:	add    0x10(%rsp),%rbp
  40d9d5:	lea    -0x1(%rbp),%rax
  40d9d9:	cmpb   $0x1,-0x1(%rbx,%rbp,1)
  40d9de:	mov    %rax,0x108(%rsp)
  40d9e6:	je     40db68 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xd58>
  40d9ec:	cmpb   $0x1,(%rbx,%rbp,1)
  40d9f0:	mov    %rbp,0x110(%rsp)
  40d9f8:	je     40db30 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xd20>
  40d9fe:	lea    0x1(%rbp),%rax
  40da02:	cmpb   $0x1,0x1(%rbx,%rbp,1)
  40da07:	mov    %rax,0x118(%rsp)
  40da0f:	jne    40d910 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb00>
  40da15:	mov    0x8(%rsp),%rdi
  40da1a:	lea    (%rdi,%rax,1),%rdx
  40da1e:	cmpb   $0x0,(%rdx)
  40da21:	jne    40d910 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb00>
  40da27:	movb   $0xff,(%rdx)
  40da2a:	mov    0x8(%r15),%rsi
  40da2e:	cmp    0x10(%r15),%rsi
  40da32:	je     40dda8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xf98>
  40da38:	mov    %rax,(%rsi)
  40da3b:	add    $0x8,%rsi
  40da3f:	mov    %rsi,0x8(%r15)
  40da43:	jmpq   40d914 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb04>
  40da48:	nopl   0x0(%rax,%rax,1)
  40da50:	mov    0x8(%rsp),%rdx
  40da55:	add    %rax,%rdx
  40da58:	cmpb   $0x0,(%rdx)
  40da5b:	jne    40d907 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xaf7>
  40da61:	movb   $0xff,(%rdx)
  40da64:	mov    0x8(%r15),%rsi
  40da68:	cmp    0x10(%r15),%rsi
  40da6c:	je     40dce0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xed0>
  40da72:	mov    %rax,(%rsi)
  40da75:	add    $0x8,%rsi
  40da79:	mov    %rsi,0x8(%r15)
  40da7d:	jmpq   40d907 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xaf7>
  40da82:	nopw   0x0(%rax,%rax,1)
  40da88:	mov    0x8(%rsp),%rcx
  40da8d:	lea    (%rcx,%rax,1),%rdx
  40da91:	cmpb   $0x0,(%rdx)
  40da94:	jne    40d983 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb73>
  40da9a:	movb   $0xff,(%rdx)
  40da9d:	mov    0x8(%r15),%rsi
  40daa1:	cmp    0x10(%r15),%rsi
  40daa5:	je     40dd60 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xf50>
  40daab:	mov    %rax,(%rsi)
  40daae:	add    $0x8,%rsi
  40dab2:	mov    %rsi,0x8(%r15)
  40dab6:	jmpq   40d983 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb73>
  40dabb:	nopl   0x0(%rax,%rax,1)
  40dac0:	mov    0x8(%rsp),%rax
  40dac5:	add    %r12,%rax
  40dac8:	cmpb   $0x0,(%rax)
  40dacb:	jne    40d96a <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb5a>
  40dad1:	movb   $0xff,(%rax)
  40dad4:	mov    0x8(%r15),%rsi
  40dad8:	cmp    0x10(%r15),%rsi
  40dadc:	je     40dd78 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xf68>
  40dae2:	mov    %r12,(%rsi)
  40dae5:	add    $0x8,%rsi
  40dae9:	mov    %rsi,0x8(%r15)
  40daed:	jmpq   40d96a <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb5a>
  40daf2:	nopw   0x0(%rax,%rax,1)
  40daf8:	mov    0x8(%rsp),%rdx
  40dafd:	add    %rax,%rdx
  40db00:	cmpb   $0x0,(%rdx)
  40db03:	jne    40d957 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb47>
  40db09:	movb   $0xff,(%rdx)
  40db0c:	mov    0x8(%r15),%rsi
  40db10:	cmp    0x10(%r15),%rsi
  40db14:	je     40dd48 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xf38>
  40db1a:	mov    %rax,(%rsi)
  40db1d:	add    $0x8,%rsi
  40db21:	mov    %rsi,0x8(%r15)
  40db25:	jmpq   40d957 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb47>
  40db2a:	nopw   0x0(%rax,%rax,1)
  40db30:	mov    0x8(%rsp),%rax
  40db35:	add    %rbp,%rax
  40db38:	cmpb   $0x0,(%rax)
  40db3b:	jne    40d9fe <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xbee>
  40db41:	movb   $0xff,(%rax)
  40db44:	mov    0x8(%r15),%rsi
  40db48:	cmp    0x10(%r15),%rsi
  40db4c:	je     40dd90 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xf80>
  40db52:	mov    %rbp,(%rsi)
  40db55:	add    $0x8,%rsi
  40db59:	mov    %rsi,0x8(%r15)
  40db5d:	jmpq   40d9fe <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xbee>
  40db62:	nopw   0x0(%rax,%rax,1)
  40db68:	mov    0x8(%rsp),%rcx
  40db6d:	lea    (%rcx,%rax,1),%rdx
  40db71:	cmpb   $0x0,(%rdx)
  40db74:	jne    40d9ec <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xbdc>
  40db7a:	movb   $0xff,(%rdx)
  40db7d:	mov    0x8(%r15),%rsi
  40db81:	cmp    0x10(%r15),%rsi
  40db85:	je     40ddc0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xfb0>
  40db8b:	mov    %rax,(%rsi)
  40db8e:	add    $0x8,%rsi
  40db92:	mov    %rsi,0x8(%r15)
  40db96:	jmpq   40d9ec <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xbdc>
  40db9b:	nopl   0x0(%rax,%rax,1)
  40dba0:	cmpb   $0x2,0x1(%rbx,%rbp,1)
  40dba5:	je     40cf48 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40dbab:	cmp    $0x1,%r13d
  40dbaf:	jle    40cec8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40dbb5:	jmpq   40cf32 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x122>
  40dbba:	nopw   0x0(%rax,%rax,1)
  40dbc0:	cmp    0x24(%rsp),%r13d
  40dbc5:	jle    40dbea <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xdda>
  40dbc7:	cmpb   $0x2,-0x1(%r12)
  40dbcd:	je     40d6a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x890>
  40dbd3:	cmpb   $0x2,(%r12)
  40dbd8:	je     40d6a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x890>
  40dbde:	cmpb   $0x2,0x1(%r12)
  40dbe4:	je     40d6a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x890>
  40dbea:	mov    0x18(%rsp),%rax
  40dbef:	cmpb   $0x2,-0x1(%rax)
  40dbf3:	jne    40d68b <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x87b>
  40dbf9:	jmpq   40d6a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x890>
  40dbfe:	xchg   %ax,%ax
  40dc00:	cmpb   $0x2,-0x1(%rbx,%rbp,1)
  40dc05:	je     40cf48 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40dc0b:	cmp    $0x1,%r13d
  40dc0f:	jle    40cec8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40dc15:	cmpb   $0x2,-0x1(%r12)
  40dc1b:	jne    40cfb2 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x1a2>
  40dc21:	jmpq   40cf48 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x138>
  40dc26:	nopw   %cs:0x0(%rax,%rax,1)
  40dc30:	test   %dl,%dl
  40dc32:	jne    40dcf8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xee8>
  40dc38:	cmp    0x24(%rsp),%r13d
  40dc3d:	jle    40dc56 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xe46>
  40dc3f:	cmpb   $0x2,-0x1(%r12)
  40dc45:	je     40d6a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x890>
  40dc4b:	cmpb   $0x2,(%r12)
  40dc50:	je     40d6a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x890>
  40dc56:	mov    0x18(%rsp),%rax
  40dc5b:	cmpb   $0x2,-0x1(%rax)
  40dc5f:	jne    40dd0f <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xeff>
  40dc65:	jmpq   40d6a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x890>
  40dc6a:	nopw   0x0(%rax,%rax,1)
  40dc70:	lea    -0x2(%rdi),%eax
  40dc73:	and    $0xffffffe0,%eax
  40dc76:	mov    %eax,%ebp
  40dc78:	sar    $0x5,%ebp
  40dc7b:	inc    %ebp
  40dc7d:	movslq %ebp,%rbp
  40dc80:	mov    %eax,0x4c(%rsp)
  40dc84:	lea    0x0(,%rbp,4),%rax
  40dc8c:	jmpq   40ce7c <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x6c>
  40dc91:	nopl   0x0(%rax)
  40dc98:	lea    0xb8(%rsp),%rdx
  40dca0:	mov    %r15,%rdi
  40dca3:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40dca8:	jmpq   40d0b8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x2a8>
  40dcad:	nopl   (%rax)
  40dcb0:	lea    0xc8(%rsp),%rdx
  40dcb8:	mov    %r15,%rdi
  40dcbb:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40dcc0:	jmpq   40d39f <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x58f>
  40dcc5:	nopl   (%rax)
  40dcc8:	lea    0xf8(%rsp),%rdx
  40dcd0:	mov    %r15,%rdi
  40dcd3:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40dcd8:	jmpq   40d8f0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xae0>
  40dcdd:	nopl   (%rax)
  40dce0:	lea    0x100(%rsp),%rdx
  40dce8:	mov    %r15,%rdi
  40dceb:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40dcf0:	jmpq   40d907 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xaf7>
  40dcf5:	nopl   (%rax)
  40dcf8:	cmp    0x24(%rsp),%r13d
  40dcfd:	jle    40dd0a <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xefa>
  40dcff:	cmpb   $0x2,(%r12)
  40dd04:	je     40d6a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x890>
  40dd0a:	mov    0x18(%rsp),%rax
  40dd0f:	cmpb   $0x2,(%rax)
  40dd12:	jne    40d618 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x808>
  40dd18:	jmpq   40d6a0 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x890>
  40dd1d:	nopl   (%rax)
  40dd20:	movl   $0x1,0x24(%rsp)
  40dd28:	jmpq   40d310 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x500>
  40dd2d:	lea    0xd8(%rsp),%rdx
  40dd35:	mov    %r15,%rdi
  40dd38:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40dd3d:	jmpq   40d618 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0x808>
  40dd42:	nopw   0x0(%rax,%rax,1)
  40dd48:	lea    0xe0(%rsp),%rdx
  40dd50:	mov    %r15,%rdi
  40dd53:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40dd58:	jmpq   40d957 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb47>
  40dd5d:	nopl   (%rax)
  40dd60:	lea    0xf0(%rsp),%rdx
  40dd68:	mov    %r15,%rdi
  40dd6b:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40dd70:	jmpq   40d983 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb73>
  40dd75:	nopl   (%rax)
  40dd78:	lea    0xe8(%rsp),%rdx
  40dd80:	mov    %r15,%rdi
  40dd83:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40dd88:	jmpq   40d96a <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb5a>
  40dd8d:	nopl   (%rax)
  40dd90:	lea    0x110(%rsp),%rdx
  40dd98:	mov    %r15,%rdi
  40dd9b:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40dda0:	jmpq   40d9fe <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xbee>
  40dda5:	nopl   (%rax)
  40dda8:	lea    0x118(%rsp),%rdx
  40ddb0:	mov    %r15,%rdi
  40ddb3:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40ddb8:	jmpq   40d910 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb00>
  40ddbd:	nopl   (%rax)
  40ddc0:	lea    0x108(%rsp),%rdx
  40ddc8:	mov    %r15,%rdi
  40ddcb:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40ddd0:	jmpq   40d9ec <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xbdc>
  40ddd5:	nopl   (%rax)
  40ddd8:	lea    0xb0(%rsp),%rdx
  40dde0:	mov    %r15,%rdi
  40dde3:	callq  40de00 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long&&)>
  40dde8:	jmpq   40cec8 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&)+0xb8>
  40dded:	mov    %rax,%rbx
  40ddf0:	jmpq   401b78 <hysteresis_slab(int, int, unsigned char const*, unsigned char*, std::vector<unsigned long, std::allocator<unsigned long> >&) [clone .cold.62]>
  40ddf5:	nopw   %cs:0x0(%rax,%rax,1)
  40ddff:	nop
