
_spin:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fs.h"

int
main(int argc, char *argv[]) 
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 10             	sub    $0x10,%esp
  12:	89 cb                	mov    %ecx,%ebx
  int i;
  int x = 0;
  14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  if(argc != 2) {
  1b:	83 3b 02             	cmpl   $0x2,(%ebx)
  1e:	74 05                	je     25 <main+0x25>
    exit();
  20:	e8 88 02 00 00       	call   2ad <exit>
  }

  for(i=1; i< atoi(argv[1]); i++)
  25:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  2c:	eb 0a                	jmp    38 <main+0x38>
    x += i;
  2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  31:	01 45 f0             	add    %eax,-0x10(%ebp)
  for(i=1; i< atoi(argv[1]); i++)
  34:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  38:	8b 43 04             	mov    0x4(%ebx),%eax
  3b:	83 c0 04             	add    $0x4,%eax
  3e:	8b 00                	mov    (%eax),%eax
  40:	83 ec 0c             	sub    $0xc,%esp
  43:	50                   	push   %eax
  44:	e8 d2 01 00 00       	call   21b <atoi>
  49:	83 c4 10             	add    $0x10,%esp
  4c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4f:	7c dd                	jl     2e <main+0x2e>
  exit();
  51:	e8 57 02 00 00       	call   2ad <exit>

00000056 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  56:	55                   	push   %ebp
  57:	89 e5                	mov    %esp,%ebp
  59:	57                   	push   %edi
  5a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  5e:	8b 55 10             	mov    0x10(%ebp),%edx
  61:	8b 45 0c             	mov    0xc(%ebp),%eax
  64:	89 cb                	mov    %ecx,%ebx
  66:	89 df                	mov    %ebx,%edi
  68:	89 d1                	mov    %edx,%ecx
  6a:	fc                   	cld    
  6b:	f3 aa                	rep stos %al,%es:(%edi)
  6d:	89 ca                	mov    %ecx,%edx
  6f:	89 fb                	mov    %edi,%ebx
  71:	89 5d 08             	mov    %ebx,0x8(%ebp)
  74:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  77:	90                   	nop
  78:	5b                   	pop    %ebx
  79:	5f                   	pop    %edi
  7a:	5d                   	pop    %ebp
  7b:	c3                   	ret    

0000007c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  7c:	55                   	push   %ebp
  7d:	89 e5                	mov    %esp,%ebp
  7f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  82:	8b 45 08             	mov    0x8(%ebp),%eax
  85:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  88:	90                   	nop
  89:	8b 55 0c             	mov    0xc(%ebp),%edx
  8c:	8d 42 01             	lea    0x1(%edx),%eax
  8f:	89 45 0c             	mov    %eax,0xc(%ebp)
  92:	8b 45 08             	mov    0x8(%ebp),%eax
  95:	8d 48 01             	lea    0x1(%eax),%ecx
  98:	89 4d 08             	mov    %ecx,0x8(%ebp)
  9b:	0f b6 12             	movzbl (%edx),%edx
  9e:	88 10                	mov    %dl,(%eax)
  a0:	0f b6 00             	movzbl (%eax),%eax
  a3:	84 c0                	test   %al,%al
  a5:	75 e2                	jne    89 <strcpy+0xd>
    ;
  return os;
  a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  aa:	c9                   	leave  
  ab:	c3                   	ret    

000000ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ac:	55                   	push   %ebp
  ad:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  af:	eb 08                	jmp    b9 <strcmp+0xd>
    p++, q++;
  b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  b5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  b9:	8b 45 08             	mov    0x8(%ebp),%eax
  bc:	0f b6 00             	movzbl (%eax),%eax
  bf:	84 c0                	test   %al,%al
  c1:	74 10                	je     d3 <strcmp+0x27>
  c3:	8b 45 08             	mov    0x8(%ebp),%eax
  c6:	0f b6 10             	movzbl (%eax),%edx
  c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  cc:	0f b6 00             	movzbl (%eax),%eax
  cf:	38 c2                	cmp    %al,%dl
  d1:	74 de                	je     b1 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
  d3:	8b 45 08             	mov    0x8(%ebp),%eax
  d6:	0f b6 00             	movzbl (%eax),%eax
  d9:	0f b6 d0             	movzbl %al,%edx
  dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  df:	0f b6 00             	movzbl (%eax),%eax
  e2:	0f b6 c8             	movzbl %al,%ecx
  e5:	89 d0                	mov    %edx,%eax
  e7:	29 c8                	sub    %ecx,%eax
}
  e9:	5d                   	pop    %ebp
  ea:	c3                   	ret    

