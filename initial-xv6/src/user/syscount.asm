
user/_syscount:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	7115                	addi	sp,sp,-224
   2:	ed86                	sd	ra,216(sp)
   4:	e9a2                	sd	s0,208(sp)
   6:	e5a6                	sd	s1,200(sp)
   8:	e1ca                	sd	s2,192(sp)
   a:	fd4e                	sd	s3,184(sp)
   c:	1180                	addi	s0,sp,224
    if (argc < 3)
   e:	4789                	li	a5,2
  10:	00a7cf63          	blt	a5,a0,2e <main+0x2e>
    {
        printf("Usage: syscount <mask> command [args]\n");
  14:	00001517          	auipc	a0,0x1
  18:	9b450513          	addi	a0,a0,-1612 # 9c8 <malloc+0x1a8>
  1c:	00000097          	auipc	ra,0x0
  20:	746080e7          	jalr	1862(ra) # 762 <printf>
        exit(1);
  24:	4505                	li	a0,1
  26:	00000097          	auipc	ra,0x0
  2a:	39c080e7          	jalr	924(ra) # 3c2 <exit>
  2e:	892e                	mv	s2,a1
    }

    int mask = atoi(argv[1]);
  30:	6588                	ld	a0,8(a1)
  32:	00000097          	auipc	ra,0x0
  36:	294080e7          	jalr	660(ra) # 2c6 <atoi>
  3a:	84aa                	mv	s1,a0
    int pid = fork();
  3c:	00000097          	auipc	ra,0x0
  40:	37e080e7          	jalr	894(ra) # 3ba <fork>
  44:	89aa                	mv	s3,a0

    if (pid == 0)
  46:	cd59                	beqz	a0,e4 <main+0xe4>
        // Child process: Run the command
        exec(argv[2], &argv[2]);
        printf("exec failed\n");
        exit(1);
    }
    else if (pid > 0)
  48:	0ca05c63          	blez	a0,120 <main+0x120>
    {
        // Parent process: Wait for the command to complete
        wait(0);
  4c:	4501                	li	a0,0
  4e:	00000097          	auipc	ra,0x0
  52:	37c080e7          	jalr	892(ra) # 3ca <wait>
        // Get the syscall count
        int count = getSysCount(mask);
  56:	8526                	mv	a0,s1
  58:	00000097          	auipc	ra,0x0
  5c:	412080e7          	jalr	1042(ra) # 46a <getSysCount>
  60:	86aa                	mv	a3,a0
        if (count < 0)
  62:	0a054663          	bltz	a0,10e <main+0x10e>
            printf("Invalid syscall mask\n");
        }
        else
        {
            int syscall_index = 0;
            while (mask > 1)
  66:	4605                	li	a2,1
            int syscall_index = 0;
  68:	4781                	li	a5,0
            while (mask > 1)
  6a:	4705                	li	a4,1
  6c:	00965763          	bge	a2,s1,7a <main+0x7a>
            {
                syscall_index++;
  70:	2785                	addiw	a5,a5,1
                mask >>= 1;
  72:	4014d49b          	sraiw	s1,s1,0x1
            while (mask > 1)
  76:	fe974de3          	blt	a4,s1,70 <main+0x70>
            }
            char *syscall_names[] = {"fork", "exit", "wait", "pipe", "read", "kill", "exec", "fstat", "chdir", "dup", "getpid", "sbrk", "sleep", "uptime", "open", "write", "mknod", "unlink", "link", "mkdir", "close", "getSysCount"};
  7a:	00001717          	auipc	a4,0x1
  7e:	9ce70713          	addi	a4,a4,-1586 # a48 <malloc+0x228>
  82:	f2040613          	addi	a2,s0,-224
  86:	00001317          	auipc	t1,0x1
  8a:	a6230313          	addi	t1,t1,-1438 # ae8 <malloc+0x2c8>
  8e:	00073883          	ld	a7,0(a4)
  92:	00873803          	ld	a6,8(a4)
  96:	6b08                	ld	a0,16(a4)
  98:	6f0c                	ld	a1,24(a4)
  9a:	01163023          	sd	a7,0(a2)
  9e:	01063423          	sd	a6,8(a2)
  a2:	ea08                	sd	a0,16(a2)
  a4:	ee0c                	sd	a1,24(a2)
  a6:	02070713          	addi	a4,a4,32
  aa:	02060613          	addi	a2,a2,32
  ae:	fe6710e3          	bne	a4,t1,8e <main+0x8e>
  b2:	630c                	ld	a1,0(a4)
  b4:	6718                	ld	a4,8(a4)
  b6:	e20c                	sd	a1,0(a2)
  b8:	e618                	sd	a4,8(a2)
            printf("PID %d called %s %d times.\n", pid, syscall_names[syscall_index - 1], count);
  ba:	37fd                	addiw	a5,a5,-1
  bc:	078e                	slli	a5,a5,0x3
  be:	fd040713          	addi	a4,s0,-48
  c2:	97ba                	add	a5,a5,a4
  c4:	f507b603          	ld	a2,-176(a5)
  c8:	85ce                	mv	a1,s3
  ca:	00001517          	auipc	a0,0x1
  ce:	94e50513          	addi	a0,a0,-1714 # a18 <malloc+0x1f8>
  d2:	00000097          	auipc	ra,0x0
  d6:	690080e7          	jalr	1680(ra) # 762 <printf>
    {
        printf("fork failed\n");
        exit(1);
    }

    exit(0);
  da:	4501                	li	a0,0
  dc:	00000097          	auipc	ra,0x0
  e0:	2e6080e7          	jalr	742(ra) # 3c2 <exit>
        exec(argv[2], &argv[2]);
  e4:	01090593          	addi	a1,s2,16
  e8:	01093503          	ld	a0,16(s2)
  ec:	00000097          	auipc	ra,0x0
  f0:	30e080e7          	jalr	782(ra) # 3fa <exec>
        printf("exec failed\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	8fc50513          	addi	a0,a0,-1796 # 9f0 <malloc+0x1d0>
  fc:	00000097          	auipc	ra,0x0
 100:	666080e7          	jalr	1638(ra) # 762 <printf>
        exit(1);
 104:	4505                	li	a0,1
 106:	00000097          	auipc	ra,0x0
 10a:	2bc080e7          	jalr	700(ra) # 3c2 <exit>
            printf("Invalid syscall mask\n");
 10e:	00001517          	auipc	a0,0x1
 112:	8f250513          	addi	a0,a0,-1806 # a00 <malloc+0x1e0>
 116:	00000097          	auipc	ra,0x0
 11a:	64c080e7          	jalr	1612(ra) # 762 <printf>
 11e:	bf75                	j	da <main+0xda>
        printf("fork failed\n");
 120:	00001517          	auipc	a0,0x1
 124:	91850513          	addi	a0,a0,-1768 # a38 <malloc+0x218>
 128:	00000097          	auipc	ra,0x0
 12c:	63a080e7          	jalr	1594(ra) # 762 <printf>
        exit(1);
 130:	4505                	li	a0,1
 132:	00000097          	auipc	ra,0x0
 136:	290080e7          	jalr	656(ra) # 3c2 <exit>

000000000000013a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 13a:	1141                	addi	sp,sp,-16
 13c:	e406                	sd	ra,8(sp)
 13e:	e022                	sd	s0,0(sp)
 140:	0800                	addi	s0,sp,16
  extern int main();
  main();
 142:	00000097          	auipc	ra,0x0
 146:	ebe080e7          	jalr	-322(ra) # 0 <main>
  exit(0);
 14a:	4501                	li	a0,0
 14c:	00000097          	auipc	ra,0x0
 150:	276080e7          	jalr	630(ra) # 3c2 <exit>

0000000000000154 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 154:	1141                	addi	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 15a:	87aa                	mv	a5,a0
 15c:	0585                	addi	a1,a1,1
 15e:	0785                	addi	a5,a5,1
 160:	fff5c703          	lbu	a4,-1(a1)
 164:	fee78fa3          	sb	a4,-1(a5)
 168:	fb75                	bnez	a4,15c <strcpy+0x8>
    ;
  return os;
}
 16a:	6422                	ld	s0,8(sp)
 16c:	0141                	addi	sp,sp,16
 16e:	8082                	ret

0000000000000170 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 170:	1141                	addi	sp,sp,-16
 172:	e422                	sd	s0,8(sp)
 174:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 176:	00054783          	lbu	a5,0(a0)
 17a:	cb91                	beqz	a5,18e <strcmp+0x1e>
 17c:	0005c703          	lbu	a4,0(a1)
 180:	00f71763          	bne	a4,a5,18e <strcmp+0x1e>
    p++, q++;
 184:	0505                	addi	a0,a0,1
 186:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 188:	00054783          	lbu	a5,0(a0)
 18c:	fbe5                	bnez	a5,17c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 18e:	0005c503          	lbu	a0,0(a1)
}
 192:	40a7853b          	subw	a0,a5,a0
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret

