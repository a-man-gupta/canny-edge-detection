0000000000401aca <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone .cold.138]>:
  401aca:	mov    0xb0(%rsp),%rdi
  401ad2:	test   %rdi,%rdi
  401ad5:	je     401b17 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone .cold.138]+0x4d>
  401ad7:	vzeroupper 
  401ada:	callq  401770 <operator delete(void*)@plt>
  401adf:	mov    0x90(%rsp),%rdi
  401ae7:	test   %rdi,%rdi
  401aea:	je     401af1 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone .cold.138]+0x27>
  401aec:	callq  401770 <operator delete(void*)@plt>
  401af1:	mov    0x70(%rsp),%rdi
  401af6:	test   %rdi,%rdi
  401af9:	je     401b00 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone .cold.138]+0x36>
  401afb:	callq  401770 <operator delete(void*)@plt>
  401b00:	mov    0x50(%rsp),%rdi
  401b05:	test   %rdi,%rdi
  401b08:	je     401b0f <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone .cold.138]+0x45>
  401b0a:	callq  401770 <operator delete(void*)@plt>
  401b0f:	mov    %rbx,%rdi
  401b12:	callq  401910 <_Unwind_Resume@plt>
  401b17:	vzeroupper 
  401b1a:	jmp    401adf <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone .cold.138]+0x15>
  401b1c:	mov    $0x4018e0,%edx
  401b21:	mov    $0x60fda8,%esi
  401b26:	mov    %rbx,%rdi
  401b29:	callq  401900 <__cxa_throw@plt>
  401b2e:	mov    %rbx,%rdi
  401b31:	vzeroupper 
  401b34:	callq  401750 <__cxa_free_exception@plt>
  401b39:	mov    %rbp,%rdi
  401b3c:	callq  401910 <_Unwind_Resume@plt>