000000eb <strlen>:

uint
strlen(const char *s)
{
  eb:	55                   	push   %ebp
  ec:	89 e5                	mov    %esp,%ebp
  ee:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  f8:	eb 04                	jmp    fe <strlen+0x13>
  fa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
 101:	8b 45 08             	mov    0x8(%ebp),%eax
 104:	01 d0                	add    %edx,%eax
 106:	0f b6 00             	movzbl (%eax),%eax
 109:	84 c0                	test   %al,%al
 10b:	75 ed                	jne    fa <strlen+0xf>
    ;
  return n;
 10d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 110:	c9                   	leave  
 111:	c3                   	ret    

00000112 <memset>:

void*
memset(void *dst, int c, uint n)
{
 112:	55                   	push   %ebp
 113:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 115:	8b 45 10             	mov    0x10(%ebp),%eax
 118:	50                   	push   %eax
 119:	ff 75 0c             	push   0xc(%ebp)
 11c:	ff 75 08             	push   0x8(%ebp)
 11f:	e8 32 ff ff ff       	call   56 <stosb>
 124:	83 c4 0c             	add    $0xc,%esp
  return dst;
 127:	8b 45 08             	mov    0x8(%ebp),%eax
}
 12a:	c9                   	leave  
 12b:	c3                   	ret    

0000012c <strchr>:

char*
strchr(const char *s, char c)
{
 12c:	55                   	push   %ebp
 12d:	89 e5                	mov    %esp,%ebp
 12f:	83 ec 04             	sub    $0x4,%esp
 132:	8b 45 0c             	mov    0xc(%ebp),%eax
 135:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 138:	eb 14                	jmp    14e <strchr+0x22>
    if(*s == c)
 13a:	8b 45 08             	mov    0x8(%ebp),%eax
 13d:	0f b6 00             	movzbl (%eax),%eax
 140:	38 45 fc             	cmp    %al,-0x4(%ebp)
 143:	75 05                	jne    14a <strchr+0x1e>
      return (char*)s;
 145:	8b 45 08             	mov    0x8(%ebp),%eax
 148:	eb 13                	jmp    15d <strchr+0x31>
  for(; *s; s++)
 14a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 14e:	8b 45 08             	mov    0x8(%ebp),%eax
 151:	0f b6 00             	movzbl (%eax),%eax
 154:	84 c0                	test   %al,%al
 156:	75 e2                	jne    13a <strchr+0xe>
  return 0;
 158:	b8 00 00 00 00       	mov    $0x0,%eax
}
 15d:	c9                   	leave  
 15e:	c3                   	ret    

0000015f <gets>:

char*
gets(char *buf, int max)
{
 15f:	55                   	push   %ebp
 160:	89 e5                	mov    %esp,%ebp
 162:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 165:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 16c:	eb 42                	jmp    1b0 <gets+0x51>
    cc = read(0, &c, 1);
 16e:	83 ec 04             	sub    $0x4,%esp
 171:	6a 01                	push   $0x1
 173:	8d 45 ef             	lea    -0x11(%ebp),%eax
 176:	50                   	push   %eax
 177:	6a 00                	push   $0x0
 179:	e8 47 01 00 00       	call   2c5 <read>
 17e:	83 c4 10             	add    $0x10,%esp
 181:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 184:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 188:	7e 33                	jle    1bd <gets+0x5e>
      break;
    buf[i++] = c;
 18a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18d:	8d 50 01             	lea    0x1(%eax),%edx
 190:	89 55 f4             	mov    %edx,-0xc(%ebp)
 193:	89 c2                	mov    %eax,%edx
 195:	8b 45 08             	mov    0x8(%ebp),%eax
 198:	01 c2                	add    %eax,%edx
 19a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 19e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1a0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1a4:	3c 0a                	cmp    $0xa,%al
 1a6:	74 16                	je     1be <gets+0x5f>
 1a8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ac:	3c 0d                	cmp    $0xd,%al
 1ae:	74 0e                	je     1be <gets+0x5f>
  for(i=0; i+1 < max; ){
 1b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b3:	83 c0 01             	add    $0x1,%eax
 1b6:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1b9:	7f b3                	jg     16e <gets+0xf>
 1bb:	eb 01                	jmp    1be <gets+0x5f>
      break;
 1bd:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1be:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1c1:	8b 45 08             	mov    0x8(%ebp),%eax
 1c4:	01 d0                	add    %edx,%eax
 1c6:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1c9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1cc:	c9                   	leave  
 1cd:	c3                   	ret    

000001ce <stat>:

int
stat(const char *n, struct stat *st)
{
 1ce:	55                   	push   %ebp
 1cf:	89 e5                	mov    %esp,%ebp
 1d1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d4:	83 ec 08             	sub    $0x8,%esp
 1d7:	6a 00                	push   $0x0
 1d9:	ff 75 08             	push   0x8(%ebp)
 1dc:	e8 0c 01 00 00       	call   2ed <open>
 1e1:	83 c4 10             	add    $0x10,%esp
 1e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1eb:	79 07                	jns    1f4 <stat+0x26>
    return -1;
 1ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1f2:	eb 25                	jmp    219 <stat+0x4b>
  r = fstat(fd, st);
 1f4:	83 ec 08             	sub    $0x8,%esp
 1f7:	ff 75 0c             	push   0xc(%ebp)
 1fa:	ff 75 f4             	push   -0xc(%ebp)
 1fd:	e8 03 01 00 00       	call   305 <fstat>
 202:	83 c4 10             	add    $0x10,%esp
 205:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 208:	83 ec 0c             	sub    $0xc,%esp
 20b:	ff 75 f4             	push   -0xc(%ebp)
 20e:	e8 c2 00 00 00       	call   2d5 <close>
 213:	83 c4 10             	add    $0x10,%esp
  return r;
 216:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 219:	c9                   	leave  
 21a:	c3                   	ret    

0000021b <atoi>:

int
atoi(const char *s)
{
 21b:	55                   	push   %ebp
 21c:	89 e5                	mov    %esp,%ebp
 21e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 221:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 228:	eb 25                	jmp    24f <atoi+0x34>
    n = n*10 + *s++ - '0';
 22a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 22d:	89 d0                	mov    %edx,%eax
 22f:	c1 e0 02             	shl    $0x2,%eax
 232:	01 d0                	add    %edx,%eax
 234:	01 c0                	add    %eax,%eax
 236:	89 c1                	mov    %eax,%ecx
 238:	8b 45 08             	mov    0x8(%ebp),%eax
 23b:	8d 50 01             	lea    0x1(%eax),%edx
 23e:	89 55 08             	mov    %edx,0x8(%ebp)
 241:	0f b6 00             	movzbl (%eax),%eax
 244:	0f be c0             	movsbl %al,%eax
 247:	01 c8                	add    %ecx,%eax
 249:	83 e8 30             	sub    $0x30,%eax
 24c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 24f:	8b 45 08             	mov    0x8(%ebp),%eax
 252:	0f b6 00             	movzbl (%eax),%eax
 255:	3c 2f                	cmp    $0x2f,%al
 257:	7e 0a                	jle    263 <atoi+0x48>
 259:	8b 45 08             	mov    0x8(%ebp),%eax
 25c:	0f b6 00             	movzbl (%eax),%eax
 25f:	3c 39                	cmp    $0x39,%al
 261:	7e c7                	jle    22a <atoi+0xf>
  return n;
 263:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 266:	c9                   	leave  
 267:	c3                   	ret    

00000268 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 268:	55                   	push   %ebp
 269:	89 e5                	mov    %esp,%ebp
 26b:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 26e:	8b 45 08             	mov    0x8(%ebp),%eax
 271:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 274:	8b 45 0c             	mov    0xc(%ebp),%eax
 277:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 27a:	eb 17                	jmp    293 <memmove+0x2b>
    *dst++ = *src++;
 27c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 27f:	8d 42 01             	lea    0x1(%edx),%eax
 282:	89 45 f8             	mov    %eax,-0x8(%ebp)
 285:	8b 45 fc             	mov    -0x4(%ebp),%eax
 288:	8d 48 01             	lea    0x1(%eax),%ecx
 28b:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 28e:	0f b6 12             	movzbl (%edx),%edx
 291:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 293:	8b 45 10             	mov    0x10(%ebp),%eax
 296:	8d 50 ff             	lea    -0x1(%eax),%edx
 299:	89 55 10             	mov    %edx,0x10(%ebp)
 29c:	85 c0                	test   %eax,%eax
 29e:	7f dc                	jg     27c <memmove+0x14>
  return vdst;
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a3:	c9                   	leave  
 2a4:	c3                   	ret    

000002a5 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2a5:	b8 01 00 00 00       	mov    $0x1,%eax
 2aa:	cd 40                	int    $0x40
 2ac:	c3                   	ret    

000002ad <exit>:
SYSCALL(exit)
 2ad:	b8 02 00 00 00       	mov    $0x2,%eax
 2b2:	cd 40                	int    $0x40
 2b4:	c3                   	ret    

000002b5 <wait>:
SYSCALL(wait)
 2b5:	b8 03 00 00 00       	mov    $0x3,%eax
 2ba:	cd 40                	int    $0x40
 2bc:	c3                   	ret    

000002bd <pipe>:
SYSCALL(pipe)
 2bd:	b8 04 00 00 00       	mov    $0x4,%eax
 2c2:	cd 40                	int    $0x40
 2c4:	c3                   	ret    

000002c5 <read>:
SYSCALL(read)
 2c5:	b8 05 00 00 00       	mov    $0x5,%eax
 2ca:	cd 40                	int    $0x40
 2cc:	c3                   	ret    

000002cd <write>:
SYSCALL(write)
 2cd:	b8 10 00 00 00       	mov    $0x10,%eax
 2d2:	cd 40                	int    $0x40
 2d4:	c3                   	ret    

000002d5 <close>:
SYSCALL(close)
 2d5:	b8 15 00 00 00       	mov    $0x15,%eax
 2da:	cd 40                	int    $0x40
 2dc:	c3                   	ret    

000002dd <kill>:
SYSCALL(kill)
 2dd:	b8 06 00 00 00       	mov    $0x6,%eax
 2e2:	cd 40                	int    $0x40
 2e4:	c3                   	ret    

000002e5 <exec>:
SYSCALL(exec)
 2e5:	b8 07 00 00 00       	mov    $0x7,%eax
 2ea:	cd 40                	int    $0x40
 2ec:	c3                   	ret    

000002ed <open>:
SYSCALL(open)
 2ed:	b8 0f 00 00 00       	mov    $0xf,%eax
 2f2:	cd 40                	int    $0x40
 2f4:	c3                   	ret    

000002f5 <mknod>:
SYSCALL(mknod)
 2f5:	b8 11 00 00 00       	mov    $0x11,%eax
 2fa:	cd 40                	int    $0x40
 2fc:	c3                   	ret    

000002fd <unlink>:
SYSCALL(unlink)
 2fd:	b8 12 00 00 00       	mov    $0x12,%eax
 302:	cd 40                	int    $0x40
 304:	c3                   	ret    

00000305 <fstat>:
SYSCALL(fstat)
 305:	b8 08 00 00 00       	mov    $0x8,%eax
 30a:	cd 40                	int    $0x40
 30c:	c3                   	ret    

0000030d <link>:
SYSCALL(link)
 30d:	b8 13 00 00 00       	mov    $0x13,%eax
 312:	cd 40                	int    $0x40
 314:	c3                   	ret    

00000315 <mkdir>:
SYSCALL(mkdir)
 315:	b8 14 00 00 00       	mov    $0x14,%eax
 31a:	cd 40                	int    $0x40
 31c:	c3                   	ret    

0000031d <chdir>:
SYSCALL(chdir)
 31d:	b8 09 00 00 00       	mov    $0x9,%eax
 322:	cd 40                	int    $0x40
 324:	c3                   	ret    

00000325 <dup>:
SYSCALL(dup)
 325:	b8 0a 00 00 00       	mov    $0xa,%eax
 32a:	cd 40                	int    $0x40
 32c:	c3                   	ret    

0000032d <getpid>:
SYSCALL(getpid)
 32d:	b8 0b 00 00 00       	mov    $0xb,%eax
 332:	cd 40                	int    $0x40
 334:	c3                   	ret    

00000335 <sbrk>:
SYSCALL(sbrk)
 335:	b8 0c 00 00 00       	mov    $0xc,%eax
 33a:	cd 40                	int    $0x40
 33c:	c3                   	ret    

0000033d <sleep>:
SYSCALL(sleep)
 33d:	b8 0d 00 00 00       	mov    $0xd,%eax
 342:	cd 40                	int    $0x40
 344:	c3                   	ret    

00000345 <uptime>:
SYSCALL(uptime)
 345:	b8 0e 00 00 00       	mov    $0xe,%eax
 34a:	cd 40                	int    $0x40
 34c:	c3                   	ret    

0000034d <nice>:
SYSCALL(nice)
 34d:	b8 16 00 00 00       	mov    $0x16,%eax
 352:	cd 40                	int    $0x40
 354:	c3                   	ret    

00000355 <getschedstate>:
SYSCALL(getschedstate)
 355:	b8 17 00 00 00       	mov    $0x17,%eax
 35a:	cd 40                	int    $0x40
 35c:	c3                   	ret    

0000035d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 35d:	55                   	push   %ebp
 35e:	89 e5                	mov    %esp,%ebp
 360:	83 ec 18             	sub    $0x18,%esp
 363:	8b 45 0c             	mov    0xc(%ebp),%eax
 366:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 369:	83 ec 04             	sub    $0x4,%esp
 36c:	6a 01                	push   $0x1
 36e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 371:	50                   	push   %eax
 372:	ff 75 08             	push   0x8(%ebp)
 375:	e8 53 ff ff ff       	call   2cd <write>
 37a:	83 c4 10             	add    $0x10,%esp
}
 37d:	90                   	nop
 37e:	c9                   	leave  
 37f:	c3                   	ret    

00000380 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 380:	55                   	push   %ebp
 381:	89 e5                	mov    %esp,%ebp
 383:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 386:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 38d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 391:	74 17                	je     3aa <printint+0x2a>
 393:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 397:	79 11                	jns    3aa <printint+0x2a>
    neg = 1;
 399:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a3:	f7 d8                	neg    %eax
 3a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3a8:	eb 06                	jmp    3b0 <printint+0x30>
  } else {
    x = xx;
 3aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3bd:	ba 00 00 00 00       	mov    $0x0,%edx
 3c2:	f7 f1                	div    %ecx
 3c4:	89 d1                	mov    %edx,%ecx
 3c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c9:	8d 50 01             	lea    0x1(%eax),%edx
 3cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3cf:	0f b6 91 38 0a 00 00 	movzbl 0xa38(%ecx),%edx
 3d6:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3da:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3e0:	ba 00 00 00 00       	mov    $0x0,%edx
 3e5:	f7 f1                	div    %ecx
 3e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ea:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3ee:	75 c7                	jne    3b7 <printint+0x37>
  if(neg)
 3f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3f4:	74 2d                	je     423 <printint+0xa3>
    buf[i++] = '-';
 3f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f9:	8d 50 01             	lea    0x1(%eax),%edx
 3fc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3ff:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 404:	eb 1d                	jmp    423 <printint+0xa3>
    putc(fd, buf[i]);
 406:	8d 55 dc             	lea    -0x24(%ebp),%edx
 409:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40c:	01 d0                	add    %edx,%eax
 40e:	0f b6 00             	movzbl (%eax),%eax
 411:	0f be c0             	movsbl %al,%eax
 414:	83 ec 08             	sub    $0x8,%esp
 417:	50                   	push   %eax
 418:	ff 75 08             	push   0x8(%ebp)
 41b:	e8 3d ff ff ff       	call   35d <putc>
 420:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 423:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 427:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 42b:	79 d9                	jns    406 <printint+0x86>
}
 42d:	90                   	nop
 42e:	90                   	nop
 42f:	c9                   	leave  
 430:	c3                   	ret    

00000431 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 431:	55                   	push   %ebp
 432:	89 e5                	mov    %esp,%ebp
 434:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 437:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 43e:	8d 45 0c             	lea    0xc(%ebp),%eax
 441:	83 c0 04             	add    $0x4,%eax
 444:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 447:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 44e:	e9 59 01 00 00       	jmp    5ac <printf+0x17b>
    c = fmt[i] & 0xff;
 453:	8b 55 0c             	mov    0xc(%ebp),%edx
 456:	8b 45 f0             	mov    -0x10(%ebp),%eax
 459:	01 d0                	add    %edx,%eax
 45b:	0f b6 00             	movzbl (%eax),%eax
 45e:	0f be c0             	movsbl %al,%eax
 461:	25 ff 00 00 00       	and    $0xff,%eax
 466:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 469:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 46d:	75 2c                	jne    49b <printf+0x6a>
      if(c == '%'){
 46f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 473:	75 0c                	jne    481 <printf+0x50>
        state = '%';
 475:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 47c:	e9 27 01 00 00       	jmp    5a8 <printf+0x177>
      } else {
        putc(fd, c);
 481:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 484:	0f be c0             	movsbl %al,%eax
 487:	83 ec 08             	sub    $0x8,%esp
 48a:	50                   	push   %eax
 48b:	ff 75 08             	push   0x8(%ebp)
 48e:	e8 ca fe ff ff       	call   35d <putc>
 493:	83 c4 10             	add    $0x10,%esp
 496:	e9 0d 01 00 00       	jmp    5a8 <printf+0x177>
      }
    } else if(state == '%'){
 49b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 49f:	0f 85 03 01 00 00    	jne    5a8 <printf+0x177>
      if(c == 'd'){
 4a5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4a9:	75 1e                	jne    4c9 <printf+0x98>
        printint(fd, *ap, 10, 1);
 4ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ae:	8b 00                	mov    (%eax),%eax
 4b0:	6a 01                	push   $0x1
 4b2:	6a 0a                	push   $0xa
 4b4:	50                   	push   %eax
 4b5:	ff 75 08             	push   0x8(%ebp)
 4b8:	e8 c3 fe ff ff       	call   380 <printint>
 4bd:	83 c4 10             	add    $0x10,%esp
        ap++;
 4c0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4c4:	e9 d8 00 00 00       	jmp    5a1 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4c9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4cd:	74 06                	je     4d5 <printf+0xa4>
 4cf:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4d3:	75 1e                	jne    4f3 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d8:	8b 00                	mov    (%eax),%eax
 4da:	6a 00                	push   $0x0
 4dc:	6a 10                	push   $0x10
 4de:	50                   	push   %eax
 4df:	ff 75 08             	push   0x8(%ebp)
 4e2:	e8 99 fe ff ff       	call   380 <printint>
 4e7:	83 c4 10             	add    $0x10,%esp
        ap++;
 4ea:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4ee:	e9 ae 00 00 00       	jmp    5a1 <printf+0x170>
      } else if(c == 's'){
 4f3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4f7:	75 43                	jne    53c <printf+0x10b>
        s = (char*)*ap;
 4f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4fc:	8b 00                	mov    (%eax),%eax
 4fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 501:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 505:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 509:	75 25                	jne    530 <printf+0xff>
          s = "(null)";
 50b:	c7 45 f4 e8 07 00 00 	movl   $0x7e8,-0xc(%ebp)
        while(*s != 0){
 512:	eb 1c                	jmp    530 <printf+0xff>
          putc(fd, *s);
 514:	8b 45 f4             	mov    -0xc(%ebp),%eax
 517:	0f b6 00             	movzbl (%eax),%eax
 51a:	0f be c0             	movsbl %al,%eax
 51d:	83 ec 08             	sub    $0x8,%esp
 520:	50                   	push   %eax
 521:	ff 75 08             	push   0x8(%ebp)
 524:	e8 34 fe ff ff       	call   35d <putc>
 529:	83 c4 10             	add    $0x10,%esp
          s++;
 52c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 530:	8b 45 f4             	mov    -0xc(%ebp),%eax
 533:	0f b6 00             	movzbl (%eax),%eax
 536:	84 c0                	test   %al,%al
 538:	75 da                	jne    514 <printf+0xe3>
 53a:	eb 65                	jmp    5a1 <printf+0x170>
        }
      } else if(c == 'c'){
 53c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 540:	75 1d                	jne    55f <printf+0x12e>
        putc(fd, *ap);
 542:	8b 45 e8             	mov    -0x18(%ebp),%eax
 545:	8b 00                	mov    (%eax),%eax
 547:	0f be c0             	movsbl %al,%eax
 54a:	83 ec 08             	sub    $0x8,%esp
 54d:	50                   	push   %eax
 54e:	ff 75 08             	push   0x8(%ebp)
 551:	e8 07 fe ff ff       	call   35d <putc>
 556:	83 c4 10             	add    $0x10,%esp
        ap++;
 559:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 55d:	eb 42                	jmp    5a1 <printf+0x170>
      } else if(c == '%'){
 55f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 563:	75 17                	jne    57c <printf+0x14b>
        putc(fd, c);
 565:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 568:	0f be c0             	movsbl %al,%eax
 56b:	83 ec 08             	sub    $0x8,%esp
 56e:	50                   	push   %eax
 56f:	ff 75 08             	push   0x8(%ebp)
 572:	e8 e6 fd ff ff       	call   35d <putc>
 577:	83 c4 10             	add    $0x10,%esp
 57a:	eb 25                	jmp    5a1 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 57c:	83 ec 08             	sub    $0x8,%esp
 57f:	6a 25                	push   $0x25
 581:	ff 75 08             	push   0x8(%ebp)
 584:	e8 d4 fd ff ff       	call   35d <putc>
 589:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 58c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 58f:	0f be c0             	movsbl %al,%eax
 592:	83 ec 08             	sub    $0x8,%esp
 595:	50                   	push   %eax
 596:	ff 75 08             	push   0x8(%ebp)
 599:	e8 bf fd ff ff       	call   35d <putc>
 59e:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5a1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5a8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5ac:	8b 55 0c             	mov    0xc(%ebp),%edx
 5af:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5b2:	01 d0                	add    %edx,%eax
 5b4:	0f b6 00             	movzbl (%eax),%eax
 5b7:	84 c0                	test   %al,%al
 5b9:	0f 85 94 fe ff ff    	jne    453 <printf+0x22>
    }
  }
}
 5bf:	90                   	nop
 5c0:	90                   	nop
 5c1:	c9                   	leave  
 5c2:	c3                   	ret    

000005c3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5c3:	55                   	push   %ebp
 5c4:	89 e5                	mov    %esp,%ebp
 5c6:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5c9:	8b 45 08             	mov    0x8(%ebp),%eax
 5cc:	83 e8 08             	sub    $0x8,%eax
 5cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5d2:	a1 54 0a 00 00       	mov    0xa54,%eax
 5d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5da:	eb 24                	jmp    600 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5df:	8b 00                	mov    (%eax),%eax
 5e1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5e4:	72 12                	jb     5f8 <free+0x35>
 5e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5e9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5ec:	77 24                	ja     612 <free+0x4f>
 5ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f1:	8b 00                	mov    (%eax),%eax
 5f3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 5f6:	72 1a                	jb     612 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5fb:	8b 00                	mov    (%eax),%eax
 5fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
 600:	8b 45 f8             	mov    -0x8(%ebp),%eax
 603:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 606:	76 d4                	jbe    5dc <free+0x19>
 608:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60b:	8b 00                	mov    (%eax),%eax
 60d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 610:	73 ca                	jae    5dc <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 612:	8b 45 f8             	mov    -0x8(%ebp),%eax
 615:	8b 40 04             	mov    0x4(%eax),%eax
 618:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 61f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 622:	01 c2                	add    %eax,%edx
 624:	8b 45 fc             	mov    -0x4(%ebp),%eax
 627:	8b 00                	mov    (%eax),%eax
 629:	39 c2                	cmp    %eax,%edx
 62b:	75 24                	jne    651 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 62d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 630:	8b 50 04             	mov    0x4(%eax),%edx
 633:	8b 45 fc             	mov    -0x4(%ebp),%eax
 636:	8b 00                	mov    (%eax),%eax
 638:	8b 40 04             	mov    0x4(%eax),%eax
 63b:	01 c2                	add    %eax,%edx
 63d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 640:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 643:	8b 45 fc             	mov    -0x4(%ebp),%eax
 646:	8b 00                	mov    (%eax),%eax
 648:	8b 10                	mov    (%eax),%edx
 64a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64d:	89 10                	mov    %edx,(%eax)
 64f:	eb 0a                	jmp    65b <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 651:	8b 45 fc             	mov    -0x4(%ebp),%eax
 654:	8b 10                	mov    (%eax),%edx
 656:	8b 45 f8             	mov    -0x8(%ebp),%eax
 659:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 65b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65e:	8b 40 04             	mov    0x4(%eax),%eax
 661:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 668:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66b:	01 d0                	add    %edx,%eax
 66d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 670:	75 20                	jne    692 <free+0xcf>
    p->s.size += bp->s.size;
 672:	8b 45 fc             	mov    -0x4(%ebp),%eax
 675:	8b 50 04             	mov    0x4(%eax),%edx
 678:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67b:	8b 40 04             	mov    0x4(%eax),%eax
 67e:	01 c2                	add    %eax,%edx
 680:	8b 45 fc             	mov    -0x4(%ebp),%eax
 683:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 686:	8b 45 f8             	mov    -0x8(%ebp),%eax
 689:	8b 10                	mov    (%eax),%edx
 68b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68e:	89 10                	mov    %edx,(%eax)
 690:	eb 08                	jmp    69a <free+0xd7>
  } else
    p->s.ptr = bp;
 692:	8b 45 fc             	mov    -0x4(%ebp),%eax
 695:	8b 55 f8             	mov    -0x8(%ebp),%edx
 698:	89 10                	mov    %edx,(%eax)
  freep = p;
 69a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69d:	a3 54 0a 00 00       	mov    %eax,0xa54
}
 6a2:	90                   	nop
 6a3:	c9                   	leave  
 6a4:	c3                   	ret    