000000000000019c <strlen>:

uint
strlen(const char *s)
{
 19c:	1141                	addi	sp,sp,-16
 19e:	e422                	sd	s0,8(sp)
 1a0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	cf91                	beqz	a5,1c2 <strlen+0x26>
 1a8:	0505                	addi	a0,a0,1
 1aa:	87aa                	mv	a5,a0
 1ac:	4685                	li	a3,1
 1ae:	9e89                	subw	a3,a3,a0
 1b0:	00f6853b          	addw	a0,a3,a5
 1b4:	0785                	addi	a5,a5,1
 1b6:	fff7c703          	lbu	a4,-1(a5)
 1ba:	fb7d                	bnez	a4,1b0 <strlen+0x14>
    ;
  return n;
}
 1bc:	6422                	ld	s0,8(sp)
 1be:	0141                	addi	sp,sp,16
 1c0:	8082                	ret
  for(n = 0; s[n]; n++)
 1c2:	4501                	li	a0,0
 1c4:	bfe5                	j	1bc <strlen+0x20>

00000000000001c6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e422                	sd	s0,8(sp)
 1ca:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1cc:	ca19                	beqz	a2,1e2 <memset+0x1c>
 1ce:	87aa                	mv	a5,a0
 1d0:	1602                	slli	a2,a2,0x20
 1d2:	9201                	srli	a2,a2,0x20
 1d4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1d8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1dc:	0785                	addi	a5,a5,1
 1de:	fee79de3          	bne	a5,a4,1d8 <memset+0x12>
  }
  return dst;
}
 1e2:	6422                	ld	s0,8(sp)
 1e4:	0141                	addi	sp,sp,16
 1e6:	8082                	ret

