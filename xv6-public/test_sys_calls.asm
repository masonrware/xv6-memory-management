
_test_sys_calls:     file format elf32-i386


Disassembly of section .text:

00000000 <spin>:
#include "user.h"
#include "psched.h"
#define PROC 4

void spin()
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 10             	sub    $0x10,%esp
    int i = 0;
   7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
    int j = 0;
   e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int k = 0;
  15:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(i = 0; i < 100; ++i) {
  1c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  23:	eb 48                	jmp    6d <spin+0x6d>
        for(j = 0; j < 10000000; ++j) {
  25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  2c:	eb 32                	jmp    60 <spin+0x60>
            k = j % 10;
  2e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  31:	ba 67 66 66 66       	mov    $0x66666667,%edx
  36:	89 c8                	mov    %ecx,%eax
  38:	f7 ea                	imul   %edx
  3a:	89 d0                	mov    %edx,%eax
  3c:	c1 f8 02             	sar    $0x2,%eax
  3f:	89 cb                	mov    %ecx,%ebx
  41:	c1 fb 1f             	sar    $0x1f,%ebx
  44:	29 d8                	sub    %ebx,%eax
  46:	89 c2                	mov    %eax,%edx
  48:	89 d0                	mov    %edx,%eax
  4a:	c1 e0 02             	shl    $0x2,%eax
  4d:	01 d0                	add    %edx,%eax
  4f:	01 c0                	add    %eax,%eax
  51:	29 c1                	sub    %eax,%ecx
  53:	89 ca                	mov    %ecx,%edx
  55:	89 55 f0             	mov    %edx,-0x10(%ebp)
            k = k + 1;
  58:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
        for(j = 0; j < 10000000; ++j) {
  5c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  60:	81 7d f4 7f 96 98 00 	cmpl   $0x98967f,-0xc(%ebp)
  67:	7e c5                	jle    2e <spin+0x2e>
    for(i = 0; i < 100; ++i) {
  69:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  6d:	83 7d f8 63          	cmpl   $0x63,-0x8(%ebp)
  71:	7e b2                	jle    25 <spin+0x25>
        }
    }
}
  73:	90                   	nop
  74:	90                   	nop
  75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  78:	c9                   	leave  
  79:	c3                   	ret    

0000007a <spin2>:

void spin2()
{
  7a:	55                   	push   %ebp
  7b:	89 e5                	mov    %esp,%ebp
  7d:	53                   	push   %ebx
  7e:	83 ec 10             	sub    $0x10,%esp
    int j = 0;
  81:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
    int k = 0;
  88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        for(j = 0; j < 10000000; ++j) {
  8f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  96:	eb 32                	jmp    ca <spin2+0x50>
            k = j % 10;
  98:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  9b:	ba 67 66 66 66       	mov    $0x66666667,%edx
  a0:	89 c8                	mov    %ecx,%eax
  a2:	f7 ea                	imul   %edx
  a4:	89 d0                	mov    %edx,%eax
  a6:	c1 f8 02             	sar    $0x2,%eax
  a9:	89 cb                	mov    %ecx,%ebx
  ab:	c1 fb 1f             	sar    $0x1f,%ebx
  ae:	29 d8                	sub    %ebx,%eax
  b0:	89 c2                	mov    %eax,%edx
  b2:	89 d0                	mov    %edx,%eax
  b4:	c1 e0 02             	shl    $0x2,%eax
  b7:	01 d0                	add    %edx,%eax
  b9:	01 c0                	add    %eax,%eax
  bb:	29 c1                	sub    %eax,%ecx
  bd:	89 ca                	mov    %ecx,%edx
  bf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            k = k + 1;
  c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        for(j = 0; j < 10000000; ++j) {
  c6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  ca:	81 7d f8 7f 96 98 00 	cmpl   $0x98967f,-0x8(%ebp)
  d1:	7e c5                	jle    98 <spin2+0x1e>
        }
}
  d3:	90                   	nop
  d4:	90                   	nop
  d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  d8:	c9                   	leave  
  d9:	c3                   	ret    

000000da <main>:

int
main(int argc, char *argv[])
{
  da:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  de:	83 e4 f0             	and    $0xfffffff0,%esp
  e1:	ff 71 fc             	push   -0x4(%ecx)
  e4:	55                   	push   %ebp
  e5:	89 e5                	mov    %esp,%ebp
  e7:	51                   	push   %ecx
  e8:	81 ec 14 06 00 00    	sub    $0x614,%esp
    struct pschedinfo st;
    int count = 0;
  ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int i = 0;
  f5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    int pid[NPROC];
    printf(1,"Spinning...\n");
  fc:	83 ec 08             	sub    $0x8,%esp
  ff:	68 34 0a 00 00       	push   $0xa34
 104:	6a 01                	push   $0x1
 106:	e8 70 05 00 00       	call   67b <printf>
 10b:	83 c4 10             	add    $0x10,%esp
    while(i < PROC) {
 10e:	eb 5d                	jmp    16d <main+0x93>
        pid[i] = fork();
 110:	e8 da 03 00 00       	call   4ef <fork>
 115:	8b 55 f0             	mov    -0x10(%ebp),%edx
 118:	89 84 95 ec f9 ff ff 	mov    %eax,-0x614(%ebp,%edx,4)
        if(pid[i] == 0) {
 11f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 122:	8b 84 85 ec f9 ff ff 	mov    -0x614(%ebp,%eax,4),%eax
 129:	85 c0                	test   %eax,%eax
 12b:	75 3c                	jne    169 <main+0x8f>
            int n;
            for (n = 0; n < 100; n++) {
 12d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
 134:	eb 28                	jmp    15e <main+0x84>
                if (i%2) {
 136:	8b 45 f0             	mov    -0x10(%ebp),%eax
 139:	83 e0 01             	and    $0x1,%eax
 13c:	85 c0                	test   %eax,%eax
 13e:	74 07                	je     147 <main+0x6d>
                    spin();
 140:	e8 bb fe ff ff       	call   0 <spin>
 145:	eb 12                	jmp    159 <main+0x7f>
                } else {
                    spin2();
 147:	e8 2e ff ff ff       	call   7a <spin2>
                    sleep(50);
 14c:	83 ec 0c             	sub    $0xc,%esp
 14f:	6a 32                	push   $0x32
 151:	e8 31 04 00 00       	call   587 <sleep>
 156:	83 c4 10             	add    $0x10,%esp
                }
                asm("nop");
 159:	90                   	nop
            for (n = 0; n < 100; n++) {
 15a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
 15e:	83 7d ec 63          	cmpl   $0x63,-0x14(%ebp)
 162:	7e d2                	jle    136 <main+0x5c>
            }
            exit();
 164:	e8 8e 03 00 00       	call   4f7 <exit>
        }
        i++;
 169:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    while(i < PROC) {
 16d:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
 171:	7e 9d                	jle    110 <main+0x36>
    }
    sleep(500);
 173:	83 ec 0c             	sub    $0xc,%esp
 176:	68 f4 01 00 00       	push   $0x1f4
 17b:	e8 07 04 00 00       	call   587 <sleep>
 180:	83 c4 10             	add    $0x10,%esp

    if(getschedstate(&st) != 0) {
 183:	83 ec 0c             	sub    $0xc,%esp
 186:	8d 85 ec fa ff ff    	lea    -0x514(%ebp),%eax
 18c:	50                   	push   %eax
 18d:	e8 0d 04 00 00       	call   59f <getschedstate>
 192:	83 c4 10             	add    $0x10,%esp
 195:	85 c0                	test   %eax,%eax
 197:	74 17                	je     1b0 <main+0xd6>
        printf(1, "XV6_SCHEDULER\t FAILED\n");
 199:	83 ec 08             	sub    $0x8,%esp
 19c:	68 41 0a 00 00       	push   $0xa41
 1a1:	6a 01                	push   $0x1
 1a3:	e8 d3 04 00 00       	call   67b <printf>
 1a8:	83 c4 10             	add    $0x10,%esp
        exit();
 1ab:	e8 47 03 00 00       	call   4f7 <exit>
    }

    printf(1, "\n**** PInfo ****\n");
 1b0:	83 ec 08             	sub    $0x8,%esp
 1b3:	68 58 0a 00 00       	push   $0xa58
 1b8:	6a 01                	push   $0x1
 1ba:	e8 bc 04 00 00       	call   67b <printf>
 1bf:	83 c4 10             	add    $0x10,%esp
    for(i = 0; i < NPROC; i++) {
 1c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 1c9:	eb 56                	jmp    221 <main+0x147>
        if (st.inuse[i]) {
 1cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1ce:	8b 84 85 ec fa ff ff 	mov    -0x514(%ebp,%eax,4),%eax
 1d5:	85 c0                	test   %eax,%eax
 1d7:	74 44                	je     21d <main+0x143>
            count++;
 1d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
            printf(1, "pid: %d ticks: %d priority: %d\n", st.pid[i], st.ticks[i], st.priority[i]);
 1dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1e0:	83 c0 40             	add    $0x40,%eax
 1e3:	8b 8c 85 ec fa ff ff 	mov    -0x514(%ebp,%eax,4),%ecx
 1ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1ed:	05 00 01 00 00       	add    $0x100,%eax
 1f2:	8b 94 85 ec fa ff ff 	mov    -0x514(%ebp,%eax,4),%edx
 1f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1fc:	05 c0 00 00 00       	add    $0xc0,%eax
 201:	8b 84 85 ec fa ff ff 	mov    -0x514(%ebp,%eax,4),%eax
 208:	83 ec 0c             	sub    $0xc,%esp
 20b:	51                   	push   %ecx
 20c:	52                   	push   %edx
 20d:	50                   	push   %eax
 20e:	68 6c 0a 00 00       	push   $0xa6c
 213:	6a 01                	push   $0x1
 215:	e8 61 04 00 00       	call   67b <printf>
 21a:	83 c4 20             	add    $0x20,%esp
    for(i = 0; i < NPROC; i++) {
 21d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 221:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
 225:	7e a4                	jle    1cb <main+0xf1>
        }
    }
    for(i = 0; i < PROC; i++) {
 227:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 22e:	eb 1a                	jmp    24a <main+0x170>
        kill(pid[i]);
 230:	8b 45 f0             	mov    -0x10(%ebp),%eax
 233:	8b 84 85 ec f9 ff ff 	mov    -0x614(%ebp,%eax,4),%eax
 23a:	83 ec 0c             	sub    $0xc,%esp
 23d:	50                   	push   %eax
 23e:	e8 e4 02 00 00       	call   527 <kill>
 243:	83 c4 10             	add    $0x10,%esp
    for(i = 0; i < PROC; i++) {
 246:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 24a:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
 24e:	7e e0                	jle    230 <main+0x156>
    }
    while (wait() > 0);
 250:	90                   	nop
 251:	e8 a9 02 00 00       	call   4ff <wait>
 256:	85 c0                	test   %eax,%eax
 258:	7f f7                	jg     251 <main+0x177>
    printf(1,"Number of processes in use %d\n", count);
 25a:	83 ec 04             	sub    $0x4,%esp
 25d:	ff 75 f4             	push   -0xc(%ebp)
 260:	68 8c 0a 00 00       	push   $0xa8c
 265:	6a 01                	push   $0x1
 267:	e8 0f 04 00 00       	call   67b <printf>
 26c:	83 c4 10             	add    $0x10,%esp

    if(count == 7) {
 26f:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
 273:	75 14                	jne    289 <main+0x1af>
        printf(1, "XV6_SCHEDULER\t SUCCESS\n");
 275:	83 ec 08             	sub    $0x8,%esp
 278:	68 ab 0a 00 00       	push   $0xaab
 27d:	6a 01                	push   $0x1
 27f:	e8 f7 03 00 00       	call   67b <printf>
 284:	83 c4 10             	add    $0x10,%esp
 287:	eb 12                	jmp    29b <main+0x1c1>
    }
    else {
        printf(1, "XV6_SCHEDULER\t FAILED\n");
 289:	83 ec 08             	sub    $0x8,%esp
 28c:	68 41 0a 00 00       	push   $0xa41
 291:	6a 01                	push   $0x1
 293:	e8 e3 03 00 00       	call   67b <printf>
 298:	83 c4 10             	add    $0x10,%esp
    }

    exit();
 29b:	e8 57 02 00 00       	call   4f7 <exit>

000002a0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2a0:	55                   	push   %ebp
 2a1:	89 e5                	mov    %esp,%ebp
 2a3:	57                   	push   %edi
 2a4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2a8:	8b 55 10             	mov    0x10(%ebp),%edx
 2ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ae:	89 cb                	mov    %ecx,%ebx
 2b0:	89 df                	mov    %ebx,%edi
 2b2:	89 d1                	mov    %edx,%ecx
 2b4:	fc                   	cld    
 2b5:	f3 aa                	rep stos %al,%es:(%edi)
 2b7:	89 ca                	mov    %ecx,%edx
 2b9:	89 fb                	mov    %edi,%ebx
 2bb:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2be:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2c1:	90                   	nop
 2c2:	5b                   	pop    %ebx
 2c3:	5f                   	pop    %edi
 2c4:	5d                   	pop    %ebp
 2c5:	c3                   	ret    

000002c6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 2c6:	55                   	push   %ebp
 2c7:	89 e5                	mov    %esp,%ebp
 2c9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
 2cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2d2:	90                   	nop
 2d3:	8b 55 0c             	mov    0xc(%ebp),%edx
 2d6:	8d 42 01             	lea    0x1(%edx),%eax
 2d9:	89 45 0c             	mov    %eax,0xc(%ebp)
 2dc:	8b 45 08             	mov    0x8(%ebp),%eax
 2df:	8d 48 01             	lea    0x1(%eax),%ecx
 2e2:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2e5:	0f b6 12             	movzbl (%edx),%edx
 2e8:	88 10                	mov    %dl,(%eax)
 2ea:	0f b6 00             	movzbl (%eax),%eax
 2ed:	84 c0                	test   %al,%al
 2ef:	75 e2                	jne    2d3 <strcpy+0xd>
    ;
  return os;
 2f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2f4:	c9                   	leave  
 2f5:	c3                   	ret    

000002f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2f6:	55                   	push   %ebp
 2f7:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2f9:	eb 08                	jmp    303 <strcmp+0xd>
    p++, q++;
 2fb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2ff:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 303:	8b 45 08             	mov    0x8(%ebp),%eax
 306:	0f b6 00             	movzbl (%eax),%eax
 309:	84 c0                	test   %al,%al
 30b:	74 10                	je     31d <strcmp+0x27>
 30d:	8b 45 08             	mov    0x8(%ebp),%eax
 310:	0f b6 10             	movzbl (%eax),%edx
 313:	8b 45 0c             	mov    0xc(%ebp),%eax
 316:	0f b6 00             	movzbl (%eax),%eax
 319:	38 c2                	cmp    %al,%dl
 31b:	74 de                	je     2fb <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 31d:	8b 45 08             	mov    0x8(%ebp),%eax
 320:	0f b6 00             	movzbl (%eax),%eax
 323:	0f b6 d0             	movzbl %al,%edx
 326:	8b 45 0c             	mov    0xc(%ebp),%eax
 329:	0f b6 00             	movzbl (%eax),%eax
 32c:	0f b6 c8             	movzbl %al,%ecx
 32f:	89 d0                	mov    %edx,%eax
 331:	29 c8                	sub    %ecx,%eax
}
 333:	5d                   	pop    %ebp
 334:	c3                   	ret    

00000335 <strlen>:

uint
strlen(const char *s)
{
 335:	55                   	push   %ebp
 336:	89 e5                	mov    %esp,%ebp
 338:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 33b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 342:	eb 04                	jmp    348 <strlen+0x13>
 344:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 348:	8b 55 fc             	mov    -0x4(%ebp),%edx
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	01 d0                	add    %edx,%eax
 350:	0f b6 00             	movzbl (%eax),%eax
 353:	84 c0                	test   %al,%al
 355:	75 ed                	jne    344 <strlen+0xf>
    ;
  return n;
 357:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 35a:	c9                   	leave  
 35b:	c3                   	ret    

0000035c <memset>:

void*
memset(void *dst, int c, uint n)
{
 35c:	55                   	push   %ebp
 35d:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 35f:	8b 45 10             	mov    0x10(%ebp),%eax
 362:	50                   	push   %eax
 363:	ff 75 0c             	push   0xc(%ebp)
 366:	ff 75 08             	push   0x8(%ebp)
 369:	e8 32 ff ff ff       	call   2a0 <stosb>
 36e:	83 c4 0c             	add    $0xc,%esp
  return dst;
 371:	8b 45 08             	mov    0x8(%ebp),%eax
}
 374:	c9                   	leave  
 375:	c3                   	ret    

00000376 <strchr>:

char*
strchr(const char *s, char c)
{
 376:	55                   	push   %ebp
 377:	89 e5                	mov    %esp,%ebp
 379:	83 ec 04             	sub    $0x4,%esp
 37c:	8b 45 0c             	mov    0xc(%ebp),%eax
 37f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 382:	eb 14                	jmp    398 <strchr+0x22>
    if(*s == c)
 384:	8b 45 08             	mov    0x8(%ebp),%eax
 387:	0f b6 00             	movzbl (%eax),%eax
 38a:	38 45 fc             	cmp    %al,-0x4(%ebp)
 38d:	75 05                	jne    394 <strchr+0x1e>
      return (char*)s;
 38f:	8b 45 08             	mov    0x8(%ebp),%eax
 392:	eb 13                	jmp    3a7 <strchr+0x31>
  for(; *s; s++)
 394:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 398:	8b 45 08             	mov    0x8(%ebp),%eax
 39b:	0f b6 00             	movzbl (%eax),%eax
 39e:	84 c0                	test   %al,%al
 3a0:	75 e2                	jne    384 <strchr+0xe>
  return 0;
 3a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3a7:	c9                   	leave  
 3a8:	c3                   	ret    

000003a9 <gets>:

char*
gets(char *buf, int max)
{
 3a9:	55                   	push   %ebp
 3aa:	89 e5                	mov    %esp,%ebp
 3ac:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3b6:	eb 42                	jmp    3fa <gets+0x51>
    cc = read(0, &c, 1);
 3b8:	83 ec 04             	sub    $0x4,%esp
 3bb:	6a 01                	push   $0x1
 3bd:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3c0:	50                   	push   %eax
 3c1:	6a 00                	push   $0x0
 3c3:	e8 47 01 00 00       	call   50f <read>
 3c8:	83 c4 10             	add    $0x10,%esp
 3cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3d2:	7e 33                	jle    407 <gets+0x5e>
      break;
    buf[i++] = c;
 3d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d7:	8d 50 01             	lea    0x1(%eax),%edx
 3da:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3dd:	89 c2                	mov    %eax,%edx
 3df:	8b 45 08             	mov    0x8(%ebp),%eax
 3e2:	01 c2                	add    %eax,%edx
 3e4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3e8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3ea:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3ee:	3c 0a                	cmp    $0xa,%al
 3f0:	74 16                	je     408 <gets+0x5f>
 3f2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3f6:	3c 0d                	cmp    $0xd,%al
 3f8:	74 0e                	je     408 <gets+0x5f>
  for(i=0; i+1 < max; ){
 3fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fd:	83 c0 01             	add    $0x1,%eax
 400:	39 45 0c             	cmp    %eax,0xc(%ebp)
 403:	7f b3                	jg     3b8 <gets+0xf>
 405:	eb 01                	jmp    408 <gets+0x5f>
      break;
 407:	90                   	nop
      break;
  }
  buf[i] = '\0';
 408:	8b 55 f4             	mov    -0xc(%ebp),%edx
 40b:	8b 45 08             	mov    0x8(%ebp),%eax
 40e:	01 d0                	add    %edx,%eax
 410:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 413:	8b 45 08             	mov    0x8(%ebp),%eax
}
 416:	c9                   	leave  
 417:	c3                   	ret    

00000418 <stat>:

int
stat(const char *n, struct stat *st)
{
 418:	55                   	push   %ebp
 419:	89 e5                	mov    %esp,%ebp
 41b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 41e:	83 ec 08             	sub    $0x8,%esp
 421:	6a 00                	push   $0x0
 423:	ff 75 08             	push   0x8(%ebp)
 426:	e8 0c 01 00 00       	call   537 <open>
 42b:	83 c4 10             	add    $0x10,%esp
 42e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 431:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 435:	79 07                	jns    43e <stat+0x26>
    return -1;
 437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 43c:	eb 25                	jmp    463 <stat+0x4b>
  r = fstat(fd, st);
 43e:	83 ec 08             	sub    $0x8,%esp
 441:	ff 75 0c             	push   0xc(%ebp)
 444:	ff 75 f4             	push   -0xc(%ebp)
 447:	e8 03 01 00 00       	call   54f <fstat>
 44c:	83 c4 10             	add    $0x10,%esp
 44f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 452:	83 ec 0c             	sub    $0xc,%esp
 455:	ff 75 f4             	push   -0xc(%ebp)
 458:	e8 c2 00 00 00       	call   51f <close>
 45d:	83 c4 10             	add    $0x10,%esp
  return r;
 460:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 463:	c9                   	leave  
 464:	c3                   	ret    

00000465 <atoi>:

int
atoi(const char *s)
{
 465:	55                   	push   %ebp
 466:	89 e5                	mov    %esp,%ebp
 468:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 46b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 472:	eb 25                	jmp    499 <atoi+0x34>
    n = n*10 + *s++ - '0';
 474:	8b 55 fc             	mov    -0x4(%ebp),%edx
 477:	89 d0                	mov    %edx,%eax
 479:	c1 e0 02             	shl    $0x2,%eax
 47c:	01 d0                	add    %edx,%eax
 47e:	01 c0                	add    %eax,%eax
 480:	89 c1                	mov    %eax,%ecx
 482:	8b 45 08             	mov    0x8(%ebp),%eax
 485:	8d 50 01             	lea    0x1(%eax),%edx
 488:	89 55 08             	mov    %edx,0x8(%ebp)
 48b:	0f b6 00             	movzbl (%eax),%eax
 48e:	0f be c0             	movsbl %al,%eax
 491:	01 c8                	add    %ecx,%eax
 493:	83 e8 30             	sub    $0x30,%eax
 496:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 499:	8b 45 08             	mov    0x8(%ebp),%eax
 49c:	0f b6 00             	movzbl (%eax),%eax
 49f:	3c 2f                	cmp    $0x2f,%al
 4a1:	7e 0a                	jle    4ad <atoi+0x48>
 4a3:	8b 45 08             	mov    0x8(%ebp),%eax
 4a6:	0f b6 00             	movzbl (%eax),%eax
 4a9:	3c 39                	cmp    $0x39,%al
 4ab:	7e c7                	jle    474 <atoi+0xf>
  return n;
 4ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4b0:	c9                   	leave  
 4b1:	c3                   	ret    

000004b2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4b2:	55                   	push   %ebp
 4b3:	89 e5                	mov    %esp,%ebp
 4b5:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 4b8:	8b 45 08             	mov    0x8(%ebp),%eax
 4bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4be:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4c4:	eb 17                	jmp    4dd <memmove+0x2b>
    *dst++ = *src++;
 4c6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4c9:	8d 42 01             	lea    0x1(%edx),%eax
 4cc:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4d2:	8d 48 01             	lea    0x1(%eax),%ecx
 4d5:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4d8:	0f b6 12             	movzbl (%edx),%edx
 4db:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4dd:	8b 45 10             	mov    0x10(%ebp),%eax
 4e0:	8d 50 ff             	lea    -0x1(%eax),%edx
 4e3:	89 55 10             	mov    %edx,0x10(%ebp)
 4e6:	85 c0                	test   %eax,%eax
 4e8:	7f dc                	jg     4c6 <memmove+0x14>
  return vdst;
 4ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4ed:	c9                   	leave  
 4ee:	c3                   	ret    

000004ef <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4ef:	b8 01 00 00 00       	mov    $0x1,%eax
 4f4:	cd 40                	int    $0x40
 4f6:	c3                   	ret    

000004f7 <exit>:
SYSCALL(exit)
 4f7:	b8 02 00 00 00       	mov    $0x2,%eax
 4fc:	cd 40                	int    $0x40
 4fe:	c3                   	ret    

000004ff <wait>:
SYSCALL(wait)
 4ff:	b8 03 00 00 00       	mov    $0x3,%eax
 504:	cd 40                	int    $0x40
 506:	c3                   	ret    

00000507 <pipe>:
SYSCALL(pipe)
 507:	b8 04 00 00 00       	mov    $0x4,%eax
 50c:	cd 40                	int    $0x40
 50e:	c3                   	ret    

0000050f <read>:
SYSCALL(read)
 50f:	b8 05 00 00 00       	mov    $0x5,%eax
 514:	cd 40                	int    $0x40
 516:	c3                   	ret    

00000517 <write>:
SYSCALL(write)
 517:	b8 10 00 00 00       	mov    $0x10,%eax
 51c:	cd 40                	int    $0x40
 51e:	c3                   	ret    

0000051f <close>:
SYSCALL(close)
 51f:	b8 15 00 00 00       	mov    $0x15,%eax
 524:	cd 40                	int    $0x40
 526:	c3                   	ret    

00000527 <kill>:
SYSCALL(kill)
 527:	b8 06 00 00 00       	mov    $0x6,%eax
 52c:	cd 40                	int    $0x40
 52e:	c3                   	ret    

0000052f <exec>:
SYSCALL(exec)
 52f:	b8 07 00 00 00       	mov    $0x7,%eax
 534:	cd 40                	int    $0x40
 536:	c3                   	ret    

00000537 <open>:
SYSCALL(open)
 537:	b8 0f 00 00 00       	mov    $0xf,%eax
 53c:	cd 40                	int    $0x40
 53e:	c3                   	ret    

0000053f <mknod>:
SYSCALL(mknod)
 53f:	b8 11 00 00 00       	mov    $0x11,%eax
 544:	cd 40                	int    $0x40
 546:	c3                   	ret    

00000547 <unlink>:
SYSCALL(unlink)
 547:	b8 12 00 00 00       	mov    $0x12,%eax
 54c:	cd 40                	int    $0x40
 54e:	c3                   	ret    

0000054f <fstat>:
SYSCALL(fstat)
 54f:	b8 08 00 00 00       	mov    $0x8,%eax
 554:	cd 40                	int    $0x40
 556:	c3                   	ret    

00000557 <link>:
SYSCALL(link)
 557:	b8 13 00 00 00       	mov    $0x13,%eax
 55c:	cd 40                	int    $0x40
 55e:	c3                   	ret    

0000055f <mkdir>:
SYSCALL(mkdir)
 55f:	b8 14 00 00 00       	mov    $0x14,%eax
 564:	cd 40                	int    $0x40
 566:	c3                   	ret    

00000567 <chdir>:
SYSCALL(chdir)
 567:	b8 09 00 00 00       	mov    $0x9,%eax
 56c:	cd 40                	int    $0x40
 56e:	c3                   	ret    

0000056f <dup>:
SYSCALL(dup)
 56f:	b8 0a 00 00 00       	mov    $0xa,%eax
 574:	cd 40                	int    $0x40
 576:	c3                   	ret    

00000577 <getpid>:
SYSCALL(getpid)
 577:	b8 0b 00 00 00       	mov    $0xb,%eax
 57c:	cd 40                	int    $0x40
 57e:	c3                   	ret    

0000057f <sbrk>:
SYSCALL(sbrk)
 57f:	b8 0c 00 00 00       	mov    $0xc,%eax
 584:	cd 40                	int    $0x40
 586:	c3                   	ret    

00000587 <sleep>:
SYSCALL(sleep)
 587:	b8 0d 00 00 00       	mov    $0xd,%eax
 58c:	cd 40                	int    $0x40
 58e:	c3                   	ret    

0000058f <uptime>:
SYSCALL(uptime)
 58f:	b8 0e 00 00 00       	mov    $0xe,%eax
 594:	cd 40                	int    $0x40
 596:	c3                   	ret    

00000597 <nice>:
SYSCALL(nice)
 597:	b8 16 00 00 00       	mov    $0x16,%eax
 59c:	cd 40                	int    $0x40
 59e:	c3                   	ret    

0000059f <getschedstate>:
SYSCALL(getschedstate)
 59f:	b8 17 00 00 00       	mov    $0x17,%eax
 5a4:	cd 40                	int    $0x40
 5a6:	c3                   	ret    

000005a7 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5a7:	55                   	push   %ebp
 5a8:	89 e5                	mov    %esp,%ebp
 5aa:	83 ec 18             	sub    $0x18,%esp
 5ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5b3:	83 ec 04             	sub    $0x4,%esp
 5b6:	6a 01                	push   $0x1
 5b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5bb:	50                   	push   %eax
 5bc:	ff 75 08             	push   0x8(%ebp)
 5bf:	e8 53 ff ff ff       	call   517 <write>
 5c4:	83 c4 10             	add    $0x10,%esp
}
 5c7:	90                   	nop
 5c8:	c9                   	leave  
 5c9:	c3                   	ret    

000005ca <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5ca:	55                   	push   %ebp
 5cb:	89 e5                	mov    %esp,%ebp
 5cd:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5d7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5db:	74 17                	je     5f4 <printint+0x2a>
 5dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5e1:	79 11                	jns    5f4 <printint+0x2a>
    neg = 1;
 5e3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ed:	f7 d8                	neg    %eax
 5ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f2:	eb 06                	jmp    5fa <printint+0x30>
  } else {
    x = xx;
 5f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 601:	8b 4d 10             	mov    0x10(%ebp),%ecx
 604:	8b 45 ec             	mov    -0x14(%ebp),%eax
 607:	ba 00 00 00 00       	mov    $0x0,%edx
 60c:	f7 f1                	div    %ecx
 60e:	89 d1                	mov    %edx,%ecx
 610:	8b 45 f4             	mov    -0xc(%ebp),%eax
 613:	8d 50 01             	lea    0x1(%eax),%edx
 616:	89 55 f4             	mov    %edx,-0xc(%ebp)
 619:	0f b6 91 58 0d 00 00 	movzbl 0xd58(%ecx),%edx
 620:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 624:	8b 4d 10             	mov    0x10(%ebp),%ecx
 627:	8b 45 ec             	mov    -0x14(%ebp),%eax
 62a:	ba 00 00 00 00       	mov    $0x0,%edx
 62f:	f7 f1                	div    %ecx
 631:	89 45 ec             	mov    %eax,-0x14(%ebp)
 634:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 638:	75 c7                	jne    601 <printint+0x37>
  if(neg)
 63a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 63e:	74 2d                	je     66d <printint+0xa3>
    buf[i++] = '-';
 640:	8b 45 f4             	mov    -0xc(%ebp),%eax
 643:	8d 50 01             	lea    0x1(%eax),%edx
 646:	89 55 f4             	mov    %edx,-0xc(%ebp)
 649:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 64e:	eb 1d                	jmp    66d <printint+0xa3>
    putc(fd, buf[i]);
 650:	8d 55 dc             	lea    -0x24(%ebp),%edx
 653:	8b 45 f4             	mov    -0xc(%ebp),%eax
 656:	01 d0                	add    %edx,%eax
 658:	0f b6 00             	movzbl (%eax),%eax
 65b:	0f be c0             	movsbl %al,%eax
 65e:	83 ec 08             	sub    $0x8,%esp
 661:	50                   	push   %eax
 662:	ff 75 08             	push   0x8(%ebp)
 665:	e8 3d ff ff ff       	call   5a7 <putc>
 66a:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 66d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 671:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 675:	79 d9                	jns    650 <printint+0x86>
}
 677:	90                   	nop
 678:	90                   	nop
 679:	c9                   	leave  
 67a:	c3                   	ret    

0000067b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 67b:	55                   	push   %ebp
 67c:	89 e5                	mov    %esp,%ebp
 67e:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 681:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 688:	8d 45 0c             	lea    0xc(%ebp),%eax
 68b:	83 c0 04             	add    $0x4,%eax
 68e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 691:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 698:	e9 59 01 00 00       	jmp    7f6 <printf+0x17b>
    c = fmt[i] & 0xff;
 69d:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a3:	01 d0                	add    %edx,%eax
 6a5:	0f b6 00             	movzbl (%eax),%eax
 6a8:	0f be c0             	movsbl %al,%eax
 6ab:	25 ff 00 00 00       	and    $0xff,%eax
 6b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6b3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6b7:	75 2c                	jne    6e5 <printf+0x6a>
      if(c == '%'){
 6b9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6bd:	75 0c                	jne    6cb <printf+0x50>
        state = '%';
 6bf:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6c6:	e9 27 01 00 00       	jmp    7f2 <printf+0x177>
      } else {
        putc(fd, c);
 6cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ce:	0f be c0             	movsbl %al,%eax
 6d1:	83 ec 08             	sub    $0x8,%esp
 6d4:	50                   	push   %eax
 6d5:	ff 75 08             	push   0x8(%ebp)
 6d8:	e8 ca fe ff ff       	call   5a7 <putc>
 6dd:	83 c4 10             	add    $0x10,%esp
 6e0:	e9 0d 01 00 00       	jmp    7f2 <printf+0x177>
      }
    } else if(state == '%'){
 6e5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6e9:	0f 85 03 01 00 00    	jne    7f2 <printf+0x177>
      if(c == 'd'){
 6ef:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6f3:	75 1e                	jne    713 <printf+0x98>
        printint(fd, *ap, 10, 1);
 6f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f8:	8b 00                	mov    (%eax),%eax
 6fa:	6a 01                	push   $0x1
 6fc:	6a 0a                	push   $0xa
 6fe:	50                   	push   %eax
 6ff:	ff 75 08             	push   0x8(%ebp)
 702:	e8 c3 fe ff ff       	call   5ca <printint>
 707:	83 c4 10             	add    $0x10,%esp
        ap++;
 70a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 70e:	e9 d8 00 00 00       	jmp    7eb <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 713:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 717:	74 06                	je     71f <printf+0xa4>
 719:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 71d:	75 1e                	jne    73d <printf+0xc2>
        printint(fd, *ap, 16, 0);
 71f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 722:	8b 00                	mov    (%eax),%eax
 724:	6a 00                	push   $0x0
 726:	6a 10                	push   $0x10
 728:	50                   	push   %eax
 729:	ff 75 08             	push   0x8(%ebp)
 72c:	e8 99 fe ff ff       	call   5ca <printint>
 731:	83 c4 10             	add    $0x10,%esp
        ap++;
 734:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 738:	e9 ae 00 00 00       	jmp    7eb <printf+0x170>
      } else if(c == 's'){
 73d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 741:	75 43                	jne    786 <printf+0x10b>
        s = (char*)*ap;
 743:	8b 45 e8             	mov    -0x18(%ebp),%eax
 746:	8b 00                	mov    (%eax),%eax
 748:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 74b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 74f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 753:	75 25                	jne    77a <printf+0xff>
          s = "(null)";
 755:	c7 45 f4 c3 0a 00 00 	movl   $0xac3,-0xc(%ebp)
        while(*s != 0){
 75c:	eb 1c                	jmp    77a <printf+0xff>
          putc(fd, *s);
 75e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 761:	0f b6 00             	movzbl (%eax),%eax
 764:	0f be c0             	movsbl %al,%eax
 767:	83 ec 08             	sub    $0x8,%esp
 76a:	50                   	push   %eax
 76b:	ff 75 08             	push   0x8(%ebp)
 76e:	e8 34 fe ff ff       	call   5a7 <putc>
 773:	83 c4 10             	add    $0x10,%esp
          s++;
 776:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 77a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77d:	0f b6 00             	movzbl (%eax),%eax
 780:	84 c0                	test   %al,%al
 782:	75 da                	jne    75e <printf+0xe3>
 784:	eb 65                	jmp    7eb <printf+0x170>
        }
      } else if(c == 'c'){
 786:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 78a:	75 1d                	jne    7a9 <printf+0x12e>
        putc(fd, *ap);
 78c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 78f:	8b 00                	mov    (%eax),%eax
 791:	0f be c0             	movsbl %al,%eax
 794:	83 ec 08             	sub    $0x8,%esp
 797:	50                   	push   %eax
 798:	ff 75 08             	push   0x8(%ebp)
 79b:	e8 07 fe ff ff       	call   5a7 <putc>
 7a0:	83 c4 10             	add    $0x10,%esp
        ap++;
 7a3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a7:	eb 42                	jmp    7eb <printf+0x170>
      } else if(c == '%'){
 7a9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ad:	75 17                	jne    7c6 <printf+0x14b>
        putc(fd, c);
 7af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b2:	0f be c0             	movsbl %al,%eax
 7b5:	83 ec 08             	sub    $0x8,%esp
 7b8:	50                   	push   %eax
 7b9:	ff 75 08             	push   0x8(%ebp)
 7bc:	e8 e6 fd ff ff       	call   5a7 <putc>
 7c1:	83 c4 10             	add    $0x10,%esp
 7c4:	eb 25                	jmp    7eb <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7c6:	83 ec 08             	sub    $0x8,%esp
 7c9:	6a 25                	push   $0x25
 7cb:	ff 75 08             	push   0x8(%ebp)
 7ce:	e8 d4 fd ff ff       	call   5a7 <putc>
 7d3:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7d9:	0f be c0             	movsbl %al,%eax
 7dc:	83 ec 08             	sub    $0x8,%esp
 7df:	50                   	push   %eax
 7e0:	ff 75 08             	push   0x8(%ebp)
 7e3:	e8 bf fd ff ff       	call   5a7 <putc>
 7e8:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7eb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 7f2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7f6:	8b 55 0c             	mov    0xc(%ebp),%edx
 7f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fc:	01 d0                	add    %edx,%eax
 7fe:	0f b6 00             	movzbl (%eax),%eax
 801:	84 c0                	test   %al,%al
 803:	0f 85 94 fe ff ff    	jne    69d <printf+0x22>
    }
  }
}
 809:	90                   	nop
 80a:	90                   	nop
 80b:	c9                   	leave  
 80c:	c3                   	ret    

0000080d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80d:	55                   	push   %ebp
 80e:	89 e5                	mov    %esp,%ebp
 810:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 813:	8b 45 08             	mov    0x8(%ebp),%eax
 816:	83 e8 08             	sub    $0x8,%eax
 819:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81c:	a1 74 0d 00 00       	mov    0xd74,%eax
 821:	89 45 fc             	mov    %eax,-0x4(%ebp)
 824:	eb 24                	jmp    84a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 826:	8b 45 fc             	mov    -0x4(%ebp),%eax
 829:	8b 00                	mov    (%eax),%eax
 82b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 82e:	72 12                	jb     842 <free+0x35>
 830:	8b 45 f8             	mov    -0x8(%ebp),%eax
 833:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 836:	77 24                	ja     85c <free+0x4f>
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	8b 00                	mov    (%eax),%eax
 83d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 840:	72 1a                	jb     85c <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 842:	8b 45 fc             	mov    -0x4(%ebp),%eax
 845:	8b 00                	mov    (%eax),%eax
 847:	89 45 fc             	mov    %eax,-0x4(%ebp)
 84a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 850:	76 d4                	jbe    826 <free+0x19>
 852:	8b 45 fc             	mov    -0x4(%ebp),%eax
 855:	8b 00                	mov    (%eax),%eax
 857:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 85a:	73 ca                	jae    826 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 85c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85f:	8b 40 04             	mov    0x4(%eax),%eax
 862:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 869:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86c:	01 c2                	add    %eax,%edx
 86e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 871:	8b 00                	mov    (%eax),%eax
 873:	39 c2                	cmp    %eax,%edx
 875:	75 24                	jne    89b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 877:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87a:	8b 50 04             	mov    0x4(%eax),%edx
 87d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 880:	8b 00                	mov    (%eax),%eax
 882:	8b 40 04             	mov    0x4(%eax),%eax
 885:	01 c2                	add    %eax,%edx
 887:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 88d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 890:	8b 00                	mov    (%eax),%eax
 892:	8b 10                	mov    (%eax),%edx
 894:	8b 45 f8             	mov    -0x8(%ebp),%eax
 897:	89 10                	mov    %edx,(%eax)
 899:	eb 0a                	jmp    8a5 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 89b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89e:	8b 10                	mov    (%eax),%edx
 8a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a3:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a8:	8b 40 04             	mov    0x4(%eax),%eax
 8ab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b5:	01 d0                	add    %edx,%eax
 8b7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8ba:	75 20                	jne    8dc <free+0xcf>
    p->s.size += bp->s.size;
 8bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bf:	8b 50 04             	mov    0x4(%eax),%edx
 8c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c5:	8b 40 04             	mov    0x4(%eax),%eax
 8c8:	01 c2                	add    %eax,%edx
 8ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cd:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d3:	8b 10                	mov    (%eax),%edx
 8d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d8:	89 10                	mov    %edx,(%eax)
 8da:	eb 08                	jmp    8e4 <free+0xd7>
  } else
    p->s.ptr = bp;
 8dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8df:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8e2:	89 10                	mov    %edx,(%eax)
  freep = p;
 8e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e7:	a3 74 0d 00 00       	mov    %eax,0xd74
}
 8ec:	90                   	nop
 8ed:	c9                   	leave  
 8ee:	c3                   	ret    

000008ef <morecore>:

static Header*
morecore(uint nu)
{
 8ef:	55                   	push   %ebp
 8f0:	89 e5                	mov    %esp,%ebp
 8f2:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8f5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8fc:	77 07                	ja     905 <morecore+0x16>
    nu = 4096;
 8fe:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 905:	8b 45 08             	mov    0x8(%ebp),%eax
 908:	c1 e0 03             	shl    $0x3,%eax
 90b:	83 ec 0c             	sub    $0xc,%esp
 90e:	50                   	push   %eax
 90f:	e8 6b fc ff ff       	call   57f <sbrk>
 914:	83 c4 10             	add    $0x10,%esp
 917:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 91a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 91e:	75 07                	jne    927 <morecore+0x38>
    return 0;
 920:	b8 00 00 00 00       	mov    $0x0,%eax
 925:	eb 26                	jmp    94d <morecore+0x5e>
  hp = (Header*)p;
 927:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 92d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 930:	8b 55 08             	mov    0x8(%ebp),%edx
 933:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 936:	8b 45 f0             	mov    -0x10(%ebp),%eax
 939:	83 c0 08             	add    $0x8,%eax
 93c:	83 ec 0c             	sub    $0xc,%esp
 93f:	50                   	push   %eax
 940:	e8 c8 fe ff ff       	call   80d <free>
 945:	83 c4 10             	add    $0x10,%esp
  return freep;
 948:	a1 74 0d 00 00       	mov    0xd74,%eax
}
 94d:	c9                   	leave  
 94e:	c3                   	ret    

0000094f <malloc>:

void*
malloc(uint nbytes)
{
 94f:	55                   	push   %ebp
 950:	89 e5                	mov    %esp,%ebp
 952:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 955:	8b 45 08             	mov    0x8(%ebp),%eax
 958:	83 c0 07             	add    $0x7,%eax
 95b:	c1 e8 03             	shr    $0x3,%eax
 95e:	83 c0 01             	add    $0x1,%eax
 961:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 964:	a1 74 0d 00 00       	mov    0xd74,%eax
 969:	89 45 f0             	mov    %eax,-0x10(%ebp)
 96c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 970:	75 23                	jne    995 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 972:	c7 45 f0 6c 0d 00 00 	movl   $0xd6c,-0x10(%ebp)
 979:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97c:	a3 74 0d 00 00       	mov    %eax,0xd74
 981:	a1 74 0d 00 00       	mov    0xd74,%eax
 986:	a3 6c 0d 00 00       	mov    %eax,0xd6c
    base.s.size = 0;
 98b:	c7 05 70 0d 00 00 00 	movl   $0x0,0xd70
 992:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 995:	8b 45 f0             	mov    -0x10(%ebp),%eax
 998:	8b 00                	mov    (%eax),%eax
 99a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 99d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a0:	8b 40 04             	mov    0x4(%eax),%eax
 9a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9a6:	77 4d                	ja     9f5 <malloc+0xa6>
      if(p->s.size == nunits)
 9a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ab:	8b 40 04             	mov    0x4(%eax),%eax
 9ae:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9b1:	75 0c                	jne    9bf <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b6:	8b 10                	mov    (%eax),%edx
 9b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9bb:	89 10                	mov    %edx,(%eax)
 9bd:	eb 26                	jmp    9e5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c2:	8b 40 04             	mov    0x4(%eax),%eax
 9c5:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9c8:	89 c2                	mov    %eax,%edx
 9ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d3:	8b 40 04             	mov    0x4(%eax),%eax
 9d6:	c1 e0 03             	shl    $0x3,%eax
 9d9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9df:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9e2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e8:	a3 74 0d 00 00       	mov    %eax,0xd74
      return (void*)(p + 1);
 9ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f0:	83 c0 08             	add    $0x8,%eax
 9f3:	eb 3b                	jmp    a30 <malloc+0xe1>
    }
    if(p == freep)
 9f5:	a1 74 0d 00 00       	mov    0xd74,%eax
 9fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9fd:	75 1e                	jne    a1d <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9ff:	83 ec 0c             	sub    $0xc,%esp
 a02:	ff 75 ec             	push   -0x14(%ebp)
 a05:	e8 e5 fe ff ff       	call   8ef <morecore>
 a0a:	83 c4 10             	add    $0x10,%esp
 a0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a14:	75 07                	jne    a1d <malloc+0xce>
        return 0;
 a16:	b8 00 00 00 00       	mov    $0x0,%eax
 a1b:	eb 13                	jmp    a30 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a20:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a26:	8b 00                	mov    (%eax),%eax
 a28:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a2b:	e9 6d ff ff ff       	jmp    99d <malloc+0x4e>
  }
}
 a30:	c9                   	leave  
 a31:	c3                   	ret    