000006a5 <morecore>:

static Header*
morecore(uint nu)
{
 6a5:	55                   	push   %ebp
 6a6:	89 e5                	mov    %esp,%ebp
 6a8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6ab:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6b2:	77 07                	ja     6bb <morecore+0x16>
    nu = 4096;
 6b4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6bb:	8b 45 08             	mov    0x8(%ebp),%eax
 6be:	c1 e0 03             	shl    $0x3,%eax
 6c1:	83 ec 0c             	sub    $0xc,%esp
 6c4:	50                   	push   %eax
 6c5:	e8 6b fc ff ff       	call   335 <sbrk>
 6ca:	83 c4 10             	add    $0x10,%esp
 6cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6d0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6d4:	75 07                	jne    6dd <morecore+0x38>
    return 0;
 6d6:	b8 00 00 00 00       	mov    $0x0,%eax
 6db:	eb 26                	jmp    703 <morecore+0x5e>
  hp = (Header*)p;
 6dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e6:	8b 55 08             	mov    0x8(%ebp),%edx
 6e9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ef:	83 c0 08             	add    $0x8,%eax
 6f2:	83 ec 0c             	sub    $0xc,%esp
 6f5:	50                   	push   %eax
 6f6:	e8 c8 fe ff ff       	call   5c3 <free>
 6fb:	83 c4 10             	add    $0x10,%esp
  return freep;
 6fe:	a1 54 0a 00 00       	mov    0xa54,%eax
}
 703:	c9                   	leave  
 704:	c3                   	ret    