00000000004049c0 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)>:
  4049c0:	lea    0x8(%rsp),%r10
  4049c5:	and    $0xffffffffffffffe0,%rsp
  4049c9:	pushq  -0x8(%r10)
  4049cd:	push   %rbp
  4049ce:	mov    %rsp,%rbp
  4049d1:	push   %r15
  4049d3:	push   %r14
  4049d5:	push   %r13
  4049d7:	push   %r12
  4049d9:	push   %r10
  4049db:	push   %rbx
  4049dc:	sub    $0x160,%rsp
  4049e3:	mov    0x8(%r10),%ebx
  4049e7:	mov    (%r10),%eax
  4049ea:	mov    %ebx,-0x120(%rbp)
  4049f0:	mov    0x18(%r10),%ebx
  4049f4:	mov    %eax,-0x15c(%rbp)
  4049fa:	mov    %ebx,-0x160(%rbp)
  404a00:	mov    0x20(%r10),%ebx
  404a04:	mov    %rsi,-0x158(%rbp)
  404a0b:	mov    %ebx,-0x164(%rbp)
  404a11:	mov    %eax,%ebx
  404a13:	add    $0x7e,%eax
  404a16:	add    $0x3f,%ebx
  404a19:	cmovns %ebx,%eax
  404a1c:	mov    0x28(%r10),%r11
  404a20:	and    $0xffffffc0,%eax
  404a23:	mov    %eax,%ebx
  404a25:	mov    %eax,-0x128(%rbp)
  404a2b:	add    $0x40,%eax
  404a2e:	add    $0x21,%ebx
  404a31:	cmovns %ebx,%eax
  404a34:	mov    %r8d,%ebx
  404a37:	and    $0xffffffe0,%eax
  404a3a:	mov    %eax,%esi
  404a3c:	sub    $0x4,%ebx
  404a3f:	mov    %eax,-0x11c(%rbp)
  404a45:	mov    $0x0,%eax
  404a4a:	cmovns %ebx,%eax
  404a4d:	mov    %rdi,-0x98(%rbp)
  404a54:	mov    %eax,%ebx
  404a56:	mov    %eax,-0xe4(%rbp)
  404a5c:	lea    0x2(%rsi,%r8,1),%eax
  404a61:	cmp    %edx,%eax
  404a63:	cmovg  %edx,%eax
  404a66:	mov    %edx,-0xf8(%rbp)
  404a6c:	mov    %eax,%esi
  404a6e:	sub    %ebx,%esi
  404a70:	mov    0x8(%r11),%rbx
  404a74:	mov    %esi,-0x64(%rbp)
  404a77:	mov    %rbx,-0x70(%rbp)
  404a7b:	mov    %r9d,%esi
  404a7e:	lea    -0x1(%rcx),%ebx
  404a81:	mov    %r8d,-0x118(%rbp)
  404a88:	mov    %r9d,-0x124(%rbp)
  404a8f:	mov    %r11,-0xb8(%rbp)
  404a96:	mov    %ebx,-0xf4(%rbp)
  404a9c:	movl   $0xfffffffe,-0x9c(%rbp)
  404aa6:	sub    $0x2,%esi
  404aa9:	js     404ab9 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xf9>
  404aab:	cmp    %esi,%ebx
  404aad:	cmovg  %esi,%ebx
  404ab0:	lea    -0x2(%rbx),%ebx
  404ab3:	mov    %ebx,-0x9c(%rbp)
  404ab9:	mov    -0xf4(%rbp),%ebx
  404abf:	mov    -0xe4(%rbp),%r11d
  404ac6:	add    %ebx,%ebx
  404ac8:	mov    %ebx,-0x68(%rbp)
  404acb:	mov    -0x118(%rbp),%ebx
  404ad1:	mov    $0x0,%edi
  404ad6:	lea    -0x2(%rbx),%ecx
  404ad9:	mov    -0x11c(%rbp),%ebx
  404adf:	mov    %esi,-0xc0(%rbp)
  404ae5:	lea    0x2(%rbx),%edx
  404ae8:	mov    %r11d,%ebx
  404aeb:	sub    %ecx,%ebx
  404aed:	cmovns %ebx,%edi
  404af0:	sub    %ecx,%eax
  404af2:	cmp    %edx,%eax
  404af4:	cmovg  %edx,%eax
  404af7:	movslq %edx,%rdx
  404afa:	mov    %eax,%r13d
  404afd:	lea    0xf(%rdi),%eax
  404b00:	mov    %eax,-0xa0(%rbp)
  404b06:	movslq %r13d,%rax
  404b09:	lea    (%rdx,%rdx,1),%r9
  404b0d:	add    %rax,%rax
  404b10:	mov    -0xb8(%rbp),%rdx
  404b17:	mov    %rax,-0xe0(%rbp)
  404b1e:	movslq -0x64(%rbp),%rax
  404b22:	lea    0x8bc0(%rdx),%r14
  404b29:	lea    -0x1(%r14,%rax,1),%rax
  404b2e:	mov    %rax,-0xd0(%rbp)
  404b35:	lea    -0x1(%rdi),%eax
  404b38:	inc    %rax
  404b3b:	mov    %ebx,-0xd4(%rbp)
  404b41:	lea    0x40(%rdx),%rbx
  404b45:	mov    %rax,-0xf0(%rbp)
  404b4c:	lea    (%rbx,%rax,2),%rax
  404b50:	mov    %rax,-0xc8(%rbp)
  404b57:	lea    0xe40(%rdx),%rax
  404b5e:	sub    %r11d,%ecx
  404b61:	mov    %rax,-0x110(%rbp)
  404b68:	lea    0x10(%r10),%rax
  404b6c:	mov    %rax,-0x80(%rbp)
  404b70:	movslq %ecx,%rax
  404b73:	add    %rdx,%rax
  404b76:	mov    %rbx,%r15
  404b79:	mov    %edi,-0xd8(%rbp)
  404b7f:	mov    %r9,-0x178(%rbp)
  404b86:	mov    %rbx,-0x100(%rbp)
  404b8d:	mov    %ecx,-0xe8(%rbp)
  404b93:	mov    %rax,-0x108(%rbp)
  404b9a:	mov    %r13d,-0x90(%rbp)
  404ba1:	add    %r9,%r15
  404ba4:	mov    %r14,-0xb0(%rbp)
  404bab:	mov    -0x70(%rbp),%r14
  404baf:	mov    %r15,-0xa8(%rbp)
  404bb6:	mov    $0xffffffff,%r12d
  404bbc:	mov    %rbx,%r15
  404bbf:	mov    -0xc0(%rbp),%eax
  404bc5:	mov    $0x2,%ebx
  404bca:	test   %eax,%eax
  404bcc:	js     404bde <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x21e>
  404bce:	mov    -0xf4(%rbp),%ecx
  404bd4:	mov    %eax,%ebx
  404bd6:	cmp    %eax,%ecx
  404bd8:	cmovle %ecx,%ebx
  404bdb:	add    $0x2,%ebx
  404bde:	sub    -0x9c(%rbp),%ebx
  404be4:	cmp    %ebx,%r12d
  404be7:	jge    404cb3 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x2f3>
  404bed:	movslq -0xf8(%rbp),%rax
  404bf4:	mov    %rax,-0x78(%rbp)
  404bf8:	movslq -0xe4(%rbp),%rax
  404bff:	mov    %rax,-0x88(%rbp)
  404c06:	jmp    404c73 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x2b3>
  404c08:	nopl   0x0(%rax,%rax,1)
  404c10:	sub    %edx,%ecx
  404c12:	cmp    %edx,%ecx
  404c14:	mov    %edx,%edi
  404c16:	cmovle %ecx,%edi
  404c19:	movslq %edi,%rdi
  404c1c:	imul   -0x78(%rbp),%rdi
  404c21:	mov    -0x64(%rbp),%edx
  404c24:	mov    %r13,%rsi
  404c27:	add    -0x88(%rbp),%rdi
  404c2e:	add    -0x98(%rbp),%rdi
  404c35:	callq  408100 <gaussian_expand_row(unsigned char const*, short*, int)>
  404c3a:	mov    $0x66666667,%eax
  404c3f:	imul   %r12d
  404c42:	mov    %r12d,%eax
  404c45:	sar    $0x1f,%eax
  404c48:	sar    %edx
  404c4a:	sub    %eax,%edx
  404c4c:	lea    (%rdx,%rdx,4),%eax
  404c4f:	mov    %r12d,%esi
  404c52:	sub    %eax,%esi
  404c54:	mov    %r14,%rdi
  404c57:	callq  4080e0 <gaussian_ring_row(GaussianWork*, int)>
  404c5c:	mov    -0x80(%rbp),%rcx
  404c60:	mov    -0x64(%rbp),%edx
  404c63:	mov    %rax,%rsi
  404c66:	mov    %r13,%rdi
  404c69:	callq  408110 <gaussian_horiz_row(short const*, short*, int, GaussQ15 const&)>
  404c6e:	cmp    %r12d,%ebx
  404c71:	je     404cb0 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x2f0>
  404c73:	mov    %r14,%rdi
  404c76:	callq  4080d0 <gaussian_scratch(GaussianWork*)>
  404c7b:	mov    %rax,%r13
  404c7e:	mov    -0x9c(%rbp),%eax
  404c84:	inc    %r12d
  404c87:	add    %r12d,%eax
  404c8a:	mov    -0x68(%rbp),%ecx
  404c8d:	cltd   
  404c8e:	idiv   %ecx
  404c90:	test   %edx,%edx
  404c92:	jns    404c10 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x250>
  404c98:	mov    %edx,%edi
  404c9a:	lea    (%rcx,%rdx,1),%eax
  404c9d:	neg    %edi
  404c9f:	cmp    %edi,%eax
  404ca1:	cmovle %eax,%edi
  404ca4:	jmpq   404c19 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x259>
  404ca9:	nopl   0x0(%rax)
  404cb0:	mov    %ebx,%r12d
  404cb3:	xor    %r13d,%r13d
  404cb6:	sub    $0x4,%ebx
  404cb9:	lea    (%rbx,%r13,1),%esi
  404cbd:	mov    $0x66666667,%eax
  404cc2:	imul   %esi
  404cc4:	mov    %esi,%eax
  404cc6:	sar    $0x1f,%eax
  404cc9:	sar    %edx
  404ccb:	sub    %eax,%edx
  404ccd:	lea    (%rdx,%rdx,4),%eax
  404cd0:	sub    %eax,%esi
  404cd2:	mov    %r14,%rdi
  404cd5:	callq  4080e0 <gaussian_ring_row(GaussianWork*, int)>
  404cda:	mov    %rax,-0x60(%rbp,%r13,8)
  404cdf:	inc    %r13
  404ce2:	cmp    $0x5,%r13
  404ce6:	jne    404cb9 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x2f9>
  404ce8:	mov    -0x80(%rbp),%rcx
  404cec:	mov    -0x64(%rbp),%edx
  404cef:	mov    -0xb0(%rbp),%rsi
  404cf6:	lea    -0x60(%rbp),%rdi
  404cfa:	callq  408350 <gaussian_vert_row(short const* const*, unsigned char*, int, GaussQ15 const&)>
  404cff:	mov    -0xb8(%rbp),%rax
  404d06:	mov    -0xd4(%rbp),%ecx
  404d0c:	movzbl 0x8bc0(%rax),%edx
  404d13:	mov    %r15,%rax
  404d16:	test   %ecx,%ecx
  404d18:	jle    404d34 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x374>
  404d1a:	mov    -0xc8(%rbp),%rcx
  404d21:	nopl   0x0(%rax)
  404d28:	mov    %dx,(%rax)
  404d2b:	add    $0x2,%rax
  404d2f:	cmp    %rcx,%rax
  404d32:	jne    404d28 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x368>
  404d34:	mov    -0x90(%rbp),%ebx
  404d3a:	cmp    %ebx,-0xa0(%rbp)
  404d40:	jge    405647 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xc87>
  404d46:	mov    -0xd8(%rbp),%eax
  404d4c:	mov    -0x108(%rbp),%rdi
  404d53:	add    $0x10,%eax
  404d56:	mov    %ebx,%esi
  404d58:	cltq   
  404d5a:	nopw   0x0(%rax,%rax,1)
  404d60:	vpmovzxbw 0x8bb0(%rax,%rdi,1),%ymm0
  404d6a:	mov    %eax,%edx
  404d6c:	vmovdqu %ymm0,-0x20(%r15,%rax,2)
  404d73:	add    $0x10,%rax
  404d77:	lea    -0x1(%rax),%ecx
  404d7a:	cmp    %ecx,%esi
  404d7c:	jg     404d60 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x3a0>
  404d7e:	vzeroupper 
  404d81:	cmp    %edx,-0x90(%rbp)
  404d87:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404d8d:	mov    -0xe8(%rbp),%ebx
  404d93:	mov    -0xb0(%rbp),%rsi
  404d9a:	lea    (%rbx,%rdx,1),%eax
  404d9d:	cltq   
  404d9f:	movzbl (%rsi,%rax,1),%eax
  404da3:	movslq %edx,%rcx
  404da6:	mov    -0x90(%rbp),%edi
  404dac:	mov    %ax,(%r15,%rcx,2)
  404db1:	lea    0x1(%rdx),%eax
  404db4:	cmp    %eax,%edi
  404db6:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404dbc:	movslq %eax,%rcx
  404dbf:	add    %ebx,%eax
  404dc1:	cltq   
  404dc3:	movzbl (%rsi,%rax,1),%eax
  404dc7:	mov    %ax,(%r15,%rcx,2)
  404dcc:	lea    0x2(%rdx),%eax
  404dcf:	cmp    %edi,%eax
  404dd1:	jge    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404dd7:	movslq %eax,%rcx
  404dda:	add    %ebx,%eax
  404ddc:	cltq   
  404dde:	movzbl (%rsi,%rax,1),%eax
  404de2:	mov    %ax,(%r15,%rcx,2)
  404de7:	lea    0x3(%rdx),%eax
  404dea:	cmp    %eax,%edi
  404dec:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404df2:	movslq %eax,%rcx
  404df5:	add    %ebx,%eax
  404df7:	cltq   
  404df9:	movzbl (%rsi,%rax,1),%eax
  404dfd:	mov    %ax,(%r15,%rcx,2)
  404e02:	lea    0x4(%rdx),%eax
  404e05:	cmp    %eax,%edi
  404e07:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404e0d:	movslq %eax,%rcx
  404e10:	add    %ebx,%eax
  404e12:	cltq   
  404e14:	movzbl (%rsi,%rax,1),%eax
  404e18:	mov    %ax,(%r15,%rcx,2)
  404e1d:	lea    0x5(%rdx),%eax
  404e20:	cmp    %eax,%edi
  404e22:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404e28:	movslq %eax,%rcx
  404e2b:	add    %ebx,%eax
  404e2d:	cltq   
  404e2f:	movzbl (%rsi,%rax,1),%eax
  404e33:	mov    %ax,(%r15,%rcx,2)
  404e38:	lea    0x6(%rdx),%eax
  404e3b:	cmp    %eax,%edi
  404e3d:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404e43:	movslq %eax,%rcx
  404e46:	add    %ebx,%eax
  404e48:	cltq   
  404e4a:	movzbl (%rsi,%rax,1),%eax
  404e4e:	mov    %ax,(%r15,%rcx,2)
  404e53:	lea    0x7(%rdx),%eax
  404e56:	cmp    %eax,%edi
  404e58:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404e5e:	movslq %eax,%rcx
  404e61:	add    %ebx,%eax
  404e63:	cltq   
  404e65:	movzbl (%rsi,%rax,1),%eax
  404e69:	mov    %ax,(%r15,%rcx,2)
  404e6e:	lea    0x8(%rdx),%eax
  404e71:	cmp    %eax,%edi
  404e73:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404e79:	movslq %eax,%rcx
  404e7c:	add    %ebx,%eax
  404e7e:	cltq   
  404e80:	movzbl (%rsi,%rax,1),%eax
  404e84:	mov    %ax,(%r15,%rcx,2)
  404e89:	lea    0x9(%rdx),%eax
  404e8c:	cmp    %eax,%edi
  404e8e:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404e94:	movslq %eax,%rcx
  404e97:	add    %ebx,%eax
  404e99:	cltq   
  404e9b:	movzbl (%rsi,%rax,1),%eax
  404e9f:	mov    %ax,(%r15,%rcx,2)
  404ea4:	lea    0xa(%rdx),%eax
  404ea7:	cmp    %eax,%edi
  404ea9:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404eaf:	movslq %eax,%rcx
  404eb2:	add    %ebx,%eax
  404eb4:	cltq   
  404eb6:	movzbl (%rsi,%rax,1),%eax
  404eba:	mov    %ax,(%r15,%rcx,2)
  404ebf:	lea    0xb(%rdx),%eax
  404ec2:	cmp    %eax,%edi
  404ec4:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404ec6:	movslq %eax,%rcx
  404ec9:	add    %ebx,%eax
  404ecb:	cltq   
  404ecd:	movzbl (%rsi,%rax,1),%eax
  404ed1:	mov    %ax,(%r15,%rcx,2)
  404ed6:	lea    0xc(%rdx),%eax
  404ed9:	cmp    %eax,%edi
  404edb:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404edd:	movslq %eax,%rcx
  404ee0:	add    %ebx,%eax
  404ee2:	cltq   
  404ee4:	movzbl (%rsi,%rax,1),%eax
  404ee8:	mov    %ax,(%r15,%rcx,2)
  404eed:	lea    0xd(%rdx),%eax
  404ef0:	cmp    %eax,%edi
  404ef2:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404ef4:	movslq %eax,%rcx
  404ef7:	add    %ebx,%eax
  404ef9:	cltq   
  404efb:	movzbl (%rsi,%rax,1),%eax
  404eff:	mov    %ax,(%r15,%rcx,2)
  404f04:	lea    0xe(%rdx),%eax
  404f07:	cmp    %eax,%edi
  404f09:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404f0b:	movslq %eax,%rcx
  404f0e:	add    %ebx,%eax
  404f10:	cltq   
  404f12:	movzbl (%rsi,%rax,1),%eax
  404f16:	add    $0xf,%edx
  404f19:	mov    %ax,(%r15,%rcx,2)
  404f1e:	cmp    %edx,%edi
  404f20:	jle    404f38 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x578>
  404f22:	movslq %edx,%rcx
  404f25:	add    %ebx,%edx
  404f27:	movslq %edx,%rax
  404f2a:	movzbl (%rsi,%rax,1),%eax
  404f2e:	mov    %ax,(%r15,%rcx,2)
  404f33:	nopl   0x0(%rax,%rax,1)
  404f38:	mov    -0xe0(%rbp),%rax
  404f3f:	mov    -0xd0(%rbp),%rbx
  404f46:	add    %r15,%rax
  404f49:	movzbl (%rbx),%edx
  404f4c:	mov    -0xa8(%rbp),%rcx
  404f53:	cmp    %rax,-0xa8(%rbp)
  404f5a:	je     404f6c <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x5ac>
  404f5c:	nopl   0x0(%rax)
  404f60:	mov    %dx,(%rax)
  404f63:	add    $0x2,%rax
  404f67:	cmp    %rcx,%rax
  404f6a:	jne    404f60 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x5a0>
  404f6c:	add    $0x380,%r15
  404f73:	incl   -0xc0(%rbp)
  404f79:	addq   $0x380,-0xa8(%rbp)
  404f84:	addq   $0x380,-0xc8(%rbp)
  404f8f:	cmp    -0x110(%rbp),%r15
  404f96:	jne    404bbf <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x1ff>
  404f9c:	mov    -0x120(%rbp),%esi
  404fa2:	mov    -0xb0(%rbp),%r14
  404fa9:	mov    -0x90(%rbp),%r13d
  404fb0:	test   %esi,%esi
  404fb2:	jle    4055c3 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xc03>
  404fb8:	mov    -0xb8(%rbp),%rbx
  404fbf:	movslq -0xf8(%rbp),%rcx
  404fc6:	lea    0x2a40(%rbx),%rax
  404fcd:	mov    %rax,-0xc8(%rbp)
  404fd4:	lea    0x0(,%rcx,8),%rax
  404fdc:	mov    %rax,-0x180(%rbp)
  404fe3:	movslq -0x124(%rbp),%rax
  404fea:	movslq -0x118(%rbp),%rdi
  404ff1:	mov    %rax,%rdx
  404ff4:	imul   %rcx,%rax
  404ff8:	mov    %rcx,-0xa8(%rbp)
  404fff:	mov    %rdi,-0x170(%rbp)
  405006:	add    %rdi,%rax
  405009:	add    -0x158(%rbp),%rax
  405010:	mov    %rax,-0x118(%rbp)
  405017:	lea    0x2(%rdx),%eax
  40501a:	mov    %eax,-0x108(%rbp)
  405020:	lea    -0x1(%rsi),%eax
  405023:	and    $0xfffffff8,%eax
  405026:	inc    %eax
  405028:	mov    %eax,-0x124(%rbp)
  40502e:	lea    (%rcx,%rcx,1),%rax
  405032:	mov    %rax,-0x140(%rbp)
  405039:	mov    -0x178(%rbp),%rax
  405040:	movl   $0x1,-0xf8(%rbp)
  40504a:	add    $0xe00,%rax
  405050:	mov    %rax,-0x130(%rbp)
  405057:	lea    0x2a42(%rbx),%rax
  40505e:	mov    %rax,-0x138(%rbp)
  405065:	lea    0x4442(%rbx),%rax
  40506c:	mov    %rax,-0x148(%rbp)
  405073:	movslq -0xe8(%rbp),%rax
  40507a:	mov    %r13d,-0x78(%rbp)
  40507e:	add    %rbx,%rax
  405081:	mov    %rax,-0xc0(%rbp)
  405088:	mov    -0x100(%rbp),%rax
  40508f:	mov    -0x110(%rbp),%r13
  405096:	add    -0x130(%rbp),%rax
  40509d:	mov    %rax,-0x88(%rbp)
  4050a4:	mov    -0x108(%rbp),%eax
  4050aa:	mov    %r13,%rbx
  4050ad:	mov    %eax,-0xb0(%rbp)
  4050b3:	nopl   0x0(%rax,%rax,1)
  4050b8:	mov    -0xb0(%rbp),%eax
  4050be:	mov    $0x2,%r15d
  4050c4:	test   %eax,%eax
  4050c6:	js     4050db <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x71b>
  4050c8:	mov    -0xf4(%rbp),%ecx
  4050ce:	mov    %eax,%r15d
  4050d1:	cmp    %eax,%ecx
  4050d3:	cmovle %ecx,%r15d
  4050d7:	add    $0x2,%r15d
  4050db:	sub    -0x9c(%rbp),%r15d
  4050e2:	cmp    %r15d,%r12d
  4050e5:	jge    4051a3 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x7e3>
  4050eb:	movslq -0xe4(%rbp),%rax
  4050f2:	mov    %rax,-0x90(%rbp)
  4050f9:	jmp    405165 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x7a5>
  4050fb:	nopl   0x0(%rax,%rax,1)
  405100:	sub    %edx,%ecx
  405102:	cmp    %edx,%ecx
  405104:	cmovle %ecx,%edi
  405107:	movslq %edi,%rdi
  40510a:	imul   -0xa8(%rbp),%rdi
  405112:	mov    -0x64(%rbp),%edx
  405115:	mov    %r13,%rsi
  405118:	add    -0x90(%rbp),%rdi
  40511f:	add    -0x98(%rbp),%rdi
  405126:	callq  408100 <gaussian_expand_row(unsigned char const*, short*, int)>
  40512b:	mov    $0x66666667,%eax
  405130:	imul   %r12d
  405133:	mov    %r12d,%eax
  405136:	sar    $0x1f,%eax
  405139:	sar    %edx
  40513b:	sub    %eax,%edx
  40513d:	lea    (%rdx,%rdx,4),%eax
  405140:	mov    -0x70(%rbp),%rdi
  405144:	mov    %r12d,%esi
  405147:	sub    %eax,%esi
  405149:	callq  4080e0 <gaussian_ring_row(GaussianWork*, int)>
  40514e:	mov    -0x80(%rbp),%rcx
  405152:	mov    -0x64(%rbp),%edx
  405155:	mov    %rax,%rsi
  405158:	mov    %r13,%rdi
  40515b:	callq  408110 <gaussian_horiz_row(short const*, short*, int, GaussQ15 const&)>
  405160:	cmp    %r12d,%r15d
  405163:	je     4051a0 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x7e0>
  405165:	mov    -0x70(%rbp),%rdi
  405169:	inc    %r12d
  40516c:	callq  4080d0 <gaussian_scratch(GaussianWork*)>
  405171:	mov    %rax,%r13
  405174:	mov    -0x9c(%rbp),%eax
  40517a:	mov    -0x68(%rbp),%ecx
  40517d:	add    %r12d,%eax
  405180:	cltd   
  405181:	idiv   %ecx
  405183:	mov    %edx,%edi
  405185:	test   %edx,%edx
  405187:	jns    405100 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x740>
  40518d:	lea    (%rcx,%rdx,1),%esi
  405190:	neg    %edi
  405192:	cmp    %edi,%esi
  405194:	cmovle %esi,%edi
  405197:	jmpq   405107 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x747>
  40519c:	nopl   0x0(%rax)
  4051a0:	mov    %r15d,%r12d
  4051a3:	xor    %r13d,%r13d
  4051a6:	sub    $0x4,%r15d
  4051aa:	lea    (%r15,%r13,1),%esi
  4051ae:	mov    $0x66666667,%eax
  4051b3:	imul   %esi
  4051b5:	mov    %esi,%eax
  4051b7:	sar    $0x1f,%eax
  4051ba:	sar    %edx
  4051bc:	sub    %eax,%edx
  4051be:	lea    (%rdx,%rdx,4),%eax
  4051c1:	mov    -0x70(%rbp),%rdi
  4051c5:	sub    %eax,%esi
  4051c7:	callq  4080e0 <gaussian_ring_row(GaussianWork*, int)>
  4051cc:	mov    %rax,-0x60(%rbp,%r13,8)
  4051d1:	inc    %r13
  4051d4:	cmp    $0x5,%r13
  4051d8:	jne    4051aa <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x7ea>
  4051da:	mov    -0x64(%rbp),%edx
  4051dd:	mov    -0x80(%rbp),%rcx
  4051e1:	mov    %r14,%rsi
  4051e4:	lea    -0x60(%rbp),%rdi
  4051e8:	callq  408350 <gaussian_vert_row(short const* const*, unsigned char*, int, GaussQ15 const&)>
  4051ed:	mov    -0xb8(%rbp),%rax
  4051f4:	movzbl 0x8bc0(%rax),%edx
  4051fb:	mov    -0xd4(%rbp),%eax
  405201:	test   %eax,%eax
  405203:	jle    405224 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x864>
  405205:	mov    -0xf0(%rbp),%rax
  40520c:	lea    (%rbx,%rax,2),%rcx
  405210:	mov    %rbx,%rax
  405213:	nopl   0x0(%rax,%rax,1)
  405218:	mov    %dx,(%rax)
  40521b:	add    $0x2,%rax
  40521f:	cmp    %rcx,%rax
  405222:	jne    405218 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x858>
  405224:	mov    -0x78(%rbp),%ecx
  405227:	cmp    %ecx,-0xa0(%rbp)
  40522d:	jge    4055e0 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xc20>
  405233:	mov    -0xd8(%rbp),%eax
  405239:	lea    0x10(%rax),%edx
  40523c:	movslq %edx,%rdx
  40523f:	nop
  405240:	mov    -0xc0(%rbp),%rax
  405247:	vpmovzxbw 0x8bb0(%rdx,%rax,1),%ymm0
  405251:	mov    %edx,%eax
  405253:	vmovdqu %ymm0,-0x20(%rbx,%rdx,2)
  405259:	add    $0x10,%rdx
  40525d:	lea    -0x1(%rdx),%ecx
  405260:	cmp    %ecx,-0x78(%rbp)
  405263:	jg     405240 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x880>
  405265:	vzeroupper 
  405268:	cmp    -0x78(%rbp),%eax
  40526b:	jge    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  405271:	mov    -0xe8(%rbp),%esi
  405277:	movslq %eax,%rcx
  40527a:	lea    (%rsi,%rax,1),%edx
  40527d:	movslq %edx,%rdx
  405280:	movzbl (%r14,%rdx,1),%edx
  405285:	mov    -0x78(%rbp),%edi
  405288:	mov    %dx,(%rbx,%rcx,2)
  40528c:	lea    0x1(%rax),%edx
  40528f:	cmp    %edx,%edi
  405291:	jle    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  405297:	movslq %edx,%rcx
  40529a:	add    %esi,%edx
  40529c:	movslq %edx,%rdx
  40529f:	movzbl (%r14,%rdx,1),%edx
  4052a4:	mov    %dx,(%rbx,%rcx,2)
  4052a8:	lea    0x2(%rax),%edx
  4052ab:	cmp    %edx,%edi
  4052ad:	jle    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  4052b3:	movslq %edx,%rcx
  4052b6:	add    %esi,%edx
  4052b8:	movslq %edx,%rdx
  4052bb:	movzbl (%r14,%rdx,1),%edx
  4052c0:	mov    %dx,(%rbx,%rcx,2)
  4052c4:	lea    0x3(%rax),%edx
  4052c7:	cmp    %edx,%edi
  4052c9:	jle    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  4052cf:	movslq %edx,%rcx
  4052d2:	add    %esi,%edx
  4052d4:	movslq %edx,%rdx
  4052d7:	movzbl (%r14,%rdx,1),%edx
  4052dc:	mov    %dx,(%rbx,%rcx,2)
  4052e0:	lea    0x4(%rax),%edx
  4052e3:	cmp    %edx,%edi
  4052e5:	jle    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  4052eb:	movslq %edx,%rcx
  4052ee:	add    %esi,%edx
  4052f0:	movslq %edx,%rdx
  4052f3:	movzbl (%r14,%rdx,1),%edx
  4052f8:	mov    %dx,(%rbx,%rcx,2)
  4052fc:	lea    0x5(%rax),%edx
  4052ff:	cmp    %edx,%edi
  405301:	jle    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  405307:	movslq %edx,%rcx
  40530a:	add    %esi,%edx
  40530c:	movslq %edx,%rdx
  40530f:	movzbl (%r14,%rdx,1),%edx
  405314:	mov    %dx,(%rbx,%rcx,2)
  405318:	lea    0x6(%rax),%edx
  40531b:	cmp    %edx,%edi
  40531d:	jle    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  405323:	movslq %edx,%rcx
  405326:	add    %esi,%edx
  405328:	movslq %edx,%rdx
  40532b:	movzbl (%r14,%rdx,1),%edx
  405330:	mov    %dx,(%rbx,%rcx,2)
  405334:	lea    0x7(%rax),%edx
  405337:	cmp    %edi,%edx
  405339:	jge    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  40533f:	movslq %edx,%rcx
  405342:	add    %esi,%edx
  405344:	movslq %edx,%rdx
  405347:	movzbl (%r14,%rdx,1),%edx
  40534c:	mov    %dx,(%rbx,%rcx,2)
  405350:	lea    0x8(%rax),%edx
  405353:	cmp    %edi,%edx
  405355:	jge    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  40535b:	movslq %edx,%rcx
  40535e:	add    %esi,%edx
  405360:	movslq %edx,%rdx
  405363:	movzbl (%r14,%rdx,1),%edx
  405368:	mov    %dx,(%rbx,%rcx,2)
  40536c:	lea    0x9(%rax),%edx
  40536f:	cmp    %edi,%edx
  405371:	jge    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  405377:	movslq %edx,%rcx
  40537a:	add    %esi,%edx
  40537c:	movslq %edx,%rdx
  40537f:	movzbl (%r14,%rdx,1),%edx
  405384:	mov    %dx,(%rbx,%rcx,2)
  405388:	lea    0xa(%rax),%edx
  40538b:	cmp    %edi,%edx
  40538d:	jge    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  405393:	movslq %edx,%rcx
  405396:	add    %esi,%edx
  405398:	movslq %edx,%rdx
  40539b:	movzbl (%r14,%rdx,1),%edx
  4053a0:	mov    %dx,(%rbx,%rcx,2)
  4053a4:	lea    0xb(%rax),%edx
  4053a7:	cmp    %edi,%edx
  4053a9:	jge    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  4053ab:	movslq %edx,%rcx
  4053ae:	add    %esi,%edx
  4053b0:	movslq %edx,%rdx
  4053b3:	movzbl (%r14,%rdx,1),%edx
  4053b8:	mov    %dx,(%rbx,%rcx,2)
  4053bc:	lea    0xc(%rax),%edx
  4053bf:	cmp    %edx,%edi
  4053c1:	jle    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  4053c3:	movslq %edx,%rcx
  4053c6:	add    %esi,%edx
  4053c8:	movslq %edx,%rdx
  4053cb:	movzbl (%r14,%rdx,1),%edx
  4053d0:	mov    %dx,(%rbx,%rcx,2)
  4053d4:	lea    0xd(%rax),%edx
  4053d7:	cmp    %edx,%edi
  4053d9:	jle    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  4053db:	movslq %edx,%rcx
  4053de:	add    %esi,%edx
  4053e0:	movslq %edx,%rdx
  4053e3:	movzbl (%r14,%rdx,1),%edx
  4053e8:	mov    %dx,(%rbx,%rcx,2)
  4053ec:	lea    0xe(%rax),%edx
  4053ef:	cmp    %edi,%edx
  4053f1:	jge    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  4053f3:	movslq %edx,%rcx
  4053f6:	add    %esi,%edx
  4053f8:	movslq %edx,%rdx
  4053fb:	movzbl (%r14,%rdx,1),%edx
  405400:	add    $0xf,%eax
  405403:	mov    %dx,(%rbx,%rcx,2)
  405407:	cmp    %edi,%eax
  405409:	jge    405420 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa60>
  40540b:	movslq %eax,%rdx
  40540e:	add    %esi,%eax
  405410:	cltq   
  405412:	movzbl (%r14,%rax,1),%eax
  405417:	mov    %ax,(%rbx,%rdx,2)
  40541b:	nopl   0x0(%rax,%rax,1)
  405420:	mov    -0xe0(%rbp),%rax
  405427:	mov    -0xd0(%rbp),%rcx
  40542e:	add    %rbx,%rax
  405431:	movzbl (%rcx),%edx
  405434:	cmp    %rax,-0x88(%rbp)
  40543b:	je     405450 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa90>
  40543d:	nopl   (%rax)
  405440:	mov    %dx,(%rax)
  405443:	add    $0x2,%rax
  405447:	cmp    -0x88(%rbp),%rax
  40544e:	jne    405440 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xa80>
  405450:	add    $0x380,%rbx
  405457:	incl   -0xb0(%rbp)
  40545d:	addq   $0x380,-0x88(%rbp)
  405468:	cmp    -0xc8(%rbp),%rbx
  40546f:	jne    4050b8 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x6f8>
  405475:	mov    -0x11c(%rbp),%edx
  40547b:	mov    -0xc8(%rbp),%rsi
  405482:	mov    -0x100(%rbp),%rdi
  405489:	callq  409430 <sobel_kernel(unsigned short const*, short*, int)>
  40548e:	mov    -0xb8(%rbp),%rcx
  405495:	mov    -0xf8(%rbp),%eax
  40549b:	add    $0x8d80,%rcx
  4054a2:	mov    %rcx,-0x88(%rbp)
  4054a9:	mov    -0x108(%rbp),%ecx
  4054af:	mov    %eax,%r10d
  4054b2:	not    %eax
  4054b4:	add    %ecx,%eax
  4054b6:	mov    %eax,-0x90(%rbp)
  4054bc:	mov    -0x138(%rbp),%rbx
  4054c3:	mov    -0x118(%rbp),%r15
  4054ca:	mov    %r10d,%r13d
  4054cd:	lea    -0x1(%r13),%eax
  4054d1:	cmp    %eax,-0x120(%rbp)
  4054d7:	jle    4055b5 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xbf5>
  4054dd:	mov    -0x164(%rbp),%eax
  4054e3:	movslq -0x128(%rbp),%r10
  4054ea:	push   %rax
  4054eb:	mov    -0x160(%rbp),%eax
  4054f1:	mov    -0x88(%rbp),%r9
  4054f8:	push   %rax
  4054f9:	lea    0x4440(%rbx),%rcx
  405500:	lea    0x23c0(%rbx),%rdx
  405507:	push   %r10
  405509:	mov    $0x1a0,%esi
  40550e:	mov    %rbx,%rdi
  405511:	push   %r10
  405513:	mov    $0x1a0,%r8d
  405519:	mov    %r10,-0x150(%rbp)
  405520:	callq  409ca0 <nms_labels(short const*, long, short const*, short const*, long, unsigned char*, long, int, int, int)>
  405525:	movslq -0x15c(%rbp),%rcx
  40552c:	mov    -0x88(%rbp),%rsi
  405533:	add    $0x20,%rsp
  405537:	mov    %rcx,%rdx
  40553a:	mov    %r15,%rdi
  40553d:	mov    %rcx,-0xb0(%rbp)
  405544:	callq  401760 <memcpy@plt>
  405549:	cmp    %r13d,-0x120(%rbp)
  405550:	jle    405596 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xbd6>
  405552:	mov    -0x90(%rbp),%ecx
  405558:	mov    -0x88(%rbp),%rax
  40555f:	lea    (%rcx,%r13,1),%edi
  405563:	movslq %edi,%rdi
  405566:	imul   -0xa8(%rbp),%rdi
  40556e:	mov    -0x150(%rbp),%r10
  405575:	mov    -0xb0(%rbp),%rcx
  40557c:	add    -0x170(%rbp),%rdi
  405583:	add    -0x158(%rbp),%rdi
  40558a:	lea    (%rax,%r10,1),%rsi
  40558e:	mov    %rcx,%rdx
  405591:	callq  401760 <memcpy@plt>
  405596:	add    $0x680,%rbx
  40559d:	add    -0x140(%rbp),%r15
  4055a4:	add    $0x2,%r13d
  4055a8:	cmp    -0x148(%rbp),%rbx
  4055af:	jne    4054cd <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xb0d>
  4055b5:	mov    -0x124(%rbp),%ebx
  4055bb:	cmp    %ebx,-0xf8(%rbp)
  4055c1:	jne    4055f0 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xc30>
  4055c3:	lea    -0x30(%rbp),%rsp
  4055c7:	pop    %rbx
  4055c8:	pop    %r10
  4055ca:	pop    %r12
  4055cc:	pop    %r13
  4055ce:	pop    %r14
  4055d0:	pop    %r15
  4055d2:	pop    %rbp
  4055d3:	lea    -0x8(%r10),%rsp
  4055d7:	retq   
  4055d8:	nopl   0x0(%rax,%rax,1)
  4055e0:	mov    -0xd8(%rbp),%eax
  4055e6:	jmpq   405268 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x8a8>
  4055eb:	nopl   0x0(%rax,%rax,1)
  4055f0:	mov    -0x100(%rbp),%rcx
  4055f7:	mov    -0x178(%rbp),%rbx
  4055fe:	mov    -0x110(%rbp),%r13
  405605:	lea    0x1c00(%rcx),%rsi
  40560c:	mov    %rcx,%rdi
  40560f:	mov    %rbx,%rdx
  405612:	callq  401760 <memcpy@plt>
  405617:	mov    %rax,%rcx
  40561a:	add    $0x380,%rcx
  405621:	cmp    %r13,%rcx
  405624:	jne    405605 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0xc45>
  405626:	mov    -0x180(%rbp),%rbx
  40562d:	addl   $0x8,-0xf8(%rbp)
  405634:	add    %rbx,-0x118(%rbp)
  40563b:	addl   $0x8,-0x108(%rbp)
  405642:	jmpq   405088 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x6c8>
  405647:	mov    -0xd8(%rbp),%edx
  40564d:	jmpq   404d81 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)+0x3c1>
  405652:	data16 nopw %cs:0x0(%rax,%rax,1)
  40565d:	nopl   (%rax)

