
user/_lbstest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <usless_work>:
#include "kernel/riscv.h"
#include "user/user.h"
#pragma GCC push_options
#pragma GCC optimize ("O0") // Causing wierd errors of moving things here and there

void usless_work() {
   0:	1101                	addi	sp,sp,-32
   2:	ec22                	sd	s0,24(sp)
   4:	1000                	addi	s0,sp,32
    for (int i = 0; i < 1000 * 900000; i++) {
   6:	fe042623          	sw	zero,-20(s0)
   a:	a039                	j	18 <usless_work+0x18>
        asm volatile("nop"); // avoid compiler optimizing away loop
   c:	0001                	nop
    for (int i = 0; i < 1000 * 900000; i++) {
   e:	fec42783          	lw	a5,-20(s0)
  12:	2785                	addiw	a5,a5,1
  14:	fef42623          	sw	a5,-20(s0)
  18:	fec42783          	lw	a5,-20(s0)
  1c:	0007871b          	sext.w	a4,a5
  20:	35a4f7b7          	lui	a5,0x35a4f
  24:	8ff78793          	addi	a5,a5,-1793 # 35a4e8ff <base+0x35a4d8ef>
  28:	fee7d2e3          	bge	a5,a4,c <usless_work+0xc>
    }
}
  2c:	0001                	nop
  2e:	0001                	nop
  30:	6462                	ld	s0,24(sp)
  32:	6105                	addi	sp,sp,32
  34:	8082                	ret

0000000000000036 <test0>:


void test0(){
  36:	1101                	addi	sp,sp,-32
  38:	ec06                	sd	ra,24(sp)
  3a:	e822                	sd	s0,16(sp)
  3c:	1000                	addi	s0,sp,32
    settickets(600);// So that parent will get the higher priority and the forks can run at once
  3e:	25800513          	li	a0,600
  42:	00000097          	auipc	ra,0x0
  46:	6bc080e7          	jalr	1724(ra) # 6fe <settickets>
    printf("TEST 0\n"); // To check the randomness
  4a:	00001517          	auipc	a0,0x1
  4e:	b3650513          	addi	a0,a0,-1226 # b80 <malloc+0xe4>
  52:	00001097          	auipc	ra,0x1
  56:	98c080e7          	jalr	-1652(ra) # 9de <printf>
    int prog1_tickets = 10;
  5a:	47a9                	li	a5,10
  5c:	fef42623          	sw	a5,-20(s0)
    int prog2_tickets = 50;
  60:	03200793          	li	a5,50
  64:	fef42423          	sw	a5,-24(s0)
    int prog3_tickets = 2000;
  68:	7d000793          	li	a5,2000
  6c:	fef42223          	sw	a5,-28(s0)
    int prog4_tickets = 750;
  70:	2ee00793          	li	a5,750
  74:	fef42023          	sw	a5,-32(s0)
    printf("Child 1 has %d tickets.\nChild 2 has %d tickets\nChild 3 has %d tickets\nChild 4 has %d tickets\n",
  78:	fe042703          	lw	a4,-32(s0)
  7c:	fe442683          	lw	a3,-28(s0)
  80:	fe842603          	lw	a2,-24(s0)
  84:	fec42783          	lw	a5,-20(s0)
  88:	85be                	mv	a1,a5
  8a:	00001517          	auipc	a0,0x1
  8e:	afe50513          	addi	a0,a0,-1282 # b88 <malloc+0xec>
  92:	00001097          	auipc	ra,0x1
  96:	94c080e7          	jalr	-1716(ra) # 9de <printf>
           prog1_tickets, prog2_tickets, prog3_tickets, prog4_tickets);

    if (fork() == 0) {
  9a:	00000097          	auipc	ra,0x0
  9e:	59c080e7          	jalr	1436(ra) # 636 <fork>
  a2:	87aa                	mv	a5,a0
  a4:	e7b1                	bnez	a5,f0 <test0+0xba>
        settickets(prog1_tickets);
  a6:	fec42783          	lw	a5,-20(s0)
  aa:	853e                	mv	a0,a5
  ac:	00000097          	auipc	ra,0x0
  b0:	652080e7          	jalr	1618(ra) # 6fe <settickets>
        printf("Child 1 started\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	b3450513          	addi	a0,a0,-1228 # be8 <malloc+0x14c>
  bc:	00001097          	auipc	ra,0x1
  c0:	922080e7          	jalr	-1758(ra) # 9de <printf>
        sleep(1);
  c4:	4505                	li	a0,1
  c6:	00000097          	auipc	ra,0x0
  ca:	608080e7          	jalr	1544(ra) # 6ce <sleep>
        usless_work();
  ce:	00000097          	auipc	ra,0x0
  d2:	f32080e7          	jalr	-206(ra) # 0 <usless_work>
        printf("Child 1 exited\n");
  d6:	00001517          	auipc	a0,0x1
  da:	b2a50513          	addi	a0,a0,-1238 # c00 <malloc+0x164>
  de:	00001097          	auipc	ra,0x1
  e2:	900080e7          	jalr	-1792(ra) # 9de <printf>
        exit(0);
  e6:	4501                	li	a0,0
  e8:	00000097          	auipc	ra,0x0
  ec:	556080e7          	jalr	1366(ra) # 63e <exit>

    }
    if (fork() == 0) {
  f0:	00000097          	auipc	ra,0x0
  f4:	546080e7          	jalr	1350(ra) # 636 <fork>
  f8:	87aa                	mv	a5,a0
  fa:	e7b1                	bnez	a5,146 <test0+0x110>
        settickets(prog2_tickets);
  fc:	fe842783          	lw	a5,-24(s0)
 100:	853e                	mv	a0,a5
 102:	00000097          	auipc	ra,0x0
 106:	5fc080e7          	jalr	1532(ra) # 6fe <settickets>
        printf("Child 2 started\n");
 10a:	00001517          	auipc	a0,0x1
 10e:	b0650513          	addi	a0,a0,-1274 # c10 <malloc+0x174>
 112:	00001097          	auipc	ra,0x1
 116:	8cc080e7          	jalr	-1844(ra) # 9de <printf>
        sleep(1);
 11a:	4505                	li	a0,1
 11c:	00000097          	auipc	ra,0x0
 120:	5b2080e7          	jalr	1458(ra) # 6ce <sleep>
        usless_work();
 124:	00000097          	auipc	ra,0x0
 128:	edc080e7          	jalr	-292(ra) # 0 <usless_work>
        printf("Child 2 exited\n");
 12c:	00001517          	auipc	a0,0x1
 130:	afc50513          	addi	a0,a0,-1284 # c28 <malloc+0x18c>
 134:	00001097          	auipc	ra,0x1
 138:	8aa080e7          	jalr	-1878(ra) # 9de <printf>
        exit(0);
 13c:	4501                	li	a0,0
 13e:	00000097          	auipc	ra,0x0
 142:	500080e7          	jalr	1280(ra) # 63e <exit>
    }
    if (fork() == 0) {
 146:	00000097          	auipc	ra,0x0
 14a:	4f0080e7          	jalr	1264(ra) # 636 <fork>
 14e:	87aa                	mv	a5,a0
 150:	e7b1                	bnez	a5,19c <test0+0x166>
        settickets(prog3_tickets);
 152:	fe442783          	lw	a5,-28(s0)
 156:	853e                	mv	a0,a5
 158:	00000097          	auipc	ra,0x0
 15c:	5a6080e7          	jalr	1446(ra) # 6fe <settickets>
        printf("Child 3 started\n");
 160:	00001517          	auipc	a0,0x1
 164:	ad850513          	addi	a0,a0,-1320 # c38 <malloc+0x19c>
 168:	00001097          	auipc	ra,0x1
 16c:	876080e7          	jalr	-1930(ra) # 9de <printf>
        sleep(1);
 170:	4505                	li	a0,1
 172:	00000097          	auipc	ra,0x0
 176:	55c080e7          	jalr	1372(ra) # 6ce <sleep>
        usless_work();
 17a:	00000097          	auipc	ra,0x0
 17e:	e86080e7          	jalr	-378(ra) # 0 <usless_work>
        printf("Child 3 exited\n");
 182:	00001517          	auipc	a0,0x1
 186:	ace50513          	addi	a0,a0,-1330 # c50 <malloc+0x1b4>
 18a:	00001097          	auipc	ra,0x1
 18e:	854080e7          	jalr	-1964(ra) # 9de <printf>
        exit(0);
 192:	4501                	li	a0,0
 194:	00000097          	auipc	ra,0x0
 198:	4aa080e7          	jalr	1194(ra) # 63e <exit>
    }
    if (fork() == 0) {
 19c:	00000097          	auipc	ra,0x0
 1a0:	49a080e7          	jalr	1178(ra) # 636 <fork>
 1a4:	87aa                	mv	a5,a0
 1a6:	e7b1                	bnez	a5,1f2 <test0+0x1bc>
        settickets(prog4_tickets);
 1a8:	fe042783          	lw	a5,-32(s0)
 1ac:	853e                	mv	a0,a5
 1ae:	00000097          	auipc	ra,0x0
 1b2:	550080e7          	jalr	1360(ra) # 6fe <settickets>
        printf("Child 4 started\n");
 1b6:	00001517          	auipc	a0,0x1
 1ba:	aaa50513          	addi	a0,a0,-1366 # c60 <malloc+0x1c4>
 1be:	00001097          	auipc	ra,0x1
 1c2:	820080e7          	jalr	-2016(ra) # 9de <printf>
        sleep(1);
 1c6:	4505                	li	a0,1
 1c8:	00000097          	auipc	ra,0x0
 1cc:	506080e7          	jalr	1286(ra) # 6ce <sleep>
        usless_work();
 1d0:	00000097          	auipc	ra,0x0
 1d4:	e30080e7          	jalr	-464(ra) # 0 <usless_work>
        printf("Child 4 exited\n");
 1d8:	00001517          	auipc	a0,0x1
 1dc:	aa050513          	addi	a0,a0,-1376 # c78 <malloc+0x1dc>
 1e0:	00000097          	auipc	ra,0x0
 1e4:	7fe080e7          	jalr	2046(ra) # 9de <printf>
        exit(0);
 1e8:	4501                	li	a0,0
 1ea:	00000097          	auipc	ra,0x0
 1ee:	454080e7          	jalr	1108(ra) # 63e <exit>
    }
    wait(0);
 1f2:	4501                	li	a0,0
 1f4:	00000097          	auipc	ra,0x0
 1f8:	452080e7          	jalr	1106(ra) # 646 <wait>
    wait(0);
 1fc:	4501                	li	a0,0
 1fe:	00000097          	auipc	ra,0x0
 202:	448080e7          	jalr	1096(ra) # 646 <wait>
    wait(0);
 206:	4501                	li	a0,0
 208:	00000097          	auipc	ra,0x0
 20c:	43e080e7          	jalr	1086(ra) # 646 <wait>
    wait(0);
 210:	4501                	li	a0,0
 212:	00000097          	auipc	ra,0x0
 216:	434080e7          	jalr	1076(ra) # 646 <wait>
    printf("The correct order should be ideally 3,4,2,1.\n");
 21a:	00001517          	auipc	a0,0x1
 21e:	a6e50513          	addi	a0,a0,-1426 # c88 <malloc+0x1ec>
 222:	00000097          	auipc	ra,0x0
 226:	7bc080e7          	jalr	1980(ra) # 9de <printf>

}
 22a:	0001                	nop
 22c:	60e2                	ld	ra,24(sp)
 22e:	6442                	ld	s0,16(sp)
 230:	6105                	addi	sp,sp,32
 232:	8082                	ret

0000000000000234 <test1>:

void test1(){
 234:	1101                	addi	sp,sp,-32
 236:	ec06                	sd	ra,24(sp)
 238:	e822                	sd	s0,16(sp)
 23a:	1000                	addi	s0,sp,32
    printf("TEST1\n"); // To check the FCFS part of the implementation
 23c:	00001517          	auipc	a0,0x1
 240:	a7c50513          	addi	a0,a0,-1412 # cb8 <malloc+0x21c>
 244:	00000097          	auipc	ra,0x0
 248:	79a080e7          	jalr	1946(ra) # 9de <printf>
    int tickets = 30; // To check for this finish times
 24c:	47f9                	li	a5,30
 24e:	fef42623          	sw	a5,-20(s0)
    settickets(30); // So that now, the parent will always get the main priority to set up its children
 252:	4579                	li	a0,30
 254:	00000097          	auipc	ra,0x0
 258:	4aa080e7          	jalr	1194(ra) # 6fe <settickets>
    sleep(1); // So that this will have a different ctime than others. Ctime is not entirely very accurate
 25c:	4505                	li	a0,1
 25e:	00000097          	auipc	ra,0x0
 262:	470080e7          	jalr	1136(ra) # 6ce <sleep>

    printf("Child 1 started\n");
 266:	00001517          	auipc	a0,0x1
 26a:	98250513          	addi	a0,a0,-1662 # be8 <malloc+0x14c>
 26e:	00000097          	auipc	ra,0x0
 272:	770080e7          	jalr	1904(ra) # 9de <printf>
    if (fork() == 0) {
 276:	00000097          	auipc	ra,0x0
 27a:	3c0080e7          	jalr	960(ra) # 636 <fork>
 27e:	87aa                	mv	a5,a0
 280:	eb8d                	bnez	a5,2b2 <test1+0x7e>
        settickets(tickets);
 282:	fec42783          	lw	a5,-20(s0)
 286:	853e                	mv	a0,a5
 288:	00000097          	auipc	ra,0x0
 28c:	476080e7          	jalr	1142(ra) # 6fe <settickets>
        usless_work();
 290:	00000097          	auipc	ra,0x0
 294:	d70080e7          	jalr	-656(ra) # 0 <usless_work>
        printf("Child 1 ended\n");
 298:	00001517          	auipc	a0,0x1
 29c:	a2850513          	addi	a0,a0,-1496 # cc0 <malloc+0x224>
 2a0:	00000097          	auipc	ra,0x0
 2a4:	73e080e7          	jalr	1854(ra) # 9de <printf>
        exit(0);
 2a8:	4501                	li	a0,0
 2aa:	00000097          	auipc	ra,0x0
 2ae:	394080e7          	jalr	916(ra) # 63e <exit>
    }
    printf("Child 2 started\n");
 2b2:	00001517          	auipc	a0,0x1
 2b6:	95e50513          	addi	a0,a0,-1698 # c10 <malloc+0x174>
 2ba:	00000097          	auipc	ra,0x0
 2be:	724080e7          	jalr	1828(ra) # 9de <printf>
    if (fork() == 0) {
 2c2:	00000097          	auipc	ra,0x0
 2c6:	374080e7          	jalr	884(ra) # 636 <fork>
 2ca:	87aa                	mv	a5,a0
 2cc:	eb8d                	bnez	a5,2fe <test1+0xca>
        settickets(tickets);
 2ce:	fec42783          	lw	a5,-20(s0)
 2d2:	853e                	mv	a0,a5
 2d4:	00000097          	auipc	ra,0x0
 2d8:	42a080e7          	jalr	1066(ra) # 6fe <settickets>
        usless_work();
 2dc:	00000097          	auipc	ra,0x0
 2e0:	d24080e7          	jalr	-732(ra) # 0 <usless_work>
        printf("Child 2 ended\n");
 2e4:	00001517          	auipc	a0,0x1
 2e8:	9ec50513          	addi	a0,a0,-1556 # cd0 <malloc+0x234>
 2ec:	00000097          	auipc	ra,0x0
 2f0:	6f2080e7          	jalr	1778(ra) # 9de <printf>
        exit(0);
 2f4:	4501                	li	a0,0
 2f6:	00000097          	auipc	ra,0x0
 2fa:	348080e7          	jalr	840(ra) # 63e <exit>
    }
    printf("Child 3 started\n");
 2fe:	00001517          	auipc	a0,0x1
 302:	93a50513          	addi	a0,a0,-1734 # c38 <malloc+0x19c>
 306:	00000097          	auipc	ra,0x0
 30a:	6d8080e7          	jalr	1752(ra) # 9de <printf>
    if (fork() == 0) {
 30e:	00000097          	auipc	ra,0x0
 312:	328080e7          	jalr	808(ra) # 636 <fork>
 316:	87aa                	mv	a5,a0
 318:	eb8d                	bnez	a5,34a <test1+0x116>
        settickets(tickets);
 31a:	fec42783          	lw	a5,-20(s0)
 31e:	853e                	mv	a0,a5
 320:	00000097          	auipc	ra,0x0
 324:	3de080e7          	jalr	990(ra) # 6fe <settickets>
        usless_work();
 328:	00000097          	auipc	ra,0x0
 32c:	cd8080e7          	jalr	-808(ra) # 0 <usless_work>
        printf("Child 3 ended\n");
 330:	00001517          	auipc	a0,0x1
 334:	9b050513          	addi	a0,a0,-1616 # ce0 <malloc+0x244>
 338:	00000097          	auipc	ra,0x0
 33c:	6a6080e7          	jalr	1702(ra) # 9de <printf>
        exit(0);
 340:	4501                	li	a0,0
 342:	00000097          	auipc	ra,0x0
 346:	2fc080e7          	jalr	764(ra) # 63e <exit>
    }
    wait(0);
 34a:	4501                	li	a0,0
 34c:	00000097          	auipc	ra,0x0
 350:	2fa080e7          	jalr	762(ra) # 646 <wait>
    wait(0);
 354:	4501                	li	a0,0
 356:	00000097          	auipc	ra,0x0
 35a:	2f0080e7          	jalr	752(ra) # 646 <wait>
    wait(0);
 35e:	4501                	li	a0,0
 360:	00000097          	auipc	ra,0x0
 364:	2e6080e7          	jalr	742(ra) # 646 <wait>
    printf("The order should be 4,3 and 2 then 1 since all tickets have same value\n");
 368:	00001517          	auipc	a0,0x1
 36c:	98850513          	addi	a0,a0,-1656 # cf0 <malloc+0x254>
 370:	00000097          	auipc	ra,0x0
 374:	66e080e7          	jalr	1646(ra) # 9de <printf>
}
 378:	0001                	nop
 37a:	60e2                	ld	ra,24(sp)
 37c:	6442                	ld	s0,16(sp)
 37e:	6105                	addi	sp,sp,32
 380:	8082                	ret

0000000000000382 <main>:
int main() {
 382:	1141                	addi	sp,sp,-16
 384:	e406                	sd	ra,8(sp)
 386:	e022                	sd	s0,0(sp)
 388:	0800                	addi	s0,sp,16
    test0();
 38a:	00000097          	auipc	ra,0x0
 38e:	cac080e7          	jalr	-852(ra) # 36 <test0>
    test1();
 392:	00000097          	auipc	ra,0x0
 396:	ea2080e7          	jalr	-350(ra) # 234 <test1>
    printf("Finished all tests\n");
 39a:	00001517          	auipc	a0,0x1
 39e:	99e50513          	addi	a0,a0,-1634 # d38 <malloc+0x29c>
 3a2:	00000097          	auipc	ra,0x0
 3a6:	63c080e7          	jalr	1596(ra) # 9de <printf>

    return 0;
 3aa:	4781                	li	a5,0
}
 3ac:	853e                	mv	a0,a5
 3ae:	60a2                	ld	ra,8(sp)
 3b0:	6402                	ld	s0,0(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret

00000000000003b6 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 3b6:	1141                	addi	sp,sp,-16
 3b8:	e406                	sd	ra,8(sp)
 3ba:	e022                	sd	s0,0(sp)
 3bc:	0800                	addi	s0,sp,16
  extern int main();
  main();
 3be:	00000097          	auipc	ra,0x0
 3c2:	fc4080e7          	jalr	-60(ra) # 382 <main>
  exit(0);
 3c6:	4501                	li	a0,0
 3c8:	00000097          	auipc	ra,0x0
 3cc:	276080e7          	jalr	630(ra) # 63e <exit>

00000000000003d0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 3d0:	1141                	addi	sp,sp,-16
 3d2:	e422                	sd	s0,8(sp)
 3d4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 3d6:	87aa                	mv	a5,a0
 3d8:	0585                	addi	a1,a1,1
 3da:	0785                	addi	a5,a5,1
 3dc:	fff5c703          	lbu	a4,-1(a1)
 3e0:	fee78fa3          	sb	a4,-1(a5)
 3e4:	fb75                	bnez	a4,3d8 <strcpy+0x8>
    ;
  return os;
}
 3e6:	6422                	ld	s0,8(sp)
 3e8:	0141                	addi	sp,sp,16
 3ea:	8082                	ret

00000000000003ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3ec:	1141                	addi	sp,sp,-16
 3ee:	e422                	sd	s0,8(sp)
 3f0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 3f2:	00054783          	lbu	a5,0(a0)
 3f6:	cb91                	beqz	a5,40a <strcmp+0x1e>
 3f8:	0005c703          	lbu	a4,0(a1)
 3fc:	00f71763          	bne	a4,a5,40a <strcmp+0x1e>
    p++, q++;
 400:	0505                	addi	a0,a0,1
 402:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 404:	00054783          	lbu	a5,0(a0)
 408:	fbe5                	bnez	a5,3f8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 40a:	0005c503          	lbu	a0,0(a1)
}
 40e:	40a7853b          	subw	a0,a5,a0
 412:	6422                	ld	s0,8(sp)
 414:	0141                	addi	sp,sp,16
 416:	8082                	ret

0000000000000418 <strlen>:

uint
strlen(const char *s)
{
 418:	1141                	addi	sp,sp,-16
 41a:	e422                	sd	s0,8(sp)
 41c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 41e:	00054783          	lbu	a5,0(a0)
 422:	cf91                	beqz	a5,43e <strlen+0x26>
 424:	0505                	addi	a0,a0,1
 426:	87aa                	mv	a5,a0
 428:	4685                	li	a3,1
 42a:	9e89                	subw	a3,a3,a0
 42c:	00f6853b          	addw	a0,a3,a5
 430:	0785                	addi	a5,a5,1
 432:	fff7c703          	lbu	a4,-1(a5)
 436:	fb7d                	bnez	a4,42c <strlen+0x14>
    ;
  return n;
}
 438:	6422                	ld	s0,8(sp)
 43a:	0141                	addi	sp,sp,16
 43c:	8082                	ret
  for(n = 0; s[n]; n++)
 43e:	4501                	li	a0,0
 440:	bfe5                	j	438 <strlen+0x20>

0000000000000442 <memset>:

void*
memset(void *dst, int c, uint n)
{
 442:	1141                	addi	sp,sp,-16
 444:	e422                	sd	s0,8(sp)
 446:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 448:	ca19                	beqz	a2,45e <memset+0x1c>
 44a:	87aa                	mv	a5,a0
 44c:	1602                	slli	a2,a2,0x20
 44e:	9201                	srli	a2,a2,0x20
 450:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 454:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 458:	0785                	addi	a5,a5,1
 45a:	fee79de3          	bne	a5,a4,454 <memset+0x12>
  }
  return dst;
}
 45e:	6422                	ld	s0,8(sp)
 460:	0141                	addi	sp,sp,16
 462:	8082                	ret

