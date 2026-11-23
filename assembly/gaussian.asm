0000000000407b70 <expand_tail(unsigned char const*, short*, int)>:
  407b70:	push   %rbp
  407b71:	vpxor  %xmm0,%xmm0,%xmm0
  407b75:	movslq %edx,%rdx
  407b78:	mov    %rsp,%rbp
  407b7b:	push   %rbx
  407b7c:	mov    %rsi,%rbx
  407b7f:	mov    %rdi,%rsi
  407b82:	and    $0xffffffffffffffe0,%rsp
  407b86:	sub    $0x20,%rsp
  407b8a:	lea    0x10(%rsp),%rdi
  407b8f:	vmovaps %xmm0,0x10(%rsp)
  407b95:	callq  401760 <memcpy@plt>
  407b9a:	vpmovzxbw 0x10(%rsp),%ymm0
  407ba1:	vpsllw $0x6,%ymm0,%ymm0
  407ba6:	vmovdqa %ymm0,(%rbx)
  407baa:	vzeroupper 
  407bad:	mov    -0x8(%rbp),%rbx
  407bb1:	leaveq 
  407bb2:	retq   
  407bb3:	data16 nopw %cs:0x0(%rax,%rax,1)
  407bbe:	xchg   %ax,%ax

0000000000407bc0 <expand_impl(unsigned char const*, short*, int, bool, bool)>:
  407bc0:	push   %rbp
  407bc1:	mov    %rsp,%rbp
  407bc4:	push   %r13
  407bc6:	mov    %rdi,%r13
  407bc9:	push   %r12
  407bcb:	mov    %rsi,%r12
  407bce:	push   %rbx
  407bcf:	movslq %edx,%rbx
  407bd2:	and    $0xffffffffffffffe0,%rsp
  407bd6:	sub    $0x20,%rsp
  407bda:	cmp    $0x3f,%ebx
  407bdd:	jle    407db0 <expand_impl(unsigned char const*, short*, int, bool, bool)+0x1f0>
  407be3:	lea    -0x40(%rbx),%r9d
  407be7:	mov    %r9d,%edi
  407bea:	and    $0xffffffc0,%edi
  407bed:	mov    %rsi,%rdx
  407bf0:	add    $0x40,%edi
  407bf3:	mov    %r13,%rax
  407bf6:	xor    %esi,%esi
  407bf8:	nopl   0x0(%rax,%rax,1)
  407c00:	vpmovzxbw (%rax),%ymm3
  407c05:	vpmovzxbw 0x10(%rax),%ymm2
  407c0b:	vpmovzxbw 0x20(%rax),%ymm1
  407c11:	vpmovzxbw 0x30(%rax),%ymm0
  407c17:	vpsllw $0x6,%ymm3,%ymm3
  407c1c:	vpsllw $0x6,%ymm2,%ymm2
  407c21:	vpsllw $0x6,%ymm1,%ymm1
  407c26:	vpsllw $0x6,%ymm0,%ymm0
  407c2b:	add    $0x40,%esi
  407c2e:	vmovdqa %ymm3,(%rdx)
  407c32:	vmovdqa %ymm2,0x20(%rdx)
  407c37:	vmovdqa %ymm1,0x40(%rdx)
  407c3c:	vmovdqa %ymm0,0x60(%rdx)
  407c41:	add    $0x40,%rax
  407c45:	sub    $0xffffffffffffff80,%rdx
  407c49:	cmp    %esi,%edi
  407c4b:	jne    407c00 <expand_impl(unsigned char const*, short*, int, bool, bool)+0x40>
  407c4d:	and    $0xffffffc0,%r9d
  407c51:	lea    0x40(%r9),%eax
  407c55:	lea    0xf(%rax),%edx
  407c58:	cmp    %edx,%ebx
  407c5a:	jle    407cd9 <expand_impl(unsigned char const*, short*, int, bool, bool)+0x119>
  407c5c:	movslq %eax,%rdx
  407c5f:	vpmovzxbw 0x0(%r13,%rdx,1),%ymm0
  407c66:	lea    0x1f(%rax),%esi
  407c69:	vpsllw $0x6,%ymm0,%ymm0
  407c6e:	vmovdqa %ymm0,(%r12,%rdx,2)
  407c74:	lea    0x10(%rax),%edx
  407c77:	cmp    %esi,%ebx
  407c79:	jle    407d30 <expand_impl(unsigned char const*, short*, int, bool, bool)+0x170>
  407c7f:	movslq %edx,%rdx
  407c82:	vpmovzxbw 0x0(%r13,%rdx,1),%ymm0
  407c89:	lea    0x2f(%rax),%esi
  407c8c:	vpsllw $0x6,%ymm0,%ymm0
  407c91:	vmovdqa %ymm0,(%r12,%rdx,2)
  407c97:	lea    0x20(%rax),%edx
  407c9a:	cmp    %esi,%ebx
  407c9c:	jle    407d30 <expand_impl(unsigned char const*, short*, int, bool, bool)+0x170>
  407ca2:	movslq %edx,%rdx
  407ca5:	vpmovzxbw 0x0(%r13,%rdx,1),%ymm0
  407cac:	lea    0x3f(%rax),%esi
  407caf:	vpsllw $0x6,%ymm0,%ymm0
  407cb4:	vmovdqa %ymm0,(%r12,%rdx,2)
  407cba:	lea    0x30(%rax),%edx
  407cbd:	cmp    %ebx,%esi
  407cbf:	jge    407d30 <expand_impl(unsigned char const*, short*, int, bool, bool)+0x170>
  407cc1:	movslq %edx,%rdx
  407cc4:	vpmovzxbw 0x0(%r13,%rdx,1),%ymm0
  407ccb:	add    $0x40,%eax
  407cce:	vpsllw $0x6,%ymm0,%ymm0
  407cd3:	vmovdqa %ymm0,(%r12,%rdx,2)
  407cd9:	cmp    %eax,%ebx
  407cdb:	jg     407d36 <expand_impl(unsigned char const*, short*, int, bool, bool)+0x176>
  407cdd:	vzeroupper 
  407ce0:	test   %cl,%cl
  407ce2:	je     407d62 <expand_impl(unsigned char const*, short*, int, bool, bool)+0x1a2>
  407ce4:	movzwl 0x2(%r12),%eax
  407cea:	mov    %ax,-0x2(%r12)
  407cf0:	movzwl 0x4(%r12),%eax
  407cf6:	mov    %ax,-0x4(%r12)
  407cfc:	lea    (%rbx,%rbx,1),%rax
  407d00:	lea    (%r12,%rax,1),%rcx
  407d04:	lea    0x2(%r12,%rax,1),%rdx
  407d09:	test   %r8b,%r8b
  407d0c:	je     407d88 <expand_impl(unsigned char const*, short*, int, bool, bool)+0x1c8>
  407d0e:	movzwl -0x4(%r12,%rax,1),%esi
  407d14:	mov    %si,(%rcx)
  407d17:	movzwl -0x6(%r12,%rax,1),%eax
  407d1d:	mov    %ax,(%rdx)
  407d20:	lea    -0x18(%rbp),%rsp
  407d24:	pop    %rbx
  407d25:	pop    %r12
  407d27:	pop    %r13
  407d29:	pop    %rbp
  407d2a:	retq   
  407d2b:	nopl   0x0(%rax,%rax,1)
  407d30:	mov    %edx,%eax
  407d32:	cmp    %eax,%ebx
  407d34:	jle    407cdd <expand_impl(unsigned char const*, short*, int, bool, bool)+0x11d>
  407d36:	movslq %eax,%rdi
  407d39:	mov    %ebx,%edx
  407d3b:	lea    (%r12,%rdi,2),%rsi
  407d3f:	sub    %eax,%edx
  407d41:	add    %r13,%rdi
  407d44:	mov    %r8d,0x18(%rsp)
  407d49:	mov    %ecx,0x1c(%rsp)
  407d4d:	vzeroupper 
  407d50:	callq  407b70 <expand_tail(unsigned char const*, short*, int)>
  407d55:	mov    0x1c(%rsp),%ecx
  407d59:	mov    0x18(%rsp),%r8d
  407d5e:	test   %cl,%cl
  407d60:	jne    407ce4 <expand_impl(unsigned char const*, short*, int, bool, bool)+0x124>
  407d62:	movzbl -0x1(%r13),%eax
  407d67:	shl    $0x6,%eax
  407d6a:	mov    %ax,-0x2(%r12)
  407d70:	movzbl -0x2(%r13),%eax
  407d75:	shl    $0x6,%eax
  407d78:	mov    %ax,-0x4(%r12)
  407d7e:	jmpq   407cfc <expand_impl(unsigned char const*, short*, int, bool, bool)+0x13c>
  407d83:	nopl   0x0(%rax,%rax,1)
  407d88:	movzbl 0x0(%r13,%rbx,1),%eax
  407d8e:	shl    $0x6,%eax
  407d91:	mov    %ax,(%rcx)
  407d94:	movzbl 0x1(%r13,%rbx,1),%eax
  407d9a:	shl    $0x6,%eax
  407d9d:	mov    %ax,(%rdx)
  407da0:	lea    -0x18(%rbp),%rsp
  407da4:	pop    %rbx
  407da5:	pop    %r12
  407da7:	pop    %r13
  407da9:	pop    %rbp
  407daa:	retq   
  407dab:	nopl   0x0(%rax,%rax,1)
  407db0:	mov    $0xf,%edx
  407db5:	xor    %eax,%eax
  407db7:	jmpq   407c58 <expand_impl(unsigned char const*, short*, int, bool, bool)+0x98>
  407dbc:	nopl   0x0(%rax)