0000000000405980 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]>:
  405980:	lea    0x8(%rsp),%r10
  405985:	and    $0xffffffffffffffc0,%rsp
  405989:	pushq  -0x8(%r10)
  40598d:	push   %rbp
  40598e:	mov    %rsp,%rbp
  405991:	push   %r15
  405993:	mov    %rdi,%r15
  405996:	push   %r14
  405998:	push   %r13
  40599a:	push   %r12
  40599c:	push   %r10
  40599e:	push   %rbx
  40599f:	sub    $0x9200,%rsp
  4059a6:	mov    0x74(%rdi),%eax
  4059a9:	mov    0x60(%rdi),%r14d
  4059ad:	mov    %eax,-0x90f8(%rbp)
  4059b3:	mov    0x70(%rdi),%eax
  4059b6:	vmovsd 0x38(%rdi),%xmm1
  4059bb:	mov    %eax,-0x9208(%rbp)
  4059c1:	movzbl 0x7c(%rdi),%eax
  4059c5:	mov    0x6c(%rdi),%ebx
  4059c8:	mov    %al,-0x9219(%rbp)
  4059ce:	mov    0x68(%rdi),%eax
  4059d1:	vmovsd %xmm1,-0x9228(%rbp)
  4059d9:	mov    %eax,-0x9180(%rbp)
  4059df:	mov    0x64(%rdi),%eax
  4059e2:	mov    %ebx,-0x91f4(%rbp)
  4059e8:	mov    %eax,-0x919c(%rbp)
  4059ee:	mov    0x10(%rdi),%rax
  4059f2:	mov    %r14d,-0x9168(%rbp)
  4059f9:	mov    %rax,-0x9210(%rbp)
  405a00:	mov    0x8(%rdi),%rax
  405a04:	mov    %rax,-0x9138(%rbp)
  405a0b:	mov    (%rdi),%rax
  405a0e:	mov    %rax,-0x9200(%rbp)
  405a15:	callq  401950 <omp_get_num_threads@plt>
  405a1a:	mov    %eax,-0x9204(%rbp)
  405a20:	callq  4018b0 <omp_get_thread_num@plt>
  405a25:	mov    %eax,-0x91e0(%rbp)
  405a2b:	movslq %r14d,%rax
  405a2e:	mov    %rax,-0x9108(%rbp)
  405a35:	cmp    $0x2,%ebx
  405a38:	je     4069d0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1050>
  405a3e:	mov    0x28(%r15),%rax
  405a42:	mov    (%rax),%edi
  405a44:	add    $0x40,%edi
  405a47:	callq  407fa0 <gaussian_work_create(int)>
  405a4c:	mov    $0x2a00,%edx
  405a51:	xor    %esi,%esi
  405a53:	lea    -0x9070(%rbp),%rdi
  405a5a:	movq   $0x408090,-0x90b0(%rbp)
  405a65:	mov    %rax,-0x90a8(%rbp)
  405a6c:	callq  401720 <memset@plt>
  405a71:	mov    $0x6180,%edx
  405a76:	xor    %esi,%esi
  405a78:	lea    -0x6670(%rbp),%rdi
  405a7f:	callq  401720 <memset@plt>
  405a84:	xor    %eax,%eax
  405a86:	lea    -0x4f0(%rbp),%rdi
  405a8d:	mov    $0x38,%ecx
  405a92:	rep stos %rax,%es:(%rdi)
  405a95:	mov    $0x300,%edx
  405a9a:	xor    %esi,%esi
  405a9c:	lea    -0x330(%rbp),%rdi
  405aa3:	callq  401720 <memset@plt>
  405aa8:	lea    -0x90e0(%rbp),%rax
  405aaf:	mov    %rax,-0x9218(%rbp)
  405ab6:	mov    -0x90f8(%rbp),%eax
  405abc:	imul   -0x9208(%rbp),%eax
  405ac3:	cltd   
  405ac4:	idivl  -0x9204(%rbp)
  405aca:	cmp    -0x91e0(%rbp),%edx
  405ad0:	jg     4069c0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1040>
  405ad6:	mov    -0x91e0(%rbp),%ecx
  405adc:	mov    -0x9168(%rbp),%edi
  405ae2:	imul   %eax,%ecx
  405ae5:	dec    %edi
  405ae7:	mov    %edi,-0x91dc(%rbp)
  405aed:	lea    (%rcx,%rdx,1),%ebx
  405af0:	add    %ebx,%eax
  405af2:	mov    %ebx,-0x9124(%rbp)
  405af8:	mov    %eax,-0x91f8(%rbp)
  405afe:	cmp    %eax,%ebx
  405b00:	jge    406573 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xbf3>
  405b06:	movslq %ebx,%rax
  405b09:	shl    $0x4,%rax
  405b0d:	mov    %rax,-0x91a8(%rbp)
  405b14:	mov    -0x9108(%rbp),%rax
  405b1b:	lea    -0x90b0(%rbp),%r14
  405b22:	lea    0x0(,%rax,8),%rbx
  405b2a:	add    %rax,%rax
  405b2d:	mov    %rbx,-0x91e8(%rbp)
  405b34:	mov    %rax,-0x91f0(%rbp)
  405b3b:	jmpq   405bc1 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x241>
  405b40:	mov    0x20(%r15),%rax
  405b44:	mov    -0x9180(%rbp),%ebx
  405b4a:	mov    (%rax),%edx
  405b4c:	movzwl 0x4(%rax),%eax
  405b50:	push   %r14
  405b52:	mov    %ax,-0x90ea(%rbp)
  405b59:	mov    %edx,-0x90ee(%rbp)
  405b5f:	push   %rbx
  405b60:	mov    -0x919c(%rbp),%ebx
  405b66:	mov    -0x9138(%rbp),%rsi
  405b6d:	push   %rbx
  405b6e:	mov    -0x9200(%rbp),%rdi
  405b75:	sub    $0x8,%rsp
  405b79:	mov    %ax,0x4(%rsp)
  405b7e:	mov    -0x9100(%rbp),%eax
  405b84:	mov    %edx,(%rsp)
  405b87:	push   %rax
  405b88:	mov    -0x9128(%rbp),%eax
  405b8e:	mov    -0x9168(%rbp),%edx
  405b94:	push   %rax
  405b95:	vzeroupper 
  405b98:	callq  4049c0 <void (anonymous namespace)::tile<false>(unsigned char const*, unsigned char*, int, int, int, int, int, int, GaussQ15, int, int, (anonymous namespace)::Scratch&)>
  405b9d:	add    $0x30,%rsp
  405ba1:	incl   -0x9124(%rbp)
  405ba7:	addq   $0x10,-0x91a8(%rbp)
  405baf:	mov    -0x9124(%rbp),%eax
  405bb5:	cmp    %eax,-0x91f8(%rbp)
  405bbb:	je     406570 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xbf0>
  405bc1:	mov    0x48(%r15),%rdx
  405bc5:	mov    0x28(%r15),%rcx
  405bc9:	mov    (%rdx),%rax
  405bcc:	mov    (%rcx),%ecx
  405bce:	cmp    0x8(%rdx),%rax
  405bd2:	je     406550 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xbd0>
  405bd8:	add    -0x91a8(%rbp),%rax
  405bdf:	mov    0x8(%rax),%r8d
  405be3:	mov    0xc(%rax),%r9d
  405be7:	imul   %ecx,%r8d
  405beb:	shl    $0x6,%r9d
  405bef:	inc    %r9d
  405bf2:	inc    %r8d
  405bf5:	mov    -0x91dc(%rbp),%eax
  405bfb:	mov    $0x40,%ebx
  405c00:	sub    %r8d,%eax
  405c03:	cmp    %ecx,%eax
  405c05:	cmovle %eax,%ecx
  405c08:	mov    0x18(%r15),%rax
  405c0c:	mov    %ecx,-0x9128(%rbp)
  405c12:	mov    (%rax),%ecx
  405c14:	lea    -0x1(%rcx),%eax
  405c17:	mov    %eax,-0x9130(%rbp)
  405c1d:	sub    %r9d,%eax
  405c20:	cmp    $0x40,%eax
  405c23:	cmovl  %eax,%ebx
  405c26:	cmpl   $0x2,-0x91f4(%rbp)
  405c2d:	mov    %ebx,-0x9100(%rbp)
  405c33:	jne    405b40 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1c0>
  405c39:	mov    0x50(%r15),%rax
  405c3d:	mov    -0x9128(%rbp),%ebx
  405c43:	mov    (%rax),%rax
  405c46:	mov    %r8d,%edx
  405c49:	mov    %rax,-0x9140(%rbp)
  405c50:	lea    0x7e(%rbx),%eax
  405c53:	add    $0x3f,%ebx
  405c56:	cmovns %ebx,%eax
  405c59:	mov    -0x9168(%rbp),%edi
  405c5f:	and    $0xffffffc0,%eax
  405c62:	mov    %eax,%ebx
  405c64:	add    $0x21,%ebx
  405c67:	mov    %eax,-0x9164(%rbp)
  405c6d:	lea    0x40(%rax),%eax
  405c70:	cmovns %ebx,%eax
  405c73:	lea    -0x2(%r8),%esi
  405c77:	mov    %eax,%ebx
  405c79:	and    $0xffffffe0,%ebx
  405c7c:	mov    $0x0,%eax
  405c81:	sub    $0x4,%edx
  405c84:	cmovs  %eax,%edx
  405c87:	lea    0x2(%rbx,%r8,1),%eax
  405c8c:	lea    0x2(%rbx),%ecx
  405c8f:	cmp    %edi,%eax
  405c91:	mov    %ebx,-0x91a0(%rbp)
  405c97:	mov    %edx,%ebx
  405c99:	cmovg  %edi,%eax
  405c9c:	sub    %esi,%ebx
  405c9e:	mov    %ebx,%edi
  405ca0:	mov    %ebx,-0x9144(%rbp)
  405ca6:	mov    $0x0,%ebx
  405cab:	cmovns %edi,%ebx
  405cae:	mov    %eax,%edi
  405cb0:	sub    %esi,%edi
  405cb2:	cmp    %ecx,%edi
  405cb4:	cmovg  %ecx,%edi
  405cb7:	sub    %edx,%eax
  405cb9:	cltq   
  405cbb:	dec    %rax
  405cbe:	mov    %rax,-0x9158(%rbp)
  405cc5:	lea    0xe40(%r14),%rax
  405ccc:	mov    %edi,%r12d
  405ccf:	movslq %ecx,%rcx
  405cd2:	lea    0xf(%rbx),%edi
  405cd5:	mov    %rax,-0x90f8(%rbp)
  405cdc:	lea    -0x1(%rbx),%eax
  405cdf:	sub    %edx,%esi
  405ce1:	add    %rax,%rax
  405ce4:	mov    %edi,-0x9148(%rbp)
  405cea:	lea    (%rcx,%rcx,1),%rdi
  405cee:	movslq %r12d,%rcx
  405cf1:	mov    %ebx,-0x912c(%rbp)
  405cf7:	mov    %rdi,-0x9198(%rbp)
  405cfe:	mov    %rax,-0x9120(%rbp)
  405d05:	lea    (%rcx,%rcx,1),%rdi
  405d09:	mov    %ebx,%ecx
  405d0b:	lea    0x2(%rax),%rbx
  405d0f:	movslq %esi,%rax
  405d12:	mov    %rax,-0x9110(%rbp)
  405d19:	lea    0x10(%rcx),%eax
  405d1c:	mov    %eax,-0x9118(%rbp)
  405d22:	mov    %rdi,-0x9150(%rbp)
  405d29:	movslq %edx,%rdi
  405d2c:	mov    %rdi,-0x9160(%rbp)
  405d33:	mov    %esi,%r13d
  405d36:	lea    -0x2(%r9),%edi
  405d3a:	lea    0x40(%r14),%rdx
  405d3e:	xor    %eax,%eax
  405d40:	test   %edi,%edi
  405d42:	js     405d59 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x3d9>
  405d44:	mov    -0x9130(%rbp),%eax
  405d4a:	cmp    %edi,%eax
  405d4c:	cmovg  %edi,%eax
  405d4f:	cltq   
  405d51:	imul   -0x9108(%rbp),%rax
  405d59:	add    -0x9160(%rbp),%rax
  405d60:	mov    -0x9144(%rbp),%r11d
  405d67:	add    -0x9140(%rbp),%rax
  405d6e:	movzbl (%rax),%esi
  405d71:	lea    (%rbx,%rdx,1),%r10
  405d75:	mov    %rdx,%rcx
  405d78:	test   %r11d,%r11d
  405d7b:	jle    405d8c <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x40c>
  405d7d:	nopl   (%rax)
  405d80:	mov    %si,(%rcx)
  405d83:	add    $0x2,%rcx
  405d87:	cmp    %r10,%rcx
  405d8a:	jne    405d80 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x400>
  405d8c:	cmp    -0x9148(%rbp),%r12d
  405d93:	jle    406748 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xdc8>
  405d99:	mov    -0x9110(%rbp),%rcx
  405da0:	movslq -0x9118(%rbp),%rsi
  405da7:	lea    (%rax,%rcx,1),%r11
  405dab:	nopl   0x0(%rax,%rax,1)
  405db0:	vpmovzxbw -0x10(%rsi,%r11,1),%ymm0
  405db7:	mov    %esi,%ecx
  405db9:	vmovdqu %ymm0,-0x20(%rdx,%rsi,2)
  405dbf:	add    $0x10,%rsi
  405dc3:	lea    -0x1(%rsi),%r10d
  405dc7:	cmp    %r10d,%r12d
  405dca:	jg     405db0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x430>
  405dcc:	cmp    %ecx,%r12d
  405dcf:	jle    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405dd5:	lea    0x0(%r13,%rcx,1),%esi
  405dda:	movslq %esi,%rsi
  405ddd:	movzbl (%rax,%rsi,1),%esi
  405de1:	movslq %ecx,%r10
  405de4:	mov    %si,(%rdx,%r10,2)
  405de9:	lea    0x1(%rcx),%esi
  405dec:	cmp    %r12d,%esi
  405def:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405df5:	movslq %esi,%r10
  405df8:	add    %r13d,%esi
  405dfb:	movslq %esi,%rsi
  405dfe:	movzbl (%rax,%rsi,1),%esi
  405e02:	mov    %si,(%rdx,%r10,2)
  405e07:	lea    0x2(%rcx),%esi
  405e0a:	cmp    %r12d,%esi
  405e0d:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405e13:	movslq %esi,%r10
  405e16:	add    %r13d,%esi
  405e19:	movslq %esi,%rsi
  405e1c:	movzbl (%rax,%rsi,1),%esi
  405e20:	mov    %si,(%rdx,%r10,2)
  405e25:	lea    0x3(%rcx),%esi
  405e28:	cmp    %r12d,%esi
  405e2b:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405e31:	movslq %esi,%r10
  405e34:	add    %r13d,%esi
  405e37:	movslq %esi,%rsi
  405e3a:	movzbl (%rax,%rsi,1),%esi
  405e3e:	mov    %si,(%rdx,%r10,2)
  405e43:	lea    0x4(%rcx),%esi
  405e46:	cmp    %r12d,%esi
  405e49:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405e4f:	movslq %esi,%r10
  405e52:	add    %r13d,%esi
  405e55:	movslq %esi,%rsi
  405e58:	movzbl (%rax,%rsi,1),%esi
  405e5c:	mov    %si,(%rdx,%r10,2)
  405e61:	lea    0x5(%rcx),%esi
  405e64:	cmp    %r12d,%esi
  405e67:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405e6d:	movslq %esi,%r10
  405e70:	add    %r13d,%esi
  405e73:	movslq %esi,%rsi
  405e76:	movzbl (%rax,%rsi,1),%esi
  405e7a:	mov    %si,(%rdx,%r10,2)
  405e7f:	lea    0x6(%rcx),%esi
  405e82:	cmp    %r12d,%esi
  405e85:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405e8b:	movslq %esi,%r10
  405e8e:	add    %r13d,%esi
  405e91:	movslq %esi,%rsi
  405e94:	movzbl (%rax,%rsi,1),%esi
  405e98:	mov    %si,(%rdx,%r10,2)
  405e9d:	lea    0x7(%rcx),%esi
  405ea0:	cmp    %r12d,%esi
  405ea3:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405ea9:	movslq %esi,%r10
  405eac:	add    %r13d,%esi
  405eaf:	movslq %esi,%rsi
  405eb2:	movzbl (%rax,%rsi,1),%esi
  405eb6:	mov    %si,(%rdx,%r10,2)
  405ebb:	lea    0x8(%rcx),%esi
  405ebe:	cmp    %r12d,%esi
  405ec1:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405ec7:	movslq %esi,%r10
  405eca:	add    %r13d,%esi
  405ecd:	movslq %esi,%rsi
  405ed0:	movzbl (%rax,%rsi,1),%esi
  405ed4:	mov    %si,(%rdx,%r10,2)
  405ed9:	lea    0x9(%rcx),%esi
  405edc:	cmp    %r12d,%esi
  405edf:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405ee5:	movslq %esi,%r10
  405ee8:	add    %r13d,%esi
  405eeb:	movslq %esi,%rsi
  405eee:	movzbl (%rax,%rsi,1),%esi
  405ef2:	mov    %si,(%rdx,%r10,2)
  405ef7:	lea    0xa(%rcx),%esi
  405efa:	cmp    %r12d,%esi
  405efd:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405f03:	movslq %esi,%r10
  405f06:	add    %r13d,%esi
  405f09:	movslq %esi,%rsi
  405f0c:	movzbl (%rax,%rsi,1),%esi
  405f10:	mov    %si,(%rdx,%r10,2)
  405f15:	lea    0xb(%rcx),%esi
  405f18:	cmp    %r12d,%esi
  405f1b:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405f21:	movslq %esi,%r10
  405f24:	add    %r13d,%esi
  405f27:	movslq %esi,%rsi
  405f2a:	movzbl (%rax,%rsi,1),%esi
  405f2e:	mov    %si,(%rdx,%r10,2)
  405f33:	lea    0xc(%rcx),%esi
  405f36:	cmp    %r12d,%esi
  405f39:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405f3b:	movslq %esi,%r10
  405f3e:	add    %r13d,%esi
  405f41:	movslq %esi,%rsi
  405f44:	movzbl (%rax,%rsi,1),%esi
  405f48:	mov    %si,(%rdx,%r10,2)
  405f4d:	lea    0xd(%rcx),%esi
  405f50:	cmp    %r12d,%esi
  405f53:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405f55:	movslq %esi,%r10
  405f58:	add    %r13d,%esi
  405f5b:	movslq %esi,%rsi
  405f5e:	movzbl (%rax,%rsi,1),%esi
  405f62:	mov    %si,(%rdx,%r10,2)
  405f67:	lea    0xe(%rcx),%esi
  405f6a:	cmp    %r12d,%esi
  405f6d:	jge    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405f6f:	movslq %esi,%r10
  405f72:	add    %r13d,%esi
  405f75:	movslq %esi,%rsi
  405f78:	movzbl (%rax,%rsi,1),%esi
  405f7c:	add    $0xf,%ecx
  405f7f:	mov    %si,(%rdx,%r10,2)
  405f84:	cmp    %ecx,%r12d
  405f87:	jle    405fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x620>
  405f89:	movslq %ecx,%rsi
  405f8c:	add    %r13d,%ecx
  405f8f:	movslq %ecx,%rcx
  405f92:	movzbl (%rax,%rcx,1),%ecx
  405f96:	mov    %cx,(%rdx,%rsi,2)
  405f9a:	nopw   0x0(%rax,%rax,1)
  405fa0:	mov    -0x9158(%rbp),%rsi
  405fa7:	mov    -0x9150(%rbp),%rcx
  405fae:	movzbl (%rax,%rsi,1),%eax
  405fb2:	mov    -0x9198(%rbp),%rsi
  405fb9:	add    %rdx,%rcx
  405fbc:	add    %rdx,%rsi
  405fbf:	cmp    %rcx,%rsi
  405fc2:	je     405fd4 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x654>
  405fc4:	nopl   0x0(%rax)
  405fc8:	mov    %ax,(%rcx)
  405fcb:	add    $0x2,%rcx
  405fcf:	cmp    %rsi,%rcx
  405fd2:	jne    405fc8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x648>
  405fd4:	add    $0x380,%rdx
  405fdb:	inc    %edi
  405fdd:	cmp    -0x90f8(%rbp),%rdx
  405fe4:	jne    405d3e <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x3be>
  405fea:	mov    -0x9100(%rbp),%ebx
  405ff0:	test   %ebx,%ebx
  405ff2:	jle    405ba1 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x221>
  405ff8:	movslq %r9d,%rax
  405ffb:	imul   -0x9108(%rbp),%rax
  406003:	movslq %r8d,%rbx
  406006:	mov    %rbx,-0x91d8(%rbp)
  40600d:	add    %rbx,%rax
  406010:	add    -0x9138(%rbp),%rax
  406017:	mov    %rax,-0x9170(%rbp)
  40601e:	lea    0x2(%r9),%eax
  406022:	mov    %eax,-0x9110(%rbp)
  406028:	mov    -0x9198(%rbp),%rax
  40602f:	movl   $0x0,-0x90f8(%rbp)
  406039:	add    $0xe40,%rax
  40603f:	mov    %rax,-0x91c0(%rbp)
  406046:	lea    0x2a40(%r14),%rax
  40604d:	mov    %rax,-0x91b0(%rbp)
  406054:	lea    0x6802(%r14),%rax
  40605b:	mov    %rax,-0x91b8(%rbp)
  406062:	mov    -0x9120(%rbp),%rax
  406069:	mov    %r15,-0x91d0(%rbp)
  406070:	add    $0x2,%rax
  406074:	mov    %rax,-0x91c8(%rbp)
  40607b:	mov    %r13d,%r15d
  40607e:	mov    -0x91c0(%rbp),%rax
  406085:	mov    -0x9110(%rbp),%edi
  40608b:	lea    (%r14,%rax,1),%r8
  40608f:	mov    -0x912c(%rbp),%eax
  406095:	lea    0xe40(%r14),%rcx
  40609c:	movslq %r15d,%r9
  40609f:	lea    0x10(%rax),%ebx
  4060a2:	nopw   0x0(%rax,%rax,1)
  4060a8:	mov    -0x9160(%rbp),%rdx
  4060af:	mov    %rdx,%rax
  4060b2:	test   %edi,%edi
  4060b4:	js     4060ce <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x74e>
  4060b6:	mov    -0x9130(%rbp),%eax
  4060bc:	cmp    %edi,%eax
  4060be:	cmovg  %edi,%eax
  4060c1:	cltq   
  4060c3:	imul   -0x9108(%rbp),%rax
  4060cb:	add    %rdx,%rax
  4060ce:	mov    -0x91c8(%rbp),%rdx
  4060d5:	mov    -0x9144(%rbp),%r11d
  4060dc:	add    -0x9140(%rbp),%rax
  4060e3:	lea    (%rdx,%rcx,1),%r10
  4060e7:	movzbl (%rax),%esi
  4060ea:	mov    %rcx,%rdx
  4060ed:	test   %r11d,%r11d
  4060f0:	jle    406104 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x784>
  4060f2:	nopw   0x0(%rax,%rax,1)
  4060f8:	mov    %si,(%rdx)
  4060fb:	add    $0x2,%rdx
  4060ff:	cmp    %r10,%rdx
  406102:	jne    4060f8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x778>
  406104:	movslq %ebx,%rsi
  406107:	lea    (%rax,%r9,1),%r10
  40610b:	cmp    -0x9148(%rbp),%r12d
  406112:	jle    4064d8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xb58>
  406118:	nopl   0x0(%rax,%rax,1)
  406120:	vpmovzxbw -0x10(%rsi,%r10,1),%ymm0
  406127:	mov    %esi,%edx
  406129:	vmovdqu %ymm0,-0x20(%rcx,%rsi,2)
  40612f:	add    $0x10,%rsi
  406133:	lea    -0x1(%rsi),%r11d
  406137:	cmp    %r12d,%r11d
  40613a:	jl     406120 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x7a0>
  40613c:	cmp    %r12d,%edx
  40613f:	jge    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  406145:	lea    (%r15,%rdx,1),%esi
  406149:	movslq %esi,%rsi
  40614c:	movzbl (%rax,%rsi,1),%esi
  406150:	movslq %edx,%r10
  406153:	mov    %si,(%rcx,%r10,2)
  406158:	lea    0x1(%rdx),%esi
  40615b:	cmp    %esi,%r12d
  40615e:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  406164:	movslq %esi,%r10
  406167:	add    %r15d,%esi
  40616a:	movslq %esi,%rsi
  40616d:	movzbl (%rax,%rsi,1),%esi
  406171:	mov    %si,(%rcx,%r10,2)
  406176:	lea    0x2(%rdx),%esi
  406179:	cmp    %esi,%r12d
  40617c:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  406182:	movslq %esi,%r10
  406185:	add    %r15d,%esi
  406188:	movslq %esi,%rsi
  40618b:	movzbl (%rax,%rsi,1),%esi
  40618f:	mov    %si,(%rcx,%r10,2)
  406194:	lea    0x3(%rdx),%esi
  406197:	cmp    %esi,%r12d
  40619a:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  4061a0:	movslq %esi,%r10
  4061a3:	add    %r15d,%esi
  4061a6:	movslq %esi,%rsi
  4061a9:	movzbl (%rax,%rsi,1),%esi
  4061ad:	mov    %si,(%rcx,%r10,2)
  4061b2:	lea    0x4(%rdx),%esi
  4061b5:	cmp    %esi,%r12d
  4061b8:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  4061be:	movslq %esi,%r10
  4061c1:	add    %r15d,%esi
  4061c4:	movslq %esi,%rsi
  4061c7:	movzbl (%rax,%rsi,1),%esi
  4061cb:	mov    %si,(%rcx,%r10,2)
  4061d0:	lea    0x5(%rdx),%esi
  4061d3:	cmp    %esi,%r12d
  4061d6:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  4061dc:	movslq %esi,%r10
  4061df:	add    %r15d,%esi
  4061e2:	movslq %esi,%rsi
  4061e5:	movzbl (%rax,%rsi,1),%esi
  4061e9:	mov    %si,(%rcx,%r10,2)
  4061ee:	lea    0x6(%rdx),%esi
  4061f1:	cmp    %esi,%r12d
  4061f4:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  4061fa:	movslq %esi,%r10
  4061fd:	add    %r15d,%esi
  406200:	movslq %esi,%rsi
  406203:	movzbl (%rax,%rsi,1),%esi
  406207:	mov    %si,(%rcx,%r10,2)
  40620c:	lea    0x7(%rdx),%esi
  40620f:	cmp    %esi,%r12d
  406212:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  406218:	movslq %esi,%r10
  40621b:	add    %r15d,%esi
  40621e:	movslq %esi,%rsi
  406221:	movzbl (%rax,%rsi,1),%esi
  406225:	mov    %si,(%rcx,%r10,2)
  40622a:	lea    0x8(%rdx),%esi
  40622d:	cmp    %esi,%r12d
  406230:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  406236:	movslq %esi,%r10
  406239:	add    %r15d,%esi
  40623c:	movslq %esi,%rsi
  40623f:	movzbl (%rax,%rsi,1),%esi
  406243:	mov    %si,(%rcx,%r10,2)
  406248:	lea    0x9(%rdx),%esi
  40624b:	cmp    %esi,%r12d
  40624e:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  406254:	movslq %esi,%r10
  406257:	add    %r15d,%esi
  40625a:	movslq %esi,%rsi
  40625d:	movzbl (%rax,%rsi,1),%esi
  406261:	mov    %si,(%rcx,%r10,2)
  406266:	lea    0xa(%rdx),%esi
  406269:	cmp    %esi,%r12d
  40626c:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  406272:	movslq %esi,%r10
  406275:	add    %r15d,%esi
  406278:	movslq %esi,%rsi
  40627b:	movzbl (%rax,%rsi,1),%esi
  40627f:	mov    %si,(%rcx,%r10,2)
  406284:	lea    0xb(%rdx),%esi
  406287:	cmp    %esi,%r12d
  40628a:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  40628c:	movslq %esi,%r10
  40628f:	add    %r15d,%esi
  406292:	movslq %esi,%rsi
  406295:	movzbl (%rax,%rsi,1),%esi
  406299:	mov    %si,(%rcx,%r10,2)
  40629e:	lea    0xc(%rdx),%esi
  4062a1:	cmp    %esi,%r12d
  4062a4:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  4062a6:	movslq %esi,%r10
  4062a9:	add    %r15d,%esi
  4062ac:	movslq %esi,%rsi
  4062af:	movzbl (%rax,%rsi,1),%esi
  4062b3:	mov    %si,(%rcx,%r10,2)
  4062b8:	lea    0xd(%rdx),%esi
  4062bb:	cmp    %esi,%r12d
  4062be:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  4062c0:	movslq %esi,%r10
  4062c3:	add    %r15d,%esi
  4062c6:	movslq %esi,%rsi
  4062c9:	movzbl (%rax,%rsi,1),%esi
  4062cd:	mov    %si,(%rcx,%r10,2)
  4062d2:	lea    0xe(%rdx),%esi
  4062d5:	cmp    %esi,%r12d
  4062d8:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  4062da:	movslq %esi,%r10
  4062dd:	add    %r15d,%esi
  4062e0:	movslq %esi,%rsi
  4062e3:	movzbl (%rax,%rsi,1),%esi
  4062e7:	add    $0xf,%edx
  4062ea:	mov    %si,(%rcx,%r10,2)
  4062ef:	cmp    %edx,%r12d
  4062f2:	jle    406308 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x988>
  4062f4:	movslq %edx,%rsi
  4062f7:	add    %r15d,%edx
  4062fa:	movslq %edx,%rdx
  4062fd:	movzbl (%rax,%rdx,1),%edx
  406301:	mov    %dx,(%rcx,%rsi,2)
  406305:	nopl   (%rax)
  406308:	mov    -0x9150(%rbp),%rdx
  40630f:	mov    -0x9158(%rbp),%rsi
  406316:	add    %rcx,%rdx
  406319:	movzbl (%rax,%rsi,1),%eax
  40631d:	cmp    %r8,%rdx
  406320:	je     406334 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x9b4>
  406322:	nopw   0x0(%rax,%rax,1)
  406328:	mov    %ax,(%rdx)
  40632b:	add    $0x2,%rdx
  40632f:	cmp    %r8,%rdx
  406332:	jne    406328 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x9a8>
  406334:	add    $0x380,%rcx
  40633b:	inc    %edi
  40633d:	add    $0x380,%r8
  406344:	cmp    -0x91b0(%rbp),%rcx
  40634b:	jne    4060a8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x728>
  406351:	mov    -0x91a0(%rbp),%edx
  406357:	lea    0x2a40(%r14),%rsi
  40635e:	lea    0x40(%r14),%rdi
  406362:	vzeroupper 
  406365:	callq  409430 <sobel_kernel(unsigned short const*, short*, int)>
  40636a:	mov    -0x9170(%rbp),%rax
  406371:	movslq -0x9164(%rbp),%rdi
  406378:	mov    -0x9110(%rbp),%ecx
  40637e:	mov    %rax,-0x9118(%rbp)
  406385:	lea    0x8d80(%r14),%rax
  40638c:	mov    %rax,-0x9120(%rbp)
  406393:	dec    %ecx
  406395:	add    %rdi,%rax
  406398:	mov    %rdi,-0x9178(%rbp)
  40639f:	mov    %ecx,-0x917c(%rbp)
  4063a5:	mov    %rax,-0x9188(%rbp)
  4063ac:	mov    -0x90f8(%rbp),%ebx
  4063b2:	lea    0x4e02(%r14),%r13
  4063b9:	cmp    %ebx,-0x9100(%rbp)
  4063bf:	jle    40649d <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xb1d>
  4063c5:	mov    -0x9180(%rbp),%eax
  4063cb:	mov    -0x9120(%rbp),%r9
  4063d2:	push   %rax
  4063d3:	mov    -0x919c(%rbp),%eax
  4063d9:	lea    0x2080(%r13),%rcx
  4063e0:	push   %rax
  4063e1:	mov    -0x9164(%rbp),%eax
  4063e7:	lea    -0x23c0(%r13),%rdi
  4063ee:	push   %rax
  4063ef:	mov    $0x1a0,%r8d
  4063f5:	mov    %r13,%rdx
  4063f8:	pushq  -0x9178(%rbp)
  4063fe:	mov    $0x1a0,%esi
  406403:	callq  409ca0 <nms_labels(short const*, long, short const*, short const*, long, unsigned char*, long, int, int, int)>
  406408:	movslq -0x9128(%rbp),%rcx
  40640f:	mov    -0x9120(%rbp),%rsi
  406416:	mov    -0x9118(%rbp),%rdi
  40641d:	add    $0x20,%rsp
  406421:	mov    %rcx,%rdx
  406424:	mov    %rcx,-0x9190(%rbp)
  40642b:	callq  401760 <memcpy@plt>
  406430:	lea    0x1(%rbx),%eax
  406433:	cmp    %eax,-0x9100(%rbp)
  406439:	jle    406478 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xaf8>
  40643b:	mov    -0x917c(%rbp),%edi
  406441:	mov    -0x9190(%rbp),%rcx
  406448:	sub    -0x90f8(%rbp),%edi
  40644e:	add    %ebx,%edi
  406450:	movslq %edi,%rdi
  406453:	imul   -0x9108(%rbp),%rdi
  40645b:	mov    -0x9188(%rbp),%rsi
  406462:	mov    %rcx,%rdx
  406465:	add    -0x91d8(%rbp),%rdi
  40646c:	add    -0x9138(%rbp),%rdi
  406473:	callq  401760 <memcpy@plt>
  406478:	mov    -0x91f0(%rbp),%rdi
  40647f:	add    $0x680,%r13
  406486:	add    $0x2,%ebx
  406489:	add    %rdi,-0x9118(%rbp)
  406490:	cmp    %r13,-0x91b8(%rbp)
  406497:	jne    4063b9 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xa39>
  40649d:	addl   $0x8,-0x90f8(%rbp)
  4064a4:	mov    -0x91e8(%rbp),%rdi
  4064ab:	addl   $0x8,-0x9110(%rbp)
  4064b2:	add    %rdi,-0x9170(%rbp)
  4064b9:	mov    -0x90f8(%rbp),%eax
  4064bf:	cmp    %eax,-0x9100(%rbp)
  4064c5:	jg     4064e8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xb68>
  4064c7:	mov    -0x91d0(%rbp),%r15
  4064ce:	jmpq   405ba1 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x221>
  4064d3:	nopl   0x0(%rax,%rax,1)
  4064d8:	mov    -0x912c(%rbp),%edx
  4064de:	jmpq   40613c <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x7bc>
  4064e3:	nopl   0x0(%rax,%rax,1)
  4064e8:	mov    -0x9198(%rbp),%rbx
  4064ef:	lea    0x40(%r14),%rdi
  4064f3:	lea    0x1c40(%r14),%rsi
  4064fa:	mov    %rbx,%rdx
  4064fd:	callq  401760 <memcpy@plt>
  406502:	lea    0x3c0(%r14),%rdi
  406509:	lea    0x1fc0(%r14),%rsi
  406510:	mov    %rbx,%rdx
  406513:	callq  401760 <memcpy@plt>
  406518:	lea    0x740(%r14),%rdi
  40651f:	lea    0x2340(%r14),%rsi
  406526:	mov    %rbx,%rdx
  406529:	callq  401760 <memcpy@plt>
  40652e:	lea    0xac0(%r14),%rdi
  406535:	lea    0x26c0(%r14),%rsi
  40653c:	mov    %rbx,%rdx
  40653f:	callq  401760 <memcpy@plt>
  406544:	jmpq   40607e <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x6fe>
  406549:	nopl   0x0(%rax)
  406550:	mov    -0x9124(%rbp),%eax
  406556:	cltd   
  406557:	idivl  -0x9208(%rbp)
  40655d:	imul   %ecx,%edx
  406560:	shl    $0x6,%eax
  406563:	lea    0x1(%rax),%r9d
  406567:	lea    0x1(%rdx),%r8d
  40656b:	jmpq   405bf5 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x275>
  406570:	vzeroupper 
  406573:	callq  401930 <GOMP_barrier@plt>
  406578:	mov    -0x91e0(%rbp),%edx
  40657e:	test   %edx,%edx
  406580:	je     406758 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xdd8>
  406586:	callq  401930 <GOMP_barrier@plt>
  40658b:	mov    0x18(%r15),%rax
  40658f:	movslq -0x9204(%rbp),%rdi
  406596:	movslq (%rax),%rcx
  406599:	movslq -0x91e0(%rbp),%rax
  4065a0:	mov    $0x40b6f0,%r10d
  4065a6:	imul   %rcx,%rax
  4065aa:	mov    -0x9210(%rbp),%rbx
  4065b1:	movq   $0x0,-0x90e0(%rbp)
  4065bc:	cqto   
  4065be:	mov    %rax,%rsi
  4065c1:	idiv   %rdi
  4065c4:	movq   $0x0,-0x90d8(%rbp)
  4065cf:	movq   $0x0,-0x90d0(%rbp)
  4065da:	mov    -0x9218(%rbp),%r8
  4065e1:	mov    %rax,%r12
  4065e4:	mov    %eax,-0x90f8(%rbp)
  4065ea:	lea    (%rcx,%rsi,1),%rax
  4065ee:	cqto   
  4065f0:	idiv   %rdi
  4065f3:	mov    -0x9168(%rbp),%edi
  4065f9:	cmpb   $0x0,-0x9219(%rbp)
  406600:	mov    $0x40ce10,%edx
  406605:	cmovne %rdx,%r10
  406609:	movslq %r12d,%rdx
  40660c:	imul   -0x9108(%rbp),%rdx
  406614:	lea    (%rbx,%rdx,1),%rcx
  406618:	add    -0x9138(%rbp),%rdx
  40661f:	mov    %eax,%esi
  406621:	sub    %r12d,%esi
  406624:	mov    %eax,%r13d
  406627:	callq  *%r10
  40662a:	callq  401930 <GOMP_barrier@plt>
  40662f:	mov    -0x90e0(%rbp),%rax
  406636:	cmp    -0x90d8(%rbp),%rax
  40663d:	je     406646 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xcc6>
  40663f:	mov    %rax,-0x90d8(%rbp)
  406646:	mov    -0x9168(%rbp),%r8d
  40664d:	mov    -0x9210(%rbp),%r11
  406654:	dec    %r12d
  406657:	xor    %r9d,%r9d
  40665a:	lea    -0x1(%r13),%ecx
  40665e:	sub    $0x3,%r8d
  406662:	test   %r9d,%r9d
  406665:	je     406728 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xda8>
  40666b:	test   %r13d,%r13d
  40666e:	js     406680 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xd00>
  406670:	mov    0x18(%r15),%rax
  406674:	movslq %ecx,%rdx
  406677:	cmp    (%rax),%r13d
  40667a:	jl     4069b0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1030>
  406680:	cmp    $0x1,%r9d
  406684:	jne    40673a <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xdba>
  40668a:	mov    $0x6101f0,%edi
  40668f:	callq  401780 <GOMP_critical_name_start@plt>
  406694:	mov    0x40(%r15),%r12
  406698:	mov    -0x90d8(%rbp),%rbx
  40669f:	mov    -0x90e0(%rbp),%r13
  4066a6:	mov    0x8(%r12),%r15
  4066ab:	cmp    %rbx,%r13
  4066ae:	je     4066e2 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xd62>
  4066b0:	mov    0x10(%r12),%rax
  4066b5:	sub    %r13,%rbx
  4066b8:	mov    %rbx,%rcx
  4066bb:	sub    %r15,%rax
  4066be:	sar    $0x3,%rcx
  4066c2:	sar    $0x3,%rax
  4066c6:	cmp    %rax,%rcx
  4066c9:	ja     406800 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xe80>
  4066cf:	mov    %rbx,%rdx
  4066d2:	mov    %r13,%rsi
  4066d5:	mov    %r15,%rdi
  4066d8:	callq  4018c0 <memmove@plt>
  4066dd:	add    %rbx,0x8(%r12)
  4066e2:	mov    $0x6101f0,%edi
  4066e7:	callq  401690 <GOMP_critical_name_end@plt>
  4066ec:	mov    -0x90e0(%rbp),%rdi
  4066f3:	test   %rdi,%rdi
  4066f6:	je     4066fd <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xd7d>
  4066f8:	callq  401770 <operator delete(void*)@plt>
  4066fd:	mov    -0x90a8(%rbp),%rdi
  406704:	test   %rdi,%rdi
  406707:	je     40670f <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xd8f>
  406709:	callq  *-0x90b0(%rbp)
  40670f:	lea    -0x30(%rbp),%rsp
  406713:	pop    %rbx
  406714:	pop    %r10
  406716:	pop    %r12
  406718:	pop    %r13
  40671a:	pop    %r14
  40671c:	pop    %r15
  40671e:	pop    %rbp
  40671f:	lea    -0x8(%r10),%rsp
  406723:	retq   
  406724:	nopl   0x0(%rax)
  406728:	test   %r12d,%r12d
  40672b:	js     40673a <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xdba>
  40672d:	mov    0x18(%r15),%rax
  406731:	cmp    (%rax),%r12d
  406734:	jl     406908 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xf88>
  40673a:	inc    %r9d
  40673d:	jmpq   406662 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xce2>
  406742:	nopw   0x0(%rax,%rax,1)
  406748:	mov    -0x912c(%rbp),%ecx
  40674e:	jmpq   405dcc <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x44c>
  406753:	nopl   0x0(%rax,%rax,1)
  406758:	mov    -0x9168(%rbp),%eax
  40675e:	mov    0x18(%r15),%rbx
  406762:	test   %eax,%eax
  406764:	jle    4067a1 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xe21>
  406766:	movslq -0x91dc(%rbp),%r12
  40676d:	mov    -0x9138(%rbp),%r14
  406774:	inc    %r12
  406777:	mov    %r12,%rdx
  40677a:	xor    %esi,%esi
  40677c:	mov    %r14,%rdi
  40677f:	callq  401720 <memset@plt>
  406784:	mov    (%rbx),%eax
  406786:	mov    %r12,%rdx
  406789:	lea    -0x1(%rax),%edi
  40678c:	movslq %edi,%rdi
  40678f:	imul   -0x9108(%rbp),%rdi
  406797:	xor    %esi,%esi
  406799:	add    %r14,%rdi
  40679c:	callq  401720 <memset@plt>
  4067a1:	mov    -0x9138(%rbp),%rax
  4067a8:	mov    $0x1,%ecx
  4067ad:	add    -0x9108(%rbp),%rax
  4067b4:	cmpl   $0x2,(%rbx)
  4067b7:	mov    -0x9108(%rbp),%rsi
  4067be:	jle    4067d6 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xe56>
  4067c0:	movb   $0x0,-0x1(%rax,%rsi,1)
  4067c5:	movb   $0x0,(%rax)
  4067c8:	inc    %ecx
  4067ca:	add    %rsi,%rax
  4067cd:	mov    (%rbx),%edi
  4067cf:	lea    -0x1(%rdi),%edx
  4067d2:	cmp    %ecx,%edx
  4067d4:	jg     4067c0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xe40>
  4067d6:	callq  401920 <omp_get_wtime@plt>
  4067db:	vsubsd -0x9228(%rbp),%xmm0,%xmm0
  4067e3:	mov    0x30(%r15),%rax
  4067e7:	vmulsd 0x7ab9(%rip),%xmm0,%xmm0        # 40e2a8 <__dso_handle+0x2c0>
  4067ef:	vmovsd %xmm0,(%rax)
  4067f3:	jmpq   406586 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xc06>
  4067f8:	nopl   0x0(%rax,%rax,1)
  406800:	mov    (%r12),%r8
  406804:	mov    %r15,%rdx
  406807:	sub    %r8,%rdx
  40680a:	mov    %rdx,%rax
  40680d:	movabs $0x1fffffffffffffff,%rsi
  406817:	sar    $0x3,%rax
  40681b:	mov    %rsi,%rdi
  40681e:	sub    %rax,%rdi
  406821:	cmp    %rdi,%rcx
  406824:	ja     406dc6 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1446>
  40682a:	cmp    %rax,%rcx
  40682d:	cmovb  %rax,%rcx
  406831:	add    %rax,%rcx
  406834:	jb     406c98 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1318>
  40683a:	cmp    %rsi,%rcx
  40683d:	ja     406c98 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1318>
  406843:	movq   $0x0,-0x90f8(%rbp)
  40684e:	xor    %r14d,%r14d
  406851:	test   %rcx,%rcx
  406854:	jne    406dbd <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x143d>
  40685a:	lea    (%r14,%rdx,1),%r10
  40685e:	lea    (%r10,%rbx,1),%rcx
  406862:	cmp    %r8,%r15
  406865:	je     406cde <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x135e>
  40686b:	mov    %r8,%rsi
  40686e:	mov    %r14,%rdi
  406871:	mov    %rcx,-0x9110(%rbp)
  406878:	mov    %r8,-0x9100(%rbp)
  40687f:	mov    %r10,-0x9108(%rbp)
  406886:	callq  4018c0 <memmove@plt>
  40688b:	mov    -0x9108(%rbp),%r10
  406892:	mov    %rbx,%rdx
  406895:	mov    %r13,%rsi
  406898:	mov    %r10,%rdi
  40689b:	callq  4018c0 <memmove@plt>
  4068a0:	mov    0x8(%r12),%rax
  4068a5:	mov    -0x9110(%rbp),%rcx
  4068ac:	mov    %rax,%rdx
  4068af:	sub    %r15,%rdx
  4068b2:	cmp    %rax,%r15
  4068b5:	lea    (%rcx,%rdx,1),%rbx
  4068b9:	mov    -0x9100(%rbp),%r8
  4068c0:	je     406db0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1430>
  4068c6:	mov    %r15,%rsi
  4068c9:	mov    %rcx,%rdi
  4068cc:	mov    %r8,-0x9100(%rbp)
  4068d3:	callq  4018c0 <memmove@plt>
  4068d8:	mov    -0x9100(%rbp),%r8
  4068df:	test   %r8,%r8
  4068e2:	jne    406db0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1430>
  4068e8:	mov    -0x90f8(%rbp),%rax
  4068ef:	mov    %r14,(%r12)
  4068f3:	mov    %rbx,0x8(%r12)
  4068f8:	mov    %rax,0x10(%r12)
  4068fd:	jmpq   4066e2 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xd62>
  406902:	nopw   0x0(%rax,%rax,1)
  406908:	movslq -0x90f8(%rbp),%rdx
  40690f:	mov    %r12d,%eax
  406912:	cmpl   $0x1,-0x91dc(%rbp)
  406919:	jle    406680 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xd00>
  40691f:	mov    -0x9108(%rbp),%rbx
  406926:	movslq %eax,%r14
  406929:	imul   %rbx,%rdx
  40692d:	imul   %rbx,%r14
  406931:	mov    %r8d,%eax
  406934:	lea    0x1(%rdx),%rbx
  406938:	sub    %rdx,%r14
  40693b:	lea    0x2(%rdx,%rax,1),%rax
  406940:	add    %r11,%r14
  406943:	mov    -0x9138(%rbp),%r10
  40694a:	jmp    40695c <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xfdc>
  40694c:	nopl   0x0(%rax)
  406950:	inc    %rbx
  406953:	cmp    %rax,%rbx
  406956:	je     406680 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xd00>
  40695c:	cmpb   $0x1,(%r10,%rbx,1)
  406961:	mov    %rbx,-0x90e8(%rbp)
  406968:	jne    406950 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xfd0>
  40696a:	cmpb   $0x0,(%r11,%rbx,1)
  40696f:	jne    406950 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xfd0>
  406971:	cmpb   $0x0,-0x1(%r14,%rbx,1)
  406977:	jne    406988 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1008>
  406979:	cmpb   $0x0,(%r14,%rbx,1)
  40697e:	jne    406988 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1008>
  406980:	cmpb   $0x0,0x1(%r14,%rbx,1)
  406986:	je     406950 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xfd0>
  406988:	mov    -0x90d8(%rbp),%rsi
  40698f:	cmp    -0x90d0(%rbp),%rsi
  406996:	je     406d40 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x13c0>
  40699c:	mov    %rbx,(%rsi)
  40699f:	add    $0x8,%rsi
  4069a3:	mov    %rsi,-0x90d8(%rbp)
  4069aa:	jmp    406950 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xfd0>
  4069ac:	nopl   0x0(%rax)
  4069b0:	mov    %r13d,%eax
  4069b3:	jmpq   406912 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xf92>
  4069b8:	nopl   0x0(%rax,%rax,1)
  4069c0:	inc    %eax
  4069c2:	xor    %edx,%edx
  4069c4:	jmpq   405ad6 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x156>
  4069c9:	nopl   0x0(%rax)
  4069d0:	mov    0x58(%r15),%rax
  4069d4:	mov    %rax,-0x9118(%rbp)
  4069db:	mov    0x78(%r15),%eax
  4069df:	mov    %eax,-0x9120(%rbp)
  4069e5:	mov    -0x9168(%rbp),%eax
  4069eb:	lea    0x40(%rax),%edi
  4069ee:	callq  407fa0 <gaussian_work_create(int)>
  4069f3:	mov    $0x2a00,%edx
  4069f8:	xor    %esi,%esi
  4069fa:	lea    -0x9070(%rbp),%rdi
  406a01:	mov    %rax,%rbx
  406a04:	movq   $0x408090,-0x90b0(%rbp)
  406a0f:	mov    %rax,-0x90a8(%rbp)
  406a16:	callq  401720 <memset@plt>
  406a1b:	mov    $0x6180,%edx
  406a20:	xor    %esi,%esi
  406a22:	lea    -0x6670(%rbp),%rdi
  406a29:	callq  401720 <memset@plt>
  406a2e:	xor    %eax,%eax
  406a30:	lea    -0x4f0(%rbp),%rdi
  406a37:	mov    $0x38,%ecx
  406a3c:	rep stos %rax,%es:(%rdi)
  406a3f:	mov    $0x300,%edx
  406a44:	xor    %esi,%esi
  406a46:	lea    -0x330(%rbp),%rdi
  406a4d:	callq  401720 <memset@plt>
  406a52:	mov    %rbx,%rdi
  406a55:	callq  4080d0 <gaussian_scratch(GaussianWork*)>
  406a5a:	mov    %rax,%r13
  406a5d:	mov    0x18(%r15),%rax
  406a61:	mov    (%rax),%eax
  406a63:	cltd   
  406a64:	idivl  -0x9204(%rbp)
  406a6a:	cmp    -0x91e0(%rbp),%edx
  406a70:	jg     406d25 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x13a5>
  406a76:	mov    -0x91e0(%rbp),%r8d
  406a7d:	imul   %eax,%r8d
  406a81:	lea    (%r8,%rdx,1),%r14d
  406a85:	add    %r14d,%eax
  406a88:	mov    %eax,-0x9100(%rbp)
  406a8e:	cmp    %eax,%r14d
  406a91:	jge    406b10 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1190>
  406a93:	mov    -0x9108(%rbp),%rax
  406a9a:	movslq %r14d,%rbx
  406a9d:	imul   %rbx,%rax
  406aa1:	mov    -0x9200(%rbp),%rdi
  406aa8:	lea    (%rdi,%rax,1),%r12
  406aac:	movslq -0x9120(%rbp),%rax
  406ab3:	add    %rax,%rax
  406ab6:	imul   %rax,%rbx
  406aba:	mov    %rax,-0x9110(%rbp)
  406ac1:	add    -0x9118(%rbp),%rbx
  406ac8:	nopl   0x0(%rax,%rax,1)
  406ad0:	mov    -0x9168(%rbp),%edx
  406ad6:	mov    %r12,%rdi
  406ad9:	mov    %r13,%rsi
  406adc:	callq  408100 <gaussian_expand_row(unsigned char const*, short*, int)>
  406ae1:	mov    0x20(%r15),%rcx
  406ae5:	mov    -0x9168(%rbp),%edx
  406aeb:	mov    %rbx,%rsi
  406aee:	mov    %r13,%rdi
  406af1:	inc    %r14d
  406af4:	callq  408110 <gaussian_horiz_row(short const*, short*, int, GaussQ15 const&)>
  406af9:	add    -0x9108(%rbp),%r12
  406b00:	add    -0x9110(%rbp),%rbx
  406b07:	cmp    %r14d,-0x9100(%rbp)
  406b0e:	jne    406ad0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1150>
  406b10:	callq  401930 <GOMP_barrier@plt>
  406b15:	mov    0x18(%r15),%rax
  406b19:	mov    (%rax),%ecx
  406b1b:	mov    %ecx,%eax
  406b1d:	cltd   
  406b1e:	idivl  -0x9204(%rbp)
  406b24:	cmp    -0x91e0(%rbp),%edx
  406b2a:	jg     406d2e <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x13ae>
  406b30:	mov    -0x91e0(%rbp),%esi
  406b36:	imul   %eax,%esi
  406b39:	add    %edx,%esi
  406b3b:	lea    (%rax,%rsi,1),%ebx
  406b3e:	lea    -0x90e0(%rbp),%rax
  406b45:	mov    %rax,-0x9218(%rbp)
  406b4c:	cmp    %ebx,%esi
  406b4e:	jge    406c87 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1307>
  406b54:	movslq -0x9120(%rbp),%r12
  406b5b:	movslq %esi,%r14
  406b5e:	add    %r12,%r12
  406b61:	mov    %ebx,-0x9100(%rbp)
  406b67:	imul   -0x9108(%rbp),%r14
  406b6f:	mov    -0x9118(%rbp),%r13
  406b76:	mov    %r12,%rbx
  406b79:	jmp    406b89 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1209>
  406b7b:	nopl   0x0(%rax,%rax,1)
  406b80:	mov    0x18(%r15),%rax
  406b84:	mov    %r12d,%esi
  406b87:	mov    (%rax),%ecx
  406b89:	lea    -0x2(%rsi),%eax
  406b8c:	lea    -0x2(%rcx,%rcx,1),%ecx
  406b90:	cltd   
  406b91:	idiv   %ecx
  406b93:	mov    %ecx,%edi
  406b95:	lea    0x1(%rsi),%r12d
  406b99:	test   %edx,%edx
  406b9b:	lea    (%rdx,%rcx,1),%eax
  406b9e:	cmovns %edx,%eax
  406ba1:	sub    %eax,%edi
  406ba3:	cmp    %eax,%edi
  406ba5:	cmovle %edi,%eax
  406ba8:	mov    %ecx,%edi
  406baa:	cltq   
  406bac:	imul   %rbx,%rax
  406bb0:	add    %r13,%rax
  406bb3:	mov    %rax,-0x90e0(%rbp)
  406bba:	lea    -0x1(%rsi),%eax
  406bbd:	cltd   
  406bbe:	idiv   %ecx
  406bc0:	test   %edx,%edx
  406bc2:	lea    (%rdx,%rcx,1),%eax
  406bc5:	cmovns %edx,%eax
  406bc8:	sub    %eax,%edi
  406bca:	cmp    %eax,%edi
  406bcc:	cmovle %edi,%eax
  406bcf:	lea    0x2(%rsi),%edi
  406bd2:	cltq   
  406bd4:	imul   %rbx,%rax
  406bd8:	add    %r13,%rax
  406bdb:	mov    %rax,-0x90d8(%rbp)
  406be2:	mov    %esi,%eax
  406be4:	cltd   
  406be5:	idiv   %ecx
  406be7:	mov    %ecx,%esi
  406be9:	lea    (%rdx,%rcx,1),%eax
  406bec:	test   %edx,%edx
  406bee:	cmovs  %eax,%edx
  406bf1:	mov    %ecx,%eax
  406bf3:	sub    %edx,%eax
  406bf5:	cmp    %edx,%eax
  406bf7:	cmovg  %edx,%eax
  406bfa:	cltq   
  406bfc:	imul   %rbx,%rax
  406c00:	add    %r13,%rax
  406c03:	mov    %rax,-0x90d0(%rbp)
  406c0a:	mov    %r12d,%eax
  406c0d:	cltd   
  406c0e:	idiv   %ecx
  406c10:	test   %edx,%edx
  406c12:	lea    (%rdx,%rcx,1),%eax
  406c15:	cmovns %edx,%eax
  406c18:	sub    %eax,%esi
  406c1a:	cmp    %eax,%esi
  406c1c:	cmovle %esi,%eax
  406c1f:	cltq   
  406c21:	imul   %rbx,%rax
  406c25:	add    %r13,%rax
  406c28:	mov    %rax,-0x90c8(%rbp)
  406c2f:	mov    %edi,%eax
  406c31:	cltd   
  406c32:	idiv   %ecx
  406c34:	mov    -0x9218(%rbp),%rdi
  406c3b:	test   %edx,%edx
  406c3d:	lea    (%rdx,%rcx,1),%eax
  406c40:	cmovns %edx,%eax
  406c43:	mov    -0x9168(%rbp),%edx
  406c49:	sub    %eax,%ecx
  406c4b:	cmp    %eax,%ecx
  406c4d:	cmovle %ecx,%eax
  406c50:	mov    0x20(%r15),%rcx
  406c54:	cltq   
  406c56:	imul   %rbx,%rax
  406c5a:	add    %r13,%rax
  406c5d:	mov    %rax,-0x90c0(%rbp)
  406c64:	mov    0x50(%r15),%rax
  406c68:	mov    (%rax),%rsi
  406c6b:	add    %r14,%rsi
  406c6e:	callq  408350 <gaussian_vert_row(short const* const*, unsigned char*, int, GaussQ15 const&)>
  406c73:	add    -0x9108(%rbp),%r14
  406c7a:	cmp    %r12d,-0x9100(%rbp)
  406c81:	jne    406b80 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x1200>
  406c87:	callq  401930 <GOMP_barrier@plt>
  406c8c:	jmpq   405ab6 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x136>
  406c91:	nopl   0x0(%rax)
  406c98:	mov    $0xfffffffffffffff8,%rcx
  406c9f:	mov    %rcx,%rdi
  406ca2:	mov    %rcx,-0x90f8(%rbp)
  406ca9:	callq  4017a0 <operator new(unsigned long)@plt>
  406cae:	mov    (%r12),%r8
  406cb2:	mov    -0x90f8(%rbp),%rcx
  406cb9:	mov    %r15,%rdx
  406cbc:	mov    %rax,%r14
  406cbf:	sub    %r8,%rdx
  406cc2:	lea    (%rax,%rcx,1),%rax
  406cc6:	lea    (%r14,%rdx,1),%r10
  406cca:	mov    %rax,-0x90f8(%rbp)
  406cd1:	lea    (%r10,%rbx,1),%rcx
  406cd5:	cmp    %r8,%r15
  406cd8:	jne    40686b <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xeeb>
  406cde:	mov    %rbx,%rdx
  406ce1:	mov    %r13,%rsi
  406ce4:	mov    %r10,%rdi
  406ce7:	mov    %rcx,-0x9108(%rbp)
  406cee:	mov    %r8,-0x9100(%rbp)
  406cf5:	callq  4018c0 <memmove@plt>
  406cfa:	mov    0x8(%r12),%rax
  406cff:	mov    -0x9108(%rbp),%rcx
  406d06:	mov    %rax,%rdx
  406d09:	sub    %r15,%rdx
  406d0c:	cmp    %r15,%rax
  406d0f:	lea    (%rcx,%rdx,1),%rbx
  406d13:	mov    -0x9100(%rbp),%r8
  406d1a:	jne    4068c6 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xf46>
  406d20:	jmpq   4068df <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xf5f>
  406d25:	inc    %eax
  406d27:	xor    %edx,%edx
  406d29:	jmpq   406a76 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x10f6>
  406d2e:	inc    %eax
  406d30:	xor    %edx,%edx
  406d32:	jmpq   406b30 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x11b0>
  406d37:	nopw   0x0(%rax,%rax,1)
  406d40:	mov    -0x9218(%rbp),%rdi
  406d47:	lea    -0x90e8(%rbp),%rdx
  406d4e:	mov    %r8d,-0x9128(%rbp)
  406d55:	mov    %ecx,-0x9124(%rbp)
  406d5b:	mov    %r9d,-0x9120(%rbp)
  406d62:	mov    %rax,-0x9118(%rbp)
  406d69:	mov    %r10,-0x9110(%rbp)
  406d70:	mov    %r11,-0x9100(%rbp)
  406d77:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  406d7c:	mov    -0x9100(%rbp),%r11
  406d83:	mov    -0x9110(%rbp),%r10
  406d8a:	mov    -0x9118(%rbp),%rax
  406d91:	mov    -0x9120(%rbp),%r9d
  406d98:	mov    -0x9124(%rbp),%ecx
  406d9e:	mov    -0x9128(%rbp),%r8d
  406da5:	jmpq   406950 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xfd0>
  406daa:	nopw   0x0(%rax,%rax,1)
  406db0:	mov    %r8,%rdi
  406db3:	callq  401770 <operator delete(void*)@plt>
  406db8:	jmpq   4068e8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0xf68>
  406dbd:	shl    $0x3,%rcx
  406dc1:	jmpq   406c9f <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone ._omp_fn.0]+0x131f>
  406dc6:	mov    $0x40e2ca,%edi
  406dcb:	callq  401710 <std::__throw_length_error(char const*)@plt>