0000000000000464 <strchr>:

char*
strchr(const char *s, char c)
{
 464:	1141                	addi	sp,sp,-16
 466:	e422                	sd	s0,8(sp)
 468:	0800                	addi	s0,sp,16
  for(; *s; s++)
 46a:	00054783          	lbu	a5,0(a0)
 46e:	cb99                	beqz	a5,484 <strchr+0x20>
    if(*s == c)
 470:	00f58763          	beq	a1,a5,47e <strchr+0x1a>
  for(; *s; s++)
 474:	0505                	addi	a0,a0,1
 476:	00054783          	lbu	a5,0(a0)
 47a:	fbfd                	bnez	a5,470 <strchr+0xc>
      return (char*)s;
  return 0;
 47c:	4501                	li	a0,0
}
 47e:	6422                	ld	s0,8(sp)
 480:	0141                	addi	sp,sp,16
 482:	8082                	ret
  return 0;
 484:	4501                	li	a0,0
 486:	bfe5                	j	47e <strchr+0x1a>

0000000000000488 <gets>:

char*
gets(char *buf, int max)
{
 488:	711d                	addi	sp,sp,-96
 48a:	ec86                	sd	ra,88(sp)
 48c:	e8a2                	sd	s0,80(sp)
 48e:	e4a6                	sd	s1,72(sp)
 490:	e0ca                	sd	s2,64(sp)
 492:	fc4e                	sd	s3,56(sp)
 494:	f852                	sd	s4,48(sp)
 496:	f456                	sd	s5,40(sp)
 498:	f05a                	sd	s6,32(sp)
 49a:	ec5e                	sd	s7,24(sp)
 49c:	1080                	addi	s0,sp,96
 49e:	8baa                	mv	s7,a0
 4a0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4a2:	892a                	mv	s2,a0
 4a4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 4a6:	4aa9                	li	s5,10
 4a8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 4aa:	89a6                	mv	s3,s1
 4ac:	2485                	addiw	s1,s1,1
 4ae:	0344d863          	bge	s1,s4,4de <gets+0x56>
    cc = read(0, &c, 1);
 4b2:	4605                	li	a2,1
 4b4:	faf40593          	addi	a1,s0,-81
 4b8:	4501                	li	a0,0
 4ba:	00000097          	auipc	ra,0x0
 4be:	19c080e7          	jalr	412(ra) # 656 <read>
    if(cc < 1)
 4c2:	00a05e63          	blez	a0,4de <gets+0x56>
    buf[i++] = c;
 4c6:	faf44783          	lbu	a5,-81(s0)
 4ca:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 4ce:	01578763          	beq	a5,s5,4dc <gets+0x54>
 4d2:	0905                	addi	s2,s2,1
 4d4:	fd679be3          	bne	a5,s6,4aa <gets+0x22>
  for(i=0; i+1 < max; ){
 4d8:	89a6                	mv	s3,s1
 4da:	a011                	j	4de <gets+0x56>
 4dc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 4de:	99de                	add	s3,s3,s7
 4e0:	00098023          	sb	zero,0(s3)
  return buf;
}
 4e4:	855e                	mv	a0,s7
 4e6:	60e6                	ld	ra,88(sp)
 4e8:	6446                	ld	s0,80(sp)
 4ea:	64a6                	ld	s1,72(sp)
 4ec:	6906                	ld	s2,64(sp)
 4ee:	79e2                	ld	s3,56(sp)
 4f0:	7a42                	ld	s4,48(sp)
 4f2:	7aa2                	ld	s5,40(sp)
 4f4:	7b02                	ld	s6,32(sp)
 4f6:	6be2                	ld	s7,24(sp)
 4f8:	6125                	addi	sp,sp,96
 4fa:	8082                	ret

00000000000004fc <stat>:

int
stat(const char *n, struct stat *st)
{
 4fc:	1101                	addi	sp,sp,-32
 4fe:	ec06                	sd	ra,24(sp)
 500:	e822                	sd	s0,16(sp)
 502:	e426                	sd	s1,8(sp)
 504:	e04a                	sd	s2,0(sp)
 506:	1000                	addi	s0,sp,32
 508:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 50a:	4581                	li	a1,0
 50c:	00000097          	auipc	ra,0x0
 510:	172080e7          	jalr	370(ra) # 67e <open>
  if(fd < 0)
 514:	02054563          	bltz	a0,53e <stat+0x42>
 518:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 51a:	85ca                	mv	a1,s2
 51c:	00000097          	auipc	ra,0x0
 520:	17a080e7          	jalr	378(ra) # 696 <fstat>
 524:	892a                	mv	s2,a0
  close(fd);
 526:	8526                	mv	a0,s1
 528:	00000097          	auipc	ra,0x0
 52c:	13e080e7          	jalr	318(ra) # 666 <close>
  return r;
}
 530:	854a                	mv	a0,s2
 532:	60e2                	ld	ra,24(sp)
 534:	6442                	ld	s0,16(sp)
 536:	64a2                	ld	s1,8(sp)
 538:	6902                	ld	s2,0(sp)
 53a:	6105                	addi	sp,sp,32
 53c:	8082                	ret
    return -1;
 53e:	597d                	li	s2,-1
 540:	bfc5                	j	530 <stat+0x34>

0000000000000542 <atoi>:

int
atoi(const char *s)
{
 542:	1141                	addi	sp,sp,-16
 544:	e422                	sd	s0,8(sp)
 546:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 548:	00054603          	lbu	a2,0(a0)
 54c:	fd06079b          	addiw	a5,a2,-48
 550:	0ff7f793          	andi	a5,a5,255
 554:	4725                	li	a4,9
 556:	02f76963          	bltu	a4,a5,588 <atoi+0x46>
 55a:	86aa                	mv	a3,a0
  n = 0;
 55c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 55e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 560:	0685                	addi	a3,a3,1
 562:	0025179b          	slliw	a5,a0,0x2
 566:	9fa9                	addw	a5,a5,a0
 568:	0017979b          	slliw	a5,a5,0x1
 56c:	9fb1                	addw	a5,a5,a2
 56e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 572:	0006c603          	lbu	a2,0(a3)
 576:	fd06071b          	addiw	a4,a2,-48
 57a:	0ff77713          	andi	a4,a4,255
 57e:	fee5f1e3          	bgeu	a1,a4,560 <atoi+0x1e>
  return n;
}
 582:	6422                	ld	s0,8(sp)
 584:	0141                	addi	sp,sp,16
 586:	8082                	ret
  n = 0;
 588:	4501                	li	a0,0
 58a:	bfe5                	j	582 <atoi+0x40>

000000000000058c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 58c:	1141                	addi	sp,sp,-16
 58e:	e422                	sd	s0,8(sp)
 590:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 592:	02b57463          	bgeu	a0,a1,5ba <memmove+0x2e>
    while(n-- > 0)
 596:	00c05f63          	blez	a2,5b4 <memmove+0x28>
 59a:	1602                	slli	a2,a2,0x20
 59c:	9201                	srli	a2,a2,0x20
 59e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 5a2:	872a                	mv	a4,a0
      *dst++ = *src++;
 5a4:	0585                	addi	a1,a1,1
 5a6:	0705                	addi	a4,a4,1
 5a8:	fff5c683          	lbu	a3,-1(a1)
 5ac:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 5b0:	fee79ae3          	bne	a5,a4,5a4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 5b4:	6422                	ld	s0,8(sp)
 5b6:	0141                	addi	sp,sp,16
 5b8:	8082                	ret
    dst += n;
 5ba:	00c50733          	add	a4,a0,a2
    src += n;
 5be:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 5c0:	fec05ae3          	blez	a2,5b4 <memmove+0x28>
 5c4:	fff6079b          	addiw	a5,a2,-1
 5c8:	1782                	slli	a5,a5,0x20
 5ca:	9381                	srli	a5,a5,0x20
 5cc:	fff7c793          	not	a5,a5
 5d0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 5d2:	15fd                	addi	a1,a1,-1
 5d4:	177d                	addi	a4,a4,-1
 5d6:	0005c683          	lbu	a3,0(a1)
 5da:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 5de:	fee79ae3          	bne	a5,a4,5d2 <memmove+0x46>
 5e2:	bfc9                	j	5b4 <memmove+0x28>

00000000000005e4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 5e4:	1141                	addi	sp,sp,-16
 5e6:	e422                	sd	s0,8(sp)
 5e8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 5ea:	ca05                	beqz	a2,61a <memcmp+0x36>
 5ec:	fff6069b          	addiw	a3,a2,-1
 5f0:	1682                	slli	a3,a3,0x20
 5f2:	9281                	srli	a3,a3,0x20
 5f4:	0685                	addi	a3,a3,1
 5f6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 5f8:	00054783          	lbu	a5,0(a0)
 5fc:	0005c703          	lbu	a4,0(a1)
 600:	00e79863          	bne	a5,a4,610 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 604:	0505                	addi	a0,a0,1
    p2++;
 606:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 608:	fed518e3          	bne	a0,a3,5f8 <memcmp+0x14>
  }
  return 0;
 60c:	4501                	li	a0,0
 60e:	a019                	j	614 <memcmp+0x30>
      return *p1 - *p2;
 610:	40e7853b          	subw	a0,a5,a4
}
 614:	6422                	ld	s0,8(sp)
 616:	0141                	addi	sp,sp,16
 618:	8082                	ret
  return 0;
 61a:	4501                	li	a0,0
 61c:	bfe5                	j	614 <memcmp+0x30>