0000000000407dc0 <vert_tail(short const* const*, unsigned char*, unsigned long, int, long long __vector(4), long long __vector(4), long long __vector(4), long long __vector(4)) [clone .constprop.13]>:
  407dc0:	push   %rbp
  407dc1:	mov    %rsp,%rbp
  407dc4:	push   %rbx
  407dc5:	mov    %rsi,%rbx
  407dc8:	and    $0xffffffffffffffe0,%rsp
  407dcc:	sub    $0x20,%rsp
  407dd0:	mov    0x8(%rdi),%r10
  407dd4:	mov    (%rdi),%r8
  407dd7:	mov    0x18(%rdi),%r9
  407ddb:	vmovdqa (%r10,%rdx,2),%ymm5
  407de1:	vmovdqa (%r8,%rdx,2),%ymm4
  407de7:	mov    0x20(%rdi),%rsi
  407deb:	vpaddw (%r9,%rdx,2),%ymm5,%ymm7
  407df1:	vpaddw (%rsi,%rdx,2),%ymm4,%ymm6
  407df6:	vpmulhrsw %ymm1,%ymm7,%ymm7
  407dfb:	vpmulhrsw %ymm2,%ymm6,%ymm6
  407e00:	mov    0x10(%rdi),%r11
  407e04:	vpmulhrsw (%r11,%rdx,2),%ymm0,%ymm3
  407e0a:	vpaddw %ymm7,%ymm3,%ymm3
  407e0e:	vpaddw %ymm6,%ymm3,%ymm3
  407e12:	vmovdqa %ymm3,%ymm4
  407e16:	cmp    $0x10,%ecx
  407e19:	jle    407e53 <vert_tail(short const* const*, unsigned char*, unsigned long, int, long long __vector(4), long long __vector(4), long long __vector(4), long long __vector(4)) [clone .constprop.13]+0x93>
  407e1b:	lea    (%rdx,%rdx,1),%rax
  407e1f:	vmovdqa 0x20(%r10,%rax,1),%ymm6
  407e26:	vmovdqa 0x20(%r8,%rax,1),%ymm5
  407e2d:	vpaddw 0x20(%r9,%rax,1),%ymm6,%ymm6
  407e34:	vpaddw 0x20(%rsi,%rax,1),%ymm5,%ymm5
  407e3a:	vpmulhrsw %ymm1,%ymm6,%ymm6
  407e3f:	vpmulhrsw %ymm2,%ymm5,%ymm5
  407e44:	vpmulhrsw 0x20(%r11,%rax,1),%ymm0,%ymm0
  407e4b:	vpaddw %ymm6,%ymm0,%ymm0
  407e4f:	vpaddw %ymm5,%ymm0,%ymm4
  407e53:	vmovdqa 0x64c5(%rip),%ymm2        # 40e320 <__dso_handle+0x338>
  407e5b:	movslq %ecx,%rdx
  407e5e:	vpmulhrsw %ymm2,%ymm3,%ymm3
  407e63:	vpmulhrsw %ymm2,%ymm4,%ymm4
  407e68:	mov    %rsp,%rsi
  407e6b:	mov    %rbx,%rdi
  407e6e:	vpackuswb %ymm4,%ymm3,%ymm3
  407e72:	vpermq $0xd8,%ymm3,%ymm3
  407e78:	vmovdqa %ymm3,(%rsp)
  407e7d:	vzeroupper 
  407e80:	callq  401760 <memcpy@plt>
  407e85:	mov    -0x8(%rbp),%rbx
  407e89:	leaveq 
  407e8a:	retq   
  407e8b:	nopl   0x0(%rax,%rax,1)