0000000000406dd0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)>:
  406dd0:	push   %r15
  406dd2:	push   %r14
  406dd4:	push   %r13
  406dd6:	push   %r12
  406dd8:	push   %rbp
  406dd9:	push   %rbx
  406dda:	sub    $0x158,%rsp
  406de1:	mov    0x1c0(%rsp),%eax
  406de8:	mov    %rdi,0x30(%rsp)
  406ded:	mov    %rdx,(%rsp)
  406df1:	mov    %ecx,0x38(%rsp)
  406df5:	mov    %r8d,0x4c(%rsp)
  406dfa:	mov    %r9,0x40(%rsp)
  406dff:	mov    %eax,0x3c(%rsp)
  406e03:	cmp    $0x4,%ecx
  406e06:	jle    4078c8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xaf8>
  406e0c:	cmp    $0x4,%r8d
  406e10:	jle    4078c8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xaf8>
  406e16:	mov    0x1a0(%rsp),%eax
  406e1d:	lea    -0x40(%rax),%edx
  406e20:	cmp    $0x100,%edx
  406e26:	ja     4078c8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xaf8>
  406e2c:	test   $0x3f,%al
  406e2e:	jne    4078c8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xaf8>
  406e34:	mov    0x190(%rsp),%eax
  406e3b:	mov    0x198(%rsp),%ebx
  406e42:	shr    $0x1f,%eax
  406e45:	cmp    %ebx,0x190(%rsp)
  406e4c:	setge  %dl
  406e4f:	or     %al,%dl
  406e51:	jne    4078c8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xaf8>
  406e57:	cmp    $0x7fff,%ebx
  406e5d:	jg     4078c8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xaf8>
  406e63:	mov    %rsi,%r13
  406e66:	callq  401920 <omp_get_wtime@plt>
  406e6b:	vmovsd %xmm0,0x28(%rsp)
  406e71:	callq  4018f0 <omp_get_max_threads@plt>
  406e76:	movslq 0x4c(%rsp),%rcx
  406e7b:	movq   $0x0,0x50(%rsp)
  406e84:	cmp    %ecx,%eax
  406e86:	cmovg  %ecx,%eax
  406e89:	movq   $0x0,0x58(%rsp)
  406e92:	mov    %eax,0x48(%rsp)
  406e96:	mov    0x38(%rsp),%eax
  406e9a:	movq   $0x0,0x60(%rsp)
  406ea3:	sub    $0x3,%eax
  406ea6:	cltd   
  406ea7:	idivl  0x1a0(%rsp)
  406eae:	movq   $0x0,0x70(%rsp)
  406eb7:	movq   $0x0,0x78(%rsp)
  406ec0:	movq   $0x0,0x80(%rsp)
  406ecc:	mov    %ecx,%edx
  406ece:	inc    %eax
  406ed0:	mov    %eax,0x8(%rsp)
  406ed4:	sub    $0x3,%edx
  406ed7:	lea    0x3c(%rcx),%eax
  406eda:	cmovns %edx,%eax
  406edd:	sar    $0x6,%eax
  406ee0:	inc    %eax
  406ee2:	cmpl   $0x1,0x1b8(%rsp)
  406eea:	mov    %eax,0x24(%rsp)
  406eee:	je     40744e <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x67e>
  406ef4:	mov    0x38(%rsp),%eax
  406ef8:	movq   $0x0,0x90(%rsp)
  406f04:	lea    0x1f(%rax),%ebp
  406f07:	and    $0xffffffe0,%ebp
  406f0a:	cmpl   $0x2,0x1b8(%rsp)
  406f12:	movq   $0x0,0x98(%rsp)
  406f1e:	movq   $0x0,0xa0(%rsp)
  406f2a:	movq   $0x0,0xb0(%rsp)
  406f36:	movq   $0x0,0xb8(%rsp)
  406f42:	movq   $0x0,0xc0(%rsp)
  406f4e:	jne    406f96 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x1c6>
  406f50:	movslq %eax,%rsi
  406f53:	imul   %rcx,%rsi
  406f57:	test   %rsi,%rsi
  406f5a:	jne    407834 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xa64>
  406f60:	movslq %ebp,%rsi
  406f63:	imul   %rsi,%rcx
  406f67:	lea    0x10(%rcx),%rsi
  406f6b:	lea    0xb0(%rsp),%rdi
  406f73:	callq  407a20 <std::vector<short, std::allocator<short> >::_M_default_append(unsigned long)>
  406f78:	mov    0xb0(%rsp),%rdx
  406f80:	lea    0x90(%rsp),%rbx
  406f88:	mov    %rdx,%rax
  406f8b:	neg    %rax
  406f8e:	and    $0x1e,%eax
  406f91:	add    %rdx,%rax
  406f94:	jmp    406fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x1d0>
  406f96:	xor    %eax,%eax
  406f98:	lea    0x90(%rsp),%rbx
  406fa0:	mov    %rax,0x128(%rsp)
  406fa8:	mov    0x24(%rsp),%eax
  406fac:	vmovsd 0x28(%rsp),%xmm2
  406fb2:	mov    %eax,0x144(%rsp)
  406fb9:	mov    0x8(%rsp),%eax
  406fbd:	mov    0x48(%rsp),%edx
  406fc1:	mov    %eax,0x140(%rsp)
  406fc8:	movzbl 0x3c(%rsp),%eax
  406fcd:	xor    %ecx,%ecx
  406fcf:	mov    %al,0x14c(%rsp)
  406fd6:	mov    0x1b8(%rsp),%eax
  406fdd:	lea    0xd0(%rsp),%rsi
  406fe5:	mov    %eax,0x13c(%rsp)
  406fec:	mov    0x198(%rsp),%eax
  406ff3:	mov    $0x405980,%edi
  406ff8:	mov    %eax,0x138(%rsp)
  406fff:	mov    0x190(%rsp),%eax
  407006:	mov    %ebp,0x148(%rsp)
  40700d:	mov    %eax,0x134(%rsp)
  407014:	mov    0x38(%rsp),%eax
  407018:	vmovsd %xmm2,0x108(%rsp)
  407021:	mov    %eax,0x130(%rsp)
  407028:	mov    (%rsp),%rax
  40702c:	mov    %r13,0xd8(%rsp)
  407034:	mov    %rax,0xe0(%rsp)
  40703c:	mov    0x30(%rsp),%rax
  407041:	mov    %rbx,0x120(%rsp)
  407049:	mov    %rax,0xd0(%rsp)
  407051:	lea    0x4c(%rsp),%rax
  407056:	mov    %rax,0xe8(%rsp)
  40705e:	lea    0x40(%rsp),%rax
  407063:	mov    %rax,0xf0(%rsp)
  40706b:	lea    0x1a0(%rsp),%rax
  407073:	mov    %rax,0xf8(%rsp)
  40707b:	mov    0x1a8(%rsp),%rax
  407083:	mov    %rax,0x100(%rsp)
  40708b:	lea    0x50(%rsp),%rax
  407090:	mov    %rax,0x110(%rsp)
  407098:	lea    0x70(%rsp),%rax
  40709d:	mov    %rax,0x118(%rsp)
  4070a5:	callq  401890 <GOMP_parallel@plt>
  4070aa:	mov    0x50(%rsp),%rcx
  4070af:	mov    0x58(%rsp),%rsi
  4070b4:	mov    %rcx,%rax
  4070b7:	mov    (%rsp),%rdi
  4070bb:	cmp    %rcx,%rsi
  4070be:	je     4073cf <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x5ff>
  4070c4:	nopl   0x0(%rax)
  4070c8:	mov    (%rax),%rdx
  4070cb:	add    $0x8,%rax
  4070cf:	movb   $0xff,(%rdi,%rdx,1)
  4070d3:	cmp    %rax,%rsi
  4070d6:	jne    4070c8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x2f8>
  4070d8:	movslq 0x38(%rsp),%rbp
  4070dd:	xor    %ebx,%ebx
  4070df:	mov    %rbp,%rax
  4070e2:	not    %rax
  4070e5:	mov    %rax,0x8(%rsp)
  4070ea:	mov    $0x1,%eax
  4070ef:	sub    %rbp,%rax
  4070f2:	mov    %rax,0x10(%rsp)
  4070f7:	lea    -0x1(%rbp),%r15
  4070fb:	lea    0x1(%rbp),%r14
  4070ff:	jmpq   4071f2 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x422>
  407104:	nopl   0x0(%rax)
  407108:	lea    (%rcx,%r12,1),%rax
  40710c:	mov    (%rax),%rdx
  40710f:	sub    %rbp,%rdx
  407112:	cmpb   $0x1,0x0(%r13,%rdx,1)
  407118:	mov    %rdx,0xd0(%rsp)
  407120:	je     4073a0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x5d0>
  407126:	mov    0x10(%rsp),%rdx
  40712b:	add    (%rax),%rdx
  40712e:	cmpb   $0x1,0x0(%r13,%rdx,1)
  407134:	mov    %rdx,0xd0(%rsp)
  40713c:	je     407370 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x5a0>
  407142:	mov    (%rax),%rdx
  407145:	lea    -0x1(%rdx),%rdi
  407149:	cmpb   $0x1,-0x1(%r13,%rdx,1)
  40714f:	mov    %rdi,0xd0(%rsp)
  407157:	je     407340 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x570>
  40715d:	mov    (%rax),%rdx
  407160:	cmpb   $0x1,0x0(%r13,%rdx,1)
  407166:	mov    %rdx,0xd0(%rsp)
  40716e:	je     407310 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x540>
  407174:	mov    (%rax),%rdx
  407177:	lea    0x1(%rdx),%rdi
  40717b:	cmpb   $0x1,0x1(%r13,%rdx,1)
  407181:	mov    %rdi,0xd0(%rsp)
  407189:	je     4072e0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x510>
  40718f:	mov    (%rax),%rdx
  407192:	add    %r15,%rdx
  407195:	cmpb   $0x1,0x0(%r13,%rdx,1)
  40719b:	mov    %rdx,0xd0(%rsp)
  4071a3:	je     4072b0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x4e0>
  4071a9:	mov    (%rax),%rdx
  4071ac:	add    %rbp,%rdx
  4071af:	cmpb   $0x1,0x0(%r13,%rdx,1)
  4071b5:	mov    %rdx,0xd0(%rsp)
  4071bd:	je     407280 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x4b0>
  4071c3:	mov    (%rax),%rdx
  4071c6:	add    %r14,%rdx
  4071c9:	cmpb   $0x1,0x0(%r13,%rdx,1)
  4071cf:	mov    %rdx,%rax
  4071d2:	mov    %rdx,0xd0(%rsp)
  4071da:	je     407250 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x480>
  4071dc:	mov    %rsi,%rax
  4071df:	sub    %rcx,%rax
  4071e2:	inc    %rbx
  4071e5:	sar    $0x3,%rax
  4071e9:	cmp    %rax,%rbx
  4071ec:	jae    4073cf <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x5ff>
  4071f2:	mov    0x8(%rsp),%rax
  4071f7:	lea    0x0(,%rbx,8),%r12
  4071ff:	add    (%rcx,%rbx,8),%rax
  407203:	cmpb   $0x1,0x0(%r13,%rax,1)
  407209:	mov    %rax,0xd0(%rsp)
  407211:	jne    407108 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x338>
  407217:	mov    (%rsp),%rdi
  40721b:	lea    (%rdi,%rax,1),%rdx
  40721f:	cmpb   $0x0,(%rdx)
  407222:	jne    407108 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x338>
  407228:	movb   $0xff,(%rdx)
  40722b:	cmp    0x60(%rsp),%rsi
  407230:	je     4076ef <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x91f>
  407236:	mov    %rax,(%rsi)
  407239:	add    $0x8,%rsi
  40723d:	mov    %rsi,0x58(%rsp)
  407242:	jmpq   407108 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x338>
  407247:	nopw   0x0(%rax,%rax,1)
  407250:	mov    (%rsp),%rdx
  407254:	add    %rax,%rdx
  407257:	cmpb   $0x0,(%rdx)
  40725a:	jne    4071dc <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x40c>
  40725c:	movb   $0xff,(%rdx)
  40725f:	cmp    0x60(%rsp),%rsi
  407264:	je     407735 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x965>
  40726a:	mov    %rax,(%rsi)
  40726d:	add    $0x8,%rsi
  407271:	mov    %rsi,0x58(%rsp)
  407276:	jmpq   4071dc <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x40c>
  40727b:	nopl   0x0(%rax,%rax,1)
  407280:	mov    (%rsp),%rdi
  407284:	add    %rdx,%rdi
  407287:	cmpb   $0x0,(%rdi)
  40728a:	jne    4071c3 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x3f3>
  407290:	movb   $0xff,(%rdi)
  407293:	cmp    0x60(%rsp),%rsi
  407298:	je     407710 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x940>
  40729e:	mov    %rdx,(%rsi)
  4072a1:	add    $0x8,%rsi
  4072a5:	mov    %rsi,0x58(%rsp)
  4072aa:	jmpq   4071c3 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x3f3>
  4072af:	nop
  4072b0:	mov    (%rsp),%rdi
  4072b4:	add    %rdx,%rdi
  4072b7:	cmpb   $0x0,(%rdi)
  4072ba:	jne    4071a9 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x3d9>
  4072c0:	movb   $0xff,(%rdi)
  4072c3:	cmp    0x60(%rsp),%rsi
  4072c8:	je     40780f <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xa3f>
  4072ce:	mov    %rdx,(%rsi)
  4072d1:	add    $0x8,%rsi
  4072d5:	mov    %rsi,0x58(%rsp)
  4072da:	jmpq   4071a9 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x3d9>
  4072df:	nop
  4072e0:	mov    (%rsp),%rdx
  4072e4:	add    %rdi,%rdx
  4072e7:	cmpb   $0x0,(%rdx)
  4072ea:	jne    40718f <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x3bf>
  4072f0:	movb   $0xff,(%rdx)
  4072f3:	cmp    0x60(%rsp),%rsi
  4072f8:	je     4077ea <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xa1a>
  4072fe:	mov    %rdi,(%rsi)
  407301:	add    $0x8,%rsi
  407305:	mov    %rsi,0x58(%rsp)
  40730a:	jmpq   40718f <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x3bf>
  40730f:	nop
  407310:	mov    (%rsp),%rdi
  407314:	add    %rdx,%rdi
  407317:	cmpb   $0x0,(%rdi)
  40731a:	jne    407174 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x3a4>
  407320:	movb   $0xff,(%rdi)
  407323:	cmp    0x60(%rsp),%rsi
  407328:	je     4077c5 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x9f5>
  40732e:	mov    %rdx,(%rsi)
  407331:	add    $0x8,%rsi
  407335:	mov    %rsi,0x58(%rsp)
  40733a:	jmpq   407174 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x3a4>
  40733f:	nop
  407340:	mov    (%rsp),%rdx
  407344:	add    %rdi,%rdx
  407347:	cmpb   $0x0,(%rdx)
  40734a:	jne    40715d <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x38d>
  407350:	movb   $0xff,(%rdx)
  407353:	cmp    %rsi,0x60(%rsp)
  407358:	je     4077a0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x9d0>
  40735e:	mov    %rdi,(%rsi)
  407361:	add    $0x8,%rsi
  407365:	mov    %rsi,0x58(%rsp)
  40736a:	jmpq   40715d <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x38d>
  40736f:	nop
  407370:	mov    (%rsp),%rdi
  407374:	add    %rdx,%rdi
  407377:	cmpb   $0x0,(%rdi)
  40737a:	jne    407142 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x372>
  407380:	movb   $0xff,(%rdi)
  407383:	cmp    0x60(%rsp),%rsi
  407388:	je     40777b <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x9ab>
  40738e:	mov    %rdx,(%rsi)
  407391:	add    $0x8,%rsi
  407395:	mov    %rsi,0x58(%rsp)
  40739a:	jmpq   407142 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x372>
  40739f:	nop
  4073a0:	mov    (%rsp),%rdi
  4073a4:	add    %rdx,%rdi
  4073a7:	cmpb   $0x0,(%rdi)
  4073aa:	jne    407126 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x356>
  4073b0:	movb   $0xff,(%rdi)
  4073b3:	cmp    0x60(%rsp),%rsi
  4073b8:	je     407756 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x986>
  4073be:	mov    %rdx,(%rsi)
  4073c1:	add    $0x8,%rsi
  4073c5:	mov    %rsi,0x58(%rsp)
  4073ca:	jmpq   407126 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x356>
  4073cf:	callq  401920 <omp_get_wtime@plt>
  4073d4:	vsubsd 0x28(%rsp),%xmm0,%xmm0
  4073da:	mov    0x1a8(%rsp),%rax
  4073e2:	mov    0xb0(%rsp),%rdi
  4073ea:	vmulsd 0x6eb6(%rip),%xmm0,%xmm0        # 40e2a8 <__dso_handle+0x2c0>
  4073f2:	vsubsd (%rax),%xmm0,%xmm0
  4073f6:	mov    0x1b0(%rsp),%rax
  4073fe:	vmovsd %xmm0,(%rax)
  407402:	test   %rdi,%rdi
  407405:	je     40740c <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x63c>
  407407:	callq  401770 <operator delete(void*)@plt>
  40740c:	mov    0x90(%rsp),%rdi
  407414:	test   %rdi,%rdi
  407417:	je     40741e <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x64e>
  407419:	callq  401770 <operator delete(void*)@plt>
  40741e:	mov    0x70(%rsp),%rdi
  407423:	test   %rdi,%rdi
  407426:	je     40742d <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x65d>
  407428:	callq  401770 <operator delete(void*)@plt>
  40742d:	mov    0x50(%rsp),%rdi
  407432:	test   %rdi,%rdi
  407435:	je     40743c <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x66c>
  407437:	callq  401770 <operator delete(void*)@plt>
  40743c:	add    $0x158,%rsp
  407443:	pop    %rbx
  407444:	pop    %rbp
  407445:	pop    %r12
  407447:	pop    %r13
  407449:	pop    %r14
  40744b:	pop    %r15
  40744d:	retq   
  40744e:	xor    %ebp,%ebp
  407450:	movq   $0x0,0x10(%rsp)
  407459:	xor    %r14d,%r14d
  40745c:	test   %eax,%eax
  40745e:	jle    4075a1 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x7d1>
  407464:	nopl   0x0(%rax)
  407468:	mov    0x8(%rsp),%eax
  40746c:	test   %eax,%eax
  40746e:	jle    4074e8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x718>
  407470:	mov    0x80(%rsp),%r15
  407478:	xor    %r12d,%r12d
  40747b:	nopl   0x0(%rax,%rax,1)
  407480:	mov    %r14d,%eax
  407483:	or     %r12d,%eax
  407486:	mov    %r12d,%edx
  407489:	je     4076a0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x8d0>
  40748f:	xor    %ecx,%ecx
  407491:	mov    %r14d,%esi
  407494:	xor    %ebx,%ebx
  407496:	nopw   %cs:0x0(%rax,%rax,1)
  4074a0:	lea    (%rsi,%rsi,1),%eax
  4074a3:	mov    %edx,%edi
  4074a5:	and    $0x2,%eax
  4074a8:	and    $0x1,%edi
  4074ab:	or     %edi,%eax
  4074ad:	shl    %cl,%rax
  4074b0:	shr    %edx
  4074b2:	or     %rax,%rbx
  4074b5:	shr    %esi
  4074b7:	mov    %edx,%eax
  4074b9:	add    $0x2,%ecx
  4074bc:	or     %esi,%eax
  4074be:	jne    4074a0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x6d0>
  4074c0:	cmp    %rbp,%r15
  4074c3:	je     407608 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x838>
  4074c9:	mov    %rbx,0x0(%rbp)
  4074cd:	mov    %r12d,0x8(%rbp)
  4074d1:	mov    %r14d,0xc(%rbp)
  4074d5:	add    $0x10,%rbp
  4074d9:	mov    %rbp,0x78(%rsp)
  4074de:	inc    %r12d
  4074e1:	cmp    0x8(%rsp),%r12d
  4074e6:	jne    407480 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x6b0>
  4074e8:	inc    %r14d
  4074eb:	cmp    0x24(%rsp),%r14d
  4074f0:	jne    407468 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x698>
  4074f6:	mov    0x10(%rsp),%r15
  4074fb:	cmp    %r15,%rbp
  4074fe:	je     4075a1 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x7d1>
  407504:	mov    %rbp,%rbx
  407507:	sub    %r15,%rbx
  40750a:	mov    %rbx,%rax
  40750d:	sar    $0x4,%rax
  407511:	bsr    %rax,%rax
  407515:	xor    $0x3f,%rax
  407519:	mov    $0x3f,%edx
  40751e:	sub    %eax,%edx
  407520:	movslq %edx,%rdx
  407523:	add    %rdx,%rdx
  407526:	mov    %rbp,%rsi
  407529:	mov    %r15,%rdi
  40752c:	callq  404680 <void std::__introsort_loop<__gnu_cxx::__normal_iterator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile*, std::vector<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile, std::allocator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile> > >, long, __gnu_cxx::__ops::_Iter_comp_iter<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::{lambda(auto:1, auto:2)#1}> >(__gnu_cxx::__normal_iterator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile*, std::vector<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile, std::allocator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile> > >, __gnu_cxx::__normal_iterator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile*, std::vector<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile, std::allocator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile> > >, long, __gnu_cxx::__ops::_Iter_comp_iter<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::{lambda(auto:1, auto:2)#1}>)>
  407531:	cmp    $0x100,%rbx
  407538:	jle    40789a <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xaca>
  40753e:	lea    0x100(%r15),%rbx
  407545:	mov    %rbx,%rsi
  407548:	mov    %r15,%rdi
  40754b:	callq  4048e0 <void std::__insertion_sort<__gnu_cxx::__normal_iterator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile*, std::vector<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile, std::allocator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile> > >, __gnu_cxx::__ops::_Iter_comp_iter<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::{lambda(auto:1, auto:2)#1}> >(__gnu_cxx::__normal_iterator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile*, std::vector<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile, std::allocator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile> > >, __gnu_cxx::__normal_iterator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile*, std::vector<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile, std::allocator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile> > >, __gnu_cxx::__ops::_Iter_comp_iter<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::{lambda(auto:1, auto:2)#1}>) [clone .isra.42]>
  407550:	mov    %rbx,%rsi
  407553:	cmp    %rbp,%rbx
  407556:	je     4075a1 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x7d1>
  407558:	mov    (%rsi),%rcx
  40755b:	mov    0x8(%rsi),%r8d
  40755f:	mov    0xc(%rsi),%edi
  407562:	lea    -0x10(%rsi),%rax
  407566:	cmp    %rcx,-0x10(%rsi)
  40756a:	ja     40757b <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x7ab>
  40756c:	jmpq   407892 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xac2>
  407571:	nopl   0x0(%rax)
  407578:	mov    %rdx,%rax
  40757b:	vmovdqu (%rax),%xmm1
  40757f:	lea    -0x10(%rax),%rdx
  407583:	vmovups %xmm1,0x10(%rax)
  407588:	cmp    -0x10(%rax),%rcx
  40758c:	jb     407578 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x7a8>
  40758e:	add    $0x10,%rsi
  407592:	mov    %rcx,(%rax)
  407595:	mov    %r8d,0x8(%rax)
  407599:	mov    %edi,0xc(%rax)
  40759c:	cmp    %rsi,%rbp
  40759f:	jne    407558 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x788>
  4075a1:	mov    0x38(%rsp),%eax
  4075a5:	movq   $0x0,0x90(%rsp)
  4075b1:	lea    0x1f(%rax),%ebp
  4075b4:	and    $0xffffffe0,%ebp
  4075b7:	movq   $0x0,0x98(%rsp)
  4075c3:	movq   $0x0,0xa0(%rsp)
  4075cf:	movq   $0x0,0xb0(%rsp)
  4075db:	movq   $0x0,0xb8(%rsp)
  4075e7:	movq   $0x0,0xc0(%rsp)
  4075f3:	xor    %eax,%eax
  4075f5:	lea    0x90(%rsp),%rbx
  4075fd:	jmpq   406fa0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x1d0>
  407602:	nopw   0x0(%rax,%rax,1)
  407608:	mov    %rbp,%rax
  40760b:	sub    0x10(%rsp),%rax
  407610:	mov    %rax,0x18(%rsp)
  407615:	sar    $0x4,%rax
  407619:	je     4076d8 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x908>
  40761f:	lea    (%rax,%rax,1),%rdx
  407623:	mov    $0xfffffffffffffff0,%r15
  40762a:	cmp    %rdx,%rax
  40762d:	jbe    4076a7 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x8d7>
  40762f:	mov    %r15,%rdi
  407632:	callq  4017a0 <operator new(unsigned long)@plt>
  407637:	mov    %rax,%rcx
  40763a:	add    %rax,%r15
  40763d:	mov    0x18(%rsp),%rdx
  407642:	mov    0x10(%rsp),%rsi
  407647:	lea    (%rcx,%rdx,1),%rax
  40764b:	mov    %rbx,(%rax)
  40764e:	mov    %r12d,0x8(%rax)
  407652:	mov    %r14d,0xc(%rax)
  407656:	lea    0x10(%rcx,%rdx,1),%rbx
  40765b:	cmp    %rsi,%rbp
  40765e:	je     4076c9 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x8f9>
  407660:	mov    %rcx,%rdi
  407663:	callq  4018c0 <memmove@plt>
  407668:	mov    %rax,%rcx
  40766b:	mov    0x10(%rsp),%rdi
  407670:	mov    %rcx,0x18(%rsp)
  407675:	callq  401770 <operator delete(void*)@plt>
  40767a:	mov    0x18(%rsp),%rcx
  40767f:	mov    %rcx,0x70(%rsp)
  407684:	mov    %rbx,0x78(%rsp)
  407689:	mov    %r15,0x80(%rsp)
  407691:	mov    %rbx,%rbp
  407694:	mov    %rcx,0x10(%rsp)
  407699:	jmpq   4074de <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x70e>
  40769e:	xchg   %ax,%ax
  4076a0:	xor    %ebx,%ebx
  4076a2:	jmpq   4074c0 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x6f0>
  4076a7:	movabs $0xfffffffffffffff,%rcx
  4076b1:	cmp    %rcx,%rdx
  4076b4:	ja     4076e3 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x913>
  4076b6:	test   %rdx,%rdx
  4076b9:	jne    4078b7 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xae7>
  4076bf:	xor    %r15d,%r15d
  4076c2:	xor    %ecx,%ecx
  4076c4:	jmpq   40763d <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x86d>
  4076c9:	cmpq   $0x0,0x10(%rsp)
  4076cf:	je     40767f <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x8af>
  4076d1:	jmp    40766b <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x89b>
  4076d3:	nopl   0x0(%rax,%rax,1)
  4076d8:	mov    $0x10,%r15d
  4076de:	jmpq   40762f <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x85f>
  4076e3:	mov    $0xfffffffffffffff0,%r15
  4076ea:	jmpq   40762f <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x85f>
  4076ef:	lea    0xd0(%rsp),%rdx
  4076f7:	lea    0x50(%rsp),%rdi
  4076fc:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  407701:	mov    0x50(%rsp),%rcx
  407706:	mov    0x58(%rsp),%rsi
  40770b:	jmpq   407108 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x338>
  407710:	lea    0xd0(%rsp),%rdx
  407718:	lea    0x50(%rsp),%rdi
  40771d:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  407722:	mov    0x50(%rsp),%rcx
  407727:	mov    0x58(%rsp),%rsi
  40772c:	lea    (%rcx,%r12,1),%rax
  407730:	jmpq   4071c3 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x3f3>
  407735:	lea    0xd0(%rsp),%rdx
  40773d:	lea    0x50(%rsp),%rdi
  407742:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  407747:	mov    0x50(%rsp),%rcx
  40774c:	mov    0x58(%rsp),%rsi
  407751:	jmpq   4071dc <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x40c>
  407756:	lea    0xd0(%rsp),%rdx
  40775e:	lea    0x50(%rsp),%rdi
  407763:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  407768:	mov    0x50(%rsp),%rcx
  40776d:	mov    0x58(%rsp),%rsi
  407772:	lea    (%rcx,%r12,1),%rax
  407776:	jmpq   407126 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x356>
  40777b:	lea    0xd0(%rsp),%rdx
  407783:	lea    0x50(%rsp),%rdi
  407788:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40778d:	mov    0x50(%rsp),%rcx
  407792:	mov    0x58(%rsp),%rsi
  407797:	lea    (%rcx,%r12,1),%rax
  40779b:	jmpq   407142 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x372>
  4077a0:	lea    0xd0(%rsp),%rdx
  4077a8:	lea    0x50(%rsp),%rdi
  4077ad:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  4077b2:	mov    0x50(%rsp),%rcx
  4077b7:	mov    0x58(%rsp),%rsi
  4077bc:	lea    (%rcx,%r12,1),%rax
  4077c0:	jmpq   40715d <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x38d>
  4077c5:	lea    0xd0(%rsp),%rdx
  4077cd:	lea    0x50(%rsp),%rdi
  4077d2:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  4077d7:	mov    0x50(%rsp),%rcx
  4077dc:	mov    0x58(%rsp),%rsi
  4077e1:	lea    (%rcx,%r12,1),%rax
  4077e5:	jmpq   407174 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x3a4>
  4077ea:	lea    0xd0(%rsp),%rdx
  4077f2:	lea    0x50(%rsp),%rdi
  4077f7:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  4077fc:	mov    0x50(%rsp),%rcx
  407801:	mov    0x58(%rsp),%rsi
  407806:	lea    (%rcx,%r12,1),%rax
  40780a:	jmpq   40718f <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x3bf>
  40780f:	lea    0xd0(%rsp),%rdx
  407817:	lea    0x50(%rsp),%rdi
  40781c:	callq  404190 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  407821:	mov    0x50(%rsp),%rcx
  407826:	mov    0x58(%rsp),%rsi
  40782b:	lea    (%rcx,%r12,1),%rax
  40782f:	jmpq   4071a9 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x3d9>
  407834:	lea    0x90(%rsp),%rbx
  40783c:	mov    %rbx,%rdi
  40783f:	callq  407910 <std::vector<unsigned char, std::allocator<unsigned char> >::_M_default_append(unsigned long)>
  407844:	movslq 0x4c(%rsp),%rax
  407849:	movslq %ebp,%rdx
  40784c:	mov    0xb8(%rsp),%rsi
  407854:	imul   %rdx,%rax
  407858:	mov    0xb0(%rsp),%rdx
  407860:	mov    %rsi,%rcx
  407863:	sub    %rdx,%rcx
  407866:	add    $0x10,%rax
  40786a:	sar    %rcx
  40786d:	cmp    %rcx,%rax
  407870:	ja     4078ac <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0xadc>
  407872:	jae    406f88 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x1b8>
  407878:	lea    (%rdx,%rax,2),%rax
  40787c:	cmp    %rax,%rsi
  40787f:	je     406f88 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x1b8>
  407885:	mov    %rax,0xb8(%rsp)
  40788d:	jmpq   406f88 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x1b8>
  407892:	mov    %rsi,%rax
  407895:	jmpq   40758e <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x7be>
  40789a:	mov    0x10(%rsp),%rdi
  40789f:	mov    %rbp,%rsi
  4078a2:	callq  4048e0 <void std::__insertion_sort<__gnu_cxx::__normal_iterator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile*, std::vector<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile, std::allocator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile> > >, __gnu_cxx::__ops::_Iter_comp_iter<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::{lambda(auto:1, auto:2)#1}> >(__gnu_cxx::__normal_iterator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile*, std::vector<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile, std::allocator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile> > >, __gnu_cxx::__normal_iterator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile*, std::vector<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile, std::allocator<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::Tile> > >, __gnu_cxx::__ops::_Iter_comp_iter<canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)::{lambda(auto:1, auto:2)#1}>) [clone .isra.42]>
  4078a7:	jmpq   4075a1 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x7d1>
  4078ac:	sub    %rcx,%rax
  4078af:	mov    %rax,%rsi
  4078b2:	jmpq   406f6b <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x19b>
  4078b7:	shl    $0x5,%rax
  4078bb:	mov    %rax,%r15
  4078be:	jmpq   40762f <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool)+0x85f>
  4078c3:	nopl   0x0(%rax,%rax,1)
  4078c8:	mov    $0x10,%edi
  4078cd:	callq  4016f0 <__cxa_allocate_exception@plt>
  4078d2:	mov    %rax,%rdi
  4078d5:	mov    $0x40e2e8,%esi
  4078da:	mov    %rax,%rbx
  4078dd:	callq  401960 <std::invalid_argument::invalid_argument(char const*)@plt>
  4078e2:	jmpq   401b1c <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone .cold.138]+0x52>
  4078e7:	mov    %rax,%rbx
  4078ea:	jmpq   401aca <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone .cold.138]>
  4078ef:	mov    %rax,%rbx
  4078f2:	vzeroupper 
  4078f5:	jmpq   401af1 <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone .cold.138]+0x27>
  4078fa:	mov    %rax,%rbp
  4078fd:	jmpq   401b2e <canny_tiled(unsigned char const*, unsigned char*, unsigned char*, int, int, GaussQ15, int, int, int, double&, double&, FusionMode, bool) [clone .cold.138]+0x64>
  407902:	nopw   %cs:0x0(%rax,%rax,1)
  40790c:	nopl   0x0(%rax)