000000000000061e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 61e:	1141                	addi	sp,sp,-16
 620:	e406                	sd	ra,8(sp)
 622:	e022                	sd	s0,0(sp)
 624:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 626:	00000097          	auipc	ra,0x0
 62a:	f66080e7          	jalr	-154(ra) # 58c <memmove>
}
 62e:	60a2                	ld	ra,8(sp)
 630:	6402                	ld	s0,0(sp)
 632:	0141                	addi	sp,sp,16
 634:	8082                	ret

0000000000000636 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 636:	4885                	li	a7,1
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <exit>:
.global exit
exit:
 li a7, SYS_exit
 63e:	4889                	li	a7,2
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <wait>:
.global wait
wait:
 li a7, SYS_wait
 646:	488d                	li	a7,3
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 64e:	4891                	li	a7,4
 ecall
 650:	00000073          	ecall
 ret
 654:	8082                	ret

0000000000000656 <read>:
.global read
read:
 li a7, SYS_read
 656:	4895                	li	a7,5
 ecall
 658:	00000073          	ecall
 ret
 65c:	8082                	ret

000000000000065e <write>:
.global write
write:
 li a7, SYS_write
 65e:	48c1                	li	a7,16
 ecall
 660:	00000073          	ecall
 ret
 664:	8082                	ret

