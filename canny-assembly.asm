
build-inspect/canny_scalar:     file format elf64-x86-64


Disassembly of section .init:

0000000000401898 <_init>:
  401898:	f3 0f 1e fa          	endbr64 
  40189c:	48 83 ec 08          	sub    $0x8,%rsp
  4018a0:	48 8b 05 31 37 20 00 	mov    0x203731(%rip),%rax        # 604fd8 <__gmon_start__@Base>
  4018a7:	48 85 c0             	test   %rax,%rax
  4018aa:	74 02                	je     4018ae <_init+0x16>
  4018ac:	ff d0                	callq  *%rax
  4018ae:	48 83 c4 08          	add    $0x8,%rsp
  4018b2:	c3                   	retq   

Disassembly of section .plt:

00000000004018c0 <.plt>:
  4018c0:	ff 35 42 37 20 00    	pushq  0x203742(%rip)        # 605008 <_GLOBAL_OFFSET_TABLE_+0x8>
  4018c6:	ff 25 44 37 20 00    	jmpq   *0x203744(%rip)        # 605010 <_GLOBAL_OFFSET_TABLE_+0x10>
  4018cc:	0f 1f 40 00          	nopl   0x0(%rax)

00000000004018d0 <__errno_location@plt>:
  4018d0:	ff 25 42 37 20 00    	jmpq   *0x203742(%rip)        # 605018 <__errno_location@GLIBC_2.2.5>
  4018d6:	68 00 00 00 00       	pushq  $0x0
  4018db:	e9 e0 ff ff ff       	jmpq   4018c0 <.plt>

00000000004018e0 <std::basic_ifstream<char, std::char_traits<char> >::~basic_ifstream()@plt>:
  4018e0:	ff 25 3a 37 20 00    	jmpq   *0x20373a(%rip)        # 605020 <std::basic_ifstream<char, std::char_traits<char> >::~basic_ifstream()@GLIBCXX_3.4>
  4018e6:	68 01 00 00 00       	pushq  $0x1
  4018eb:	e9 d0 ff ff ff       	jmpq   4018c0 <.plt>

00000000004018f0 <std::__throw_bad_alloc()@plt>:
  4018f0:	ff 25 32 37 20 00    	jmpq   *0x203732(%rip)        # 605028 <std::__throw_bad_alloc()@GLIBCXX_3.4>
  4018f6:	68 02 00 00 00       	pushq  $0x2
  4018fb:	e9 c0 ff ff ff       	jmpq   4018c0 <.plt>

0000000000401900 <std::istream::peek()@plt>:
  401900:	ff 25 2a 37 20 00    	jmpq   *0x20372a(%rip)        # 605030 <std::istream::peek()@GLIBCXX_3.4>
  401906:	68 03 00 00 00       	pushq  $0x3
  40190b:	e9 b0 ff ff ff       	jmpq   4018c0 <.plt>

0000000000401910 <std::runtime_error::runtime_error(char const*)@plt>:
  401910:	ff 25 22 37 20 00    	jmpq   *0x203722(%rip)        # 605038 <std::runtime_error::runtime_error(char const*)@GLIBCXX_3.4.21>
  401916:	68 04 00 00 00       	pushq  $0x4
  40191b:	e9 a0 ff ff ff       	jmpq   4018c0 <.plt>

0000000000401920 <__cxa_begin_catch@plt>:
  401920:	ff 25 1a 37 20 00    	jmpq   *0x20371a(%rip)        # 605040 <__cxa_begin_catch@CXXABI_1.3>
  401926:	68 05 00 00 00       	pushq  $0x5
  40192b:	e9 90 ff ff ff       	jmpq   4018c0 <.plt>

0000000000401930 <strlen@plt>:
  401930:	ff 25 12 37 20 00    	jmpq   *0x203712(%rip)        # 605048 <strlen@GLIBC_2.2.5>
  401936:	68 06 00 00 00       	pushq  $0x6
  40193b:	e9 80 ff ff ff       	jmpq   4018c0 <.plt>

0000000000401940 <memcmp@plt>:
  401940:	ff 25 0a 37 20 00    	jmpq   *0x20370a(%rip)        # 605050 <memcmp@GLIBC_2.2.5>
  401946:	68 07 00 00 00       	pushq  $0x7
  40194b:	e9 70 ff ff ff       	jmpq   4018c0 <.plt>

0000000000401950 <__cxa_allocate_exception@plt>:
  401950:	ff 25 02 37 20 00    	jmpq   *0x203702(%rip)        # 605058 <__cxa_allocate_exception@CXXABI_1.3>
  401956:	68 08 00 00 00       	pushq  $0x8
  40195b:	e9 60 ff ff ff       	jmpq   4018c0 <.plt>

0000000000401960 <std::__throw_length_error(char const*)@plt>:
  401960:	ff 25 fa 36 20 00    	jmpq   *0x2036fa(%rip)        # 605060 <std::__throw_length_error(char const*)@GLIBCXX_3.4>
  401966:	68 09 00 00 00       	pushq  $0x9
  40196b:	e9 50 ff ff ff       	jmpq   4018c0 <.plt>

0000000000401970 <memset@plt>:
  401970:	ff 25 f2 36 20 00    	jmpq   *0x2036f2(%rip)        # 605068 <memset@GLIBC_2.2.5>
  401976:	68 0a 00 00 00       	pushq  $0xa
  40197b:	e9 40 ff ff ff       	jmpq   4018c0 <.plt>

0000000000401980 <std::__throw_invalid_argument(char const*)@plt>:
  401980:	ff 25 ea 36 20 00    	jmpq   *0x2036ea(%rip)        # 605070 <std::__throw_invalid_argument(char const*)@GLIBCXX_3.4>
  401986:	68 0b 00 00 00       	pushq  $0xb
  40198b:	e9 30 ff ff ff       	jmpq   4018c0 <.plt>

0000000000401990 <std::__throw_logic_error(char const*)@plt>:
  401990:	ff 25 e2 36 20 00    	jmpq   *0x2036e2(%rip)        # 605078 <std::__throw_logic_error(char const*)@GLIBCXX_3.4>
  401996:	68 0c 00 00 00       	pushq  $0xc
  40199b:	e9 20 ff ff ff       	jmpq   4018c0 <.plt>

00000000004019a0 <__cxa_free_exception@plt>:
  4019a0:	ff 25 da 36 20 00    	jmpq   *0x2036da(%rip)        # 605080 <__cxa_free_exception@CXXABI_1.3>
  4019a6:	68 0d 00 00 00       	pushq  $0xd
  4019ab:	e9 10 ff ff ff       	jmpq   4018c0 <.plt>

00000000004019b0 <memcpy@plt>:
  4019b0:	ff 25 d2 36 20 00    	jmpq   *0x2036d2(%rip)        # 605088 <memcpy@GLIBC_2.14>
  4019b6:	68 0e 00 00 00       	pushq  $0xe
  4019bb:	e9 00 ff ff ff       	jmpq   4018c0 <.plt>

00000000004019c0 <__cxa_atexit@plt>:
  4019c0:	ff 25 ca 36 20 00    	jmpq   *0x2036ca(%rip)        # 605090 <__cxa_atexit@GLIBC_2.2.5>
  4019c6:	68 0f 00 00 00       	pushq  $0xf
  4019cb:	e9 f0 fe ff ff       	jmpq   4018c0 <.plt>

00000000004019d0 <operator delete(void*)@plt>:
  4019d0:	ff 25 c2 36 20 00    	jmpq   *0x2036c2(%rip)        # 605098 <operator delete(void*)@GLIBCXX_3.4>
  4019d6:	68 10 00 00 00       	pushq  $0x10
  4019db:	e9 e0 fe ff ff       	jmpq   4018c0 <.plt>

00000000004019e0 <std::basic_ostream<char, std::char_traits<char> >& std::operator<< <std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*)@plt>:
  4019e0:	ff 25 ba 36 20 00    	jmpq   *0x2036ba(%rip)        # 6050a0 <std::basic_ostream<char, std::char_traits<char> >& std::operator<< <std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*)@GLIBCXX_3.4>
  4019e6:	68 11 00 00 00       	pushq  $0x11
  4019eb:	e9 d0 fe ff ff       	jmpq   4018c0 <.plt>

00000000004019f0 <operator new(unsigned long)@plt>:
  4019f0:	ff 25 b2 36 20 00    	jmpq   *0x2036b2(%rip)        # 6050a8 <operator new(unsigned long)@GLIBCXX_3.4>
  4019f6:	68 12 00 00 00       	pushq  $0x12
  4019fb:	e9 c0 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401a00 <std::runtime_error::~runtime_error()@plt>:
  401a00:	ff 25 aa 36 20 00    	jmpq   *0x2036aa(%rip)        # 6050b0 <std::runtime_error::~runtime_error()@GLIBCXX_3.4>
  401a06:	68 13 00 00 00       	pushq  $0x13
  401a0b:	e9 b0 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401a10 <std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)@plt>:
  401a10:	ff 25 a2 36 20 00    	jmpq   *0x2036a2(%rip)        # 6050b8 <std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)@GLIBCXX_3.4.9>
  401a16:	68 14 00 00 00       	pushq  $0x14
  401a1b:	e9 a0 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401a20 <std::ctype<char>::_M_widen_init() const@plt>:
  401a20:	ff 25 9a 36 20 00    	jmpq   *0x20369a(%rip)        # 6050c0 <std::ctype<char>::_M_widen_init() const@GLIBCXX_3.4.11>
  401a26:	68 15 00 00 00       	pushq  $0x15
  401a2b:	e9 90 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401a30 <std::istream::get()@plt>:
  401a30:	ff 25 92 36 20 00    	jmpq   *0x203692(%rip)        # 6050c8 <std::istream::get()@GLIBCXX_3.4>
  401a36:	68 16 00 00 00       	pushq  $0x16
  401a3b:	e9 80 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401a40 <std::istream::read(char*, long)@plt>:
  401a40:	ff 25 8a 36 20 00    	jmpq   *0x20368a(%rip)        # 6050d0 <std::istream::read(char*, long)@GLIBCXX_3.4>
  401a46:	68 17 00 00 00       	pushq  $0x17
  401a4b:	e9 70 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401a50 <std::__throw_bad_cast()@plt>:
  401a50:	ff 25 82 36 20 00    	jmpq   *0x203682(%rip)        # 6050d8 <std::__throw_bad_cast()@GLIBCXX_3.4>
  401a56:	68 18 00 00 00       	pushq  $0x18
  401a5b:	e9 60 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401a60 <std::basic_istream<char, std::char_traits<char> >& std::operator>><char, std::char_traits<char>, std::allocator<char> >(std::basic_istream<char, std::char_traits<char> >&, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >&)@plt>:
  401a60:	ff 25 7a 36 20 00    	jmpq   *0x20367a(%rip)        # 6050e0 <std::basic_istream<char, std::char_traits<char> >& std::operator>><char, std::char_traits<char>, std::allocator<char> >(std::basic_istream<char, std::char_traits<char> >&, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >&)@GLIBCXX_3.4.21>
  401a66:	68 19 00 00 00       	pushq  $0x19
  401a6b:	e9 50 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401a70 <std::ostream::write(char const*, long)@plt>:
  401a70:	ff 25 72 36 20 00    	jmpq   *0x203672(%rip)        # 6050e8 <std::ostream::write(char const*, long)@GLIBCXX_3.4>
  401a76:	68 1a 00 00 00       	pushq  $0x1a
  401a7b:	e9 40 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401a80 <std::chrono::_V2::steady_clock::now()@plt>:
  401a80:	ff 25 6a 36 20 00    	jmpq   *0x20366a(%rip)        # 6050f0 <std::chrono::_V2::steady_clock::now()@GLIBCXX_3.4.19>
  401a86:	68 1b 00 00 00       	pushq  $0x1b
  401a8b:	e9 30 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401a90 <strtof@plt>:
  401a90:	ff 25 62 36 20 00    	jmpq   *0x203662(%rip)        # 6050f8 <strtof@GLIBC_2.2.5>
  401a96:	68 1c 00 00 00       	pushq  $0x1c
  401a9b:	e9 20 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401aa0 <atan2f@plt>:
  401aa0:	ff 25 5a 36 20 00    	jmpq   *0x20365a(%rip)        # 605100 <atan2f@GLIBC_2.2.5>
  401aa6:	68 1d 00 00 00       	pushq  $0x1d
  401aab:	e9 10 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401ab0 <std::istream::get(char&)@plt>:
  401ab0:	ff 25 52 36 20 00    	jmpq   *0x203652(%rip)        # 605108 <std::istream::get(char&)@GLIBCXX_3.4>
  401ab6:	68 1e 00 00 00       	pushq  $0x1e
  401abb:	e9 00 fe ff ff       	jmpq   4018c0 <.plt>

0000000000401ac0 <strtol@plt>:
  401ac0:	ff 25 4a 36 20 00    	jmpq   *0x20364a(%rip)        # 605110 <strtol@GLIBC_2.2.5>
  401ac6:	68 1f 00 00 00       	pushq  $0x1f
  401acb:	e9 f0 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401ad0 <std::__throw_out_of_range(char const*)@plt>:
  401ad0:	ff 25 42 36 20 00    	jmpq   *0x203642(%rip)        # 605118 <std::__throw_out_of_range(char const*)@GLIBCXX_3.4>
  401ad6:	68 20 00 00 00       	pushq  $0x20
  401adb:	e9 e0 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401ae0 <std::basic_ofstream<char, std::char_traits<char> >::~basic_ofstream()@plt>:
  401ae0:	ff 25 3a 36 20 00    	jmpq   *0x20363a(%rip)        # 605120 <std::basic_ofstream<char, std::char_traits<char> >::~basic_ofstream()@GLIBCXX_3.4>
  401ae6:	68 21 00 00 00       	pushq  $0x21
  401aeb:	e9 d0 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401af0 <std::ios_base::Init::Init()@plt>:
  401af0:	ff 25 32 36 20 00    	jmpq   *0x203632(%rip)        # 605128 <std::ios_base::Init::Init()@GLIBCXX_3.4>
  401af6:	68 22 00 00 00       	pushq  $0x22
  401afb:	e9 c0 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401b00 <std::ostream& std::ostream::_M_insert<double>(double)@plt>:
  401b00:	ff 25 2a 36 20 00    	jmpq   *0x20362a(%rip)        # 605130 <std::ostream& std::ostream::_M_insert<double>(double)@GLIBCXX_3.4.9>
  401b06:	68 23 00 00 00       	pushq  $0x23
  401b0b:	e9 b0 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401b10 <std::basic_ifstream<char, std::char_traits<char> >::basic_ifstream(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, std::_Ios_Openmode)@plt>:
  401b10:	ff 25 22 36 20 00    	jmpq   *0x203622(%rip)        # 605138 <std::basic_ifstream<char, std::char_traits<char> >::basic_ifstream(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, std::_Ios_Openmode)@GLIBCXX_3.4.21>
  401b16:	68 24 00 00 00       	pushq  $0x24
  401b1b:	e9 a0 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401b20 <std::runtime_error::runtime_error(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)@plt>:
  401b20:	ff 25 1a 36 20 00    	jmpq   *0x20361a(%rip)        # 605140 <std::runtime_error::runtime_error(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)@GLIBCXX_3.4.21>
  401b26:	68 25 00 00 00       	pushq  $0x25
  401b2b:	e9 90 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401b30 <memmove@plt>:
  401b30:	ff 25 12 36 20 00    	jmpq   *0x203612(%rip)        # 605148 <memmove@GLIBC_2.2.5>
  401b36:	68 26 00 00 00       	pushq  $0x26
  401b3b:	e9 80 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401b40 <__cxa_end_catch@plt>:
  401b40:	ff 25 0a 36 20 00    	jmpq   *0x20360a(%rip)        # 605150 <__cxa_end_catch@CXXABI_1.3>
  401b46:	68 27 00 00 00       	pushq  $0x27
  401b4b:	e9 70 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401b50 <__gxx_personality_v0@plt>:
  401b50:	ff 25 02 36 20 00    	jmpq   *0x203602(%rip)        # 605158 <__gxx_personality_v0@CXXABI_1.3>
  401b56:	68 28 00 00 00       	pushq  $0x28
  401b5b:	e9 60 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401b60 <expf@plt>:
  401b60:	ff 25 fa 35 20 00    	jmpq   *0x2035fa(%rip)        # 605160 <expf@GLIBC_2.27>
  401b66:	68 29 00 00 00       	pushq  $0x29
  401b6b:	e9 50 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401b70 <std::basic_ios<char, std::char_traits<char> >::clear(std::_Ios_Iostate)@plt>:
  401b70:	ff 25 f2 35 20 00    	jmpq   *0x2035f2(%rip)        # 605168 <std::basic_ios<char, std::char_traits<char> >::clear(std::_Ios_Iostate)@GLIBCXX_3.4>
  401b76:	68 2a 00 00 00       	pushq  $0x2a
  401b7b:	e9 40 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401b80 <__cxa_throw@plt>:
  401b80:	ff 25 ea 35 20 00    	jmpq   *0x2035ea(%rip)        # 605170 <__cxa_throw@CXXABI_1.3>
  401b86:	68 2b 00 00 00       	pushq  $0x2b
  401b8b:	e9 30 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401b90 <std::ostream::operator<<(int)@plt>:
  401b90:	ff 25 e2 35 20 00    	jmpq   *0x2035e2(%rip)        # 605178 <std::ostream::operator<<(int)@GLIBCXX_3.4>
  401b96:	68 2c 00 00 00       	pushq  $0x2c
  401b9b:	e9 20 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401ba0 <_Unwind_Resume@plt>:
  401ba0:	ff 25 da 35 20 00    	jmpq   *0x2035da(%rip)        # 605180 <_Unwind_Resume@GCC_3.0>
  401ba6:	68 2d 00 00 00       	pushq  $0x2d
  401bab:	e9 10 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401bb0 <sqrtf@plt>:
  401bb0:	ff 25 d2 35 20 00    	jmpq   *0x2035d2(%rip)        # 605188 <sqrtf@GLIBC_2.2.5>
  401bb6:	68 2e 00 00 00       	pushq  $0x2e
  401bbb:	e9 00 fd ff ff       	jmpq   4018c0 <.plt>

0000000000401bc0 <std::basic_istream<char, std::char_traits<char> >& std::getline<char, std::char_traits<char>, std::allocator<char> >(std::basic_istream<char, std::char_traits<char> >&, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >&, char)@plt>:
  401bc0:	ff 25 ca 35 20 00    	jmpq   *0x2035ca(%rip)        # 605190 <std::basic_istream<char, std::char_traits<char> >& std::getline<char, std::char_traits<char>, std::allocator<char> >(std::basic_istream<char, std::char_traits<char> >&, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >&, char)@GLIBCXX_3.4.21>
  401bc6:	68 2f 00 00 00       	pushq  $0x2f
  401bcb:	e9 f0 fc ff ff       	jmpq   4018c0 <.plt>

0000000000401bd0 <std::basic_ofstream<char, std::char_traits<char> >::basic_ofstream(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, std::_Ios_Openmode)@plt>:
  401bd0:	ff 25 c2 35 20 00    	jmpq   *0x2035c2(%rip)        # 605198 <std::basic_ofstream<char, std::char_traits<char> >::basic_ofstream(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, std::_Ios_Openmode)@GLIBCXX_3.4.21>
  401bd6:	68 30 00 00 00       	pushq  $0x30
  401bdb:	e9 e0 fc ff ff       	jmpq   4018c0 <.plt>

0000000000401be0 <std::ios_base::Init::~Init()@plt>:
  401be0:	ff 25 ba 35 20 00    	jmpq   *0x2035ba(%rip)        # 6051a0 <std::ios_base::Init::~Init()@GLIBCXX_3.4>
  401be6:	68 31 00 00 00       	pushq  $0x31
  401beb:	e9 d0 fc ff ff       	jmpq   4018c0 <.plt>

Disassembly of section .text:

0000000000401bf0 <token(std::istream&) [clone .cold.118]>:

// Next PGM header token. A '#' starts a comment that runs to the end of the line.
static std::string token(std::istream& in) {
    std::string s;
    while(in >> s) { if(s[0]!='#') return s; std::getline(in,s); }
    throw std::runtime_error("Invalid PGM header");
  401bf0:	ba 00 1a 40 00       	mov    $0x401a00,%edx
  401bf5:	be b0 4d 60 00       	mov    $0x604db0,%esi
  401bfa:	48 89 ef             	mov    %rbp,%rdi
  401bfd:	e8 7e ff ff ff       	callq  401b80 <__cxa_throw@plt>
  401c02:	48 89 c3             	mov    %rax,%rbx
  401c05:	eb 08                	jmp    401c0f <token(std::istream&) [clone .cold.118]+0x1f>
  401c07:	48 89 ef             	mov    %rbp,%rdi
  401c0a:	e8 91 fd ff ff       	callq  4019a0 <__cxa_free_exception@plt>
	traits_type::assign(_M_data()[__n], _CharT());
      }

      bool
      _M_is_local() const
      { return _M_data() == _M_local_data(); }
  401c0f:	49 8b 3c 24          	mov    (%r12),%rdi
      _M_create(size_type&, size_type);

      void
      _M_dispose()
      {
	if (!_M_is_local())
  401c13:	49 39 fd             	cmp    %rdi,%r13
  401c16:	74 05                	je     401c1d <token(std::istream&) [clone .cold.118]+0x2d>
	  {
	    ::operator delete(__p, std::align_val_t(alignof(_Tp)));
	    return;
	  }
#endif
	::operator delete(__p);
  401c18:	e8 b3 fd ff ff       	callq  4019d0 <operator delete(void*)@plt>
      ~new_allocator() _GLIBCXX_USE_NOEXCEPT { }
  401c1d:	48 89 df             	mov    %rbx,%rdi
  401c20:	e8 7b ff ff ff       	callq  401ba0 <_Unwind_Resume@plt>

0000000000401c25 <main.cold.119>:
  401c25:	90                   	nop
    char separator; in.get(separator);
    if(separator=='\r' && in.peek()=='\n') in.get();
    size_t n=size_t(w)*h;
    std::vector<uint8_t> image(n), edges(n), labels(n);
    in.read(reinterpret_cast<char*>(image.data()),std::streamsize(n));
    if(size_t(in.gcount())!=n) throw std::runtime_error("Truncated image");
  401c26:	48 89 c3             	mov    %rax,%rbx
  401c29:	48 89 d5             	mov    %rdx,%rbp
            samples.push_back(row);
        }
    }

    // Write output: binary PGM edge map. Kept pixels are 255, the rest are 0.
    std::ofstream out(output,std::ios::binary); out<<"P5\n"<<w<<" "<<h<<"\n255\n";
  401c2c:	48 8d bc 24 d0 02 00 	lea    0x2d0(%rsp),%rdi
  401c33:	00 
  401c34:	e8 a7 fe ff ff       	callq  401ae0 <std::basic_ofstream<char, std::char_traits<char> >::~basic_ofstream()@plt>
       *  not touched in any way.  Managing the pointer is the user's
       *  responsibility.
       */
      ~vector() _GLIBCXX_NOEXCEPT
      {
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  401c39:	48 8b bc 24 d0 01 00 	mov    0x1d0(%rsp),%rdi
  401c40:	00 
	if (__p)
  401c41:	48 85 ff             	test   %rdi,%rdi
  401c44:	74 05                	je     401c4b <main.cold.119+0x26>
	::operator delete(__p);
  401c46:	e8 85 fd ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  401c4b:	48 8b bc 24 b0 01 00 	mov    0x1b0(%rsp),%rdi
  401c52:	00 
	if (__p)
  401c53:	48 85 ff             	test   %rdi,%rdi
  401c56:	74 05                	je     401c5d <main.cold.119+0x38>
  401c58:	e8 73 fd ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  401c5d:	48 8b bc 24 90 01 00 	mov    0x190(%rsp),%rdi
  401c64:	00 
	if (__p)
  401c65:	48 85 ff             	test   %rdi,%rdi
  401c68:	74 05                	je     401c6f <main.cold.119+0x4a>
  401c6a:	e8 61 fd ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  401c6f:	48 8b bc 24 70 01 00 	mov    0x170(%rsp),%rdi
  401c76:	00 
	if (__p)
  401c77:	48 85 ff             	test   %rdi,%rdi
  401c7a:	74 05                	je     401c81 <main.cold.119+0x5c>
  401c7c:	e8 4f fd ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  401c81:	48 8b bc 24 50 01 00 	mov    0x150(%rsp),%rdi
  401c88:	00 
	if (__p)
  401c89:	48 85 ff             	test   %rdi,%rdi
  401c8c:	74 05                	je     401c93 <main.cold.119+0x6e>
  401c8e:	e8 3d fd ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  401c93:	48 8b bc 24 30 01 00 	mov    0x130(%rsp),%rdi
  401c9a:	00 
	if (__p)
  401c9b:	48 85 ff             	test   %rdi,%rdi
  401c9e:	74 05                	je     401ca5 <main.cold.119+0x80>
  401ca0:	e8 2b fd ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  401ca5:	48 8b bc 24 10 01 00 	mov    0x110(%rsp),%rdi
  401cac:	00 
	if (__p)
  401cad:	48 85 ff             	test   %rdi,%rdi
  401cb0:	74 05                	je     401cb7 <main.cold.119+0x92>
  401cb2:	e8 19 fd ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  401cb7:	48 8b bc 24 f0 00 00 	mov    0xf0(%rsp),%rdi
  401cbe:	00 
	if (__p)
  401cbf:	48 85 ff             	test   %rdi,%rdi
  401cc2:	74 05                	je     401cc9 <main.cold.119+0xa4>
  401cc4:	e8 07 fd ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  401cc9:	48 8b bc 24 d0 00 00 	mov    0xd0(%rsp),%rdi
  401cd0:	00 
	if (__p)
  401cd1:	48 85 ff             	test   %rdi,%rdi
  401cd4:	74 05                	je     401cdb <main.cold.119+0xb6>
  401cd6:	e8 f5 fc ff ff       	callq  4019d0 <operator delete(void*)@plt>
    std::ifstream in(input,std::ios::binary);
  401cdb:	48 8b 7c 24 10       	mov    0x10(%rsp),%rdi
  401ce0:	e8 fb fb ff ff       	callq  4018e0 <std::basic_ifstream<char, std::char_traits<char> >::~basic_ifstream()@plt>
  401ce5:	eb 08                	jmp    401cef <main.cold.119+0xca>
        if(a+1==argc) throw std::runtime_error("Missing option value");
  401ce7:	4c 89 e7             	mov    %r12,%rdi
  401cea:	e8 b1 fc ff ff       	callq  4019a0 <__cxa_free_exception@plt>
      { return _M_data() == _M_local_data(); }
  401cef:	48 8b bc 24 10 02 00 	mov    0x210(%rsp),%rdi
  401cf6:	00 
	if (!_M_is_local())
  401cf7:	48 8d 84 24 20 02 00 	lea    0x220(%rsp),%rax
  401cfe:	00 
  401cff:	48 39 c7             	cmp    %rax,%rdi
  401d02:	74 05                	je     401d09 <main.cold.119+0xe4>
  401d04:	e8 c7 fc ff ff       	callq  4019d0 <operator delete(void*)@plt>
      { return _M_data() == _M_local_data(); }
  401d09:	48 8b bc 24 f0 01 00 	mov    0x1f0(%rsp),%rdi
  401d10:	00 
	if (!_M_is_local())
  401d11:	48 8d 84 24 00 02 00 	lea    0x200(%rsp),%rax
  401d18:	00 
  401d19:	48 39 c7             	cmp    %rax,%rdi
  401d1c:	74 05                	je     401d23 <main.cold.119+0xfe>
  401d1e:	e8 ad fc ff ff       	callq  4019d0 <operator delete(void*)@plt>
      ~new_allocator() _GLIBCXX_USE_NOEXCEPT { }
  401d23:	48 83 ed 01          	sub    $0x1,%rbp
        for(int s=0;s<5;++s) std::cout<<",\""<<names[s]<<"\":"<<samples[i][s+1];
        std::cout<<"}";
    }
    std::cout<<"]}\n";
    return 0;
} catch(const std::exception& e) {std::cerr<<e.what()<<"\n";return 1;}
  401d27:	48 89 df             	mov    %rbx,%rdi
  401d2a:	75 61                	jne    401d8d <main.cold.119+0x168>
  401d2c:	e8 ef fb ff ff       	callq  401920 <__cxa_begin_catch@plt>
  401d31:	48 8b 10             	mov    (%rax),%rdx
  401d34:	48 89 c7             	mov    %rax,%rdi
  401d37:	ff 52 10             	callq  *0x10(%rdx)
  401d3a:	bf e0 52 60 00       	mov    $0x6052e0,%edi
  401d3f:	48 89 c6             	mov    %rax,%rsi
  401d42:	e8 99 fc ff ff       	callq  4019e0 <std::basic_ostream<char, std::char_traits<char> >& std::operator<< <std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*)@plt>
  401d47:	be a2 43 40 00       	mov    $0x4043a2,%esi
  401d4c:	48 89 c7             	mov    %rax,%rdi
  401d4f:	e8 8c fc ff ff       	callq  4019e0 <std::basic_ostream<char, std::char_traits<char> >& std::operator<< <std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*)@plt>
  401d54:	e8 e7 fd ff ff       	callq  401b40 <__cxa_end_catch@plt>
  401d59:	bb 01 00 00 00       	mov    $0x1,%ebx
  401d5e:	e9 09 15 00 00       	jmpq   40326c <main+0x13bc>
    if(size_t(in.gcount())!=n) throw std::runtime_error("Truncated image");
  401d63:	ba 00 1a 40 00       	mov    $0x401a00,%edx
  401d68:	be b0 4d 60 00       	mov    $0x604db0,%esi
  401d6d:	4c 89 e7             	mov    %r12,%rdi
  401d70:	e8 0b fe ff ff       	callq  401b80 <__cxa_throw@plt>
  401d75:	48 89 c3             	mov    %rax,%rbx
  401d78:	48 89 d5             	mov    %rdx,%rbp
  401d7b:	e9 25 ff ff ff       	jmpq   401ca5 <main.cold.119+0x80>
  401d80:	4c 89 e7             	mov    %r12,%rdi
  401d83:	e8 18 fc ff ff       	callq  4019a0 <__cxa_free_exception@plt>
  401d88:	e9 18 ff ff ff       	jmpq   401ca5 <main.cold.119+0x80>
  401d8d:	e8 0e fe ff ff       	callq  401ba0 <_Unwind_Resume@plt>
    if(token(in)!="255" || w<5 || h<5) throw std::runtime_error("Expected >=5x5 uint8 PGM");
  401d92:	ba 00 1a 40 00       	mov    $0x401a00,%edx
  401d97:	be b0 4d 60 00       	mov    $0x604db0,%esi
  401d9c:	4c 89 e7             	mov    %r12,%rdi
  401d9f:	e8 dc fd ff ff       	callq  401b80 <__cxa_throw@plt>
  401da4:	48 89 c3             	mov    %rax,%rbx
  401da7:	48 89 d5             	mov    %rdx,%rbp
  401daa:	e9 2c ff ff ff       	jmpq   401cdb <main.cold.119+0xb6>
  401daf:	4c 89 e7             	mov    %r12,%rdi
  401db2:	e8 e9 fb ff ff       	callq  4019a0 <__cxa_free_exception@plt>
  401db7:	e9 1f ff ff ff       	jmpq   401cdb <main.cold.119+0xb6>
      { return _M_data() == _M_local_data(); }
  401dbc:	48 8b bc 24 d0 02 00 	mov    0x2d0(%rsp),%rdi
  401dc3:	00 
	if (!_M_is_local())
  401dc4:	48 8d 84 24 e0 02 00 	lea    0x2e0(%rsp),%rax
  401dcb:	00 
  401dcc:	48 39 c7             	cmp    %rax,%rdi
  401dcf:	0f 85 01 ff ff ff    	jne    401cd6 <main.cold.119+0xb1>
  401dd5:	e9 01 ff ff ff       	jmpq   401cdb <main.cold.119+0xb6>
  401dda:	48 89 c3             	mov    %rax,%rbx
  401ddd:	48 89 d5             	mov    %rdx,%rbp
      { return _M_data() == _M_local_data(); }
  401de0:	48 8b bc 24 d0 02 00 	mov    0x2d0(%rsp),%rdi
  401de7:	00 
	if (!_M_is_local())
  401de8:	48 8d 84 24 e0 02 00 	lea    0x2e0(%rsp),%rax
  401def:	00 
  401df0:	48 39 c7             	cmp    %rax,%rdi
  401df3:	74 05                	je     401dfa <main.cold.119+0x1d5>
	::operator delete(__p);
  401df5:	e8 d6 fb ff ff       	callq  4019d0 <operator delete(void*)@plt>
  401dfa:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
      { return _M_data() == _M_local_data(); }
  401dff:	48 8b bc 24 60 02 00 	mov    0x260(%rsp),%rdi
  401e06:	00 
	if (!_M_is_local())
  401e07:	48 83 c0 10          	add    $0x10,%rax
  401e0b:	48 39 c7             	cmp    %rax,%rdi
  401e0e:	0f 84 db fe ff ff    	je     401cef <main.cold.119+0xca>
  401e14:	e8 b7 fb ff ff       	callq  4019d0 <operator delete(void*)@plt>
      ~new_allocator() _GLIBCXX_USE_NOEXCEPT { }
  401e19:	e9 d1 fe ff ff       	jmpq   401cef <main.cold.119+0xca>
  401e1e:	48 89 c3             	mov    %rax,%rbx
} catch(const std::exception& e) {std::cerr<<e.what()<<"\n";return 1;}
  401e21:	e8 1a fd ff ff       	callq  401b40 <__cxa_end_catch@plt>
  401e26:	48 89 df             	mov    %rbx,%rdi
  401e29:	e8 72 fd ff ff       	callq  401ba0 <_Unwind_Resume@plt>
        throw std::runtime_error("Invalid iteration count or parameters");
  401e2e:	4c 89 e7             	mov    %r12,%rdi
  401e31:	e8 6a fb ff ff       	callq  4019a0 <__cxa_free_exception@plt>
  401e36:	e9 b4 fe ff ff       	jmpq   401cef <main.cold.119+0xca>
    if(token(in)!="P5") throw std::runtime_error("Expected binary PGM");
  401e3b:	ba 00 1a 40 00       	mov    $0x401a00,%edx
  401e40:	be b0 4d 60 00       	mov    $0x604db0,%esi
  401e45:	4c 89 e7             	mov    %r12,%rdi
  401e48:	e8 33 fd ff ff       	callq  401b80 <__cxa_throw@plt>
  401e4d:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
      { return _M_data() == _M_local_data(); }
  401e52:	48 8b bc 24 d0 04 00 	mov    0x4d0(%rsp),%rdi
  401e59:	00 
	if (!_M_is_local())
  401e5a:	48 83 c0 10          	add    $0x10,%rax
  401e5e:	48 39 c7             	cmp    %rax,%rdi
  401e61:	74 05                	je     401e68 <main.cold.119+0x243>
	::operator delete(__p);
  401e63:	e8 68 fb ff ff       	callq  4019d0 <operator delete(void*)@plt>
        else if(k=="--sigma") sigma=std::stof(v); else throw std::runtime_error("Unknown option "+k);
  401e68:	4c 89 e7             	mov    %r12,%rdi
  401e6b:	e8 30 fb ff ff       	callq  4019a0 <__cxa_free_exception@plt>
  401e70:	e9 6b ff ff ff       	jmpq   401de0 <main.cold.119+0x1bb>
  401e75:	ba 00 1a 40 00       	mov    $0x401a00,%edx
  401e7a:	be b0 4d 60 00       	mov    $0x604db0,%esi
  401e7f:	4c 89 e7             	mov    %r12,%rdi
  401e82:	e8 f9 fc ff ff       	callq  401b80 <__cxa_throw@plt>
    if(!out) throw std::runtime_error("Could not write output");
  401e87:	ba 00 1a 40 00       	mov    $0x401a00,%edx
  401e8c:	be b0 4d 60 00       	mov    $0x604db0,%esi
  401e91:	4c 89 e7             	mov    %r12,%rdi
  401e94:	e8 e7 fc ff ff       	callq  401b80 <__cxa_throw@plt>
  401e99:	4c 89 e7             	mov    %r12,%rdi
  401e9c:	e8 ff fa ff ff       	callq  4019a0 <__cxa_free_exception@plt>
  401ea1:	e9 86 fd ff ff       	jmpq   401c2c <main.cold.119+0x7>