00000000000001e8 <strchr>:

char*
strchr(const char *s, char c)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e422                	sd	s0,8(sp)
 1ec:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ee:	00054783          	lbu	a5,0(a0)
 1f2:	cb99                	beqz	a5,208 <strchr+0x20>
    if(*s == c)
 1f4:	00f58763          	beq	a1,a5,202 <strchr+0x1a>
  for(; *s; s++)
 1f8:	0505                	addi	a0,a0,1
 1fa:	00054783          	lbu	a5,0(a0)
 1fe:	fbfd                	bnez	a5,1f4 <strchr+0xc>
      return (char*)s;
  return 0;
 200:	4501                	li	a0,0
}
 202:	6422                	ld	s0,8(sp)
 204:	0141                	addi	sp,sp,16
 206:	8082                	ret
  return 0;
 208:	4501                	li	a0,0
 20a:	bfe5                	j	202 <strchr+0x1a>

000000000000020c <gets>:

char*
gets(char *buf, int max)
{
 20c:	711d                	addi	sp,sp,-96
 20e:	ec86                	sd	ra,88(sp)
 210:	e8a2                	sd	s0,80(sp)
 212:	e4a6                	sd	s1,72(sp)
 214:	e0ca                	sd	s2,64(sp)
 216:	fc4e                	sd	s3,56(sp)
 218:	f852                	sd	s4,48(sp)
 21a:	f456                	sd	s5,40(sp)
 21c:	f05a                	sd	s6,32(sp)
 21e:	ec5e                	sd	s7,24(sp)
 220:	1080                	addi	s0,sp,96
 222:	8baa                	mv	s7,a0
 224:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 226:	892a                	mv	s2,a0
 228:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 22a:	4aa9                	li	s5,10
 22c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 22e:	89a6                	mv	s3,s1
 230:	2485                	addiw	s1,s1,1
 232:	0344d863          	bge	s1,s4,262 <gets+0x56>
    cc = read(0, &c, 1);
 236:	4605                	li	a2,1
 238:	faf40593          	addi	a1,s0,-81
 23c:	4501                	li	a0,0
 23e:	00000097          	auipc	ra,0x0
 242:	19c080e7          	jalr	412(ra) # 3da <read>
    if(cc < 1)
 246:	00a05e63          	blez	a0,262 <gets+0x56>
    buf[i++] = c;
 24a:	faf44783          	lbu	a5,-81(s0)
 24e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 252:	01578763          	beq	a5,s5,260 <gets+0x54>
 256:	0905                	addi	s2,s2,1
 258:	fd679be3          	bne	a5,s6,22e <gets+0x22>
  for(i=0; i+1 < max; ){
 25c:	89a6                	mv	s3,s1
 25e:	a011                	j	262 <gets+0x56>
 260:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 262:	99de                	add	s3,s3,s7
 264:	00098023          	sb	zero,0(s3)
  return buf;
}
 268:	855e                	mv	a0,s7
 26a:	60e6                	ld	ra,88(sp)
 26c:	6446                	ld	s0,80(sp)
 26e:	64a6                	ld	s1,72(sp)
 270:	6906                	ld	s2,64(sp)
 272:	79e2                	ld	s3,56(sp)
 274:	7a42                	ld	s4,48(sp)
 276:	7aa2                	ld	s5,40(sp)
 278:	7b02                	ld	s6,32(sp)
 27a:	6be2                	ld	s7,24(sp)
 27c:	6125                	addi	sp,sp,96
 27e:	8082                	ret

0000000000000280 <stat>:

int
stat(const char *n, struct stat *st)
{
 280:	1101                	addi	sp,sp,-32
 282:	ec06                	sd	ra,24(sp)
 284:	e822                	sd	s0,16(sp)
 286:	e426                	sd	s1,8(sp)
 288:	e04a                	sd	s2,0(sp)
 28a:	1000                	addi	s0,sp,32
 28c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28e:	4581                	li	a1,0
 290:	00000097          	auipc	ra,0x0
 294:	172080e7          	jalr	370(ra) # 402 <open>
  if(fd < 0)
 298:	02054563          	bltz	a0,2c2 <stat+0x42>
 29c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 29e:	85ca                	mv	a1,s2
 2a0:	00000097          	auipc	ra,0x0
 2a4:	17a080e7          	jalr	378(ra) # 41a <fstat>
 2a8:	892a                	mv	s2,a0
  close(fd);
 2aa:	8526                	mv	a0,s1
 2ac:	00000097          	auipc	ra,0x0
 2b0:	13e080e7          	jalr	318(ra) # 3ea <close>
  return r;
}
 2b4:	854a                	mv	a0,s2
 2b6:	60e2                	ld	ra,24(sp)
 2b8:	6442                	ld	s0,16(sp)
 2ba:	64a2                	ld	s1,8(sp)
 2bc:	6902                	ld	s2,0(sp)
 2be:	6105                	addi	sp,sp,32
 2c0:	8082                	ret
    return -1;
 2c2:	597d                	li	s2,-1
 2c4:	bfc5                	j	2b4 <stat+0x34>

00000000000002c6 <atoi>:

int
atoi(const char *s)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2cc:	00054603          	lbu	a2,0(a0)
 2d0:	fd06079b          	addiw	a5,a2,-48
 2d4:	0ff7f793          	andi	a5,a5,255
 2d8:	4725                	li	a4,9
 2da:	02f76963          	bltu	a4,a5,30c <atoi+0x46>
 2de:	86aa                	mv	a3,a0
  n = 0;
 2e0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2e2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2e4:	0685                	addi	a3,a3,1
 2e6:	0025179b          	slliw	a5,a0,0x2
 2ea:	9fa9                	addw	a5,a5,a0
 2ec:	0017979b          	slliw	a5,a5,0x1
 2f0:	9fb1                	addw	a5,a5,a2
 2f2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f6:	0006c603          	lbu	a2,0(a3)
 2fa:	fd06071b          	addiw	a4,a2,-48
 2fe:	0ff77713          	andi	a4,a4,255
 302:	fee5f1e3          	bgeu	a1,a4,2e4 <atoi+0x1e>
  return n;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  n = 0;
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <atoi+0x40>

0000000000000310 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 316:	02b57463          	bgeu	a0,a1,33e <memmove+0x2e>
    while(n-- > 0)
 31a:	00c05f63          	blez	a2,338 <memmove+0x28>
 31e:	1602                	slli	a2,a2,0x20
 320:	9201                	srli	a2,a2,0x20
 322:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 326:	872a                	mv	a4,a0
      *dst++ = *src++;
 328:	0585                	addi	a1,a1,1
 32a:	0705                	addi	a4,a4,1
 32c:	fff5c683          	lbu	a3,-1(a1)
 330:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 334:	fee79ae3          	bne	a5,a4,328 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 338:	6422                	ld	s0,8(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret
    dst += n;
 33e:	00c50733          	add	a4,a0,a2
    src += n;
 342:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 344:	fec05ae3          	blez	a2,338 <memmove+0x28>
 348:	fff6079b          	addiw	a5,a2,-1
 34c:	1782                	slli	a5,a5,0x20
 34e:	9381                	srli	a5,a5,0x20
 350:	fff7c793          	not	a5,a5
 354:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 356:	15fd                	addi	a1,a1,-1
 358:	177d                	addi	a4,a4,-1
 35a:	0005c683          	lbu	a3,0(a1)
 35e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 362:	fee79ae3          	bne	a5,a4,356 <memmove+0x46>
 366:	bfc9                	j	338 <memmove+0x28>

0000000000000368 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 368:	1141                	addi	sp,sp,-16
 36a:	e422                	sd	s0,8(sp)
 36c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 36e:	ca05                	beqz	a2,39e <memcmp+0x36>
 370:	fff6069b          	addiw	a3,a2,-1
 374:	1682                	slli	a3,a3,0x20
 376:	9281                	srli	a3,a3,0x20
 378:	0685                	addi	a3,a3,1
 37a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 37c:	00054783          	lbu	a5,0(a0)
 380:	0005c703          	lbu	a4,0(a1)
 384:	00e79863          	bne	a5,a4,394 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 388:	0505                	addi	a0,a0,1
    p2++;
 38a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 38c:	fed518e3          	bne	a0,a3,37c <memcmp+0x14>
  }
  return 0;
 390:	4501                	li	a0,0
 392:	a019                	j	398 <memcmp+0x30>
      return *p1 - *p2;
 394:	40e7853b          	subw	a0,a5,a4
}
 398:	6422                	ld	s0,8(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret
  return 0;
 39e:	4501                	li	a0,0
 3a0:	bfe5                	j	398 <memcmp+0x30>

00000000000003a2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a2:	1141                	addi	sp,sp,-16
 3a4:	e406                	sd	ra,8(sp)
 3a6:	e022                	sd	s0,0(sp)
 3a8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3aa:	00000097          	auipc	ra,0x0
 3ae:	f66080e7          	jalr	-154(ra) # 310 <memmove>
}
 3b2:	60a2                	ld	ra,8(sp)
 3b4:	6402                	ld	s0,0(sp)
 3b6:	0141                	addi	sp,sp,16
 3b8:	8082                	ret