0000000000000666 <close>:
.global close
close:
 li a7, SYS_close
 666:	48d5                	li	a7,21
 ecall
 668:	00000073          	ecall
 ret
 66c:	8082                	ret

000000000000066e <kill>:
.global kill
kill:
 li a7, SYS_kill
 66e:	4899                	li	a7,6
 ecall
 670:	00000073          	ecall
 ret
 674:	8082                	ret

0000000000000676 <exec>:
.global exec
exec:
 li a7, SYS_exec
 676:	489d                	li	a7,7
 ecall
 678:	00000073          	ecall
 ret
 67c:	8082                	ret

000000000000067e <open>:
.global open
open:
 li a7, SYS_open
 67e:	48bd                	li	a7,15
 ecall
 680:	00000073          	ecall
 ret
 684:	8082                	ret

0000000000000686 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 686:	48c5                	li	a7,17
 ecall
 688:	00000073          	ecall
 ret
 68c:	8082                	ret

000000000000068e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 68e:	48c9                	li	a7,18
 ecall
 690:	00000073          	ecall
 ret
 694:	8082                	ret

0000000000000696 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 696:	48a1                	li	a7,8
 ecall
 698:	00000073          	ecall
 ret
 69c:	8082                	ret

000000000000069e <link>:
.global link
link:
 li a7, SYS_link
 69e:	48cd                	li	a7,19
 ecall
 6a0:	00000073          	ecall
 ret
 6a4:	8082                	ret