0000000000408100 <gaussian_expand_row(unsigned char const*, short*, int)>:
  408100:	mov    $0x1,%r8d
  408106:	mov    $0x1,%ecx
  40810b:	jmpq   407bc0 <expand_impl(unsigned char const*, short*, int, bool, bool)>

0000000000408110 <gaussian_horiz_row(short const*, short*, int, GaussQ15 const&)>:
  408110:	add    $0xf,%edx
  408113:	sar    $0x4,%edx
  408116:	vpbroadcastw (%rcx),%ymm7
  40811b:	vpbroadcastw 0x2(%rcx),%ymm9
  408121:	vpbroadcastw 0x4(%rcx),%ymm8
  408127:	cmp    $0x3,%edx
  40812a:	jle    408348 <gaussian_horiz_row(short const*, short*, int, GaussQ15 const&)+0x238>
  408130:	lea    -0x4(%rdx),%r10d
  408134:	mov    %r10d,%r9d
  408137:	and    $0xfffffffc,%r9d
  40813b:	add    $0x4,%r9d
  40813f:	mov    %rsi,%rcx
  408142:	mov    %rdi,%rax
  408145:	xor    %r8d,%r8d
  408148:	nopl   0x0(%rax,%rax,1)
  408150:	vmovdqu -0x2(%rax),%ymm4
  408155:	vmovdqu 0x1e(%rax),%ymm2
  40815a:	vmovdqu 0x1c(%rax),%ymm1
  40815f:	vpaddw 0x2(%rax),%ymm4,%ymm14
  408164:	vmovdqu -0x4(%rax),%ymm5
  408169:	vpaddw 0x22(%rax),%ymm2,%ymm11
  40816e:	vpaddw 0x24(%rax),%ymm1,%ymm10
  408173:	vmovdqu 0x3e(%rax),%ymm4
  408178:	vmovdqu 0x3c(%rax),%ymm2
  40817d:	vmovdqu 0x5e(%rax),%ymm1
  408182:	vpaddw 0x4(%rax),%ymm5,%ymm13
  408187:	vpaddw 0x42(%rax),%ymm4,%ymm5
  40818c:	vpaddw 0x44(%rax),%ymm2,%ymm4
  408191:	vpaddw 0x62(%rax),%ymm1,%ymm2
  408196:	vmovdqu 0x5c(%rax),%ymm1
  40819b:	vpmulhrsw %ymm9,%ymm14,%ymm14
  4081a0:	vpaddw 0x64(%rax),%ymm1,%ymm1
  4081a5:	vpmulhrsw %ymm9,%ymm11,%ymm11
  4081aa:	vpmulhrsw %ymm9,%ymm5,%ymm5
  4081af:	vpmulhrsw %ymm9,%ymm2,%ymm2
  4081b4:	vpmulhrsw %ymm8,%ymm13,%ymm13
  4081b9:	vpmulhrsw %ymm8,%ymm10,%ymm10
  4081be:	vpmulhrsw %ymm8,%ymm4,%ymm4
  4081c3:	vpmulhrsw %ymm8,%ymm1,%ymm1
  4081c8:	vpmulhrsw (%rax),%ymm7,%ymm12
  4081cd:	vpmulhrsw 0x20(%rax),%ymm7,%ymm6
  4081d3:	vpmulhrsw 0x40(%rax),%ymm7,%ymm3
  4081d9:	vpmulhrsw 0x60(%rax),%ymm7,%ymm0
  4081df:	vpaddw %ymm14,%ymm12,%ymm12
  4081e4:	vpaddw %ymm11,%ymm6,%ymm6
  4081e9:	vpaddw %ymm5,%ymm3,%ymm3
  4081ed:	vpaddw %ymm2,%ymm0,%ymm0
  4081f1:	vpaddw %ymm13,%ymm12,%ymm12
  4081f6:	vpaddw %ymm10,%ymm6,%ymm6
  4081fb:	vpaddw %ymm4,%ymm3,%ymm3
  4081ff:	vpaddw %ymm1,%ymm0,%ymm0
  408203:	add    $0x4,%r8d
  408207:	vmovdqa %ymm12,(%rcx)
  40820b:	vmovdqa %ymm6,0x20(%rcx)
  408210:	vmovdqa %ymm3,0x40(%rcx)
  408215:	vmovdqa %ymm0,0x60(%rcx)
  40821a:	sub    $0xffffffffffffff80,%rax
  40821e:	sub    $0xffffffffffffff80,%rcx
  408222:	cmp    %r9d,%r8d
  408225:	jne    408150 <gaussian_horiz_row(short const*, short*, int, GaussQ15 const&)+0x40>
  40822b:	shr    $0x2,%r10d
  40822f:	lea    0x4(,%r10,4),%eax
  408237:	cmp    %eax,%edx
  408239:	jle    408341 <gaussian_horiz_row(short const*, short*, int, GaussQ15 const&)+0x231>
  40823f:	mov    %eax,%r9d
  408242:	shl    $0x4,%r9d
  408246:	movslq %r9d,%r9
  408249:	lea    (%r9,%r9,1),%r8
  40824d:	lea    (%rdi,%r8,1),%rcx
  408251:	vmovdqu 0x2(%rcx),%ymm3
  408256:	vmovdqu 0x4(%rcx),%ymm5
  40825b:	vpaddw -0x2(%rcx),%ymm3,%ymm0
  408260:	vpaddw -0x4(%rcx),%ymm5,%ymm1
  408265:	vpmulhrsw %ymm9,%ymm0,%ymm0
  40826a:	vpmulhrsw %ymm8,%ymm1,%ymm1
  40826f:	vpmulhrsw (%rcx),%ymm7,%ymm2
  408274:	lea    0x1(%rax),%ecx
  408277:	vpaddw %ymm2,%ymm0,%ymm0
  40827b:	vpaddw %ymm1,%ymm0,%ymm0
  40827f:	vmovdqa %ymm0,(%rsi,%r9,2)
  408285:	cmp    %ecx,%edx
  408287:	jle    408341 <gaussian_horiz_row(short const*, short*, int, GaussQ15 const&)+0x231>
  40828d:	lea    0x20(%rdi,%r8,1),%rcx
  408292:	vmovdqu 0x2(%rcx),%ymm6
  408297:	vpmulhrsw (%rcx),%ymm7,%ymm2
  40829c:	vpaddw -0x2(%rcx),%ymm6,%ymm0
  4082a1:	vmovdqu 0x4(%rcx),%ymm6
  4082a6:	vpmulhrsw %ymm9,%ymm0,%ymm0
  4082ab:	vpaddw -0x4(%rcx),%ymm6,%ymm1
  4082b0:	lea    0x2(%rax),%ecx
  4082b3:	vpmulhrsw %ymm8,%ymm1,%ymm1
  4082b8:	vpaddw %ymm2,%ymm0,%ymm0
  4082bc:	vpaddw %ymm1,%ymm0,%ymm0
  4082c0:	vmovdqa %ymm0,0x20(%rsi,%r8,1)
  4082c7:	cmp    %ecx,%edx
  4082c9:	jle    408341 <gaussian_horiz_row(short const*, short*, int, GaussQ15 const&)+0x231>
  4082cb:	lea    0x40(%rdi,%r8,1),%rcx
  4082d0:	vmovdqu 0x2(%rcx),%ymm3
  4082d5:	vmovdqu 0x4(%rcx),%ymm5
  4082da:	vpaddw -0x2(%rcx),%ymm3,%ymm0
  4082df:	vpaddw -0x4(%rcx),%ymm5,%ymm1
  4082e4:	vpmulhrsw %ymm9,%ymm0,%ymm0
  4082e9:	vpmulhrsw %ymm8,%ymm1,%ymm1
  4082ee:	vpmulhrsw (%rcx),%ymm7,%ymm2
  4082f3:	add    $0x3,%eax
  4082f6:	vpaddw %ymm2,%ymm0,%ymm0
  4082fa:	vpaddw %ymm1,%ymm0,%ymm0
  4082fe:	vmovdqa %ymm0,0x40(%rsi,%r8,1)
  408305:	cmp    %eax,%edx
  408307:	jle    408341 <gaussian_horiz_row(short const*, short*, int, GaussQ15 const&)+0x231>
  408309:	lea    0x60(%rdi,%r8,1),%rax
  40830e:	vmovdqu -0x2(%rax),%ymm6
  408313:	vmovdqu -0x4(%rax),%ymm3
  408318:	vpaddw 0x2(%rax),%ymm6,%ymm0
  40831d:	vpmulhrsw (%rax),%ymm7,%ymm7
  408322:	vpmulhrsw %ymm9,%ymm0,%ymm9
  408327:	vpaddw 0x4(%rax),%ymm3,%ymm0
  40832c:	vpmulhrsw %ymm8,%ymm0,%ymm0
  408331:	vpaddw %ymm9,%ymm7,%ymm8
  408336:	vpaddw %ymm0,%ymm8,%ymm8
  40833a:	vmovdqa %ymm8,0x60(%rsi,%r8,1)
  408341:	vzeroupper 
  408344:	retq   
  408345:	nopl   (%rax)
  408348:	xor    %eax,%eax
  40834a:	jmpq   408237 <gaussian_horiz_row(short const*, short*, int, GaussQ15 const&)+0x127>
  40834f:	nop