00000000000003ba <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ba:	4885                	li	a7,1
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3c2:	4889                	li	a7,2
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ca:	488d                	li	a7,3
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3d2:	4891                	li	a7,4
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <read>:
.global read
read:
 li a7, SYS_read
 3da:	4895                	li	a7,5
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <write>:
.global write
write:
 li a7, SYS_write
 3e2:	48c1                	li	a7,16
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <close>:
.global close
close:
 li a7, SYS_close
 3ea:	48d5                	li	a7,21
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3f2:	4899                	li	a7,6
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <exec>:
.global exec
exec:
 li a7, SYS_exec
 3fa:	489d                	li	a7,7
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <open>:
.global open
open:
 li a7, SYS_open
 402:	48bd                	li	a7,15
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 40a:	48c5                	li	a7,17
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 412:	48c9                	li	a7,18
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 41a:	48a1                	li	a7,8
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <link>:
.global link
link:
 li a7, SYS_link
 422:	48cd                	li	a7,19
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 42a:	48d1                	li	a7,20
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 432:	48a5                	li	a7,9
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <dup>:
.global dup
dup:
 li a7, SYS_dup
 43a:	48a9                	li	a7,10
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 442:	48ad                	li	a7,11
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 44a:	48b1                	li	a7,12
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 452:	48b5                	li	a7,13
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 45a:	48b9                	li	a7,14
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 462:	48d9                	li	a7,22
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 46a:	48dd                	li	a7,23
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 472:	48e1                	li	a7,24
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 47a:	48e5                	li	a7,25
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 482:	48e9                	li	a7,26
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 48a:	1101                	addi	sp,sp,-32
 48c:	ec06                	sd	ra,24(sp)
 48e:	e822                	sd	s0,16(sp)
 490:	1000                	addi	s0,sp,32
 492:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 496:	4605                	li	a2,1
 498:	fef40593          	addi	a1,s0,-17
 49c:	00000097          	auipc	ra,0x0
 4a0:	f46080e7          	jalr	-186(ra) # 3e2 <write>
}
 4a4:	60e2                	ld	ra,24(sp)
 4a6:	6442                	ld	s0,16(sp)
 4a8:	6105                	addi	sp,sp,32
 4aa:	8082                	ret