00000000000006a6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 6a6:	48d1                	li	a7,20
 ecall
 6a8:	00000073          	ecall
 ret
 6ac:	8082                	ret

00000000000006ae <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 6ae:	48a5                	li	a7,9
 ecall
 6b0:	00000073          	ecall
 ret
 6b4:	8082                	ret

00000000000006b6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 6b6:	48a9                	li	a7,10
 ecall
 6b8:	00000073          	ecall
 ret
 6bc:	8082                	ret

00000000000006be <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 6be:	48ad                	li	a7,11
 ecall
 6c0:	00000073          	ecall
 ret
 6c4:	8082                	ret

00000000000006c6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 6c6:	48b1                	li	a7,12
 ecall
 6c8:	00000073          	ecall
 ret
 6cc:	8082                	ret

00000000000006ce <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 6ce:	48b5                	li	a7,13
 ecall
 6d0:	00000073          	ecall
 ret
 6d4:	8082                	ret

00000000000006d6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6d6:	48b9                	li	a7,14
 ecall
 6d8:	00000073          	ecall
 ret
 6dc:	8082                	ret

00000000000006de <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 6de:	48d9                	li	a7,22
 ecall
 6e0:	00000073          	ecall
 ret
 6e4:	8082                	ret

00000000000006e6 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 6e6:	48dd                	li	a7,23
 ecall
 6e8:	00000073          	ecall
 ret
 6ec:	8082                	ret

00000000000006ee <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 6ee:	48e1                	li	a7,24
 ecall
 6f0:	00000073          	ecall
 ret
 6f4:	8082                	ret

00000000000006f6 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 6f6:	48e5                	li	a7,25
 ecall
 6f8:	00000073          	ecall
 ret
 6fc:	8082                	ret