0000000000408350 <gaussian_vert_row(short const* const*, unsigned char*, int, GaussQ15 const&)>:
  408350:	lea    0x8(%rsp),%r10
  408355:	and    $0xffffffffffffffe0,%rsp
  408359:	pushq  -0x8(%r10)
  40835d:	push   %rbp
  40835e:	mov    %rsp,%rbp
  408361:	push   %r13
  408363:	push   %r12
  408365:	push   %r10
  408367:	push   %rbx
  408368:	sub    $0x50,%rsp
  40836c:	vpbroadcastw (%rcx),%ymm0
  408371:	vpbroadcastw 0x2(%rcx),%ymm1
  408377:	vpbroadcastw 0x4(%rcx),%ymm2
  40837d:	mov    0x8(%rdi),%r8
  408381:	mov    (%rdi),%rcx
  408384:	mov    0x10(%rdi),%r9
  408388:	mov    0x18(%rdi),%r10
  40838c:	mov    0x20(%rdi),%r11
  408390:	cmp    $0x3f,%edx
  408393:	jle    4085e0 <gaussian_vert_row(short const* const*, unsigned char*, int, GaussQ15 const&)+0x290>
  408399:	lea    -0x40(%rdx),%r13d
  40839d:	mov    %r13d,%r12d
  4083a0:	and    $0xffffffc0,%r12d
  4083a4:	vmovdqa 0x5f74(%rip),%ymm4        # 40e320 <__dso_handle+0x338>
  4083ac:	add    $0x40,%r12d
  4083b0:	mov    %rsi,%rax
  4083b3:	xor    %ebx,%ebx
  4083b5:	nopl   (%rax)
  4083b8:	vmovdqa (%r8),%ymm7
  4083bd:	vmovdqa 0x40(%r8),%ymm5
  4083c3:	vpaddw (%r10),%ymm7,%ymm15
  4083c8:	vmovdqa (%rcx),%ymm7
  4083cc:	vpaddw 0x40(%r10),%ymm5,%ymm10
  4083d2:	vpaddw (%r11),%ymm7,%ymm14
  4083d7:	vmovdqa 0x20(%r8),%ymm7
  4083dd:	vpmulhrsw %ymm1,%ymm15,%ymm15
  4083e2:	vpaddw 0x20(%r10),%ymm7,%ymm13
  4083e8:	vmovdqa 0x20(%rcx),%ymm7
  4083ed:	vpmulhrsw %ymm1,%ymm13,%ymm13
  4083f2:	vpaddw 0x20(%r11),%ymm7,%ymm12
  4083f8:	vmovdqa 0x40(%rcx),%ymm7
  4083fd:	vpmulhrsw %ymm1,%ymm10,%ymm10
  408402:	vpaddw 0x40(%r11),%ymm7,%ymm9
  408408:	vmovdqa 0x60(%r8),%ymm7
  40840e:	vpmulhrsw %ymm2,%ymm14,%ymm14
  408413:	vpaddw 0x60(%r10),%ymm7,%ymm8
  408419:	vmovdqa 0x60(%rcx),%ymm7
  40841e:	vpmulhrsw %ymm1,%ymm8,%ymm8
  408423:	vpaddw 0x60(%r11),%ymm7,%ymm7
  408429:	vpmulhrsw %ymm2,%ymm12,%ymm12
  40842e:	vpmulhrsw %ymm2,%ymm9,%ymm9
  408433:	vpmulhrsw %ymm2,%ymm7,%ymm7
  408438:	vpmulhrsw (%r9),%ymm0,%ymm11
  40843d:	vpmulhrsw 0x20(%r9),%ymm0,%ymm6
  408443:	vpmulhrsw 0x40(%r9),%ymm0,%ymm3
  408449:	vpmulhrsw 0x60(%r9),%ymm0,%ymm5
  40844f:	vpaddw %ymm15,%ymm11,%ymm11
  408454:	vpaddw %ymm13,%ymm6,%ymm6
  408459:	vpaddw %ymm10,%ymm3,%ymm3
  40845e:	vpaddw %ymm8,%ymm5,%ymm5
  408463:	vpaddw %ymm14,%ymm11,%ymm11
  408468:	vpaddw %ymm12,%ymm6,%ymm6
  40846d:	vpaddw %ymm9,%ymm3,%ymm3
  408472:	vpaddw %ymm7,%ymm5,%ymm5
  408476:	vpmulhrsw %ymm4,%ymm11,%ymm11
  40847b:	vpmulhrsw %ymm4,%ymm6,%ymm6
  408480:	vpmulhrsw %ymm4,%ymm3,%ymm3
  408485:	vpmulhrsw %ymm4,%ymm5,%ymm5
  40848a:	add    $0x40,%ebx
  40848d:	sub    $0xffffffffffffff80,%rcx
  408491:	vpackuswb %ymm6,%ymm11,%ymm6
  408495:	vpermq $0xd8,%ymm6,%ymm6
  40849b:	vpackuswb %ymm5,%ymm3,%ymm3
  40849f:	vpermq $0xd8,%ymm3,%ymm3
  4084a5:	vmovdqu %ymm6,(%rax)
  4084a9:	vmovdqu %ymm3,0x20(%rax)
  4084ae:	sub    $0xffffffffffffff80,%r8
  4084b2:	sub    $0xffffffffffffff80,%r9
  4084b6:	sub    $0xffffffffffffff80,%r10
  4084ba:	sub    $0xffffffffffffff80,%r11
  4084be:	add    $0x40,%rax
  4084c2:	cmp    %r12d,%ebx
  4084c5:	jne    4083b8 <gaussian_vert_row(short const* const*, unsigned char*, int, GaussQ15 const&)+0x68>
  4084cb:	and    $0xffffffc0,%r13d
  4084cf:	lea    0x40(%r13),%ebx
  4084d3:	mov    (%rdi),%rcx
  4084d6:	mov    0x8(%rdi),%r8
  4084da:	mov    0x10(%rdi),%r9
  4084de:	mov    0x18(%rdi),%r10
  4084e2:	mov    0x20(%rdi),%r11
  4084e6:	lea    0x1f(%rbx),%eax
  4084e9:	mov    %rcx,-0x60(%rbp)
  4084ed:	mov    %r8,-0x58(%rbp)
  4084f1:	mov    %r9,-0x50(%rbp)
  4084f5:	mov    %r10,-0x48(%rbp)
  4084f9:	mov    %r11,-0x40(%rbp)
  4084fd:	cmp    %eax,%edx
  4084ff:	jle    4085ad <gaussian_vert_row(short const* const*, unsigned char*, int, GaussQ15 const&)+0x25d>
  408505:	lea    0x20(%rbx),%eax
  408508:	vmovdqa 0x5e10(%rip),%ymm4        # 40e320 <__dso_handle+0x338>
  408510:	cltq   
  408512:	nopw   0x0(%rax,%rax,1)
  408518:	vmovdqa -0x40(%r8,%rax,2),%ymm6
  40851f:	vmovdqa -0x40(%rcx,%rax,2),%ymm5
  408525:	vpaddw -0x40(%r10,%rax,2),%ymm6,%ymm9
  40852c:	vmovdqa -0x20(%r8,%rax,2),%ymm6
  408533:	vpaddw -0x40(%r11,%rax,2),%ymm5,%ymm8
  40853a:	vpaddw -0x20(%r10,%rax,2),%ymm6,%ymm7
  408541:	vmovdqa -0x20(%rcx,%rax,2),%ymm6
  408547:	vpmulhrsw %ymm1,%ymm9,%ymm9
  40854c:	vpaddw -0x20(%r11,%rax,2),%ymm6,%ymm6
  408553:	vpmulhrsw %ymm1,%ymm7,%ymm7
  408558:	vpmulhrsw %ymm2,%ymm8,%ymm8
  40855d:	vpmulhrsw %ymm2,%ymm6,%ymm6
  408562:	vpmulhrsw -0x40(%r9,%rax,2),%ymm0,%ymm3
  408569:	vpmulhrsw -0x20(%r9,%rax,2),%ymm0,%ymm5
  408570:	vpaddw %ymm9,%ymm3,%ymm3
  408575:	vpaddw %ymm7,%ymm5,%ymm5
  408579:	vpaddw %ymm8,%ymm3,%ymm3
  40857e:	vpaddw %ymm6,%ymm5,%ymm5
  408582:	vpmulhrsw %ymm4,%ymm3,%ymm3
  408587:	vpmulhrsw %ymm4,%ymm5,%ymm5
  40858c:	mov    %eax,%ebx
  40858e:	vpackuswb %ymm5,%ymm3,%ymm3
  408592:	vpermq $0xd8,%ymm3,%ymm3
  408598:	vmovdqu %ymm3,-0x20(%rsi,%rax,1)
  40859e:	add    $0x20,%rax
  4085a2:	lea    -0x1(%rax),%edi
  4085a5:	cmp    %edi,%edx
  4085a7:	jg     408518 <gaussian_vert_row(short const* const*, unsigned char*, int, GaussQ15 const&)+0x1c8>
  4085ad:	cmp    %ebx,%edx
  4085af:	jg     4085c8 <gaussian_vert_row(short const* const*, unsigned char*, int, GaussQ15 const&)+0x278>
  4085b1:	vzeroupper 
  4085b4:	add    $0x50,%rsp
  4085b8:	pop    %rbx
  4085b9:	pop    %r10
  4085bb:	pop    %r12
  4085bd:	pop    %r13
  4085bf:	pop    %rbp
  4085c0:	lea    -0x8(%r10),%rsp
  4085c4:	retq   
  4085c5:	nopl   (%rax)
  4085c8:	mov    %edx,%ecx
  4085ca:	movslq %ebx,%rdx
  4085cd:	sub    %ebx,%ecx
  4085cf:	add    %rdx,%rsi
  4085d2:	lea    -0x60(%rbp),%rdi
  4085d6:	callq  407dc0 <vert_tail(short const* const*, unsigned char*, unsigned long, int, long long __vector(4), long long __vector(4), long long __vector(4), long long __vector(4)) [clone .constprop.13]>
  4085db:	jmp    4085b4 <gaussian_vert_row(short const* const*, unsigned char*, int, GaussQ15 const&)+0x264>
  4085dd:	nopl   (%rax)
  4085e0:	mov    $0x1f,%eax
  4085e5:	xor    %ebx,%ebx
  4085e7:	jmpq   4084e9 <gaussian_vert_row(short const* const*, unsigned char*, int, GaussQ15 const&)+0x199>
  4085ec:	nopl   0x0(%rax)