00000000000004ac <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ac:	7139                	addi	sp,sp,-64
 4ae:	fc06                	sd	ra,56(sp)
 4b0:	f822                	sd	s0,48(sp)
 4b2:	f426                	sd	s1,40(sp)
 4b4:	f04a                	sd	s2,32(sp)
 4b6:	ec4e                	sd	s3,24(sp)
 4b8:	0080                	addi	s0,sp,64
 4ba:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4bc:	c299                	beqz	a3,4c2 <printint+0x16>
 4be:	0805c863          	bltz	a1,54e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4c2:	2581                	sext.w	a1,a1
  neg = 0;
 4c4:	4881                	li	a7,0
 4c6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ca:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4cc:	2601                	sext.w	a2,a2
 4ce:	00000517          	auipc	a0,0x0
 4d2:	63250513          	addi	a0,a0,1586 # b00 <digits>
 4d6:	883a                	mv	a6,a4
 4d8:	2705                	addiw	a4,a4,1
 4da:	02c5f7bb          	remuw	a5,a1,a2
 4de:	1782                	slli	a5,a5,0x20
 4e0:	9381                	srli	a5,a5,0x20
 4e2:	97aa                	add	a5,a5,a0
 4e4:	0007c783          	lbu	a5,0(a5)
 4e8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ec:	0005879b          	sext.w	a5,a1
 4f0:	02c5d5bb          	divuw	a1,a1,a2
 4f4:	0685                	addi	a3,a3,1
 4f6:	fec7f0e3          	bgeu	a5,a2,4d6 <printint+0x2a>
  if(neg)
 4fa:	00088b63          	beqz	a7,510 <printint+0x64>
    buf[i++] = '-';
 4fe:	fd040793          	addi	a5,s0,-48
 502:	973e                	add	a4,a4,a5
 504:	02d00793          	li	a5,45
 508:	fef70823          	sb	a5,-16(a4)
 50c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 510:	02e05863          	blez	a4,540 <printint+0x94>
 514:	fc040793          	addi	a5,s0,-64
 518:	00e78933          	add	s2,a5,a4
 51c:	fff78993          	addi	s3,a5,-1
 520:	99ba                	add	s3,s3,a4
 522:	377d                	addiw	a4,a4,-1
 524:	1702                	slli	a4,a4,0x20
 526:	9301                	srli	a4,a4,0x20
 528:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 52c:	fff94583          	lbu	a1,-1(s2)
 530:	8526                	mv	a0,s1
 532:	00000097          	auipc	ra,0x0
 536:	f58080e7          	jalr	-168(ra) # 48a <putc>
  while(--i >= 0)
 53a:	197d                	addi	s2,s2,-1
 53c:	ff3918e3          	bne	s2,s3,52c <printint+0x80>
}
 540:	70e2                	ld	ra,56(sp)
 542:	7442                	ld	s0,48(sp)
 544:	74a2                	ld	s1,40(sp)
 546:	7902                	ld	s2,32(sp)
 548:	69e2                	ld	s3,24(sp)
 54a:	6121                	addi	sp,sp,64
 54c:	8082                	ret
    x = -xx;
 54e:	40b005bb          	negw	a1,a1
    neg = 1;
 552:	4885                	li	a7,1
    x = -xx;
 554:	bf8d                	j	4c6 <printint+0x1a>