00000000000006fe <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 6fe:	48e9                	li	a7,26
 ecall
 700:	00000073          	ecall
 ret
 704:	8082                	ret

0000000000000706 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 706:	1101                	addi	sp,sp,-32
 708:	ec06                	sd	ra,24(sp)
 70a:	e822                	sd	s0,16(sp)
 70c:	1000                	addi	s0,sp,32
 70e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 712:	4605                	li	a2,1
 714:	fef40593          	addi	a1,s0,-17
 718:	00000097          	auipc	ra,0x0
 71c:	f46080e7          	jalr	-186(ra) # 65e <write>
}
 720:	60e2                	ld	ra,24(sp)
 722:	6442                	ld	s0,16(sp)
 724:	6105                	addi	sp,sp,32
 726:	8082                	ret

0000000000000728 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 728:	7139                	addi	sp,sp,-64
 72a:	fc06                	sd	ra,56(sp)
 72c:	f822                	sd	s0,48(sp)
 72e:	f426                	sd	s1,40(sp)
 730:	f04a                	sd	s2,32(sp)
 732:	ec4e                	sd	s3,24(sp)
 734:	0080                	addi	s0,sp,64
 736:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 738:	c299                	beqz	a3,73e <printint+0x16>
 73a:	0805c863          	bltz	a1,7ca <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 73e:	2581                	sext.w	a1,a1
  neg = 0;
 740:	4881                	li	a7,0
 742:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 746:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 748:	2601                	sext.w	a2,a2
 74a:	00000517          	auipc	a0,0x0
 74e:	60e50513          	addi	a0,a0,1550 # d58 <digits>
 752:	883a                	mv	a6,a4
 754:	2705                	addiw	a4,a4,1
 756:	02c5f7bb          	remuw	a5,a1,a2
 75a:	1782                	slli	a5,a5,0x20
 75c:	9381                	srli	a5,a5,0x20
 75e:	97aa                	add	a5,a5,a0
 760:	0007c783          	lbu	a5,0(a5)
 764:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 768:	0005879b          	sext.w	a5,a1
 76c:	02c5d5bb          	divuw	a1,a1,a2
 770:	0685                	addi	a3,a3,1
 772:	fec7f0e3          	bgeu	a5,a2,752 <printint+0x2a>
  if(neg)
 776:	00088b63          	beqz	a7,78c <printint+0x64>
    buf[i++] = '-';
 77a:	fd040793          	addi	a5,s0,-48
 77e:	973e                	add	a4,a4,a5
 780:	02d00793          	li	a5,45
 784:	fef70823          	sb	a5,-16(a4)
 788:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 78c:	02e05863          	blez	a4,7bc <printint+0x94>
 790:	fc040793          	addi	a5,s0,-64
 794:	00e78933          	add	s2,a5,a4
 798:	fff78993          	addi	s3,a5,-1
 79c:	99ba                	add	s3,s3,a4
 79e:	377d                	addiw	a4,a4,-1
 7a0:	1702                	slli	a4,a4,0x20
 7a2:	9301                	srli	a4,a4,0x20
 7a4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 7a8:	fff94583          	lbu	a1,-1(s2)
 7ac:	8526                	mv	a0,s1
 7ae:	00000097          	auipc	ra,0x0
 7b2:	f58080e7          	jalr	-168(ra) # 706 <putc>
  while(--i >= 0)
 7b6:	197d                	addi	s2,s2,-1
 7b8:	ff3918e3          	bne	s2,s3,7a8 <printint+0x80>
}
 7bc:	70e2                	ld	ra,56(sp)
 7be:	7442                	ld	s0,48(sp)
 7c0:	74a2                	ld	s1,40(sp)
 7c2:	7902                	ld	s2,32(sp)
 7c4:	69e2                	ld	s3,24(sp)
 7c6:	6121                	addi	sp,sp,64
 7c8:	8082                	ret
    x = -xx;
 7ca:	40b005bb          	negw	a1,a1
    neg = 1;
 7ce:	4885                	li	a7,1
    x = -xx;
 7d0:	bf8d                	j	742 <printint+0x1a>