0000000000401ea6 <.annobin_elf_init.c.exit>:
  401ea6:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  401ead:	00 00 00 

0000000000401eb0 <main>:
int main(int argc, char** argv) try {
  401eb0:	41 57                	push   %r15
  401eb2:	41 56                	push   %r14
  401eb4:	41 55                	push   %r13
  401eb6:	41 54                	push   %r12
  401eb8:	55                   	push   %rbp
  401eb9:	53                   	push   %rbx
  401eba:	48 81 ec e8 06 00 00 	sub    $0x6e8,%rsp
	: allocator_type(std::move(__a)), _M_p(__dat) { }
  401ec1:	48 8d 84 24 00 02 00 	lea    0x200(%rsp),%rax
  401ec8:	00 
      { _M_string_length = __length; }
  401ec9:	48 c7 84 24 f8 01 00 	movq   $0x0,0x1f8(%rsp)
  401ed0:	00 00 00 00 00 
	: allocator_type(std::move(__a)), _M_p(__dat) { }
  401ed5:	48 89 84 24 f0 01 00 	mov    %rax,0x1f0(%rsp)
  401edc:	00 
  401edd:	48 8d 84 24 20 02 00 	lea    0x220(%rsp),%rax
  401ee4:	00 
      typedef streamoff         off_type;
      typedef mbstate_t         state_type;

      static _GLIBCXX17_CONSTEXPR void
      assign(char_type& __c1, const char_type& __c2) _GLIBCXX_NOEXCEPT
      { __c1 = __c2; }
  401ee5:	c6 84 24 00 02 00 00 	movb   $0x0,0x200(%rsp)
  401eec:	00 
  401eed:	48 89 84 24 10 02 00 	mov    %rax,0x210(%rsp)
  401ef4:	00 
      { _M_string_length = __length; }
  401ef5:	48 c7 84 24 18 02 00 	movq   $0x0,0x218(%rsp)
  401efc:	00 00 00 00 00 
  401f01:	c6 84 24 20 02 00 00 	movb   $0x0,0x220(%rsp)
  401f08:	00 
    for(int a=1;a<argc;a+=2) {
  401f09:	83 ff 01             	cmp    $0x1,%edi
  401f0c:	0f 8e 9a 15 00 00    	jle    4034ac <main+0x15fc>
  401f12:	41 89 fc             	mov    %edi,%r12d
        if(a+1==argc) throw std::runtime_error("Missing option value");
  401f15:	83 ff 02             	cmp    $0x2,%edi
  401f18:	0f 84 62 15 00 00    	je     403480 <main+0x15d0>
  401f1e:	8d 47 fe             	lea    -0x2(%rdi),%eax
  401f21:	49 89 f5             	mov    %rsi,%r13
  401f24:	bd 01 00 00 00       	mov    $0x1,%ebp
    int iterations=100, warmup=10; float low=50, high=100, sigma=1.4f;
  401f29:	bb 0a 00 00 00       	mov    $0xa,%ebx
  401f2e:	f3 0f 10 3d aa 25 00 	movss  0x25aa(%rip),%xmm7        # 4044e0 <__dso_handle+0x238>
  401f35:	00 
  401f36:	d1 e8                	shr    %eax
  401f38:	c7 44 24 40 64 00 00 	movl   $0x64,0x40(%rsp)
  401f3f:	00 
	: allocator_type(__a), _M_p(__dat) { }
  401f40:	4c 8d b4 24 70 02 00 	lea    0x270(%rsp),%r14
  401f47:	00 
  401f48:	48 8d 44 00 01       	lea    0x1(%rax,%rax,1),%rax
  401f4d:	4c 8d bc 24 e0 02 00 	lea    0x2e0(%rsp),%r15
  401f54:	00 
  401f55:	f3 0f 11 3c 24       	movss  %xmm7,(%rsp)
  401f5a:	f3 0f 10 3d 82 25 00 	movss  0x2582(%rip),%xmm7        # 4044e4 <__dso_handle+0x23c>
  401f61:	00 
  401f62:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
  401f67:	48 8d 84 24 60 02 00 	lea    0x260(%rsp),%rax
  401f6e:	00 
  401f6f:	f3 0f 11 7c 24 44    	movss  %xmm7,0x44(%rsp)
  401f75:	f3 0f 10 3d 6b 25 00 	movss  0x256b(%rip),%xmm7        # 4044e8 <__dso_handle+0x240>
  401f7c:	00 
  401f7d:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
  401f82:	f3 0f 11 7c 24 3c    	movss  %xmm7,0x3c(%rsp)
  401f88:	eb 54                	jmp    401fde <main+0x12e>
       *  @return  Reference to this string.
       */
      basic_string&
      assign(const basic_string& __str)
      {
	this->_M_assign(__str);
  401f8a:	48 8d b4 24 d0 02 00 	lea    0x2d0(%rsp),%rsi
  401f91:	00 
  401f92:	48 8d bc 24 f0 01 00 	lea    0x1f0(%rsp),%rdi
  401f99:	00 
  401f9a:	e8 01 21 00 00       	callq  4040a0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)>
      { return _M_data() == _M_local_data(); }
  401f9f:	48 8b bc 24 d0 02 00 	mov    0x2d0(%rsp),%rdi
  401fa6:	00 
	if (!_M_is_local())
  401fa7:	4c 39 ff             	cmp    %r15,%rdi
  401faa:	74 05                	je     401fb1 <main+0x101>
  401fac:	e8 1f fa ff ff       	callq  4019d0 <operator delete(void*)@plt>
      { return _M_data() == _M_local_data(); }
  401fb1:	48 8b bc 24 60 02 00 	mov    0x260(%rsp),%rdi
  401fb8:	00 
	if (!_M_is_local())
  401fb9:	4c 39 f7             	cmp    %r14,%rdi
  401fbc:	74 05                	je     401fc3 <main+0x113>
  401fbe:	e8 0d fa ff ff       	callq  4019d0 <operator delete(void*)@plt>
    for(int a=1;a<argc;a+=2) {
  401fc3:	48 39 6c 24 10       	cmp    %rbp,0x10(%rsp)
  401fc8:	0f 84 08 01 00 00    	je     4020d6 <main+0x226>
        if(a+1==argc) throw std::runtime_error("Missing option value");
  401fce:	48 83 c5 02          	add    $0x2,%rbp
  401fd2:	8d 45 01             	lea    0x1(%rbp),%eax
  401fd5:	41 39 c4             	cmp    %eax,%r12d
  401fd8:	0f 84 a2 14 00 00    	je     403480 <main+0x15d0>
        std::string k=argv[a], v=argv[a+1];
  401fde:	49 8b 74 ed 00       	mov    0x0(%r13,%rbp,8),%rsi
	: allocator_type(__a), _M_p(__dat) { }
  401fe3:	4c 89 b4 24 60 02 00 	mov    %r14,0x260(%rsp)
  401fea:	00 
      { _M_construct(__s, __s ? __s + traits_type::length(__s) : __s+npos); }
  401feb:	48 c7 c2 ff ff ff ff 	mov    $0xffffffffffffffff,%rdx
  401ff2:	48 85 f6             	test   %rsi,%rsi
  401ff5:	74 16                	je     40200d <main+0x15d>
      {
#if __cplusplus > 201402
	if (__constant_string_p(__s))
	  return __gnu_cxx::char_traits<char_type>::length(__s);
#endif
	return __builtin_strlen(__s);
  401ff7:	48 89 f7             	mov    %rsi,%rdi
  401ffa:	48 89 74 24 18       	mov    %rsi,0x18(%rsp)
  401fff:	e8 2c f9 ff ff       	callq  401930 <strlen@plt>
  402004:	48 8b 74 24 18       	mov    0x18(%rsp),%rsi
  402009:	48 8d 14 06          	lea    (%rsi,%rax,1),%rdx
          _M_construct(__beg, __end, _Tag());
  40200d:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  402012:	e8 59 21 00 00       	callq  404170 <void std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_construct<char const*>(char const*, char const*, std::forward_iterator_tag)>
  402017:	49 8b 74 ed 08       	mov    0x8(%r13,%rbp,8),%rsi
	: allocator_type(__a), _M_p(__dat) { }
  40201c:	4c 89 bc 24 d0 02 00 	mov    %r15,0x2d0(%rsp)
  402023:	00 
      { _M_construct(__s, __s ? __s + traits_type::length(__s) : __s+npos); }
  402024:	48 c7 c2 ff ff ff ff 	mov    $0xffffffffffffffff,%rdx
  40202b:	48 85 f6             	test   %rsi,%rsi
  40202e:	74 16                	je     402046 <main+0x196>
  402030:	48 89 f7             	mov    %rsi,%rdi
  402033:	48 89 74 24 18       	mov    %rsi,0x18(%rsp)
  402038:	e8 f3 f8 ff ff       	callq  401930 <strlen@plt>
  40203d:	48 8b 74 24 18       	mov    0x18(%rsp),%rsi
  402042:	48 8d 14 06          	lea    (%rsi,%rax,1),%rdx
          _M_construct(__beg, __end, _Tag());
  402046:	48 8d bc 24 d0 02 00 	lea    0x2d0(%rsp),%rdi
  40204d:	00 
  40204e:	e8 1d 21 00 00       	callq  404170 <void std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_construct<char const*>(char const*, char const*, std::forward_iterator_tag)>
   */
  template<typename _CharT, typename _Traits, typename _Alloc>
    inline bool
    operator==(const basic_string<_CharT, _Traits, _Alloc>& __lhs,
	       const _CharT* __rhs)
    { return __lhs.compare(__rhs) == 0; }
  402053:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  402058:	be f0 42 40 00       	mov    $0x4042f0,%esi
  40205d:	e8 ae 1b 00 00       	callq  403c10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const>
        if(k=="--input") input=v; else if(k=="--output") output=v;
  402062:	85 c0                	test   %eax,%eax
  402064:	0f 84 20 ff ff ff    	je     401f8a <main+0xda>
  40206a:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  40206f:	be f8 42 40 00       	mov    $0x4042f8,%esi
  402074:	e8 97 1b 00 00       	callq  403c10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const>
  402079:	85 c0                	test   %eax,%eax
  40207b:	75 1a                	jne    402097 <main+0x1e7>
	this->_M_assign(__str);
  40207d:	48 8d b4 24 d0 02 00 	lea    0x2d0(%rsp),%rsi
  402084:	00 
  402085:	48 8d bc 24 10 02 00 	lea    0x210(%rsp),%rdi
  40208c:	00 
  40208d:	e8 0e 20 00 00       	callq  4040a0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)>
  402092:	e9 08 ff ff ff       	jmpq   401f9f <main+0xef>
    { return __lhs.compare(__rhs) == 0; }
  402097:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  40209c:	be 01 43 40 00       	mov    $0x404301,%esi
  4020a1:	e8 6a 1b 00 00       	callq  403c10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const>
        else if(k=="--iterations") iterations=std::stoi(v);
  4020a6:	85 c0                	test   %eax,%eax
  4020a8:	0f 85 32 02 00 00    	jne    4022e0 <main+0x430>

#if _GLIBCXX_USE_C99_STDLIB
  // 21.4 Numeric Conversions [string.conversions].
  inline int
  stoi(const string& __str, size_t* __idx = 0, int __base = 10)
  { return __gnu_cxx::__stoa<long, int>(&std::strtol, "stoi", __str.c_str(),
  4020ae:	48 8b 94 24 d0 02 00 	mov    0x2d0(%rsp),%rdx
  4020b5:	00 
  4020b6:	41 b8 0a 00 00 00    	mov    $0xa,%r8d
  4020bc:	31 c9                	xor    %ecx,%ecx
  4020be:	be 0e 43 40 00       	mov    $0x40430e,%esi
  4020c3:	bf c0 1a 40 00       	mov    $0x401ac0,%edi
  4020c8:	e8 c3 17 00 00       	callq  403890 <int __gnu_cxx::__stoa<long, int, char, int>(long (*)(char const*, char**, int), char const*, char const*, unsigned long*, int)>
  4020cd:	89 44 24 40          	mov    %eax,0x40(%rsp)
  4020d1:	e9 c9 fe ff ff       	jmpq   401f9f <main+0xef>
       !std::isfinite(low) || !std::isfinite(high) || low<0 || high<=low)
  4020d6:	8b 4c 24 40          	mov    0x40(%rsp),%ecx
  4020da:	85 c9                	test   %ecx,%ecx
  4020dc:	0f 8e 72 13 00 00    	jle    403454 <main+0x15a4>
  4020e2:	85 db                	test   %ebx,%ebx
  4020e4:	0f 88 6a 13 00 00    	js     403454 <main+0x15a4>
#endif

#ifndef __CORRECT_ISO_CPP11_MATH_H_PROTO_FP
  constexpr bool
  isfinite(float __x)
  { return __builtin_isfinite(__x); }
  4020ea:	f3 0f 10 3c 24       	movss  (%rsp),%xmm7
  4020ef:	f3 0f 10 2d 29 24 00 	movss  0x2429(%rip),%xmm5        # 404520 <__dso_handle+0x278>
  4020f6:	00 
    if(iterations<1 || warmup<0 || !std::isfinite(sigma) || sigma<=0 ||
  4020f7:	f3 0f 10 05 f1 23 00 	movss  0x23f1(%rip),%xmm0        # 4044f0 <__dso_handle+0x248>
  4020fe:	00 
  4020ff:	0f 29 6c 24 60       	movaps %xmm5,0x60(%rsp)
  402104:	0f 28 cf             	movaps %xmm7,%xmm1
  402107:	0f 54 cd             	andps  %xmm5,%xmm1
  40210a:	0f 2e c1             	ucomiss %xmm1,%xmm0
  40210d:	0f 82 41 13 00 00    	jb     403454 <main+0x15a4>
  402113:	66 0f ef c9          	pxor   %xmm1,%xmm1
  402117:	0f 2f cf             	comiss %xmm7,%xmm1
  40211a:	0f 83 34 13 00 00    	jae    403454 <main+0x15a4>
  402120:	f3 0f 10 6c 24 3c    	movss  0x3c(%rsp),%xmm5
  402126:	0f 28 74 24 60       	movaps 0x60(%rsp),%xmm6
  40212b:	0f 28 cd             	movaps %xmm5,%xmm1
  40212e:	0f 54 ce             	andps  %xmm6,%xmm1
  402131:	0f 2e c1             	ucomiss %xmm1,%xmm0
  402134:	0f 82 1a 13 00 00    	jb     403454 <main+0x15a4>
  40213a:	f3 0f 10 7c 24 44    	movss  0x44(%rsp),%xmm7
  402140:	0f 28 cf             	movaps %xmm7,%xmm1
  402143:	0f 54 ce             	andps  %xmm6,%xmm1
       !std::isfinite(low) || !std::isfinite(high) || low<0 || high<=low)
  402146:	0f 2e c1             	ucomiss %xmm1,%xmm0
  402149:	0f 82 05 13 00 00    	jb     403454 <main+0x15a4>
  40214f:	66 0f ef f6          	pxor   %xmm6,%xmm6
  402153:	0f 2f f5             	comiss %xmm5,%xmm6
  402156:	0f 87 f8 12 00 00    	ja     403454 <main+0x15a4>
  40215c:	0f 2f ef             	comiss %xmm7,%xmm5
  40215f:	0f 83 ef 12 00 00    	jae    403454 <main+0x15a4>
    std::ifstream in(input,std::ios::binary);
  402165:	48 8d 84 24 d0 04 00 	lea    0x4d0(%rsp),%rax
  40216c:	00 
  40216d:	ba 04 00 00 00       	mov    $0x4,%edx
  402172:	48 8d b4 24 f0 01 00 	lea    0x1f0(%rsp),%rsi
  402179:	00 
  40217a:	48 89 c7             	mov    %rax,%rdi
  40217d:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
  402182:	e8 89 f9 ff ff       	callq  401b10 <std::basic_ifstream<char, std::char_traits<char> >::basic_ifstream(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, std::_Ios_Openmode)@plt>
    if(token(in)!="P5") throw std::runtime_error("Expected binary PGM");
  402187:	48 8b 74 24 10       	mov    0x10(%rsp),%rsi
  40218c:	48 8d bc 24 30 02 00 	lea    0x230(%rsp),%rdi
  402193:	00 
  402194:	e8 f7 15 00 00       	callq  403790 <token(std::istream&)>
    { return __lhs.compare(__rhs) == 0; }
  402199:	48 8d bc 24 30 02 00 	lea    0x230(%rsp),%rdi
  4021a0:	00 
  4021a1:	be 46 43 40 00       	mov    $0x404346,%esi
  4021a6:	e8 65 1a 00 00       	callq  403c10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const>
      { return _M_data() == _M_local_data(); }
  4021ab:	48 8b bc 24 30 02 00 	mov    0x230(%rsp),%rdi
  4021b2:	00 
    { return __lhs.compare(__rhs) == 0; }
  4021b3:	89 c5                	mov    %eax,%ebp
	if (!_M_is_local())
  4021b5:	48 8d 84 24 40 02 00 	lea    0x240(%rsp),%rax
  4021bc:	00 
  4021bd:	48 39 c7             	cmp    %rax,%rdi
  4021c0:	74 05                	je     4021c7 <main+0x317>
  4021c2:	e8 09 f8 ff ff       	callq  4019d0 <operator delete(void*)@plt>
  4021c7:	85 ed                	test   %ebp,%ebp
  4021c9:	0f 85 5c 12 00 00    	jne    40342b <main+0x157b>
    int w=std::stoi(token(in)), h=std::stoi(token(in));
  4021cf:	48 8b 74 24 10       	mov    0x10(%rsp),%rsi
  4021d4:	48 8d bc 24 d0 02 00 	lea    0x2d0(%rsp),%rdi
  4021db:	00 
  4021dc:	e8 af 15 00 00       	callq  403790 <token(std::istream&)>
  { return __gnu_cxx::__stoa<long, int>(&std::strtol, "stoi", __str.c_str(),
  4021e1:	48 8b 94 24 d0 02 00 	mov    0x2d0(%rsp),%rdx
  4021e8:	00 
  4021e9:	41 b8 0a 00 00 00    	mov    $0xa,%r8d
  4021ef:	31 c9                	xor    %ecx,%ecx
  4021f1:	be 0e 43 40 00       	mov    $0x40430e,%esi
  4021f6:	bf c0 1a 40 00       	mov    $0x401ac0,%edi
  4021fb:	e8 90 16 00 00       	callq  403890 <int __gnu_cxx::__stoa<long, int, char, int>(long (*)(char const*, char**, int), char const*, char const*, unsigned long*, int)>
      { return _M_data() == _M_local_data(); }
  402200:	48 8b bc 24 d0 02 00 	mov    0x2d0(%rsp),%rdi
  402207:	00 
  { return __gnu_cxx::__stoa<long, int>(&std::strtol, "stoi", __str.c_str(),
  402208:	89 c5                	mov    %eax,%ebp
	if (!_M_is_local())
  40220a:	48 8d 84 24 e0 02 00 	lea    0x2e0(%rsp),%rax
  402211:	00 
  402212:	48 39 c7             	cmp    %rax,%rdi
  402215:	74 05                	je     40221c <main+0x36c>
  402217:	e8 b4 f7 ff ff       	callq  4019d0 <operator delete(void*)@plt>
  40221c:	48 8b 74 24 10       	mov    0x10(%rsp),%rsi
  402221:	48 8d bc 24 d0 02 00 	lea    0x2d0(%rsp),%rdi
  402228:	00 
  402229:	e8 62 15 00 00       	callq  403790 <token(std::istream&)>
  { return __gnu_cxx::__stoa<long, int>(&std::strtol, "stoi", __str.c_str(),
  40222e:	48 8b 94 24 d0 02 00 	mov    0x2d0(%rsp),%rdx
  402235:	00 
  402236:	41 b8 0a 00 00 00    	mov    $0xa,%r8d
  40223c:	31 c9                	xor    %ecx,%ecx
  40223e:	be 0e 43 40 00       	mov    $0x40430e,%esi
  402243:	bf c0 1a 40 00       	mov    $0x401ac0,%edi
  402248:	e8 43 16 00 00       	callq  403890 <int __gnu_cxx::__stoa<long, int, char, int>(long (*)(char const*, char**, int), char const*, char const*, unsigned long*, int)>
      { return _M_data() == _M_local_data(); }
  40224d:	48 8b bc 24 d0 02 00 	mov    0x2d0(%rsp),%rdi
  402254:	00 
  { return __gnu_cxx::__stoa<long, int>(&std::strtol, "stoi", __str.c_str(),
  402255:	41 89 c4             	mov    %eax,%r12d
	if (!_M_is_local())
  402258:	48 8d 84 24 e0 02 00 	lea    0x2e0(%rsp),%rax
  40225f:	00 
  402260:	48 39 c7             	cmp    %rax,%rdi
  402263:	74 05                	je     40226a <main+0x3ba>
  402265:	e8 66 f7 ff ff       	callq  4019d0 <operator delete(void*)@plt>
    if(token(in)!="255" || w<5 || h<5) throw std::runtime_error("Expected >=5x5 uint8 PGM");
  40226a:	48 8b 74 24 10       	mov    0x10(%rsp),%rsi
  40226f:	48 8d bc 24 d0 02 00 	lea    0x2d0(%rsp),%rdi
  402276:	00 
  402277:	e8 14 15 00 00       	callq  403790 <token(std::istream&)>
    { return __lhs.compare(__rhs) == 0; }
  40227c:	48 8d bc 24 d0 02 00 	lea    0x2d0(%rsp),%rdi
  402283:	00 
  402284:	be 5d 43 40 00       	mov    $0x40435d,%esi
  402289:	e8 82 19 00 00       	callq  403c10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const>
  40228e:	83 fd 04             	cmp    $0x4,%ebp
  402291:	48 8b bc 24 d0 02 00 	mov    0x2d0(%rsp),%rdi
  402298:	00 
  402299:	0f 9e c1             	setle  %cl
  40229c:	41 83 fc 04          	cmp    $0x4,%r12d
  4022a0:	0f 9e c2             	setle  %dl
  4022a3:	08 d1                	or     %dl,%cl
  4022a5:	75 08                	jne    4022af <main+0x3ff>
  4022a7:	85 c0                	test   %eax,%eax
  4022a9:	0f 84 12 01 00 00    	je     4023c1 <main+0x511>
	if (!_M_is_local())
  4022af:	48 8d 84 24 e0 02 00 	lea    0x2e0(%rsp),%rax
  4022b6:	00 
  4022b7:	48 39 c7             	cmp    %rax,%rdi
  4022ba:	74 05                	je     4022c1 <main+0x411>
  4022bc:	e8 0f f7 ff ff       	callq  4019d0 <operator delete(void*)@plt>
  4022c1:	bf 10 00 00 00       	mov    $0x10,%edi
  4022c6:	e8 85 f6 ff ff       	callq  401950 <__cxa_allocate_exception@plt>
  4022cb:	be 61 43 40 00       	mov    $0x404361,%esi
  4022d0:	48 89 c7             	mov    %rax,%rdi
  4022d3:	49 89 c4             	mov    %rax,%r12
  4022d6:	e8 35 f6 ff ff       	callq  401910 <std::runtime_error::runtime_error(char const*)@plt>
  4022db:	e9 b2 fa ff ff       	jmpq   401d92 <main.cold.119+0x16d>
    { return __lhs.compare(__rhs) == 0; }
  4022e0:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  4022e5:	be 13 43 40 00       	mov    $0x404313,%esi
  4022ea:	e8 21 19 00 00       	callq  403c10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const>
        else if(k=="--warmup") warmup=std::stoi(v);
  4022ef:	85 c0                	test   %eax,%eax
  4022f1:	75 26                	jne    402319 <main+0x469>
  { return __gnu_cxx::__stoa<long, int>(&std::strtol, "stoi", __str.c_str(),
  4022f3:	48 8b 94 24 d0 02 00 	mov    0x2d0(%rsp),%rdx
  4022fa:	00 
  4022fb:	41 b8 0a 00 00 00    	mov    $0xa,%r8d
  402301:	31 c9                	xor    %ecx,%ecx
  402303:	be 0e 43 40 00       	mov    $0x40430e,%esi
  402308:	bf c0 1a 40 00       	mov    $0x401ac0,%edi
  40230d:	e8 7e 15 00 00       	callq  403890 <int __gnu_cxx::__stoa<long, int, char, int>(long (*)(char const*, char**, int), char const*, char const*, unsigned long*, int)>
  402312:	89 c3                	mov    %eax,%ebx
  402314:	e9 86 fc ff ff       	jmpq   401f9f <main+0xef>
    { return __lhs.compare(__rhs) == 0; }
  402319:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  40231e:	be 1c 43 40 00       	mov    $0x40431c,%esi
  402323:	e8 e8 18 00 00       	callq  403c10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const>
        else if(k=="--low") low=std::stof(v); else if(k=="--high") high=std::stof(v);
  402328:	85 c0                	test   %eax,%eax
  40232a:	75 24                	jne    402350 <main+0x4a0>
			     __idx, __base); }

  // NB: strtof vs strtod.
  inline float
  stof(const string& __str, size_t* __idx = 0)
  { return __gnu_cxx::__stoa(&std::strtof, "stof", __str.c_str(), __idx); }
  40232c:	48 8b 94 24 d0 02 00 	mov    0x2d0(%rsp),%rdx
  402333:	00 
  402334:	31 c9                	xor    %ecx,%ecx
  402336:	be 22 43 40 00       	mov    $0x404322,%esi
  40233b:	bf 90 1a 40 00       	mov    $0x401a90,%edi
  402340:	e8 fb 15 00 00       	callq  403940 <float __gnu_cxx::__stoa<float, float, char>(float (*)(char const*, char**), char const*, char const*, unsigned long*)>
  402345:	f3 0f 11 44 24 3c    	movss  %xmm0,0x3c(%rsp)
  40234b:	e9 4f fc ff ff       	jmpq   401f9f <main+0xef>
    { return __lhs.compare(__rhs) == 0; }
  402350:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  402355:	be 27 43 40 00       	mov    $0x404327,%esi
  40235a:	e8 b1 18 00 00       	callq  403c10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const>
  40235f:	85 c0                	test   %eax,%eax
  402361:	74 3a                	je     40239d <main+0x4ed>
  402363:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  402368:	be 2e 43 40 00       	mov    $0x40432e,%esi
  40236d:	e8 9e 18 00 00       	callq  403c10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const>
        else if(k=="--sigma") sigma=std::stof(v); else throw std::runtime_error("Unknown option "+k);
  402372:	85 c0                	test   %eax,%eax
  402374:	0f 85 58 10 00 00    	jne    4033d2 <main+0x1522>
  { return __gnu_cxx::__stoa(&std::strtof, "stof", __str.c_str(), __idx); }
  40237a:	48 8b 94 24 d0 02 00 	mov    0x2d0(%rsp),%rdx
  402381:	00 
  402382:	31 c9                	xor    %ecx,%ecx
  402384:	be 22 43 40 00       	mov    $0x404322,%esi
  402389:	bf 90 1a 40 00       	mov    $0x401a90,%edi
  40238e:	e8 ad 15 00 00       	callq  403940 <float __gnu_cxx::__stoa<float, float, char>(float (*)(char const*, char**), char const*, char const*, unsigned long*)>
  402393:	f3 0f 11 04 24       	movss  %xmm0,(%rsp)
  402398:	e9 02 fc ff ff       	jmpq   401f9f <main+0xef>
  40239d:	48 8b 94 24 d0 02 00 	mov    0x2d0(%rsp),%rdx
  4023a4:	00 
  4023a5:	31 c9                	xor    %ecx,%ecx
  4023a7:	be 22 43 40 00       	mov    $0x404322,%esi
  4023ac:	bf 90 1a 40 00       	mov    $0x401a90,%edi
  4023b1:	e8 8a 15 00 00       	callq  403940 <float __gnu_cxx::__stoa<float, float, char>(float (*)(char const*, char**), char const*, char const*, unsigned long*)>
  4023b6:	f3 0f 11 44 24 44    	movss  %xmm0,0x44(%rsp)
  4023bc:	e9 de fb ff ff       	jmpq   401f9f <main+0xef>
	if (!_M_is_local())
  4023c1:	48 8d 84 24 e0 02 00 	lea    0x2e0(%rsp),%rax
  4023c8:	00 
  4023c9:	48 39 c7             	cmp    %rax,%rdi
  4023cc:	0f 85 d7 0f 00 00    	jne    4033a9 <main+0x14f9>
    char separator; in.get(separator);
  4023d2:	48 8b 7c 24 10       	mov    0x10(%rsp),%rdi
  4023d7:	48 8d b4 24 bf 00 00 	lea    0xbf(%rsp),%rsi
  4023de:	00 
  4023df:	e8 cc f6 ff ff       	callq  401ab0 <std::istream::get(char&)@plt>
    if(separator=='\r' && in.peek()=='\n') in.get();
  4023e4:	80 bc 24 bf 00 00 00 	cmpb   $0xd,0xbf(%rsp)
  4023eb:	0d 
  4023ec:	0f 84 6c 04 00 00    	je     40285e <main+0x9ae>
    size_t n=size_t(w)*h;
  4023f2:	49 63 c4             	movslq %r12d,%rax
  4023f5:	4c 63 fd             	movslq %ebp,%r15
    std::vector<uint8_t> image(n), edges(n), labels(n);
  4023f8:	48 8d 94 24 d0 02 00 	lea    0x2d0(%rsp),%rdx
  4023ff:	00 
    size_t n=size_t(w)*h;
  402400:	49 89 c6             	mov    %rax,%r14
    std::vector<uint8_t> image(n), edges(n), labels(n);
  402403:	48 8d bc 24 d0 00 00 	lea    0xd0(%rsp),%rdi
  40240a:	00 
    size_t n=size_t(w)*h;
  40240b:	4d 0f af f7          	imul   %r15,%r14
    std::vector<uint8_t> image(n), edges(n), labels(n);
  40240f:	4c 89 f6             	mov    %r14,%rsi
    size_t n=size_t(w)*h;
  402412:	4c 89 74 24 20       	mov    %r14,0x20(%rsp)
    std::vector<uint8_t> image(n), edges(n), labels(n);
  402417:	e8 b4 15 00 00       	callq  4039d0 <std::vector<unsigned char, std::allocator<unsigned char> >::vector(unsigned long, std::allocator<unsigned char> const&)>
  40241c:	48 8d 94 24 d0 02 00 	lea    0x2d0(%rsp),%rdx
  402423:	00 
  402424:	4c 89 f6             	mov    %r14,%rsi
  402427:	48 8d bc 24 f0 00 00 	lea    0xf0(%rsp),%rdi
  40242e:	00 
  40242f:	e8 9c 15 00 00       	callq  4039d0 <std::vector<unsigned char, std::allocator<unsigned char> >::vector(unsigned long, std::allocator<unsigned char> const&)>
  402434:	48 8d 94 24 d0 02 00 	lea    0x2d0(%rsp),%rdx
  40243b:	00 
  40243c:	4c 89 f6             	mov    %r14,%rsi
  40243f:	48 8d bc 24 10 01 00 	lea    0x110(%rsp),%rdi
  402446:	00 
  402447:	e8 84 15 00 00       	callq  4039d0 <std::vector<unsigned char, std::allocator<unsigned char> >::vector(unsigned long, std::allocator<unsigned char> const&)>
    in.read(reinterpret_cast<char*>(image.data()),std::streamsize(n));
  40244c:	48 8b b4 24 d0 00 00 	mov    0xd0(%rsp),%rsi
  402453:	00 
  402454:	48 8b 7c 24 10       	mov    0x10(%rsp),%rdi
  402459:	4c 89 f2             	mov    %r14,%rdx
  40245c:	e8 df f5 ff ff       	callq  401a40 <std::istream::read(char*, long)@plt>
    if(size_t(in.gcount())!=n) throw std::runtime_error("Truncated image");
  402461:	4c 39 b4 24 d8 04 00 	cmp    %r14,0x4d8(%rsp)
  402468:	00 
  402469:	0f 85 8d 10 00 00    	jne    4034fc <main+0x164c>
    std::vector<float> blur(n), mag(n), angle(n), suppressed(n);
  40246f:	4c 8b 74 24 20       	mov    0x20(%rsp),%r14
  402474:	48 8d 94 24 d0 02 00 	lea    0x2d0(%rsp),%rdx
  40247b:	00 
  40247c:	48 8d bc 24 30 01 00 	lea    0x130(%rsp),%rdi
  402483:	00 
  402484:	4c 89 f6             	mov    %r14,%rsi
  402487:	e8 a4 15 00 00       	callq  403a30 <std::vector<float, std::allocator<float> >::vector(unsigned long, std::allocator<float> const&)>
  40248c:	48 8d 94 24 d0 02 00 	lea    0x2d0(%rsp),%rdx
  402493:	00 
  402494:	4c 89 f6             	mov    %r14,%rsi
  402497:	48 8d bc 24 50 01 00 	lea    0x150(%rsp),%rdi
  40249e:	00 
  40249f:	e8 8c 15 00 00       	callq  403a30 <std::vector<float, std::allocator<float> >::vector(unsigned long, std::allocator<float> const&)>
  4024a4:	48 8d 94 24 d0 02 00 	lea    0x2d0(%rsp),%rdx
  4024ab:	00 
  4024ac:	4c 89 f6             	mov    %r14,%rsi
  4024af:	48 8d bc 24 70 01 00 	lea    0x170(%rsp),%rdi
  4024b6:	00 
  4024b7:	e8 74 15 00 00       	callq  403a30 <std::vector<float, std::allocator<float> >::vector(unsigned long, std::allocator<float> const&)>
  4024bc:	48 8d 94 24 d0 02 00 	lea    0x2d0(%rsp),%rdx
  4024c3:	00 
  4024c4:	4c 89 f6             	mov    %r14,%rsi
  4024c7:	48 8d bc 24 90 01 00 	lea    0x190(%rsp),%rdi
  4024ce:	00 
  4024cf:	e8 5c 15 00 00       	callq  403a30 <std::vector<float, std::allocator<float> >::vector(unsigned long, std::allocator<float> const&)>
  template<typename _Tp, typename _Alloc>
    void
    vector<_Tp, _Alloc>::
    reserve(size_type __n)
    {
      if (__n > this->max_size())
  4024d4:	48 b8 ff ff ff ff ff 	movabs $0x1fffffffffffffff,%rax
  4024db:	ff ff 1f 
	: _Tp_alloc_type(), _M_start(), _M_finish(), _M_end_of_storage()
  4024de:	48 c7 84 24 b0 01 00 	movq   $0x0,0x1b0(%rsp)
  4024e5:	00 00 00 00 00 
  4024ea:	48 c7 84 24 b8 01 00 	movq   $0x0,0x1b8(%rsp)
  4024f1:	00 00 00 00 00 
  4024f6:	48 c7 84 24 c0 01 00 	movq   $0x0,0x1c0(%rsp)
  4024fd:	00 00 00 00 00 
  402502:	49 39 c6             	cmp    %rax,%r14
  402505:	0f 87 3f 0f 00 00    	ja     40344a <main+0x159a>
	return static_cast<_Tp*>(::operator new(__n * sizeof(_Tp)));
  40250b:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
  402510:	4c 8d 2c c5 00 00 00 	lea    0x0(,%rax,8),%r13
  402517:	00 
  402518:	4c 89 ef             	mov    %r13,%rdi
  40251b:	e8 d0 f4 ff ff       	callq  4019f0 <operator new(unsigned long)@plt>
	  const size_type __old_size = size();
	  pointer __tmp = _M_allocate_and_copy(__n,
	    _GLIBCXX_MAKE_MOVE_IF_NOEXCEPT_ITERATOR(this->_M_impl._M_start),
	    _GLIBCXX_MAKE_MOVE_IF_NOEXCEPT_ITERATOR(this->_M_impl._M_finish));
	  _GLIBCXX_ASAN_ANNOTATE_REINIT;
	  std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  402520:	48 8b bc 24 b0 01 00 	mov    0x1b0(%rsp),%rdi
  402527:	00 
  402528:	49 89 c6             	mov    %rax,%r14
	if (__p)
  40252b:	48 85 ff             	test   %rdi,%rdi
  40252e:	74 05                	je     402535 <main+0x685>
	::operator delete(__p);
  402530:	e8 9b f4 ff ff       	callq  4019d0 <operator delete(void*)@plt>
        weights[y+2][x+2]=std::exp(-(x*x+y*y)/(2*sigma*sigma)); sum+=weights[y+2][x+2];
  402535:	f3 0f 10 34 24       	movss  (%rsp),%xmm6
	  _M_deallocate(this->_M_impl._M_start,
			this->_M_impl._M_end_of_storage
			- this->_M_impl._M_start);
	  this->_M_impl._M_start = __tmp;
	  this->_M_impl._M_finish = __tmp + __old_size;
	  this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
  40253a:	4d 01 f5             	add    %r14,%r13
  40253d:	89 6c 24 28          	mov    %ebp,0x28(%rsp)
  402541:	66 0f ef c9          	pxor   %xmm1,%xmm1
  402545:	48 8d 84 24 60 02 00 	lea    0x260(%rsp),%rax
  40254c:	00 
	  this->_M_impl._M_start = __tmp;
  40254d:	4c 89 b4 24 b0 01 00 	mov    %r14,0x1b0(%rsp)
  402554:	00 
  402555:	0f 28 c6             	movaps %xmm6,%xmm0
	  this->_M_impl._M_finish = __tmp + __old_size;
  402558:	4c 89 b4 24 b8 01 00 	mov    %r14,0x1b8(%rsp)
  40255f:	00 
  402560:	48 89 c2             	mov    %rax,%rdx
  402563:	f3 0f 58 c6          	addss  %xmm6,%xmm0
  402567:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
  40256c:	44 89 e0             	mov    %r12d,%eax
  40256f:	48 89 d5             	mov    %rdx,%rbp
	  this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
  402572:	4c 89 ac 24 c0 01 00 	mov    %r13,0x1c0(%rsp)
  402579:	00 
  40257a:	41 89 dc             	mov    %ebx,%r12d
  40257d:	89 c3                	mov    %eax,%ebx
  40257f:	41 bd fe ff ff ff    	mov    $0xfffffffe,%r13d
  402585:	f3 0f 59 c6          	mulss  %xmm6,%xmm0
  402589:	f3 0f 11 44 24 18    	movss  %xmm0,0x18(%rsp)
  40258f:	44 89 e8             	mov    %r13d,%eax
  402592:	49 c7 c6 fe ff ff ff 	mov    $0xfffffffffffffffe,%r14
  402599:	41 0f af c5          	imul   %r13d,%eax
  40259d:	89 04 24             	mov    %eax,(%rsp)
  4025a0:	44 89 f0             	mov    %r14d,%eax
  4025a3:	66 0f ef c0          	pxor   %xmm0,%xmm0
  4025a7:	f3 0f 11 4c 24 30    	movss  %xmm1,0x30(%rsp)
  4025ad:	41 0f af c6          	imul   %r14d,%eax
  4025b1:	03 04 24             	add    (%rsp),%eax
  4025b4:	f7 d8                	neg    %eax
  4025b6:	f3 0f 2a c0          	cvtsi2ss %eax,%xmm0
  4025ba:	f3 0f 5e 44 24 18    	divss  0x18(%rsp),%xmm0
  { return __builtin_expf(__x); }
  4025c0:	e8 9b f5 ff ff       	callq  401b60 <expf@plt>
  4025c5:	f3 0f 10 4c 24 30    	movss  0x30(%rsp),%xmm1
  4025cb:	f3 42 0f 11 44 b5 08 	movss  %xmm0,0x8(%rbp,%r14,4)
  4025d2:	49 83 c6 01          	add    $0x1,%r14
  4025d6:	f3 0f 58 c8          	addss  %xmm0,%xmm1
    for(int y=-2;y<=2;++y) for(int x=-2;x<=2;++x) {
  4025da:	49 83 fe 03          	cmp    $0x3,%r14
  4025de:	75 c0                	jne    4025a0 <main+0x6f0>
  4025e0:	41 83 c5 01          	add    $0x1,%r13d
  4025e4:	48 83 c5 14          	add    $0x14,%rbp
  4025e8:	41 83 fd 03          	cmp    $0x3,%r13d
  4025ec:	75 a1                	jne    40258f <main+0x6df>
    for(auto& row:weights) for(float& x:row) x/=sum;
  4025ee:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  4025f3:	89 d8                	mov    %ebx,%eax
  4025f5:	8b 6c 24 28          	mov    0x28(%rsp),%ebp
  4025f9:	44 89 e3             	mov    %r12d,%ebx
  4025fc:	41 89 c4             	mov    %eax,%r12d
  4025ff:	48 8d 4f 64          	lea    0x64(%rdi),%rcx
  402603:	48 89 f8             	mov    %rdi,%rax
  402606:	48 83 c0 14          	add    $0x14,%rax
  40260a:	48 8d 50 ec          	lea    -0x14(%rax),%rdx
  40260e:	f3 0f 10 02          	movss  (%rdx),%xmm0
  402612:	48 83 c2 04          	add    $0x4,%rdx
  402616:	f3 0f 5e c1          	divss  %xmm1,%xmm0
  40261a:	f3 0f 11 42 fc       	movss  %xmm0,-0x4(%rdx)
  40261f:	48 39 d0             	cmp    %rdx,%rax
  402622:	75 ea                	jne    40260e <main+0x75e>
  402624:	48 39 c8             	cmp    %rcx,%rax
  402627:	75 dd                	jne    402606 <main+0x756>
            p = p < 0 ? -p : 2 * length - 2 - p;
  402629:	41 8d 44 24 ff       	lea    -0x1(%r12),%eax
    for(int it=-warmup;it<iterations;++it) {
  40262e:	f7 db                	neg    %ebx
	: _Tp_alloc_type(), _M_start(), _M_finish(), _M_end_of_storage()
  402630:	48 c7 84 24 d0 01 00 	movq   $0x0,0x1d0(%rsp)
  402637:	00 00 00 00 00 
            p = p < 0 ? -p : 2 * length - 2 - p;
  40263c:	89 84 24 88 00 00 00 	mov    %eax,0x88(%rsp)
  402643:	44 8d 34 00          	lea    (%rax,%rax,1),%r14d
  402647:	8d 45 ff             	lea    -0x1(%rbp),%eax
    for(int it=-warmup;it<iterations;++it) {
  40264a:	89 5c 24 70          	mov    %ebx,0x70(%rsp)
            p = p < 0 ? -p : 2 * length - 2 - p;
  40264e:	8d 1c 00             	lea    (%rax,%rax,1),%ebx
  402651:	89 84 24 8c 00 00 00 	mov    %eax,0x8c(%rsp)
  402658:	4a 8d 04 bd 00 00 00 	lea    0x0(,%r15,4),%rax
  40265f:	00 
  402660:	48 89 84 24 80 00 00 	mov    %rax,0x80(%rsp)
  402667:	00 
  402668:	48 8b 44 24 20       	mov    0x20(%rsp),%rax
  40266d:	48 c7 84 24 d8 01 00 	movq   $0x0,0x1d8(%rsp)
  402674:	00 00 00 00 00 
  402679:	48 c7 84 24 e0 01 00 	movq   $0x0,0x1e0(%rsp)
  402680:	00 00 00 00 00 
    for(int it=-warmup;it<iterations;++it) {
  402685:	4c 29 f8             	sub    %r15,%rax
  402688:	48 89 44 24 58       	mov    %rax,0x58(%rsp)
  40268d:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
  402692:	48 83 c0 64          	add    $0x64,%rax
  402696:	48 89 04 24          	mov    %rax,(%rsp)
  40269a:	8d 45 fd             	lea    -0x3(%rbp),%eax
  40269d:	89 84 24 98 00 00 00 	mov    %eax,0x98(%rsp)
  4026a4:	49 8d 47 03          	lea    0x3(%r15),%rax
  4026a8:	48 89 84 24 90 00 00 	mov    %rax,0x90(%rsp)
  4026af:	00 
        std::array<Clock::time_point,6> t; t[0]=Clock::now();
  4026b0:	48 c7 84 24 40 02 00 	movq   $0x0,0x240(%rsp)
  4026b7:	00 00 00 00 00 
  4026bc:	48 c7 84 24 48 02 00 	movq   $0x0,0x248(%rsp)
  4026c3:	00 00 00 00 00 
  4026c8:	48 c7 84 24 50 02 00 	movq   $0x0,0x250(%rsp)
  4026cf:	00 00 00 00 00 
  4026d4:	48 c7 84 24 58 02 00 	movq   $0x0,0x258(%rsp)
  4026db:	00 00 00 00 00 
  4026e0:	e8 9b f3 ff ff       	callq  401a80 <std::chrono::_V2::steady_clock::now()@plt>
            blur[size_t(y)*w+x]=std::clamp(std::floor(value+0.5f),0.0f,255.0f);
  4026e5:	c7 44 24 18 fe ff ff 	movl   $0xfffffffe,0x18(%rsp)
  4026ec:	ff 
  4026ed:	0f 28 64 24 60       	movaps 0x60(%rsp),%xmm4
        std::array<Clock::time_point,6> t; t[0]=Clock::now();
  4026f2:	48 89 84 24 30 02 00 	mov    %rax,0x230(%rsp)
  4026f9:	00 
        for(int y=0;y<h;++y) for(int x=0;x<w;++x) {
  4026fa:	48 8b 84 24 30 01 00 	mov    0x130(%rsp),%rax
  402701:	00 
                value+=weights[j+2][k+2]*image[size_t(reflect(y+j,h))*w+reflect(x+k,w)];
  402702:	4c 8b 9c 24 d0 00 00 	mov    0xd0(%rsp),%r11
  402709:	00 
  40270a:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
            blur[size_t(y)*w+x]=std::clamp(std::floor(value+0.5f),0.0f,255.0f);
  40270f:	45 31 ed             	xor    %r13d,%r13d
  402712:	4c 8b 44 24 08       	mov    0x8(%rsp),%r8
  402717:	44 8b 4c 24 18       	mov    0x18(%rsp),%r9d
            float value=0;
  40271c:	66 0f ef c9          	pxor   %xmm1,%xmm1
  402720:	45 8d 55 fe          	lea    -0x2(%r13),%r10d
  402724:	31 ff                	xor    %edi,%edi
                value+=weights[j+2][k+2]*image[size_t(reflect(y+j,h))*w+reflect(x+k,w)];
  402726:	f3 41 0f 10 14 b8    	movss  (%r8,%rdi,4),%xmm2
  40272c:	44 89 c8             	mov    %r9d,%eax
  40272f:	eb 17                	jmp    402748 <main+0x898>
  402731:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
            p = p < 0 ? -p : 2 * length - 2 - p;
  402738:	89 c2                	mov    %eax,%edx
  40273a:	44 89 f1             	mov    %r14d,%ecx
  40273d:	f7 da                	neg    %edx
  40273f:	29 c1                	sub    %eax,%ecx
  402741:	85 c0                	test   %eax,%eax
  402743:	89 d0                	mov    %edx,%eax
  402745:	0f 49 c1             	cmovns %ecx,%eax
        while (p < 0 || p >= length)
  402748:	44 39 e0             	cmp    %r12d,%eax
  40274b:	7d eb                	jge    402738 <main+0x888>
  40274d:	85 c0                	test   %eax,%eax
  40274f:	78 e7                	js     402738 <main+0x888>
                value+=weights[j+2][k+2]*image[size_t(reflect(y+j,h))*w+reflect(x+k,w)];
  402751:	48 63 d0             	movslq %eax,%rdx
  402754:	41 8d 04 3a          	lea    (%r10,%rdi,1),%eax
  402758:	49 0f af d7          	imul   %r15,%rdx
  40275c:	eb 11                	jmp    40276f <main+0x8bf>
  40275e:	66 90                	xchg   %ax,%ax
            p = p < 0 ? -p : 2 * length - 2 - p;
  402760:	89 c1                	mov    %eax,%ecx
  402762:	89 de                	mov    %ebx,%esi
  402764:	f7 d9                	neg    %ecx
  402766:	29 c6                	sub    %eax,%esi
  402768:	85 c0                	test   %eax,%eax
  40276a:	89 c8                	mov    %ecx,%eax
  40276c:	0f 49 c6             	cmovns %esi,%eax
        while (p < 0 || p >= length)
  40276f:	39 e8                	cmp    %ebp,%eax
  402771:	7d ed                	jge    402760 <main+0x8b0>
  402773:	85 c0                	test   %eax,%eax
  402775:	78 e9                	js     402760 <main+0x8b0>
                value+=weights[j+2][k+2]*image[size_t(reflect(y+j,h))*w+reflect(x+k,w)];
  402777:	48 98                	cltq   
  402779:	4c 01 da             	add    %r11,%rdx
  40277c:	66 0f ef c0          	pxor   %xmm0,%xmm0
  402780:	48 83 c7 01          	add    $0x1,%rdi
  402784:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  402788:	f3 0f 2a c0          	cvtsi2ss %eax,%xmm0
  40278c:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  402790:	f3 0f 58 c8          	addss  %xmm0,%xmm1
            for(int j=-2;j<=2;++j) for(int k=-2;k<=2;++k)
  402794:	48 83 ff 05          	cmp    $0x5,%rdi
  402798:	75 8c                	jne    402726 <main+0x876>
  40279a:	41 83 c1 01          	add    $0x1,%r9d
  40279e:	49 83 c0 14          	add    $0x14,%r8
  4027a2:	4c 39 04 24          	cmp    %r8,(%rsp)
  4027a6:	0f 85 78 ff ff ff    	jne    402724 <main+0x874>
            blur[size_t(y)*w+x]=std::clamp(std::floor(value+0.5f),0.0f,255.0f);
  4027ac:	f3 0f 58 0d 40 1d 00 	addss  0x1d40(%rip),%xmm1        # 4044f4 <__dso_handle+0x24c>
  4027b3:	00 
  { return __builtin_floorf(__x); }
  4027b4:	f3 0f 10 3d 3c 1d 00 	movss  0x1d3c(%rip),%xmm7        # 4044f8 <__dso_handle+0x250>
  4027bb:	00 
  4027bc:	0f 28 d4             	movaps %xmm4,%xmm2
  4027bf:	0f 28 c1             	movaps %xmm1,%xmm0
  4027c2:	0f 54 c4             	andps  %xmm4,%xmm0
  4027c5:	0f 2e f8             	ucomiss %xmm0,%xmm7
  4027c8:	76 2c                	jbe    4027f6 <main+0x946>
  4027ca:	f3 0f 2c c1          	cvttss2si %xmm1,%eax
  4027ce:	66 0f ef c0          	pxor   %xmm0,%xmm0
  4027d2:	f3 0f 10 2d 22 1d 00 	movss  0x1d22(%rip),%xmm5        # 4044fc <__dso_handle+0x254>
  4027d9:	00 
  4027da:	0f 55 d1             	andnps %xmm1,%xmm2
  4027dd:	f3 0f 2a c0          	cvtsi2ss %eax,%xmm0
  4027e1:	0f 28 d8             	movaps %xmm0,%xmm3
  4027e4:	f3 0f c2 d9 06       	cmpnless %xmm1,%xmm3
  4027e9:	0f 28 ca             	movaps %xmm2,%xmm1
  4027ec:	0f 54 dd             	andps  %xmm5,%xmm3
  4027ef:	f3 0f 5c c3          	subss  %xmm3,%xmm0
  4027f3:	0f 56 c8             	orps   %xmm0,%xmm1
  template<typename _Tp>
    constexpr const _Tp&
    clamp(const _Tp& __val, const _Tp& __lo, const _Tp& __hi)
    {
      __glibcxx_assert(!(__hi < __lo));
      return (__val < __lo) ? __lo : (__hi < __val) ? __hi : __val;
  4027f6:	66 0f ef ff          	pxor   %xmm7,%xmm7
  4027fa:	0f 2f f9             	comiss %xmm1,%xmm7
  4027fd:	0f 87 7d 00 00 00    	ja     402880 <main+0x9d0>
  402803:	f3 0f 10 05 e1 1c 00 	movss  0x1ce1(%rip),%xmm0        # 4044ec <__dso_handle+0x244>
  40280a:	00 
  40280b:	f3 0f 10 35 d9 1c 00 	movss  0x1cd9(%rip),%xmm6        # 4044ec <__dso_handle+0x244>
  402812:	00 
  402813:	f3 0f c2 c1 05       	cmpnltss %xmm1,%xmm0
  402818:	0f 54 c8             	andps  %xmm0,%xmm1
  40281b:	0f 55 c6             	andnps %xmm6,%xmm0
  40281e:	0f 56 c8             	orps   %xmm0,%xmm1
  402821:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
  402826:	f3 42 0f 11 0c a8    	movss  %xmm1,(%rax,%r13,4)
        for(int y=0;y<h;++y) for(int x=0;x<w;++x) {
  40282c:	49 83 c5 01          	add    $0x1,%r13
  402830:	44 39 ed             	cmp    %r13d,%ebp
  402833:	0f 8f d9 fe ff ff    	jg     402712 <main+0x862>
  402839:	8b 44 24 18          	mov    0x18(%rsp),%eax
  40283d:	48 8b bc 24 80 00 00 	mov    0x80(%rsp),%rdi
  402844:	00 
  402845:	48 01 7c 24 28       	add    %rdi,0x28(%rsp)
  40284a:	8d 50 01             	lea    0x1(%rax),%edx
  40284d:	83 c0 03             	add    $0x3,%eax
  402850:	41 39 c4             	cmp    %eax,%r12d
  402853:	7e 31                	jle    402886 <main+0x9d6>
  402855:	89 54 24 18          	mov    %edx,0x18(%rsp)
  402859:	e9 b1 fe ff ff       	jmpq   40270f <main+0x85f>
    if(separator=='\r' && in.peek()=='\n') in.get();
  40285e:	48 8b 7c 24 10       	mov    0x10(%rsp),%rdi
  402863:	e8 98 f0 ff ff       	callq  401900 <std::istream::peek()@plt>
  402868:	83 f8 0a             	cmp    $0xa,%eax
  40286b:	0f 85 81 fb ff ff    	jne    4023f2 <main+0x542>
  402871:	48 8b 7c 24 10       	mov    0x10(%rsp),%rdi
  402876:	e8 b5 f1 ff ff       	callq  401a30 <std::istream::get()@plt>
  40287b:	e9 72 fb ff ff       	jmpq   4023f2 <main+0x542>
  402880:	66 0f ef c9          	pxor   %xmm1,%xmm1
  402884:	eb 9b                	jmp    402821 <main+0x971>
        t[1]=Clock::now();
  402886:	e8 f5 f1 ff ff       	callq  401a80 <std::chrono::_V2::steady_clock::now()@plt>
        for (int y = 0; y < h; ++y) {
  40288b:	c7 44 24 74 00 00 00 	movl   $0x0,0x74(%rsp)
  402892:	00 
        t[1]=Clock::now();
  402893:	41 bd ff ff ff ff    	mov    $0xffffffff,%r13d
  402899:	48 89 84 24 38 02 00 	mov    %rax,0x238(%rsp)
  4028a0:	00 
        for (int y = 0; y < h; ++y) {
  4028a1:	4c 89 f8             	mov    %r15,%rax
  4028a4:	48 f7 d8             	neg    %rax
        t[1]=Clock::now();
  4028a7:	c7 44 24 28 00 00 00 	movl   $0x0,0x28(%rsp)
  4028ae:	00 
  4028af:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
                    return blur[size_t(sample_row) * w + sample_col];
  4028b4:	44 89 b4 24 9c 00 00 	mov    %r14d,0x9c(%rsp)
  4028bb:	00 
  4028bc:	89 9c 24 a0 00 00 00 	mov    %ebx,0xa0(%rsp)
  4028c3:	89 6c 24 30          	mov    %ebp,0x30(%rsp)
  4028c7:	4c 89 7c 24 78       	mov    %r15,0x78(%rsp)
  4028cc:	45 89 ef             	mov    %r13d,%r15d
  4028cf:	48 63 7c 24 74       	movslq 0x74(%rsp),%rdi
  4028d4:	8b 9c 24 88 00 00 00 	mov    0x88(%rsp),%ebx
  4028db:	be 00 00 00 00       	mov    $0x0,%esi
  4028e0:	45 89 fd             	mov    %r15d,%r13d
  4028e3:	41 be 00 00 00 00    	mov    $0x0,%r14d
  4028e9:	4c 63 bc 24 8c 00 00 	movslq 0x8c(%rsp),%r15
  4028f0:	00 
  4028f1:	39 df                	cmp    %ebx,%edi
  4028f3:	48 63 c3             	movslq %ebx,%rax
  4028f6:	48 0f 4e c7          	cmovle %rdi,%rax
  4028fa:	85 ff                	test   %edi,%edi
  4028fc:	48 0f 48 c6          	cmovs  %rsi,%rax
  402900:	48 8b 74 24 78       	mov    0x78(%rsp),%rsi
                    int sample_row = std::clamp(y + j, 0, h - 1);
  402905:	83 c7 01             	add    $0x1,%edi
  402908:	89 7c 24 74          	mov    %edi,0x74(%rsp)
                    return blur[size_t(sample_row) * w + sample_col];
  40290c:	48 0f af c6          	imul   %rsi,%rax
  402910:	39 df                	cmp    %ebx,%edi
  402912:	48 89 44 24 50       	mov    %rax,0x50(%rsp)
  402917:	89 d8                	mov    %ebx,%eax
  402919:	0f 4e c7             	cmovle %edi,%eax
  40291c:	48 63 e8             	movslq %eax,%rbp
  40291f:	48 0f af ee          	imul   %rsi,%rbp
  402923:	85 ff                	test   %edi,%edi
  402925:	48 8b 7c 24 18       	mov    0x18(%rsp),%rdi
  40292a:	44 0f 49 f0          	cmovns %eax,%r14d
  40292e:	48 8b 84 24 80 00 00 	mov    0x80(%rsp),%rax
  402935:	00 
            for (int x = 0; x < w; ++x) {
  402936:	31 d2                	xor    %edx,%edx
                    return blur[size_t(sample_row) * w + sample_col];
  402938:	4d 63 f6             	movslq %r14d,%r14
  40293b:	4c 0f af f6          	imul   %rsi,%r14
  40293f:	4c 89 74 24 48       	mov    %r14,0x48(%rsp)
  402944:	4c 8d 34 b8          	lea    (%rax,%rdi,4),%r14
  402948:	e9 7a 01 00 00       	jmpq   402ac7 <main+0xc17>
  40294d:	8b 74 24 28          	mov    0x28(%rsp),%esi
  402951:	48 8b 7c 24 18       	mov    0x18(%rsp),%rdi
                    int sample_col = std::clamp(x + k, 0, w - 1);
  402956:	8d 5a 01             	lea    0x1(%rdx),%ebx
  402959:	45 89 fa             	mov    %r15d,%r10d
  40295c:	4c 8b 4c 24 58       	mov    0x58(%rsp),%r9
                    return blur[size_t(sample_row) * w + sample_col];
  402961:	48 8b 8c 24 30 01 00 	mov    0x130(%rsp),%rcx
  402968:	00 
  402969:	41 39 f4             	cmp    %esi,%r12d
  40296c:	48 89 f8             	mov    %rdi,%rax
  40296f:	49 0f 4c c1          	cmovl  %r9,%rax
                    int sample_col = std::clamp(x + k, 0, w - 1);
  402973:	44 39 fb             	cmp    %r15d,%ebx
  402976:	44 0f 4e d3          	cmovle %ebx,%r10d
  40297a:	4d 63 d2             	movslq %r10d,%r10
       */
      reference
      operator[](size_type __n) _GLIBCXX_NOEXCEPT
      {
	__glibcxx_requires_subscript(__n);
	return *(this->_M_impl._M_start + __n);
  40297d:	4c 01 d0             	add    %r10,%rax
  402980:	41 39 f4             	cmp    %esi,%r12d
  402983:	49 0f 4c f9          	cmovl  %r9,%rdi
                    return blur[size_t(sample_row) * w + sample_col];
  402987:	f3 0f 10 34 81       	movss  (%rcx,%rax,4),%xmm6
  40298c:	49 89 fb             	mov    %rdi,%r11
  40298f:	89 d8                	mov    %ebx,%eax
  402991:	bf 00 00 00 00       	mov    $0x0,%edi
                float gx = -b(-1, -1) + b(-1, 1)
  402996:	0f 28 ce             	movaps %xmm6,%xmm1
                    return blur[size_t(sample_row) * w + sample_col];
  402999:	83 e8 02             	sub    $0x2,%eax
  40299c:	0f 48 c7             	cmovs  %edi,%eax
  40299f:	48 8b 7c 24 50       	mov    0x50(%rsp),%rdi
  4029a4:	49 01 ea             	add    %rbp,%r10
  4029a7:	f3 42 0f 10 1c 91    	movss  (%rcx,%r10,4),%xmm3
  4029ad:	48 98                	cltq   
  4029af:	49 01 c3             	add    %rax,%r11
  4029b2:	f3 42 0f 10 04 99    	movss  (%rcx,%r11,4),%xmm0
  4029b8:	4c 8d 1c 28          	lea    (%rax,%rbp,1),%r11
  4029bc:	48 01 f8             	add    %rdi,%rax
  4029bf:	41 39 df             	cmp    %ebx,%r15d
                         - 2 * b(0, -1) + 2 * b(0, 1)
  4029c2:	f3 0f 10 24 81       	movss  (%rcx,%rax,4),%xmm4
  4029c7:	48 63 c3             	movslq %ebx,%rax
                    return blur[size_t(sample_row) * w + sample_col];
  4029ca:	f3 42 0f 10 2c 99    	movss  (%rcx,%r11,4),%xmm5
  4029d0:	49 0f 4e c7          	cmovle %r15,%rax
                float gx = -b(-1, -1) + b(-1, 1)
  4029d4:	f3 0f 5c c8          	subss  %xmm0,%xmm1
                float gy = -b(-1, -1) - 2 * b(-1, 0) - b(-1, 1)
  4029d8:	0f 28 d0             	movaps %xmm0,%xmm2
  4029db:	45 31 d2             	xor    %r10d,%r10d
                         - 2 * b(0, -1) + 2 * b(0, 1)
  4029de:	f3 0f 58 e4          	addss  %xmm4,%xmm4
                float gy = -b(-1, -1) - 2 * b(-1, 0) - b(-1, 1)
  4029e2:	0f 57 15 47 1b 00 00 	xorps  0x1b47(%rip),%xmm2        # 404530 <__dso_handle+0x288>
  4029e9:	48 01 f8             	add    %rdi,%rax
                         - 2 * b(0, -1) + 2 * b(0, 1)
  4029ec:	f3 0f 5c cc          	subss  %xmm4,%xmm1
  4029f0:	f3 0f 10 24 81       	movss  (%rcx,%rax,4),%xmm4
  4029f5:	f3 0f 58 e4          	addss  %xmm4,%xmm4
  4029f9:	f3 0f 58 cc          	addss  %xmm4,%xmm1
                         - b(1, -1) + b(1, 1);
  4029fd:	f3 0f 5c cd          	subss  %xmm5,%xmm1
  402a01:	f3 0f 58 cb          	addss  %xmm3,%xmm1
  402a05:	45 85 ed             	test   %r13d,%r13d
  402a08:	78 10                	js     402a1a <main+0xb6a>
  402a0a:	44 3b 64 24 28       	cmp    0x28(%rsp),%r12d
  402a0f:	4c 8b 54 24 18       	mov    0x18(%rsp),%r10
  402a14:	4c 0f 4c 54 24 58    	cmovl  0x58(%rsp),%r10
                    return blur[size_t(sample_row) * w + sample_col];
  402a1a:	44 39 fa             	cmp    %r15d,%edx
  402a1d:	66 0f ef ff          	pxor   %xmm7,%xmm7
  402a21:	48 63 c2             	movslq %edx,%rax
  402a24:	49 0f 4f c7          	cmovg  %r15,%rax
  402a28:	4a 8d 14 10          	lea    (%rax,%r10,1),%rdx
  402a2c:	48 03 44 24 48       	add    0x48(%rsp),%rax
                float gy = -b(-1, -1) - 2 * b(-1, 0) - b(-1, 1)
  402a31:	f3 0f 10 04 91       	movss  (%rcx,%rdx,4),%xmm0
  402a36:	f3 0f 58 c0          	addss  %xmm0,%xmm0
  402a3a:	f3 0f 5c d0          	subss  %xmm0,%xmm2
                         + b(1, -1) + 2 * b(1, 0) + b(1, 1);
  402a3e:	f3 0f 10 04 81       	movss  (%rcx,%rax,4),%xmm0
  402a43:	f3 0f 58 c0          	addss  %xmm0,%xmm0
                float gy = -b(-1, -1) - 2 * b(-1, 0) - b(-1, 1)
  402a47:	f3 0f 5c d6          	subss  %xmm6,%xmm2
                         + b(1, -1) + 2 * b(1, 0) + b(1, 1);
  402a4b:	f3 0f 58 d5          	addss  %xmm5,%xmm2
  402a4f:	f3 0f 58 d0          	addss  %xmm0,%xmm2
                mag[i] = std::sqrt(gx * gx + gy * gy);
  402a53:	0f 28 c1             	movaps %xmm1,%xmm0
  402a56:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
                         + b(1, -1) + 2 * b(1, 0) + b(1, 1);
  402a5a:	f3 0f 58 d3          	addss  %xmm3,%xmm2
                mag[i] = std::sqrt(gx * gx + gy * gy);
  402a5e:	0f 28 da             	movaps %xmm2,%xmm3
  402a61:	f3 0f 59 da          	mulss  %xmm2,%xmm3
  402a65:	f3 0f 58 c3          	addss  %xmm3,%xmm0
  { return __builtin_sqrtf(__x); }
  402a69:	0f 2e f8             	ucomiss %xmm0,%xmm7
  402a6c:	f3 0f 51 d8          	sqrtss %xmm0,%xmm3
  402a70:	0f 87 b7 08 00 00    	ja     40332d <main+0x147d>
  402a76:	48 8b 84 24 50 01 00 	mov    0x150(%rsp),%rax
  402a7d:	00 
  { return __builtin_atan2f(__y, __x); }
  402a7e:	0f 28 c2             	movaps %xmm2,%xmm0
  402a81:	f3 42 0f 11 1c 30    	movss  %xmm3,(%rax,%r14,1)
  402a87:	e8 14 f0 ff ff       	callq  401aa0 <atan2f@plt>
                angle[i] = degrees < 0 ? degrees + 180 : degrees;
  402a8c:	66 0f ef ed          	pxor   %xmm5,%xmm5
                float degrees = std::atan2(gy, gx) * 180.0f / 3.14159265358979323846f;
  402a90:	f3 0f 59 05 68 1a 00 	mulss  0x1a68(%rip),%xmm0        # 404500 <__dso_handle+0x258>
  402a97:	00 
  402a98:	f3 0f 5e 05 64 1a 00 	divss  0x1a64(%rip),%xmm0        # 404504 <__dso_handle+0x25c>
  402a9f:	00 
                angle[i] = degrees < 0 ? degrees + 180 : degrees;
  402aa0:	0f 2f e8             	comiss %xmm0,%xmm5
  402aa3:	76 08                	jbe    402aad <main+0xbfd>
  402aa5:	f3 0f 58 05 53 1a 00 	addss  0x1a53(%rip),%xmm0        # 404500 <__dso_handle+0x258>
  402aac:	00 
  402aad:	48 8b 84 24 70 01 00 	mov    0x170(%rsp),%rax
  402ab4:	00 
  402ab5:	f3 42 0f 11 04 30    	movss  %xmm0,(%rax,%r14,1)
            for (int x = 0; x < w; ++x) {
  402abb:	49 83 c6 04          	add    $0x4,%r14
  402abf:	39 5c 24 30          	cmp    %ebx,0x30(%rsp)
  402ac3:	7e 31                	jle    402af6 <main+0xc46>
  402ac5:	89 da                	mov    %ebx,%edx
  402ac7:	45 85 ed             	test   %r13d,%r13d
  402aca:	0f 89 7d fe ff ff    	jns    40294d <main+0xa9d>
                    int sample_col = std::clamp(x + k, 0, w - 1);
  402ad0:	8d 5a 01             	lea    0x1(%rdx),%ebx
  402ad3:	45 89 fa             	mov    %r15d,%r10d
                    return blur[size_t(sample_row) * w + sample_col];
  402ad6:	48 8b 8c 24 30 01 00 	mov    0x130(%rsp),%rcx
  402add:	00 
  402ade:	44 39 fb             	cmp    %r15d,%ebx
  402ae1:	44 0f 4e d3          	cmovle %ebx,%r10d
  402ae5:	45 31 db             	xor    %r11d,%r11d
  402ae8:	4d 63 d2             	movslq %r10d,%r10
  402aeb:	f3 42 0f 10 34 91    	movss  (%rcx,%r10,4),%xmm6
    clamp(const _Tp& __val, const _Tp& __lo, const _Tp& __hi)
  402af1:	e9 99 fe ff ff       	jmpq   40298f <main+0xadf>
  402af6:	45 89 ef             	mov    %r13d,%r15d
        for (int y = 0; y < h; ++y) {
  402af9:	48 8b 7c 24 78       	mov    0x78(%rsp),%rdi
  402afe:	83 44 24 28 01       	addl   $0x1,0x28(%rsp)
  402b03:	48 01 7c 24 18       	add    %rdi,0x18(%rsp)
  402b08:	41 83 c7 01          	add    $0x1,%r15d
  402b0c:	44 3b 64 24 74       	cmp    0x74(%rsp),%r12d
  402b11:	0f 8f b8 fd ff ff    	jg     4028cf <main+0xa1f>
  402b17:	49 89 ff             	mov    %rdi,%r15
  402b1a:	44 8b b4 24 9c 00 00 	mov    0x9c(%rsp),%r14d
  402b21:	00 
  402b22:	8b 9c 24 a0 00 00 00 	mov    0xa0(%rsp),%ebx
  402b29:	8b 6c 24 30          	mov    0x30(%rsp),%ebp
        t[2]=Clock::now();
  402b2d:	e8 4e ef ff ff       	callq  401a80 <std::chrono::_V2::steady_clock::now()@plt>
      _GLIBCXX_CONSTEXPR __normal_iterator() _GLIBCXX_NOEXCEPT
      : _M_current(_Iterator()) { }

      explicit
      __normal_iterator(const _Iterator& __i) _GLIBCXX_NOEXCEPT
      : _M_current(__i) { }
  402b32:	4c 8b 8c 24 90 01 00 	mov    0x190(%rsp),%r9
  402b39:	00 
  402b3a:	48 8b 94 24 98 01 00 	mov    0x198(%rsp),%rdx
  402b41:	00 
  402b42:	48 89 84 24 40 02 00 	mov    %rax,0x240(%rsp)
  402b49:	00 
    __gnu_cxx::__enable_if<__is_scalar<_Tp>::__value, void>::__type
    __fill_a(_ForwardIterator __first, _ForwardIterator __last,
	     const _Tp& __value)
    {
      const _Tp __tmp = __value;
      for (; __first != __last; ++__first)
  402b4a:	4c 89 c8             	mov    %r9,%rax
  402b4d:	49 39 d1             	cmp    %rdx,%r9
  402b50:	74 0f                	je     402b61 <main+0xcb1>
	*__first = __tmp;
  402b52:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
      for (; __first != __last; ++__first)
  402b58:	48 83 c0 04          	add    $0x4,%rax
  402b5c:	48 39 d0             	cmp    %rdx,%rax
  402b5f:	75 f1                	jne    402b52 <main+0xca2>
        for (int y = 1; y < h - 1; ++y) {
  402b61:	8b 84 24 98 00 00 00 	mov    0x98(%rsp),%eax
  402b68:	48 8b bc 24 90 00 00 	mov    0x90(%rsp),%rdi
  402b6f:	00 
  402b70:	41 ba 01 00 00 00    	mov    $0x1,%r10d
  402b76:	4d 8d 6f fe          	lea    -0x2(%r15),%r13
                float d = angle[i];
  402b7a:	4c 8b 84 24 70 01 00 	mov    0x170(%rsp),%r8
  402b81:	00 
                if (mag[i] > mag[a] && mag[i] >= mag[b])
  402b82:	48 8b 94 24 50 01 00 	mov    0x150(%rsp),%rdx
  402b89:	00 
  402b8a:	4d 8d 5f ff          	lea    -0x1(%r15),%r11
  402b8e:	48 8d 34 07          	lea    (%rdi,%rax,1),%rsi
  402b92:	48 f7 d0             	not    %rax
                } else if (d < 67.5f) {
  402b95:	f3 0f 10 15 73 19 00 	movss  0x1973(%rip),%xmm2        # 404510 <__dso_handle+0x268>
  402b9c:	00 
                } else if (d < 112.5f) {
  402b9d:	f3 0f 10 0d 6f 19 00 	movss  0x196f(%rip),%xmm1        # 404514 <__dso_handle+0x26c>
  402ba4:	00 
  402ba5:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
  402baa:	48 c7 c0 fe ff ff ff 	mov    $0xfffffffffffffffe,%rax
  402bb1:	4c 29 f8             	sub    %r15,%rax
  402bb4:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
            for (int x = 1; x < w - 1; ++x) {
  402bb9:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
  402bbe:	4c 89 ff             	mov    %r15,%rdi
  402bc1:	48 f7 d7             	not    %rdi
  402bc4:	48 01 f0             	add    %rsi,%rax
  402bc7:	48 89 7c 24 28       	mov    %rdi,0x28(%rsp)
  402bcc:	eb 3d                	jmp    402c0b <main+0xd5b>
                if (d < 22.5f || d >= 157.5f) {
  402bce:	0f 2f 05 37 19 00 00 	comiss 0x1937(%rip),%xmm0        # 40450c <__dso_handle+0x264>
  402bd5:	73 48                	jae    402c1f <main+0xd6f>
                } else if (d < 67.5f) {
  402bd7:	0f 2f d0             	comiss %xmm0,%xmm2
  402bda:	76 4c                	jbe    402c28 <main+0xd78>
                    a = i - w - 1; // one row up, one column left
  402bdc:	48 8b 7c 24 30       	mov    0x30(%rsp),%rdi
  402be1:	48 8d 0c 07          	lea    (%rdi,%rax,1),%rcx
                    b = i + w + 1; // one row down, one column right
  402be5:	49 8d 3c 07          	lea    (%r15,%rax,1),%rdi
                if (mag[i] > mag[a] && mag[i] >= mag[b])
  402be9:	f3 0f 10 44 82 fc    	movss  -0x4(%rdx,%rax,4),%xmm0
  402bef:	0f 2f 04 8a          	comiss (%rdx,%rcx,4),%xmm0
  402bf3:	76 0d                	jbe    402c02 <main+0xd52>
  402bf5:	0f 2f 04 ba          	comiss (%rdx,%rdi,4),%xmm0
  402bf9:	72 07                	jb     402c02 <main+0xd52>
                    suppressed[i] = mag[i];
  402bfb:	f3 41 0f 11 44 81 fc 	movss  %xmm0,-0x4(%r9,%rax,4)
            for (int x = 1; x < w - 1; ++x) {
  402c02:	48 83 c0 01          	add    $0x1,%rax
  402c06:	48 39 c6             	cmp    %rax,%rsi
  402c09:	74 35                	je     402c40 <main+0xd90>
                float d = angle[i];
  402c0b:	f3 41 0f 10 44 80 fc 	movss  -0x4(%r8,%rax,4),%xmm0
                if (d < 22.5f || d >= 157.5f) {
  402c12:	f3 0f 10 35 ee 18 00 	movss  0x18ee(%rip),%xmm6        # 404508 <__dso_handle+0x260>
  402c19:	00 
  402c1a:	0f 2f f0             	comiss %xmm0,%xmm6
  402c1d:	76 af                	jbe    402bce <main+0xd1e>
                    a = i - 1; // pixel to the left
  402c1f:	48 8d 48 fe          	lea    -0x2(%rax),%rcx
                    b = i + 1; // pixel to the right
  402c23:	48 89 c7             	mov    %rax,%rdi
  402c26:	eb c1                	jmp    402be9 <main+0xd39>
                } else if (d < 112.5f) {
  402c28:	0f 2f c8             	comiss %xmm0,%xmm1
  402c2b:	0f 86 42 01 00 00    	jbe    402d73 <main+0xec3>
                    a = i - w; // pixel one row above
  402c31:	48 8b 7c 24 28       	mov    0x28(%rsp),%rdi
  402c36:	48 8d 0c 07          	lea    (%rdi,%rax,1),%rcx
                    b = i + w; // pixel one row below
  402c3a:	49 8d 3c 03          	lea    (%r11,%rax,1),%rdi
  402c3e:	eb a9                	jmp    402be9 <main+0xd39>
        for (int y = 1; y < h - 1; ++y) {
  402c40:	41 83 c2 01          	add    $0x1,%r10d
  402c44:	4c 01 fe             	add    %r15,%rsi
  402c47:	44 3b 94 24 88 00 00 	cmp    0x88(%rsp),%r10d
  402c4e:	00 
  402c4f:	0f 8c 64 ff ff ff    	jl     402bb9 <main+0xd09>
        t[3]=Clock::now();
  402c55:	e8 26 ee ff ff       	callq  401a80 <std::chrono::_V2::steady_clock::now()@plt>
  402c5a:	48 89 84 24 48 02 00 	mov    %rax,0x248(%rsp)
  402c61:	00 
        for(size_t i=0;i<n;++i) labels[i]=suppressed[i]>high?2:(suppressed[i]>low?1:0);
  402c62:	31 c0                	xor    %eax,%eax
  402c64:	48 8b 94 24 90 01 00 	mov    0x190(%rsp),%rdx
  402c6b:	00 
  402c6c:	f3 0f 10 04 82       	movss  (%rdx,%rax,4),%xmm0
  402c71:	0f 2f 44 24 44       	comiss 0x44(%rsp),%xmm0
  402c76:	ba 02 00 00 00       	mov    $0x2,%edx
  402c7b:	77 08                	ja     402c85 <main+0xdd5>
  402c7d:	0f 2f 44 24 3c       	comiss 0x3c(%rsp),%xmm0
  402c82:	0f 97 c2             	seta   %dl
  402c85:	48 8b 8c 24 10 01 00 	mov    0x110(%rsp),%rcx
  402c8c:	00 
  402c8d:	88 14 01             	mov    %dl,(%rcx,%rax,1)
  402c90:	48 83 c0 01          	add    $0x1,%rax
  402c94:	48 39 44 24 20       	cmp    %rax,0x20(%rsp)
  402c99:	75 c9                	jne    402c64 <main+0xdb4>
        t[4]=Clock::now();
  402c9b:	e8 e0 ed ff ff       	callq  401a80 <std::chrono::_V2::steady_clock::now()@plt>
  402ca0:	48 89 84 24 50 02 00 	mov    %rax,0x250(%rsp)
  402ca7:	00 
       *  pointed-to memory is not touched in any way.  Managing the pointer is
       *  the user's responsibility.
       */
      void
      clear() _GLIBCXX_NOEXCEPT
      { _M_erase_at_end(this->_M_impl._M_start); }
  402ca8:	48 8b 84 24 b0 01 00 	mov    0x1b0(%rsp),%rax
  402caf:	00 
      // Called by erase(q1,q2), clear(), resize(), _M_fill_assign,
      // _M_assign_aux.
      void
      _M_erase_at_end(pointer __pos) _GLIBCXX_NOEXCEPT
      {
	if (size_type __n = this->_M_impl._M_finish - __pos)
  402cb0:	48 3b 84 24 b8 01 00 	cmp    0x1b8(%rsp),%rax
  402cb7:	00 
  402cb8:	74 08                	je     402cc2 <main+0xe12>
	  {
	    std::_Destroy(__pos, this->_M_impl._M_finish,
			  _M_get_Tp_allocator());
	    this->_M_impl._M_finish = __pos;
  402cba:	48 89 84 24 b8 01 00 	mov    %rax,0x1b8(%rsp)
  402cc1:	00 
  402cc2:	48 8b 94 24 f8 00 00 	mov    0xf8(%rsp),%rdx
  402cc9:	00 
  402cca:	48 8b 84 24 f0 00 00 	mov    0xf0(%rsp),%rax
  402cd1:	00 
  402cd2:	48 39 c2             	cmp    %rax,%rdx
  402cd5:	74 0c                	je     402ce3 <main+0xe33>
	*__first = __tmp;
  402cd7:	c6 00 00             	movb   $0x0,(%rax)
      for (; __first != __last; ++__first)
  402cda:	48 83 c0 01          	add    $0x1,%rax
  402cde:	48 39 c2             	cmp    %rax,%rdx
  402ce1:	75 f4                	jne    402cd7 <main+0xe27>
    // Start from a cleared edge map and an empty queue.
    queue.clear();
    std::fill(edges.begin(),edges.end(),0);

    // Seed: every strong pixel is an edge and a place to grow from.
    for(size_t i=0;i<labels.size();++i) if(labels[i]==2) {edges[i]=255;queue.push_back(i);}
  402ce3:	48 c7 84 24 c0 00 00 	movq   $0x0,0xc0(%rsp)
  402cea:	00 00 00 00 00 
  402cef:	48 8b 94 24 10 01 00 	mov    0x110(%rsp),%rdx
  402cf6:	00 
  402cf7:	31 c0                	xor    %eax,%eax
  402cf9:	48 39 94 24 18 01 00 	cmp    %rdx,0x118(%rsp)
  402d00:	00 
  402d01:	75 26                	jne    402d29 <main+0xe79>
  402d03:	eb 7e                	jmp    402d83 <main+0xed3>
  402d05:	48 8b 84 24 c0 00 00 	mov    0xc0(%rsp),%rax
  402d0c:	00 
      { return size_type(this->_M_impl._M_finish - this->_M_impl._M_start); }
  402d0d:	48 8b 8c 24 18 01 00 	mov    0x118(%rsp),%rcx
  402d14:	00 
  402d15:	48 83 c0 01          	add    $0x1,%rax
  402d19:	48 29 d1             	sub    %rdx,%rcx
  402d1c:	48 89 84 24 c0 00 00 	mov    %rax,0xc0(%rsp)
  402d23:	00 
  402d24:	48 39 c1             	cmp    %rax,%rcx
  402d27:	76 5a                	jbe    402d83 <main+0xed3>
  402d29:	80 3c 02 02          	cmpb   $0x2,(%rdx,%rax,1)
  402d2d:	75 d6                	jne    402d05 <main+0xe55>
  402d2f:	48 8b 94 24 f0 00 00 	mov    0xf0(%rsp),%rdx
  402d36:	00 
  402d37:	c6 04 02 ff          	movb   $0xff,(%rdx,%rax,1)
	if (this->_M_impl._M_finish != this->_M_impl._M_end_of_storage)
  402d3b:	48 8b b4 24 b8 01 00 	mov    0x1b8(%rsp),%rsi
  402d42:	00 
  402d43:	48 3b b4 24 c0 01 00 	cmp    0x1c0(%rsp),%rsi
  402d4a:	00 
  402d4b:	0f 84 1c 06 00 00    	je     40336d <main+0x14bd>
	    _Alloc_traits::construct(this->_M_impl, this->_M_impl._M_finish,
  402d51:	48 8b 84 24 c0 00 00 	mov    0xc0(%rsp),%rax
  402d58:	00 
	    ++this->_M_impl._M_finish;
  402d59:	48 83 c6 08          	add    $0x8,%rsi
  402d5d:	48 8b 94 24 10 01 00 	mov    0x110(%rsp),%rdx
  402d64:	00 
  402d65:	48 89 46 f8          	mov    %rax,-0x8(%rsi)
  402d69:	48 89 b4 24 b8 01 00 	mov    %rsi,0x1b8(%rsp)
  402d70:	00 
  402d71:	eb 92                	jmp    402d05 <main+0xe55>
                    a = i - w + 1; // one row up, one column right
  402d73:	48 89 c1             	mov    %rax,%rcx
  402d76:	49 8d 7c 05 00       	lea    0x0(%r13,%rax,1),%rdi
  402d7b:	4c 29 f9             	sub    %r15,%rcx
                    b = i + w - 1; // one row down, one column left
  402d7e:	e9 66 fe ff ff       	jmpq   402be9 <main+0xd39>

    // Track: a weak neighbor of a kept edge is kept too, including long chains.
    for(size_t head=0;head<queue.size();++head) {
  402d83:	48 8b 94 24 b0 01 00 	mov    0x1b0(%rsp),%rdx
  402d8a:	00 
  402d8b:	48 c7 44 24 18 00 00 	movq   $0x0,0x18(%rsp)
  402d92:	00 00 
  402d94:	48 3b 94 24 b8 01 00 	cmp    0x1b8(%rsp),%rdx
  402d9b:	00 
  402d9c:	0f 84 dc 00 00 00    	je     402e7e <main+0xfce>
        size_t i=queue[head]; int y=int(i/w),x=int(i%w);
  402da2:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
  402da7:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  402dab:	31 d2                	xor    %edx,%edx
  402dad:	49 f7 f7             	div    %r15
        for(int j=-1;j<=1;++j) for(int k=-1;k<=1;++k) {
  402db0:	48 63 c8             	movslq %eax,%rcx
  402db3:	8d 78 ff             	lea    -0x1(%rax),%edi
  402db6:	83 c0 02             	add    $0x2,%eax
  402db9:	48 83 e9 01          	sub    $0x1,%rcx
  402dbd:	89 7c 24 28          	mov    %edi,0x28(%rsp)
  402dc1:	49 0f af cf          	imul   %r15,%rcx
  402dc5:	89 44 24 74          	mov    %eax,0x74(%rsp)
  402dc9:	8d 42 ff             	lea    -0x1(%rdx),%eax
  402dcc:	89 44 24 50          	mov    %eax,0x50(%rsp)
  402dd0:	48 8d 3c 11          	lea    (%rcx,%rdx,1),%rdi
  402dd4:	48 89 7c 24 48       	mov    %rdi,0x48(%rsp)
  402dd9:	8b 7c 24 28          	mov    0x28(%rsp),%edi
  402ddd:	41 39 fc             	cmp    %edi,%r12d
  402de0:	0f 9e c0             	setle  %al
  402de3:	c1 ef 1f             	shr    $0x1f,%edi
    for(size_t head=0;head<queue.size();++head) {
  402de6:	45 31 ed             	xor    %r13d,%r13d
  402de9:	09 f8                	or     %edi,%eax
  402deb:	88 44 24 30          	mov    %al,0x30(%rsp)
  402def:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
  402df4:	48 83 e8 01          	sub    $0x1,%rax
  402df8:	48 89 44 24 78       	mov    %rax,0x78(%rsp)
            if(y+j<0 || y+j>=h || x+k<0 || x+k>=w) continue;
  402dfd:	80 7c 24 30 00       	cmpb   $0x0,0x30(%rsp)
  402e02:	75 31                	jne    402e35 <main+0xf85>
  402e04:	8b 44 24 50          	mov    0x50(%rsp),%eax
  402e08:	44 01 e8             	add    %r13d,%eax
  402e0b:	39 c5                	cmp    %eax,%ebp
  402e0d:	7e 26                	jle    402e35 <main+0xf85>
  402e0f:	85 c0                	test   %eax,%eax
  402e11:	78 22                	js     402e35 <main+0xf85>
            size_t neighbor=size_t(y+j)*w+x+k;
  402e13:	48 8b 44 24 78       	mov    0x78(%rsp),%rax
            if(labels[neighbor]==1 && !edges[neighbor]) {edges[neighbor]=255;queue.push_back(neighbor);}
  402e18:	48 8b 94 24 10 01 00 	mov    0x110(%rsp),%rdx
  402e1f:	00 
  402e20:	4c 01 e8             	add    %r13,%rax
            size_t neighbor=size_t(y+j)*w+x+k;
  402e23:	48 89 84 24 c8 00 00 	mov    %rax,0xc8(%rsp)
  402e2a:	00 
            if(labels[neighbor]==1 && !edges[neighbor]) {edges[neighbor]=255;queue.push_back(neighbor);}
  402e2b:	80 3c 02 01          	cmpb   $0x1,(%rdx,%rax,1)
  402e2f:	0f 84 bc 02 00 00    	je     4030f1 <main+0x1241>
        for(int j=-1;j<=1;++j) for(int k=-1;k<=1;++k) {
  402e35:	49 83 c5 01          	add    $0x1,%r13
  402e39:	49 83 fd 03          	cmp    $0x3,%r13
  402e3d:	75 be                	jne    402dfd <main+0xf4d>
  402e3f:	83 44 24 28 01       	addl   $0x1,0x28(%rsp)
  402e44:	8b 44 24 28          	mov    0x28(%rsp),%eax
  402e48:	4c 01 7c 24 48       	add    %r15,0x48(%rsp)
  402e4d:	39 44 24 74          	cmp    %eax,0x74(%rsp)
  402e51:	75 86                	jne    402dd9 <main+0xf29>
    for(size_t head=0;head<queue.size();++head) {
  402e53:	48 8b 94 24 b0 01 00 	mov    0x1b0(%rsp),%rdx
  402e5a:	00 
      { return size_type(this->_M_impl._M_finish - this->_M_impl._M_start); }
  402e5b:	48 8b 84 24 b8 01 00 	mov    0x1b8(%rsp),%rax
  402e62:	00 
  402e63:	48 83 44 24 18 01    	addq   $0x1,0x18(%rsp)
  402e69:	48 8b 7c 24 18       	mov    0x18(%rsp),%rdi
  402e6e:	48 29 d0             	sub    %rdx,%rax
  402e71:	48 c1 f8 03          	sar    $0x3,%rax
  402e75:	48 39 f8             	cmp    %rdi,%rax
  402e78:	0f 87 24 ff ff ff    	ja     402da2 <main+0xef2>
        t[5]=Clock::now();
  402e7e:	e8 fd eb ff ff       	callq  401a80 <std::chrono::_V2::steady_clock::now()@plt>
        if(it>=0) {
  402e83:	8b 54 24 70          	mov    0x70(%rsp),%edx
        t[5]=Clock::now();
  402e87:	48 89 84 24 58 02 00 	mov    %rax,0x258(%rsp)
  402e8e:	00 
        if(it>=0) {
  402e8f:	85 d2                	test   %edx,%edx
  402e91:	0f 89 e9 03 00 00    	jns    403280 <main+0x13d0>
    for(int it=-warmup;it<iterations;++it) {
  402e97:	83 44 24 70 01       	addl   $0x1,0x70(%rsp)
  402e9c:	8b 44 24 70          	mov    0x70(%rsp),%eax
  402ea0:	3b 44 24 40          	cmp    0x40(%rsp),%eax
  402ea4:	0f 8c 06 f8 ff ff    	jl     4026b0 <main+0x800>
    std::ofstream out(output,std::ios::binary); out<<"P5\n"<<w<<" "<<h<<"\n255\n";
  402eaa:	ba 04 00 00 00       	mov    $0x4,%edx
  402eaf:	48 8d b4 24 10 02 00 	lea    0x210(%rsp),%rsi
  402eb6:	00 
  402eb7:	48 8d bc 24 d0 02 00 	lea    0x2d0(%rsp),%rdi
  402ebe:	00 
  402ebf:	e8 0c ed ff ff       	callq  401bd0 <std::basic_ofstream<char, std::char_traits<char> >::basic_ofstream(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&, std::_Ios_Openmode)@plt>
    {
      if (!__s)
	__out.setstate(ios_base::badbit);
      else
	__ostream_insert(__out, __s,
			 static_cast<streamsize>(_Traits::length(__s)));
  402ec4:	bf 9a 43 40 00       	mov    $0x40439a,%edi
  402ec9:	e8 b2 09 00 00       	callq  403880 <std::char_traits<char>::length(char const*)>
	__ostream_insert(__out, __s,
  402ece:	be 9a 43 40 00       	mov    $0x40439a,%esi
  402ed3:	48 8d bc 24 d0 02 00 	lea    0x2d0(%rsp),%rdi
  402eda:	00 
  402edb:	48 89 c2             	mov    %rax,%rdx
  402ede:	e8 2d eb ff ff       	callq  401a10 <std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)@plt>
  402ee3:	89 ee                	mov    %ebp,%esi
  402ee5:	48 8d bc 24 d0 02 00 	lea    0x2d0(%rsp),%rdi
  402eec:	00 
  402eed:	e8 9e ec ff ff       	callq  401b90 <std::ostream::operator<<(int)@plt>
			 static_cast<streamsize>(_Traits::length(__s)));
  402ef2:	bf 44 43 40 00       	mov    $0x404344,%edi
  402ef7:	48 89 c3             	mov    %rax,%rbx
  402efa:	e8 81 09 00 00       	callq  403880 <std::char_traits<char>::length(char const*)>
	__ostream_insert(__out, __s,
  402eff:	be 44 43 40 00       	mov    $0x404344,%esi
  402f04:	48 89 df             	mov    %rbx,%rdi
  402f07:	48 89 c2             	mov    %rax,%rdx
  402f0a:	e8 01 eb ff ff       	callq  401a10 <std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)@plt>
  402f0f:	44 89 e6             	mov    %r12d,%esi
  402f12:	48 89 df             	mov    %rbx,%rdi
  402f15:	e8 76 ec ff ff       	callq  401b90 <std::ostream::operator<<(int)@plt>
  402f1a:	be 9e 43 40 00       	mov    $0x40439e,%esi
  402f1f:	48 89 c7             	mov    %rax,%rdi
  402f22:	e8 b9 ea ff ff       	callq  4019e0 <std::basic_ostream<char, std::char_traits<char> >& std::operator<< <std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*)@plt>
    out.write(reinterpret_cast<char*>(edges.data()),std::streamsize(n));
  402f27:	48 8b 54 24 20       	mov    0x20(%rsp),%rdx
  402f2c:	48 8b b4 24 f0 00 00 	mov    0xf0(%rsp),%rsi
  402f33:	00 
  402f34:	48 8d bc 24 d0 02 00 	lea    0x2d0(%rsp),%rdi
  402f3b:	00 
  402f3c:	e8 2f eb ff ff       	callq  401a70 <std::ostream::write(char const*, long)@plt>
    if(!out) throw std::runtime_error("Could not write output");
  402f41:	8b 9c 24 e8 03 00 00 	mov    0x3e8(%rsp),%ebx
  402f48:	83 e3 05             	and    $0x5,%ebx
  402f4b:	0f 85 62 04 00 00    	jne    4033b3 <main+0x1503>
    std::cout<<"{\"timing_method\":\"steady_clock instrumented pipeline; allocations and I/O excluded\",\"samples\":[";
  402f51:	be 80 44 40 00       	mov    $0x404480,%esi
  402f56:	bf c0 51 60 00       	mov    $0x6051c0,%edi
  402f5b:	e8 80 ea ff ff       	callq  4019e0 <std::basic_ostream<char, std::char_traits<char> >& std::operator<< <std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*)@plt>
    for(size_t i=0;i<samples.size();++i) {
  402f60:	31 ed                	xor    %ebp,%ebp
  402f62:	45 31 e4             	xor    %r12d,%r12d
  402f65:	49 bd ab aa aa aa aa 	movabs $0xaaaaaaaaaaaaaaab,%r13
  402f6c:	aa aa aa 
  402f6f:	48 8b 84 24 d0 01 00 	mov    0x1d0(%rsp),%rax
  402f76:	00 
  402f77:	48 39 84 24 d8 01 00 	cmp    %rax,0x1d8(%rsp)
  402f7e:	00 
  402f7f:	0f 84 eb 01 00 00    	je     403170 <main+0x12c0>
  402f85:	ba 0e 00 00 00       	mov    $0xe,%edx
  402f8a:	be c1 43 40 00       	mov    $0x4043c1,%esi
  402f8f:	bf c0 51 60 00       	mov    $0x6051c0,%edi
  402f94:	e8 77 ea ff ff       	callq  401a10 <std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)@plt>
        std::cout<<"{\"compute_ms\":"<<samples[i][0]<<",\"e2e_ms\":"<<samples[i][0];
  402f99:	48 8b 84 24 d0 01 00 	mov    0x1d0(%rsp),%rax
  402fa0:	00 
      { return _M_insert(__f); }
  402fa1:	bf c0 51 60 00       	mov    $0x6051c0,%edi
  402fa6:	f2 0f 10 04 28       	movsd  (%rax,%rbp,1),%xmm0
  402fab:	e8 50 eb ff ff       	callq  401b00 <std::ostream& std::ostream::_M_insert<double>(double)@plt>
	__ostream_insert(__out, __s,
  402fb0:	ba 0a 00 00 00       	mov    $0xa,%edx
  402fb5:	be d0 43 40 00       	mov    $0x4043d0,%esi
  402fba:	48 89 c7             	mov    %rax,%rdi
      { return _M_insert(__f); }
  402fbd:	49 89 c6             	mov    %rax,%r14
	__ostream_insert(__out, __s,
  402fc0:	e8 4b ea ff ff       	callq  401a10 <std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)@plt>
  402fc5:	48 8b 84 24 d0 01 00 	mov    0x1d0(%rsp),%rax
  402fcc:	00 
      { return _M_insert(__f); }
  402fcd:	4c 89 f7             	mov    %r14,%rdi
  402fd0:	f2 0f 10 04 28       	movsd  (%rax,%rbp,1),%xmm0
  402fd5:	e8 26 eb ff ff       	callq  401b00 <std::ostream& std::ostream::_M_insert<double>(double)@plt>
        const char* names[]={"blur_ms","sobel_ms","nms_ms","threshold_ms","hysteresis_ms"};
  402fda:	48 c7 84 24 30 02 00 	movq   $0x4043db,0x230(%rsp)
  402fe1:	00 db 43 40 00 
  402fe6:	41 be 01 00 00 00    	mov    $0x1,%r14d
  402fec:	48 c7 84 24 38 02 00 	movq   $0x4043e3,0x238(%rsp)
  402ff3:	00 e3 43 40 00 
  402ff8:	48 c7 84 24 40 02 00 	movq   $0x4043ec,0x240(%rsp)
  402fff:	00 ec 43 40 00 
  403004:	48 c7 84 24 48 02 00 	movq   $0x4043f3,0x248(%rsp)
  40300b:	00 f3 43 40 00 
  403010:	48 c7 84 24 50 02 00 	movq   $0x404400,0x250(%rsp)
  403017:	00 00 44 40 00 
	__ostream_insert(__out, __s,
  40301c:	ba 02 00 00 00       	mov    $0x2,%edx
  403021:	be 0e 44 40 00       	mov    $0x40440e,%esi
  403026:	bf c0 51 60 00       	mov    $0x6051c0,%edi
  40302b:	e8 e0 e9 ff ff       	callq  401a10 <std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)@plt>
        for(int s=0;s<5;++s) std::cout<<",\""<<names[s]<<"\":"<<samples[i][s+1];
  403030:	4e 8b bc f4 28 02 00 	mov    0x228(%rsp,%r14,8),%r15
  403037:	00 
      if (!__s)
  403038:	4d 85 ff             	test   %r15,%r15
  40303b:	0f 84 f3 00 00 00    	je     403134 <main+0x1284>
  403041:	4c 89 ff             	mov    %r15,%rdi
  403044:	e8 e7 e8 ff ff       	callq  401930 <strlen@plt>
	__ostream_insert(__out, __s,
  403049:	4c 89 fe             	mov    %r15,%rsi
  40304c:	bf c0 51 60 00       	mov    $0x6051c0,%edi
  403051:	48 89 c2             	mov    %rax,%rdx
  403054:	e8 b7 e9 ff ff       	callq  401a10 <std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)@plt>
  403059:	ba 02 00 00 00       	mov    $0x2,%edx
  40305e:	be d8 43 40 00       	mov    $0x4043d8,%esi
  403063:	bf c0 51 60 00       	mov    $0x6051c0,%edi
  403068:	e8 a3 e9 ff ff       	callq  401a10 <std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)@plt>
  40306d:	4a 8d 04 f5 00 00 00 	lea    0x0(,%r14,8),%rax
  403074:	00 
  403075:	48 03 84 24 d0 01 00 	add    0x1d0(%rsp),%rax
  40307c:	00 
      { return _M_insert(__f); }
  40307d:	bf c0 51 60 00       	mov    $0x6051c0,%edi
  403082:	f2 0f 10 04 28       	movsd  (%rax,%rbp,1),%xmm0
  403087:	e8 74 ea ff ff       	callq  401b00 <std::ostream& std::ostream::_M_insert<double>(double)@plt>
  40308c:	49 83 c6 01          	add    $0x1,%r14
  403090:	49 83 fe 06          	cmp    $0x6,%r14
  403094:	75 86                	jne    40301c <main+0x116c>
	__ostream_insert(__out, __s,
  403096:	ba 01 00 00 00       	mov    $0x1,%edx
  40309b:	be 11 44 40 00       	mov    $0x404411,%esi
  4030a0:	bf c0 51 60 00       	mov    $0x6051c0,%edi
  4030a5:	e8 66 e9 ff ff       	callq  401a10 <std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)@plt>
  4030aa:	48 8b 84 24 d8 01 00 	mov    0x1d8(%rsp),%rax
  4030b1:	00 
  4030b2:	48 2b 84 24 d0 01 00 	sub    0x1d0(%rsp),%rax
  4030b9:	00 
    for(size_t i=0;i<samples.size();++i) {
  4030ba:	49 83 c4 01          	add    $0x1,%r12
  4030be:	48 c1 f8 04          	sar    $0x4,%rax
  4030c2:	49 0f af c5          	imul   %r13,%rax
  4030c6:	49 39 c4             	cmp    %rax,%r12
  4030c9:	0f 83 a1 00 00 00    	jae    403170 <main+0x12c0>
        if(i) std::cout<<",";
  4030cf:	4d 85 e4             	test   %r12,%r12
  4030d2:	74 14                	je     4030e8 <main+0x1238>
  4030d4:	ba 01 00 00 00       	mov    $0x1,%edx
  4030d9:	be bf 43 40 00       	mov    $0x4043bf,%esi
  4030de:	bf c0 51 60 00       	mov    $0x6051c0,%edi
  4030e3:	e8 28 e9 ff ff       	callq  401a10 <std::basic_ostream<char, std::char_traits<char> >& std::__ostream_insert<char, std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*, long)@plt>
  4030e8:	48 83 c5 30          	add    $0x30,%rbp
  4030ec:	e9 94 fe ff ff       	jmpq   402f85 <main+0x10d5>
	return *(this->_M_impl._M_start + __n);
  4030f1:	48 03 84 24 f0 00 00 	add    0xf0(%rsp),%rax
  4030f8:	00 
            if(labels[neighbor]==1 && !edges[neighbor]) {edges[neighbor]=255;queue.push_back(neighbor);}
  4030f9:	80 38 00             	cmpb   $0x0,(%rax)
  4030fc:	0f 85 33 fd ff ff    	jne    402e35 <main+0xf85>
  403102:	c6 00 ff             	movb   $0xff,(%rax)
	if (this->_M_impl._M_finish != this->_M_impl._M_end_of_storage)
  403105:	48 8b b4 24 b8 01 00 	mov    0x1b8(%rsp),%rsi
  40310c:	00 
  40310d:	48 3b b4 24 c0 01 00 	cmp    0x1c0(%rsp),%rsi
  403114:	00 
  403115:	74 3f                	je     403156 <main+0x12a6>
	    _Alloc_traits::construct(this->_M_impl, this->_M_impl._M_finish,
  403117:	48 8b 84 24 c8 00 00 	mov    0xc8(%rsp),%rax
  40311e:	00 
	    ++this->_M_impl._M_finish;
  40311f:	48 83 c6 08          	add    $0x8,%rsi
  403123:	48 89 46 f8          	mov    %rax,-0x8(%rsi)
  403127:	48 89 b4 24 b8 01 00 	mov    %rsi,0x1b8(%rsp)
  40312e:	00 
  40312f:	e9 01 fd ff ff       	jmpq   402e35 <main+0xf85>
	__out.setstate(ios_base::badbit);
  403134:	48 8b 05 85 20 20 00 	mov    0x202085(%rip),%rax        # 6051c0 <std::cout@@GLIBCXX_3.4>
  40313b:	48 8b 78 e8          	mov    -0x18(%rax),%rdi
  40313f:	48 81 c7 c0 51 60 00 	add    $0x6051c0,%rdi
  operator&(_Ios_Iostate __a, _Ios_Iostate __b)
  { return _Ios_Iostate(static_cast<int>(__a) & static_cast<int>(__b)); }

  inline _GLIBCXX_CONSTEXPR _Ios_Iostate
  operator|(_Ios_Iostate __a, _Ios_Iostate __b)
  { return _Ios_Iostate(static_cast<int>(__a) | static_cast<int>(__b)); }
  403146:	8b 77 20             	mov    0x20(%rdi),%esi
  403149:	83 ce 01             	or     $0x1,%esi
       *
       *  See std::ios_base::iostate for the possible bit values.
      */
      void
      setstate(iostate __state)
      { this->clear(this->rdstate() | __state); }
  40314c:	e8 1f ea ff ff       	callq  401b70 <std::basic_ios<char, std::char_traits<char> >::clear(std::_Ios_Iostate)@plt>
  403151:	e9 03 ff ff ff       	jmpq   403059 <main+0x11a9>
	  _M_realloc_insert(end(), __x);
  403156:	48 8d 94 24 c8 00 00 	lea    0xc8(%rsp),%rdx
  40315d:	00 
  40315e:	48 8d bc 24 b0 01 00 	lea    0x1b0(%rsp),%rdi
  403165:	00 
  403166:	e8 55 09 00 00       	callq  403ac0 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  40316b:	e9 c5 fc ff ff       	jmpq   402e35 <main+0xf85>
    std::cout<<"]}\n";
  403170:	be bb 43 40 00       	mov    $0x4043bb,%esi
  403175:	bf c0 51 60 00       	mov    $0x6051c0,%edi
  40317a:	e8 61 e8 ff ff       	callq  4019e0 <std::basic_ostream<char, std::char_traits<char> >& std::operator<< <std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char const*)@plt>
    std::ofstream out(output,std::ios::binary); out<<"P5\n"<<w<<" "<<h<<"\n255\n";
  40317f:	48 8d bc 24 d0 02 00 	lea    0x2d0(%rsp),%rdi
  403186:	00 
  403187:	e8 54 e9 ff ff       	callq  401ae0 <std::basic_ofstream<char, std::char_traits<char> >::~basic_ofstream()@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  40318c:	48 8b bc 24 d0 01 00 	mov    0x1d0(%rsp),%rdi
  403193:	00 
	if (__p)
  403194:	48 85 ff             	test   %rdi,%rdi
  403197:	74 05                	je     40319e <main+0x12ee>
  403199:	e8 32 e8 ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  40319e:	48 8b bc 24 b0 01 00 	mov    0x1b0(%rsp),%rdi
  4031a5:	00 
	if (__p)
  4031a6:	48 85 ff             	test   %rdi,%rdi
  4031a9:	74 05                	je     4031b0 <main+0x1300>
  4031ab:	e8 20 e8 ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  4031b0:	48 8b bc 24 90 01 00 	mov    0x190(%rsp),%rdi
  4031b7:	00 
	if (__p)
  4031b8:	48 85 ff             	test   %rdi,%rdi
  4031bb:	74 05                	je     4031c2 <main+0x1312>
  4031bd:	e8 0e e8 ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  4031c2:	48 8b bc 24 70 01 00 	mov    0x170(%rsp),%rdi
  4031c9:	00 
	if (__p)
  4031ca:	48 85 ff             	test   %rdi,%rdi
  4031cd:	74 05                	je     4031d4 <main+0x1324>
  4031cf:	e8 fc e7 ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  4031d4:	48 8b bc 24 50 01 00 	mov    0x150(%rsp),%rdi
  4031db:	00 
	if (__p)
  4031dc:	48 85 ff             	test   %rdi,%rdi
  4031df:	74 05                	je     4031e6 <main+0x1336>
  4031e1:	e8 ea e7 ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  4031e6:	48 8b bc 24 30 01 00 	mov    0x130(%rsp),%rdi
  4031ed:	00 
	if (__p)
  4031ee:	48 85 ff             	test   %rdi,%rdi
  4031f1:	74 05                	je     4031f8 <main+0x1348>
  4031f3:	e8 d8 e7 ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  4031f8:	48 8b bc 24 10 01 00 	mov    0x110(%rsp),%rdi
  4031ff:	00 
	if (__p)
  403200:	48 85 ff             	test   %rdi,%rdi
  403203:	74 05                	je     40320a <main+0x135a>
  403205:	e8 c6 e7 ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  40320a:	48 8b bc 24 f0 00 00 	mov    0xf0(%rsp),%rdi
  403211:	00 
	if (__p)
  403212:	48 85 ff             	test   %rdi,%rdi
  403215:	74 05                	je     40321c <main+0x136c>
  403217:	e8 b4 e7 ff ff       	callq  4019d0 <operator delete(void*)@plt>
	std::_Destroy(this->_M_impl._M_start, this->_M_impl._M_finish,
  40321c:	48 8b bc 24 d0 00 00 	mov    0xd0(%rsp),%rdi
  403223:	00 
	if (__p)
  403224:	48 85 ff             	test   %rdi,%rdi
  403227:	74 05                	je     40322e <main+0x137e>
  403229:	e8 a2 e7 ff ff       	callq  4019d0 <operator delete(void*)@plt>
    std::ifstream in(input,std::ios::binary);
  40322e:	48 8b 7c 24 10       	mov    0x10(%rsp),%rdi
  403233:	e8 a8 e6 ff ff       	callq  4018e0 <std::basic_ifstream<char, std::char_traits<char> >::~basic_ifstream()@plt>
      { return _M_data() == _M_local_data(); }
  403238:	48 8b bc 24 10 02 00 	mov    0x210(%rsp),%rdi
  40323f:	00 
	if (!_M_is_local())
  403240:	48 8d 84 24 20 02 00 	lea    0x220(%rsp),%rax
  403247:	00 
  403248:	48 39 c7             	cmp    %rax,%rdi
  40324b:	74 05                	je     403252 <main+0x13a2>
  40324d:	e8 7e e7 ff ff       	callq  4019d0 <operator delete(void*)@plt>
      { return _M_data() == _M_local_data(); }
  403252:	48 8b bc 24 f0 01 00 	mov    0x1f0(%rsp),%rdi
  403259:	00 
	if (!_M_is_local())
  40325a:	48 8d 84 24 00 02 00 	lea    0x200(%rsp),%rax
  403261:	00 
  403262:	48 39 c7             	cmp    %rax,%rdi
  403265:	74 05                	je     40326c <main+0x13bc>
  403267:	e8 64 e7 ff ff       	callq  4019d0 <operator delete(void*)@plt>
} catch(const std::exception& e) {std::cerr<<e.what()<<"\n";return 1;}
  40326c:	48 81 c4 e8 06 00 00 	add    $0x6e8,%rsp
  403273:	89 d8                	mov    %ebx,%eax
  403275:	5b                   	pop    %rbx
  403276:	5d                   	pop    %rbp
  403277:	41 5c                	pop    %r12
  403279:	41 5d                	pop    %r13
  40327b:	41 5e                	pop    %r14
  40327d:	41 5f                	pop    %r15
  40327f:	c3                   	retq   
            row[0]=ms(t[0],t[5]);
  403280:	48 8b 94 24 30 02 00 	mov    0x230(%rsp),%rdx
  403287:	00 
	  static constexpr _ToDur
	  __cast(const duration<_Rep, _Period>& __d)
	  {
	    typedef typename _ToDur::rep			__to_rep;
	    return _ToDur(static_cast<__to_rep>(
	      static_cast<_CR>(__d.count()) / static_cast<_CR>(_CF::den)));
  403288:	66 0f ef c0          	pxor   %xmm0,%xmm0
  40328c:	f2 0f 10 0d ac 12 00 	movsd  0x12ac(%rip),%xmm1        # 404540 <__dso_handle+0x298>
  403293:	00 
		const duration<_Rep2, _Period2>& __rhs)
      {
	typedef duration<_Rep1, _Period1>			__dur1;
	typedef duration<_Rep2, _Period2>			__dur2;
	typedef typename common_type<__dur1,__dur2>::type	__cd;
	return __cd(__cd(__lhs).count() - __cd(__rhs).count());
  403294:	48 29 d0             	sub    %rdx,%rax
	      static_cast<_CR>(__d.count()) / static_cast<_CR>(_CF::den)));
  403297:	f2 48 0f 2a c0       	cvtsi2sd %rax,%xmm0
  40329c:	b8 08 00 00 00       	mov    $0x8,%eax
  4032a1:	f2 0f 5e c1          	divsd  %xmm1,%xmm0
  4032a5:	f2 0f 11 84 24 d0 02 	movsd  %xmm0,0x2d0(%rsp)
  4032ac:	00 00 
                row[s+1]=ms(t[s],t[s+1]);
  4032ae:	48 8b 8c 04 30 02 00 	mov    0x230(%rsp,%rax,1),%rcx
  4032b5:	00 
  4032b6:	66 0f ef c0          	pxor   %xmm0,%xmm0
	return __cd(__cd(__lhs).count() - __cd(__rhs).count());
  4032ba:	48 89 cf             	mov    %rcx,%rdi
  4032bd:	48 29 d7             	sub    %rdx,%rdi
  4032c0:	48 89 ca             	mov    %rcx,%rdx
	      static_cast<_CR>(__d.count()) / static_cast<_CR>(_CF::den)));
  4032c3:	f2 48 0f 2a c7       	cvtsi2sd %rdi,%xmm0
  4032c8:	f2 0f 5e c1          	divsd  %xmm1,%xmm0
  4032cc:	f2 0f 11 84 04 d0 02 	movsd  %xmm0,0x2d0(%rsp,%rax,1)
  4032d3:	00 00 
            for(int s=0;s<5;++s)
  4032d5:	48 83 c0 08          	add    $0x8,%rax
  4032d9:	48 83 f8 30          	cmp    $0x30,%rax
  4032dd:	75 cf                	jne    4032ae <main+0x13fe>
	if (this->_M_impl._M_finish != this->_M_impl._M_end_of_storage)
  4032df:	48 8b b4 24 d8 01 00 	mov    0x1d8(%rsp),%rsi
  4032e6:	00 
  4032e7:	48 3b b4 24 e0 01 00 	cmp    0x1e0(%rsp),%rsi
  4032ee:	00 
  4032ef:	0f 84 9a 00 00 00    	je     40338f <main+0x14df>
#endif // __cpp_sized_deallocation
#endif // __cpp_aligned_new

// Default placement versions of operator new.
inline void* operator new(std::size_t, void* __p) _GLIBCXX_USE_NOEXCEPT
{ return __p; }
  4032f5:	66 0f 6f b4 24 d0 02 	movdqa 0x2d0(%rsp),%xmm6
  4032fc:	00 00 
	    ++this->_M_impl._M_finish;
  4032fe:	48 83 c6 30          	add    $0x30,%rsi
  403302:	0f 11 76 d0          	movups %xmm6,-0x30(%rsi)
  403306:	66 0f 6f bc 24 e0 02 	movdqa 0x2e0(%rsp),%xmm7
  40330d:	00 00 
  40330f:	0f 11 7e e0          	movups %xmm7,-0x20(%rsi)
  403313:	66 0f 6f ac 24 f0 02 	movdqa 0x2f0(%rsp),%xmm5
  40331a:	00 00 
  40331c:	0f 11 6e f0          	movups %xmm5,-0x10(%rsi)
  403320:	48 89 b4 24 d8 01 00 	mov    %rsi,0x1d8(%rsp)
  403327:	00 
  403328:	e9 6a fb ff ff       	jmpq   402e97 <main+0xfe7>
  40332d:	f3 0f 11 9c 24 ac 00 	movss  %xmm3,0xac(%rsp)
  403334:	00 00 
  403336:	f3 0f 11 94 24 a8 00 	movss  %xmm2,0xa8(%rsp)
  40333d:	00 00 
  40333f:	f3 0f 11 8c 24 a4 00 	movss  %xmm1,0xa4(%rsp)
  403346:	00 00 
  { return __builtin_sqrtf(__x); }
  403348:	e8 63 e8 ff ff       	callq  401bb0 <sqrtf@plt>
  40334d:	f3 0f 10 9c 24 ac 00 	movss  0xac(%rsp),%xmm3
  403354:	00 00 
  403356:	f3 0f 10 94 24 a8 00 	movss  0xa8(%rsp),%xmm2
  40335d:	00 00 
  40335f:	f3 0f 10 8c 24 a4 00 	movss  0xa4(%rsp),%xmm1
  403366:	00 00 
  403368:	e9 09 f7 ff ff       	jmpq   402a76 <main+0xbc6>
	  _M_realloc_insert(end(), __x);
  40336d:	48 8d 94 24 c0 00 00 	lea    0xc0(%rsp),%rdx
  403374:	00 
  403375:	48 8d bc 24 b0 01 00 	lea    0x1b0(%rsp),%rdi
  40337c:	00 
  40337d:	e8 3e 07 00 00       	callq  403ac0 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>
  403382:	48 8b 94 24 10 01 00 	mov    0x110(%rsp),%rdx
  403389:	00 
  40338a:	e9 76 f9 ff ff       	jmpq   402d05 <main+0xe55>
  40338f:	48 8d 94 24 d0 02 00 	lea    0x2d0(%rsp),%rdx
  403396:	00 
  403397:	48 8d bc 24 d0 01 00 	lea    0x1d0(%rsp),%rdi
  40339e:	00 
  40339f:	e8 ec 08 00 00       	callq  403c90 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)>
  4033a4:	e9 ee fa ff ff       	jmpq   402e97 <main+0xfe7>
  4033a9:	e8 22 e6 ff ff       	callq  4019d0 <operator delete(void*)@plt>
      ~new_allocator() _GLIBCXX_USE_NOEXCEPT { }
  4033ae:	e9 1f f0 ff ff       	jmpq   4023d2 <main+0x522>
    if(!out) throw std::runtime_error("Could not write output");
  4033b3:	bf 10 00 00 00       	mov    $0x10,%edi
  4033b8:	e8 93 e5 ff ff       	callq  401950 <__cxa_allocate_exception@plt>
  4033bd:	be a4 43 40 00       	mov    $0x4043a4,%esi
  4033c2:	48 89 c7             	mov    %rax,%rdi
  4033c5:	49 89 c4             	mov    %rax,%r12
  4033c8:	e8 43 e5 ff ff       	callq  401910 <std::runtime_error::runtime_error(char const*)@plt>
  4033cd:	e9 b5 ea ff ff       	jmpq   401e87 <main.cold.119+0x262>
        else if(k=="--sigma") sigma=std::stof(v); else throw std::runtime_error("Unknown option "+k);
  4033d2:	bf 10 00 00 00       	mov    $0x10,%edi
  4033d7:	48 8d 9c 24 d0 04 00 	lea    0x4d0(%rsp),%rbx
  4033de:	00 
  4033df:	e8 6c e5 ff ff       	callq  401950 <__cxa_allocate_exception@plt>
  4033e4:	48 8b 54 24 08       	mov    0x8(%rsp),%rdx
  4033e9:	be 36 43 40 00       	mov    $0x404336,%esi
  4033ee:	48 89 df             	mov    %rbx,%rdi
  4033f1:	49 89 c4             	mov    %rax,%r12
  4033f4:	48 89 5c 24 10       	mov    %rbx,0x10(%rsp)
  4033f9:	e8 72 0b 00 00       	callq  403f70 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > std::operator+<char, std::char_traits<char>, std::allocator<char> >(char const*, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)>
  4033fe:	48 89 de             	mov    %rbx,%rsi
  403401:	4c 89 e7             	mov    %r12,%rdi
  403404:	e8 17 e7 ff ff       	callq  401b20 <std::runtime_error::runtime_error(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)@plt>
  403409:	48 89 d8             	mov    %rbx,%rax
      { return _M_data() == _M_local_data(); }
  40340c:	48 8b bc 24 d0 04 00 	mov    0x4d0(%rsp),%rdi
  403413:	00 
	if (!_M_is_local())
  403414:	48 83 c0 10          	add    $0x10,%rax
  403418:	48 39 c7             	cmp    %rax,%rdi
  40341b:	0f 84 54 ea ff ff    	je     401e75 <main.cold.119+0x250>
	::operator delete(__p);
  403421:	e8 aa e5 ff ff       	callq  4019d0 <operator delete(void*)@plt>
  403426:	e9 4a ea ff ff       	jmpq   401e75 <main.cold.119+0x250>
    if(token(in)!="P5") throw std::runtime_error("Expected binary PGM");
  40342b:	bf 10 00 00 00       	mov    $0x10,%edi
  403430:	e8 1b e5 ff ff       	callq  401950 <__cxa_allocate_exception@plt>
  403435:	be 49 43 40 00       	mov    $0x404349,%esi
  40343a:	48 89 c7             	mov    %rax,%rdi
  40343d:	49 89 c4             	mov    %rax,%r12
  403440:	e8 cb e4 ff ff       	callq  401910 <std::runtime_error::runtime_error(char const*)@plt>
  403445:	e9 f1 e9 ff ff       	jmpq   401e3b <main.cold.119+0x216>
	__throw_length_error(__N("vector::reserve"));
  40344a:	bf 8a 43 40 00       	mov    $0x40438a,%edi
  40344f:	e8 0c e5 ff ff       	callq  401960 <std::__throw_length_error(char const*)@plt>
        throw std::runtime_error("Invalid iteration count or parameters");
  403454:	bf 10 00 00 00       	mov    $0x10,%edi
  403459:	e8 f2 e4 ff ff       	callq  401950 <__cxa_allocate_exception@plt>
  40345e:	be 58 44 40 00       	mov    $0x404458,%esi
  403463:	48 89 c7             	mov    %rax,%rdi
  403466:	49 89 c4             	mov    %rax,%r12
  403469:	e8 a2 e4 ff ff       	callq  401910 <std::runtime_error::runtime_error(char const*)@plt>
  40346e:	ba 00 1a 40 00       	mov    $0x401a00,%edx
  403473:	be b0 4d 60 00       	mov    $0x604db0,%esi
  403478:	4c 89 e7             	mov    %r12,%rdi
  40347b:	e8 00 e7 ff ff       	callq  401b80 <__cxa_throw@plt>
        if(a+1==argc) throw std::runtime_error("Missing option value");
  403480:	bf 10 00 00 00       	mov    $0x10,%edi
  403485:	e8 c6 e4 ff ff       	callq  401950 <__cxa_allocate_exception@plt>
  40348a:	be db 42 40 00       	mov    $0x4042db,%esi
  40348f:	48 89 c7             	mov    %rax,%rdi
  403492:	49 89 c4             	mov    %rax,%r12
  403495:	e8 76 e4 ff ff       	callq  401910 <std::runtime_error::runtime_error(char const*)@plt>
  40349a:	ba 00 1a 40 00       	mov    $0x401a00,%edx
  40349f:	be b0 4d 60 00       	mov    $0x604db0,%esi
  4034a4:	4c 89 e7             	mov    %r12,%rdi
  4034a7:	e8 d4 e6 ff ff       	callq  401b80 <__cxa_throw@plt>
    int iterations=100, warmup=10; float low=50, high=100, sigma=1.4f;
  4034ac:	f3 0f 10 3d 34 10 00 	movss  0x1034(%rip),%xmm7        # 4044e8 <__dso_handle+0x240>
  4034b3:	00 
  4034b4:	f3 0f 10 2d 24 10 00 	movss  0x1024(%rip),%xmm5        # 4044e0 <__dso_handle+0x238>
  4034bb:	00 
  4034bc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  4034c1:	c7 44 24 40 64 00 00 	movl   $0x64,0x40(%rsp)
  4034c8:	00 
  4034c9:	f3 0f 10 35 13 10 00 	movss  0x1013(%rip),%xmm6        # 4044e4 <__dso_handle+0x23c>
  4034d0:	00 
  4034d1:	f3 0f 10 05 17 10 00 	movss  0x1017(%rip),%xmm0        # 4044f0 <__dso_handle+0x248>
  4034d8:	00 
  4034d9:	f3 0f 11 7c 24 3c    	movss  %xmm7,0x3c(%rsp)
  4034df:	f3 0f 10 3d 39 10 00 	movss  0x1039(%rip),%xmm7        # 404520 <__dso_handle+0x278>
  4034e6:	00 
  4034e7:	f3 0f 11 2c 24       	movss  %xmm5,(%rsp)
  4034ec:	f3 0f 11 74 24 44    	movss  %xmm6,0x44(%rsp)
  4034f2:	0f 29 7c 24 60       	movaps %xmm7,0x60(%rsp)
  4034f7:	e9 24 ec ff ff       	jmpq   402120 <main+0x270>
    if(size_t(in.gcount())!=n) throw std::runtime_error("Truncated image");
  4034fc:	bf 10 00 00 00       	mov    $0x10,%edi
  403501:	e8 4a e4 ff ff       	callq  401950 <__cxa_allocate_exception@plt>
  403506:	be 7a 43 40 00       	mov    $0x40437a,%esi
  40350b:	48 89 c7             	mov    %rax,%rdi
  40350e:	49 89 c4             	mov    %rax,%r12
  403511:	e8 fa e3 ff ff       	callq  401910 <std::runtime_error::runtime_error(char const*)@plt>
  403516:	e9 48 e8 ff ff       	jmpq   401d63 <main.cold.119+0x13e>
  40351b:	48 89 c3             	mov    %rax,%rbx
  40351e:	48 89 d5             	mov    %rdx,%rbp
  403521:	e9 25 e7 ff ff       	jmpq   401c4b <main.cold.119+0x26>
  403526:	48 89 c3             	mov    %rax,%rbx
  403529:	48 89 d5             	mov    %rdx,%rbp
  40352c:	e9 b6 e7 ff ff       	jmpq   401ce7 <main.cold.119+0xc2>
  403531:	48 89 c3             	mov    %rax,%rbx
  403534:	48 89 d5             	mov    %rdx,%rbp
  403537:	e9 44 e8 ff ff       	jmpq   401d80 <main.cold.119+0x15b>
  40353c:	48 89 c3             	mov    %rax,%rbx
  40353f:	48 89 d5             	mov    %rdx,%rbp
  403542:	e9 a8 e7 ff ff       	jmpq   401cef <main.cold.119+0xca>
  403547:	48 89 c3             	mov    %rax,%rbx
  40354a:	48 89 d5             	mov    %rdx,%rbp
  40354d:	e9 5d e8 ff ff       	jmpq   401daf <main.cold.119+0x18a>
  403552:	48 89 c3             	mov    %rax,%rbx
  403555:	48 89 d5             	mov    %rdx,%rbp
  403558:	e9 5f e8 ff ff       	jmpq   401dbc <main.cold.119+0x197>
  40355d:	e9 78 e8 ff ff       	jmpq   401dda <main.cold.119+0x1b5>
  403562:	48 89 c3             	mov    %rax,%rbx
  403565:	48 89 d5             	mov    %rdx,%rbp
  403568:	e9 8d e8 ff ff       	jmpq   401dfa <main.cold.119+0x1d5>
  40356d:	48 89 c3             	mov    %rax,%rbx
  403570:	48 89 d5             	mov    %rdx,%rbp
  403573:	e9 44 e8 ff ff       	jmpq   401dbc <main.cold.119+0x197>
  403578:	e9 27 e8 ff ff       	jmpq   401da4 <main.cold.119+0x17f>
  40357d:	48 89 c3             	mov    %rax,%rbx
  403580:	48 89 d5             	mov    %rdx,%rbp
  403583:	e9 a6 e8 ff ff       	jmpq   401e2e <main.cold.119+0x209>
  403588:	e9 e8 e7 ff ff       	jmpq   401d75 <main.cold.119+0x150>
  40358d:	48 89 c3             	mov    %rax,%rbx
  403590:	48 89 d5             	mov    %rdx,%rbp
  403593:	e9 1f e7 ff ff       	jmpq   401cb7 <main.cold.119+0x92>
  403598:	48 89 c3             	mov    %rax,%rbx
  40359b:	48 89 d5             	mov    %rdx,%rbp
  40359e:	e9 26 e7 ff ff       	jmpq   401cc9 <main.cold.119+0xa4>
  4035a3:	48 89 c3             	mov    %rax,%rbx
  4035a6:	48 89 d5             	mov    %rdx,%rbp
  4035a9:	e9 d3 e6 ff ff       	jmpq   401c81 <main.cold.119+0x5c>
  4035ae:	48 89 c3             	mov    %rax,%rbx
  4035b1:	48 89 d5             	mov    %rdx,%rbp
  4035b4:	e9 da e6 ff ff       	jmpq   401c93 <main.cold.119+0x6e>
  4035b9:	48 89 c3             	mov    %rax,%rbx
  4035bc:	48 89 d5             	mov    %rdx,%rbp
  4035bf:	e9 eb e7 ff ff       	jmpq   401daf <main.cold.119+0x18a>
  4035c4:	48 89 c3             	mov    %rax,%rbx
  4035c7:	48 89 d5             	mov    %rdx,%rbp
  4035ca:	e9 7e e8 ff ff       	jmpq   401e4d <main.cold.119+0x228>
  4035cf:	48 89 c3             	mov    %rax,%rbx
  4035d2:	48 89 d5             	mov    %rdx,%rbp
  4035d5:	e9 8e e8 ff ff       	jmpq   401e68 <main.cold.119+0x243>
  4035da:	48 89 c3             	mov    %rax,%rbx
  4035dd:	48 89 d5             	mov    %rdx,%rbp
  4035e0:	e9 8a e6 ff ff       	jmpq   401c6f <main.cold.119+0x4a>
  4035e5:	e9 3c e6 ff ff       	jmpq   401c26 <main.cold.119+0x1>
  4035ea:	48 89 c3             	mov    %rax,%rbx
  4035ed:	48 89 d5             	mov    %rdx,%rbp
  4035f0:	e9 44 e6 ff ff       	jmpq   401c39 <main.cold.119+0x14>
  4035f5:	48 89 c3             	mov    %rax,%rbx
  4035f8:	48 89 d5             	mov    %rdx,%rbp
  4035fb:	e9 99 e8 ff ff       	jmpq   401e99 <main.cold.119+0x274>

0000000000403600 <_GLOBAL__sub_I_main>:
} catch(const std::exception& e) {std::cerr<<e.what()<<"\n";return 1;}
  403600:	48 83 ec 08          	sub    $0x8,%rsp
  extern wostream wclog;	/// Linked to standard error (buffered)
#endif
  //@}

  // For construction of filebuffers for cout, cin, cerr, clog et. al.
  static ios_base::Init __ioinit;
  403604:	bf f1 53 60 00       	mov    $0x6053f1,%edi
  403609:	e8 e2 e4 ff ff       	callq  401af0 <std::ios_base::Init::Init()@plt>
  40360e:	ba a8 42 40 00       	mov    $0x4042a8,%edx
  403613:	be f1 53 60 00       	mov    $0x6053f1,%esi
  403618:	bf e0 1b 40 00       	mov    $0x401be0,%edi
  40361d:	48 83 c4 08          	add    $0x8,%rsp
  403621:	e9 9a e3 ff ff       	jmpq   4019c0 <__cxa_atexit@plt>

0000000000403626 <.annobin_elf_init.c.hot>:
  403626:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  40362d:	00 00 00 

0000000000403630 <_start>:
  403630:	f3 0f 1e fa          	endbr64 
  403634:	31 ed                	xor    %ebp,%ebp
  403636:	49 89 d1             	mov    %rdx,%r9
  403639:	5e                   	pop    %rsi
  40363a:	48 89 e2             	mov    %rsp,%rdx
  40363d:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
  403641:	50                   	push   %rax
  403642:	54                   	push   %rsp
  403643:	49 c7 c0 80 42 40 00 	mov    $0x404280,%r8
  40364a:	48 c7 c1 10 42 40 00 	mov    $0x404210,%rcx
  403651:	48 c7 c7 b0 1e 40 00 	mov    $0x401eb0,%rdi
  403658:	ff 15 72 19 20 00    	callq  *0x201972(%rip)        # 604fd0 <__libc_start_main@GLIBC_2.2.5>
  40365e:	f4                   	hlt    

000000000040365f <.annobin_init.c>:
  40365f:	90                   	nop

0000000000403660 <_dl_relocate_static_pie>:
  403660:	f3 0f 1e fa          	endbr64 
  403664:	c3                   	retq   

0000000000403665 <.annobin__dl_relocate_static_pie.end>:
  403665:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  40366c:	00 00 00 
  40366f:	90                   	nop

0000000000403670 <deregister_tm_clones>:
  403670:	48 8d 3d 39 1b 20 00 	lea    0x201b39(%rip),%rdi        # 6051b0 <__TMC_END__>
  403677:	48 8d 05 32 1b 20 00 	lea    0x201b32(%rip),%rax        # 6051b0 <__TMC_END__>
  40367e:	48 39 f8             	cmp    %rdi,%rax
  403681:	74 15                	je     403698 <deregister_tm_clones+0x28>
  403683:	48 8b 05 3e 19 20 00 	mov    0x20193e(%rip),%rax        # 604fc8 <_ITM_deregisterTMCloneTable@Base>
  40368a:	48 85 c0             	test   %rax,%rax
  40368d:	74 09                	je     403698 <deregister_tm_clones+0x28>
  40368f:	ff e0                	jmpq   *%rax
  403691:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  403698:	c3                   	retq   
  403699:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

00000000004036a0 <register_tm_clones>:
  4036a0:	48 8d 3d 09 1b 20 00 	lea    0x201b09(%rip),%rdi        # 6051b0 <__TMC_END__>
  4036a7:	48 8d 35 02 1b 20 00 	lea    0x201b02(%rip),%rsi        # 6051b0 <__TMC_END__>
  4036ae:	48 29 fe             	sub    %rdi,%rsi
  4036b1:	48 c1 fe 03          	sar    $0x3,%rsi
  4036b5:	48 89 f0             	mov    %rsi,%rax
  4036b8:	48 c1 e8 3f          	shr    $0x3f,%rax
  4036bc:	48 01 c6             	add    %rax,%rsi
  4036bf:	48 d1 fe             	sar    %rsi
  4036c2:	74 14                	je     4036d8 <register_tm_clones+0x38>
  4036c4:	48 8b 05 15 19 20 00 	mov    0x201915(%rip),%rax        # 604fe0 <_ITM_registerTMCloneTable@Base>
  4036cb:	48 85 c0             	test   %rax,%rax
  4036ce:	74 08                	je     4036d8 <register_tm_clones+0x38>
  4036d0:	ff e0                	jmpq   *%rax
  4036d2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  4036d8:	c3                   	retq   
  4036d9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

00000000004036e0 <__do_global_dtors_aux>:
  4036e0:	f3 0f 1e fa          	endbr64 
  4036e4:	80 3d 05 1d 20 00 00 	cmpb   $0x0,0x201d05(%rip)        # 6053f0 <completed.7303>
  4036eb:	75 13                	jne    403700 <__do_global_dtors_aux+0x20>
  4036ed:	55                   	push   %rbp
  4036ee:	48 89 e5             	mov    %rsp,%rbp
  4036f1:	e8 7a ff ff ff       	callq  403670 <deregister_tm_clones>
  4036f6:	c6 05 f3 1c 20 00 01 	movb   $0x1,0x201cf3(%rip)        # 6053f0 <completed.7303>
  4036fd:	5d                   	pop    %rbp
  4036fe:	c3                   	retq   
  4036ff:	90                   	nop
  403700:	c3                   	retq   
  403701:	66 66 2e 0f 1f 84 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  403708:	00 00 00 00 
  40370c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000403710 <frame_dummy>:
  403710:	f3 0f 1e fa          	endbr64 
  403714:	eb 8a                	jmp    4036a0 <register_tm_clones>
  403716:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  40371d:	00 00 00 

0000000000403720 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long) [clone .isra.77]>:
    basic_string<_CharT, _Traits, _Alloc>::
    _M_create(size_type& __capacity, size_type __old_capacity)
    {
      // _GLIBCXX_RESOLVE_LIB_DEFECTS
      // 83.  String::npos vs. string::max_size()
      if (__capacity > max_size())
  403720:	48 8b 07             	mov    (%rdi),%rax
  403723:	48 85 c0             	test   %rax,%rax
  403726:	78 54                	js     40377c <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long) [clone .isra.77]+0x5c>
	std::__throw_length_error(__N("basic_string::_M_create"));

      // The below implements an exponential growth policy, necessary to
      // meet amortized linear time requirements of the library: see
      // http://gcc.gnu.org/ml/libstdc++/2001-07/msg00085.html.
      if (__capacity > __old_capacity && __capacity < 2 * __old_capacity)
  403728:	48 39 f0             	cmp    %rsi,%rax
  40372b:	76 23                	jbe    403750 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long) [clone .isra.77]+0x30>
  40372d:	48 01 f6             	add    %rsi,%rsi
  403730:	48 39 f0             	cmp    %rsi,%rax
  403733:	73 1b                	jae    403750 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long) [clone .isra.77]+0x30>
	{
	  __capacity = 2 * __old_capacity;
	  // Never allocate a string bigger than max_size.
	  if (__capacity > max_size())
  403735:	48 85 f6             	test   %rsi,%rsi
  403738:	78 26                	js     403760 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long) [clone .isra.77]+0x40>
	  __capacity = 2 * __old_capacity;
  40373a:	48 89 37             	mov    %rsi,(%rdi)
  40373d:	48 8d 7e 01          	lea    0x1(%rsi),%rdi
	return static_cast<_Tp*>(::operator new(__n * sizeof(_Tp)));
  403741:	e9 aa e2 ff ff       	jmpq   4019f0 <operator new(unsigned long)@plt>
  403746:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  40374d:	00 00 00 
  403750:	48 8d 78 01          	lea    0x1(%rax),%rdi
  403754:	e9 97 e2 ff ff       	jmpq   4019f0 <operator new(unsigned long)@plt>
  403759:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
	    __capacity = max_size();
  403760:	48 b8 ff ff ff ff ff 	movabs $0x7fffffffffffffff,%rax
  403767:	ff ff 7f 
  40376a:	48 89 07             	mov    %rax,(%rdi)
  40376d:	48 bf 00 00 00 00 00 	movabs $0x8000000000000000,%rdi
  403774:	00 00 80 
  403777:	e9 74 e2 ff ff       	jmpq   4019f0 <operator new(unsigned long)@plt>
    basic_string<_CharT, _Traits, _Alloc>::
  40377c:	50                   	push   %rax
	std::__throw_length_error(__N("basic_string::_M_create"));
  40377d:	bf b0 42 40 00       	mov    $0x4042b0,%edi
  403782:	e8 d9 e1 ff ff       	callq  401960 <std::__throw_length_error(char const*)@plt>
  403787:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  40378e:	00 00 

0000000000403790 <token(std::istream&)>:
static std::string token(std::istream& in) {
  403790:	41 55                	push   %r13
	return std::pointer_traits<pointer>::pointer_to(*_M_local_buf);
  403792:	4c 8d 6f 10          	lea    0x10(%rdi),%r13
  403796:	41 54                	push   %r12
  403798:	49 89 fc             	mov    %rdi,%r12
  40379b:	55                   	push   %rbp
  40379c:	48 89 f5             	mov    %rsi,%rbp
  40379f:	53                   	push   %rbx
  4037a0:	48 83 ec 08          	sub    $0x8,%rsp
	: allocator_type(std::move(__a)), _M_p(__dat) { }
  4037a4:	4c 89 2f             	mov    %r13,(%rdi)
      { _M_string_length = __length; }
  4037a7:	48 c7 47 08 00 00 00 	movq   $0x0,0x8(%rdi)
  4037ae:	00 
      { __c1 = __c2; }
  4037af:	c6 47 10 00          	movb   $0x0,0x10(%rdi)
  4037b3:	eb 12                	jmp    4037c7 <token(std::istream&)+0x37>
  4037b5:	0f 1f 00             	nopl   (%rax)
      */
      char_type
      widen(char __c) const
      {
	if (_M_widen_ok)
	  return _M_widen[static_cast<unsigned char>(__c)];
  4037b8:	0f be 53 43          	movsbl 0x43(%rbx),%edx
    { return std::getline(__is, __str, __is.widen('\n')); }
  4037bc:	4c 89 e6             	mov    %r12,%rsi
  4037bf:	48 89 ef             	mov    %rbp,%rdi
  4037c2:	e8 f9 e3 ff ff       	callq  401bc0 <std::basic_istream<char, std::char_traits<char> >& std::getline<char, std::char_traits<char>, std::allocator<char> >(std::basic_istream<char, std::char_traits<char> >&, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >&, char)@plt>
    while(in >> s) { if(s[0]!='#') return s; std::getline(in,s); }
  4037c7:	4c 89 e6             	mov    %r12,%rsi
  4037ca:	48 89 ef             	mov    %rbp,%rdi
  4037cd:	e8 8e e2 ff ff       	callq  401a60 <std::basic_istream<char, std::char_traits<char> >& std::operator>><char, std::char_traits<char>, std::allocator<char> >(std::basic_istream<char, std::char_traits<char> >&, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >&)@plt>
  4037d2:	48 8b 10             	mov    (%rax),%rdx
       *  Checking the badbit in fail() is historical practice.
       *  Note that other iostate flags may also be set.
      */
      bool
      fail() const
      { return (this->rdstate() & (badbit | failbit)) != 0; }
  4037d5:	48 8b 52 e8          	mov    -0x18(%rdx),%rdx
  4037d9:	f6 44 10 20 05       	testb  $0x5,0x20(%rax,%rdx,1)
  4037de:	75 5e                	jne    40383e <token(std::istream&)+0xae>
  4037e0:	49 8b 04 24          	mov    (%r12),%rax
  4037e4:	80 38 23             	cmpb   $0x23,(%rax)
  4037e7:	75 47                	jne    403830 <token(std::istream&)+0xa0>
  4037e9:	48 8b 45 00          	mov    0x0(%rbp),%rax
       *  Additional l10n notes are at
       *  http://gcc.gnu.org/onlinedocs/libstdc++/manual/localization.html
      */
      char_type
      widen(char __c) const
      { return __check_facet(_M_ctype).widen(__c); }
  4037ed:	48 8b 40 e8          	mov    -0x18(%rax),%rax
  4037f1:	48 8b 9c 05 f0 00 00 	mov    0xf0(%rbp,%rax,1),%rbx
  4037f8:	00 
      if (!__f)
  4037f9:	48 85 db             	test   %rbx,%rbx
  4037fc:	74 5f                	je     40385d <token(std::istream&)+0xcd>
	if (_M_widen_ok)
  4037fe:	80 7b 38 00          	cmpb   $0x0,0x38(%rbx)
  403802:	75 b4                	jne    4037b8 <token(std::istream&)+0x28>
	this->_M_widen_init();
  403804:	48 89 df             	mov    %rbx,%rdi
  403807:	e8 14 e2 ff ff       	callq  401a20 <std::ctype<char>::_M_widen_init() const@plt>
	return this->do_widen(__c);
  40380c:	48 8b 03             	mov    (%rbx),%rax
  40380f:	ba 0a 00 00 00       	mov    $0xa,%edx
  403814:	48 8b 40 30          	mov    0x30(%rax),%rax
  403818:	48 3d 70 38 40 00    	cmp    $0x403870,%rax
  40381e:	74 9c                	je     4037bc <token(std::istream&)+0x2c>
  403820:	be 0a 00 00 00       	mov    $0xa,%esi
  403825:	48 89 df             	mov    %rbx,%rdi
  403828:	ff d0                	callq  *%rax
  40382a:	0f be d0             	movsbl %al,%edx
  40382d:	eb 8d                	jmp    4037bc <token(std::istream&)+0x2c>
  40382f:	90                   	nop
}
  403830:	48 83 c4 08          	add    $0x8,%rsp
  403834:	4c 89 e0             	mov    %r12,%rax
  403837:	5b                   	pop    %rbx
  403838:	5d                   	pop    %rbp
  403839:	41 5c                	pop    %r12
  40383b:	41 5d                	pop    %r13
  40383d:	c3                   	retq   
    throw std::runtime_error("Invalid PGM header");
  40383e:	bf 10 00 00 00       	mov    $0x10,%edi
  403843:	e8 08 e1 ff ff       	callq  401950 <__cxa_allocate_exception@plt>
  403848:	be c8 42 40 00       	mov    $0x4042c8,%esi
  40384d:	48 89 c7             	mov    %rax,%rdi
  403850:	48 89 c5             	mov    %rax,%rbp
  403853:	e8 b8 e0 ff ff       	callq  401910 <std::runtime_error::runtime_error(char const*)@plt>
  403858:	e9 93 e3 ff ff       	jmpq   401bf0 <token(std::istream&) [clone .cold.118]>
	__throw_bad_cast();
  40385d:	e8 ee e1 ff ff       	callq  401a50 <std::__throw_bad_cast()@plt>
  403862:	e9 9b e3 ff ff       	jmpq   401c02 <token(std::istream&) [clone .cold.118]+0x12>
  403867:	48 89 c3             	mov    %rax,%rbx
  40386a:	e9 98 e3 ff ff       	jmpq   401c07 <token(std::istream&) [clone .cold.118]+0x17>
  40386f:	90                   	nop

0000000000403870 <std::ctype<char>::do_widen(char) const>:
       *  @param __c  The char to convert.
       *  @return  The converted character.
      */
      virtual char_type
      do_widen(char __c) const
      { return __c; }
  403870:	89 f0                	mov    %esi,%eax
  403872:	c3                   	retq   
  403873:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  40387a:	00 00 00 
  40387d:	0f 1f 00             	nopl   (%rax)

0000000000403880 <std::char_traits<char>::length(char const*)>:
	return __builtin_strlen(__s);
  403880:	e9 ab e0 ff ff       	jmpq   401930 <strlen@plt>
  403885:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  40388c:	00 00 00 
  40388f:	90                   	nop

0000000000403890 <int __gnu_cxx::__stoa<long, int, char, int>(long (*)(char const*, char**, int), char const*, char const*, unsigned long*, int)>:

  // Helper for all the sto* functions.
  template<typename _TRet, typename _Ret = _TRet, typename _CharT,
	   typename... _Base>
    _Ret
    __stoa(_TRet (*__convf) (const _CharT*, _CharT**, _Base...),
  403890:	41 57                	push   %r15
  403892:	49 89 ff             	mov    %rdi,%r15
  403895:	41 56                	push   %r14
  403897:	45 89 c6             	mov    %r8d,%r14d
  40389a:	41 55                	push   %r13
  40389c:	41 54                	push   %r12
  40389e:	49 89 cc             	mov    %rcx,%r12
  4038a1:	55                   	push   %rbp
  4038a2:	48 89 d5             	mov    %rdx,%rbp
  4038a5:	53                   	push   %rbx
  4038a6:	48 83 ec 28          	sub    $0x28,%rsp
  4038aa:	48 89 74 24 08       	mov    %rsi,0x8(%rsp)
      _Ret __ret;

      _CharT* __endptr;

      struct _Save_errno {
	_Save_errno() : _M_errno(errno) { errno = 0; }
  4038af:	e8 1c e0 ff ff       	callq  4018d0 <__errno_location@plt>
	    return __val < _TRet(__numeric_traits<int>::__min)
	      || __val > _TRet(__numeric_traits<int>::__max);
	  }
      };

      const _TRet __tmp = __convf(__str, &__endptr, __base...);
  4038b4:	44 89 f2             	mov    %r14d,%edx
  4038b7:	48 8d 74 24 18       	lea    0x18(%rsp),%rsi
  4038bc:	48 89 ef             	mov    %rbp,%rdi
	_Save_errno() : _M_errno(errno) { errno = 0; }
  4038bf:	44 8b 28             	mov    (%rax),%r13d
  4038c2:	48 89 c3             	mov    %rax,%rbx
  4038c5:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
      const _TRet __tmp = __convf(__str, &__endptr, __base...);
  4038cb:	41 ff d7             	callq  *%r15

      if (__endptr == __str)
  4038ce:	48 8b 54 24 18       	mov    0x18(%rsp),%rdx
  4038d3:	48 39 ea             	cmp    %rbp,%rdx
  4038d6:	74 45                	je     40391d <int __gnu_cxx::__stoa<long, int, char, int>(long (*)(char const*, char**, int), char const*, char const*, unsigned long*, int)+0x8d>
	std::__throw_invalid_argument(__name);
      else if (errno == ERANGE
  4038d8:	8b 33                	mov    (%rbx),%esi
	  || _Range_chk::_S_chk(__tmp, std::is_same<_Ret, int>{}))
  4038da:	83 fe 22             	cmp    $0x22,%esi
  4038dd:	74 34                	je     403913 <int __gnu_cxx::__stoa<long, int, char, int>(long (*)(char const*, char**, int), char const*, char const*, unsigned long*, int)+0x83>
	      || __val > _TRet(__numeric_traits<int>::__max);
  4038df:	b9 00 00 00 80       	mov    $0x80000000,%ecx
	  || _Range_chk::_S_chk(__tmp, std::is_same<_Ret, int>{}))
  4038e4:	bf ff ff ff ff       	mov    $0xffffffff,%edi
	      || __val > _TRet(__numeric_traits<int>::__max);
  4038e9:	48 01 c1             	add    %rax,%rcx
	  || _Range_chk::_S_chk(__tmp, std::is_same<_Ret, int>{}))
  4038ec:	48 39 f9             	cmp    %rdi,%rcx
  4038ef:	77 22                	ja     403913 <int __gnu_cxx::__stoa<long, int, char, int>(long (*)(char const*, char**, int), char const*, char const*, unsigned long*, int)+0x83>
	std::__throw_out_of_range(__name);
      else
	__ret = __tmp;

      if (__idx)
  4038f1:	4d 85 e4             	test   %r12,%r12
  4038f4:	74 07                	je     4038fd <int __gnu_cxx::__stoa<long, int, char, int>(long (*)(char const*, char**, int), char const*, char const*, unsigned long*, int)+0x6d>
	*__idx = __endptr - __str;
  4038f6:	48 29 ea             	sub    %rbp,%rdx
  4038f9:	49 89 14 24          	mov    %rdx,(%r12)
	~_Save_errno() { if (errno == 0) errno = _M_errno; }
  4038fd:	85 f6                	test   %esi,%esi
  4038ff:	75 03                	jne    403904 <int __gnu_cxx::__stoa<long, int, char, int>(long (*)(char const*, char**, int), char const*, char const*, unsigned long*, int)+0x74>
  403901:	44 89 2b             	mov    %r13d,(%rbx)

      return __ret;
    }
  403904:	48 83 c4 28          	add    $0x28,%rsp
  403908:	5b                   	pop    %rbx
  403909:	5d                   	pop    %rbp
  40390a:	41 5c                	pop    %r12
  40390c:	41 5d                	pop    %r13
  40390e:	41 5e                	pop    %r14
  403910:	41 5f                	pop    %r15
  403912:	c3                   	retq   
	std::__throw_out_of_range(__name);
  403913:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  403918:	e8 b3 e1 ff ff       	callq  401ad0 <std::__throw_out_of_range(char const*)@plt>
	std::__throw_invalid_argument(__name);
  40391d:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  403922:	e8 59 e0 ff ff       	callq  401980 <std::__throw_invalid_argument(char const*)@plt>
	~_Save_errno() { if (errno == 0) errno = _M_errno; }
  403927:	83 3b 00             	cmpl   $0x0,(%rbx)
  40392a:	75 03                	jne    40392f <int __gnu_cxx::__stoa<long, int, char, int>(long (*)(char const*, char**, int), char const*, char const*, unsigned long*, int)+0x9f>
  40392c:	44 89 2b             	mov    %r13d,(%rbx)
  40392f:	48 89 c7             	mov    %rax,%rdi
  403932:	e8 69 e2 ff ff       	callq  401ba0 <_Unwind_Resume@plt>
  403937:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  40393e:	00 00 

0000000000403940 <float __gnu_cxx::__stoa<float, float, char>(float (*)(char const*, char**), char const*, char const*, unsigned long*)>:
    __stoa(_TRet (*__convf) (const _CharT*, _CharT**, _Base...),
  403940:	41 57                	push   %r15
  403942:	49 89 ff             	mov    %rdi,%r15
  403945:	41 56                	push   %r14
  403947:	49 89 f6             	mov    %rsi,%r14
  40394a:	41 55                	push   %r13
  40394c:	41 54                	push   %r12
  40394e:	49 89 cc             	mov    %rcx,%r12
  403951:	55                   	push   %rbp
  403952:	48 89 d5             	mov    %rdx,%rbp
  403955:	53                   	push   %rbx
  403956:	48 83 ec 18          	sub    $0x18,%rsp
	_Save_errno() : _M_errno(errno) { errno = 0; }
  40395a:	e8 71 df ff ff       	callq  4018d0 <__errno_location@plt>
      const _TRet __tmp = __convf(__str, &__endptr, __base...);
  40395f:	48 8d 74 24 08       	lea    0x8(%rsp),%rsi
  403964:	48 89 ef             	mov    %rbp,%rdi
	_Save_errno() : _M_errno(errno) { errno = 0; }
  403967:	44 8b 28             	mov    (%rax),%r13d
  40396a:	48 89 c3             	mov    %rax,%rbx
  40396d:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
      const _TRet __tmp = __convf(__str, &__endptr, __base...);
  403973:	41 ff d7             	callq  *%r15
      if (__endptr == __str)
  403976:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
  40397b:	48 39 e8             	cmp    %rbp,%rax
  40397e:	74 31                	je     4039b1 <float __gnu_cxx::__stoa<float, float, char>(float (*)(char const*, char**), char const*, char const*, unsigned long*)+0x71>
      else if (errno == ERANGE
  403980:	8b 13                	mov    (%rbx),%edx
	  || _Range_chk::_S_chk(__tmp, std::is_same<_Ret, int>{}))
  403982:	83 fa 22             	cmp    $0x22,%edx
  403985:	74 22                	je     4039a9 <float __gnu_cxx::__stoa<float, float, char>(float (*)(char const*, char**), char const*, char const*, unsigned long*)+0x69>
      if (__idx)
  403987:	4d 85 e4             	test   %r12,%r12
  40398a:	74 07                	je     403993 <float __gnu_cxx::__stoa<float, float, char>(float (*)(char const*, char**), char const*, char const*, unsigned long*)+0x53>
	*__idx = __endptr - __str;
  40398c:	48 29 e8             	sub    %rbp,%rax
  40398f:	49 89 04 24          	mov    %rax,(%r12)
	~_Save_errno() { if (errno == 0) errno = _M_errno; }
  403993:	85 d2                	test   %edx,%edx
  403995:	75 03                	jne    40399a <float __gnu_cxx::__stoa<float, float, char>(float (*)(char const*, char**), char const*, char const*, unsigned long*)+0x5a>
  403997:	44 89 2b             	mov    %r13d,(%rbx)
    }
  40399a:	48 83 c4 18          	add    $0x18,%rsp
  40399e:	5b                   	pop    %rbx
  40399f:	5d                   	pop    %rbp
  4039a0:	41 5c                	pop    %r12
  4039a2:	41 5d                	pop    %r13
  4039a4:	41 5e                	pop    %r14
  4039a6:	41 5f                	pop    %r15
  4039a8:	c3                   	retq   
	std::__throw_out_of_range(__name);
  4039a9:	4c 89 f7             	mov    %r14,%rdi
  4039ac:	e8 1f e1 ff ff       	callq  401ad0 <std::__throw_out_of_range(char const*)@plt>
	std::__throw_invalid_argument(__name);
  4039b1:	4c 89 f7             	mov    %r14,%rdi
  4039b4:	e8 c7 df ff ff       	callq  401980 <std::__throw_invalid_argument(char const*)@plt>
	~_Save_errno() { if (errno == 0) errno = _M_errno; }
  4039b9:	83 3b 00             	cmpl   $0x0,(%rbx)
  4039bc:	75 03                	jne    4039c1 <float __gnu_cxx::__stoa<float, float, char>(float (*)(char const*, char**), char const*, char const*, unsigned long*)+0x81>
  4039be:	44 89 2b             	mov    %r13d,(%rbx)
  4039c1:	48 89 c7             	mov    %rax,%rdi
  4039c4:	e8 d7 e1 ff ff       	callq  401ba0 <_Unwind_Resume@plt>
  4039c9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

00000000004039d0 <std::vector<unsigned char, std::allocator<unsigned char> >::vector(unsigned long, std::allocator<unsigned char> const&)>:
      vector(size_type __n, const allocator_type& __a = allocator_type())
  4039d0:	41 54                	push   %r12
  4039d2:	45 31 e4             	xor    %r12d,%r12d
  4039d5:	55                   	push   %rbp
  4039d6:	53                   	push   %rbx
  4039d7:	48 89 fb             	mov    %rdi,%rbx
	: _Tp_alloc_type(__a), _M_start(), _M_finish(), _M_end_of_storage()
  4039da:	48 c7 07 00 00 00 00 	movq   $0x0,(%rdi)
  4039e1:	48 c7 47 08 00 00 00 	movq   $0x0,0x8(%rdi)
  4039e8:	00 
  4039e9:	48 c7 47 10 00 00 00 	movq   $0x0,0x10(%rdi)
  4039f0:	00 
	return __n != 0 ? _Tr::allocate(_M_impl, __n) : pointer();
  4039f1:	48 85 f6             	test   %rsi,%rsi
  4039f4:	74 23                	je     403a19 <std::vector<unsigned char, std::allocator<unsigned char> >::vector(unsigned long, std::allocator<unsigned char> const&)+0x49>
  4039f6:	48 89 f7             	mov    %rsi,%rdi
  4039f9:	48 89 f5             	mov    %rsi,%rbp
  4039fc:	e8 ef df ff ff       	callq  4019f0 <operator new(unsigned long)@plt>
    __gnu_cxx::__enable_if<__is_byte<_Tp>::__value, void>::__type
    __fill_a(_Tp* __first, _Tp* __last, const _Tp& __c)
    {
      const _Tp __tmp = __c;
      if (const size_t __len = __last - __first)
	__builtin_memset(__first, static_cast<unsigned char>(__tmp), __len);
  403a01:	48 89 ea             	mov    %rbp,%rdx
  403a04:	31 f6                	xor    %esi,%esi
	this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
  403a06:	4c 8d 24 28          	lea    (%rax,%rbp,1),%r12
	this->_M_impl._M_start = this->_M_allocate(__n);
  403a0a:	48 89 03             	mov    %rax,(%rbx)
  403a0d:	48 89 c7             	mov    %rax,%rdi
	this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
  403a10:	4c 89 63 10          	mov    %r12,0x10(%rbx)
  403a14:	e8 57 df ff ff       	callq  401970 <memset@plt>
	this->_M_impl._M_finish =
  403a19:	4c 89 63 08          	mov    %r12,0x8(%rbx)
      { _M_default_initialize(__n); }
  403a1d:	5b                   	pop    %rbx
  403a1e:	5d                   	pop    %rbp
  403a1f:	41 5c                	pop    %r12
  403a21:	c3                   	retq   
  403a22:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  403a29:	00 00 00 
  403a2c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000403a30 <std::vector<float, std::allocator<float> >::vector(unsigned long, std::allocator<float> const&)>:
      vector(size_type __n, const allocator_type& __a = allocator_type())
  403a30:	41 54                	push   %r12
  403a32:	55                   	push   %rbp
  403a33:	48 89 fd             	mov    %rdi,%rbp
  403a36:	53                   	push   %rbx
	: _Tp_alloc_type(__a), _M_start(), _M_finish(), _M_end_of_storage()
  403a37:	48 c7 07 00 00 00 00 	movq   $0x0,(%rdi)
  403a3e:	48 c7 47 08 00 00 00 	movq   $0x0,0x8(%rdi)
  403a45:	00 
  403a46:	48 c7 47 10 00 00 00 	movq   $0x0,0x10(%rdi)
  403a4d:	00 
	return __n != 0 ? _Tr::allocate(_M_impl, __n) : pointer();
  403a4e:	48 85 f6             	test   %rsi,%rsi
  403a51:	74 55                	je     403aa8 <std::vector<float, std::allocator<float> >::vector(unsigned long, std::allocator<float> const&)+0x78>
	if (__n > this->max_size())
  403a53:	48 b8 ff ff ff ff ff 	movabs $0x3fffffffffffffff,%rax
  403a5a:	ff ff 3f 
  403a5d:	48 89 f3             	mov    %rsi,%rbx
  403a60:	48 39 c6             	cmp    %rax,%rsi
  403a63:	77 4e                	ja     403ab3 <std::vector<float, std::allocator<float> >::vector(unsigned long, std::allocator<float> const&)+0x83>
	return static_cast<_Tp*>(::operator new(__n * sizeof(_Tp)));
  403a65:	4c 8d 24 b5 00 00 00 	lea    0x0(,%rsi,4),%r12
  403a6c:	00 
  403a6d:	4c 89 e7             	mov    %r12,%rdi
  403a70:	e8 7b df ff ff       	callq  4019f0 <operator new(unsigned long)@plt>
	this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
  403a75:	31 d2                	xor    %edx,%edx
  403a77:	4a 8d 3c 20          	lea    (%rax,%r12,1),%rdi
	this->_M_impl._M_start = this->_M_allocate(__n);
  403a7b:	48 89 45 00          	mov    %rax,0x0(%rbp)
	this->_M_impl._M_end_of_storage = this->_M_impl._M_start + __n;
  403a7f:	48 89 7d 10          	mov    %rdi,0x10(%rbp)
    __gnu_cxx::__enable_if<__is_scalar<_Tp>::__value, _OutputIterator>::__type
    __fill_n_a(_OutputIterator __first, _Size __n, const _Tp& __value)
    {
      const _Tp __tmp = __value;
      for (__decltype(__n + 0) __niter = __n;
	   __niter > 0; --__niter, (void) ++__first)
  403a83:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
	*__first = __tmp;
  403a88:	c7 04 90 00 00 00 00 	movl   $0x0,(%rax,%rdx,4)
	   __niter > 0; --__niter, (void) ++__first)
  403a8f:	48 83 c2 01          	add    $0x1,%rdx
  403a93:	48 39 d3             	cmp    %rdx,%rbx
  403a96:	75 f0                	jne    403a88 <std::vector<float, std::allocator<float> >::vector(unsigned long, std::allocator<float> const&)+0x58>
      { _M_default_initialize(__n); }
  403a98:	5b                   	pop    %rbx
	this->_M_impl._M_finish =
  403a99:	48 89 7d 08          	mov    %rdi,0x8(%rbp)
      { _M_default_initialize(__n); }
  403a9d:	5d                   	pop    %rbp
  403a9e:	41 5c                	pop    %r12
  403aa0:	c3                   	retq   
  403aa1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
	return __n != 0 ? _Tr::allocate(_M_impl, __n) : pointer();
  403aa8:	31 ff                	xor    %edi,%edi
      { _M_default_initialize(__n); }
  403aaa:	5b                   	pop    %rbx
	this->_M_impl._M_finish =
  403aab:	48 89 7d 08          	mov    %rdi,0x8(%rbp)
      { _M_default_initialize(__n); }
  403aaf:	5d                   	pop    %rbp
  403ab0:	41 5c                	pop    %r12
  403ab2:	c3                   	retq   
	  std::__throw_bad_alloc();
  403ab3:	e8 38 de ff ff       	callq  4018f0 <std::__throw_bad_alloc()@plt>
  403ab8:	0f 1f 84 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  403abf:	00 

0000000000403ac0 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)>:

#if __cplusplus >= 201103L
  template<typename _Tp, typename _Alloc>
    template<typename... _Args>
      void
      vector<_Tp, _Alloc>::
  403ac0:	41 57                	push   %r15
  403ac2:	49 89 d7             	mov    %rdx,%r15
  403ac5:	48 89 f2             	mov    %rsi,%rdx
  403ac8:	41 56                	push   %r14
  403aca:	41 55                	push   %r13
  403acc:	41 54                	push   %r12
  403ace:	49 89 f4             	mov    %rsi,%r12
  403ad1:	55                   	push   %rbp
  403ad2:	53                   	push   %rbx
  403ad3:	48 89 fb             	mov    %rdi,%rbx
  403ad6:	48 83 ec 28          	sub    $0x28,%rsp
	if (max_size() - size() < __n)
  403ada:	48 8b 4f 08          	mov    0x8(%rdi),%rcx
  403ade:	48 8b 2f             	mov    (%rdi),%rbp
      { return size_type(this->_M_impl._M_finish - this->_M_impl._M_start); }
  403ae1:	48 89 c8             	mov    %rcx,%rax
  403ae4:	48 29 ea             	sub    %rbp,%rdx
  403ae7:	48 29 e8             	sub    %rbp,%rax
      if (__a < __b)
  403aea:	48 c1 f8 03          	sar    $0x3,%rax
  403aee:	0f 84 fc 00 00 00    	je     403bf0 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)+0x130>
	const size_type __len = size() + std::max(size(), __n);
  403af4:	48 8d 3c 00          	lea    (%rax,%rax,1),%rdi
	return (__len < size() || __len > max_size()) ? max_size() : __len;
  403af8:	49 c7 c6 f8 ff ff ff 	mov    $0xfffffffffffffff8,%r14
  403aff:	48 39 f8             	cmp    %rdi,%rax
  403b02:	0f 86 b0 00 00 00    	jbe    403bb8 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)+0xf8>
	return static_cast<_Tp*>(::operator new(__n * sizeof(_Tp)));
  403b08:	4c 89 f7             	mov    %r14,%rdi
  403b0b:	48 89 54 24 10       	mov    %rdx,0x10(%rsp)
  403b10:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
  403b15:	e8 d6 de ff ff       	callq  4019f0 <operator new(unsigned long)@plt>
  403b1a:	48 8b 54 24 10       	mov    0x10(%rsp),%rdx
  403b1f:	48 8b 4c 24 08       	mov    0x8(%rsp),%rcx
  403b24:	49 89 c5             	mov    %rax,%r13
  403b27:	49 01 c6             	add    %rax,%r14
  403b2a:	49 8b 07             	mov    (%r15),%rax
  403b2d:	49 89 c8             	mov    %rcx,%r8
  403b30:	4d 8d 4c 15 08       	lea    0x8(%r13,%rdx,1),%r9
  403b35:	4d 29 e0             	sub    %r12,%r8
  403b38:	49 89 44 15 00       	mov    %rax,0x0(%r13,%rdx,1)
	__copy_m(const _Tp* __first, const _Tp* __last, _Tp* __result)
  403b3d:	4f 8d 3c 01          	lea    (%r9,%r8,1),%r15
	  if (_Num)
  403b41:	49 39 ec             	cmp    %rbp,%r12
  403b44:	0f 84 96 00 00 00    	je     403be0 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)+0x120>
	    __builtin_memmove(__result, __first, sizeof(_Tp) * _Num);
  403b4a:	48 89 ee             	mov    %rbp,%rsi
  403b4d:	4c 89 ef             	mov    %r13,%rdi
  403b50:	4c 89 4c 24 18       	mov    %r9,0x18(%rsp)
  403b55:	4c 89 44 24 10       	mov    %r8,0x10(%rsp)
  403b5a:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
  403b5f:	e8 cc df ff ff       	callq  401b30 <memmove@plt>
	  if (_Num)
  403b64:	48 8b 4c 24 08       	mov    0x8(%rsp),%rcx
  403b69:	4c 8b 44 24 10       	mov    0x10(%rsp),%r8
  403b6e:	4c 8b 4c 24 18       	mov    0x18(%rsp),%r9
  403b73:	49 39 cc             	cmp    %rcx,%r12
  403b76:	74 30                	je     403ba8 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)+0xe8>
	    __builtin_memmove(__result, __first, sizeof(_Tp) * _Num);
  403b78:	4c 89 c2             	mov    %r8,%rdx
  403b7b:	4c 89 e6             	mov    %r12,%rsi
  403b7e:	4c 89 cf             	mov    %r9,%rdi
  403b81:	e8 2a de ff ff       	callq  4019b0 <memcpy@plt>
	if (__p)
  403b86:	48 85 ed             	test   %rbp,%rbp
  403b89:	75 1d                	jne    403ba8 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)+0xe8>
	}
      _GLIBCXX_ASAN_ANNOTATE_REINIT;
      std::_Destroy(__old_start, __old_finish, _M_get_Tp_allocator());
      _M_deallocate(__old_start,
		    this->_M_impl._M_end_of_storage - __old_start);
      this->_M_impl._M_start = __new_start;
  403b8b:	4c 89 2b             	mov    %r13,(%rbx)
      this->_M_impl._M_finish = __new_finish;
  403b8e:	4c 89 7b 08          	mov    %r15,0x8(%rbx)
      this->_M_impl._M_end_of_storage = __new_start + __len;
  403b92:	4c 89 73 10          	mov    %r14,0x10(%rbx)
    }
  403b96:	48 83 c4 28          	add    $0x28,%rsp
  403b9a:	5b                   	pop    %rbx
  403b9b:	5d                   	pop    %rbp
  403b9c:	41 5c                	pop    %r12
  403b9e:	41 5d                	pop    %r13
  403ba0:	41 5e                	pop    %r14
  403ba2:	41 5f                	pop    %r15
  403ba4:	c3                   	retq   
  403ba5:	0f 1f 00             	nopl   (%rax)
	::operator delete(__p);
  403ba8:	48 89 ef             	mov    %rbp,%rdi
  403bab:	e8 20 de ff ff       	callq  4019d0 <operator delete(void*)@plt>
  403bb0:	eb d9                	jmp    403b8b <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)+0xcb>
  403bb2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
	return (__len < size() || __len > max_size()) ? max_size() : __len;
  403bb8:	48 b8 ff ff ff ff ff 	movabs $0x1fffffffffffffff,%rax
  403bbf:	ff ff 1f 
  403bc2:	48 39 c7             	cmp    %rax,%rdi
  403bc5:	0f 87 3d ff ff ff    	ja     403b08 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)+0x48>
	return __n != 0 ? _Tr::allocate(_M_impl, __n) : pointer();
  403bcb:	45 31 f6             	xor    %r14d,%r14d
  403bce:	45 31 ed             	xor    %r13d,%r13d
  403bd1:	48 85 ff             	test   %rdi,%rdi
  403bd4:	0f 84 50 ff ff ff    	je     403b2a <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)+0x6a>
  403bda:	eb 19                	jmp    403bf5 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)+0x135>
  403bdc:	0f 1f 40 00          	nopl   0x0(%rax)
	  if (_Num)
  403be0:	49 39 cc             	cmp    %rcx,%r12
  403be3:	75 93                	jne    403b78 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)+0xb8>
  403be5:	eb 9f                	jmp    403b86 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)+0xc6>
  403be7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  403bee:	00 00 
	const size_type __len = size() + std::max(size(), __n);
  403bf0:	bf 01 00 00 00       	mov    $0x1,%edi
  403bf5:	4c 8d 34 fd 00 00 00 	lea    0x0(,%rdi,8),%r14
  403bfc:	00 
  403bfd:	e9 06 ff ff ff       	jmpq   403b08 <void std::vector<unsigned long, std::allocator<unsigned long> >::_M_realloc_insert<unsigned long const&>(__gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >, unsigned long const&)+0x48>
  403c02:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  403c09:	00 00 00 
  403c0c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000403c10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const>:
      return __r;
    }

  template<typename _CharT, typename _Traits, typename _Alloc>
    int
    basic_string<_CharT, _Traits, _Alloc>::
  403c10:	41 55                	push   %r13
  403c12:	49 89 f5             	mov    %rsi,%r13
  403c15:	41 54                	push   %r12
  403c17:	49 89 fc             	mov    %rdi,%r12
  403c1a:	55                   	push   %rbp
  403c1b:	53                   	push   %rbx
  403c1c:	48 83 ec 08          	sub    $0x8,%rsp
    compare(const _CharT* __s) const _GLIBCXX_NOEXCEPT
    {
      __glibcxx_requires_string(__s);
      const size_type __size = this->size();
  403c20:	48 8b 5f 08          	mov    0x8(%rdi),%rbx
  403c24:	48 89 f7             	mov    %rsi,%rdi
  403c27:	e8 04 dd ff ff       	callq  401930 <strlen@plt>
  403c2c:	48 39 c3             	cmp    %rax,%rbx
  403c2f:	48 89 c2             	mov    %rax,%rdx
  403c32:	48 89 c5             	mov    %rax,%rbp
  403c35:	48 0f 46 d3          	cmovbe %rbx,%rdx
	if (__n == 0)
  403c39:	48 85 d2             	test   %rdx,%rdx
  403c3c:	74 22                	je     403c60 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const+0x50>
	return __builtin_memcmp(__s1, __s2, __n);
  403c3e:	49 8b 3c 24          	mov    (%r12),%rdi
  403c42:	4c 89 ee             	mov    %r13,%rsi
  403c45:	e8 f6 dc ff ff       	callq  401940 <memcmp@plt>
      const size_type __osize = traits_type::length(__s);
      const size_type __len = std::min(__size, __osize);
      int __r = traits_type::compare(_M_data(), __s, __len);
      if (!__r)
  403c4a:	85 c0                	test   %eax,%eax
  403c4c:	74 12                	je     403c60 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const+0x50>
	__r = _S_compare(__size, __osize);
      return __r;
    }
  403c4e:	48 83 c4 08          	add    $0x8,%rsp
  403c52:	5b                   	pop    %rbx
  403c53:	5d                   	pop    %rbp
  403c54:	41 5c                	pop    %r12
  403c56:	41 5d                	pop    %r13
  403c58:	c3                   	retq   
  403c59:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
	const difference_type __d = difference_type(__n1 - __n2);
  403c60:	48 29 eb             	sub    %rbp,%rbx
	  return __gnu_cxx::__numeric_traits<int>::__max;
  403c63:	b8 ff ff ff 7f       	mov    $0x7fffffff,%eax
	if (__d > __gnu_cxx::__numeric_traits<int>::__max)
  403c68:	48 81 fb ff ff ff 7f 	cmp    $0x7fffffff,%rbx
  403c6f:	7f dd                	jg     403c4e <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::compare(char const*) const+0x3e>
	  return int(__d);
  403c71:	48 81 fb 00 00 00 80 	cmp    $0xffffffff80000000,%rbx
  403c78:	8d 40 01             	lea    0x1(%rax),%eax
  403c7b:	0f 4d c3             	cmovge %ebx,%eax
  403c7e:	48 83 c4 08          	add    $0x8,%rsp
  403c82:	5b                   	pop    %rbx
  403c83:	5d                   	pop    %rbp
  403c84:	41 5c                	pop    %r12
  403c86:	41 5d                	pop    %r13
  403c88:	c3                   	retq   
  403c89:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000403c90 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)>:
      vector<_Tp, _Alloc>::
  403c90:	41 57                	push   %r15
  403c92:	49 89 d7             	mov    %rdx,%r15
  403c95:	48 89 f1             	mov    %rsi,%rcx
      { return size_type(this->_M_impl._M_finish - this->_M_impl._M_start); }
  403c98:	48 ba ab aa aa aa aa 	movabs $0xaaaaaaaaaaaaaaab,%rdx
  403c9f:	aa aa aa 
  403ca2:	41 56                	push   %r14
  403ca4:	41 55                	push   %r13
  403ca6:	49 89 f5             	mov    %rsi,%r13
  403ca9:	41 54                	push   %r12
  403cab:	55                   	push   %rbp
  403cac:	48 89 fd             	mov    %rdi,%rbp
  403caf:	53                   	push   %rbx
  403cb0:	48 83 ec 28          	sub    $0x28,%rsp
	if (max_size() - size() < __n)
  403cb4:	4c 8b 47 08          	mov    0x8(%rdi),%r8
  403cb8:	4c 8b 27             	mov    (%rdi),%r12
      { return size_type(this->_M_impl._M_finish - this->_M_impl._M_start); }
  403cbb:	4c 89 c0             	mov    %r8,%rax
  403cbe:	4c 29 e1             	sub    %r12,%rcx
  403cc1:	4c 29 e0             	sub    %r12,%rax
  403cc4:	48 c1 f8 04          	sar    $0x4,%rax
  403cc8:	48 0f af c2          	imul   %rdx,%rax
      if (__a < __b)
  403ccc:	48 85 c0             	test   %rax,%rax
  403ccf:	0f 84 1b 01 00 00    	je     403df0 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)+0x160>
	const size_type __len = size() + std::max(size(), __n);
  403cd5:	48 8d 14 00          	lea    (%rax,%rax,1),%rdx
	return (__len < size() || __len > max_size()) ? max_size() : __len;
  403cd9:	49 c7 c6 f0 ff ff ff 	mov    $0xfffffffffffffff0,%r14
  403ce0:	48 39 d0             	cmp    %rdx,%rax
  403ce3:	0f 86 cf 00 00 00    	jbe    403db8 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)+0x128>
	return static_cast<_Tp*>(::operator new(__n * sizeof(_Tp)));
  403ce9:	4c 89 f7             	mov    %r14,%rdi
  403cec:	48 89 4c 24 10       	mov    %rcx,0x10(%rsp)
  403cf1:	4c 89 44 24 08       	mov    %r8,0x8(%rsp)
  403cf6:	e8 f5 dc ff ff       	callq  4019f0 <operator new(unsigned long)@plt>
  403cfb:	48 8b 4c 24 10       	mov    0x10(%rsp),%rcx
  403d00:	4c 8b 44 24 08       	mov    0x8(%rsp),%r8
  403d05:	48 89 c3             	mov    %rax,%rbx
  403d08:	49 01 c6             	add    %rax,%r14
	__copy_m(const _Tp* __first, const _Tp* __last, _Tp* __result)
  403d0b:	f3 41 0f 6f 07       	movdqu (%r15),%xmm0
  403d10:	f3 41 0f 6f 4f 10    	movdqu 0x10(%r15),%xmm1
  403d16:	4d 89 c1             	mov    %r8,%r9
  403d19:	4c 8d 54 0b 30       	lea    0x30(%rbx,%rcx,1),%r10
  403d1e:	f3 41 0f 6f 57 20    	movdqu 0x20(%r15),%xmm2
  403d24:	4d 29 e9             	sub    %r13,%r9
  403d27:	0f 11 04 0b          	movups %xmm0,(%rbx,%rcx,1)
  403d2b:	4f 8d 3c 0a          	lea    (%r10,%r9,1),%r15
  403d2f:	0f 11 4c 0b 10       	movups %xmm1,0x10(%rbx,%rcx,1)
  403d34:	0f 11 54 0b 20       	movups %xmm2,0x20(%rbx,%rcx,1)
	  if (_Num)
  403d39:	4d 39 e5             	cmp    %r12,%r13
  403d3c:	0f 84 9e 00 00 00    	je     403de0 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)+0x150>
	    __builtin_memmove(__result, __first, sizeof(_Tp) * _Num);
  403d42:	48 89 ca             	mov    %rcx,%rdx
  403d45:	4c 89 e6             	mov    %r12,%rsi
  403d48:	48 89 df             	mov    %rbx,%rdi
  403d4b:	4c 89 54 24 18       	mov    %r10,0x18(%rsp)
  403d50:	4c 89 4c 24 10       	mov    %r9,0x10(%rsp)
  403d55:	4c 89 44 24 08       	mov    %r8,0x8(%rsp)
  403d5a:	e8 d1 dd ff ff       	callq  401b30 <memmove@plt>
	  if (_Num)
  403d5f:	4c 8b 44 24 08       	mov    0x8(%rsp),%r8
  403d64:	4c 8b 4c 24 10       	mov    0x10(%rsp),%r9
  403d69:	4c 8b 54 24 18       	mov    0x18(%rsp),%r10
  403d6e:	4d 39 c5             	cmp    %r8,%r13
  403d71:	74 35                	je     403da8 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)+0x118>
	    __builtin_memmove(__result, __first, sizeof(_Tp) * _Num);
  403d73:	4c 89 ca             	mov    %r9,%rdx
  403d76:	4c 89 ee             	mov    %r13,%rsi
  403d79:	4c 89 d7             	mov    %r10,%rdi
  403d7c:	e8 2f dc ff ff       	callq  4019b0 <memcpy@plt>
	if (__p)
  403d81:	4d 85 e4             	test   %r12,%r12
  403d84:	75 22                	jne    403da8 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)+0x118>
      this->_M_impl._M_start = __new_start;
  403d86:	48 89 5d 00          	mov    %rbx,0x0(%rbp)
      this->_M_impl._M_finish = __new_finish;
  403d8a:	4c 89 7d 08          	mov    %r15,0x8(%rbp)
      this->_M_impl._M_end_of_storage = __new_start + __len;
  403d8e:	4c 89 75 10          	mov    %r14,0x10(%rbp)
    }
  403d92:	48 83 c4 28          	add    $0x28,%rsp
  403d96:	5b                   	pop    %rbx
  403d97:	5d                   	pop    %rbp
  403d98:	41 5c                	pop    %r12
  403d9a:	41 5d                	pop    %r13
  403d9c:	41 5e                	pop    %r14
  403d9e:	41 5f                	pop    %r15
  403da0:	c3                   	retq   
  403da1:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
	::operator delete(__p);
  403da8:	4c 89 e7             	mov    %r12,%rdi
  403dab:	e8 20 dc ff ff       	callq  4019d0 <operator delete(void*)@plt>
  403db0:	eb d4                	jmp    403d86 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)+0xf6>
  403db2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
	return (__len < size() || __len > max_size()) ? max_size() : __len;
  403db8:	48 b8 55 55 55 55 55 	movabs $0x555555555555555,%rax
  403dbf:	55 55 05 
  403dc2:	48 39 c2             	cmp    %rax,%rdx
  403dc5:	0f 87 1e ff ff ff    	ja     403ce9 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)+0x59>
	return __n != 0 ? _Tr::allocate(_M_impl, __n) : pointer();
  403dcb:	45 31 f6             	xor    %r14d,%r14d
  403dce:	31 db                	xor    %ebx,%ebx
  403dd0:	48 85 d2             	test   %rdx,%rdx
  403dd3:	0f 84 32 ff ff ff    	je     403d0b <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)+0x7b>
  403dd9:	eb 1a                	jmp    403df5 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)+0x165>
  403ddb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
	  if (_Num)
  403de0:	4d 39 c5             	cmp    %r8,%r13
  403de3:	75 8e                	jne    403d73 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)+0xe3>
  403de5:	eb 9a                	jmp    403d81 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)+0xf1>
  403de7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  403dee:	00 00 
	const size_type __len = size() + std::max(size(), __n);
  403df0:	ba 01 00 00 00       	mov    $0x1,%edx
  403df5:	4c 8d 34 52          	lea    (%rdx,%rdx,2),%r14
  403df9:	49 c1 e6 04          	shl    $0x4,%r14
  403dfd:	e9 e7 fe ff ff       	jmpq   403ce9 <void std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > >::_M_realloc_insert<std::array<double, 6ul> const&>(__gnu_cxx::__normal_iterator<std::array<double, 6ul>*, std::vector<std::array<double, 6ul>, std::allocator<std::array<double, 6ul> > > >, std::array<double, 6ul> const&)+0x59>
  403e02:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  403e09:	00 00 00 
  403e0c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000403e10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)>:
    basic_string<_CharT, _Traits, _Alloc>::
  403e10:	41 57                	push   %r15
	return std::pointer_traits<const_pointer>::pointer_to(*_M_local_buf);
  403e12:	4c 8d 7f 10          	lea    0x10(%rdi),%r15
  403e16:	48 89 f1             	mov    %rsi,%rcx
  403e19:	41 56                	push   %r14
  403e1b:	49 89 d6             	mov    %rdx,%r14
  403e1e:	41 55                	push   %r13
  403e20:	41 54                	push   %r12
  403e22:	55                   	push   %rbp
  403e23:	53                   	push   %rbx
  403e24:	48 89 fb             	mov    %rdi,%rbx
  403e27:	48 83 ec 28          	sub    $0x28,%rsp
      const size_type __len = __n + this->size();
  403e2b:	4c 8b 6f 08          	mov    0x8(%rdi),%r13
      { return _M_data() == _M_local_data(); }
  403e2f:	48 8b 2f             	mov    (%rdi),%rbp
  403e32:	4e 8d 24 2a          	lea    (%rdx,%r13,1),%r12
	return _M_is_local() ? size_type(_S_local_capacity)
  403e36:	49 39 ef             	cmp    %rbp,%r15
  403e39:	0f 84 e9 00 00 00    	je     403f28 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0x118>
  403e3f:	48 8b 77 10          	mov    0x10(%rdi),%rsi
      if (__len <= this->capacity())
  403e43:	49 39 f4             	cmp    %rsi,%r12
  403e46:	77 48                	ja     403e90 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0x80>
	  if (__n)
  403e48:	4d 85 f6             	test   %r14,%r14
  403e4b:	74 1d                	je     403e6a <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0x5a>
	    this->_S_copy(this->_M_data() + this->size(), __s, __n);
  403e4d:	4a 8d 7c 2d 00       	lea    0x0(%rbp,%r13,1),%rdi
	if (__n == 1)
  403e52:	49 83 fe 01          	cmp    $0x1,%r14
  403e56:	0f 84 ec 00 00 00    	je     403f48 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0x138>
      static char_type*
      copy(char_type* __s1, const char_type* __s2, size_t __n)
      {
	if (__n == 0)
	  return __s1;
	return static_cast<char_type*>(__builtin_memcpy(__s1, __s2, __n));
  403e5c:	4c 89 f2             	mov    %r14,%rdx
  403e5f:	48 89 ce             	mov    %rcx,%rsi
  403e62:	e8 49 db ff ff       	callq  4019b0 <memcpy@plt>
  403e67:	48 8b 2b             	mov    (%rbx),%rbp
      { _M_string_length = __length; }
  403e6a:	4c 89 63 08          	mov    %r12,0x8(%rbx)
    }
  403e6e:	48 89 d8             	mov    %rbx,%rax
      { __c1 = __c2; }
  403e71:	42 c6 44 25 00 00    	movb   $0x0,0x0(%rbp,%r12,1)
  403e77:	48 83 c4 28          	add    $0x28,%rsp
  403e7b:	5b                   	pop    %rbx
  403e7c:	5d                   	pop    %rbp
  403e7d:	41 5c                	pop    %r12
  403e7f:	41 5d                	pop    %r13
  403e81:	41 5e                	pop    %r14
  403e83:	41 5f                	pop    %r15
  403e85:	c3                   	retq   
  403e86:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  403e8d:	00 00 00 
      size_type __new_capacity = length() + __len2 - __len1;
  403e90:	4c 89 64 24 18       	mov    %r12,0x18(%rsp)
      pointer __r = _M_create(__new_capacity, capacity());
  403e95:	48 8d 7c 24 18       	lea    0x18(%rsp),%rdi
  403e9a:	48 89 0c 24          	mov    %rcx,(%rsp)
  403e9e:	e8 7d f8 ff ff       	callq  403720 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long) [clone .isra.77]>
      if (__pos)
  403ea3:	4d 85 ed             	test   %r13,%r13
	this->_S_copy(__r, _M_data(), __pos);
  403ea6:	4c 8b 03             	mov    (%rbx),%r8
      if (__pos)
  403ea9:	48 8b 0c 24          	mov    (%rsp),%rcx
      pointer __r = _M_create(__new_capacity, capacity());
  403ead:	48 89 c5             	mov    %rax,%rbp
      if (__pos)
  403eb0:	74 2a                	je     403edc <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0xcc>
	if (__n == 1)
  403eb2:	49 83 fd 01          	cmp    $0x1,%r13
  403eb6:	0f 84 a4 00 00 00    	je     403f60 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0x150>
	return static_cast<char_type*>(__builtin_memcpy(__s1, __s2, __n));
  403ebc:	4c 89 c6             	mov    %r8,%rsi
  403ebf:	4c 89 ea             	mov    %r13,%rdx
  403ec2:	48 89 c7             	mov    %rax,%rdi
  403ec5:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
  403eca:	4c 89 04 24          	mov    %r8,(%rsp)
  403ece:	e8 dd da ff ff       	callq  4019b0 <memcpy@plt>
  403ed3:	48 8b 4c 24 08       	mov    0x8(%rsp),%rcx
  403ed8:	4c 8b 04 24          	mov    (%rsp),%r8
      if (__s && __len2)
  403edc:	48 85 c9             	test   %rcx,%rcx
  403edf:	74 23                	je     403f04 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0xf4>
  403ee1:	4d 85 f6             	test   %r14,%r14
  403ee4:	74 1e                	je     403f04 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0xf4>
	this->_S_copy(__r + __pos, __s, __len2);
  403ee6:	4a 8d 7c 2d 00       	lea    0x0(%rbp,%r13,1),%rdi
  403eeb:	49 83 fe 01          	cmp    $0x1,%r14
  403eef:	74 67                	je     403f58 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0x148>
  403ef1:	4c 89 f2             	mov    %r14,%rdx
  403ef4:	48 89 ce             	mov    %rcx,%rsi
  403ef7:	4c 89 04 24          	mov    %r8,(%rsp)
  403efb:	e8 b0 da ff ff       	callq  4019b0 <memcpy@plt>
  403f00:	4c 8b 04 24          	mov    (%rsp),%r8
	if (!_M_is_local())
  403f04:	4d 39 c7             	cmp    %r8,%r15
  403f07:	74 08                	je     403f11 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0x101>
  403f09:	4c 89 c7             	mov    %r8,%rdi
  403f0c:	e8 bf da ff ff       	callq  4019d0 <operator delete(void*)@plt>
      { _M_allocated_capacity = __capacity; }
  403f11:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
      { _M_dataplus._M_p = __p; }
  403f16:	48 89 2b             	mov    %rbp,(%rbx)
      { _M_allocated_capacity = __capacity; }
  403f19:	48 89 43 10          	mov    %rax,0x10(%rbx)
  403f1d:	e9 48 ff ff ff       	jmpq   403e6a <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0x5a>
  403f22:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
      if (__len <= this->capacity())
  403f28:	49 83 fc 0f          	cmp    $0xf,%r12
  403f2c:	0f 86 16 ff ff ff    	jbe    403e48 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0x38>
      size_type __new_capacity = length() + __len2 - __len1;
  403f32:	4c 89 64 24 18       	mov    %r12,0x18(%rsp)
	return _M_is_local() ? size_type(_S_local_capacity)
  403f37:	be 0f 00 00 00       	mov    $0xf,%esi
  403f3c:	e9 54 ff ff ff       	jmpq   403e95 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0x85>
  403f41:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
	  traits_type::assign(*__d, *__s);
  403f48:	0f b6 01             	movzbl (%rcx),%eax
      { __c1 = __c2; }
  403f4b:	88 07                	mov    %al,(%rdi)
  403f4d:	48 8b 2b             	mov    (%rbx),%rbp
  403f50:	e9 15 ff ff ff       	jmpq   403e6a <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0x5a>
  403f55:	0f 1f 00             	nopl   (%rax)
  403f58:	0f b6 01             	movzbl (%rcx),%eax
  403f5b:	88 07                	mov    %al,(%rdi)
  403f5d:	eb a5                	jmp    403f04 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0xf4>
  403f5f:	90                   	nop
  403f60:	41 0f b6 00          	movzbl (%r8),%eax
  403f64:	88 45 00             	mov    %al,0x0(%rbp)
  403f67:	e9 70 ff ff ff       	jmpq   403edc <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)+0xcc>
  403f6c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000403f70 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > std::operator+<char, std::char_traits<char>, std::allocator<char> >(char const*, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)>:
    operator+(const _CharT* __lhs,
  403f70:	41 57                	push   %r15
  403f72:	41 56                	push   %r14
  403f74:	41 55                	push   %r13
  403f76:	49 89 f5             	mov    %rsi,%r13
  403f79:	41 54                	push   %r12
  403f7b:	55                   	push   %rbp
  403f7c:	48 89 d5             	mov    %rdx,%rbp
  403f7f:	53                   	push   %rbx
  403f80:	48 89 fb             	mov    %rdi,%rbx
	return __builtin_strlen(__s);
  403f83:	48 89 f7             	mov    %rsi,%rdi
	return std::pointer_traits<pointer>::pointer_to(*_M_local_buf);
  403f86:	4c 8d 73 10          	lea    0x10(%rbx),%r14
  403f8a:	48 83 ec 28          	sub    $0x28,%rsp
  403f8e:	e8 9d d9 ff ff       	callq  401930 <strlen@plt>
	: allocator_type(std::move(__a)), _M_p(__dat) { }
  403f93:	4c 89 33             	mov    %r14,(%rbx)
  403f96:	49 89 c4             	mov    %rax,%r12
      { _M_string_length = __length; }
  403f99:	48 c7 43 08 00 00 00 	movq   $0x0,0x8(%rbx)
  403fa0:	00 
      { __c1 = __c2; }
  403fa1:	c6 43 10 00          	movb   $0x0,0x10(%rbx)
      __str.reserve(__len + __rhs.size());
  403fa5:	48 03 45 08          	add    0x8(%rbp),%rax
  403fa9:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
	  if (__res > __capacity
  403fae:	48 83 f8 0f          	cmp    $0xf,%rax
  403fb2:	77 34                	ja     403fe8 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > std::operator+<char, std::char_traits<char>, std::allocator<char> >(char const*, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0x78>
	return _M_append(__s, __n);
  403fb4:	4c 89 e2             	mov    %r12,%rdx
  403fb7:	4c 89 ee             	mov    %r13,%rsi
  403fba:	48 89 df             	mov    %rbx,%rdi
  403fbd:	e8 4e fe ff ff       	callq  403e10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)>
      { return _M_append(__str._M_data(), __str.size()); }
  403fc2:	48 8b 55 08          	mov    0x8(%rbp),%rdx
  403fc6:	48 8b 75 00          	mov    0x0(%rbp),%rsi
  403fca:	48 89 df             	mov    %rbx,%rdi
  403fcd:	e8 3e fe ff ff       	callq  403e10 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_append(char const*, unsigned long)>
    }
  403fd2:	48 83 c4 28          	add    $0x28,%rsp
  403fd6:	48 89 d8             	mov    %rbx,%rax
  403fd9:	5b                   	pop    %rbx
  403fda:	5d                   	pop    %rbp
  403fdb:	41 5c                	pop    %r12
  403fdd:	41 5d                	pop    %r13
  403fdf:	41 5e                	pop    %r14
  403fe1:	41 5f                	pop    %r15
  403fe3:	c3                   	retq   
  403fe4:	0f 1f 40 00          	nopl   0x0(%rax)
	      pointer __tmp = _M_create(__res, __capacity);
  403fe8:	be 0f 00 00 00       	mov    $0xf,%esi
  403fed:	48 8d 7c 24 18       	lea    0x18(%rsp),%rdi
  403ff2:	e8 29 f7 ff ff       	callq  403720 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long) [clone .isra.77]>
	      this->_S_copy(__tmp, _M_data(), length() + 1);
  403ff7:	4c 8b 7b 08          	mov    0x8(%rbx),%r15
	      pointer __tmp = _M_create(__res, __capacity);
  403ffb:	49 89 c0             	mov    %rax,%r8
	      this->_S_copy(__tmp, _M_data(), length() + 1);
  403ffe:	48 8b 0b             	mov    (%rbx),%rcx
  404001:	49 8d 57 01          	lea    0x1(%r15),%rdx
	if (__n == 1)
  404005:	48 83 fa 01          	cmp    $0x1,%rdx
  404009:	74 75                	je     404080 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > std::operator+<char, std::char_traits<char>, std::allocator<char> >(char const*, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0x110>
	if (__n == 0)
  40400b:	48 85 d2             	test   %rdx,%rdx
  40400e:	75 50                	jne    404060 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > std::operator+<char, std::char_traits<char>, std::allocator<char> >(char const*, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0xf0>
	if (!_M_is_local())
  404010:	49 39 ce             	cmp    %rcx,%r14
  404013:	74 16                	je     40402b <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > std::operator+<char, std::char_traits<char>, std::allocator<char> >(char const*, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0xbb>
  404015:	48 89 cf             	mov    %rcx,%rdi
  404018:	4c 89 44 24 08       	mov    %r8,0x8(%rsp)
  40401d:	e8 ae d9 ff ff       	callq  4019d0 <operator delete(void*)@plt>
  404022:	4c 8b 7b 08          	mov    0x8(%rbx),%r15
  404026:	4c 8b 44 24 08       	mov    0x8(%rsp),%r8
      { _M_allocated_capacity = __capacity; }
  40402b:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
      { _M_dataplus._M_p = __p; }
  404030:	4c 89 03             	mov    %r8,(%rbx)
      { _M_allocated_capacity = __capacity; }
  404033:	48 89 43 10          	mov    %rax,0x10(%rbx)
	if (this->max_size() - (this->size() - __n1) < __n2)
  404037:	48 b8 ff ff ff ff ff 	movabs $0x7fffffffffffffff,%rax
  40403e:	ff ff 7f 
  404041:	4c 29 f8             	sub    %r15,%rax
  404044:	4c 39 e0             	cmp    %r12,%rax
  404047:	0f 83 67 ff ff ff    	jae    403fb4 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > std::operator+<char, std::char_traits<char>, std::allocator<char> >(char const*, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0x44>
	  __throw_length_error(__N(__s));
  40404d:	bf 13 44 40 00       	mov    $0x404413,%edi
  404052:	e8 09 d9 ff ff       	callq  401960 <std::__throw_length_error(char const*)@plt>
  404057:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  40405e:	00 00 
	return static_cast<char_type*>(__builtin_memcpy(__s1, __s2, __n));
  404060:	48 89 ce             	mov    %rcx,%rsi
  404063:	48 89 c7             	mov    %rax,%rdi
  404066:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
  40406b:	e8 40 d9 ff ff       	callq  4019b0 <memcpy@plt>
  404070:	48 8b 4c 24 08       	mov    0x8(%rsp),%rcx
  404075:	49 89 c0             	mov    %rax,%r8
  404078:	eb 96                	jmp    404010 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > std::operator+<char, std::char_traits<char>, std::allocator<char> >(char const*, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0xa0>
  40407a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
	  traits_type::assign(*__d, *__s);
  404080:	0f b6 01             	movzbl (%rcx),%eax
      { __c1 = __c2; }
  404083:	41 88 00             	mov    %al,(%r8)
  404086:	eb 88                	jmp    404010 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > std::operator+<char, std::char_traits<char>, std::allocator<char> >(char const*, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0xa0>
  404088:	48 89 c5             	mov    %rax,%rbp
      { return _M_data() == _M_local_data(); }
  40408b:	48 8b 3b             	mov    (%rbx),%rdi
	if (!_M_is_local())
  40408e:	49 39 fe             	cmp    %rdi,%r14
  404091:	74 05                	je     404098 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > std::operator+<char, std::char_traits<char>, std::allocator<char> >(char const*, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0x128>
  404093:	e8 38 d9 ff ff       	callq  4019d0 <operator delete(void*)@plt>
      ~new_allocator() _GLIBCXX_USE_NOEXCEPT { }
  404098:	48 89 ef             	mov    %rbp,%rdi
  40409b:	e8 00 db ff ff       	callq  401ba0 <_Unwind_Resume@plt>

00000000004040a0 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)>:
      if (this != &__str)
  4040a0:	48 39 f7             	cmp    %rsi,%rdi
  4040a3:	0f 84 9f 00 00 00    	je     404148 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0xa8>
    basic_string<_CharT, _Traits, _Alloc>::
  4040a9:	41 56                	push   %r14
	return std::pointer_traits<const_pointer>::pointer_to(*_M_local_buf);
  4040ab:	4c 8d 77 10          	lea    0x10(%rdi),%r14
  4040af:	41 55                	push   %r13
  4040b1:	41 54                	push   %r12
  4040b3:	55                   	push   %rbp
  4040b4:	53                   	push   %rbx
  4040b5:	48 83 ec 10          	sub    $0x10,%rsp
      { return _M_data() == _M_local_data(); }
  4040b9:	4c 8b 2f             	mov    (%rdi),%r13
	  const size_type __rsize = __str.length();
  4040bc:	4c 8b 66 08          	mov    0x8(%rsi),%r12
	return _M_is_local() ? size_type(_S_local_capacity)
  4040c0:	4d 39 ee             	cmp    %r13,%r14
  4040c3:	0f 84 87 00 00 00    	je     404150 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0xb0>
  4040c9:	48 8b 47 10          	mov    0x10(%rdi),%rax
  4040cd:	48 89 f5             	mov    %rsi,%rbp
  4040d0:	48 89 fb             	mov    %rdi,%rbx
	  if (__rsize > __capacity)
  4040d3:	4c 39 e0             	cmp    %r12,%rax
  4040d6:	72 38                	jb     404110 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0x70>
	  if (__rsize)
  4040d8:	4d 85 e4             	test   %r12,%r12
  4040db:	74 18                	je     4040f5 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0x55>
	    this->_S_copy(_M_data(), __str._M_data(), __rsize);
  4040dd:	48 8b 75 00          	mov    0x0(%rbp),%rsi
	if (__n == 1)
  4040e1:	49 83 fc 01          	cmp    $0x1,%r12
  4040e5:	74 79                	je     404160 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0xc0>
	return static_cast<char_type*>(__builtin_memcpy(__s1, __s2, __n));
  4040e7:	4c 89 ef             	mov    %r13,%rdi
  4040ea:	4c 89 e2             	mov    %r12,%rdx
  4040ed:	e8 be d8 ff ff       	callq  4019b0 <memcpy@plt>
  4040f2:	4c 8b 2b             	mov    (%rbx),%r13
      { _M_string_length = __length; }
  4040f5:	4c 89 63 08          	mov    %r12,0x8(%rbx)
      { __c1 = __c2; }
  4040f9:	43 c6 44 25 00 00    	movb   $0x0,0x0(%r13,%r12,1)
    }
  4040ff:	48 83 c4 10          	add    $0x10,%rsp
  404103:	5b                   	pop    %rbx
  404104:	5d                   	pop    %rbp
  404105:	41 5c                	pop    %r12
  404107:	41 5d                	pop    %r13
  404109:	41 5e                	pop    %r14
  40410b:	c3                   	retq   
  40410c:	0f 1f 40 00          	nopl   0x0(%rax)
	      pointer __tmp = _M_create(__new_capacity, __capacity);
  404110:	48 8d 7c 24 08       	lea    0x8(%rsp),%rdi
  404115:	48 89 c6             	mov    %rax,%rsi
	      size_type __new_capacity = __rsize;
  404118:	4c 89 64 24 08       	mov    %r12,0x8(%rsp)
	      pointer __tmp = _M_create(__new_capacity, __capacity);
  40411d:	e8 fe f5 ff ff       	callq  403720 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long) [clone .isra.77]>
      { return _M_data() == _M_local_data(); }
  404122:	48 8b 3b             	mov    (%rbx),%rdi
  404125:	49 89 c5             	mov    %rax,%r13
	if (!_M_is_local())
  404128:	49 39 fe             	cmp    %rdi,%r14
  40412b:	74 05                	je     404132 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0x92>
	::operator delete(__p);
  40412d:	e8 9e d8 ff ff       	callq  4019d0 <operator delete(void*)@plt>
      { _M_allocated_capacity = __capacity; }
  404132:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
      { _M_dataplus._M_p = __p; }
  404137:	4c 89 2b             	mov    %r13,(%rbx)
      { _M_allocated_capacity = __capacity; }
  40413a:	48 89 43 10          	mov    %rax,0x10(%rbx)
	  if (__rsize)
  40413e:	4d 85 e4             	test   %r12,%r12
  404141:	74 b2                	je     4040f5 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0x55>
  404143:	eb 98                	jmp    4040dd <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0x3d>
  404145:	0f 1f 00             	nopl   (%rax)
  404148:	c3                   	retq   
  404149:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
	return _M_is_local() ? size_type(_S_local_capacity)
  404150:	b8 0f 00 00 00       	mov    $0xf,%eax
  404155:	e9 73 ff ff ff       	jmpq   4040cd <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0x2d>
  40415a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
	  traits_type::assign(*__d, *__s);
  404160:	0f b6 06             	movzbl (%rsi),%eax
  404163:	41 88 45 00          	mov    %al,0x0(%r13)
  404167:	4c 8b 2b             	mov    (%rbx),%r13
  40416a:	eb 89                	jmp    4040f5 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_assign(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)+0x55>
  40416c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000404170 <void std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_construct<char const*>(char const*, char const*, std::forward_iterator_tag)>:
      basic_string<_CharT, _Traits, _Alloc>::
  404170:	41 54                	push   %r12
  404172:	49 89 f4             	mov    %rsi,%r12
  404175:	55                   	push   %rbp
  404176:	48 89 fd             	mov    %rdi,%rbp
  404179:	53                   	push   %rbx
  40417a:	48 83 ec 10          	sub    $0x10,%rsp
	if (__gnu_cxx::__is_null_pointer(__beg) && __beg != __end)
  40417e:	48 85 d2             	test   %rdx,%rdx
  404181:	74 05                	je     404188 <void std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_construct<char const*>(char const*, char const*, std::forward_iterator_tag)+0x18>
  404183:	48 85 f6             	test   %rsi,%rsi
  404186:	74 7a                	je     404202 <void std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_construct<char const*>(char const*, char const*, std::forward_iterator_tag)+0x92>
               random_access_iterator_tag)
    {
      // concept requirements
      __glibcxx_function_requires(_RandomAccessIteratorConcept<
				  _RandomAccessIterator>)
      return __last - __first;
  404188:	4c 29 e2             	sub    %r12,%rdx
  40418b:	48 89 d3             	mov    %rdx,%rbx
	size_type __dnew = static_cast<size_type>(std::distance(__beg, __end));
  40418e:	48 89 54 24 08       	mov    %rdx,0x8(%rsp)
	if (__dnew > size_type(_S_local_capacity))
  404193:	48 83 fa 0f          	cmp    $0xf,%rdx
  404197:	77 37                	ja     4041d0 <void std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_construct<char const*>(char const*, char const*, std::forward_iterator_tag)+0x60>
	  { this->_S_copy_chars(_M_data(), __beg, __end); }
  404199:	48 8b 45 00          	mov    0x0(%rbp),%rax
	if (__n == 1)
  40419d:	48 83 fa 01          	cmp    $0x1,%rdx
  4041a1:	75 25                	jne    4041c8 <void std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_construct<char const*>(char const*, char const*, std::forward_iterator_tag)+0x58>
	  traits_type::assign(*__d, *__s);
  4041a3:	41 0f b6 14 24       	movzbl (%r12),%edx
  4041a8:	88 10                	mov    %dl,(%rax)
  4041aa:	48 8b 5c 24 08       	mov    0x8(%rsp),%rbx
  4041af:	48 8b 45 00          	mov    0x0(%rbp),%rax
      { _M_string_length = __length; }
  4041b3:	48 89 5d 08          	mov    %rbx,0x8(%rbp)
  4041b7:	c6 04 18 00          	movb   $0x0,(%rax,%rbx,1)
      }
  4041bb:	48 83 c4 10          	add    $0x10,%rsp
  4041bf:	5b                   	pop    %rbx
  4041c0:	5d                   	pop    %rbp
  4041c1:	41 5c                	pop    %r12
  4041c3:	c3                   	retq   
  4041c4:	0f 1f 40 00          	nopl   0x0(%rax)
	if (__n == 0)
  4041c8:	48 85 d2             	test   %rdx,%rdx
  4041cb:	74 e6                	je     4041b3 <void std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_construct<char const*>(char const*, char const*, std::forward_iterator_tag)+0x43>
  4041cd:	eb 1a                	jmp    4041e9 <void std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_construct<char const*>(char const*, char const*, std::forward_iterator_tag)+0x79>
  4041cf:	90                   	nop
	    _M_data(_M_create(__dnew, size_type(0)));
  4041d0:	31 f6                	xor    %esi,%esi
  4041d2:	48 8d 7c 24 08       	lea    0x8(%rsp),%rdi
  4041d7:	e8 44 f5 ff ff       	callq  403720 <std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_create(unsigned long&, unsigned long) [clone .isra.77]>
      { _M_allocated_capacity = __capacity; }
  4041dc:	48 8b 54 24 08       	mov    0x8(%rsp),%rdx
      { _M_dataplus._M_p = __p; }
  4041e1:	48 89 45 00          	mov    %rax,0x0(%rbp)
      { _M_allocated_capacity = __capacity; }
  4041e5:	48 89 55 10          	mov    %rdx,0x10(%rbp)
	return static_cast<char_type*>(__builtin_memcpy(__s1, __s2, __n));
  4041e9:	48 89 da             	mov    %rbx,%rdx
  4041ec:	4c 89 e6             	mov    %r12,%rsi
  4041ef:	48 89 c7             	mov    %rax,%rdi
  4041f2:	e8 b9 d7 ff ff       	callq  4019b0 <memcpy@plt>
  4041f7:	48 8b 5c 24 08       	mov    0x8(%rsp),%rbx
  4041fc:	48 8b 45 00          	mov    0x0(%rbp),%rax
  404200:	eb b1                	jmp    4041b3 <void std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_M_construct<char const*>(char const*, char const*, std::forward_iterator_tag)+0x43>
	  std::__throw_logic_error(__N("basic_string::"
  404202:	bf 28 44 40 00       	mov    $0x404428,%edi
  404207:	e8 84 d7 ff ff       	callq  401990 <std::__throw_logic_error(char const*)@plt>
  40420c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000404210 <__libc_csu_init>:
  404210:	f3 0f 1e fa          	endbr64 
  404214:	41 57                	push   %r15
  404216:	49 89 d7             	mov    %rdx,%r15
  404219:	41 56                	push   %r14
  40421b:	49 89 f6             	mov    %rsi,%r14
  40421e:	41 55                	push   %r13
  404220:	41 89 fd             	mov    %edi,%r13d
  404223:	41 54                	push   %r12
  404225:	4c 8d 25 5c 0b 20 00 	lea    0x200b5c(%rip),%r12        # 604d88 <__frame_dummy_init_array_entry>
  40422c:	55                   	push   %rbp
  40422d:	48 8d 2d 64 0b 20 00 	lea    0x200b64(%rip),%rbp        # 604d98 <__init_array_end>
  404234:	53                   	push   %rbx
  404235:	4c 29 e5             	sub    %r12,%rbp
  404238:	48 83 ec 08          	sub    $0x8,%rsp
  40423c:	e8 57 d6 ff ff       	callq  401898 <_init>
  404241:	48 c1 fd 03          	sar    $0x3,%rbp
  404245:	74 1f                	je     404266 <__libc_csu_init+0x56>
  404247:	31 db                	xor    %ebx,%ebx
  404249:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
  404250:	4c 89 fa             	mov    %r15,%rdx
  404253:	4c 89 f6             	mov    %r14,%rsi
  404256:	44 89 ef             	mov    %r13d,%edi
  404259:	41 ff 14 dc          	callq  *(%r12,%rbx,8)
  40425d:	48 83 c3 01          	add    $0x1,%rbx
  404261:	48 39 dd             	cmp    %rbx,%rbp
  404264:	75 ea                	jne    404250 <__libc_csu_init+0x40>
  404266:	48 83 c4 08          	add    $0x8,%rsp
  40426a:	5b                   	pop    %rbx
  40426b:	5d                   	pop    %rbp
  40426c:	41 5c                	pop    %r12
  40426e:	41 5d                	pop    %r13
  404270:	41 5e                	pop    %r14
  404272:	41 5f                	pop    %r15
  404274:	c3                   	retq   

0000000000404275 <.annobin___libc_csu_fini.start>:
  404275:	66 66 2e 0f 1f 84 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  40427c:	00 00 00 00 

0000000000404280 <__libc_csu_fini>:
  404280:	f3 0f 1e fa          	endbr64 
  404284:	c3                   	retq   

Disassembly of section .fini:

0000000000404288 <_fini>:
  404288:	f3 0f 1e fa          	endbr64 
  40428c:	48 83 ec 08          	sub    $0x8,%rsp
  404290:	48 83 c4 08          	add    $0x8,%rsp
  404294:	c3                   	retq   