0000000000000556 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 556:	7119                	addi	sp,sp,-128
 558:	fc86                	sd	ra,120(sp)
 55a:	f8a2                	sd	s0,112(sp)
 55c:	f4a6                	sd	s1,104(sp)
 55e:	f0ca                	sd	s2,96(sp)
 560:	ecce                	sd	s3,88(sp)
 562:	e8d2                	sd	s4,80(sp)
 564:	e4d6                	sd	s5,72(sp)
 566:	e0da                	sd	s6,64(sp)
 568:	fc5e                	sd	s7,56(sp)
 56a:	f862                	sd	s8,48(sp)
 56c:	f466                	sd	s9,40(sp)
 56e:	f06a                	sd	s10,32(sp)
 570:	ec6e                	sd	s11,24(sp)
 572:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 574:	0005c903          	lbu	s2,0(a1)
 578:	18090f63          	beqz	s2,716 <vprintf+0x1c0>
 57c:	8aaa                	mv	s5,a0
 57e:	8b32                	mv	s6,a2
 580:	00158493          	addi	s1,a1,1
  state = 0;
 584:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 586:	02500a13          	li	s4,37
      if(c == 'd'){
 58a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 58e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 592:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 596:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 59a:	00000b97          	auipc	s7,0x0
 59e:	566b8b93          	addi	s7,s7,1382 # b00 <digits>
 5a2:	a839                	j	5c0 <vprintf+0x6a>
        putc(fd, c);
 5a4:	85ca                	mv	a1,s2
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	ee2080e7          	jalr	-286(ra) # 48a <putc>
 5b0:	a019                	j	5b6 <vprintf+0x60>
    } else if(state == '%'){
 5b2:	01498f63          	beq	s3,s4,5d0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5b6:	0485                	addi	s1,s1,1
 5b8:	fff4c903          	lbu	s2,-1(s1)
 5bc:	14090d63          	beqz	s2,716 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5c0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5c4:	fe0997e3          	bnez	s3,5b2 <vprintf+0x5c>
      if(c == '%'){
 5c8:	fd479ee3          	bne	a5,s4,5a4 <vprintf+0x4e>
        state = '%';
 5cc:	89be                	mv	s3,a5
 5ce:	b7e5                	j	5b6 <vprintf+0x60>
      if(c == 'd'){
 5d0:	05878063          	beq	a5,s8,610 <vprintf+0xba>
      } else if(c == 'l') {
 5d4:	05978c63          	beq	a5,s9,62c <vprintf+0xd6>
      } else if(c == 'x') {
 5d8:	07a78863          	beq	a5,s10,648 <vprintf+0xf2>
      } else if(c == 'p') {
 5dc:	09b78463          	beq	a5,s11,664 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5e0:	07300713          	li	a4,115
 5e4:	0ce78663          	beq	a5,a4,6b0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5e8:	06300713          	li	a4,99
 5ec:	0ee78e63          	beq	a5,a4,6e8 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5f0:	11478863          	beq	a5,s4,700 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5f4:	85d2                	mv	a1,s4
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	e92080e7          	jalr	-366(ra) # 48a <putc>
        putc(fd, c);
 600:	85ca                	mv	a1,s2
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	e86080e7          	jalr	-378(ra) # 48a <putc>
      }
      state = 0;
 60c:	4981                	li	s3,0
 60e:	b765                	j	5b6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 610:	008b0913          	addi	s2,s6,8
 614:	4685                	li	a3,1
 616:	4629                	li	a2,10
 618:	000b2583          	lw	a1,0(s6)
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	e8e080e7          	jalr	-370(ra) # 4ac <printint>
 626:	8b4a                	mv	s6,s2
      state = 0;
 628:	4981                	li	s3,0
 62a:	b771                	j	5b6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 62c:	008b0913          	addi	s2,s6,8
 630:	4681                	li	a3,0
 632:	4629                	li	a2,10
 634:	000b2583          	lw	a1,0(s6)
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	e72080e7          	jalr	-398(ra) # 4ac <printint>
 642:	8b4a                	mv	s6,s2
      state = 0;
 644:	4981                	li	s3,0
 646:	bf85                	j	5b6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 648:	008b0913          	addi	s2,s6,8
 64c:	4681                	li	a3,0
 64e:	4641                	li	a2,16
 650:	000b2583          	lw	a1,0(s6)
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	e56080e7          	jalr	-426(ra) # 4ac <printint>
 65e:	8b4a                	mv	s6,s2
      state = 0;
 660:	4981                	li	s3,0
 662:	bf91                	j	5b6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 664:	008b0793          	addi	a5,s6,8
 668:	f8f43423          	sd	a5,-120(s0)
 66c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 670:	03000593          	li	a1,48
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	e14080e7          	jalr	-492(ra) # 48a <putc>
  putc(fd, 'x');
 67e:	85ea                	mv	a1,s10
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e08080e7          	jalr	-504(ra) # 48a <putc>
 68a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 68c:	03c9d793          	srli	a5,s3,0x3c
 690:	97de                	add	a5,a5,s7
 692:	0007c583          	lbu	a1,0(a5)
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	df2080e7          	jalr	-526(ra) # 48a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a0:	0992                	slli	s3,s3,0x4
 6a2:	397d                	addiw	s2,s2,-1
 6a4:	fe0914e3          	bnez	s2,68c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6a8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	b721                	j	5b6 <vprintf+0x60>
        s = va_arg(ap, char*);
 6b0:	008b0993          	addi	s3,s6,8
 6b4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6b8:	02090163          	beqz	s2,6da <vprintf+0x184>
        while(*s != 0){
 6bc:	00094583          	lbu	a1,0(s2)
 6c0:	c9a1                	beqz	a1,710 <vprintf+0x1ba>
          putc(fd, *s);
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	dc6080e7          	jalr	-570(ra) # 48a <putc>
          s++;
 6cc:	0905                	addi	s2,s2,1
        while(*s != 0){
 6ce:	00094583          	lbu	a1,0(s2)
 6d2:	f9e5                	bnez	a1,6c2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6d4:	8b4e                	mv	s6,s3
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	bdf9                	j	5b6 <vprintf+0x60>
          s = "(null)";
 6da:	00000917          	auipc	s2,0x0
 6de:	41e90913          	addi	s2,s2,1054 # af8 <malloc+0x2d8>
        while(*s != 0){
 6e2:	02800593          	li	a1,40
 6e6:	bff1                	j	6c2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6e8:	008b0913          	addi	s2,s6,8
 6ec:	000b4583          	lbu	a1,0(s6)
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	d98080e7          	jalr	-616(ra) # 48a <putc>
 6fa:	8b4a                	mv	s6,s2
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	bd65                	j	5b6 <vprintf+0x60>
        putc(fd, c);
 700:	85d2                	mv	a1,s4
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	d86080e7          	jalr	-634(ra) # 48a <putc>
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b565                	j	5b6 <vprintf+0x60>
        s = va_arg(ap, char*);
 710:	8b4e                	mv	s6,s3
      state = 0;
 712:	4981                	li	s3,0
 714:	b54d                	j	5b6 <vprintf+0x60>
    }
  }
}
 716:	70e6                	ld	ra,120(sp)
 718:	7446                	ld	s0,112(sp)
 71a:	74a6                	ld	s1,104(sp)
 71c:	7906                	ld	s2,96(sp)
 71e:	69e6                	ld	s3,88(sp)
 720:	6a46                	ld	s4,80(sp)
 722:	6aa6                	ld	s5,72(sp)
 724:	6b06                	ld	s6,64(sp)
 726:	7be2                	ld	s7,56(sp)
 728:	7c42                	ld	s8,48(sp)
 72a:	7ca2                	ld	s9,40(sp)
 72c:	7d02                	ld	s10,32(sp)
 72e:	6de2                	ld	s11,24(sp)
 730:	6109                	addi	sp,sp,128
 732:	8082                	ret

0000000000000734 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 734:	715d                	addi	sp,sp,-80
 736:	ec06                	sd	ra,24(sp)
 738:	e822                	sd	s0,16(sp)
 73a:	1000                	addi	s0,sp,32
 73c:	e010                	sd	a2,0(s0)
 73e:	e414                	sd	a3,8(s0)
 740:	e818                	sd	a4,16(s0)
 742:	ec1c                	sd	a5,24(s0)
 744:	03043023          	sd	a6,32(s0)
 748:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 74c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 750:	8622                	mv	a2,s0
 752:	00000097          	auipc	ra,0x0
 756:	e04080e7          	jalr	-508(ra) # 556 <vprintf>
}
 75a:	60e2                	ld	ra,24(sp)
 75c:	6442                	ld	s0,16(sp)
 75e:	6161                	addi	sp,sp,80
 760:	8082                	ret

0000000000000762 <printf>:

void
printf(const char *fmt, ...)
{
 762:	711d                	addi	sp,sp,-96
 764:	ec06                	sd	ra,24(sp)
 766:	e822                	sd	s0,16(sp)
 768:	1000                	addi	s0,sp,32
 76a:	e40c                	sd	a1,8(s0)
 76c:	e810                	sd	a2,16(s0)
 76e:	ec14                	sd	a3,24(s0)
 770:	f018                	sd	a4,32(s0)
 772:	f41c                	sd	a5,40(s0)
 774:	03043823          	sd	a6,48(s0)
 778:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 77c:	00840613          	addi	a2,s0,8
 780:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 784:	85aa                	mv	a1,a0
 786:	4505                	li	a0,1
 788:	00000097          	auipc	ra,0x0
 78c:	dce080e7          	jalr	-562(ra) # 556 <vprintf>
}
 790:	60e2                	ld	ra,24(sp)
 792:	6442                	ld	s0,16(sp)
 794:	6125                	addi	sp,sp,96
 796:	8082                	ret

0000000000000798 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 798:	1141                	addi	sp,sp,-16
 79a:	e422                	sd	s0,8(sp)
 79c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 79e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a2:	00001797          	auipc	a5,0x1
 7a6:	85e7b783          	ld	a5,-1954(a5) # 1000 <freep>
 7aa:	a805                	j	7da <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ac:	4618                	lw	a4,8(a2)
 7ae:	9db9                	addw	a1,a1,a4
 7b0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b4:	6398                	ld	a4,0(a5)
 7b6:	6318                	ld	a4,0(a4)
 7b8:	fee53823          	sd	a4,-16(a0)
 7bc:	a091                	j	800 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7be:	ff852703          	lw	a4,-8(a0)
 7c2:	9e39                	addw	a2,a2,a4
 7c4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7c6:	ff053703          	ld	a4,-16(a0)
 7ca:	e398                	sd	a4,0(a5)
 7cc:	a099                	j	812 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ce:	6398                	ld	a4,0(a5)
 7d0:	00e7e463          	bltu	a5,a4,7d8 <free+0x40>
 7d4:	00e6ea63          	bltu	a3,a4,7e8 <free+0x50>
{
 7d8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7da:	fed7fae3          	bgeu	a5,a3,7ce <free+0x36>
 7de:	6398                	ld	a4,0(a5)
 7e0:	00e6e463          	bltu	a3,a4,7e8 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e4:	fee7eae3          	bltu	a5,a4,7d8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7e8:	ff852583          	lw	a1,-8(a0)
 7ec:	6390                	ld	a2,0(a5)
 7ee:	02059713          	slli	a4,a1,0x20
 7f2:	9301                	srli	a4,a4,0x20
 7f4:	0712                	slli	a4,a4,0x4
 7f6:	9736                	add	a4,a4,a3
 7f8:	fae60ae3          	beq	a2,a4,7ac <free+0x14>
    bp->s.ptr = p->s.ptr;
 7fc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 800:	4790                	lw	a2,8(a5)
 802:	02061713          	slli	a4,a2,0x20
 806:	9301                	srli	a4,a4,0x20
 808:	0712                	slli	a4,a4,0x4
 80a:	973e                	add	a4,a4,a5
 80c:	fae689e3          	beq	a3,a4,7be <free+0x26>
  } else
    p->s.ptr = bp;
 810:	e394                	sd	a3,0(a5)
  freep = p;
 812:	00000717          	auipc	a4,0x0
 816:	7ef73723          	sd	a5,2030(a4) # 1000 <freep>
}
 81a:	6422                	ld	s0,8(sp)
 81c:	0141                	addi	sp,sp,16
 81e:	8082                	ret