00000000000007d2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7d2:	7119                	addi	sp,sp,-128
 7d4:	fc86                	sd	ra,120(sp)
 7d6:	f8a2                	sd	s0,112(sp)
 7d8:	f4a6                	sd	s1,104(sp)
 7da:	f0ca                	sd	s2,96(sp)
 7dc:	ecce                	sd	s3,88(sp)
 7de:	e8d2                	sd	s4,80(sp)
 7e0:	e4d6                	sd	s5,72(sp)
 7e2:	e0da                	sd	s6,64(sp)
 7e4:	fc5e                	sd	s7,56(sp)
 7e6:	f862                	sd	s8,48(sp)
 7e8:	f466                	sd	s9,40(sp)
 7ea:	f06a                	sd	s10,32(sp)
 7ec:	ec6e                	sd	s11,24(sp)
 7ee:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7f0:	0005c903          	lbu	s2,0(a1)
 7f4:	18090f63          	beqz	s2,992 <vprintf+0x1c0>
 7f8:	8aaa                	mv	s5,a0
 7fa:	8b32                	mv	s6,a2
 7fc:	00158493          	addi	s1,a1,1
  state = 0;
 800:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 802:	02500a13          	li	s4,37
      if(c == 'd'){
 806:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 80a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 80e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 812:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 816:	00000b97          	auipc	s7,0x0
 81a:	542b8b93          	addi	s7,s7,1346 # d58 <digits>
 81e:	a839                	j	83c <vprintf+0x6a>
        putc(fd, c);
 820:	85ca                	mv	a1,s2
 822:	8556                	mv	a0,s5
 824:	00000097          	auipc	ra,0x0
 828:	ee2080e7          	jalr	-286(ra) # 706 <putc>
 82c:	a019                	j	832 <vprintf+0x60>
    } else if(state == '%'){
 82e:	01498f63          	beq	s3,s4,84c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 832:	0485                	addi	s1,s1,1
 834:	fff4c903          	lbu	s2,-1(s1)
 838:	14090d63          	beqz	s2,992 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 83c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 840:	fe0997e3          	bnez	s3,82e <vprintf+0x5c>
      if(c == '%'){
 844:	fd479ee3          	bne	a5,s4,820 <vprintf+0x4e>
        state = '%';
 848:	89be                	mv	s3,a5
 84a:	b7e5                	j	832 <vprintf+0x60>
      if(c == 'd'){
 84c:	05878063          	beq	a5,s8,88c <vprintf+0xba>
      } else if(c == 'l') {
 850:	05978c63          	beq	a5,s9,8a8 <vprintf+0xd6>
      } else if(c == 'x') {
 854:	07a78863          	beq	a5,s10,8c4 <vprintf+0xf2>
      } else if(c == 'p') {
 858:	09b78463          	beq	a5,s11,8e0 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 85c:	07300713          	li	a4,115
 860:	0ce78663          	beq	a5,a4,92c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 864:	06300713          	li	a4,99
 868:	0ee78e63          	beq	a5,a4,964 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 86c:	11478863          	beq	a5,s4,97c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 870:	85d2                	mv	a1,s4
 872:	8556                	mv	a0,s5
 874:	00000097          	auipc	ra,0x0
 878:	e92080e7          	jalr	-366(ra) # 706 <putc>
        putc(fd, c);
 87c:	85ca                	mv	a1,s2
 87e:	8556                	mv	a0,s5
 880:	00000097          	auipc	ra,0x0
 884:	e86080e7          	jalr	-378(ra) # 706 <putc>
      }
      state = 0;
 888:	4981                	li	s3,0
 88a:	b765                	j	832 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 88c:	008b0913          	addi	s2,s6,8
 890:	4685                	li	a3,1
 892:	4629                	li	a2,10
 894:	000b2583          	lw	a1,0(s6)
 898:	8556                	mv	a0,s5
 89a:	00000097          	auipc	ra,0x0
 89e:	e8e080e7          	jalr	-370(ra) # 728 <printint>
 8a2:	8b4a                	mv	s6,s2
      state = 0;
 8a4:	4981                	li	s3,0
 8a6:	b771                	j	832 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8a8:	008b0913          	addi	s2,s6,8
 8ac:	4681                	li	a3,0
 8ae:	4629                	li	a2,10
 8b0:	000b2583          	lw	a1,0(s6)
 8b4:	8556                	mv	a0,s5
 8b6:	00000097          	auipc	ra,0x0
 8ba:	e72080e7          	jalr	-398(ra) # 728 <printint>
 8be:	8b4a                	mv	s6,s2
      state = 0;
 8c0:	4981                	li	s3,0
 8c2:	bf85                	j	832 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 8c4:	008b0913          	addi	s2,s6,8
 8c8:	4681                	li	a3,0
 8ca:	4641                	li	a2,16
 8cc:	000b2583          	lw	a1,0(s6)
 8d0:	8556                	mv	a0,s5
 8d2:	00000097          	auipc	ra,0x0
 8d6:	e56080e7          	jalr	-426(ra) # 728 <printint>
 8da:	8b4a                	mv	s6,s2
      state = 0;
 8dc:	4981                	li	s3,0
 8de:	bf91                	j	832 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 8e0:	008b0793          	addi	a5,s6,8
 8e4:	f8f43423          	sd	a5,-120(s0)
 8e8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 8ec:	03000593          	li	a1,48
 8f0:	8556                	mv	a0,s5
 8f2:	00000097          	auipc	ra,0x0
 8f6:	e14080e7          	jalr	-492(ra) # 706 <putc>
  putc(fd, 'x');
 8fa:	85ea                	mv	a1,s10
 8fc:	8556                	mv	a0,s5
 8fe:	00000097          	auipc	ra,0x0
 902:	e08080e7          	jalr	-504(ra) # 706 <putc>
 906:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 908:	03c9d793          	srli	a5,s3,0x3c
 90c:	97de                	add	a5,a5,s7
 90e:	0007c583          	lbu	a1,0(a5)
 912:	8556                	mv	a0,s5
 914:	00000097          	auipc	ra,0x0
 918:	df2080e7          	jalr	-526(ra) # 706 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 91c:	0992                	slli	s3,s3,0x4
 91e:	397d                	addiw	s2,s2,-1
 920:	fe0914e3          	bnez	s2,908 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 924:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 928:	4981                	li	s3,0
 92a:	b721                	j	832 <vprintf+0x60>
        s = va_arg(ap, char*);
 92c:	008b0993          	addi	s3,s6,8
 930:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 934:	02090163          	beqz	s2,956 <vprintf+0x184>
        while(*s != 0){
 938:	00094583          	lbu	a1,0(s2)
 93c:	c9a1                	beqz	a1,98c <vprintf+0x1ba>
          putc(fd, *s);
 93e:	8556                	mv	a0,s5
 940:	00000097          	auipc	ra,0x0
 944:	dc6080e7          	jalr	-570(ra) # 706 <putc>
          s++;
 948:	0905                	addi	s2,s2,1
        while(*s != 0){
 94a:	00094583          	lbu	a1,0(s2)
 94e:	f9e5                	bnez	a1,93e <vprintf+0x16c>
        s = va_arg(ap, char*);
 950:	8b4e                	mv	s6,s3
      state = 0;
 952:	4981                	li	s3,0
 954:	bdf9                	j	832 <vprintf+0x60>
          s = "(null)";
 956:	00000917          	auipc	s2,0x0
 95a:	3fa90913          	addi	s2,s2,1018 # d50 <malloc+0x2b4>
        while(*s != 0){
 95e:	02800593          	li	a1,40
 962:	bff1                	j	93e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 964:	008b0913          	addi	s2,s6,8
 968:	000b4583          	lbu	a1,0(s6)
 96c:	8556                	mv	a0,s5
 96e:	00000097          	auipc	ra,0x0
 972:	d98080e7          	jalr	-616(ra) # 706 <putc>
 976:	8b4a                	mv	s6,s2
      state = 0;
 978:	4981                	li	s3,0
 97a:	bd65                	j	832 <vprintf+0x60>
        putc(fd, c);
 97c:	85d2                	mv	a1,s4
 97e:	8556                	mv	a0,s5
 980:	00000097          	auipc	ra,0x0
 984:	d86080e7          	jalr	-634(ra) # 706 <putc>
      state = 0;
 988:	4981                	li	s3,0
 98a:	b565                	j	832 <vprintf+0x60>
        s = va_arg(ap, char*);
 98c:	8b4e                	mv	s6,s3
      state = 0;
 98e:	4981                	li	s3,0
 990:	b54d                	j	832 <vprintf+0x60>
    }
  }
}
 992:	70e6                	ld	ra,120(sp)
 994:	7446                	ld	s0,112(sp)
 996:	74a6                	ld	s1,104(sp)
 998:	7906                	ld	s2,96(sp)
 99a:	69e6                	ld	s3,88(sp)
 99c:	6a46                	ld	s4,80(sp)
 99e:	6aa6                	ld	s5,72(sp)
 9a0:	6b06                	ld	s6,64(sp)
 9a2:	7be2                	ld	s7,56(sp)
 9a4:	7c42                	ld	s8,48(sp)
 9a6:	7ca2                	ld	s9,40(sp)
 9a8:	7d02                	ld	s10,32(sp)
 9aa:	6de2                	ld	s11,24(sp)
 9ac:	6109                	addi	sp,sp,128
 9ae:	8082                	ret

00000000000009b0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9b0:	715d                	addi	sp,sp,-80
 9b2:	ec06                	sd	ra,24(sp)
 9b4:	e822                	sd	s0,16(sp)
 9b6:	1000                	addi	s0,sp,32
 9b8:	e010                	sd	a2,0(s0)
 9ba:	e414                	sd	a3,8(s0)
 9bc:	e818                	sd	a4,16(s0)
 9be:	ec1c                	sd	a5,24(s0)
 9c0:	03043023          	sd	a6,32(s0)
 9c4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9c8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9cc:	8622                	mv	a2,s0
 9ce:	00000097          	auipc	ra,0x0
 9d2:	e04080e7          	jalr	-508(ra) # 7d2 <vprintf>
}
 9d6:	60e2                	ld	ra,24(sp)
 9d8:	6442                	ld	s0,16(sp)
 9da:	6161                	addi	sp,sp,80
 9dc:	8082                	ret

00000000000009de <printf>:

void
printf(const char *fmt, ...)
{
 9de:	711d                	addi	sp,sp,-96
 9e0:	ec06                	sd	ra,24(sp)
 9e2:	e822                	sd	s0,16(sp)
 9e4:	1000                	addi	s0,sp,32
 9e6:	e40c                	sd	a1,8(s0)
 9e8:	e810                	sd	a2,16(s0)
 9ea:	ec14                	sd	a3,24(s0)
 9ec:	f018                	sd	a4,32(s0)
 9ee:	f41c                	sd	a5,40(s0)
 9f0:	03043823          	sd	a6,48(s0)
 9f4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9f8:	00840613          	addi	a2,s0,8
 9fc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a00:	85aa                	mv	a1,a0
 a02:	4505                	li	a0,1
 a04:	00000097          	auipc	ra,0x0
 a08:	dce080e7          	jalr	-562(ra) # 7d2 <vprintf>
}
 a0c:	60e2                	ld	ra,24(sp)
 a0e:	6442                	ld	s0,16(sp)
 a10:	6125                	addi	sp,sp,96
 a12:	8082                	ret

0000000000000a14 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a14:	1141                	addi	sp,sp,-16
 a16:	e422                	sd	s0,8(sp)
 a18:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a1a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a1e:	00000797          	auipc	a5,0x0
 a22:	5e27b783          	ld	a5,1506(a5) # 1000 <freep>
 a26:	a805                	j	a56 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a28:	4618                	lw	a4,8(a2)
 a2a:	9db9                	addw	a1,a1,a4
 a2c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a30:	6398                	ld	a4,0(a5)
 a32:	6318                	ld	a4,0(a4)
 a34:	fee53823          	sd	a4,-16(a0)
 a38:	a091                	j	a7c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a3a:	ff852703          	lw	a4,-8(a0)
 a3e:	9e39                	addw	a2,a2,a4
 a40:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 a42:	ff053703          	ld	a4,-16(a0)
 a46:	e398                	sd	a4,0(a5)
 a48:	a099                	j	a8e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a4a:	6398                	ld	a4,0(a5)
 a4c:	00e7e463          	bltu	a5,a4,a54 <free+0x40>
 a50:	00e6ea63          	bltu	a3,a4,a64 <free+0x50>
{
 a54:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a56:	fed7fae3          	bgeu	a5,a3,a4a <free+0x36>
 a5a:	6398                	ld	a4,0(a5)
 a5c:	00e6e463          	bltu	a3,a4,a64 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a60:	fee7eae3          	bltu	a5,a4,a54 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 a64:	ff852583          	lw	a1,-8(a0)
 a68:	6390                	ld	a2,0(a5)
 a6a:	02059713          	slli	a4,a1,0x20
 a6e:	9301                	srli	a4,a4,0x20
 a70:	0712                	slli	a4,a4,0x4
 a72:	9736                	add	a4,a4,a3
 a74:	fae60ae3          	beq	a2,a4,a28 <free+0x14>
    bp->s.ptr = p->s.ptr;
 a78:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a7c:	4790                	lw	a2,8(a5)
 a7e:	02061713          	slli	a4,a2,0x20
 a82:	9301                	srli	a4,a4,0x20
 a84:	0712                	slli	a4,a4,0x4
 a86:	973e                	add	a4,a4,a5
 a88:	fae689e3          	beq	a3,a4,a3a <free+0x26>
  } else
    p->s.ptr = bp;
 a8c:	e394                	sd	a3,0(a5)
  freep = p;
 a8e:	00000717          	auipc	a4,0x0
 a92:	56f73923          	sd	a5,1394(a4) # 1000 <freep>
}
 a96:	6422                	ld	s0,8(sp)
 a98:	0141                	addi	sp,sp,16
 a9a:	8082                	ret