00000705 <malloc>:

void*
malloc(uint nbytes)
{
 705:	55                   	push   %ebp
 706:	89 e5                	mov    %esp,%ebp
 708:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 70b:	8b 45 08             	mov    0x8(%ebp),%eax
 70e:	83 c0 07             	add    $0x7,%eax
 711:	c1 e8 03             	shr    $0x3,%eax
 714:	83 c0 01             	add    $0x1,%eax
 717:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 71a:	a1 54 0a 00 00       	mov    0xa54,%eax
 71f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 722:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 726:	75 23                	jne    74b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 728:	c7 45 f0 4c 0a 00 00 	movl   $0xa4c,-0x10(%ebp)
 72f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 732:	a3 54 0a 00 00       	mov    %eax,0xa54
 737:	a1 54 0a 00 00       	mov    0xa54,%eax
 73c:	a3 4c 0a 00 00       	mov    %eax,0xa4c
    base.s.size = 0;
 741:	c7 05 50 0a 00 00 00 	movl   $0x0,0xa50
 748:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 74b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74e:	8b 00                	mov    (%eax),%eax
 750:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 753:	8b 45 f4             	mov    -0xc(%ebp),%eax
 756:	8b 40 04             	mov    0x4(%eax),%eax
 759:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 75c:	77 4d                	ja     7ab <malloc+0xa6>
      if(p->s.size == nunits)
 75e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 761:	8b 40 04             	mov    0x4(%eax),%eax
 764:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 767:	75 0c                	jne    775 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 769:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76c:	8b 10                	mov    (%eax),%edx
 76e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 771:	89 10                	mov    %edx,(%eax)
 773:	eb 26                	jmp    79b <malloc+0x96>
      else {
        p->s.size -= nunits;
 775:	8b 45 f4             	mov    -0xc(%ebp),%eax
 778:	8b 40 04             	mov    0x4(%eax),%eax
 77b:	2b 45 ec             	sub    -0x14(%ebp),%eax
 77e:	89 c2                	mov    %eax,%edx
 780:	8b 45 f4             	mov    -0xc(%ebp),%eax
 783:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 786:	8b 45 f4             	mov    -0xc(%ebp),%eax
 789:	8b 40 04             	mov    0x4(%eax),%eax
 78c:	c1 e0 03             	shl    $0x3,%eax
 78f:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 792:	8b 45 f4             	mov    -0xc(%ebp),%eax
 795:	8b 55 ec             	mov    -0x14(%ebp),%edx
 798:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 79b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79e:	a3 54 0a 00 00       	mov    %eax,0xa54
      return (void*)(p + 1);
 7a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a6:	83 c0 08             	add    $0x8,%eax
 7a9:	eb 3b                	jmp    7e6 <malloc+0xe1>
    }
    if(p == freep)
 7ab:	a1 54 0a 00 00       	mov    0xa54,%eax
 7b0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7b3:	75 1e                	jne    7d3 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7b5:	83 ec 0c             	sub    $0xc,%esp
 7b8:	ff 75 ec             	push   -0x14(%ebp)
 7bb:	e8 e5 fe ff ff       	call   6a5 <morecore>
 7c0:	83 c4 10             	add    $0x10,%esp
 7c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ca:	75 07                	jne    7d3 <malloc+0xce>
        return 0;
 7cc:	b8 00 00 00 00       	mov    $0x0,%eax
 7d1:	eb 13                	jmp    7e6 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dc:	8b 00                	mov    (%eax),%eax
 7de:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7e1:	e9 6d ff ff ff       	jmp    753 <malloc+0x4e>
  }
}
 7e6:	c9                   	leave  
 7e7:	c3                   	ret    