0000000000000820 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 820:	7139                	addi	sp,sp,-64
 822:	fc06                	sd	ra,56(sp)
 824:	f822                	sd	s0,48(sp)
 826:	f426                	sd	s1,40(sp)
 828:	f04a                	sd	s2,32(sp)
 82a:	ec4e                	sd	s3,24(sp)
 82c:	e852                	sd	s4,16(sp)
 82e:	e456                	sd	s5,8(sp)
 830:	e05a                	sd	s6,0(sp)
 832:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 834:	02051493          	slli	s1,a0,0x20
 838:	9081                	srli	s1,s1,0x20
 83a:	04bd                	addi	s1,s1,15
 83c:	8091                	srli	s1,s1,0x4
 83e:	0014899b          	addiw	s3,s1,1
 842:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 844:	00000517          	auipc	a0,0x0
 848:	7bc53503          	ld	a0,1980(a0) # 1000 <freep>
 84c:	c515                	beqz	a0,878 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 850:	4798                	lw	a4,8(a5)
 852:	02977f63          	bgeu	a4,s1,890 <malloc+0x70>
 856:	8a4e                	mv	s4,s3
 858:	0009871b          	sext.w	a4,s3
 85c:	6685                	lui	a3,0x1
 85e:	00d77363          	bgeu	a4,a3,864 <malloc+0x44>
 862:	6a05                	lui	s4,0x1
 864:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 868:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 86c:	00000917          	auipc	s2,0x0
 870:	79490913          	addi	s2,s2,1940 # 1000 <freep>
  if(p == (char*)-1)
 874:	5afd                	li	s5,-1
 876:	a88d                	j	8e8 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 878:	00000797          	auipc	a5,0x0
 87c:	79878793          	addi	a5,a5,1944 # 1010 <base>
 880:	00000717          	auipc	a4,0x0
 884:	78f73023          	sd	a5,1920(a4) # 1000 <freep>
 888:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 88a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 88e:	b7e1                	j	856 <malloc+0x36>
      if(p->s.size == nunits)
 890:	02e48b63          	beq	s1,a4,8c6 <malloc+0xa6>
        p->s.size -= nunits;
 894:	4137073b          	subw	a4,a4,s3
 898:	c798                	sw	a4,8(a5)
        p += p->s.size;
 89a:	1702                	slli	a4,a4,0x20
 89c:	9301                	srli	a4,a4,0x20
 89e:	0712                	slli	a4,a4,0x4
 8a0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8a6:	00000717          	auipc	a4,0x0
 8aa:	74a73d23          	sd	a0,1882(a4) # 1000 <freep>
      return (void*)(p + 1);
 8ae:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8b2:	70e2                	ld	ra,56(sp)
 8b4:	7442                	ld	s0,48(sp)
 8b6:	74a2                	ld	s1,40(sp)
 8b8:	7902                	ld	s2,32(sp)
 8ba:	69e2                	ld	s3,24(sp)
 8bc:	6a42                	ld	s4,16(sp)
 8be:	6aa2                	ld	s5,8(sp)
 8c0:	6b02                	ld	s6,0(sp)
 8c2:	6121                	addi	sp,sp,64
 8c4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8c6:	6398                	ld	a4,0(a5)
 8c8:	e118                	sd	a4,0(a0)
 8ca:	bff1                	j	8a6 <malloc+0x86>
  hp->s.size = nu;
 8cc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d0:	0541                	addi	a0,a0,16
 8d2:	00000097          	auipc	ra,0x0
 8d6:	ec6080e7          	jalr	-314(ra) # 798 <free>
  return freep;
 8da:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8de:	d971                	beqz	a0,8b2 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e2:	4798                	lw	a4,8(a5)
 8e4:	fa9776e3          	bgeu	a4,s1,890 <malloc+0x70>
    if(p == freep)
 8e8:	00093703          	ld	a4,0(s2)
 8ec:	853e                	mv	a0,a5
 8ee:	fef719e3          	bne	a4,a5,8e0 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8f2:	8552                	mv	a0,s4
 8f4:	00000097          	auipc	ra,0x0
 8f8:	b56080e7          	jalr	-1194(ra) # 44a <sbrk>
  if(p == (char*)-1)
 8fc:	fd5518e3          	bne	a0,s5,8cc <malloc+0xac>
        return 0;
 900:	4501                	li	a0,0
 902:	bf45                	j	8b2 <malloc+0x92>