0000000000000a9c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a9c:	7139                	addi	sp,sp,-64
 a9e:	fc06                	sd	ra,56(sp)
 aa0:	f822                	sd	s0,48(sp)
 aa2:	f426                	sd	s1,40(sp)
 aa4:	f04a                	sd	s2,32(sp)
 aa6:	ec4e                	sd	s3,24(sp)
 aa8:	e852                	sd	s4,16(sp)
 aaa:	e456                	sd	s5,8(sp)
 aac:	e05a                	sd	s6,0(sp)
 aae:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ab0:	02051493          	slli	s1,a0,0x20
 ab4:	9081                	srli	s1,s1,0x20
 ab6:	04bd                	addi	s1,s1,15
 ab8:	8091                	srli	s1,s1,0x4
 aba:	0014899b          	addiw	s3,s1,1
 abe:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ac0:	00000517          	auipc	a0,0x0
 ac4:	54053503          	ld	a0,1344(a0) # 1000 <freep>
 ac8:	c515                	beqz	a0,af4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 acc:	4798                	lw	a4,8(a5)
 ace:	02977f63          	bgeu	a4,s1,b0c <malloc+0x70>
 ad2:	8a4e                	mv	s4,s3
 ad4:	0009871b          	sext.w	a4,s3
 ad8:	6685                	lui	a3,0x1
 ada:	00d77363          	bgeu	a4,a3,ae0 <malloc+0x44>
 ade:	6a05                	lui	s4,0x1
 ae0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ae4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ae8:	00000917          	auipc	s2,0x0
 aec:	51890913          	addi	s2,s2,1304 # 1000 <freep>
  if(p == (char*)-1)
 af0:	5afd                	li	s5,-1
 af2:	a88d                	j	b64 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 af4:	00000797          	auipc	a5,0x0
 af8:	51c78793          	addi	a5,a5,1308 # 1010 <base>
 afc:	00000717          	auipc	a4,0x0
 b00:	50f73223          	sd	a5,1284(a4) # 1000 <freep>
 b04:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b06:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b0a:	b7e1                	j	ad2 <malloc+0x36>
      if(p->s.size == nunits)
 b0c:	02e48b63          	beq	s1,a4,b42 <malloc+0xa6>
        p->s.size -= nunits;
 b10:	4137073b          	subw	a4,a4,s3
 b14:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b16:	1702                	slli	a4,a4,0x20
 b18:	9301                	srli	a4,a4,0x20
 b1a:	0712                	slli	a4,a4,0x4
 b1c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b1e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b22:	00000717          	auipc	a4,0x0
 b26:	4ca73f23          	sd	a0,1246(a4) # 1000 <freep>
      return (void*)(p + 1);
 b2a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b2e:	70e2                	ld	ra,56(sp)
 b30:	7442                	ld	s0,48(sp)
 b32:	74a2                	ld	s1,40(sp)
 b34:	7902                	ld	s2,32(sp)
 b36:	69e2                	ld	s3,24(sp)
 b38:	6a42                	ld	s4,16(sp)
 b3a:	6aa2                	ld	s5,8(sp)
 b3c:	6b02                	ld	s6,0(sp)
 b3e:	6121                	addi	sp,sp,64
 b40:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b42:	6398                	ld	a4,0(a5)
 b44:	e118                	sd	a4,0(a0)
 b46:	bff1                	j	b22 <malloc+0x86>
  hp->s.size = nu;
 b48:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b4c:	0541                	addi	a0,a0,16
 b4e:	00000097          	auipc	ra,0x0
 b52:	ec6080e7          	jalr	-314(ra) # a14 <free>
  return freep;
 b56:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b5a:	d971                	beqz	a0,b2e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b5c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b5e:	4798                	lw	a4,8(a5)
 b60:	fa9776e3          	bgeu	a4,s1,b0c <malloc+0x70>
    if(p == freep)
 b64:	00093703          	ld	a4,0(s2)
 b68:	853e                	mv	a0,a5
 b6a:	fef719e3          	bne	a4,a5,b5c <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 b6e:	8552                	mv	a0,s4
 b70:	00000097          	auipc	ra,0x0
 b74:	b56080e7          	jalr	-1194(ra) # 6c6 <sbrk>
  if(p == (char*)-1)
 b78:	fd5518e3          	bne	a0,s5,b48 <malloc+0xac>
        return 0;
 b7c:	4501                	li	a0,0
 b7e:	bf45                	j	b2e <malloc+0x92>
