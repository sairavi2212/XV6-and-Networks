
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a5010113          	addi	sp,sp,-1456 # 80008a50 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8be70713          	addi	a4,a4,-1858 # 80008910 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	14c78793          	addi	a5,a5,332 # 800061b0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd9c7f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	57a080e7          	jalr	1402(ra) # 800026a6 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8c650513          	addi	a0,a0,-1850 # 80010a50 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8b648493          	addi	s1,s1,-1866 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	94690913          	addi	s2,s2,-1722 # 80010ae8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	82a080e7          	jalr	-2006(ra) # 800019ea <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	328080e7          	jalr	808(ra) # 800024f0 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	04a080e7          	jalr	74(ra) # 80002220 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	43e080e7          	jalr	1086(ra) # 80002650 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	82a50513          	addi	a0,a0,-2006 # 80010a50 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	81450513          	addi	a0,a0,-2028 # 80010a50 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	86f72b23          	sw	a5,-1930(a4) # 80010ae8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	78450513          	addi	a0,a0,1924 # 80010a50 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	40a080e7          	jalr	1034(ra) # 800026fc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	75650513          	addi	a0,a0,1878 # 80010a50 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	73270713          	addi	a4,a4,1842 # 80010a50 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	70878793          	addi	a5,a5,1800 # 80010a50 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7727a783          	lw	a5,1906(a5) # 80010ae8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6c670713          	addi	a4,a4,1734 # 80010a50 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6b648493          	addi	s1,s1,1718 # 80010a50 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	67a70713          	addi	a4,a4,1658 # 80010a50 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72223          	sw	a5,1796(a4) # 80010af0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	63e78793          	addi	a5,a5,1598 # 80010a50 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ac7ab23          	sw	a2,1718(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6aa50513          	addi	a0,a0,1706 # 80010ae8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	e3e080e7          	jalr	-450(ra) # 80002284 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	5f050513          	addi	a0,a0,1520 # 80010a50 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00023797          	auipc	a5,0x23
    8000047c:	57078793          	addi	a5,a5,1392 # 800239e8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	5c07a323          	sw	zero,1478(a5) # 80010b10 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	34f72923          	sw	a5,850(a4) # 800088d0 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	556dad83          	lw	s11,1366(s11) # 80010b10 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	50050513          	addi	a0,a0,1280 # 80010af8 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	3a250513          	addi	a0,a0,930 # 80010af8 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	38648493          	addi	s1,s1,902 # 80010af8 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	34650513          	addi	a0,a0,838 # 80010b18 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0d27a783          	lw	a5,210(a5) # 800088d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0a27b783          	ld	a5,162(a5) # 800088d8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0a273703          	ld	a4,162(a4) # 800088e0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	2b8a0a13          	addi	s4,s4,696 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	07048493          	addi	s1,s1,112 # 800088d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	07098993          	addi	s3,s3,112 # 800088e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	9f2080e7          	jalr	-1550(ra) # 80002284 <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	24a50513          	addi	a0,a0,586 # 80010b18 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	ff27a783          	lw	a5,-14(a5) # 800088d0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	ff873703          	ld	a4,-8(a4) # 800088e0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fe87b783          	ld	a5,-24(a5) # 800088d8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	21c98993          	addi	s3,s3,540 # 80010b18 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fd448493          	addi	s1,s1,-44 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fd490913          	addi	s2,s2,-44 # 800088e0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	904080e7          	jalr	-1788(ra) # 80002220 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1e648493          	addi	s1,s1,486 # 80010b18 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f8e7bd23          	sd	a4,-102(a5) # 800088e0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	15c48493          	addi	s1,s1,348 # 80010b18 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00024797          	auipc	a5,0x24
    80000a02:	18278793          	addi	a5,a5,386 # 80024b80 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	13290913          	addi	s2,s2,306 # 80010b50 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	09650513          	addi	a0,a0,150 # 80010b50 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00024517          	auipc	a0,0x24
    80000ad2:	0b250513          	addi	a0,a0,178 # 80024b80 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	06048493          	addi	s1,s1,96 # 80010b50 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	04850513          	addi	a0,a0,72 # 80010b50 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	01c50513          	addi	a0,a0,28 # 80010b50 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e5e080e7          	jalr	-418(ra) # 800019ce <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	e2c080e7          	jalr	-468(ra) # 800019ce <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	e20080e7          	jalr	-480(ra) # 800019ce <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	e08080e7          	jalr	-504(ra) # 800019ce <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	dc8080e7          	jalr	-568(ra) # 800019ce <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d9c080e7          	jalr	-612(ra) # 800019ce <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b3e080e7          	jalr	-1218(ra) # 800019be <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a6070713          	addi	a4,a4,-1440 # 800088e8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	b22080e7          	jalr	-1246(ra) # 800019be <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	b2c080e7          	jalr	-1236(ra) # 800029ea <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	32a080e7          	jalr	810(ra) # 800061f0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	0cc080e7          	jalr	204(ra) # 80001f9a <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	9dc080e7          	jalr	-1572(ra) # 8000190a <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	a8c080e7          	jalr	-1396(ra) # 800029c2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	aac080e7          	jalr	-1364(ra) # 800029ea <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	294080e7          	jalr	660(ra) # 800061da <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	2a2080e7          	jalr	674(ra) # 800061f0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	444080e7          	jalr	1092(ra) # 8000339a <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	ae8080e7          	jalr	-1304(ra) # 80003a46 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	a86080e7          	jalr	-1402(ra) # 800049ec <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	38a080e7          	jalr	906(ra) # 800062f8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	dd6080e7          	jalr	-554(ra) # 80001d4c <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	96f72223          	sw	a5,-1692(a4) # 800088e8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9587b783          	ld	a5,-1704(a5) # 800088f0 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55a080e7          	jalr	1370(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	00a7d513          	srli	a0,a5,0xa
    80001096:	0532                	slli	a0,a0,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	77fd                	lui	a5,0xfffff
    800010bc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	15fd                	addi	a1,a1,-1
    800010c2:	00c589b3          	add	s3,a1,a2
    800010c6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ca:	8952                	mv	s2,s4
    800010cc:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	434080e7          	jalr	1076(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3d8080e7          	jalr	984(ra) # 8000053e <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	68a7be23          	sd	a0,1692(a5) # 800088f0 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6cc080e7          	jalr	1740(ra) # 800009ea <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	767d                	lui	a2,0xfffff
    800013e4:	8f71                	and	a4,a4,a2
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff1                	and	a5,a5,a2
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	54a080e7          	jalr	1354(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c7650513          	addi	a0,a0,-906 # 80008178 <digits+0x138>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	034080e7          	jalr	52(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	4d6080e7          	jalr	1238(ra) # 800009ea <kfree>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
  if(sz > 0)
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
}
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154e:	6605                	lui	a2,0x1
    80001550:	167d                	addi	a2,a2,-1
    80001552:	962e                	add	a2,a2,a1
    80001554:	4685                	li	a3,1
    80001556:	8231                	srli	a2,a2,0xc
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	d0a080e7          	jalr	-758(ra) # 80001264 <uvmunmap>
    80001562:	bfe1                	j	8000153a <uvmfree+0xe>

0000000080001564 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
{
    80001566:	715d                	addi	sp,sp,-80
    80001568:	e486                	sd	ra,72(sp)
    8000156a:	e0a2                	sd	s0,64(sp)
    8000156c:	fc26                	sd	s1,56(sp)
    8000156e:	f84a                	sd	s2,48(sp)
    80001570:	f44e                	sd	s3,40(sp)
    80001572:	f052                	sd	s4,32(sp)
    80001574:	ec56                	sd	s5,24(sp)
    80001576:	e85a                	sd	s6,16(sp)
    80001578:	e45e                	sd	s7,8(sp)
    8000157a:	0880                	addi	s0,sp,80
    8000157c:	8b2a                	mv	s6,a0
    8000157e:	8aae                	mv	s5,a1
    80001580:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001582:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a2c080e7          	jalr	-1492(ra) # 80000fb6 <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	53e080e7          	jalr	1342(ra) # 80000ae6 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	ad4080e7          	jalr	-1324(ra) # 8000109e <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	baa50513          	addi	a0,a0,-1110 # 80008188 <digits+0x148>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bba50513          	addi	a0,a0,-1094 # 800081a8 <digits+0x168>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
      kfree(mem);
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	3ea080e7          	jalr	1002(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c52080e7          	jalr	-942(ra) # 80001264 <uvmunmap>
  return -1;
    8000161a:	557d                	li	a0,-1
}
    8000161c:	60a6                	ld	ra,72(sp)
    8000161e:	6406                	ld	s0,64(sp)
    80001620:	74e2                	ld	s1,56(sp)
    80001622:	7942                	ld	s2,48(sp)
    80001624:	79a2                	ld	s3,40(sp)
    80001626:	7a02                	ld	s4,32(sp)
    80001628:	6ae2                	ld	s5,24(sp)
    8000162a:	6b42                	ld	s6,16(sp)
    8000162c:	6ba2                	ld	s7,8(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret
  return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret

0000000080001636 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	976080e7          	jalr	-1674(ra) # 80000fb6 <walk>
  if(pte == 0)
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
}
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    panic("uvmclear");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800081c8 <digits+0x188>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>

0000000080001668 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
{
    8000166a:	715d                	addi	sp,sp,-80
    8000166c:	e486                	sd	ra,72(sp)
    8000166e:	e0a2                	sd	s0,64(sp)
    80001670:	fc26                	sd	s1,56(sp)
    80001672:	f84a                	sd	s2,48(sp)
    80001674:	f44e                	sd	s3,40(sp)
    80001676:	f052                	sd	s4,32(sp)
    80001678:	ec56                	sd	s5,24(sp)
    8000167a:	e85a                	sd	s6,16(sp)
    8000167c:	e45e                	sd	s7,8(sp)
    8000167e:	e062                	sd	s8,0(sp)
    80001680:	0880                	addi	s0,sp,80
    80001682:	8b2a                	mv	s6,a0
    80001684:	8c2e                	mv	s8,a1
    80001686:	8a32                	mv	s4,a2
    80001688:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	692080e7          	jalr	1682(ra) # 80000d2e <memmove>

    len -= n;
    800016a4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016aa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9a2080e7          	jalr	-1630(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
  }
  return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret
      return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6c02                	ld	s8,0(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f4:	caa5                	beqz	a3,80001764 <copyin+0x70>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8b2a                	mv	s6,a0
    80001710:	8a2e                	mv	s4,a1
    80001712:	8c32                	mv	s8,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a01d                	j	80001740 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	018505b3          	add	a1,a0,s8
    80001720:	0004861b          	sext.w	a2,s1
    80001724:	412585b3          	sub	a1,a1,s2
    80001728:	8552                	mv	a0,s4
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	604080e7          	jalr	1540(ra) # 80000d2e <memmove>

    len -= n;
    80001732:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001736:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001738:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173c:	02098263          	beqz	s3,80001760 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001740:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001744:	85ca                	mv	a1,s2
    80001746:	855a                	mv	a0,s6
    80001748:	00000097          	auipc	ra,0x0
    8000174c:	914080e7          	jalr	-1772(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001750:	cd01                	beqz	a0,80001768 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001752:	418904b3          	sub	s1,s2,s8
    80001756:	94d6                	add	s1,s1,s5
    if(n > len)
    80001758:	fc99f2e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175c:	84ce                	mv	s1,s3
    8000175e:	bf7d                	j	8000171c <copyin+0x28>
  }
  return 0;
    80001760:	4501                	li	a0,0
    80001762:	a021                	j	8000176a <copyin+0x76>
    80001764:	4501                	li	a0,0
}
    80001766:	8082                	ret
      return -1;
    80001768:	557d                	li	a0,-1
}
    8000176a:	60a6                	ld	ra,72(sp)
    8000176c:	6406                	ld	s0,64(sp)
    8000176e:	74e2                	ld	s1,56(sp)
    80001770:	7942                	ld	s2,48(sp)
    80001772:	79a2                	ld	s3,40(sp)
    80001774:	7a02                	ld	s4,32(sp)
    80001776:	6ae2                	ld	s5,24(sp)
    80001778:	6b42                	ld	s6,16(sp)
    8000177a:	6ba2                	ld	s7,8(sp)
    8000177c:	6c02                	ld	s8,0(sp)
    8000177e:	6161                	addi	sp,sp,80
    80001780:	8082                	ret

0000000080001782 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001782:	c6c5                	beqz	a3,8000182a <copyinstr+0xa8>
{
    80001784:	715d                	addi	sp,sp,-80
    80001786:	e486                	sd	ra,72(sp)
    80001788:	e0a2                	sd	s0,64(sp)
    8000178a:	fc26                	sd	s1,56(sp)
    8000178c:	f84a                	sd	s2,48(sp)
    8000178e:	f44e                	sd	s3,40(sp)
    80001790:	f052                	sd	s4,32(sp)
    80001792:	ec56                	sd	s5,24(sp)
    80001794:	e85a                	sd	s6,16(sp)
    80001796:	e45e                	sd	s7,8(sp)
    80001798:	0880                	addi	s0,sp,80
    8000179a:	8a2a                	mv	s4,a0
    8000179c:	8b2e                	mv	s6,a1
    8000179e:	8bb2                	mv	s7,a2
    800017a0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a4:	6985                	lui	s3,0x1
    800017a6:	a035                	j	800017d2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ac:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ae:	0017b793          	seqz	a5,a5
    800017b2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6161                	addi	sp,sp,80
    800017ca:	8082                	ret
    srcva = va0 + PGSIZE;
    800017cc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d0:	c8a9                	beqz	s1,80001822 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d6:	85ca                	mv	a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	882080e7          	jalr	-1918(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e2:	c131                	beqz	a0,80001826 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e4:	41790833          	sub	a6,s2,s7
    800017e8:	984e                	add	a6,a6,s3
    if(n > max)
    800017ea:	0104f363          	bgeu	s1,a6,800017f0 <copyinstr+0x6e>
    800017ee:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f0:	955e                	add	a0,a0,s7
    800017f2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f6:	fc080be3          	beqz	a6,800017cc <copyinstr+0x4a>
    800017fa:	985a                	add	a6,a6,s6
    800017fc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fe:	41650633          	sub	a2,a0,s6
    80001802:	14fd                	addi	s1,s1,-1
    80001804:	9b26                	add	s6,s6,s1
    80001806:	00f60733          	add	a4,a2,a5
    8000180a:	00074703          	lbu	a4,0(a4)
    8000180e:	df49                	beqz	a4,800017a8 <copyinstr+0x26>
        *dst = *p;
    80001810:	00e78023          	sb	a4,0(a5)
      --max;
    80001814:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001818:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181a:	ff0796e3          	bne	a5,a6,80001806 <copyinstr+0x84>
      dst++;
    8000181e:	8b42                	mv	s6,a6
    80001820:	b775                	j	800017cc <copyinstr+0x4a>
    80001822:	4781                	li	a5,0
    80001824:	b769                	j	800017ae <copyinstr+0x2c>
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	b779                	j	800017b6 <copyinstr+0x34>
  int got_null = 0;
    8000182a:	4781                	li	a5,0
  if(got_null){
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	75448493          	addi	s1,s1,1876 # 80010fa0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1
    80001864:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001866:	00018a17          	auipc	s4,0x18
    8000186a:	f3aa0a13          	addi	s4,s4,-198 # 800197a0 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if (pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	8595                	srai	a1,a1,0x5
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800018a0:	22048493          	addi	s1,s1,544
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7a080e7          	jalr	-902(ra) # 8000053e <panic>

00000000800018cc <get_random>:
static unsigned long randstate = 31;
unsigned long get_random()
{
    800018cc:	1141                	addi	sp,sp,-16
    800018ce:	e422                	sd	s0,8(sp)
    800018d0:	0800                	addi	s0,sp,16
  for (int i = 0; i < 10; i++)
    800018d2:	00007517          	auipc	a0,0x7
    800018d6:	fa653503          	ld	a0,-90(a0) # 80008878 <randstate>
{
    800018da:	47a9                	li	a5,10
  {

    randstate = (randstate * 1664525 + 1013904223) % 4294967296; // Example LCG algorithm
    800018dc:	00196637          	lui	a2,0x196
    800018e0:	60d60613          	addi	a2,a2,1549 # 19660d <_entry-0x7fe699f3>
    800018e4:	3c6ef6b7          	lui	a3,0x3c6ef
    800018e8:	35f68693          	addi	a3,a3,863 # 3c6ef35f <_entry-0x43910ca1>
    800018ec:	577d                	li	a4,-1
    800018ee:	9301                	srli	a4,a4,0x20
    800018f0:	02c50533          	mul	a0,a0,a2
    800018f4:	9536                	add	a0,a0,a3
    800018f6:	8d79                	and	a0,a0,a4
  for (int i = 0; i < 10; i++)
    800018f8:	37fd                	addiw	a5,a5,-1
    800018fa:	fbfd                	bnez	a5,800018f0 <get_random+0x24>
    800018fc:	00007797          	auipc	a5,0x7
    80001900:	f6a7be23          	sd	a0,-132(a5) # 80008878 <randstate>
  }
  return randstate;
}
    80001904:	6422                	ld	s0,8(sp)
    80001906:	0141                	addi	sp,sp,16
    80001908:	8082                	ret

000000008000190a <procinit>:

#endif

// initialize the proc table.
void procinit(void)
{
    8000190a:	7139                	addi	sp,sp,-64
    8000190c:	fc06                	sd	ra,56(sp)
    8000190e:	f822                	sd	s0,48(sp)
    80001910:	f426                	sd	s1,40(sp)
    80001912:	f04a                	sd	s2,32(sp)
    80001914:	ec4e                	sd	s3,24(sp)
    80001916:	e852                	sd	s4,16(sp)
    80001918:	e456                	sd	s5,8(sp)
    8000191a:	e05a                	sd	s6,0(sp)
    8000191c:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    8000191e:	00007597          	auipc	a1,0x7
    80001922:	8c258593          	addi	a1,a1,-1854 # 800081e0 <digits+0x1a0>
    80001926:	0000f517          	auipc	a0,0xf
    8000192a:	24a50513          	addi	a0,a0,586 # 80010b70 <pid_lock>
    8000192e:	fffff097          	auipc	ra,0xfffff
    80001932:	218080e7          	jalr	536(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001936:	00007597          	auipc	a1,0x7
    8000193a:	8b258593          	addi	a1,a1,-1870 # 800081e8 <digits+0x1a8>
    8000193e:	0000f517          	auipc	a0,0xf
    80001942:	24a50513          	addi	a0,a0,586 # 80010b88 <wait_lock>
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	200080e7          	jalr	512(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    8000194e:	0000f497          	auipc	s1,0xf
    80001952:	65248493          	addi	s1,s1,1618 # 80010fa0 <proc>
  {
    initlock(&p->lock, "proc");
    80001956:	00007b17          	auipc	s6,0x7
    8000195a:	8a2b0b13          	addi	s6,s6,-1886 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000195e:	8aa6                	mv	s5,s1
    80001960:	00006a17          	auipc	s4,0x6
    80001964:	6a0a0a13          	addi	s4,s4,1696 # 80008000 <etext>
    80001968:	04000937          	lui	s2,0x4000
    8000196c:	197d                	addi	s2,s2,-1
    8000196e:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001970:	00018997          	auipc	s3,0x18
    80001974:	e3098993          	addi	s3,s3,-464 # 800197a0 <tickslock>
    initlock(&p->lock, "proc");
    80001978:	85da                	mv	a1,s6
    8000197a:	8526                	mv	a0,s1
    8000197c:	fffff097          	auipc	ra,0xfffff
    80001980:	1ca080e7          	jalr	458(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    80001984:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001988:	415487b3          	sub	a5,s1,s5
    8000198c:	8795                	srai	a5,a5,0x5
    8000198e:	000a3703          	ld	a4,0(s4)
    80001992:	02e787b3          	mul	a5,a5,a4
    80001996:	2785                	addiw	a5,a5,1
    80001998:	00d7979b          	slliw	a5,a5,0xd
    8000199c:	40f907b3          	sub	a5,s2,a5
    800019a0:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    800019a2:	22048493          	addi	s1,s1,544
    800019a6:	fd3499e3          	bne	s1,s3,80001978 <procinit+0x6e>
  }
}
    800019aa:	70e2                	ld	ra,56(sp)
    800019ac:	7442                	ld	s0,48(sp)
    800019ae:	74a2                	ld	s1,40(sp)
    800019b0:	7902                	ld	s2,32(sp)
    800019b2:	69e2                	ld	s3,24(sp)
    800019b4:	6a42                	ld	s4,16(sp)
    800019b6:	6aa2                	ld	s5,8(sp)
    800019b8:	6b02                	ld	s6,0(sp)
    800019ba:	6121                	addi	sp,sp,64
    800019bc:	8082                	ret

00000000800019be <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    800019be:	1141                	addi	sp,sp,-16
    800019c0:	e422                	sd	s0,8(sp)
    800019c2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019c4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019c6:	2501                	sext.w	a0,a0
    800019c8:	6422                	ld	s0,8(sp)
    800019ca:	0141                	addi	sp,sp,16
    800019cc:	8082                	ret

00000000800019ce <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800019ce:	1141                	addi	sp,sp,-16
    800019d0:	e422                	sd	s0,8(sp)
    800019d2:	0800                	addi	s0,sp,16
    800019d4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019d6:	2781                	sext.w	a5,a5
    800019d8:	079e                	slli	a5,a5,0x7
  return c;
}
    800019da:	0000f517          	auipc	a0,0xf
    800019de:	1c650513          	addi	a0,a0,454 # 80010ba0 <cpus>
    800019e2:	953e                	add	a0,a0,a5
    800019e4:	6422                	ld	s0,8(sp)
    800019e6:	0141                	addi	sp,sp,16
    800019e8:	8082                	ret

00000000800019ea <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019ea:	1101                	addi	sp,sp,-32
    800019ec:	ec06                	sd	ra,24(sp)
    800019ee:	e822                	sd	s0,16(sp)
    800019f0:	e426                	sd	s1,8(sp)
    800019f2:	1000                	addi	s0,sp,32
  push_off();
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	196080e7          	jalr	406(ra) # 80000b8a <push_off>
    800019fc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019fe:	2781                	sext.w	a5,a5
    80001a00:	079e                	slli	a5,a5,0x7
    80001a02:	0000f717          	auipc	a4,0xf
    80001a06:	16e70713          	addi	a4,a4,366 # 80010b70 <pid_lock>
    80001a0a:	97ba                	add	a5,a5,a4
    80001a0c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a0e:	fffff097          	auipc	ra,0xfffff
    80001a12:	21c080e7          	jalr	540(ra) # 80000c2a <pop_off>
  return p;
}
    80001a16:	8526                	mv	a0,s1
    80001a18:	60e2                	ld	ra,24(sp)
    80001a1a:	6442                	ld	s0,16(sp)
    80001a1c:	64a2                	ld	s1,8(sp)
    80001a1e:	6105                	addi	sp,sp,32
    80001a20:	8082                	ret

0000000080001a22 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001a22:	1141                	addi	sp,sp,-16
    80001a24:	e406                	sd	ra,8(sp)
    80001a26:	e022                	sd	s0,0(sp)
    80001a28:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a2a:	00000097          	auipc	ra,0x0
    80001a2e:	fc0080e7          	jalr	-64(ra) # 800019ea <myproc>
    80001a32:	fffff097          	auipc	ra,0xfffff
    80001a36:	258080e7          	jalr	600(ra) # 80000c8a <release>

  if (first)
    80001a3a:	00007797          	auipc	a5,0x7
    80001a3e:	e367a783          	lw	a5,-458(a5) # 80008870 <first.1>
    80001a42:	eb89                	bnez	a5,80001a54 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a44:	00001097          	auipc	ra,0x1
    80001a48:	fbe080e7          	jalr	-66(ra) # 80002a02 <usertrapret>
}
    80001a4c:	60a2                	ld	ra,8(sp)
    80001a4e:	6402                	ld	s0,0(sp)
    80001a50:	0141                	addi	sp,sp,16
    80001a52:	8082                	ret
    first = 0;
    80001a54:	00007797          	auipc	a5,0x7
    80001a58:	e007ae23          	sw	zero,-484(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001a5c:	4505                	li	a0,1
    80001a5e:	00002097          	auipc	ra,0x2
    80001a62:	f68080e7          	jalr	-152(ra) # 800039c6 <fsinit>
    80001a66:	bff9                	j	80001a44 <forkret+0x22>

0000000080001a68 <allocpid>:
{
    80001a68:	1101                	addi	sp,sp,-32
    80001a6a:	ec06                	sd	ra,24(sp)
    80001a6c:	e822                	sd	s0,16(sp)
    80001a6e:	e426                	sd	s1,8(sp)
    80001a70:	e04a                	sd	s2,0(sp)
    80001a72:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a74:	0000f917          	auipc	s2,0xf
    80001a78:	0fc90913          	addi	s2,s2,252 # 80010b70 <pid_lock>
    80001a7c:	854a                	mv	a0,s2
    80001a7e:	fffff097          	auipc	ra,0xfffff
    80001a82:	158080e7          	jalr	344(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a86:	00007797          	auipc	a5,0x7
    80001a8a:	dfa78793          	addi	a5,a5,-518 # 80008880 <nextpid>
    80001a8e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a90:	0014871b          	addiw	a4,s1,1
    80001a94:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a96:	854a                	mv	a0,s2
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	1f2080e7          	jalr	498(ra) # 80000c8a <release>
}
    80001aa0:	8526                	mv	a0,s1
    80001aa2:	60e2                	ld	ra,24(sp)
    80001aa4:	6442                	ld	s0,16(sp)
    80001aa6:	64a2                	ld	s1,8(sp)
    80001aa8:	6902                	ld	s2,0(sp)
    80001aaa:	6105                	addi	sp,sp,32
    80001aac:	8082                	ret

0000000080001aae <proc_pagetable>:
{
    80001aae:	1101                	addi	sp,sp,-32
    80001ab0:	ec06                	sd	ra,24(sp)
    80001ab2:	e822                	sd	s0,16(sp)
    80001ab4:	e426                	sd	s1,8(sp)
    80001ab6:	e04a                	sd	s2,0(sp)
    80001ab8:	1000                	addi	s0,sp,32
    80001aba:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001abc:	00000097          	auipc	ra,0x0
    80001ac0:	86c080e7          	jalr	-1940(ra) # 80001328 <uvmcreate>
    80001ac4:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001ac6:	c121                	beqz	a0,80001b06 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ac8:	4729                	li	a4,10
    80001aca:	00005697          	auipc	a3,0x5
    80001ace:	53668693          	addi	a3,a3,1334 # 80007000 <_trampoline>
    80001ad2:	6605                	lui	a2,0x1
    80001ad4:	040005b7          	lui	a1,0x4000
    80001ad8:	15fd                	addi	a1,a1,-1
    80001ada:	05b2                	slli	a1,a1,0xc
    80001adc:	fffff097          	auipc	ra,0xfffff
    80001ae0:	5c2080e7          	jalr	1474(ra) # 8000109e <mappages>
    80001ae4:	02054863          	bltz	a0,80001b14 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ae8:	4719                	li	a4,6
    80001aea:	05893683          	ld	a3,88(s2)
    80001aee:	6605                	lui	a2,0x1
    80001af0:	020005b7          	lui	a1,0x2000
    80001af4:	15fd                	addi	a1,a1,-1
    80001af6:	05b6                	slli	a1,a1,0xd
    80001af8:	8526                	mv	a0,s1
    80001afa:	fffff097          	auipc	ra,0xfffff
    80001afe:	5a4080e7          	jalr	1444(ra) # 8000109e <mappages>
    80001b02:	02054163          	bltz	a0,80001b24 <proc_pagetable+0x76>
}
    80001b06:	8526                	mv	a0,s1
    80001b08:	60e2                	ld	ra,24(sp)
    80001b0a:	6442                	ld	s0,16(sp)
    80001b0c:	64a2                	ld	s1,8(sp)
    80001b0e:	6902                	ld	s2,0(sp)
    80001b10:	6105                	addi	sp,sp,32
    80001b12:	8082                	ret
    uvmfree(pagetable, 0);
    80001b14:	4581                	li	a1,0
    80001b16:	8526                	mv	a0,s1
    80001b18:	00000097          	auipc	ra,0x0
    80001b1c:	a14080e7          	jalr	-1516(ra) # 8000152c <uvmfree>
    return 0;
    80001b20:	4481                	li	s1,0
    80001b22:	b7d5                	j	80001b06 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b24:	4681                	li	a3,0
    80001b26:	4605                	li	a2,1
    80001b28:	040005b7          	lui	a1,0x4000
    80001b2c:	15fd                	addi	a1,a1,-1
    80001b2e:	05b2                	slli	a1,a1,0xc
    80001b30:	8526                	mv	a0,s1
    80001b32:	fffff097          	auipc	ra,0xfffff
    80001b36:	732080e7          	jalr	1842(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b3a:	4581                	li	a1,0
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	00000097          	auipc	ra,0x0
    80001b42:	9ee080e7          	jalr	-1554(ra) # 8000152c <uvmfree>
    return 0;
    80001b46:	4481                	li	s1,0
    80001b48:	bf7d                	j	80001b06 <proc_pagetable+0x58>

0000000080001b4a <proc_freepagetable>:
{
    80001b4a:	1101                	addi	sp,sp,-32
    80001b4c:	ec06                	sd	ra,24(sp)
    80001b4e:	e822                	sd	s0,16(sp)
    80001b50:	e426                	sd	s1,8(sp)
    80001b52:	e04a                	sd	s2,0(sp)
    80001b54:	1000                	addi	s0,sp,32
    80001b56:	84aa                	mv	s1,a0
    80001b58:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b5a:	4681                	li	a3,0
    80001b5c:	4605                	li	a2,1
    80001b5e:	040005b7          	lui	a1,0x4000
    80001b62:	15fd                	addi	a1,a1,-1
    80001b64:	05b2                	slli	a1,a1,0xc
    80001b66:	fffff097          	auipc	ra,0xfffff
    80001b6a:	6fe080e7          	jalr	1790(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b6e:	4681                	li	a3,0
    80001b70:	4605                	li	a2,1
    80001b72:	020005b7          	lui	a1,0x2000
    80001b76:	15fd                	addi	a1,a1,-1
    80001b78:	05b6                	slli	a1,a1,0xd
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	fffff097          	auipc	ra,0xfffff
    80001b80:	6e8080e7          	jalr	1768(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b84:	85ca                	mv	a1,s2
    80001b86:	8526                	mv	a0,s1
    80001b88:	00000097          	auipc	ra,0x0
    80001b8c:	9a4080e7          	jalr	-1628(ra) # 8000152c <uvmfree>
}
    80001b90:	60e2                	ld	ra,24(sp)
    80001b92:	6442                	ld	s0,16(sp)
    80001b94:	64a2                	ld	s1,8(sp)
    80001b96:	6902                	ld	s2,0(sp)
    80001b98:	6105                	addi	sp,sp,32
    80001b9a:	8082                	ret

0000000080001b9c <freeproc>:
{
    80001b9c:	1101                	addi	sp,sp,-32
    80001b9e:	ec06                	sd	ra,24(sp)
    80001ba0:	e822                	sd	s0,16(sp)
    80001ba2:	e426                	sd	s1,8(sp)
    80001ba4:	1000                	addi	s0,sp,32
    80001ba6:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001ba8:	6d28                	ld	a0,88(a0)
    80001baa:	c509                	beqz	a0,80001bb4 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001bac:	fffff097          	auipc	ra,0xfffff
    80001bb0:	e3e080e7          	jalr	-450(ra) # 800009ea <kfree>
  if (p->backup)
    80001bb4:	1f84b503          	ld	a0,504(s1)
    80001bb8:	c509                	beqz	a0,80001bc2 <freeproc+0x26>
    kfree((void *)p->backup);
    80001bba:	fffff097          	auipc	ra,0xfffff
    80001bbe:	e30080e7          	jalr	-464(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001bc2:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001bc6:	68a8                	ld	a0,80(s1)
    80001bc8:	c511                	beqz	a0,80001bd4 <freeproc+0x38>
    proc_freepagetable(p->pagetable, p->sz);
    80001bca:	64ac                	ld	a1,72(s1)
    80001bcc:	00000097          	auipc	ra,0x0
    80001bd0:	f7e080e7          	jalr	-130(ra) # 80001b4a <proc_freepagetable>
  p->pagetable = 0;
    80001bd4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bd8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bdc:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001be0:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001be4:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001be8:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bec:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bf0:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bf4:	0004ac23          	sw	zero,24(s1)
}
    80001bf8:	60e2                	ld	ra,24(sp)
    80001bfa:	6442                	ld	s0,16(sp)
    80001bfc:	64a2                	ld	s1,8(sp)
    80001bfe:	6105                	addi	sp,sp,32
    80001c00:	8082                	ret

0000000080001c02 <allocproc>:
{
    80001c02:	7179                	addi	sp,sp,-48
    80001c04:	f406                	sd	ra,40(sp)
    80001c06:	f022                	sd	s0,32(sp)
    80001c08:	ec26                	sd	s1,24(sp)
    80001c0a:	e84a                	sd	s2,16(sp)
    80001c0c:	e44e                	sd	s3,8(sp)
    80001c0e:	1800                	addi	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++)
    80001c10:	0000f497          	auipc	s1,0xf
    80001c14:	39048493          	addi	s1,s1,912 # 80010fa0 <proc>
    80001c18:	00018997          	auipc	s3,0x18
    80001c1c:	b8898993          	addi	s3,s3,-1144 # 800197a0 <tickslock>
    acquire(&p->lock);
    80001c20:	8526                	mv	a0,s1
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	fb4080e7          	jalr	-76(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001c2a:	4c9c                	lw	a5,24(s1)
    80001c2c:	cf81                	beqz	a5,80001c44 <allocproc+0x42>
      release(&p->lock);
    80001c2e:	8526                	mv	a0,s1
    80001c30:	fffff097          	auipc	ra,0xfffff
    80001c34:	05a080e7          	jalr	90(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c38:	22048493          	addi	s1,s1,544
    80001c3c:	ff3492e3          	bne	s1,s3,80001c20 <allocproc+0x1e>
  return 0;
    80001c40:	4481                	li	s1,0
    80001c42:	a84d                	j	80001cf4 <allocproc+0xf2>
  p->pid = allocpid();
    80001c44:	00000097          	auipc	ra,0x0
    80001c48:	e24080e7          	jalr	-476(ra) # 80001a68 <allocpid>
    80001c4c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c4e:	4785                	li	a5,1
    80001c50:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	e94080e7          	jalr	-364(ra) # 80000ae6 <kalloc>
    80001c5a:	89aa                	mv	s3,a0
    80001c5c:	eca8                	sd	a0,88(s1)
    80001c5e:	c15d                	beqz	a0,80001d04 <allocproc+0x102>
  if ((p->backup = (struct trapframe *)kalloc()) == 0)
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	e86080e7          	jalr	-378(ra) # 80000ae6 <kalloc>
    80001c68:	89aa                	mv	s3,a0
    80001c6a:	1ea4bc23          	sd	a0,504(s1)
    80001c6e:	c55d                	beqz	a0,80001d1c <allocproc+0x11a>
  p->pagetable = proc_pagetable(p);
    80001c70:	8526                	mv	a0,s1
    80001c72:	00000097          	auipc	ra,0x0
    80001c76:	e3c080e7          	jalr	-452(ra) # 80001aae <proc_pagetable>
    80001c7a:	89aa                	mv	s3,a0
    80001c7c:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c7e:	c95d                	beqz	a0,80001d34 <allocproc+0x132>
  memset(&p->context, 0, sizeof(p->context));
    80001c80:	07000613          	li	a2,112
    80001c84:	4581                	li	a1,0
    80001c86:	06048513          	addi	a0,s1,96
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	048080e7          	jalr	72(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c92:	00000797          	auipc	a5,0x0
    80001c96:	d9078793          	addi	a5,a5,-624 # 80001a22 <forkret>
    80001c9a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c9c:	60bc                	ld	a5,64(s1)
    80001c9e:	6705                	lui	a4,0x1
    80001ca0:	97ba                	add	a5,a5,a4
    80001ca2:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001ca4:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001ca8:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001cac:	00007797          	auipc	a5,0x7
    80001cb0:	c5c7a783          	lw	a5,-932(a5) # 80008908 <ticks>
    80001cb4:	16f4a623          	sw	a5,364(s1)
  for (int i = 0; i < 32; i++)
    80001cb8:	17448793          	addi	a5,s1,372
    80001cbc:	1f448713          	addi	a4,s1,500
    p->syscall_cnt[i] = 0;
    80001cc0:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < 32; i++)
    80001cc4:	0791                	addi	a5,a5,4
    80001cc6:	fee79de3          	bne	a5,a4,80001cc0 <allocproc+0xbe>
  p->ticks = 0;
    80001cca:	2004a023          	sw	zero,512(s1)
  p->total_ticks = 0;
    80001cce:	2004a223          	sw	zero,516(s1)
  p->handler = 0;
    80001cd2:	2004b423          	sd	zero,520(s1)
  p->arrival_time = sys_time++;
    80001cd6:	00007717          	auipc	a4,0x7
    80001cda:	c2270713          	addi	a4,a4,-990 # 800088f8 <sys_time>
    80001cde:	631c                	ld	a5,0(a4)
    80001ce0:	00178693          	addi	a3,a5,1
    80001ce4:	e314                	sd	a3,0(a4)
    80001ce6:	20f4ac23          	sw	a5,536(s1)
  p->tickets = 1;
    80001cea:	4785                	li	a5,1
    80001cec:	20f4aa23          	sw	a5,532(s1)
  p->alarm_state = 0;
    80001cf0:	2004a823          	sw	zero,528(s1)
}
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	70a2                	ld	ra,40(sp)
    80001cf8:	7402                	ld	s0,32(sp)
    80001cfa:	64e2                	ld	s1,24(sp)
    80001cfc:	6942                	ld	s2,16(sp)
    80001cfe:	69a2                	ld	s3,8(sp)
    80001d00:	6145                	addi	sp,sp,48
    80001d02:	8082                	ret
    freeproc(p);
    80001d04:	8526                	mv	a0,s1
    80001d06:	00000097          	auipc	ra,0x0
    80001d0a:	e96080e7          	jalr	-362(ra) # 80001b9c <freeproc>
    release(&p->lock);
    80001d0e:	8526                	mv	a0,s1
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	f7a080e7          	jalr	-134(ra) # 80000c8a <release>
    return 0;
    80001d18:	84ce                	mv	s1,s3
    80001d1a:	bfe9                	j	80001cf4 <allocproc+0xf2>
    freeproc(p);
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	00000097          	auipc	ra,0x0
    80001d22:	e7e080e7          	jalr	-386(ra) # 80001b9c <freeproc>
    release(&p->lock);
    80001d26:	8526                	mv	a0,s1
    80001d28:	fffff097          	auipc	ra,0xfffff
    80001d2c:	f62080e7          	jalr	-158(ra) # 80000c8a <release>
    return 0;
    80001d30:	84ce                	mv	s1,s3
    80001d32:	b7c9                	j	80001cf4 <allocproc+0xf2>
    freeproc(p);
    80001d34:	8526                	mv	a0,s1
    80001d36:	00000097          	auipc	ra,0x0
    80001d3a:	e66080e7          	jalr	-410(ra) # 80001b9c <freeproc>
    release(&p->lock);
    80001d3e:	8526                	mv	a0,s1
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	f4a080e7          	jalr	-182(ra) # 80000c8a <release>
    return 0;
    80001d48:	84ce                	mv	s1,s3
    80001d4a:	b76d                	j	80001cf4 <allocproc+0xf2>

0000000080001d4c <userinit>:
{
    80001d4c:	1101                	addi	sp,sp,-32
    80001d4e:	ec06                	sd	ra,24(sp)
    80001d50:	e822                	sd	s0,16(sp)
    80001d52:	e426                	sd	s1,8(sp)
    80001d54:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d56:	00000097          	auipc	ra,0x0
    80001d5a:	eac080e7          	jalr	-340(ra) # 80001c02 <allocproc>
    80001d5e:	84aa                	mv	s1,a0
  initproc = p;
    80001d60:	00007797          	auipc	a5,0x7
    80001d64:	baa7b023          	sd	a0,-1120(a5) # 80008900 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d68:	03400613          	li	a2,52
    80001d6c:	00007597          	auipc	a1,0x7
    80001d70:	b2458593          	addi	a1,a1,-1244 # 80008890 <initcode>
    80001d74:	6928                	ld	a0,80(a0)
    80001d76:	fffff097          	auipc	ra,0xfffff
    80001d7a:	5e0080e7          	jalr	1504(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001d7e:	6785                	lui	a5,0x1
    80001d80:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001d82:	6cb8                	ld	a4,88(s1)
    80001d84:	00073c23          	sd	zero,24(a4)
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d88:	6cb8                	ld	a4,88(s1)
    80001d8a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d8c:	4641                	li	a2,16
    80001d8e:	00006597          	auipc	a1,0x6
    80001d92:	47258593          	addi	a1,a1,1138 # 80008200 <digits+0x1c0>
    80001d96:	15848513          	addi	a0,s1,344
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	082080e7          	jalr	130(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001da2:	00006517          	auipc	a0,0x6
    80001da6:	46e50513          	addi	a0,a0,1134 # 80008210 <digits+0x1d0>
    80001daa:	00002097          	auipc	ra,0x2
    80001dae:	63e080e7          	jalr	1598(ra) # 800043e8 <namei>
    80001db2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001db6:	478d                	li	a5,3
    80001db8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dba:	8526                	mv	a0,s1
    80001dbc:	fffff097          	auipc	ra,0xfffff
    80001dc0:	ece080e7          	jalr	-306(ra) # 80000c8a <release>
}
    80001dc4:	60e2                	ld	ra,24(sp)
    80001dc6:	6442                	ld	s0,16(sp)
    80001dc8:	64a2                	ld	s1,8(sp)
    80001dca:	6105                	addi	sp,sp,32
    80001dcc:	8082                	ret

0000000080001dce <growproc>:
{
    80001dce:	1101                	addi	sp,sp,-32
    80001dd0:	ec06                	sd	ra,24(sp)
    80001dd2:	e822                	sd	s0,16(sp)
    80001dd4:	e426                	sd	s1,8(sp)
    80001dd6:	e04a                	sd	s2,0(sp)
    80001dd8:	1000                	addi	s0,sp,32
    80001dda:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001ddc:	00000097          	auipc	ra,0x0
    80001de0:	c0e080e7          	jalr	-1010(ra) # 800019ea <myproc>
    80001de4:	84aa                	mv	s1,a0
  sz = p->sz;
    80001de6:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001de8:	01204c63          	bgtz	s2,80001e00 <growproc+0x32>
  else if (n < 0)
    80001dec:	02094663          	bltz	s2,80001e18 <growproc+0x4a>
  p->sz = sz;
    80001df0:	e4ac                	sd	a1,72(s1)
  return 0;
    80001df2:	4501                	li	a0,0
}
    80001df4:	60e2                	ld	ra,24(sp)
    80001df6:	6442                	ld	s0,16(sp)
    80001df8:	64a2                	ld	s1,8(sp)
    80001dfa:	6902                	ld	s2,0(sp)
    80001dfc:	6105                	addi	sp,sp,32
    80001dfe:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001e00:	4691                	li	a3,4
    80001e02:	00b90633          	add	a2,s2,a1
    80001e06:	6928                	ld	a0,80(a0)
    80001e08:	fffff097          	auipc	ra,0xfffff
    80001e0c:	608080e7          	jalr	1544(ra) # 80001410 <uvmalloc>
    80001e10:	85aa                	mv	a1,a0
    80001e12:	fd79                	bnez	a0,80001df0 <growproc+0x22>
      return -1;
    80001e14:	557d                	li	a0,-1
    80001e16:	bff9                	j	80001df4 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e18:	00b90633          	add	a2,s2,a1
    80001e1c:	6928                	ld	a0,80(a0)
    80001e1e:	fffff097          	auipc	ra,0xfffff
    80001e22:	5aa080e7          	jalr	1450(ra) # 800013c8 <uvmdealloc>
    80001e26:	85aa                	mv	a1,a0
    80001e28:	b7e1                	j	80001df0 <growproc+0x22>

0000000080001e2a <fork>:
{
    80001e2a:	7139                	addi	sp,sp,-64
    80001e2c:	fc06                	sd	ra,56(sp)
    80001e2e:	f822                	sd	s0,48(sp)
    80001e30:	f426                	sd	s1,40(sp)
    80001e32:	f04a                	sd	s2,32(sp)
    80001e34:	ec4e                	sd	s3,24(sp)
    80001e36:	e852                	sd	s4,16(sp)
    80001e38:	e456                	sd	s5,8(sp)
    80001e3a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e3c:	00000097          	auipc	ra,0x0
    80001e40:	bae080e7          	jalr	-1106(ra) # 800019ea <myproc>
    80001e44:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001e46:	00000097          	auipc	ra,0x0
    80001e4a:	dbc080e7          	jalr	-580(ra) # 80001c02 <allocproc>
    80001e4e:	14050463          	beqz	a0,80001f96 <fork+0x16c>
    80001e52:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001e54:	048ab603          	ld	a2,72(s5)
    80001e58:	692c                	ld	a1,80(a0)
    80001e5a:	050ab503          	ld	a0,80(s5)
    80001e5e:	fffff097          	auipc	ra,0xfffff
    80001e62:	706080e7          	jalr	1798(ra) # 80001564 <uvmcopy>
    80001e66:	04054863          	bltz	a0,80001eb6 <fork+0x8c>
  np->sz = p->sz;
    80001e6a:	048ab783          	ld	a5,72(s5)
    80001e6e:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e72:	058ab683          	ld	a3,88(s5)
    80001e76:	87b6                	mv	a5,a3
    80001e78:	0589b703          	ld	a4,88(s3)
    80001e7c:	12068693          	addi	a3,a3,288
    80001e80:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e84:	6788                	ld	a0,8(a5)
    80001e86:	6b8c                	ld	a1,16(a5)
    80001e88:	6f90                	ld	a2,24(a5)
    80001e8a:	01073023          	sd	a6,0(a4)
    80001e8e:	e708                	sd	a0,8(a4)
    80001e90:	eb0c                	sd	a1,16(a4)
    80001e92:	ef10                	sd	a2,24(a4)
    80001e94:	02078793          	addi	a5,a5,32
    80001e98:	02070713          	addi	a4,a4,32
    80001e9c:	fed792e3          	bne	a5,a3,80001e80 <fork+0x56>
  np->trapframe->a0 = 0;
    80001ea0:	0589b783          	ld	a5,88(s3)
    80001ea4:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001ea8:	0d0a8493          	addi	s1,s5,208
    80001eac:	0d098913          	addi	s2,s3,208
    80001eb0:	150a8a13          	addi	s4,s5,336
    80001eb4:	a00d                	j	80001ed6 <fork+0xac>
    freeproc(np);
    80001eb6:	854e                	mv	a0,s3
    80001eb8:	00000097          	auipc	ra,0x0
    80001ebc:	ce4080e7          	jalr	-796(ra) # 80001b9c <freeproc>
    release(&np->lock);
    80001ec0:	854e                	mv	a0,s3
    80001ec2:	fffff097          	auipc	ra,0xfffff
    80001ec6:	dc8080e7          	jalr	-568(ra) # 80000c8a <release>
    return -1;
    80001eca:	597d                	li	s2,-1
    80001ecc:	a85d                	j	80001f82 <fork+0x158>
  for (i = 0; i < NOFILE; i++)
    80001ece:	04a1                	addi	s1,s1,8
    80001ed0:	0921                	addi	s2,s2,8
    80001ed2:	01448b63          	beq	s1,s4,80001ee8 <fork+0xbe>
    if (p->ofile[i])
    80001ed6:	6088                	ld	a0,0(s1)
    80001ed8:	d97d                	beqz	a0,80001ece <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eda:	00003097          	auipc	ra,0x3
    80001ede:	ba4080e7          	jalr	-1116(ra) # 80004a7e <filedup>
    80001ee2:	00a93023          	sd	a0,0(s2)
    80001ee6:	b7e5                	j	80001ece <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ee8:	150ab503          	ld	a0,336(s5)
    80001eec:	00002097          	auipc	ra,0x2
    80001ef0:	d18080e7          	jalr	-744(ra) # 80003c04 <idup>
    80001ef4:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ef8:	4641                	li	a2,16
    80001efa:	158a8593          	addi	a1,s5,344
    80001efe:	15898513          	addi	a0,s3,344
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	f1a080e7          	jalr	-230(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001f0a:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001f0e:	854e                	mv	a0,s3
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	d7a080e7          	jalr	-646(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001f18:	0000f497          	auipc	s1,0xf
    80001f1c:	c7048493          	addi	s1,s1,-912 # 80010b88 <wait_lock>
    80001f20:	8526                	mv	a0,s1
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	cb4080e7          	jalr	-844(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001f2a:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001f2e:	8526                	mv	a0,s1
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	d5a080e7          	jalr	-678(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001f38:	854e                	mv	a0,s3
    80001f3a:	fffff097          	auipc	ra,0xfffff
    80001f3e:	c9c080e7          	jalr	-868(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001f42:	478d                	li	a5,3
    80001f44:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f48:	854e                	mv	a0,s3
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	d40080e7          	jalr	-704(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001f52:	854e                	mv	a0,s3
    80001f54:	fffff097          	auipc	ra,0xfffff
    80001f58:	c82080e7          	jalr	-894(ra) # 80000bd6 <acquire>
  np->tickets = p->tickets;
    80001f5c:	214aa783          	lw	a5,532(s5)
    80001f60:	20f9aa23          	sw	a5,532(s3)
  release(&np->lock);
    80001f64:	854e                	mv	a0,s3
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	d24080e7          	jalr	-732(ra) # 80000c8a <release>
  p->arrival_time = sys_time++; 
    80001f6e:	00007717          	auipc	a4,0x7
    80001f72:	98a70713          	addi	a4,a4,-1654 # 800088f8 <sys_time>
    80001f76:	631c                	ld	a5,0(a4)
    80001f78:	00178693          	addi	a3,a5,1
    80001f7c:	e314                	sd	a3,0(a4)
    80001f7e:	20faac23          	sw	a5,536(s5)
}
    80001f82:	854a                	mv	a0,s2
    80001f84:	70e2                	ld	ra,56(sp)
    80001f86:	7442                	ld	s0,48(sp)
    80001f88:	74a2                	ld	s1,40(sp)
    80001f8a:	7902                	ld	s2,32(sp)
    80001f8c:	69e2                	ld	s3,24(sp)
    80001f8e:	6a42                	ld	s4,16(sp)
    80001f90:	6aa2                	ld	s5,8(sp)
    80001f92:	6121                	addi	sp,sp,64
    80001f94:	8082                	ret
    return -1;
    80001f96:	597d                	li	s2,-1
    80001f98:	b7ed                	j	80001f82 <fork+0x158>

0000000080001f9a <scheduler>:
{
    80001f9a:	7119                	addi	sp,sp,-128
    80001f9c:	fc86                	sd	ra,120(sp)
    80001f9e:	f8a2                	sd	s0,112(sp)
    80001fa0:	f4a6                	sd	s1,104(sp)
    80001fa2:	f0ca                	sd	s2,96(sp)
    80001fa4:	ecce                	sd	s3,88(sp)
    80001fa6:	e8d2                	sd	s4,80(sp)
    80001fa8:	e4d6                	sd	s5,72(sp)
    80001faa:	e0da                	sd	s6,64(sp)
    80001fac:	fc5e                	sd	s7,56(sp)
    80001fae:	f862                	sd	s8,48(sp)
    80001fb0:	f466                	sd	s9,40(sp)
    80001fb2:	f06a                	sd	s10,32(sp)
    80001fb4:	ec6e                	sd	s11,24(sp)
    80001fb6:	0100                	addi	s0,sp,128
    80001fb8:	8792                	mv	a5,tp
  int id = r_tp();
    80001fba:	2781                	sext.w	a5,a5
      swtch(&c->context, &winner->context);
    80001fbc:	00779693          	slli	a3,a5,0x7
    80001fc0:	0000f717          	auipc	a4,0xf
    80001fc4:	be870713          	addi	a4,a4,-1048 # 80010ba8 <cpus+0x8>
    80001fc8:	9736                	add	a4,a4,a3
    80001fca:	f8e43423          	sd	a4,-120(s0)
    int total_tickets = 0;
    80001fce:	4d01                	li	s10,0
    for (p = proc; p < &proc[NPROC]; p++)
    80001fd0:	00017917          	auipc	s2,0x17
    80001fd4:	7d090913          	addi	s2,s2,2000 # 800197a0 <tickslock>
      c->proc = winner;
    80001fd8:	0000fd97          	auipc	s11,0xf
    80001fdc:	b98d8d93          	addi	s11,s11,-1128 # 80010b70 <pid_lock>
    80001fe0:	9db6                	add	s11,s11,a3
    80001fe2:	aa21                	j	800020fa <scheduler+0x160>
      release(&p->lock);
    80001fe4:	854e                	mv	a0,s3
    80001fe6:	fffff097          	auipc	ra,0xfffff
    80001fea:	ca4080e7          	jalr	-860(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001fee:	22098993          	addi	s3,s3,544
    80001ff2:	03298063          	beq	s3,s2,80002012 <scheduler+0x78>
      acquire(&p->lock);
    80001ff6:	854e                	mv	a0,s3
    80001ff8:	fffff097          	auipc	ra,0xfffff
    80001ffc:	bde080e7          	jalr	-1058(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE)
    80002000:	0189a783          	lw	a5,24(s3)
    80002004:	fe9790e3          	bne	a5,s1,80001fe4 <scheduler+0x4a>
        total_tickets += p->tickets;
    80002008:	2149a783          	lw	a5,532(s3)
    8000200c:	01478a3b          	addw	s4,a5,s4
    80002010:	bfd1                	j	80001fe4 <scheduler+0x4a>
    if (total_tickets == 0)
    80002012:	000a1e63          	bnez	s4,8000202e <scheduler+0x94>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002016:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000201a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000201e:	10079073          	csrw	sstatus,a5
    int total_tickets = 0;
    80002022:	8a6a                	mv	s4,s10
    for (p = proc; p < &proc[NPROC]; p++)
    80002024:	0000f997          	auipc	s3,0xf
    80002028:	f7c98993          	addi	s3,s3,-132 # 80010fa0 <proc>
    8000202c:	b7e9                	j	80001ff6 <scheduler+0x5c>
    winning_ticket = get_random() % (total_tickets + 1);
    8000202e:	00000097          	auipc	ra,0x0
    80002032:	89e080e7          	jalr	-1890(ra) # 800018cc <get_random>
    80002036:	2a05                	addiw	s4,s4,1
    80002038:	03457a33          	remu	s4,a0,s4
    8000203c:	000a0c9b          	sext.w	s9,s4
    for (p = proc; p < &proc[NPROC]; p++)
    80002040:	0000fa17          	auipc	s4,0xf
    80002044:	f60a0a13          	addi	s4,s4,-160 # 80010fa0 <proc>
    80002048:	0000f997          	auipc	s3,0xf
    8000204c:	17898993          	addi	s3,s3,376 # 800111c0 <proc+0x220>
    int winning_ticket, current_tickets = 0;
    80002050:	8bea                	mv	s7,s10
    struct proc *winner = 0;
    80002052:	8c6a                	mv	s8,s10
    80002054:	a025                	j	8000207c <scheduler+0xe2>
          if (winner == 0 || (p->tickets == winner->tickets && p->arrival_time < winner->arrival_time))
    80002056:	ff89a703          	lw	a4,-8(s3)
    8000205a:	218c2783          	lw	a5,536(s8)
    8000205e:	04f75663          	bge	a4,a5,800020aa <scheduler+0x110>
    80002062:	8c52                	mv	s8,s4
    80002064:	a099                	j	800020aa <scheduler+0x110>
      release(&p->lock);
    80002066:	8556                	mv	a0,s5
    80002068:	fffff097          	auipc	ra,0xfffff
    8000206c:	c22080e7          	jalr	-990(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002070:	052b7563          	bgeu	s6,s2,800020ba <scheduler+0x120>
    80002074:	220a0a13          	addi	s4,s4,544
    80002078:	22098993          	addi	s3,s3,544
    8000207c:	8ad2                	mv	s5,s4
      acquire(&p->lock);
    8000207e:	8552                	mv	a0,s4
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	b56080e7          	jalr	-1194(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE)
    80002088:	8b4e                	mv	s6,s3
    8000208a:	df89a783          	lw	a5,-520(s3)
    8000208e:	fc979ce3          	bne	a5,s1,80002066 <scheduler+0xcc>
        current_tickets += p->tickets;
    80002092:	ff49a783          	lw	a5,-12(s3)
    80002096:	01778bbb          	addw	s7,a5,s7
        if (current_tickets >= winning_ticket)
    8000209a:	fd9bc6e3          	blt	s7,s9,80002066 <scheduler+0xcc>
          if (winner == 0 || (p->tickets == winner->tickets && p->arrival_time < winner->arrival_time))
    8000209e:	060c0663          	beqz	s8,8000210a <scheduler+0x170>
    800020a2:	214c2703          	lw	a4,532(s8)
    800020a6:	faf708e3          	beq	a4,a5,80002056 <scheduler+0xbc>
      release(&p->lock);
    800020aa:	8556                	mv	a0,s5
    800020ac:	fffff097          	auipc	ra,0xfffff
    800020b0:	bde080e7          	jalr	-1058(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800020b4:	fd2b60e3          	bltu	s6,s2,80002074 <scheduler+0xda>
    800020b8:	a019                	j	800020be <scheduler+0x124>
    if (winner != 0)
    800020ba:	f40c0ee3          	beqz	s8,80002016 <scheduler+0x7c>
      acquire(&winner->lock);
    800020be:	8562                	mv	a0,s8
    800020c0:	fffff097          	auipc	ra,0xfffff
    800020c4:	b16080e7          	jalr	-1258(ra) # 80000bd6 <acquire>
      if (winner->state != RUNNABLE)
    800020c8:	018c2703          	lw	a4,24(s8)
    800020cc:	478d                	li	a5,3
    800020ce:	02f71863          	bne	a4,a5,800020fe <scheduler+0x164>
      winner->state = RUNNING;
    800020d2:	4791                	li	a5,4
    800020d4:	00fc2c23          	sw	a5,24(s8)
      c->proc = winner;
    800020d8:	038db823          	sd	s8,48(s11)
      swtch(&c->context, &winner->context);
    800020dc:	060c0593          	addi	a1,s8,96
    800020e0:	f8843503          	ld	a0,-120(s0)
    800020e4:	00001097          	auipc	ra,0x1
    800020e8:	874080e7          	jalr	-1932(ra) # 80002958 <swtch>
      c->proc = 0;
    800020ec:	020db823          	sd	zero,48(s11)
      release(&winner->lock);
    800020f0:	8562                	mv	a0,s8
    800020f2:	fffff097          	auipc	ra,0xfffff
    800020f6:	b98080e7          	jalr	-1128(ra) # 80000c8a <release>
      if (p->state == RUNNABLE)
    800020fa:	448d                	li	s1,3
    800020fc:	bf29                	j	80002016 <scheduler+0x7c>
        release(&winner->lock);
    800020fe:	8562                	mv	a0,s8
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	b8a080e7          	jalr	-1142(ra) # 80000c8a <release>
        continue;
    80002108:	bfcd                	j	800020fa <scheduler+0x160>
    8000210a:	8c52                	mv	s8,s4
    8000210c:	bf79                	j	800020aa <scheduler+0x110>

000000008000210e <sched>:
{
    8000210e:	7179                	addi	sp,sp,-48
    80002110:	f406                	sd	ra,40(sp)
    80002112:	f022                	sd	s0,32(sp)
    80002114:	ec26                	sd	s1,24(sp)
    80002116:	e84a                	sd	s2,16(sp)
    80002118:	e44e                	sd	s3,8(sp)
    8000211a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000211c:	00000097          	auipc	ra,0x0
    80002120:	8ce080e7          	jalr	-1842(ra) # 800019ea <myproc>
    80002124:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002126:	fffff097          	auipc	ra,0xfffff
    8000212a:	a36080e7          	jalr	-1482(ra) # 80000b5c <holding>
    8000212e:	c93d                	beqz	a0,800021a4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002130:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002132:	2781                	sext.w	a5,a5
    80002134:	079e                	slli	a5,a5,0x7
    80002136:	0000f717          	auipc	a4,0xf
    8000213a:	a3a70713          	addi	a4,a4,-1478 # 80010b70 <pid_lock>
    8000213e:	97ba                	add	a5,a5,a4
    80002140:	0a87a703          	lw	a4,168(a5)
    80002144:	4785                	li	a5,1
    80002146:	06f71763          	bne	a4,a5,800021b4 <sched+0xa6>
  if (p->state == RUNNING)
    8000214a:	4c98                	lw	a4,24(s1)
    8000214c:	4791                	li	a5,4
    8000214e:	06f70b63          	beq	a4,a5,800021c4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002152:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002156:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002158:	efb5                	bnez	a5,800021d4 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000215a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000215c:	0000f917          	auipc	s2,0xf
    80002160:	a1490913          	addi	s2,s2,-1516 # 80010b70 <pid_lock>
    80002164:	2781                	sext.w	a5,a5
    80002166:	079e                	slli	a5,a5,0x7
    80002168:	97ca                	add	a5,a5,s2
    8000216a:	0ac7a983          	lw	s3,172(a5)
    8000216e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002170:	2781                	sext.w	a5,a5
    80002172:	079e                	slli	a5,a5,0x7
    80002174:	0000f597          	auipc	a1,0xf
    80002178:	a3458593          	addi	a1,a1,-1484 # 80010ba8 <cpus+0x8>
    8000217c:	95be                	add	a1,a1,a5
    8000217e:	06048513          	addi	a0,s1,96
    80002182:	00000097          	auipc	ra,0x0
    80002186:	7d6080e7          	jalr	2006(ra) # 80002958 <swtch>
    8000218a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000218c:	2781                	sext.w	a5,a5
    8000218e:	079e                	slli	a5,a5,0x7
    80002190:	97ca                	add	a5,a5,s2
    80002192:	0b37a623          	sw	s3,172(a5)
}
    80002196:	70a2                	ld	ra,40(sp)
    80002198:	7402                	ld	s0,32(sp)
    8000219a:	64e2                	ld	s1,24(sp)
    8000219c:	6942                	ld	s2,16(sp)
    8000219e:	69a2                	ld	s3,8(sp)
    800021a0:	6145                	addi	sp,sp,48
    800021a2:	8082                	ret
    panic("sched p->lock");
    800021a4:	00006517          	auipc	a0,0x6
    800021a8:	07450513          	addi	a0,a0,116 # 80008218 <digits+0x1d8>
    800021ac:	ffffe097          	auipc	ra,0xffffe
    800021b0:	392080e7          	jalr	914(ra) # 8000053e <panic>
    panic("sched locks");
    800021b4:	00006517          	auipc	a0,0x6
    800021b8:	07450513          	addi	a0,a0,116 # 80008228 <digits+0x1e8>
    800021bc:	ffffe097          	auipc	ra,0xffffe
    800021c0:	382080e7          	jalr	898(ra) # 8000053e <panic>
    panic("sched running");
    800021c4:	00006517          	auipc	a0,0x6
    800021c8:	07450513          	addi	a0,a0,116 # 80008238 <digits+0x1f8>
    800021cc:	ffffe097          	auipc	ra,0xffffe
    800021d0:	372080e7          	jalr	882(ra) # 8000053e <panic>
    panic("sched interruptible");
    800021d4:	00006517          	auipc	a0,0x6
    800021d8:	07450513          	addi	a0,a0,116 # 80008248 <digits+0x208>
    800021dc:	ffffe097          	auipc	ra,0xffffe
    800021e0:	362080e7          	jalr	866(ra) # 8000053e <panic>

00000000800021e4 <yield>:
{
    800021e4:	1101                	addi	sp,sp,-32
    800021e6:	ec06                	sd	ra,24(sp)
    800021e8:	e822                	sd	s0,16(sp)
    800021ea:	e426                	sd	s1,8(sp)
    800021ec:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021ee:	fffff097          	auipc	ra,0xfffff
    800021f2:	7fc080e7          	jalr	2044(ra) # 800019ea <myproc>
    800021f6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	9de080e7          	jalr	-1570(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002200:	478d                	li	a5,3
    80002202:	cc9c                	sw	a5,24(s1)
  sched();
    80002204:	00000097          	auipc	ra,0x0
    80002208:	f0a080e7          	jalr	-246(ra) # 8000210e <sched>
  release(&p->lock);
    8000220c:	8526                	mv	a0,s1
    8000220e:	fffff097          	auipc	ra,0xfffff
    80002212:	a7c080e7          	jalr	-1412(ra) # 80000c8a <release>
}
    80002216:	60e2                	ld	ra,24(sp)
    80002218:	6442                	ld	s0,16(sp)
    8000221a:	64a2                	ld	s1,8(sp)
    8000221c:	6105                	addi	sp,sp,32
    8000221e:	8082                	ret

0000000080002220 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002220:	7179                	addi	sp,sp,-48
    80002222:	f406                	sd	ra,40(sp)
    80002224:	f022                	sd	s0,32(sp)
    80002226:	ec26                	sd	s1,24(sp)
    80002228:	e84a                	sd	s2,16(sp)
    8000222a:	e44e                	sd	s3,8(sp)
    8000222c:	1800                	addi	s0,sp,48
    8000222e:	89aa                	mv	s3,a0
    80002230:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	7b8080e7          	jalr	1976(ra) # 800019ea <myproc>
    8000223a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000223c:	fffff097          	auipc	ra,0xfffff
    80002240:	99a080e7          	jalr	-1638(ra) # 80000bd6 <acquire>
  release(lk);
    80002244:	854a                	mv	a0,s2
    80002246:	fffff097          	auipc	ra,0xfffff
    8000224a:	a44080e7          	jalr	-1468(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    8000224e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002252:	4789                	li	a5,2
    80002254:	cc9c                	sw	a5,24(s1)

  sched();
    80002256:	00000097          	auipc	ra,0x0
    8000225a:	eb8080e7          	jalr	-328(ra) # 8000210e <sched>

  // Tidy up.
  p->chan = 0;
    8000225e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002262:	8526                	mv	a0,s1
    80002264:	fffff097          	auipc	ra,0xfffff
    80002268:	a26080e7          	jalr	-1498(ra) # 80000c8a <release>
  acquire(lk);
    8000226c:	854a                	mv	a0,s2
    8000226e:	fffff097          	auipc	ra,0xfffff
    80002272:	968080e7          	jalr	-1688(ra) # 80000bd6 <acquire>
}
    80002276:	70a2                	ld	ra,40(sp)
    80002278:	7402                	ld	s0,32(sp)
    8000227a:	64e2                	ld	s1,24(sp)
    8000227c:	6942                	ld	s2,16(sp)
    8000227e:	69a2                	ld	s3,8(sp)
    80002280:	6145                	addi	sp,sp,48
    80002282:	8082                	ret

0000000080002284 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002284:	7139                	addi	sp,sp,-64
    80002286:	fc06                	sd	ra,56(sp)
    80002288:	f822                	sd	s0,48(sp)
    8000228a:	f426                	sd	s1,40(sp)
    8000228c:	f04a                	sd	s2,32(sp)
    8000228e:	ec4e                	sd	s3,24(sp)
    80002290:	e852                	sd	s4,16(sp)
    80002292:	e456                	sd	s5,8(sp)
    80002294:	e05a                	sd	s6,0(sp)
    80002296:	0080                	addi	s0,sp,64
    80002298:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000229a:	0000f497          	auipc	s1,0xf
    8000229e:	d0648493          	addi	s1,s1,-762 # 80010fa0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800022a2:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800022a4:	4b0d                	li	s6,3
#if defined MLFQ
        p->arrival_time_queue = sys_time++;
#else
        p->arrival_time = sys_time++;
    800022a6:	00006a97          	auipc	s5,0x6
    800022aa:	652a8a93          	addi	s5,s5,1618 # 800088f8 <sys_time>
  for (p = proc; p < &proc[NPROC]; p++)
    800022ae:	00017917          	auipc	s2,0x17
    800022b2:	4f290913          	addi	s2,s2,1266 # 800197a0 <tickslock>
    800022b6:	a811                	j	800022ca <wakeup+0x46>
#endif
      }
      release(&p->lock);
    800022b8:	8526                	mv	a0,s1
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	9d0080e7          	jalr	-1584(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800022c2:	22048493          	addi	s1,s1,544
    800022c6:	03248e63          	beq	s1,s2,80002302 <wakeup+0x7e>
    if (p != myproc())
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	720080e7          	jalr	1824(ra) # 800019ea <myproc>
    800022d2:	fea488e3          	beq	s1,a0,800022c2 <wakeup+0x3e>
      acquire(&p->lock);
    800022d6:	8526                	mv	a0,s1
    800022d8:	fffff097          	auipc	ra,0xfffff
    800022dc:	8fe080e7          	jalr	-1794(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800022e0:	4c9c                	lw	a5,24(s1)
    800022e2:	fd379be3          	bne	a5,s3,800022b8 <wakeup+0x34>
    800022e6:	709c                	ld	a5,32(s1)
    800022e8:	fd4798e3          	bne	a5,s4,800022b8 <wakeup+0x34>
        p->state = RUNNABLE;
    800022ec:	0164ac23          	sw	s6,24(s1)
        p->arrival_time = sys_time++;
    800022f0:	000ab783          	ld	a5,0(s5)
    800022f4:	00178713          	addi	a4,a5,1
    800022f8:	00eab023          	sd	a4,0(s5)
    800022fc:	20f4ac23          	sw	a5,536(s1)
    80002300:	bf65                	j	800022b8 <wakeup+0x34>
    }
  }
}
    80002302:	70e2                	ld	ra,56(sp)
    80002304:	7442                	ld	s0,48(sp)
    80002306:	74a2                	ld	s1,40(sp)
    80002308:	7902                	ld	s2,32(sp)
    8000230a:	69e2                	ld	s3,24(sp)
    8000230c:	6a42                	ld	s4,16(sp)
    8000230e:	6aa2                	ld	s5,8(sp)
    80002310:	6b02                	ld	s6,0(sp)
    80002312:	6121                	addi	sp,sp,64
    80002314:	8082                	ret

0000000080002316 <reparent>:
{
    80002316:	7179                	addi	sp,sp,-48
    80002318:	f406                	sd	ra,40(sp)
    8000231a:	f022                	sd	s0,32(sp)
    8000231c:	ec26                	sd	s1,24(sp)
    8000231e:	e84a                	sd	s2,16(sp)
    80002320:	e44e                	sd	s3,8(sp)
    80002322:	e052                	sd	s4,0(sp)
    80002324:	1800                	addi	s0,sp,48
    80002326:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002328:	0000f497          	auipc	s1,0xf
    8000232c:	c7848493          	addi	s1,s1,-904 # 80010fa0 <proc>
      pp->parent = initproc;
    80002330:	00006a17          	auipc	s4,0x6
    80002334:	5d0a0a13          	addi	s4,s4,1488 # 80008900 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002338:	00017997          	auipc	s3,0x17
    8000233c:	46898993          	addi	s3,s3,1128 # 800197a0 <tickslock>
    80002340:	a029                	j	8000234a <reparent+0x34>
    80002342:	22048493          	addi	s1,s1,544
    80002346:	01348d63          	beq	s1,s3,80002360 <reparent+0x4a>
    if (pp->parent == p)
    8000234a:	7c9c                	ld	a5,56(s1)
    8000234c:	ff279be3          	bne	a5,s2,80002342 <reparent+0x2c>
      pp->parent = initproc;
    80002350:	000a3503          	ld	a0,0(s4)
    80002354:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002356:	00000097          	auipc	ra,0x0
    8000235a:	f2e080e7          	jalr	-210(ra) # 80002284 <wakeup>
    8000235e:	b7d5                	j	80002342 <reparent+0x2c>
}
    80002360:	70a2                	ld	ra,40(sp)
    80002362:	7402                	ld	s0,32(sp)
    80002364:	64e2                	ld	s1,24(sp)
    80002366:	6942                	ld	s2,16(sp)
    80002368:	69a2                	ld	s3,8(sp)
    8000236a:	6a02                	ld	s4,0(sp)
    8000236c:	6145                	addi	sp,sp,48
    8000236e:	8082                	ret

0000000080002370 <exit>:
{
    80002370:	7179                	addi	sp,sp,-48
    80002372:	f406                	sd	ra,40(sp)
    80002374:	f022                	sd	s0,32(sp)
    80002376:	ec26                	sd	s1,24(sp)
    80002378:	e84a                	sd	s2,16(sp)
    8000237a:	e44e                	sd	s3,8(sp)
    8000237c:	e052                	sd	s4,0(sp)
    8000237e:	1800                	addi	s0,sp,48
    80002380:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	668080e7          	jalr	1640(ra) # 800019ea <myproc>
    8000238a:	89aa                	mv	s3,a0
  if (p == initproc)
    8000238c:	00006797          	auipc	a5,0x6
    80002390:	5747b783          	ld	a5,1396(a5) # 80008900 <initproc>
    80002394:	0d050493          	addi	s1,a0,208
    80002398:	15050913          	addi	s2,a0,336
    8000239c:	02a79363          	bne	a5,a0,800023c2 <exit+0x52>
    panic("init exiting");
    800023a0:	00006517          	auipc	a0,0x6
    800023a4:	ec050513          	addi	a0,a0,-320 # 80008260 <digits+0x220>
    800023a8:	ffffe097          	auipc	ra,0xffffe
    800023ac:	196080e7          	jalr	406(ra) # 8000053e <panic>
      fileclose(f);
    800023b0:	00002097          	auipc	ra,0x2
    800023b4:	720080e7          	jalr	1824(ra) # 80004ad0 <fileclose>
      p->ofile[fd] = 0;
    800023b8:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800023bc:	04a1                	addi	s1,s1,8
    800023be:	01248563          	beq	s1,s2,800023c8 <exit+0x58>
    if (p->ofile[fd])
    800023c2:	6088                	ld	a0,0(s1)
    800023c4:	f575                	bnez	a0,800023b0 <exit+0x40>
    800023c6:	bfdd                	j	800023bc <exit+0x4c>
  begin_op();
    800023c8:	00002097          	auipc	ra,0x2
    800023cc:	23c080e7          	jalr	572(ra) # 80004604 <begin_op>
  iput(p->cwd);
    800023d0:	1509b503          	ld	a0,336(s3)
    800023d4:	00002097          	auipc	ra,0x2
    800023d8:	a28080e7          	jalr	-1496(ra) # 80003dfc <iput>
  end_op();
    800023dc:	00002097          	auipc	ra,0x2
    800023e0:	2a8080e7          	jalr	680(ra) # 80004684 <end_op>
  p->cwd = 0;
    800023e4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800023e8:	0000e497          	auipc	s1,0xe
    800023ec:	7a048493          	addi	s1,s1,1952 # 80010b88 <wait_lock>
    800023f0:	8526                	mv	a0,s1
    800023f2:	ffffe097          	auipc	ra,0xffffe
    800023f6:	7e4080e7          	jalr	2020(ra) # 80000bd6 <acquire>
  reparent(p);
    800023fa:	854e                	mv	a0,s3
    800023fc:	00000097          	auipc	ra,0x0
    80002400:	f1a080e7          	jalr	-230(ra) # 80002316 <reparent>
  wakeup(p->parent);
    80002404:	0389b503          	ld	a0,56(s3)
    80002408:	00000097          	auipc	ra,0x0
    8000240c:	e7c080e7          	jalr	-388(ra) # 80002284 <wakeup>
  acquire(&p->lock);
    80002410:	854e                	mv	a0,s3
    80002412:	ffffe097          	auipc	ra,0xffffe
    80002416:	7c4080e7          	jalr	1988(ra) # 80000bd6 <acquire>
  p->xstate = status;
    8000241a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000241e:	4795                	li	a5,5
    80002420:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002424:	00006797          	auipc	a5,0x6
    80002428:	4e47a783          	lw	a5,1252(a5) # 80008908 <ticks>
    8000242c:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    80002430:	8526                	mv	a0,s1
    80002432:	fffff097          	auipc	ra,0xfffff
    80002436:	858080e7          	jalr	-1960(ra) # 80000c8a <release>
  sched();
    8000243a:	00000097          	auipc	ra,0x0
    8000243e:	cd4080e7          	jalr	-812(ra) # 8000210e <sched>
  panic("zombie exit");
    80002442:	00006517          	auipc	a0,0x6
    80002446:	e2e50513          	addi	a0,a0,-466 # 80008270 <digits+0x230>
    8000244a:	ffffe097          	auipc	ra,0xffffe
    8000244e:	0f4080e7          	jalr	244(ra) # 8000053e <panic>

0000000080002452 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002452:	7179                	addi	sp,sp,-48
    80002454:	f406                	sd	ra,40(sp)
    80002456:	f022                	sd	s0,32(sp)
    80002458:	ec26                	sd	s1,24(sp)
    8000245a:	e84a                	sd	s2,16(sp)
    8000245c:	e44e                	sd	s3,8(sp)
    8000245e:	1800                	addi	s0,sp,48
    80002460:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002462:	0000f497          	auipc	s1,0xf
    80002466:	b3e48493          	addi	s1,s1,-1218 # 80010fa0 <proc>
    8000246a:	00017997          	auipc	s3,0x17
    8000246e:	33698993          	addi	s3,s3,822 # 800197a0 <tickslock>
  {
    acquire(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	ffffe097          	auipc	ra,0xffffe
    80002478:	762080e7          	jalr	1890(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    8000247c:	589c                	lw	a5,48(s1)
    8000247e:	01278d63          	beq	a5,s2,80002498 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002482:	8526                	mv	a0,s1
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	806080e7          	jalr	-2042(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000248c:	22048493          	addi	s1,s1,544
    80002490:	ff3491e3          	bne	s1,s3,80002472 <kill+0x20>
  }
  return -1;
    80002494:	557d                	li	a0,-1
    80002496:	a829                	j	800024b0 <kill+0x5e>
      p->killed = 1;
    80002498:	4785                	li	a5,1
    8000249a:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    8000249c:	4c98                	lw	a4,24(s1)
    8000249e:	4789                	li	a5,2
    800024a0:	00f70f63          	beq	a4,a5,800024be <kill+0x6c>
      release(&p->lock);
    800024a4:	8526                	mv	a0,s1
    800024a6:	ffffe097          	auipc	ra,0xffffe
    800024aa:	7e4080e7          	jalr	2020(ra) # 80000c8a <release>
      return 0;
    800024ae:	4501                	li	a0,0
}
    800024b0:	70a2                	ld	ra,40(sp)
    800024b2:	7402                	ld	s0,32(sp)
    800024b4:	64e2                	ld	s1,24(sp)
    800024b6:	6942                	ld	s2,16(sp)
    800024b8:	69a2                	ld	s3,8(sp)
    800024ba:	6145                	addi	sp,sp,48
    800024bc:	8082                	ret
        p->state = RUNNABLE;
    800024be:	478d                	li	a5,3
    800024c0:	cc9c                	sw	a5,24(s1)
    800024c2:	b7cd                	j	800024a4 <kill+0x52>

00000000800024c4 <setkilled>:

void setkilled(struct proc *p)
{
    800024c4:	1101                	addi	sp,sp,-32
    800024c6:	ec06                	sd	ra,24(sp)
    800024c8:	e822                	sd	s0,16(sp)
    800024ca:	e426                	sd	s1,8(sp)
    800024cc:	1000                	addi	s0,sp,32
    800024ce:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024d0:	ffffe097          	auipc	ra,0xffffe
    800024d4:	706080e7          	jalr	1798(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800024d8:	4785                	li	a5,1
    800024da:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800024dc:	8526                	mv	a0,s1
    800024de:	ffffe097          	auipc	ra,0xffffe
    800024e2:	7ac080e7          	jalr	1964(ra) # 80000c8a <release>
}
    800024e6:	60e2                	ld	ra,24(sp)
    800024e8:	6442                	ld	s0,16(sp)
    800024ea:	64a2                	ld	s1,8(sp)
    800024ec:	6105                	addi	sp,sp,32
    800024ee:	8082                	ret

00000000800024f0 <killed>:

int killed(struct proc *p)
{
    800024f0:	1101                	addi	sp,sp,-32
    800024f2:	ec06                	sd	ra,24(sp)
    800024f4:	e822                	sd	s0,16(sp)
    800024f6:	e426                	sd	s1,8(sp)
    800024f8:	e04a                	sd	s2,0(sp)
    800024fa:	1000                	addi	s0,sp,32
    800024fc:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800024fe:	ffffe097          	auipc	ra,0xffffe
    80002502:	6d8080e7          	jalr	1752(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002506:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000250a:	8526                	mv	a0,s1
    8000250c:	ffffe097          	auipc	ra,0xffffe
    80002510:	77e080e7          	jalr	1918(ra) # 80000c8a <release>
  return k;
}
    80002514:	854a                	mv	a0,s2
    80002516:	60e2                	ld	ra,24(sp)
    80002518:	6442                	ld	s0,16(sp)
    8000251a:	64a2                	ld	s1,8(sp)
    8000251c:	6902                	ld	s2,0(sp)
    8000251e:	6105                	addi	sp,sp,32
    80002520:	8082                	ret

0000000080002522 <wait>:
{
    80002522:	715d                	addi	sp,sp,-80
    80002524:	e486                	sd	ra,72(sp)
    80002526:	e0a2                	sd	s0,64(sp)
    80002528:	fc26                	sd	s1,56(sp)
    8000252a:	f84a                	sd	s2,48(sp)
    8000252c:	f44e                	sd	s3,40(sp)
    8000252e:	f052                	sd	s4,32(sp)
    80002530:	ec56                	sd	s5,24(sp)
    80002532:	e85a                	sd	s6,16(sp)
    80002534:	e45e                	sd	s7,8(sp)
    80002536:	e062                	sd	s8,0(sp)
    80002538:	0880                	addi	s0,sp,80
    8000253a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000253c:	fffff097          	auipc	ra,0xfffff
    80002540:	4ae080e7          	jalr	1198(ra) # 800019ea <myproc>
    80002544:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002546:	0000e517          	auipc	a0,0xe
    8000254a:	64250513          	addi	a0,a0,1602 # 80010b88 <wait_lock>
    8000254e:	ffffe097          	auipc	ra,0xffffe
    80002552:	688080e7          	jalr	1672(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002556:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002558:	4a15                	li	s4,5
        havekids = 1;
    8000255a:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000255c:	00017997          	auipc	s3,0x17
    80002560:	24498993          	addi	s3,s3,580 # 800197a0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002564:	0000ec17          	auipc	s8,0xe
    80002568:	624c0c13          	addi	s8,s8,1572 # 80010b88 <wait_lock>
    havekids = 0;
    8000256c:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000256e:	0000f497          	auipc	s1,0xf
    80002572:	a3248493          	addi	s1,s1,-1486 # 80010fa0 <proc>
    80002576:	a0bd                	j	800025e4 <wait+0xc2>
          pid = pp->pid;
    80002578:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000257c:	000b0e63          	beqz	s6,80002598 <wait+0x76>
    80002580:	4691                	li	a3,4
    80002582:	02c48613          	addi	a2,s1,44
    80002586:	85da                	mv	a1,s6
    80002588:	05093503          	ld	a0,80(s2)
    8000258c:	fffff097          	auipc	ra,0xfffff
    80002590:	0dc080e7          	jalr	220(ra) # 80001668 <copyout>
    80002594:	02054563          	bltz	a0,800025be <wait+0x9c>
          freeproc(pp);
    80002598:	8526                	mv	a0,s1
    8000259a:	fffff097          	auipc	ra,0xfffff
    8000259e:	602080e7          	jalr	1538(ra) # 80001b9c <freeproc>
          release(&pp->lock);
    800025a2:	8526                	mv	a0,s1
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	6e6080e7          	jalr	1766(ra) # 80000c8a <release>
          release(&wait_lock);
    800025ac:	0000e517          	auipc	a0,0xe
    800025b0:	5dc50513          	addi	a0,a0,1500 # 80010b88 <wait_lock>
    800025b4:	ffffe097          	auipc	ra,0xffffe
    800025b8:	6d6080e7          	jalr	1750(ra) # 80000c8a <release>
          return pid;
    800025bc:	a0b5                	j	80002628 <wait+0x106>
            release(&pp->lock);
    800025be:	8526                	mv	a0,s1
    800025c0:	ffffe097          	auipc	ra,0xffffe
    800025c4:	6ca080e7          	jalr	1738(ra) # 80000c8a <release>
            release(&wait_lock);
    800025c8:	0000e517          	auipc	a0,0xe
    800025cc:	5c050513          	addi	a0,a0,1472 # 80010b88 <wait_lock>
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	6ba080e7          	jalr	1722(ra) # 80000c8a <release>
            return -1;
    800025d8:	59fd                	li	s3,-1
    800025da:	a0b9                	j	80002628 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800025dc:	22048493          	addi	s1,s1,544
    800025e0:	03348463          	beq	s1,s3,80002608 <wait+0xe6>
      if (pp->parent == p)
    800025e4:	7c9c                	ld	a5,56(s1)
    800025e6:	ff279be3          	bne	a5,s2,800025dc <wait+0xba>
        acquire(&pp->lock);
    800025ea:	8526                	mv	a0,s1
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	5ea080e7          	jalr	1514(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    800025f4:	4c9c                	lw	a5,24(s1)
    800025f6:	f94781e3          	beq	a5,s4,80002578 <wait+0x56>
        release(&pp->lock);
    800025fa:	8526                	mv	a0,s1
    800025fc:	ffffe097          	auipc	ra,0xffffe
    80002600:	68e080e7          	jalr	1678(ra) # 80000c8a <release>
        havekids = 1;
    80002604:	8756                	mv	a4,s5
    80002606:	bfd9                	j	800025dc <wait+0xba>
    if (!havekids || killed(p))
    80002608:	c719                	beqz	a4,80002616 <wait+0xf4>
    8000260a:	854a                	mv	a0,s2
    8000260c:	00000097          	auipc	ra,0x0
    80002610:	ee4080e7          	jalr	-284(ra) # 800024f0 <killed>
    80002614:	c51d                	beqz	a0,80002642 <wait+0x120>
      release(&wait_lock);
    80002616:	0000e517          	auipc	a0,0xe
    8000261a:	57250513          	addi	a0,a0,1394 # 80010b88 <wait_lock>
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	66c080e7          	jalr	1644(ra) # 80000c8a <release>
      return -1;
    80002626:	59fd                	li	s3,-1
}
    80002628:	854e                	mv	a0,s3
    8000262a:	60a6                	ld	ra,72(sp)
    8000262c:	6406                	ld	s0,64(sp)
    8000262e:	74e2                	ld	s1,56(sp)
    80002630:	7942                	ld	s2,48(sp)
    80002632:	79a2                	ld	s3,40(sp)
    80002634:	7a02                	ld	s4,32(sp)
    80002636:	6ae2                	ld	s5,24(sp)
    80002638:	6b42                	ld	s6,16(sp)
    8000263a:	6ba2                	ld	s7,8(sp)
    8000263c:	6c02                	ld	s8,0(sp)
    8000263e:	6161                	addi	sp,sp,80
    80002640:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002642:	85e2                	mv	a1,s8
    80002644:	854a                	mv	a0,s2
    80002646:	00000097          	auipc	ra,0x0
    8000264a:	bda080e7          	jalr	-1062(ra) # 80002220 <sleep>
    havekids = 0;
    8000264e:	bf39                	j	8000256c <wait+0x4a>

0000000080002650 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002650:	7179                	addi	sp,sp,-48
    80002652:	f406                	sd	ra,40(sp)
    80002654:	f022                	sd	s0,32(sp)
    80002656:	ec26                	sd	s1,24(sp)
    80002658:	e84a                	sd	s2,16(sp)
    8000265a:	e44e                	sd	s3,8(sp)
    8000265c:	e052                	sd	s4,0(sp)
    8000265e:	1800                	addi	s0,sp,48
    80002660:	84aa                	mv	s1,a0
    80002662:	892e                	mv	s2,a1
    80002664:	89b2                	mv	s3,a2
    80002666:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002668:	fffff097          	auipc	ra,0xfffff
    8000266c:	382080e7          	jalr	898(ra) # 800019ea <myproc>
  if (user_dst)
    80002670:	c08d                	beqz	s1,80002692 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    80002672:	86d2                	mv	a3,s4
    80002674:	864e                	mv	a2,s3
    80002676:	85ca                	mv	a1,s2
    80002678:	6928                	ld	a0,80(a0)
    8000267a:	fffff097          	auipc	ra,0xfffff
    8000267e:	fee080e7          	jalr	-18(ra) # 80001668 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002682:	70a2                	ld	ra,40(sp)
    80002684:	7402                	ld	s0,32(sp)
    80002686:	64e2                	ld	s1,24(sp)
    80002688:	6942                	ld	s2,16(sp)
    8000268a:	69a2                	ld	s3,8(sp)
    8000268c:	6a02                	ld	s4,0(sp)
    8000268e:	6145                	addi	sp,sp,48
    80002690:	8082                	ret
    memmove((char *)dst, src, len);
    80002692:	000a061b          	sext.w	a2,s4
    80002696:	85ce                	mv	a1,s3
    80002698:	854a                	mv	a0,s2
    8000269a:	ffffe097          	auipc	ra,0xffffe
    8000269e:	694080e7          	jalr	1684(ra) # 80000d2e <memmove>
    return 0;
    800026a2:	8526                	mv	a0,s1
    800026a4:	bff9                	j	80002682 <either_copyout+0x32>

00000000800026a6 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026a6:	7179                	addi	sp,sp,-48
    800026a8:	f406                	sd	ra,40(sp)
    800026aa:	f022                	sd	s0,32(sp)
    800026ac:	ec26                	sd	s1,24(sp)
    800026ae:	e84a                	sd	s2,16(sp)
    800026b0:	e44e                	sd	s3,8(sp)
    800026b2:	e052                	sd	s4,0(sp)
    800026b4:	1800                	addi	s0,sp,48
    800026b6:	892a                	mv	s2,a0
    800026b8:	84ae                	mv	s1,a1
    800026ba:	89b2                	mv	s3,a2
    800026bc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026be:	fffff097          	auipc	ra,0xfffff
    800026c2:	32c080e7          	jalr	812(ra) # 800019ea <myproc>
  if (user_src)
    800026c6:	c08d                	beqz	s1,800026e8 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800026c8:	86d2                	mv	a3,s4
    800026ca:	864e                	mv	a2,s3
    800026cc:	85ca                	mv	a1,s2
    800026ce:	6928                	ld	a0,80(a0)
    800026d0:	fffff097          	auipc	ra,0xfffff
    800026d4:	024080e7          	jalr	36(ra) # 800016f4 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800026d8:	70a2                	ld	ra,40(sp)
    800026da:	7402                	ld	s0,32(sp)
    800026dc:	64e2                	ld	s1,24(sp)
    800026de:	6942                	ld	s2,16(sp)
    800026e0:	69a2                	ld	s3,8(sp)
    800026e2:	6a02                	ld	s4,0(sp)
    800026e4:	6145                	addi	sp,sp,48
    800026e6:	8082                	ret
    memmove(dst, (char *)src, len);
    800026e8:	000a061b          	sext.w	a2,s4
    800026ec:	85ce                	mv	a1,s3
    800026ee:	854a                	mv	a0,s2
    800026f0:	ffffe097          	auipc	ra,0xffffe
    800026f4:	63e080e7          	jalr	1598(ra) # 80000d2e <memmove>
    return 0;
    800026f8:	8526                	mv	a0,s1
    800026fa:	bff9                	j	800026d8 <either_copyin+0x32>

00000000800026fc <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800026fc:	715d                	addi	sp,sp,-80
    800026fe:	e486                	sd	ra,72(sp)
    80002700:	e0a2                	sd	s0,64(sp)
    80002702:	fc26                	sd	s1,56(sp)
    80002704:	f84a                	sd	s2,48(sp)
    80002706:	f44e                	sd	s3,40(sp)
    80002708:	f052                	sd	s4,32(sp)
    8000270a:	ec56                	sd	s5,24(sp)
    8000270c:	e85a                	sd	s6,16(sp)
    8000270e:	e45e                	sd	s7,8(sp)
    80002710:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002712:	00006517          	auipc	a0,0x6
    80002716:	9b650513          	addi	a0,a0,-1610 # 800080c8 <digits+0x88>
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	e6e080e7          	jalr	-402(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002722:	0000f497          	auipc	s1,0xf
    80002726:	9d648493          	addi	s1,s1,-1578 # 800110f8 <proc+0x158>
    8000272a:	00017917          	auipc	s2,0x17
    8000272e:	1ce90913          	addi	s2,s2,462 # 800198f8 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002732:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002734:	00006997          	auipc	s3,0x6
    80002738:	b4c98993          	addi	s3,s3,-1204 # 80008280 <digits+0x240>
    printf("%d %s %s %d", p->pid, state, p->name, p->tickets);
    8000273c:	00006a97          	auipc	s5,0x6
    80002740:	b4ca8a93          	addi	s5,s5,-1204 # 80008288 <digits+0x248>
    printf("\n");
    80002744:	00006a17          	auipc	s4,0x6
    80002748:	984a0a13          	addi	s4,s4,-1660 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000274c:	00006b97          	auipc	s7,0x6
    80002750:	b7cb8b93          	addi	s7,s7,-1156 # 800082c8 <states.0>
    80002754:	a01d                	j	8000277a <procdump+0x7e>
    printf("%d %s %s %d", p->pid, state, p->name, p->tickets);
    80002756:	0bc6a703          	lw	a4,188(a3)
    8000275a:	ed86a583          	lw	a1,-296(a3)
    8000275e:	8556                	mv	a0,s5
    80002760:	ffffe097          	auipc	ra,0xffffe
    80002764:	e28080e7          	jalr	-472(ra) # 80000588 <printf>
    printf("\n");
    80002768:	8552                	mv	a0,s4
    8000276a:	ffffe097          	auipc	ra,0xffffe
    8000276e:	e1e080e7          	jalr	-482(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002772:	22048493          	addi	s1,s1,544
    80002776:	03248163          	beq	s1,s2,80002798 <procdump+0x9c>
    if (p->state == UNUSED)
    8000277a:	86a6                	mv	a3,s1
    8000277c:	ec04a783          	lw	a5,-320(s1)
    80002780:	dbed                	beqz	a5,80002772 <procdump+0x76>
      state = "???";
    80002782:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002784:	fcfb69e3          	bltu	s6,a5,80002756 <procdump+0x5a>
    80002788:	1782                	slli	a5,a5,0x20
    8000278a:	9381                	srli	a5,a5,0x20
    8000278c:	078e                	slli	a5,a5,0x3
    8000278e:	97de                	add	a5,a5,s7
    80002790:	6390                	ld	a2,0(a5)
    80002792:	f271                	bnez	a2,80002756 <procdump+0x5a>
      state = "???";
    80002794:	864e                	mv	a2,s3
    80002796:	b7c1                	j	80002756 <procdump+0x5a>
  }
}
    80002798:	60a6                	ld	ra,72(sp)
    8000279a:	6406                	ld	s0,64(sp)
    8000279c:	74e2                	ld	s1,56(sp)
    8000279e:	7942                	ld	s2,48(sp)
    800027a0:	79a2                	ld	s3,40(sp)
    800027a2:	7a02                	ld	s4,32(sp)
    800027a4:	6ae2                	ld	s5,24(sp)
    800027a6:	6b42                	ld	s6,16(sp)
    800027a8:	6ba2                	ld	s7,8(sp)
    800027aa:	6161                	addi	sp,sp,80
    800027ac:	8082                	ret

00000000800027ae <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    800027ae:	711d                	addi	sp,sp,-96
    800027b0:	ec86                	sd	ra,88(sp)
    800027b2:	e8a2                	sd	s0,80(sp)
    800027b4:	e4a6                	sd	s1,72(sp)
    800027b6:	e0ca                	sd	s2,64(sp)
    800027b8:	fc4e                	sd	s3,56(sp)
    800027ba:	f852                	sd	s4,48(sp)
    800027bc:	f456                	sd	s5,40(sp)
    800027be:	f05a                	sd	s6,32(sp)
    800027c0:	ec5e                	sd	s7,24(sp)
    800027c2:	e862                	sd	s8,16(sp)
    800027c4:	e466                	sd	s9,8(sp)
    800027c6:	e06a                	sd	s10,0(sp)
    800027c8:	1080                	addi	s0,sp,96
    800027ca:	8b2a                	mv	s6,a0
    800027cc:	8bae                	mv	s7,a1
    800027ce:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800027d0:	fffff097          	auipc	ra,0xfffff
    800027d4:	21a080e7          	jalr	538(ra) # 800019ea <myproc>
    800027d8:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800027da:	0000e517          	auipc	a0,0xe
    800027de:	3ae50513          	addi	a0,a0,942 # 80010b88 <wait_lock>
    800027e2:	ffffe097          	auipc	ra,0xffffe
    800027e6:	3f4080e7          	jalr	1012(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    800027ea:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    800027ec:	4a15                	li	s4,5
        havekids = 1;
    800027ee:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800027f0:	00017997          	auipc	s3,0x17
    800027f4:	fb098993          	addi	s3,s3,-80 # 800197a0 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027f8:	0000ed17          	auipc	s10,0xe
    800027fc:	390d0d13          	addi	s10,s10,912 # 80010b88 <wait_lock>
    havekids = 0;
    80002800:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    80002802:	0000e497          	auipc	s1,0xe
    80002806:	79e48493          	addi	s1,s1,1950 # 80010fa0 <proc>
    8000280a:	a059                	j	80002890 <waitx+0xe2>
          pid = np->pid;
    8000280c:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002810:	1684a703          	lw	a4,360(s1)
    80002814:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002818:	16c4a783          	lw	a5,364(s1)
    8000281c:	9f3d                	addw	a4,a4,a5
    8000281e:	1704a783          	lw	a5,368(s1)
    80002822:	9f99                	subw	a5,a5,a4
    80002824:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002828:	000b0e63          	beqz	s6,80002844 <waitx+0x96>
    8000282c:	4691                	li	a3,4
    8000282e:	02c48613          	addi	a2,s1,44
    80002832:	85da                	mv	a1,s6
    80002834:	05093503          	ld	a0,80(s2)
    80002838:	fffff097          	auipc	ra,0xfffff
    8000283c:	e30080e7          	jalr	-464(ra) # 80001668 <copyout>
    80002840:	02054563          	bltz	a0,8000286a <waitx+0xbc>
          freeproc(np);
    80002844:	8526                	mv	a0,s1
    80002846:	fffff097          	auipc	ra,0xfffff
    8000284a:	356080e7          	jalr	854(ra) # 80001b9c <freeproc>
          release(&np->lock);
    8000284e:	8526                	mv	a0,s1
    80002850:	ffffe097          	auipc	ra,0xffffe
    80002854:	43a080e7          	jalr	1082(ra) # 80000c8a <release>
          release(&wait_lock);
    80002858:	0000e517          	auipc	a0,0xe
    8000285c:	33050513          	addi	a0,a0,816 # 80010b88 <wait_lock>
    80002860:	ffffe097          	auipc	ra,0xffffe
    80002864:	42a080e7          	jalr	1066(ra) # 80000c8a <release>
          return pid;
    80002868:	a09d                	j	800028ce <waitx+0x120>
            release(&np->lock);
    8000286a:	8526                	mv	a0,s1
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	41e080e7          	jalr	1054(ra) # 80000c8a <release>
            release(&wait_lock);
    80002874:	0000e517          	auipc	a0,0xe
    80002878:	31450513          	addi	a0,a0,788 # 80010b88 <wait_lock>
    8000287c:	ffffe097          	auipc	ra,0xffffe
    80002880:	40e080e7          	jalr	1038(ra) # 80000c8a <release>
            return -1;
    80002884:	59fd                	li	s3,-1
    80002886:	a0a1                	j	800028ce <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002888:	22048493          	addi	s1,s1,544
    8000288c:	03348463          	beq	s1,s3,800028b4 <waitx+0x106>
      if (np->parent == p)
    80002890:	7c9c                	ld	a5,56(s1)
    80002892:	ff279be3          	bne	a5,s2,80002888 <waitx+0xda>
        acquire(&np->lock);
    80002896:	8526                	mv	a0,s1
    80002898:	ffffe097          	auipc	ra,0xffffe
    8000289c:	33e080e7          	jalr	830(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    800028a0:	4c9c                	lw	a5,24(s1)
    800028a2:	f74785e3          	beq	a5,s4,8000280c <waitx+0x5e>
        release(&np->lock);
    800028a6:	8526                	mv	a0,s1
    800028a8:	ffffe097          	auipc	ra,0xffffe
    800028ac:	3e2080e7          	jalr	994(ra) # 80000c8a <release>
        havekids = 1;
    800028b0:	8756                	mv	a4,s5
    800028b2:	bfd9                	j	80002888 <waitx+0xda>
    if (!havekids || p->killed)
    800028b4:	c701                	beqz	a4,800028bc <waitx+0x10e>
    800028b6:	02892783          	lw	a5,40(s2)
    800028ba:	cb8d                	beqz	a5,800028ec <waitx+0x13e>
      release(&wait_lock);
    800028bc:	0000e517          	auipc	a0,0xe
    800028c0:	2cc50513          	addi	a0,a0,716 # 80010b88 <wait_lock>
    800028c4:	ffffe097          	auipc	ra,0xffffe
    800028c8:	3c6080e7          	jalr	966(ra) # 80000c8a <release>
      return -1;
    800028cc:	59fd                	li	s3,-1
  }
}
    800028ce:	854e                	mv	a0,s3
    800028d0:	60e6                	ld	ra,88(sp)
    800028d2:	6446                	ld	s0,80(sp)
    800028d4:	64a6                	ld	s1,72(sp)
    800028d6:	6906                	ld	s2,64(sp)
    800028d8:	79e2                	ld	s3,56(sp)
    800028da:	7a42                	ld	s4,48(sp)
    800028dc:	7aa2                	ld	s5,40(sp)
    800028de:	7b02                	ld	s6,32(sp)
    800028e0:	6be2                	ld	s7,24(sp)
    800028e2:	6c42                	ld	s8,16(sp)
    800028e4:	6ca2                	ld	s9,8(sp)
    800028e6:	6d02                	ld	s10,0(sp)
    800028e8:	6125                	addi	sp,sp,96
    800028ea:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800028ec:	85ea                	mv	a1,s10
    800028ee:	854a                	mv	a0,s2
    800028f0:	00000097          	auipc	ra,0x0
    800028f4:	930080e7          	jalr	-1744(ra) # 80002220 <sleep>
    havekids = 0;
    800028f8:	b721                	j	80002800 <waitx+0x52>

00000000800028fa <update_time>:

void update_time()
{
    800028fa:	7179                	addi	sp,sp,-48
    800028fc:	f406                	sd	ra,40(sp)
    800028fe:	f022                	sd	s0,32(sp)
    80002900:	ec26                	sd	s1,24(sp)
    80002902:	e84a                	sd	s2,16(sp)
    80002904:	e44e                	sd	s3,8(sp)
    80002906:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002908:	0000e497          	auipc	s1,0xe
    8000290c:	69848493          	addi	s1,s1,1688 # 80010fa0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    80002910:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    80002912:	00017917          	auipc	s2,0x17
    80002916:	e8e90913          	addi	s2,s2,-370 # 800197a0 <tickslock>
    8000291a:	a811                	j	8000292e <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    8000291c:	8526                	mv	a0,s1
    8000291e:	ffffe097          	auipc	ra,0xffffe
    80002922:	36c080e7          	jalr	876(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002926:	22048493          	addi	s1,s1,544
    8000292a:	03248063          	beq	s1,s2,8000294a <update_time+0x50>
    acquire(&p->lock);
    8000292e:	8526                	mv	a0,s1
    80002930:	ffffe097          	auipc	ra,0xffffe
    80002934:	2a6080e7          	jalr	678(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    80002938:	4c9c                	lw	a5,24(s1)
    8000293a:	ff3791e3          	bne	a5,s3,8000291c <update_time+0x22>
      p->rtime++;
    8000293e:	1684a783          	lw	a5,360(s1)
    80002942:	2785                	addiw	a5,a5,1
    80002944:	16f4a423          	sw	a5,360(s1)
    80002948:	bfd1                	j	8000291c <update_time+0x22>
  }
    8000294a:	70a2                	ld	ra,40(sp)
    8000294c:	7402                	ld	s0,32(sp)
    8000294e:	64e2                	ld	s1,24(sp)
    80002950:	6942                	ld	s2,16(sp)
    80002952:	69a2                	ld	s3,8(sp)
    80002954:	6145                	addi	sp,sp,48
    80002956:	8082                	ret

0000000080002958 <swtch>:
    80002958:	00153023          	sd	ra,0(a0)
    8000295c:	00253423          	sd	sp,8(a0)
    80002960:	e900                	sd	s0,16(a0)
    80002962:	ed04                	sd	s1,24(a0)
    80002964:	03253023          	sd	s2,32(a0)
    80002968:	03353423          	sd	s3,40(a0)
    8000296c:	03453823          	sd	s4,48(a0)
    80002970:	03553c23          	sd	s5,56(a0)
    80002974:	05653023          	sd	s6,64(a0)
    80002978:	05753423          	sd	s7,72(a0)
    8000297c:	05853823          	sd	s8,80(a0)
    80002980:	05953c23          	sd	s9,88(a0)
    80002984:	07a53023          	sd	s10,96(a0)
    80002988:	07b53423          	sd	s11,104(a0)
    8000298c:	0005b083          	ld	ra,0(a1)
    80002990:	0085b103          	ld	sp,8(a1)
    80002994:	6980                	ld	s0,16(a1)
    80002996:	6d84                	ld	s1,24(a1)
    80002998:	0205b903          	ld	s2,32(a1)
    8000299c:	0285b983          	ld	s3,40(a1)
    800029a0:	0305ba03          	ld	s4,48(a1)
    800029a4:	0385ba83          	ld	s5,56(a1)
    800029a8:	0405bb03          	ld	s6,64(a1)
    800029ac:	0485bb83          	ld	s7,72(a1)
    800029b0:	0505bc03          	ld	s8,80(a1)
    800029b4:	0585bc83          	ld	s9,88(a1)
    800029b8:	0605bd03          	ld	s10,96(a1)
    800029bc:	0685bd83          	ld	s11,104(a1)
    800029c0:	8082                	ret

00000000800029c2 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    800029c2:	1141                	addi	sp,sp,-16
    800029c4:	e406                	sd	ra,8(sp)
    800029c6:	e022                	sd	s0,0(sp)
    800029c8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029ca:	00006597          	auipc	a1,0x6
    800029ce:	92e58593          	addi	a1,a1,-1746 # 800082f8 <states.0+0x30>
    800029d2:	00017517          	auipc	a0,0x17
    800029d6:	dce50513          	addi	a0,a0,-562 # 800197a0 <tickslock>
    800029da:	ffffe097          	auipc	ra,0xffffe
    800029de:	16c080e7          	jalr	364(ra) # 80000b46 <initlock>
}
    800029e2:	60a2                	ld	ra,8(sp)
    800029e4:	6402                	ld	s0,0(sp)
    800029e6:	0141                	addi	sp,sp,16
    800029e8:	8082                	ret

00000000800029ea <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    800029ea:	1141                	addi	sp,sp,-16
    800029ec:	e422                	sd	s0,8(sp)
    800029ee:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029f0:	00003797          	auipc	a5,0x3
    800029f4:	73078793          	addi	a5,a5,1840 # 80006120 <kernelvec>
    800029f8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029fc:	6422                	ld	s0,8(sp)
    800029fe:	0141                	addi	sp,sp,16
    80002a00:	8082                	ret

0000000080002a02 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002a02:	1141                	addi	sp,sp,-16
    80002a04:	e406                	sd	ra,8(sp)
    80002a06:	e022                	sd	s0,0(sp)
    80002a08:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a0a:	fffff097          	auipc	ra,0xfffff
    80002a0e:	fe0080e7          	jalr	-32(ra) # 800019ea <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a12:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a16:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a18:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a1c:	00004617          	auipc	a2,0x4
    80002a20:	5e460613          	addi	a2,a2,1508 # 80007000 <_trampoline>
    80002a24:	00004697          	auipc	a3,0x4
    80002a28:	5dc68693          	addi	a3,a3,1500 # 80007000 <_trampoline>
    80002a2c:	8e91                	sub	a3,a3,a2
    80002a2e:	040007b7          	lui	a5,0x4000
    80002a32:	17fd                	addi	a5,a5,-1
    80002a34:	07b2                	slli	a5,a5,0xc
    80002a36:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a38:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a3c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a3e:	180026f3          	csrr	a3,satp
    80002a42:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a44:	6d38                	ld	a4,88(a0)
    80002a46:	6134                	ld	a3,64(a0)
    80002a48:	6585                	lui	a1,0x1
    80002a4a:	96ae                	add	a3,a3,a1
    80002a4c:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a4e:	6d38                	ld	a4,88(a0)
    80002a50:	00000697          	auipc	a3,0x0
    80002a54:	13e68693          	addi	a3,a3,318 # 80002b8e <usertrap>
    80002a58:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002a5a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a5c:	8692                	mv	a3,tp
    80002a5e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a60:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a64:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a68:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a6c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a70:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a72:	6f18                	ld	a4,24(a4)
    80002a74:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a78:	6928                	ld	a0,80(a0)
    80002a7a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a7c:	00004717          	auipc	a4,0x4
    80002a80:	62070713          	addi	a4,a4,1568 # 8000709c <userret>
    80002a84:	8f11                	sub	a4,a4,a2
    80002a86:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002a88:	577d                	li	a4,-1
    80002a8a:	177e                	slli	a4,a4,0x3f
    80002a8c:	8d59                	or	a0,a0,a4
    80002a8e:	9782                	jalr	a5
}
    80002a90:	60a2                	ld	ra,8(sp)
    80002a92:	6402                	ld	s0,0(sp)
    80002a94:	0141                	addi	sp,sp,16
    80002a96:	8082                	ret

0000000080002a98 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002a98:	1101                	addi	sp,sp,-32
    80002a9a:	ec06                	sd	ra,24(sp)
    80002a9c:	e822                	sd	s0,16(sp)
    80002a9e:	e426                	sd	s1,8(sp)
    80002aa0:	e04a                	sd	s2,0(sp)
    80002aa2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002aa4:	00017917          	auipc	s2,0x17
    80002aa8:	cfc90913          	addi	s2,s2,-772 # 800197a0 <tickslock>
    80002aac:	854a                	mv	a0,s2
    80002aae:	ffffe097          	auipc	ra,0xffffe
    80002ab2:	128080e7          	jalr	296(ra) # 80000bd6 <acquire>
  ticks++;
    80002ab6:	00006497          	auipc	s1,0x6
    80002aba:	e5248493          	addi	s1,s1,-430 # 80008908 <ticks>
    80002abe:	409c                	lw	a5,0(s1)
    80002ac0:	2785                	addiw	a5,a5,1
    80002ac2:	c09c                	sw	a5,0(s1)
  update_time();
    80002ac4:	00000097          	auipc	ra,0x0
    80002ac8:	e36080e7          	jalr	-458(ra) # 800028fa <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002acc:	8526                	mv	a0,s1
    80002ace:	fffff097          	auipc	ra,0xfffff
    80002ad2:	7b6080e7          	jalr	1974(ra) # 80002284 <wakeup>
  release(&tickslock);
    80002ad6:	854a                	mv	a0,s2
    80002ad8:	ffffe097          	auipc	ra,0xffffe
    80002adc:	1b2080e7          	jalr	434(ra) # 80000c8a <release>
}
    80002ae0:	60e2                	ld	ra,24(sp)
    80002ae2:	6442                	ld	s0,16(sp)
    80002ae4:	64a2                	ld	s1,8(sp)
    80002ae6:	6902                	ld	s2,0(sp)
    80002ae8:	6105                	addi	sp,sp,32
    80002aea:	8082                	ret

0000000080002aec <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002aec:	1101                	addi	sp,sp,-32
    80002aee:	ec06                	sd	ra,24(sp)
    80002af0:	e822                	sd	s0,16(sp)
    80002af2:	e426                	sd	s1,8(sp)
    80002af4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002af6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002afa:	00074d63          	bltz	a4,80002b14 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002afe:	57fd                	li	a5,-1
    80002b00:	17fe                	slli	a5,a5,0x3f
    80002b02:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002b04:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002b06:	06f70363          	beq	a4,a5,80002b6c <devintr+0x80>
  }
}
    80002b0a:	60e2                	ld	ra,24(sp)
    80002b0c:	6442                	ld	s0,16(sp)
    80002b0e:	64a2                	ld	s1,8(sp)
    80002b10:	6105                	addi	sp,sp,32
    80002b12:	8082                	ret
      (scause & 0xff) == 9)
    80002b14:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80002b18:	46a5                	li	a3,9
    80002b1a:	fed792e3          	bne	a5,a3,80002afe <devintr+0x12>
    int irq = plic_claim();
    80002b1e:	00003097          	auipc	ra,0x3
    80002b22:	70a080e7          	jalr	1802(ra) # 80006228 <plic_claim>
    80002b26:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002b28:	47a9                	li	a5,10
    80002b2a:	02f50763          	beq	a0,a5,80002b58 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002b2e:	4785                	li	a5,1
    80002b30:	02f50963          	beq	a0,a5,80002b62 <devintr+0x76>
    return 1;
    80002b34:	4505                	li	a0,1
    else if (irq)
    80002b36:	d8f1                	beqz	s1,80002b0a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b38:	85a6                	mv	a1,s1
    80002b3a:	00005517          	auipc	a0,0x5
    80002b3e:	7c650513          	addi	a0,a0,1990 # 80008300 <states.0+0x38>
    80002b42:	ffffe097          	auipc	ra,0xffffe
    80002b46:	a46080e7          	jalr	-1466(ra) # 80000588 <printf>
      plic_complete(irq);
    80002b4a:	8526                	mv	a0,s1
    80002b4c:	00003097          	auipc	ra,0x3
    80002b50:	700080e7          	jalr	1792(ra) # 8000624c <plic_complete>
    return 1;
    80002b54:	4505                	li	a0,1
    80002b56:	bf55                	j	80002b0a <devintr+0x1e>
      uartintr();
    80002b58:	ffffe097          	auipc	ra,0xffffe
    80002b5c:	e42080e7          	jalr	-446(ra) # 8000099a <uartintr>
    80002b60:	b7ed                	j	80002b4a <devintr+0x5e>
      virtio_disk_intr();
    80002b62:	00004097          	auipc	ra,0x4
    80002b66:	bb6080e7          	jalr	-1098(ra) # 80006718 <virtio_disk_intr>
    80002b6a:	b7c5                	j	80002b4a <devintr+0x5e>
    if (cpuid() == 0)
    80002b6c:	fffff097          	auipc	ra,0xfffff
    80002b70:	e52080e7          	jalr	-430(ra) # 800019be <cpuid>
    80002b74:	c901                	beqz	a0,80002b84 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b76:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b7a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b7c:	14479073          	csrw	sip,a5
    return 2;
    80002b80:	4509                	li	a0,2
    80002b82:	b761                	j	80002b0a <devintr+0x1e>
      clockintr();
    80002b84:	00000097          	auipc	ra,0x0
    80002b88:	f14080e7          	jalr	-236(ra) # 80002a98 <clockintr>
    80002b8c:	b7ed                	j	80002b76 <devintr+0x8a>

0000000080002b8e <usertrap>:
{
    80002b8e:	1101                	addi	sp,sp,-32
    80002b90:	ec06                	sd	ra,24(sp)
    80002b92:	e822                	sd	s0,16(sp)
    80002b94:	e426                	sd	s1,8(sp)
    80002b96:	e04a                	sd	s2,0(sp)
    80002b98:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b9a:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002b9e:	1007f793          	andi	a5,a5,256
    80002ba2:	e3ad                	bnez	a5,80002c04 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ba4:	00003797          	auipc	a5,0x3
    80002ba8:	57c78793          	addi	a5,a5,1404 # 80006120 <kernelvec>
    80002bac:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bb0:	fffff097          	auipc	ra,0xfffff
    80002bb4:	e3a080e7          	jalr	-454(ra) # 800019ea <myproc>
    80002bb8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002bba:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bbc:	14102773          	csrr	a4,sepc
    80002bc0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bc2:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002bc6:	47a1                	li	a5,8
    80002bc8:	04f70663          	beq	a4,a5,80002c14 <usertrap+0x86>
  else if ((which_dev = devintr()) != 0)
    80002bcc:	00000097          	auipc	ra,0x0
    80002bd0:	f20080e7          	jalr	-224(ra) # 80002aec <devintr>
    80002bd4:	892a                	mv	s2,a0
    80002bd6:	c575                	beqz	a0,80002cc2 <usertrap+0x134>
    if (which_dev == 2 && p->alarm_state == 0)
    80002bd8:	4789                	li	a5,2
    80002bda:	08f50363          	beq	a0,a5,80002c60 <usertrap+0xd2>
  if (killed(p))
    80002bde:	8526                	mv	a0,s1
    80002be0:	00000097          	auipc	ra,0x0
    80002be4:	910080e7          	jalr	-1776(ra) # 800024f0 <killed>
    80002be8:	e125                	bnez	a0,80002c48 <usertrap+0xba>
  else if (which_dev == 1)
    80002bea:	4785                	li	a5,1
    80002bec:	10f90863          	beq	s2,a5,80002cfc <usertrap+0x16e>
  usertrapret();
    80002bf0:	00000097          	auipc	ra,0x0
    80002bf4:	e12080e7          	jalr	-494(ra) # 80002a02 <usertrapret>
}
    80002bf8:	60e2                	ld	ra,24(sp)
    80002bfa:	6442                	ld	s0,16(sp)
    80002bfc:	64a2                	ld	s1,8(sp)
    80002bfe:	6902                	ld	s2,0(sp)
    80002c00:	6105                	addi	sp,sp,32
    80002c02:	8082                	ret
    panic("usertrap: not from user mode");
    80002c04:	00005517          	auipc	a0,0x5
    80002c08:	71c50513          	addi	a0,a0,1820 # 80008320 <states.0+0x58>
    80002c0c:	ffffe097          	auipc	ra,0xffffe
    80002c10:	932080e7          	jalr	-1742(ra) # 8000053e <panic>
    if (killed(p))
    80002c14:	00000097          	auipc	ra,0x0
    80002c18:	8dc080e7          	jalr	-1828(ra) # 800024f0 <killed>
    80002c1c:	ed05                	bnez	a0,80002c54 <usertrap+0xc6>
    p->trapframe->epc += 4;
    80002c1e:	6cb8                	ld	a4,88(s1)
    80002c20:	6f1c                	ld	a5,24(a4)
    80002c22:	0791                	addi	a5,a5,4
    80002c24:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c26:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c2a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c2e:	10079073          	csrw	sstatus,a5
    syscall();
    80002c32:	00000097          	auipc	ra,0x0
    80002c36:	31e080e7          	jalr	798(ra) # 80002f50 <syscall>
  if (killed(p))
    80002c3a:	8526                	mv	a0,s1
    80002c3c:	00000097          	auipc	ra,0x0
    80002c40:	8b4080e7          	jalr	-1868(ra) # 800024f0 <killed>
    80002c44:	d555                	beqz	a0,80002bf0 <usertrap+0x62>
    80002c46:	4901                	li	s2,0
    exit(-1);
    80002c48:	557d                	li	a0,-1
    80002c4a:	fffff097          	auipc	ra,0xfffff
    80002c4e:	726080e7          	jalr	1830(ra) # 80002370 <exit>
  if (which_dev == 2)
    80002c52:	bf61                	j	80002bea <usertrap+0x5c>
      exit(-1);
    80002c54:	557d                	li	a0,-1
    80002c56:	fffff097          	auipc	ra,0xfffff
    80002c5a:	71a080e7          	jalr	1818(ra) # 80002370 <exit>
    80002c5e:	b7c1                	j	80002c1e <usertrap+0x90>
    if (which_dev == 2 && p->alarm_state == 0)
    80002c60:	2104a783          	lw	a5,528(s1)
    80002c64:	ef81                	bnez	a5,80002c7c <usertrap+0xee>
      p->ticks++;
    80002c66:	2004a783          	lw	a5,512(s1)
    80002c6a:	2785                	addiw	a5,a5,1
    80002c6c:	0007871b          	sext.w	a4,a5
    80002c70:	20f4a023          	sw	a5,512(s1)
      if (p->ticks == p->total_ticks)
    80002c74:	2044a783          	lw	a5,516(s1)
    80002c78:	02e78263          	beq	a5,a4,80002c9c <usertrap+0x10e>
  if (killed(p))
    80002c7c:	8526                	mv	a0,s1
    80002c7e:	00000097          	auipc	ra,0x0
    80002c82:	872080e7          	jalr	-1934(ra) # 800024f0 <killed>
    80002c86:	c511                	beqz	a0,80002c92 <usertrap+0x104>
    exit(-1);
    80002c88:	557d                	li	a0,-1
    80002c8a:	fffff097          	auipc	ra,0xfffff
    80002c8e:	6e6080e7          	jalr	1766(ra) # 80002370 <exit>
    yield();
    80002c92:	fffff097          	auipc	ra,0xfffff
    80002c96:	552080e7          	jalr	1362(ra) # 800021e4 <yield>
    80002c9a:	bf99                	j	80002bf0 <usertrap+0x62>
        memmove(p->backup, p->trapframe, sizeof(struct trapframe));
    80002c9c:	12000613          	li	a2,288
    80002ca0:	6cac                	ld	a1,88(s1)
    80002ca2:	1f84b503          	ld	a0,504(s1)
    80002ca6:	ffffe097          	auipc	ra,0xffffe
    80002caa:	088080e7          	jalr	136(ra) # 80000d2e <memmove>
        p->alarm_state = 1;
    80002cae:	4785                	li	a5,1
    80002cb0:	20f4a823          	sw	a5,528(s1)
        p->ticks = 0;
    80002cb4:	2004a023          	sw	zero,512(s1)
        p->trapframe->epc = p->handler;
    80002cb8:	6cbc                	ld	a5,88(s1)
    80002cba:	2084b703          	ld	a4,520(s1)
    80002cbe:	ef98                	sd	a4,24(a5)
    80002cc0:	bf75                	j	80002c7c <usertrap+0xee>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cc2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002cc6:	5890                	lw	a2,48(s1)
    80002cc8:	00005517          	auipc	a0,0x5
    80002ccc:	67850513          	addi	a0,a0,1656 # 80008340 <states.0+0x78>
    80002cd0:	ffffe097          	auipc	ra,0xffffe
    80002cd4:	8b8080e7          	jalr	-1864(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cd8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cdc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ce0:	00005517          	auipc	a0,0x5
    80002ce4:	69050513          	addi	a0,a0,1680 # 80008370 <states.0+0xa8>
    80002ce8:	ffffe097          	auipc	ra,0xffffe
    80002cec:	8a0080e7          	jalr	-1888(ra) # 80000588 <printf>
    setkilled(p);
    80002cf0:	8526                	mv	a0,s1
    80002cf2:	fffff097          	auipc	ra,0xfffff
    80002cf6:	7d2080e7          	jalr	2002(ra) # 800024c4 <setkilled>
    80002cfa:	b781                	j	80002c3a <usertrap+0xac>
    yield();
    80002cfc:	fffff097          	auipc	ra,0xfffff
    80002d00:	4e8080e7          	jalr	1256(ra) # 800021e4 <yield>
    80002d04:	b5f5                	j	80002bf0 <usertrap+0x62>

0000000080002d06 <kerneltrap>:
{
    80002d06:	7179                	addi	sp,sp,-48
    80002d08:	f406                	sd	ra,40(sp)
    80002d0a:	f022                	sd	s0,32(sp)
    80002d0c:	ec26                	sd	s1,24(sp)
    80002d0e:	e84a                	sd	s2,16(sp)
    80002d10:	e44e                	sd	s3,8(sp)
    80002d12:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d14:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d18:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d1c:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002d20:	1004f793          	andi	a5,s1,256
    80002d24:	cb85                	beqz	a5,80002d54 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d2a:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002d2c:	ef85                	bnez	a5,80002d64 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002d2e:	00000097          	auipc	ra,0x0
    80002d32:	dbe080e7          	jalr	-578(ra) # 80002aec <devintr>
    80002d36:	cd1d                	beqz	a0,80002d74 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d38:	4789                	li	a5,2
    80002d3a:	06f50a63          	beq	a0,a5,80002dae <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d3e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d42:	10049073          	csrw	sstatus,s1
}
    80002d46:	70a2                	ld	ra,40(sp)
    80002d48:	7402                	ld	s0,32(sp)
    80002d4a:	64e2                	ld	s1,24(sp)
    80002d4c:	6942                	ld	s2,16(sp)
    80002d4e:	69a2                	ld	s3,8(sp)
    80002d50:	6145                	addi	sp,sp,48
    80002d52:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d54:	00005517          	auipc	a0,0x5
    80002d58:	63c50513          	addi	a0,a0,1596 # 80008390 <states.0+0xc8>
    80002d5c:	ffffd097          	auipc	ra,0xffffd
    80002d60:	7e2080e7          	jalr	2018(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002d64:	00005517          	auipc	a0,0x5
    80002d68:	65450513          	addi	a0,a0,1620 # 800083b8 <states.0+0xf0>
    80002d6c:	ffffd097          	auipc	ra,0xffffd
    80002d70:	7d2080e7          	jalr	2002(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002d74:	85ce                	mv	a1,s3
    80002d76:	00005517          	auipc	a0,0x5
    80002d7a:	66250513          	addi	a0,a0,1634 # 800083d8 <states.0+0x110>
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	80a080e7          	jalr	-2038(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d86:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d8a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d8e:	00005517          	auipc	a0,0x5
    80002d92:	65a50513          	addi	a0,a0,1626 # 800083e8 <states.0+0x120>
    80002d96:	ffffd097          	auipc	ra,0xffffd
    80002d9a:	7f2080e7          	jalr	2034(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002d9e:	00005517          	auipc	a0,0x5
    80002da2:	66250513          	addi	a0,a0,1634 # 80008400 <states.0+0x138>
    80002da6:	ffffd097          	auipc	ra,0xffffd
    80002daa:	798080e7          	jalr	1944(ra) # 8000053e <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002dae:	fffff097          	auipc	ra,0xfffff
    80002db2:	c3c080e7          	jalr	-964(ra) # 800019ea <myproc>
    80002db6:	d541                	beqz	a0,80002d3e <kerneltrap+0x38>
    80002db8:	fffff097          	auipc	ra,0xfffff
    80002dbc:	c32080e7          	jalr	-974(ra) # 800019ea <myproc>
    80002dc0:	4d18                	lw	a4,24(a0)
    80002dc2:	4791                	li	a5,4
    80002dc4:	f6f71de3          	bne	a4,a5,80002d3e <kerneltrap+0x38>
    yield();
    80002dc8:	fffff097          	auipc	ra,0xfffff
    80002dcc:	41c080e7          	jalr	1052(ra) # 800021e4 <yield>
    80002dd0:	b7bd                	j	80002d3e <kerneltrap+0x38>

0000000080002dd2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002dd2:	1101                	addi	sp,sp,-32
    80002dd4:	ec06                	sd	ra,24(sp)
    80002dd6:	e822                	sd	s0,16(sp)
    80002dd8:	e426                	sd	s1,8(sp)
    80002dda:	1000                	addi	s0,sp,32
    80002ddc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002dde:	fffff097          	auipc	ra,0xfffff
    80002de2:	c0c080e7          	jalr	-1012(ra) # 800019ea <myproc>
  switch (n) {
    80002de6:	4795                	li	a5,5
    80002de8:	0497e163          	bltu	a5,s1,80002e2a <argraw+0x58>
    80002dec:	048a                	slli	s1,s1,0x2
    80002dee:	00005717          	auipc	a4,0x5
    80002df2:	64a70713          	addi	a4,a4,1610 # 80008438 <states.0+0x170>
    80002df6:	94ba                	add	s1,s1,a4
    80002df8:	409c                	lw	a5,0(s1)
    80002dfa:	97ba                	add	a5,a5,a4
    80002dfc:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002dfe:	6d3c                	ld	a5,88(a0)
    80002e00:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e02:	60e2                	ld	ra,24(sp)
    80002e04:	6442                	ld	s0,16(sp)
    80002e06:	64a2                	ld	s1,8(sp)
    80002e08:	6105                	addi	sp,sp,32
    80002e0a:	8082                	ret
    return p->trapframe->a1;
    80002e0c:	6d3c                	ld	a5,88(a0)
    80002e0e:	7fa8                	ld	a0,120(a5)
    80002e10:	bfcd                	j	80002e02 <argraw+0x30>
    return p->trapframe->a2;
    80002e12:	6d3c                	ld	a5,88(a0)
    80002e14:	63c8                	ld	a0,128(a5)
    80002e16:	b7f5                	j	80002e02 <argraw+0x30>
    return p->trapframe->a3;
    80002e18:	6d3c                	ld	a5,88(a0)
    80002e1a:	67c8                	ld	a0,136(a5)
    80002e1c:	b7dd                	j	80002e02 <argraw+0x30>
    return p->trapframe->a4;
    80002e1e:	6d3c                	ld	a5,88(a0)
    80002e20:	6bc8                	ld	a0,144(a5)
    80002e22:	b7c5                	j	80002e02 <argraw+0x30>
    return p->trapframe->a5;
    80002e24:	6d3c                	ld	a5,88(a0)
    80002e26:	6fc8                	ld	a0,152(a5)
    80002e28:	bfe9                	j	80002e02 <argraw+0x30>
  panic("argraw");
    80002e2a:	00005517          	auipc	a0,0x5
    80002e2e:	5e650513          	addi	a0,a0,1510 # 80008410 <states.0+0x148>
    80002e32:	ffffd097          	auipc	ra,0xffffd
    80002e36:	70c080e7          	jalr	1804(ra) # 8000053e <panic>

0000000080002e3a <fetchaddr>:
{
    80002e3a:	1101                	addi	sp,sp,-32
    80002e3c:	ec06                	sd	ra,24(sp)
    80002e3e:	e822                	sd	s0,16(sp)
    80002e40:	e426                	sd	s1,8(sp)
    80002e42:	e04a                	sd	s2,0(sp)
    80002e44:	1000                	addi	s0,sp,32
    80002e46:	84aa                	mv	s1,a0
    80002e48:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e4a:	fffff097          	auipc	ra,0xfffff
    80002e4e:	ba0080e7          	jalr	-1120(ra) # 800019ea <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002e52:	653c                	ld	a5,72(a0)
    80002e54:	02f4f863          	bgeu	s1,a5,80002e84 <fetchaddr+0x4a>
    80002e58:	00848713          	addi	a4,s1,8
    80002e5c:	02e7e663          	bltu	a5,a4,80002e88 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e60:	46a1                	li	a3,8
    80002e62:	8626                	mv	a2,s1
    80002e64:	85ca                	mv	a1,s2
    80002e66:	6928                	ld	a0,80(a0)
    80002e68:	fffff097          	auipc	ra,0xfffff
    80002e6c:	88c080e7          	jalr	-1908(ra) # 800016f4 <copyin>
    80002e70:	00a03533          	snez	a0,a0
    80002e74:	40a00533          	neg	a0,a0
}
    80002e78:	60e2                	ld	ra,24(sp)
    80002e7a:	6442                	ld	s0,16(sp)
    80002e7c:	64a2                	ld	s1,8(sp)
    80002e7e:	6902                	ld	s2,0(sp)
    80002e80:	6105                	addi	sp,sp,32
    80002e82:	8082                	ret
    return -1;
    80002e84:	557d                	li	a0,-1
    80002e86:	bfcd                	j	80002e78 <fetchaddr+0x3e>
    80002e88:	557d                	li	a0,-1
    80002e8a:	b7fd                	j	80002e78 <fetchaddr+0x3e>

0000000080002e8c <fetchstr>:
{
    80002e8c:	7179                	addi	sp,sp,-48
    80002e8e:	f406                	sd	ra,40(sp)
    80002e90:	f022                	sd	s0,32(sp)
    80002e92:	ec26                	sd	s1,24(sp)
    80002e94:	e84a                	sd	s2,16(sp)
    80002e96:	e44e                	sd	s3,8(sp)
    80002e98:	1800                	addi	s0,sp,48
    80002e9a:	892a                	mv	s2,a0
    80002e9c:	84ae                	mv	s1,a1
    80002e9e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	b4a080e7          	jalr	-1206(ra) # 800019ea <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002ea8:	86ce                	mv	a3,s3
    80002eaa:	864a                	mv	a2,s2
    80002eac:	85a6                	mv	a1,s1
    80002eae:	6928                	ld	a0,80(a0)
    80002eb0:	fffff097          	auipc	ra,0xfffff
    80002eb4:	8d2080e7          	jalr	-1838(ra) # 80001782 <copyinstr>
    80002eb8:	00054e63          	bltz	a0,80002ed4 <fetchstr+0x48>
  return strlen(buf);
    80002ebc:	8526                	mv	a0,s1
    80002ebe:	ffffe097          	auipc	ra,0xffffe
    80002ec2:	f90080e7          	jalr	-112(ra) # 80000e4e <strlen>
}
    80002ec6:	70a2                	ld	ra,40(sp)
    80002ec8:	7402                	ld	s0,32(sp)
    80002eca:	64e2                	ld	s1,24(sp)
    80002ecc:	6942                	ld	s2,16(sp)
    80002ece:	69a2                	ld	s3,8(sp)
    80002ed0:	6145                	addi	sp,sp,48
    80002ed2:	8082                	ret
    return -1;
    80002ed4:	557d                	li	a0,-1
    80002ed6:	bfc5                	j	80002ec6 <fetchstr+0x3a>

0000000080002ed8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ed8:	1101                	addi	sp,sp,-32
    80002eda:	ec06                	sd	ra,24(sp)
    80002edc:	e822                	sd	s0,16(sp)
    80002ede:	e426                	sd	s1,8(sp)
    80002ee0:	1000                	addi	s0,sp,32
    80002ee2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ee4:	00000097          	auipc	ra,0x0
    80002ee8:	eee080e7          	jalr	-274(ra) # 80002dd2 <argraw>
    80002eec:	c088                	sw	a0,0(s1)
}
    80002eee:	60e2                	ld	ra,24(sp)
    80002ef0:	6442                	ld	s0,16(sp)
    80002ef2:	64a2                	ld	s1,8(sp)
    80002ef4:	6105                	addi	sp,sp,32
    80002ef6:	8082                	ret

0000000080002ef8 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ef8:	1101                	addi	sp,sp,-32
    80002efa:	ec06                	sd	ra,24(sp)
    80002efc:	e822                	sd	s0,16(sp)
    80002efe:	e426                	sd	s1,8(sp)
    80002f00:	1000                	addi	s0,sp,32
    80002f02:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f04:	00000097          	auipc	ra,0x0
    80002f08:	ece080e7          	jalr	-306(ra) # 80002dd2 <argraw>
    80002f0c:	e088                	sd	a0,0(s1)
}
    80002f0e:	60e2                	ld	ra,24(sp)
    80002f10:	6442                	ld	s0,16(sp)
    80002f12:	64a2                	ld	s1,8(sp)
    80002f14:	6105                	addi	sp,sp,32
    80002f16:	8082                	ret

0000000080002f18 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002f18:	7179                	addi	sp,sp,-48
    80002f1a:	f406                	sd	ra,40(sp)
    80002f1c:	f022                	sd	s0,32(sp)
    80002f1e:	ec26                	sd	s1,24(sp)
    80002f20:	e84a                	sd	s2,16(sp)
    80002f22:	1800                	addi	s0,sp,48
    80002f24:	84ae                	mv	s1,a1
    80002f26:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002f28:	fd840593          	addi	a1,s0,-40
    80002f2c:	00000097          	auipc	ra,0x0
    80002f30:	fcc080e7          	jalr	-52(ra) # 80002ef8 <argaddr>
  return fetchstr(addr, buf, max);
    80002f34:	864a                	mv	a2,s2
    80002f36:	85a6                	mv	a1,s1
    80002f38:	fd843503          	ld	a0,-40(s0)
    80002f3c:	00000097          	auipc	ra,0x0
    80002f40:	f50080e7          	jalr	-176(ra) # 80002e8c <fetchstr>
}
    80002f44:	70a2                	ld	ra,40(sp)
    80002f46:	7402                	ld	s0,32(sp)
    80002f48:	64e2                	ld	s1,24(sp)
    80002f4a:	6942                	ld	s2,16(sp)
    80002f4c:	6145                	addi	sp,sp,48
    80002f4e:	8082                	ret

0000000080002f50 <syscall>:
[SYS_settickets] sys_settickets,
};

void
syscall(void)
{
    80002f50:	7179                	addi	sp,sp,-48
    80002f52:	f406                	sd	ra,40(sp)
    80002f54:	f022                	sd	s0,32(sp)
    80002f56:	ec26                	sd	s1,24(sp)
    80002f58:	e84a                	sd	s2,16(sp)
    80002f5a:	e44e                	sd	s3,8(sp)
    80002f5c:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002f5e:	fffff097          	auipc	ra,0xfffff
    80002f62:	a8c080e7          	jalr	-1396(ra) # 800019ea <myproc>
    80002f66:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002f68:	05853983          	ld	s3,88(a0)
    80002f6c:	0a89b783          	ld	a5,168(s3)
    80002f70:	0007891b          	sext.w	s2,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f74:	37fd                	addiw	a5,a5,-1
    80002f76:	4765                	li	a4,25
    80002f78:	02f76663          	bltu	a4,a5,80002fa4 <syscall+0x54>
    80002f7c:	00391713          	slli	a4,s2,0x3
    80002f80:	00005797          	auipc	a5,0x5
    80002f84:	4d078793          	addi	a5,a5,1232 # 80008450 <syscalls>
    80002f88:	97ba                	add	a5,a5,a4
    80002f8a:	639c                	ld	a5,0(a5)
    80002f8c:	cf81                	beqz	a5,80002fa4 <syscall+0x54>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002f8e:	9782                	jalr	a5
    80002f90:	06a9b823          	sd	a0,112(s3)
    p->syscall_cnt[num]++;
    80002f94:	090a                	slli	s2,s2,0x2
    80002f96:	94ca                	add	s1,s1,s2
    80002f98:	1744a783          	lw	a5,372(s1)
    80002f9c:	2785                	addiw	a5,a5,1
    80002f9e:	16f4aa23          	sw	a5,372(s1)
    80002fa2:	a005                	j	80002fc2 <syscall+0x72>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002fa4:	86ca                	mv	a3,s2
    80002fa6:	15848613          	addi	a2,s1,344
    80002faa:	588c                	lw	a1,48(s1)
    80002fac:	00005517          	auipc	a0,0x5
    80002fb0:	46c50513          	addi	a0,a0,1132 # 80008418 <states.0+0x150>
    80002fb4:	ffffd097          	auipc	ra,0xffffd
    80002fb8:	5d4080e7          	jalr	1492(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002fbc:	6cbc                	ld	a5,88(s1)
    80002fbe:	577d                	li	a4,-1
    80002fc0:	fbb8                	sd	a4,112(a5)
  }
}
    80002fc2:	70a2                	ld	ra,40(sp)
    80002fc4:	7402                	ld	s0,32(sp)
    80002fc6:	64e2                	ld	s1,24(sp)
    80002fc8:	6942                	ld	s2,16(sp)
    80002fca:	69a2                	ld	s3,8(sp)
    80002fcc:	6145                	addi	sp,sp,48
    80002fce:	8082                	ret

0000000080002fd0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002fd0:	1101                	addi	sp,sp,-32
    80002fd2:	ec06                	sd	ra,24(sp)
    80002fd4:	e822                	sd	s0,16(sp)
    80002fd6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002fd8:	fec40593          	addi	a1,s0,-20
    80002fdc:	4501                	li	a0,0
    80002fde:	00000097          	auipc	ra,0x0
    80002fe2:	efa080e7          	jalr	-262(ra) # 80002ed8 <argint>
  struct proc *p = myproc();
    80002fe6:	fffff097          	auipc	ra,0xfffff
    80002fea:	a04080e7          	jalr	-1532(ra) # 800019ea <myproc>
  struct proc *parent = p->parent;
    80002fee:	7d0c                	ld	a1,56(a0)
  if (p != 0 && parent != 0)
    80002ff0:	cd99                	beqz	a1,8000300e <sys_exit+0x3e>
    80002ff2:	17458793          	addi	a5,a1,372 # 1174 <_entry-0x7fffee8c>
    80002ff6:	17450693          	addi	a3,a0,372
    80002ffa:	1f458593          	addi	a1,a1,500
  {
    for (int i = 0; i < 32; i++)
    {
      parent->syscall_cnt[i] += p->syscall_cnt[i];
    80002ffe:	4398                	lw	a4,0(a5)
    80003000:	4290                	lw	a2,0(a3)
    80003002:	9f31                	addw	a4,a4,a2
    80003004:	c398                	sw	a4,0(a5)
    for (int i = 0; i < 32; i++)
    80003006:	0791                	addi	a5,a5,4
    80003008:	0691                	addi	a3,a3,4
    8000300a:	feb79ae3          	bne	a5,a1,80002ffe <sys_exit+0x2e>
    }
  }
  exit(n);
    8000300e:	fec42503          	lw	a0,-20(s0)
    80003012:	fffff097          	auipc	ra,0xfffff
    80003016:	35e080e7          	jalr	862(ra) # 80002370 <exit>
  return 0; // not reached
}
    8000301a:	4501                	li	a0,0
    8000301c:	60e2                	ld	ra,24(sp)
    8000301e:	6442                	ld	s0,16(sp)
    80003020:	6105                	addi	sp,sp,32
    80003022:	8082                	ret

0000000080003024 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003024:	1141                	addi	sp,sp,-16
    80003026:	e406                	sd	ra,8(sp)
    80003028:	e022                	sd	s0,0(sp)
    8000302a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000302c:	fffff097          	auipc	ra,0xfffff
    80003030:	9be080e7          	jalr	-1602(ra) # 800019ea <myproc>
}
    80003034:	5908                	lw	a0,48(a0)
    80003036:	60a2                	ld	ra,8(sp)
    80003038:	6402                	ld	s0,0(sp)
    8000303a:	0141                	addi	sp,sp,16
    8000303c:	8082                	ret

000000008000303e <sys_fork>:

uint64
sys_fork(void)
{
    8000303e:	1141                	addi	sp,sp,-16
    80003040:	e406                	sd	ra,8(sp)
    80003042:	e022                	sd	s0,0(sp)
    80003044:	0800                	addi	s0,sp,16
  return fork();
    80003046:	fffff097          	auipc	ra,0xfffff
    8000304a:	de4080e7          	jalr	-540(ra) # 80001e2a <fork>
}
    8000304e:	60a2                	ld	ra,8(sp)
    80003050:	6402                	ld	s0,0(sp)
    80003052:	0141                	addi	sp,sp,16
    80003054:	8082                	ret

0000000080003056 <sys_wait>:

uint64
sys_wait(void)
{
    80003056:	1101                	addi	sp,sp,-32
    80003058:	ec06                	sd	ra,24(sp)
    8000305a:	e822                	sd	s0,16(sp)
    8000305c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000305e:	fe840593          	addi	a1,s0,-24
    80003062:	4501                	li	a0,0
    80003064:	00000097          	auipc	ra,0x0
    80003068:	e94080e7          	jalr	-364(ra) # 80002ef8 <argaddr>
  return wait(p);
    8000306c:	fe843503          	ld	a0,-24(s0)
    80003070:	fffff097          	auipc	ra,0xfffff
    80003074:	4b2080e7          	jalr	1202(ra) # 80002522 <wait>
}
    80003078:	60e2                	ld	ra,24(sp)
    8000307a:	6442                	ld	s0,16(sp)
    8000307c:	6105                	addi	sp,sp,32
    8000307e:	8082                	ret

0000000080003080 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003080:	7179                	addi	sp,sp,-48
    80003082:	f406                	sd	ra,40(sp)
    80003084:	f022                	sd	s0,32(sp)
    80003086:	ec26                	sd	s1,24(sp)
    80003088:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000308a:	fdc40593          	addi	a1,s0,-36
    8000308e:	4501                	li	a0,0
    80003090:	00000097          	auipc	ra,0x0
    80003094:	e48080e7          	jalr	-440(ra) # 80002ed8 <argint>
  addr = myproc()->sz;
    80003098:	fffff097          	auipc	ra,0xfffff
    8000309c:	952080e7          	jalr	-1710(ra) # 800019ea <myproc>
    800030a0:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    800030a2:	fdc42503          	lw	a0,-36(s0)
    800030a6:	fffff097          	auipc	ra,0xfffff
    800030aa:	d28080e7          	jalr	-728(ra) # 80001dce <growproc>
    800030ae:	00054863          	bltz	a0,800030be <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800030b2:	8526                	mv	a0,s1
    800030b4:	70a2                	ld	ra,40(sp)
    800030b6:	7402                	ld	s0,32(sp)
    800030b8:	64e2                	ld	s1,24(sp)
    800030ba:	6145                	addi	sp,sp,48
    800030bc:	8082                	ret
    return -1;
    800030be:	54fd                	li	s1,-1
    800030c0:	bfcd                	j	800030b2 <sys_sbrk+0x32>

00000000800030c2 <sys_sleep>:

uint64
sys_sleep(void)
{
    800030c2:	7139                	addi	sp,sp,-64
    800030c4:	fc06                	sd	ra,56(sp)
    800030c6:	f822                	sd	s0,48(sp)
    800030c8:	f426                	sd	s1,40(sp)
    800030ca:	f04a                	sd	s2,32(sp)
    800030cc:	ec4e                	sd	s3,24(sp)
    800030ce:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800030d0:	fcc40593          	addi	a1,s0,-52
    800030d4:	4501                	li	a0,0
    800030d6:	00000097          	auipc	ra,0x0
    800030da:	e02080e7          	jalr	-510(ra) # 80002ed8 <argint>
  acquire(&tickslock);
    800030de:	00016517          	auipc	a0,0x16
    800030e2:	6c250513          	addi	a0,a0,1730 # 800197a0 <tickslock>
    800030e6:	ffffe097          	auipc	ra,0xffffe
    800030ea:	af0080e7          	jalr	-1296(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    800030ee:	00006917          	auipc	s2,0x6
    800030f2:	81a92903          	lw	s2,-2022(s2) # 80008908 <ticks>
  while (ticks - ticks0 < n)
    800030f6:	fcc42783          	lw	a5,-52(s0)
    800030fa:	cf9d                	beqz	a5,80003138 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800030fc:	00016997          	auipc	s3,0x16
    80003100:	6a498993          	addi	s3,s3,1700 # 800197a0 <tickslock>
    80003104:	00006497          	auipc	s1,0x6
    80003108:	80448493          	addi	s1,s1,-2044 # 80008908 <ticks>
    if (killed(myproc()))
    8000310c:	fffff097          	auipc	ra,0xfffff
    80003110:	8de080e7          	jalr	-1826(ra) # 800019ea <myproc>
    80003114:	fffff097          	auipc	ra,0xfffff
    80003118:	3dc080e7          	jalr	988(ra) # 800024f0 <killed>
    8000311c:	ed15                	bnez	a0,80003158 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000311e:	85ce                	mv	a1,s3
    80003120:	8526                	mv	a0,s1
    80003122:	fffff097          	auipc	ra,0xfffff
    80003126:	0fe080e7          	jalr	254(ra) # 80002220 <sleep>
  while (ticks - ticks0 < n)
    8000312a:	409c                	lw	a5,0(s1)
    8000312c:	412787bb          	subw	a5,a5,s2
    80003130:	fcc42703          	lw	a4,-52(s0)
    80003134:	fce7ece3          	bltu	a5,a4,8000310c <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003138:	00016517          	auipc	a0,0x16
    8000313c:	66850513          	addi	a0,a0,1640 # 800197a0 <tickslock>
    80003140:	ffffe097          	auipc	ra,0xffffe
    80003144:	b4a080e7          	jalr	-1206(ra) # 80000c8a <release>
  return 0;
    80003148:	4501                	li	a0,0
}
    8000314a:	70e2                	ld	ra,56(sp)
    8000314c:	7442                	ld	s0,48(sp)
    8000314e:	74a2                	ld	s1,40(sp)
    80003150:	7902                	ld	s2,32(sp)
    80003152:	69e2                	ld	s3,24(sp)
    80003154:	6121                	addi	sp,sp,64
    80003156:	8082                	ret
      release(&tickslock);
    80003158:	00016517          	auipc	a0,0x16
    8000315c:	64850513          	addi	a0,a0,1608 # 800197a0 <tickslock>
    80003160:	ffffe097          	auipc	ra,0xffffe
    80003164:	b2a080e7          	jalr	-1238(ra) # 80000c8a <release>
      return -1;
    80003168:	557d                	li	a0,-1
    8000316a:	b7c5                	j	8000314a <sys_sleep+0x88>

000000008000316c <sys_kill>:

uint64
sys_kill(void)
{
    8000316c:	1101                	addi	sp,sp,-32
    8000316e:	ec06                	sd	ra,24(sp)
    80003170:	e822                	sd	s0,16(sp)
    80003172:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003174:	fec40593          	addi	a1,s0,-20
    80003178:	4501                	li	a0,0
    8000317a:	00000097          	auipc	ra,0x0
    8000317e:	d5e080e7          	jalr	-674(ra) # 80002ed8 <argint>
  return kill(pid);
    80003182:	fec42503          	lw	a0,-20(s0)
    80003186:	fffff097          	auipc	ra,0xfffff
    8000318a:	2cc080e7          	jalr	716(ra) # 80002452 <kill>
}
    8000318e:	60e2                	ld	ra,24(sp)
    80003190:	6442                	ld	s0,16(sp)
    80003192:	6105                	addi	sp,sp,32
    80003194:	8082                	ret

0000000080003196 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003196:	1101                	addi	sp,sp,-32
    80003198:	ec06                	sd	ra,24(sp)
    8000319a:	e822                	sd	s0,16(sp)
    8000319c:	e426                	sd	s1,8(sp)
    8000319e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800031a0:	00016517          	auipc	a0,0x16
    800031a4:	60050513          	addi	a0,a0,1536 # 800197a0 <tickslock>
    800031a8:	ffffe097          	auipc	ra,0xffffe
    800031ac:	a2e080e7          	jalr	-1490(ra) # 80000bd6 <acquire>
  xticks = ticks;
    800031b0:	00005497          	auipc	s1,0x5
    800031b4:	7584a483          	lw	s1,1880(s1) # 80008908 <ticks>
  release(&tickslock);
    800031b8:	00016517          	auipc	a0,0x16
    800031bc:	5e850513          	addi	a0,a0,1512 # 800197a0 <tickslock>
    800031c0:	ffffe097          	auipc	ra,0xffffe
    800031c4:	aca080e7          	jalr	-1334(ra) # 80000c8a <release>
  return xticks;
}
    800031c8:	02049513          	slli	a0,s1,0x20
    800031cc:	9101                	srli	a0,a0,0x20
    800031ce:	60e2                	ld	ra,24(sp)
    800031d0:	6442                	ld	s0,16(sp)
    800031d2:	64a2                	ld	s1,8(sp)
    800031d4:	6105                	addi	sp,sp,32
    800031d6:	8082                	ret

00000000800031d8 <sys_waitx>:

uint64
sys_waitx(void)
{
    800031d8:	7139                	addi	sp,sp,-64
    800031da:	fc06                	sd	ra,56(sp)
    800031dc:	f822                	sd	s0,48(sp)
    800031de:	f426                	sd	s1,40(sp)
    800031e0:	f04a                	sd	s2,32(sp)
    800031e2:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800031e4:	fd840593          	addi	a1,s0,-40
    800031e8:	4501                	li	a0,0
    800031ea:	00000097          	auipc	ra,0x0
    800031ee:	d0e080e7          	jalr	-754(ra) # 80002ef8 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800031f2:	fd040593          	addi	a1,s0,-48
    800031f6:	4505                	li	a0,1
    800031f8:	00000097          	auipc	ra,0x0
    800031fc:	d00080e7          	jalr	-768(ra) # 80002ef8 <argaddr>
  argaddr(2, &addr2);
    80003200:	fc840593          	addi	a1,s0,-56
    80003204:	4509                	li	a0,2
    80003206:	00000097          	auipc	ra,0x0
    8000320a:	cf2080e7          	jalr	-782(ra) # 80002ef8 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    8000320e:	fc040613          	addi	a2,s0,-64
    80003212:	fc440593          	addi	a1,s0,-60
    80003216:	fd843503          	ld	a0,-40(s0)
    8000321a:	fffff097          	auipc	ra,0xfffff
    8000321e:	594080e7          	jalr	1428(ra) # 800027ae <waitx>
    80003222:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003224:	ffffe097          	auipc	ra,0xffffe
    80003228:	7c6080e7          	jalr	1990(ra) # 800019ea <myproc>
    8000322c:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000322e:	4691                	li	a3,4
    80003230:	fc440613          	addi	a2,s0,-60
    80003234:	fd043583          	ld	a1,-48(s0)
    80003238:	6928                	ld	a0,80(a0)
    8000323a:	ffffe097          	auipc	ra,0xffffe
    8000323e:	42e080e7          	jalr	1070(ra) # 80001668 <copyout>
    return -1;
    80003242:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003244:	00054f63          	bltz	a0,80003262 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003248:	4691                	li	a3,4
    8000324a:	fc040613          	addi	a2,s0,-64
    8000324e:	fc843583          	ld	a1,-56(s0)
    80003252:	68a8                	ld	a0,80(s1)
    80003254:	ffffe097          	auipc	ra,0xffffe
    80003258:	414080e7          	jalr	1044(ra) # 80001668 <copyout>
    8000325c:	00054a63          	bltz	a0,80003270 <sys_waitx+0x98>
    return -1;
  return ret;
    80003260:	87ca                	mv	a5,s2
}
    80003262:	853e                	mv	a0,a5
    80003264:	70e2                	ld	ra,56(sp)
    80003266:	7442                	ld	s0,48(sp)
    80003268:	74a2                	ld	s1,40(sp)
    8000326a:	7902                	ld	s2,32(sp)
    8000326c:	6121                	addi	sp,sp,64
    8000326e:	8082                	ret
    return -1;
    80003270:	57fd                	li	a5,-1
    80003272:	bfc5                	j	80003262 <sys_waitx+0x8a>

0000000080003274 <sys_getSysCount>:

uint64 sys_getSysCount(void)
{
    80003274:	7179                	addi	sp,sp,-48
    80003276:	f406                	sd	ra,40(sp)
    80003278:	f022                	sd	s0,32(sp)
    8000327a:	ec26                	sd	s1,24(sp)
    8000327c:	1800                	addi	s0,sp,48
  int mask, syscall_index;
  struct proc *p = myproc();
    8000327e:	ffffe097          	auipc	ra,0xffffe
    80003282:	76c080e7          	jalr	1900(ra) # 800019ea <myproc>
    80003286:	84aa                	mv	s1,a0
  argint(0, &mask);
    80003288:	fdc40593          	addi	a1,s0,-36
    8000328c:	4501                	li	a0,0
    8000328e:	00000097          	auipc	ra,0x0
    80003292:	c4a080e7          	jalr	-950(ra) # 80002ed8 <argint>
  if (mask == 0 || (mask & (mask - 1)) != 0)
    80003296:	fdc42783          	lw	a5,-36(s0)
    return -1; // Invalid mask, not a power of 2
    8000329a:	557d                	li	a0,-1
  if (mask == 0 || (mask & (mask - 1)) != 0)
    8000329c:	cb95                	beqz	a5,800032d0 <sys_getSysCount+0x5c>
    8000329e:	fff7871b          	addiw	a4,a5,-1
    800032a2:	8f7d                	and	a4,a4,a5
    800032a4:	2701                	sext.w	a4,a4
    800032a6:	e70d                	bnez	a4,800032d0 <sys_getSysCount+0x5c>

  // Find the index of the syscall corresponding to the mask
  syscall_index = 0;
  while (mask > 1)
    800032a8:	4685                	li	a3,1
    800032aa:	00f6dd63          	bge	a3,a5,800032c4 <sys_getSysCount+0x50>
  {
    syscall_index++;
    800032ae:	2705                	addiw	a4,a4,1
    mask >>= 1;
    800032b0:	4017d79b          	sraiw	a5,a5,0x1
  while (mask > 1)
    800032b4:	fef6cde3          	blt	a3,a5,800032ae <sys_getSysCount+0x3a>
    800032b8:	fcf42e23          	sw	a5,-36(s0)
  }

  if (syscall_index >= 32)
    800032bc:	47fd                	li	a5,31
    return -1;
    800032be:	557d                	li	a0,-1
  if (syscall_index >= 32)
    800032c0:	00e7c863          	blt	a5,a4,800032d0 <sys_getSysCount+0x5c>

  return p->syscall_cnt[syscall_index];
    800032c4:	05c70713          	addi	a4,a4,92
    800032c8:	070a                	slli	a4,a4,0x2
    800032ca:	00e48533          	add	a0,s1,a4
    800032ce:	4148                	lw	a0,4(a0)
}
    800032d0:	70a2                	ld	ra,40(sp)
    800032d2:	7402                	ld	s0,32(sp)
    800032d4:	64e2                	ld	s1,24(sp)
    800032d6:	6145                	addi	sp,sp,48
    800032d8:	8082                	ret

00000000800032da <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    800032da:	1101                	addi	sp,sp,-32
    800032dc:	ec06                	sd	ra,24(sp)
    800032de:	e822                	sd	s0,16(sp)
    800032e0:	1000                	addi	s0,sp,32
  uint64 handler;
  int total_ticks;
  argint(0, &total_ticks);
    800032e2:	fe440593          	addi	a1,s0,-28
    800032e6:	4501                	li	a0,0
    800032e8:	00000097          	auipc	ra,0x0
    800032ec:	bf0080e7          	jalr	-1040(ra) # 80002ed8 <argint>
  argaddr(1, &handler);
    800032f0:	fe840593          	addi	a1,s0,-24
    800032f4:	4505                	li	a0,1
    800032f6:	00000097          	auipc	ra,0x0
    800032fa:	c02080e7          	jalr	-1022(ra) # 80002ef8 <argaddr>

  struct proc *p = myproc();
    800032fe:	ffffe097          	auipc	ra,0xffffe
    80003302:	6ec080e7          	jalr	1772(ra) # 800019ea <myproc>
  p->handler = handler;
    80003306:	fe843783          	ld	a5,-24(s0)
    8000330a:	20f53423          	sd	a5,520(a0)
  p->total_ticks = total_ticks;
    8000330e:	fe442783          	lw	a5,-28(s0)
    80003312:	20f52223          	sw	a5,516(a0)
  p->alarm_state = 0;
    80003316:	20052823          	sw	zero,528(a0)
  p->ticks = 0;
    8000331a:	20052023          	sw	zero,512(a0)

  return 0;
}
    8000331e:	4501                	li	a0,0
    80003320:	60e2                	ld	ra,24(sp)
    80003322:	6442                	ld	s0,16(sp)
    80003324:	6105                	addi	sp,sp,32
    80003326:	8082                	ret

0000000080003328 <sys_sigreturn>:

uint64
sys_sigreturn(void)
{
    80003328:	1101                	addi	sp,sp,-32
    8000332a:	ec06                	sd	ra,24(sp)
    8000332c:	e822                	sd	s0,16(sp)
    8000332e:	e426                	sd	s1,8(sp)
    80003330:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003332:	ffffe097          	auipc	ra,0xffffe
    80003336:	6b8080e7          	jalr	1720(ra) # 800019ea <myproc>
    8000333a:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->backup, sizeof(struct trapframe));
    8000333c:	12000613          	li	a2,288
    80003340:	1f853583          	ld	a1,504(a0)
    80003344:	6d28                	ld	a0,88(a0)
    80003346:	ffffe097          	auipc	ra,0xffffe
    8000334a:	9e8080e7          	jalr	-1560(ra) # 80000d2e <memmove>
  p->ticks = 0;
    8000334e:	2004a023          	sw	zero,512(s1)
  p->alarm_state = 0;
    80003352:	2004a823          	sw	zero,528(s1)
  usertrapret();
    80003356:	fffff097          	auipc	ra,0xfffff
    8000335a:	6ac080e7          	jalr	1708(ra) # 80002a02 <usertrapret>
  return 0;
}
    8000335e:	4501                	li	a0,0
    80003360:	60e2                	ld	ra,24(sp)
    80003362:	6442                	ld	s0,16(sp)
    80003364:	64a2                	ld	s1,8(sp)
    80003366:	6105                	addi	sp,sp,32
    80003368:	8082                	ret

000000008000336a <sys_settickets>:

uint64 sys_settickets(void){
    8000336a:	1101                	addi	sp,sp,-32
    8000336c:	ec06                	sd	ra,24(sp)
    8000336e:	e822                	sd	s0,16(sp)
    80003370:	1000                	addi	s0,sp,32
  int tickets;
  argint(0,&tickets);
    80003372:	fec40593          	addi	a1,s0,-20
    80003376:	4501                	li	a0,0
    80003378:	00000097          	auipc	ra,0x0
    8000337c:	b60080e7          	jalr	-1184(ra) # 80002ed8 <argint>
  myproc()->tickets=tickets;
    80003380:	ffffe097          	auipc	ra,0xffffe
    80003384:	66a080e7          	jalr	1642(ra) # 800019ea <myproc>
    80003388:	fec42783          	lw	a5,-20(s0)
    8000338c:	20f52a23          	sw	a5,532(a0)
  return 0;
}
    80003390:	4501                	li	a0,0
    80003392:	60e2                	ld	ra,24(sp)
    80003394:	6442                	ld	s0,16(sp)
    80003396:	6105                	addi	sp,sp,32
    80003398:	8082                	ret

000000008000339a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000339a:	7179                	addi	sp,sp,-48
    8000339c:	f406                	sd	ra,40(sp)
    8000339e:	f022                	sd	s0,32(sp)
    800033a0:	ec26                	sd	s1,24(sp)
    800033a2:	e84a                	sd	s2,16(sp)
    800033a4:	e44e                	sd	s3,8(sp)
    800033a6:	e052                	sd	s4,0(sp)
    800033a8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800033aa:	00005597          	auipc	a1,0x5
    800033ae:	17e58593          	addi	a1,a1,382 # 80008528 <syscalls+0xd8>
    800033b2:	00016517          	auipc	a0,0x16
    800033b6:	40650513          	addi	a0,a0,1030 # 800197b8 <bcache>
    800033ba:	ffffd097          	auipc	ra,0xffffd
    800033be:	78c080e7          	jalr	1932(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800033c2:	0001e797          	auipc	a5,0x1e
    800033c6:	3f678793          	addi	a5,a5,1014 # 800217b8 <bcache+0x8000>
    800033ca:	0001e717          	auipc	a4,0x1e
    800033ce:	65670713          	addi	a4,a4,1622 # 80021a20 <bcache+0x8268>
    800033d2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800033d6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033da:	00016497          	auipc	s1,0x16
    800033de:	3f648493          	addi	s1,s1,1014 # 800197d0 <bcache+0x18>
    b->next = bcache.head.next;
    800033e2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800033e4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800033e6:	00005a17          	auipc	s4,0x5
    800033ea:	14aa0a13          	addi	s4,s4,330 # 80008530 <syscalls+0xe0>
    b->next = bcache.head.next;
    800033ee:	2b893783          	ld	a5,696(s2)
    800033f2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800033f4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800033f8:	85d2                	mv	a1,s4
    800033fa:	01048513          	addi	a0,s1,16
    800033fe:	00001097          	auipc	ra,0x1
    80003402:	4c4080e7          	jalr	1220(ra) # 800048c2 <initsleeplock>
    bcache.head.next->prev = b;
    80003406:	2b893783          	ld	a5,696(s2)
    8000340a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000340c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003410:	45848493          	addi	s1,s1,1112
    80003414:	fd349de3          	bne	s1,s3,800033ee <binit+0x54>
  }
}
    80003418:	70a2                	ld	ra,40(sp)
    8000341a:	7402                	ld	s0,32(sp)
    8000341c:	64e2                	ld	s1,24(sp)
    8000341e:	6942                	ld	s2,16(sp)
    80003420:	69a2                	ld	s3,8(sp)
    80003422:	6a02                	ld	s4,0(sp)
    80003424:	6145                	addi	sp,sp,48
    80003426:	8082                	ret

0000000080003428 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003428:	7179                	addi	sp,sp,-48
    8000342a:	f406                	sd	ra,40(sp)
    8000342c:	f022                	sd	s0,32(sp)
    8000342e:	ec26                	sd	s1,24(sp)
    80003430:	e84a                	sd	s2,16(sp)
    80003432:	e44e                	sd	s3,8(sp)
    80003434:	1800                	addi	s0,sp,48
    80003436:	892a                	mv	s2,a0
    80003438:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000343a:	00016517          	auipc	a0,0x16
    8000343e:	37e50513          	addi	a0,a0,894 # 800197b8 <bcache>
    80003442:	ffffd097          	auipc	ra,0xffffd
    80003446:	794080e7          	jalr	1940(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000344a:	0001e497          	auipc	s1,0x1e
    8000344e:	6264b483          	ld	s1,1574(s1) # 80021a70 <bcache+0x82b8>
    80003452:	0001e797          	auipc	a5,0x1e
    80003456:	5ce78793          	addi	a5,a5,1486 # 80021a20 <bcache+0x8268>
    8000345a:	02f48f63          	beq	s1,a5,80003498 <bread+0x70>
    8000345e:	873e                	mv	a4,a5
    80003460:	a021                	j	80003468 <bread+0x40>
    80003462:	68a4                	ld	s1,80(s1)
    80003464:	02e48a63          	beq	s1,a4,80003498 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003468:	449c                	lw	a5,8(s1)
    8000346a:	ff279ce3          	bne	a5,s2,80003462 <bread+0x3a>
    8000346e:	44dc                	lw	a5,12(s1)
    80003470:	ff3799e3          	bne	a5,s3,80003462 <bread+0x3a>
      b->refcnt++;
    80003474:	40bc                	lw	a5,64(s1)
    80003476:	2785                	addiw	a5,a5,1
    80003478:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000347a:	00016517          	auipc	a0,0x16
    8000347e:	33e50513          	addi	a0,a0,830 # 800197b8 <bcache>
    80003482:	ffffe097          	auipc	ra,0xffffe
    80003486:	808080e7          	jalr	-2040(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000348a:	01048513          	addi	a0,s1,16
    8000348e:	00001097          	auipc	ra,0x1
    80003492:	46e080e7          	jalr	1134(ra) # 800048fc <acquiresleep>
      return b;
    80003496:	a8b9                	j	800034f4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003498:	0001e497          	auipc	s1,0x1e
    8000349c:	5d04b483          	ld	s1,1488(s1) # 80021a68 <bcache+0x82b0>
    800034a0:	0001e797          	auipc	a5,0x1e
    800034a4:	58078793          	addi	a5,a5,1408 # 80021a20 <bcache+0x8268>
    800034a8:	00f48863          	beq	s1,a5,800034b8 <bread+0x90>
    800034ac:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800034ae:	40bc                	lw	a5,64(s1)
    800034b0:	cf81                	beqz	a5,800034c8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034b2:	64a4                	ld	s1,72(s1)
    800034b4:	fee49de3          	bne	s1,a4,800034ae <bread+0x86>
  panic("bget: no buffers");
    800034b8:	00005517          	auipc	a0,0x5
    800034bc:	08050513          	addi	a0,a0,128 # 80008538 <syscalls+0xe8>
    800034c0:	ffffd097          	auipc	ra,0xffffd
    800034c4:	07e080e7          	jalr	126(ra) # 8000053e <panic>
      b->dev = dev;
    800034c8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800034cc:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800034d0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800034d4:	4785                	li	a5,1
    800034d6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034d8:	00016517          	auipc	a0,0x16
    800034dc:	2e050513          	addi	a0,a0,736 # 800197b8 <bcache>
    800034e0:	ffffd097          	auipc	ra,0xffffd
    800034e4:	7aa080e7          	jalr	1962(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800034e8:	01048513          	addi	a0,s1,16
    800034ec:	00001097          	auipc	ra,0x1
    800034f0:	410080e7          	jalr	1040(ra) # 800048fc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800034f4:	409c                	lw	a5,0(s1)
    800034f6:	cb89                	beqz	a5,80003508 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034f8:	8526                	mv	a0,s1
    800034fa:	70a2                	ld	ra,40(sp)
    800034fc:	7402                	ld	s0,32(sp)
    800034fe:	64e2                	ld	s1,24(sp)
    80003500:	6942                	ld	s2,16(sp)
    80003502:	69a2                	ld	s3,8(sp)
    80003504:	6145                	addi	sp,sp,48
    80003506:	8082                	ret
    virtio_disk_rw(b, 0);
    80003508:	4581                	li	a1,0
    8000350a:	8526                	mv	a0,s1
    8000350c:	00003097          	auipc	ra,0x3
    80003510:	fd8080e7          	jalr	-40(ra) # 800064e4 <virtio_disk_rw>
    b->valid = 1;
    80003514:	4785                	li	a5,1
    80003516:	c09c                	sw	a5,0(s1)
  return b;
    80003518:	b7c5                	j	800034f8 <bread+0xd0>

000000008000351a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000351a:	1101                	addi	sp,sp,-32
    8000351c:	ec06                	sd	ra,24(sp)
    8000351e:	e822                	sd	s0,16(sp)
    80003520:	e426                	sd	s1,8(sp)
    80003522:	1000                	addi	s0,sp,32
    80003524:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003526:	0541                	addi	a0,a0,16
    80003528:	00001097          	auipc	ra,0x1
    8000352c:	46e080e7          	jalr	1134(ra) # 80004996 <holdingsleep>
    80003530:	cd01                	beqz	a0,80003548 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003532:	4585                	li	a1,1
    80003534:	8526                	mv	a0,s1
    80003536:	00003097          	auipc	ra,0x3
    8000353a:	fae080e7          	jalr	-82(ra) # 800064e4 <virtio_disk_rw>
}
    8000353e:	60e2                	ld	ra,24(sp)
    80003540:	6442                	ld	s0,16(sp)
    80003542:	64a2                	ld	s1,8(sp)
    80003544:	6105                	addi	sp,sp,32
    80003546:	8082                	ret
    panic("bwrite");
    80003548:	00005517          	auipc	a0,0x5
    8000354c:	00850513          	addi	a0,a0,8 # 80008550 <syscalls+0x100>
    80003550:	ffffd097          	auipc	ra,0xffffd
    80003554:	fee080e7          	jalr	-18(ra) # 8000053e <panic>

0000000080003558 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003558:	1101                	addi	sp,sp,-32
    8000355a:	ec06                	sd	ra,24(sp)
    8000355c:	e822                	sd	s0,16(sp)
    8000355e:	e426                	sd	s1,8(sp)
    80003560:	e04a                	sd	s2,0(sp)
    80003562:	1000                	addi	s0,sp,32
    80003564:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003566:	01050913          	addi	s2,a0,16
    8000356a:	854a                	mv	a0,s2
    8000356c:	00001097          	auipc	ra,0x1
    80003570:	42a080e7          	jalr	1066(ra) # 80004996 <holdingsleep>
    80003574:	c92d                	beqz	a0,800035e6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003576:	854a                	mv	a0,s2
    80003578:	00001097          	auipc	ra,0x1
    8000357c:	3da080e7          	jalr	986(ra) # 80004952 <releasesleep>

  acquire(&bcache.lock);
    80003580:	00016517          	auipc	a0,0x16
    80003584:	23850513          	addi	a0,a0,568 # 800197b8 <bcache>
    80003588:	ffffd097          	auipc	ra,0xffffd
    8000358c:	64e080e7          	jalr	1614(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003590:	40bc                	lw	a5,64(s1)
    80003592:	37fd                	addiw	a5,a5,-1
    80003594:	0007871b          	sext.w	a4,a5
    80003598:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000359a:	eb05                	bnez	a4,800035ca <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000359c:	68bc                	ld	a5,80(s1)
    8000359e:	64b8                	ld	a4,72(s1)
    800035a0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800035a2:	64bc                	ld	a5,72(s1)
    800035a4:	68b8                	ld	a4,80(s1)
    800035a6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800035a8:	0001e797          	auipc	a5,0x1e
    800035ac:	21078793          	addi	a5,a5,528 # 800217b8 <bcache+0x8000>
    800035b0:	2b87b703          	ld	a4,696(a5)
    800035b4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800035b6:	0001e717          	auipc	a4,0x1e
    800035ba:	46a70713          	addi	a4,a4,1130 # 80021a20 <bcache+0x8268>
    800035be:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800035c0:	2b87b703          	ld	a4,696(a5)
    800035c4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800035c6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800035ca:	00016517          	auipc	a0,0x16
    800035ce:	1ee50513          	addi	a0,a0,494 # 800197b8 <bcache>
    800035d2:	ffffd097          	auipc	ra,0xffffd
    800035d6:	6b8080e7          	jalr	1720(ra) # 80000c8a <release>
}
    800035da:	60e2                	ld	ra,24(sp)
    800035dc:	6442                	ld	s0,16(sp)
    800035de:	64a2                	ld	s1,8(sp)
    800035e0:	6902                	ld	s2,0(sp)
    800035e2:	6105                	addi	sp,sp,32
    800035e4:	8082                	ret
    panic("brelse");
    800035e6:	00005517          	auipc	a0,0x5
    800035ea:	f7250513          	addi	a0,a0,-142 # 80008558 <syscalls+0x108>
    800035ee:	ffffd097          	auipc	ra,0xffffd
    800035f2:	f50080e7          	jalr	-176(ra) # 8000053e <panic>

00000000800035f6 <bpin>:

void
bpin(struct buf *b) {
    800035f6:	1101                	addi	sp,sp,-32
    800035f8:	ec06                	sd	ra,24(sp)
    800035fa:	e822                	sd	s0,16(sp)
    800035fc:	e426                	sd	s1,8(sp)
    800035fe:	1000                	addi	s0,sp,32
    80003600:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003602:	00016517          	auipc	a0,0x16
    80003606:	1b650513          	addi	a0,a0,438 # 800197b8 <bcache>
    8000360a:	ffffd097          	auipc	ra,0xffffd
    8000360e:	5cc080e7          	jalr	1484(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003612:	40bc                	lw	a5,64(s1)
    80003614:	2785                	addiw	a5,a5,1
    80003616:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003618:	00016517          	auipc	a0,0x16
    8000361c:	1a050513          	addi	a0,a0,416 # 800197b8 <bcache>
    80003620:	ffffd097          	auipc	ra,0xffffd
    80003624:	66a080e7          	jalr	1642(ra) # 80000c8a <release>
}
    80003628:	60e2                	ld	ra,24(sp)
    8000362a:	6442                	ld	s0,16(sp)
    8000362c:	64a2                	ld	s1,8(sp)
    8000362e:	6105                	addi	sp,sp,32
    80003630:	8082                	ret

0000000080003632 <bunpin>:

void
bunpin(struct buf *b) {
    80003632:	1101                	addi	sp,sp,-32
    80003634:	ec06                	sd	ra,24(sp)
    80003636:	e822                	sd	s0,16(sp)
    80003638:	e426                	sd	s1,8(sp)
    8000363a:	1000                	addi	s0,sp,32
    8000363c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000363e:	00016517          	auipc	a0,0x16
    80003642:	17a50513          	addi	a0,a0,378 # 800197b8 <bcache>
    80003646:	ffffd097          	auipc	ra,0xffffd
    8000364a:	590080e7          	jalr	1424(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000364e:	40bc                	lw	a5,64(s1)
    80003650:	37fd                	addiw	a5,a5,-1
    80003652:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003654:	00016517          	auipc	a0,0x16
    80003658:	16450513          	addi	a0,a0,356 # 800197b8 <bcache>
    8000365c:	ffffd097          	auipc	ra,0xffffd
    80003660:	62e080e7          	jalr	1582(ra) # 80000c8a <release>
}
    80003664:	60e2                	ld	ra,24(sp)
    80003666:	6442                	ld	s0,16(sp)
    80003668:	64a2                	ld	s1,8(sp)
    8000366a:	6105                	addi	sp,sp,32
    8000366c:	8082                	ret

000000008000366e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000366e:	1101                	addi	sp,sp,-32
    80003670:	ec06                	sd	ra,24(sp)
    80003672:	e822                	sd	s0,16(sp)
    80003674:	e426                	sd	s1,8(sp)
    80003676:	e04a                	sd	s2,0(sp)
    80003678:	1000                	addi	s0,sp,32
    8000367a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000367c:	00d5d59b          	srliw	a1,a1,0xd
    80003680:	0001f797          	auipc	a5,0x1f
    80003684:	8147a783          	lw	a5,-2028(a5) # 80021e94 <sb+0x1c>
    80003688:	9dbd                	addw	a1,a1,a5
    8000368a:	00000097          	auipc	ra,0x0
    8000368e:	d9e080e7          	jalr	-610(ra) # 80003428 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003692:	0074f713          	andi	a4,s1,7
    80003696:	4785                	li	a5,1
    80003698:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000369c:	14ce                	slli	s1,s1,0x33
    8000369e:	90d9                	srli	s1,s1,0x36
    800036a0:	00950733          	add	a4,a0,s1
    800036a4:	05874703          	lbu	a4,88(a4)
    800036a8:	00e7f6b3          	and	a3,a5,a4
    800036ac:	c69d                	beqz	a3,800036da <bfree+0x6c>
    800036ae:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800036b0:	94aa                	add	s1,s1,a0
    800036b2:	fff7c793          	not	a5,a5
    800036b6:	8ff9                	and	a5,a5,a4
    800036b8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800036bc:	00001097          	auipc	ra,0x1
    800036c0:	120080e7          	jalr	288(ra) # 800047dc <log_write>
  brelse(bp);
    800036c4:	854a                	mv	a0,s2
    800036c6:	00000097          	auipc	ra,0x0
    800036ca:	e92080e7          	jalr	-366(ra) # 80003558 <brelse>
}
    800036ce:	60e2                	ld	ra,24(sp)
    800036d0:	6442                	ld	s0,16(sp)
    800036d2:	64a2                	ld	s1,8(sp)
    800036d4:	6902                	ld	s2,0(sp)
    800036d6:	6105                	addi	sp,sp,32
    800036d8:	8082                	ret
    panic("freeing free block");
    800036da:	00005517          	auipc	a0,0x5
    800036de:	e8650513          	addi	a0,a0,-378 # 80008560 <syscalls+0x110>
    800036e2:	ffffd097          	auipc	ra,0xffffd
    800036e6:	e5c080e7          	jalr	-420(ra) # 8000053e <panic>

00000000800036ea <balloc>:
{
    800036ea:	711d                	addi	sp,sp,-96
    800036ec:	ec86                	sd	ra,88(sp)
    800036ee:	e8a2                	sd	s0,80(sp)
    800036f0:	e4a6                	sd	s1,72(sp)
    800036f2:	e0ca                	sd	s2,64(sp)
    800036f4:	fc4e                	sd	s3,56(sp)
    800036f6:	f852                	sd	s4,48(sp)
    800036f8:	f456                	sd	s5,40(sp)
    800036fa:	f05a                	sd	s6,32(sp)
    800036fc:	ec5e                	sd	s7,24(sp)
    800036fe:	e862                	sd	s8,16(sp)
    80003700:	e466                	sd	s9,8(sp)
    80003702:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003704:	0001e797          	auipc	a5,0x1e
    80003708:	7787a783          	lw	a5,1912(a5) # 80021e7c <sb+0x4>
    8000370c:	10078163          	beqz	a5,8000380e <balloc+0x124>
    80003710:	8baa                	mv	s7,a0
    80003712:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003714:	0001eb17          	auipc	s6,0x1e
    80003718:	764b0b13          	addi	s6,s6,1892 # 80021e78 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000371c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000371e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003720:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003722:	6c89                	lui	s9,0x2
    80003724:	a061                	j	800037ac <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003726:	974a                	add	a4,a4,s2
    80003728:	8fd5                	or	a5,a5,a3
    8000372a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000372e:	854a                	mv	a0,s2
    80003730:	00001097          	auipc	ra,0x1
    80003734:	0ac080e7          	jalr	172(ra) # 800047dc <log_write>
        brelse(bp);
    80003738:	854a                	mv	a0,s2
    8000373a:	00000097          	auipc	ra,0x0
    8000373e:	e1e080e7          	jalr	-482(ra) # 80003558 <brelse>
  bp = bread(dev, bno);
    80003742:	85a6                	mv	a1,s1
    80003744:	855e                	mv	a0,s7
    80003746:	00000097          	auipc	ra,0x0
    8000374a:	ce2080e7          	jalr	-798(ra) # 80003428 <bread>
    8000374e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003750:	40000613          	li	a2,1024
    80003754:	4581                	li	a1,0
    80003756:	05850513          	addi	a0,a0,88
    8000375a:	ffffd097          	auipc	ra,0xffffd
    8000375e:	578080e7          	jalr	1400(ra) # 80000cd2 <memset>
  log_write(bp);
    80003762:	854a                	mv	a0,s2
    80003764:	00001097          	auipc	ra,0x1
    80003768:	078080e7          	jalr	120(ra) # 800047dc <log_write>
  brelse(bp);
    8000376c:	854a                	mv	a0,s2
    8000376e:	00000097          	auipc	ra,0x0
    80003772:	dea080e7          	jalr	-534(ra) # 80003558 <brelse>
}
    80003776:	8526                	mv	a0,s1
    80003778:	60e6                	ld	ra,88(sp)
    8000377a:	6446                	ld	s0,80(sp)
    8000377c:	64a6                	ld	s1,72(sp)
    8000377e:	6906                	ld	s2,64(sp)
    80003780:	79e2                	ld	s3,56(sp)
    80003782:	7a42                	ld	s4,48(sp)
    80003784:	7aa2                	ld	s5,40(sp)
    80003786:	7b02                	ld	s6,32(sp)
    80003788:	6be2                	ld	s7,24(sp)
    8000378a:	6c42                	ld	s8,16(sp)
    8000378c:	6ca2                	ld	s9,8(sp)
    8000378e:	6125                	addi	sp,sp,96
    80003790:	8082                	ret
    brelse(bp);
    80003792:	854a                	mv	a0,s2
    80003794:	00000097          	auipc	ra,0x0
    80003798:	dc4080e7          	jalr	-572(ra) # 80003558 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000379c:	015c87bb          	addw	a5,s9,s5
    800037a0:	00078a9b          	sext.w	s5,a5
    800037a4:	004b2703          	lw	a4,4(s6)
    800037a8:	06eaf363          	bgeu	s5,a4,8000380e <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800037ac:	41fad79b          	sraiw	a5,s5,0x1f
    800037b0:	0137d79b          	srliw	a5,a5,0x13
    800037b4:	015787bb          	addw	a5,a5,s5
    800037b8:	40d7d79b          	sraiw	a5,a5,0xd
    800037bc:	01cb2583          	lw	a1,28(s6)
    800037c0:	9dbd                	addw	a1,a1,a5
    800037c2:	855e                	mv	a0,s7
    800037c4:	00000097          	auipc	ra,0x0
    800037c8:	c64080e7          	jalr	-924(ra) # 80003428 <bread>
    800037cc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037ce:	004b2503          	lw	a0,4(s6)
    800037d2:	000a849b          	sext.w	s1,s5
    800037d6:	8662                	mv	a2,s8
    800037d8:	faa4fde3          	bgeu	s1,a0,80003792 <balloc+0xa8>
      m = 1 << (bi % 8);
    800037dc:	41f6579b          	sraiw	a5,a2,0x1f
    800037e0:	01d7d69b          	srliw	a3,a5,0x1d
    800037e4:	00c6873b          	addw	a4,a3,a2
    800037e8:	00777793          	andi	a5,a4,7
    800037ec:	9f95                	subw	a5,a5,a3
    800037ee:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037f2:	4037571b          	sraiw	a4,a4,0x3
    800037f6:	00e906b3          	add	a3,s2,a4
    800037fa:	0586c683          	lbu	a3,88(a3)
    800037fe:	00d7f5b3          	and	a1,a5,a3
    80003802:	d195                	beqz	a1,80003726 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003804:	2605                	addiw	a2,a2,1
    80003806:	2485                	addiw	s1,s1,1
    80003808:	fd4618e3          	bne	a2,s4,800037d8 <balloc+0xee>
    8000380c:	b759                	j	80003792 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    8000380e:	00005517          	auipc	a0,0x5
    80003812:	d6a50513          	addi	a0,a0,-662 # 80008578 <syscalls+0x128>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	d72080e7          	jalr	-654(ra) # 80000588 <printf>
  return 0;
    8000381e:	4481                	li	s1,0
    80003820:	bf99                	j	80003776 <balloc+0x8c>

0000000080003822 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003822:	7179                	addi	sp,sp,-48
    80003824:	f406                	sd	ra,40(sp)
    80003826:	f022                	sd	s0,32(sp)
    80003828:	ec26                	sd	s1,24(sp)
    8000382a:	e84a                	sd	s2,16(sp)
    8000382c:	e44e                	sd	s3,8(sp)
    8000382e:	e052                	sd	s4,0(sp)
    80003830:	1800                	addi	s0,sp,48
    80003832:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003834:	47ad                	li	a5,11
    80003836:	02b7e763          	bltu	a5,a1,80003864 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000383a:	02059493          	slli	s1,a1,0x20
    8000383e:	9081                	srli	s1,s1,0x20
    80003840:	048a                	slli	s1,s1,0x2
    80003842:	94aa                	add	s1,s1,a0
    80003844:	0504a903          	lw	s2,80(s1)
    80003848:	06091e63          	bnez	s2,800038c4 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000384c:	4108                	lw	a0,0(a0)
    8000384e:	00000097          	auipc	ra,0x0
    80003852:	e9c080e7          	jalr	-356(ra) # 800036ea <balloc>
    80003856:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000385a:	06090563          	beqz	s2,800038c4 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    8000385e:	0524a823          	sw	s2,80(s1)
    80003862:	a08d                	j	800038c4 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003864:	ff45849b          	addiw	s1,a1,-12
    80003868:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000386c:	0ff00793          	li	a5,255
    80003870:	08e7e563          	bltu	a5,a4,800038fa <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003874:	08052903          	lw	s2,128(a0)
    80003878:	00091d63          	bnez	s2,80003892 <bmap+0x70>
      addr = balloc(ip->dev);
    8000387c:	4108                	lw	a0,0(a0)
    8000387e:	00000097          	auipc	ra,0x0
    80003882:	e6c080e7          	jalr	-404(ra) # 800036ea <balloc>
    80003886:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000388a:	02090d63          	beqz	s2,800038c4 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000388e:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003892:	85ca                	mv	a1,s2
    80003894:	0009a503          	lw	a0,0(s3)
    80003898:	00000097          	auipc	ra,0x0
    8000389c:	b90080e7          	jalr	-1136(ra) # 80003428 <bread>
    800038a0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038a2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038a6:	02049593          	slli	a1,s1,0x20
    800038aa:	9181                	srli	a1,a1,0x20
    800038ac:	058a                	slli	a1,a1,0x2
    800038ae:	00b784b3          	add	s1,a5,a1
    800038b2:	0004a903          	lw	s2,0(s1)
    800038b6:	02090063          	beqz	s2,800038d6 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800038ba:	8552                	mv	a0,s4
    800038bc:	00000097          	auipc	ra,0x0
    800038c0:	c9c080e7          	jalr	-868(ra) # 80003558 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800038c4:	854a                	mv	a0,s2
    800038c6:	70a2                	ld	ra,40(sp)
    800038c8:	7402                	ld	s0,32(sp)
    800038ca:	64e2                	ld	s1,24(sp)
    800038cc:	6942                	ld	s2,16(sp)
    800038ce:	69a2                	ld	s3,8(sp)
    800038d0:	6a02                	ld	s4,0(sp)
    800038d2:	6145                	addi	sp,sp,48
    800038d4:	8082                	ret
      addr = balloc(ip->dev);
    800038d6:	0009a503          	lw	a0,0(s3)
    800038da:	00000097          	auipc	ra,0x0
    800038de:	e10080e7          	jalr	-496(ra) # 800036ea <balloc>
    800038e2:	0005091b          	sext.w	s2,a0
      if(addr){
    800038e6:	fc090ae3          	beqz	s2,800038ba <bmap+0x98>
        a[bn] = addr;
    800038ea:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800038ee:	8552                	mv	a0,s4
    800038f0:	00001097          	auipc	ra,0x1
    800038f4:	eec080e7          	jalr	-276(ra) # 800047dc <log_write>
    800038f8:	b7c9                	j	800038ba <bmap+0x98>
  panic("bmap: out of range");
    800038fa:	00005517          	auipc	a0,0x5
    800038fe:	c9650513          	addi	a0,a0,-874 # 80008590 <syscalls+0x140>
    80003902:	ffffd097          	auipc	ra,0xffffd
    80003906:	c3c080e7          	jalr	-964(ra) # 8000053e <panic>

000000008000390a <iget>:
{
    8000390a:	7179                	addi	sp,sp,-48
    8000390c:	f406                	sd	ra,40(sp)
    8000390e:	f022                	sd	s0,32(sp)
    80003910:	ec26                	sd	s1,24(sp)
    80003912:	e84a                	sd	s2,16(sp)
    80003914:	e44e                	sd	s3,8(sp)
    80003916:	e052                	sd	s4,0(sp)
    80003918:	1800                	addi	s0,sp,48
    8000391a:	89aa                	mv	s3,a0
    8000391c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000391e:	0001e517          	auipc	a0,0x1e
    80003922:	57a50513          	addi	a0,a0,1402 # 80021e98 <itable>
    80003926:	ffffd097          	auipc	ra,0xffffd
    8000392a:	2b0080e7          	jalr	688(ra) # 80000bd6 <acquire>
  empty = 0;
    8000392e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003930:	0001e497          	auipc	s1,0x1e
    80003934:	58048493          	addi	s1,s1,1408 # 80021eb0 <itable+0x18>
    80003938:	00020697          	auipc	a3,0x20
    8000393c:	00868693          	addi	a3,a3,8 # 80023940 <log>
    80003940:	a039                	j	8000394e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003942:	02090b63          	beqz	s2,80003978 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003946:	08848493          	addi	s1,s1,136
    8000394a:	02d48a63          	beq	s1,a3,8000397e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000394e:	449c                	lw	a5,8(s1)
    80003950:	fef059e3          	blez	a5,80003942 <iget+0x38>
    80003954:	4098                	lw	a4,0(s1)
    80003956:	ff3716e3          	bne	a4,s3,80003942 <iget+0x38>
    8000395a:	40d8                	lw	a4,4(s1)
    8000395c:	ff4713e3          	bne	a4,s4,80003942 <iget+0x38>
      ip->ref++;
    80003960:	2785                	addiw	a5,a5,1
    80003962:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003964:	0001e517          	auipc	a0,0x1e
    80003968:	53450513          	addi	a0,a0,1332 # 80021e98 <itable>
    8000396c:	ffffd097          	auipc	ra,0xffffd
    80003970:	31e080e7          	jalr	798(ra) # 80000c8a <release>
      return ip;
    80003974:	8926                	mv	s2,s1
    80003976:	a03d                	j	800039a4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003978:	f7f9                	bnez	a5,80003946 <iget+0x3c>
    8000397a:	8926                	mv	s2,s1
    8000397c:	b7e9                	j	80003946 <iget+0x3c>
  if(empty == 0)
    8000397e:	02090c63          	beqz	s2,800039b6 <iget+0xac>
  ip->dev = dev;
    80003982:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003986:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000398a:	4785                	li	a5,1
    8000398c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003990:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003994:	0001e517          	auipc	a0,0x1e
    80003998:	50450513          	addi	a0,a0,1284 # 80021e98 <itable>
    8000399c:	ffffd097          	auipc	ra,0xffffd
    800039a0:	2ee080e7          	jalr	750(ra) # 80000c8a <release>
}
    800039a4:	854a                	mv	a0,s2
    800039a6:	70a2                	ld	ra,40(sp)
    800039a8:	7402                	ld	s0,32(sp)
    800039aa:	64e2                	ld	s1,24(sp)
    800039ac:	6942                	ld	s2,16(sp)
    800039ae:	69a2                	ld	s3,8(sp)
    800039b0:	6a02                	ld	s4,0(sp)
    800039b2:	6145                	addi	sp,sp,48
    800039b4:	8082                	ret
    panic("iget: no inodes");
    800039b6:	00005517          	auipc	a0,0x5
    800039ba:	bf250513          	addi	a0,a0,-1038 # 800085a8 <syscalls+0x158>
    800039be:	ffffd097          	auipc	ra,0xffffd
    800039c2:	b80080e7          	jalr	-1152(ra) # 8000053e <panic>

00000000800039c6 <fsinit>:
fsinit(int dev) {
    800039c6:	7179                	addi	sp,sp,-48
    800039c8:	f406                	sd	ra,40(sp)
    800039ca:	f022                	sd	s0,32(sp)
    800039cc:	ec26                	sd	s1,24(sp)
    800039ce:	e84a                	sd	s2,16(sp)
    800039d0:	e44e                	sd	s3,8(sp)
    800039d2:	1800                	addi	s0,sp,48
    800039d4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800039d6:	4585                	li	a1,1
    800039d8:	00000097          	auipc	ra,0x0
    800039dc:	a50080e7          	jalr	-1456(ra) # 80003428 <bread>
    800039e0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800039e2:	0001e997          	auipc	s3,0x1e
    800039e6:	49698993          	addi	s3,s3,1174 # 80021e78 <sb>
    800039ea:	02000613          	li	a2,32
    800039ee:	05850593          	addi	a1,a0,88
    800039f2:	854e                	mv	a0,s3
    800039f4:	ffffd097          	auipc	ra,0xffffd
    800039f8:	33a080e7          	jalr	826(ra) # 80000d2e <memmove>
  brelse(bp);
    800039fc:	8526                	mv	a0,s1
    800039fe:	00000097          	auipc	ra,0x0
    80003a02:	b5a080e7          	jalr	-1190(ra) # 80003558 <brelse>
  if(sb.magic != FSMAGIC)
    80003a06:	0009a703          	lw	a4,0(s3)
    80003a0a:	102037b7          	lui	a5,0x10203
    80003a0e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a12:	02f71263          	bne	a4,a5,80003a36 <fsinit+0x70>
  initlog(dev, &sb);
    80003a16:	0001e597          	auipc	a1,0x1e
    80003a1a:	46258593          	addi	a1,a1,1122 # 80021e78 <sb>
    80003a1e:	854a                	mv	a0,s2
    80003a20:	00001097          	auipc	ra,0x1
    80003a24:	b40080e7          	jalr	-1216(ra) # 80004560 <initlog>
}
    80003a28:	70a2                	ld	ra,40(sp)
    80003a2a:	7402                	ld	s0,32(sp)
    80003a2c:	64e2                	ld	s1,24(sp)
    80003a2e:	6942                	ld	s2,16(sp)
    80003a30:	69a2                	ld	s3,8(sp)
    80003a32:	6145                	addi	sp,sp,48
    80003a34:	8082                	ret
    panic("invalid file system");
    80003a36:	00005517          	auipc	a0,0x5
    80003a3a:	b8250513          	addi	a0,a0,-1150 # 800085b8 <syscalls+0x168>
    80003a3e:	ffffd097          	auipc	ra,0xffffd
    80003a42:	b00080e7          	jalr	-1280(ra) # 8000053e <panic>

0000000080003a46 <iinit>:
{
    80003a46:	7179                	addi	sp,sp,-48
    80003a48:	f406                	sd	ra,40(sp)
    80003a4a:	f022                	sd	s0,32(sp)
    80003a4c:	ec26                	sd	s1,24(sp)
    80003a4e:	e84a                	sd	s2,16(sp)
    80003a50:	e44e                	sd	s3,8(sp)
    80003a52:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a54:	00005597          	auipc	a1,0x5
    80003a58:	b7c58593          	addi	a1,a1,-1156 # 800085d0 <syscalls+0x180>
    80003a5c:	0001e517          	auipc	a0,0x1e
    80003a60:	43c50513          	addi	a0,a0,1084 # 80021e98 <itable>
    80003a64:	ffffd097          	auipc	ra,0xffffd
    80003a68:	0e2080e7          	jalr	226(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a6c:	0001e497          	auipc	s1,0x1e
    80003a70:	45448493          	addi	s1,s1,1108 # 80021ec0 <itable+0x28>
    80003a74:	00020997          	auipc	s3,0x20
    80003a78:	edc98993          	addi	s3,s3,-292 # 80023950 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a7c:	00005917          	auipc	s2,0x5
    80003a80:	b5c90913          	addi	s2,s2,-1188 # 800085d8 <syscalls+0x188>
    80003a84:	85ca                	mv	a1,s2
    80003a86:	8526                	mv	a0,s1
    80003a88:	00001097          	auipc	ra,0x1
    80003a8c:	e3a080e7          	jalr	-454(ra) # 800048c2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a90:	08848493          	addi	s1,s1,136
    80003a94:	ff3498e3          	bne	s1,s3,80003a84 <iinit+0x3e>
}
    80003a98:	70a2                	ld	ra,40(sp)
    80003a9a:	7402                	ld	s0,32(sp)
    80003a9c:	64e2                	ld	s1,24(sp)
    80003a9e:	6942                	ld	s2,16(sp)
    80003aa0:	69a2                	ld	s3,8(sp)
    80003aa2:	6145                	addi	sp,sp,48
    80003aa4:	8082                	ret

0000000080003aa6 <ialloc>:
{
    80003aa6:	715d                	addi	sp,sp,-80
    80003aa8:	e486                	sd	ra,72(sp)
    80003aaa:	e0a2                	sd	s0,64(sp)
    80003aac:	fc26                	sd	s1,56(sp)
    80003aae:	f84a                	sd	s2,48(sp)
    80003ab0:	f44e                	sd	s3,40(sp)
    80003ab2:	f052                	sd	s4,32(sp)
    80003ab4:	ec56                	sd	s5,24(sp)
    80003ab6:	e85a                	sd	s6,16(sp)
    80003ab8:	e45e                	sd	s7,8(sp)
    80003aba:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003abc:	0001e717          	auipc	a4,0x1e
    80003ac0:	3c872703          	lw	a4,968(a4) # 80021e84 <sb+0xc>
    80003ac4:	4785                	li	a5,1
    80003ac6:	04e7fa63          	bgeu	a5,a4,80003b1a <ialloc+0x74>
    80003aca:	8aaa                	mv	s5,a0
    80003acc:	8bae                	mv	s7,a1
    80003ace:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003ad0:	0001ea17          	auipc	s4,0x1e
    80003ad4:	3a8a0a13          	addi	s4,s4,936 # 80021e78 <sb>
    80003ad8:	00048b1b          	sext.w	s6,s1
    80003adc:	0044d793          	srli	a5,s1,0x4
    80003ae0:	018a2583          	lw	a1,24(s4)
    80003ae4:	9dbd                	addw	a1,a1,a5
    80003ae6:	8556                	mv	a0,s5
    80003ae8:	00000097          	auipc	ra,0x0
    80003aec:	940080e7          	jalr	-1728(ra) # 80003428 <bread>
    80003af0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003af2:	05850993          	addi	s3,a0,88
    80003af6:	00f4f793          	andi	a5,s1,15
    80003afa:	079a                	slli	a5,a5,0x6
    80003afc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003afe:	00099783          	lh	a5,0(s3)
    80003b02:	c3a1                	beqz	a5,80003b42 <ialloc+0x9c>
    brelse(bp);
    80003b04:	00000097          	auipc	ra,0x0
    80003b08:	a54080e7          	jalr	-1452(ra) # 80003558 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b0c:	0485                	addi	s1,s1,1
    80003b0e:	00ca2703          	lw	a4,12(s4)
    80003b12:	0004879b          	sext.w	a5,s1
    80003b16:	fce7e1e3          	bltu	a5,a4,80003ad8 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003b1a:	00005517          	auipc	a0,0x5
    80003b1e:	ac650513          	addi	a0,a0,-1338 # 800085e0 <syscalls+0x190>
    80003b22:	ffffd097          	auipc	ra,0xffffd
    80003b26:	a66080e7          	jalr	-1434(ra) # 80000588 <printf>
  return 0;
    80003b2a:	4501                	li	a0,0
}
    80003b2c:	60a6                	ld	ra,72(sp)
    80003b2e:	6406                	ld	s0,64(sp)
    80003b30:	74e2                	ld	s1,56(sp)
    80003b32:	7942                	ld	s2,48(sp)
    80003b34:	79a2                	ld	s3,40(sp)
    80003b36:	7a02                	ld	s4,32(sp)
    80003b38:	6ae2                	ld	s5,24(sp)
    80003b3a:	6b42                	ld	s6,16(sp)
    80003b3c:	6ba2                	ld	s7,8(sp)
    80003b3e:	6161                	addi	sp,sp,80
    80003b40:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b42:	04000613          	li	a2,64
    80003b46:	4581                	li	a1,0
    80003b48:	854e                	mv	a0,s3
    80003b4a:	ffffd097          	auipc	ra,0xffffd
    80003b4e:	188080e7          	jalr	392(ra) # 80000cd2 <memset>
      dip->type = type;
    80003b52:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b56:	854a                	mv	a0,s2
    80003b58:	00001097          	auipc	ra,0x1
    80003b5c:	c84080e7          	jalr	-892(ra) # 800047dc <log_write>
      brelse(bp);
    80003b60:	854a                	mv	a0,s2
    80003b62:	00000097          	auipc	ra,0x0
    80003b66:	9f6080e7          	jalr	-1546(ra) # 80003558 <brelse>
      return iget(dev, inum);
    80003b6a:	85da                	mv	a1,s6
    80003b6c:	8556                	mv	a0,s5
    80003b6e:	00000097          	auipc	ra,0x0
    80003b72:	d9c080e7          	jalr	-612(ra) # 8000390a <iget>
    80003b76:	bf5d                	j	80003b2c <ialloc+0x86>

0000000080003b78 <iupdate>:
{
    80003b78:	1101                	addi	sp,sp,-32
    80003b7a:	ec06                	sd	ra,24(sp)
    80003b7c:	e822                	sd	s0,16(sp)
    80003b7e:	e426                	sd	s1,8(sp)
    80003b80:	e04a                	sd	s2,0(sp)
    80003b82:	1000                	addi	s0,sp,32
    80003b84:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b86:	415c                	lw	a5,4(a0)
    80003b88:	0047d79b          	srliw	a5,a5,0x4
    80003b8c:	0001e597          	auipc	a1,0x1e
    80003b90:	3045a583          	lw	a1,772(a1) # 80021e90 <sb+0x18>
    80003b94:	9dbd                	addw	a1,a1,a5
    80003b96:	4108                	lw	a0,0(a0)
    80003b98:	00000097          	auipc	ra,0x0
    80003b9c:	890080e7          	jalr	-1904(ra) # 80003428 <bread>
    80003ba0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ba2:	05850793          	addi	a5,a0,88
    80003ba6:	40c8                	lw	a0,4(s1)
    80003ba8:	893d                	andi	a0,a0,15
    80003baa:	051a                	slli	a0,a0,0x6
    80003bac:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003bae:	04449703          	lh	a4,68(s1)
    80003bb2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003bb6:	04649703          	lh	a4,70(s1)
    80003bba:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003bbe:	04849703          	lh	a4,72(s1)
    80003bc2:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003bc6:	04a49703          	lh	a4,74(s1)
    80003bca:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003bce:	44f8                	lw	a4,76(s1)
    80003bd0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003bd2:	03400613          	li	a2,52
    80003bd6:	05048593          	addi	a1,s1,80
    80003bda:	0531                	addi	a0,a0,12
    80003bdc:	ffffd097          	auipc	ra,0xffffd
    80003be0:	152080e7          	jalr	338(ra) # 80000d2e <memmove>
  log_write(bp);
    80003be4:	854a                	mv	a0,s2
    80003be6:	00001097          	auipc	ra,0x1
    80003bea:	bf6080e7          	jalr	-1034(ra) # 800047dc <log_write>
  brelse(bp);
    80003bee:	854a                	mv	a0,s2
    80003bf0:	00000097          	auipc	ra,0x0
    80003bf4:	968080e7          	jalr	-1688(ra) # 80003558 <brelse>
}
    80003bf8:	60e2                	ld	ra,24(sp)
    80003bfa:	6442                	ld	s0,16(sp)
    80003bfc:	64a2                	ld	s1,8(sp)
    80003bfe:	6902                	ld	s2,0(sp)
    80003c00:	6105                	addi	sp,sp,32
    80003c02:	8082                	ret

0000000080003c04 <idup>:
{
    80003c04:	1101                	addi	sp,sp,-32
    80003c06:	ec06                	sd	ra,24(sp)
    80003c08:	e822                	sd	s0,16(sp)
    80003c0a:	e426                	sd	s1,8(sp)
    80003c0c:	1000                	addi	s0,sp,32
    80003c0e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c10:	0001e517          	auipc	a0,0x1e
    80003c14:	28850513          	addi	a0,a0,648 # 80021e98 <itable>
    80003c18:	ffffd097          	auipc	ra,0xffffd
    80003c1c:	fbe080e7          	jalr	-66(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003c20:	449c                	lw	a5,8(s1)
    80003c22:	2785                	addiw	a5,a5,1
    80003c24:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c26:	0001e517          	auipc	a0,0x1e
    80003c2a:	27250513          	addi	a0,a0,626 # 80021e98 <itable>
    80003c2e:	ffffd097          	auipc	ra,0xffffd
    80003c32:	05c080e7          	jalr	92(ra) # 80000c8a <release>
}
    80003c36:	8526                	mv	a0,s1
    80003c38:	60e2                	ld	ra,24(sp)
    80003c3a:	6442                	ld	s0,16(sp)
    80003c3c:	64a2                	ld	s1,8(sp)
    80003c3e:	6105                	addi	sp,sp,32
    80003c40:	8082                	ret

0000000080003c42 <ilock>:
{
    80003c42:	1101                	addi	sp,sp,-32
    80003c44:	ec06                	sd	ra,24(sp)
    80003c46:	e822                	sd	s0,16(sp)
    80003c48:	e426                	sd	s1,8(sp)
    80003c4a:	e04a                	sd	s2,0(sp)
    80003c4c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c4e:	c115                	beqz	a0,80003c72 <ilock+0x30>
    80003c50:	84aa                	mv	s1,a0
    80003c52:	451c                	lw	a5,8(a0)
    80003c54:	00f05f63          	blez	a5,80003c72 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c58:	0541                	addi	a0,a0,16
    80003c5a:	00001097          	auipc	ra,0x1
    80003c5e:	ca2080e7          	jalr	-862(ra) # 800048fc <acquiresleep>
  if(ip->valid == 0){
    80003c62:	40bc                	lw	a5,64(s1)
    80003c64:	cf99                	beqz	a5,80003c82 <ilock+0x40>
}
    80003c66:	60e2                	ld	ra,24(sp)
    80003c68:	6442                	ld	s0,16(sp)
    80003c6a:	64a2                	ld	s1,8(sp)
    80003c6c:	6902                	ld	s2,0(sp)
    80003c6e:	6105                	addi	sp,sp,32
    80003c70:	8082                	ret
    panic("ilock");
    80003c72:	00005517          	auipc	a0,0x5
    80003c76:	98650513          	addi	a0,a0,-1658 # 800085f8 <syscalls+0x1a8>
    80003c7a:	ffffd097          	auipc	ra,0xffffd
    80003c7e:	8c4080e7          	jalr	-1852(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c82:	40dc                	lw	a5,4(s1)
    80003c84:	0047d79b          	srliw	a5,a5,0x4
    80003c88:	0001e597          	auipc	a1,0x1e
    80003c8c:	2085a583          	lw	a1,520(a1) # 80021e90 <sb+0x18>
    80003c90:	9dbd                	addw	a1,a1,a5
    80003c92:	4088                	lw	a0,0(s1)
    80003c94:	fffff097          	auipc	ra,0xfffff
    80003c98:	794080e7          	jalr	1940(ra) # 80003428 <bread>
    80003c9c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c9e:	05850593          	addi	a1,a0,88
    80003ca2:	40dc                	lw	a5,4(s1)
    80003ca4:	8bbd                	andi	a5,a5,15
    80003ca6:	079a                	slli	a5,a5,0x6
    80003ca8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003caa:	00059783          	lh	a5,0(a1)
    80003cae:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003cb2:	00259783          	lh	a5,2(a1)
    80003cb6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003cba:	00459783          	lh	a5,4(a1)
    80003cbe:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003cc2:	00659783          	lh	a5,6(a1)
    80003cc6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003cca:	459c                	lw	a5,8(a1)
    80003ccc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003cce:	03400613          	li	a2,52
    80003cd2:	05b1                	addi	a1,a1,12
    80003cd4:	05048513          	addi	a0,s1,80
    80003cd8:	ffffd097          	auipc	ra,0xffffd
    80003cdc:	056080e7          	jalr	86(ra) # 80000d2e <memmove>
    brelse(bp);
    80003ce0:	854a                	mv	a0,s2
    80003ce2:	00000097          	auipc	ra,0x0
    80003ce6:	876080e7          	jalr	-1930(ra) # 80003558 <brelse>
    ip->valid = 1;
    80003cea:	4785                	li	a5,1
    80003cec:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003cee:	04449783          	lh	a5,68(s1)
    80003cf2:	fbb5                	bnez	a5,80003c66 <ilock+0x24>
      panic("ilock: no type");
    80003cf4:	00005517          	auipc	a0,0x5
    80003cf8:	90c50513          	addi	a0,a0,-1780 # 80008600 <syscalls+0x1b0>
    80003cfc:	ffffd097          	auipc	ra,0xffffd
    80003d00:	842080e7          	jalr	-1982(ra) # 8000053e <panic>

0000000080003d04 <iunlock>:
{
    80003d04:	1101                	addi	sp,sp,-32
    80003d06:	ec06                	sd	ra,24(sp)
    80003d08:	e822                	sd	s0,16(sp)
    80003d0a:	e426                	sd	s1,8(sp)
    80003d0c:	e04a                	sd	s2,0(sp)
    80003d0e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d10:	c905                	beqz	a0,80003d40 <iunlock+0x3c>
    80003d12:	84aa                	mv	s1,a0
    80003d14:	01050913          	addi	s2,a0,16
    80003d18:	854a                	mv	a0,s2
    80003d1a:	00001097          	auipc	ra,0x1
    80003d1e:	c7c080e7          	jalr	-900(ra) # 80004996 <holdingsleep>
    80003d22:	cd19                	beqz	a0,80003d40 <iunlock+0x3c>
    80003d24:	449c                	lw	a5,8(s1)
    80003d26:	00f05d63          	blez	a5,80003d40 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d2a:	854a                	mv	a0,s2
    80003d2c:	00001097          	auipc	ra,0x1
    80003d30:	c26080e7          	jalr	-986(ra) # 80004952 <releasesleep>
}
    80003d34:	60e2                	ld	ra,24(sp)
    80003d36:	6442                	ld	s0,16(sp)
    80003d38:	64a2                	ld	s1,8(sp)
    80003d3a:	6902                	ld	s2,0(sp)
    80003d3c:	6105                	addi	sp,sp,32
    80003d3e:	8082                	ret
    panic("iunlock");
    80003d40:	00005517          	auipc	a0,0x5
    80003d44:	8d050513          	addi	a0,a0,-1840 # 80008610 <syscalls+0x1c0>
    80003d48:	ffffc097          	auipc	ra,0xffffc
    80003d4c:	7f6080e7          	jalr	2038(ra) # 8000053e <panic>

0000000080003d50 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d50:	7179                	addi	sp,sp,-48
    80003d52:	f406                	sd	ra,40(sp)
    80003d54:	f022                	sd	s0,32(sp)
    80003d56:	ec26                	sd	s1,24(sp)
    80003d58:	e84a                	sd	s2,16(sp)
    80003d5a:	e44e                	sd	s3,8(sp)
    80003d5c:	e052                	sd	s4,0(sp)
    80003d5e:	1800                	addi	s0,sp,48
    80003d60:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d62:	05050493          	addi	s1,a0,80
    80003d66:	08050913          	addi	s2,a0,128
    80003d6a:	a021                	j	80003d72 <itrunc+0x22>
    80003d6c:	0491                	addi	s1,s1,4
    80003d6e:	01248d63          	beq	s1,s2,80003d88 <itrunc+0x38>
    if(ip->addrs[i]){
    80003d72:	408c                	lw	a1,0(s1)
    80003d74:	dde5                	beqz	a1,80003d6c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d76:	0009a503          	lw	a0,0(s3)
    80003d7a:	00000097          	auipc	ra,0x0
    80003d7e:	8f4080e7          	jalr	-1804(ra) # 8000366e <bfree>
      ip->addrs[i] = 0;
    80003d82:	0004a023          	sw	zero,0(s1)
    80003d86:	b7dd                	j	80003d6c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d88:	0809a583          	lw	a1,128(s3)
    80003d8c:	e185                	bnez	a1,80003dac <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d8e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d92:	854e                	mv	a0,s3
    80003d94:	00000097          	auipc	ra,0x0
    80003d98:	de4080e7          	jalr	-540(ra) # 80003b78 <iupdate>
}
    80003d9c:	70a2                	ld	ra,40(sp)
    80003d9e:	7402                	ld	s0,32(sp)
    80003da0:	64e2                	ld	s1,24(sp)
    80003da2:	6942                	ld	s2,16(sp)
    80003da4:	69a2                	ld	s3,8(sp)
    80003da6:	6a02                	ld	s4,0(sp)
    80003da8:	6145                	addi	sp,sp,48
    80003daa:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003dac:	0009a503          	lw	a0,0(s3)
    80003db0:	fffff097          	auipc	ra,0xfffff
    80003db4:	678080e7          	jalr	1656(ra) # 80003428 <bread>
    80003db8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003dba:	05850493          	addi	s1,a0,88
    80003dbe:	45850913          	addi	s2,a0,1112
    80003dc2:	a021                	j	80003dca <itrunc+0x7a>
    80003dc4:	0491                	addi	s1,s1,4
    80003dc6:	01248b63          	beq	s1,s2,80003ddc <itrunc+0x8c>
      if(a[j])
    80003dca:	408c                	lw	a1,0(s1)
    80003dcc:	dde5                	beqz	a1,80003dc4 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003dce:	0009a503          	lw	a0,0(s3)
    80003dd2:	00000097          	auipc	ra,0x0
    80003dd6:	89c080e7          	jalr	-1892(ra) # 8000366e <bfree>
    80003dda:	b7ed                	j	80003dc4 <itrunc+0x74>
    brelse(bp);
    80003ddc:	8552                	mv	a0,s4
    80003dde:	fffff097          	auipc	ra,0xfffff
    80003de2:	77a080e7          	jalr	1914(ra) # 80003558 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003de6:	0809a583          	lw	a1,128(s3)
    80003dea:	0009a503          	lw	a0,0(s3)
    80003dee:	00000097          	auipc	ra,0x0
    80003df2:	880080e7          	jalr	-1920(ra) # 8000366e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003df6:	0809a023          	sw	zero,128(s3)
    80003dfa:	bf51                	j	80003d8e <itrunc+0x3e>

0000000080003dfc <iput>:
{
    80003dfc:	1101                	addi	sp,sp,-32
    80003dfe:	ec06                	sd	ra,24(sp)
    80003e00:	e822                	sd	s0,16(sp)
    80003e02:	e426                	sd	s1,8(sp)
    80003e04:	e04a                	sd	s2,0(sp)
    80003e06:	1000                	addi	s0,sp,32
    80003e08:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e0a:	0001e517          	auipc	a0,0x1e
    80003e0e:	08e50513          	addi	a0,a0,142 # 80021e98 <itable>
    80003e12:	ffffd097          	auipc	ra,0xffffd
    80003e16:	dc4080e7          	jalr	-572(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e1a:	4498                	lw	a4,8(s1)
    80003e1c:	4785                	li	a5,1
    80003e1e:	02f70363          	beq	a4,a5,80003e44 <iput+0x48>
  ip->ref--;
    80003e22:	449c                	lw	a5,8(s1)
    80003e24:	37fd                	addiw	a5,a5,-1
    80003e26:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e28:	0001e517          	auipc	a0,0x1e
    80003e2c:	07050513          	addi	a0,a0,112 # 80021e98 <itable>
    80003e30:	ffffd097          	auipc	ra,0xffffd
    80003e34:	e5a080e7          	jalr	-422(ra) # 80000c8a <release>
}
    80003e38:	60e2                	ld	ra,24(sp)
    80003e3a:	6442                	ld	s0,16(sp)
    80003e3c:	64a2                	ld	s1,8(sp)
    80003e3e:	6902                	ld	s2,0(sp)
    80003e40:	6105                	addi	sp,sp,32
    80003e42:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e44:	40bc                	lw	a5,64(s1)
    80003e46:	dff1                	beqz	a5,80003e22 <iput+0x26>
    80003e48:	04a49783          	lh	a5,74(s1)
    80003e4c:	fbf9                	bnez	a5,80003e22 <iput+0x26>
    acquiresleep(&ip->lock);
    80003e4e:	01048913          	addi	s2,s1,16
    80003e52:	854a                	mv	a0,s2
    80003e54:	00001097          	auipc	ra,0x1
    80003e58:	aa8080e7          	jalr	-1368(ra) # 800048fc <acquiresleep>
    release(&itable.lock);
    80003e5c:	0001e517          	auipc	a0,0x1e
    80003e60:	03c50513          	addi	a0,a0,60 # 80021e98 <itable>
    80003e64:	ffffd097          	auipc	ra,0xffffd
    80003e68:	e26080e7          	jalr	-474(ra) # 80000c8a <release>
    itrunc(ip);
    80003e6c:	8526                	mv	a0,s1
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	ee2080e7          	jalr	-286(ra) # 80003d50 <itrunc>
    ip->type = 0;
    80003e76:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e7a:	8526                	mv	a0,s1
    80003e7c:	00000097          	auipc	ra,0x0
    80003e80:	cfc080e7          	jalr	-772(ra) # 80003b78 <iupdate>
    ip->valid = 0;
    80003e84:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e88:	854a                	mv	a0,s2
    80003e8a:	00001097          	auipc	ra,0x1
    80003e8e:	ac8080e7          	jalr	-1336(ra) # 80004952 <releasesleep>
    acquire(&itable.lock);
    80003e92:	0001e517          	auipc	a0,0x1e
    80003e96:	00650513          	addi	a0,a0,6 # 80021e98 <itable>
    80003e9a:	ffffd097          	auipc	ra,0xffffd
    80003e9e:	d3c080e7          	jalr	-708(ra) # 80000bd6 <acquire>
    80003ea2:	b741                	j	80003e22 <iput+0x26>

0000000080003ea4 <iunlockput>:
{
    80003ea4:	1101                	addi	sp,sp,-32
    80003ea6:	ec06                	sd	ra,24(sp)
    80003ea8:	e822                	sd	s0,16(sp)
    80003eaa:	e426                	sd	s1,8(sp)
    80003eac:	1000                	addi	s0,sp,32
    80003eae:	84aa                	mv	s1,a0
  iunlock(ip);
    80003eb0:	00000097          	auipc	ra,0x0
    80003eb4:	e54080e7          	jalr	-428(ra) # 80003d04 <iunlock>
  iput(ip);
    80003eb8:	8526                	mv	a0,s1
    80003eba:	00000097          	auipc	ra,0x0
    80003ebe:	f42080e7          	jalr	-190(ra) # 80003dfc <iput>
}
    80003ec2:	60e2                	ld	ra,24(sp)
    80003ec4:	6442                	ld	s0,16(sp)
    80003ec6:	64a2                	ld	s1,8(sp)
    80003ec8:	6105                	addi	sp,sp,32
    80003eca:	8082                	ret

0000000080003ecc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ecc:	1141                	addi	sp,sp,-16
    80003ece:	e422                	sd	s0,8(sp)
    80003ed0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ed2:	411c                	lw	a5,0(a0)
    80003ed4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ed6:	415c                	lw	a5,4(a0)
    80003ed8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003eda:	04451783          	lh	a5,68(a0)
    80003ede:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ee2:	04a51783          	lh	a5,74(a0)
    80003ee6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003eea:	04c56783          	lwu	a5,76(a0)
    80003eee:	e99c                	sd	a5,16(a1)
}
    80003ef0:	6422                	ld	s0,8(sp)
    80003ef2:	0141                	addi	sp,sp,16
    80003ef4:	8082                	ret

0000000080003ef6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ef6:	457c                	lw	a5,76(a0)
    80003ef8:	0ed7e963          	bltu	a5,a3,80003fea <readi+0xf4>
{
    80003efc:	7159                	addi	sp,sp,-112
    80003efe:	f486                	sd	ra,104(sp)
    80003f00:	f0a2                	sd	s0,96(sp)
    80003f02:	eca6                	sd	s1,88(sp)
    80003f04:	e8ca                	sd	s2,80(sp)
    80003f06:	e4ce                	sd	s3,72(sp)
    80003f08:	e0d2                	sd	s4,64(sp)
    80003f0a:	fc56                	sd	s5,56(sp)
    80003f0c:	f85a                	sd	s6,48(sp)
    80003f0e:	f45e                	sd	s7,40(sp)
    80003f10:	f062                	sd	s8,32(sp)
    80003f12:	ec66                	sd	s9,24(sp)
    80003f14:	e86a                	sd	s10,16(sp)
    80003f16:	e46e                	sd	s11,8(sp)
    80003f18:	1880                	addi	s0,sp,112
    80003f1a:	8b2a                	mv	s6,a0
    80003f1c:	8bae                	mv	s7,a1
    80003f1e:	8a32                	mv	s4,a2
    80003f20:	84b6                	mv	s1,a3
    80003f22:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003f24:	9f35                	addw	a4,a4,a3
    return 0;
    80003f26:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f28:	0ad76063          	bltu	a4,a3,80003fc8 <readi+0xd2>
  if(off + n > ip->size)
    80003f2c:	00e7f463          	bgeu	a5,a4,80003f34 <readi+0x3e>
    n = ip->size - off;
    80003f30:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f34:	0a0a8963          	beqz	s5,80003fe6 <readi+0xf0>
    80003f38:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f3a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f3e:	5c7d                	li	s8,-1
    80003f40:	a82d                	j	80003f7a <readi+0x84>
    80003f42:	020d1d93          	slli	s11,s10,0x20
    80003f46:	020ddd93          	srli	s11,s11,0x20
    80003f4a:	05890793          	addi	a5,s2,88
    80003f4e:	86ee                	mv	a3,s11
    80003f50:	963e                	add	a2,a2,a5
    80003f52:	85d2                	mv	a1,s4
    80003f54:	855e                	mv	a0,s7
    80003f56:	ffffe097          	auipc	ra,0xffffe
    80003f5a:	6fa080e7          	jalr	1786(ra) # 80002650 <either_copyout>
    80003f5e:	05850d63          	beq	a0,s8,80003fb8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f62:	854a                	mv	a0,s2
    80003f64:	fffff097          	auipc	ra,0xfffff
    80003f68:	5f4080e7          	jalr	1524(ra) # 80003558 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f6c:	013d09bb          	addw	s3,s10,s3
    80003f70:	009d04bb          	addw	s1,s10,s1
    80003f74:	9a6e                	add	s4,s4,s11
    80003f76:	0559f763          	bgeu	s3,s5,80003fc4 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f7a:	00a4d59b          	srliw	a1,s1,0xa
    80003f7e:	855a                	mv	a0,s6
    80003f80:	00000097          	auipc	ra,0x0
    80003f84:	8a2080e7          	jalr	-1886(ra) # 80003822 <bmap>
    80003f88:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f8c:	cd85                	beqz	a1,80003fc4 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f8e:	000b2503          	lw	a0,0(s6)
    80003f92:	fffff097          	auipc	ra,0xfffff
    80003f96:	496080e7          	jalr	1174(ra) # 80003428 <bread>
    80003f9a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f9c:	3ff4f613          	andi	a2,s1,1023
    80003fa0:	40cc87bb          	subw	a5,s9,a2
    80003fa4:	413a873b          	subw	a4,s5,s3
    80003fa8:	8d3e                	mv	s10,a5
    80003faa:	2781                	sext.w	a5,a5
    80003fac:	0007069b          	sext.w	a3,a4
    80003fb0:	f8f6f9e3          	bgeu	a3,a5,80003f42 <readi+0x4c>
    80003fb4:	8d3a                	mv	s10,a4
    80003fb6:	b771                	j	80003f42 <readi+0x4c>
      brelse(bp);
    80003fb8:	854a                	mv	a0,s2
    80003fba:	fffff097          	auipc	ra,0xfffff
    80003fbe:	59e080e7          	jalr	1438(ra) # 80003558 <brelse>
      tot = -1;
    80003fc2:	59fd                	li	s3,-1
  }
  return tot;
    80003fc4:	0009851b          	sext.w	a0,s3
}
    80003fc8:	70a6                	ld	ra,104(sp)
    80003fca:	7406                	ld	s0,96(sp)
    80003fcc:	64e6                	ld	s1,88(sp)
    80003fce:	6946                	ld	s2,80(sp)
    80003fd0:	69a6                	ld	s3,72(sp)
    80003fd2:	6a06                	ld	s4,64(sp)
    80003fd4:	7ae2                	ld	s5,56(sp)
    80003fd6:	7b42                	ld	s6,48(sp)
    80003fd8:	7ba2                	ld	s7,40(sp)
    80003fda:	7c02                	ld	s8,32(sp)
    80003fdc:	6ce2                	ld	s9,24(sp)
    80003fde:	6d42                	ld	s10,16(sp)
    80003fe0:	6da2                	ld	s11,8(sp)
    80003fe2:	6165                	addi	sp,sp,112
    80003fe4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fe6:	89d6                	mv	s3,s5
    80003fe8:	bff1                	j	80003fc4 <readi+0xce>
    return 0;
    80003fea:	4501                	li	a0,0
}
    80003fec:	8082                	ret

0000000080003fee <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fee:	457c                	lw	a5,76(a0)
    80003ff0:	10d7e863          	bltu	a5,a3,80004100 <writei+0x112>
{
    80003ff4:	7159                	addi	sp,sp,-112
    80003ff6:	f486                	sd	ra,104(sp)
    80003ff8:	f0a2                	sd	s0,96(sp)
    80003ffa:	eca6                	sd	s1,88(sp)
    80003ffc:	e8ca                	sd	s2,80(sp)
    80003ffe:	e4ce                	sd	s3,72(sp)
    80004000:	e0d2                	sd	s4,64(sp)
    80004002:	fc56                	sd	s5,56(sp)
    80004004:	f85a                	sd	s6,48(sp)
    80004006:	f45e                	sd	s7,40(sp)
    80004008:	f062                	sd	s8,32(sp)
    8000400a:	ec66                	sd	s9,24(sp)
    8000400c:	e86a                	sd	s10,16(sp)
    8000400e:	e46e                	sd	s11,8(sp)
    80004010:	1880                	addi	s0,sp,112
    80004012:	8aaa                	mv	s5,a0
    80004014:	8bae                	mv	s7,a1
    80004016:	8a32                	mv	s4,a2
    80004018:	8936                	mv	s2,a3
    8000401a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000401c:	00e687bb          	addw	a5,a3,a4
    80004020:	0ed7e263          	bltu	a5,a3,80004104 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004024:	00043737          	lui	a4,0x43
    80004028:	0ef76063          	bltu	a4,a5,80004108 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000402c:	0c0b0863          	beqz	s6,800040fc <writei+0x10e>
    80004030:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004032:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004036:	5c7d                	li	s8,-1
    80004038:	a091                	j	8000407c <writei+0x8e>
    8000403a:	020d1d93          	slli	s11,s10,0x20
    8000403e:	020ddd93          	srli	s11,s11,0x20
    80004042:	05848793          	addi	a5,s1,88
    80004046:	86ee                	mv	a3,s11
    80004048:	8652                	mv	a2,s4
    8000404a:	85de                	mv	a1,s7
    8000404c:	953e                	add	a0,a0,a5
    8000404e:	ffffe097          	auipc	ra,0xffffe
    80004052:	658080e7          	jalr	1624(ra) # 800026a6 <either_copyin>
    80004056:	07850263          	beq	a0,s8,800040ba <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000405a:	8526                	mv	a0,s1
    8000405c:	00000097          	auipc	ra,0x0
    80004060:	780080e7          	jalr	1920(ra) # 800047dc <log_write>
    brelse(bp);
    80004064:	8526                	mv	a0,s1
    80004066:	fffff097          	auipc	ra,0xfffff
    8000406a:	4f2080e7          	jalr	1266(ra) # 80003558 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000406e:	013d09bb          	addw	s3,s10,s3
    80004072:	012d093b          	addw	s2,s10,s2
    80004076:	9a6e                	add	s4,s4,s11
    80004078:	0569f663          	bgeu	s3,s6,800040c4 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000407c:	00a9559b          	srliw	a1,s2,0xa
    80004080:	8556                	mv	a0,s5
    80004082:	fffff097          	auipc	ra,0xfffff
    80004086:	7a0080e7          	jalr	1952(ra) # 80003822 <bmap>
    8000408a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000408e:	c99d                	beqz	a1,800040c4 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004090:	000aa503          	lw	a0,0(s5)
    80004094:	fffff097          	auipc	ra,0xfffff
    80004098:	394080e7          	jalr	916(ra) # 80003428 <bread>
    8000409c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000409e:	3ff97513          	andi	a0,s2,1023
    800040a2:	40ac87bb          	subw	a5,s9,a0
    800040a6:	413b073b          	subw	a4,s6,s3
    800040aa:	8d3e                	mv	s10,a5
    800040ac:	2781                	sext.w	a5,a5
    800040ae:	0007069b          	sext.w	a3,a4
    800040b2:	f8f6f4e3          	bgeu	a3,a5,8000403a <writei+0x4c>
    800040b6:	8d3a                	mv	s10,a4
    800040b8:	b749                	j	8000403a <writei+0x4c>
      brelse(bp);
    800040ba:	8526                	mv	a0,s1
    800040bc:	fffff097          	auipc	ra,0xfffff
    800040c0:	49c080e7          	jalr	1180(ra) # 80003558 <brelse>
  }

  if(off > ip->size)
    800040c4:	04caa783          	lw	a5,76(s5)
    800040c8:	0127f463          	bgeu	a5,s2,800040d0 <writei+0xe2>
    ip->size = off;
    800040cc:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800040d0:	8556                	mv	a0,s5
    800040d2:	00000097          	auipc	ra,0x0
    800040d6:	aa6080e7          	jalr	-1370(ra) # 80003b78 <iupdate>

  return tot;
    800040da:	0009851b          	sext.w	a0,s3
}
    800040de:	70a6                	ld	ra,104(sp)
    800040e0:	7406                	ld	s0,96(sp)
    800040e2:	64e6                	ld	s1,88(sp)
    800040e4:	6946                	ld	s2,80(sp)
    800040e6:	69a6                	ld	s3,72(sp)
    800040e8:	6a06                	ld	s4,64(sp)
    800040ea:	7ae2                	ld	s5,56(sp)
    800040ec:	7b42                	ld	s6,48(sp)
    800040ee:	7ba2                	ld	s7,40(sp)
    800040f0:	7c02                	ld	s8,32(sp)
    800040f2:	6ce2                	ld	s9,24(sp)
    800040f4:	6d42                	ld	s10,16(sp)
    800040f6:	6da2                	ld	s11,8(sp)
    800040f8:	6165                	addi	sp,sp,112
    800040fa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040fc:	89da                	mv	s3,s6
    800040fe:	bfc9                	j	800040d0 <writei+0xe2>
    return -1;
    80004100:	557d                	li	a0,-1
}
    80004102:	8082                	ret
    return -1;
    80004104:	557d                	li	a0,-1
    80004106:	bfe1                	j	800040de <writei+0xf0>
    return -1;
    80004108:	557d                	li	a0,-1
    8000410a:	bfd1                	j	800040de <writei+0xf0>

000000008000410c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000410c:	1141                	addi	sp,sp,-16
    8000410e:	e406                	sd	ra,8(sp)
    80004110:	e022                	sd	s0,0(sp)
    80004112:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004114:	4639                	li	a2,14
    80004116:	ffffd097          	auipc	ra,0xffffd
    8000411a:	c8c080e7          	jalr	-884(ra) # 80000da2 <strncmp>
}
    8000411e:	60a2                	ld	ra,8(sp)
    80004120:	6402                	ld	s0,0(sp)
    80004122:	0141                	addi	sp,sp,16
    80004124:	8082                	ret

0000000080004126 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004126:	7139                	addi	sp,sp,-64
    80004128:	fc06                	sd	ra,56(sp)
    8000412a:	f822                	sd	s0,48(sp)
    8000412c:	f426                	sd	s1,40(sp)
    8000412e:	f04a                	sd	s2,32(sp)
    80004130:	ec4e                	sd	s3,24(sp)
    80004132:	e852                	sd	s4,16(sp)
    80004134:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004136:	04451703          	lh	a4,68(a0)
    8000413a:	4785                	li	a5,1
    8000413c:	00f71a63          	bne	a4,a5,80004150 <dirlookup+0x2a>
    80004140:	892a                	mv	s2,a0
    80004142:	89ae                	mv	s3,a1
    80004144:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004146:	457c                	lw	a5,76(a0)
    80004148:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000414a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000414c:	e79d                	bnez	a5,8000417a <dirlookup+0x54>
    8000414e:	a8a5                	j	800041c6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004150:	00004517          	auipc	a0,0x4
    80004154:	4c850513          	addi	a0,a0,1224 # 80008618 <syscalls+0x1c8>
    80004158:	ffffc097          	auipc	ra,0xffffc
    8000415c:	3e6080e7          	jalr	998(ra) # 8000053e <panic>
      panic("dirlookup read");
    80004160:	00004517          	auipc	a0,0x4
    80004164:	4d050513          	addi	a0,a0,1232 # 80008630 <syscalls+0x1e0>
    80004168:	ffffc097          	auipc	ra,0xffffc
    8000416c:	3d6080e7          	jalr	982(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004170:	24c1                	addiw	s1,s1,16
    80004172:	04c92783          	lw	a5,76(s2)
    80004176:	04f4f763          	bgeu	s1,a5,800041c4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000417a:	4741                	li	a4,16
    8000417c:	86a6                	mv	a3,s1
    8000417e:	fc040613          	addi	a2,s0,-64
    80004182:	4581                	li	a1,0
    80004184:	854a                	mv	a0,s2
    80004186:	00000097          	auipc	ra,0x0
    8000418a:	d70080e7          	jalr	-656(ra) # 80003ef6 <readi>
    8000418e:	47c1                	li	a5,16
    80004190:	fcf518e3          	bne	a0,a5,80004160 <dirlookup+0x3a>
    if(de.inum == 0)
    80004194:	fc045783          	lhu	a5,-64(s0)
    80004198:	dfe1                	beqz	a5,80004170 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000419a:	fc240593          	addi	a1,s0,-62
    8000419e:	854e                	mv	a0,s3
    800041a0:	00000097          	auipc	ra,0x0
    800041a4:	f6c080e7          	jalr	-148(ra) # 8000410c <namecmp>
    800041a8:	f561                	bnez	a0,80004170 <dirlookup+0x4a>
      if(poff)
    800041aa:	000a0463          	beqz	s4,800041b2 <dirlookup+0x8c>
        *poff = off;
    800041ae:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800041b2:	fc045583          	lhu	a1,-64(s0)
    800041b6:	00092503          	lw	a0,0(s2)
    800041ba:	fffff097          	auipc	ra,0xfffff
    800041be:	750080e7          	jalr	1872(ra) # 8000390a <iget>
    800041c2:	a011                	j	800041c6 <dirlookup+0xa0>
  return 0;
    800041c4:	4501                	li	a0,0
}
    800041c6:	70e2                	ld	ra,56(sp)
    800041c8:	7442                	ld	s0,48(sp)
    800041ca:	74a2                	ld	s1,40(sp)
    800041cc:	7902                	ld	s2,32(sp)
    800041ce:	69e2                	ld	s3,24(sp)
    800041d0:	6a42                	ld	s4,16(sp)
    800041d2:	6121                	addi	sp,sp,64
    800041d4:	8082                	ret

00000000800041d6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800041d6:	711d                	addi	sp,sp,-96
    800041d8:	ec86                	sd	ra,88(sp)
    800041da:	e8a2                	sd	s0,80(sp)
    800041dc:	e4a6                	sd	s1,72(sp)
    800041de:	e0ca                	sd	s2,64(sp)
    800041e0:	fc4e                	sd	s3,56(sp)
    800041e2:	f852                	sd	s4,48(sp)
    800041e4:	f456                	sd	s5,40(sp)
    800041e6:	f05a                	sd	s6,32(sp)
    800041e8:	ec5e                	sd	s7,24(sp)
    800041ea:	e862                	sd	s8,16(sp)
    800041ec:	e466                	sd	s9,8(sp)
    800041ee:	1080                	addi	s0,sp,96
    800041f0:	84aa                	mv	s1,a0
    800041f2:	8aae                	mv	s5,a1
    800041f4:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800041f6:	00054703          	lbu	a4,0(a0)
    800041fa:	02f00793          	li	a5,47
    800041fe:	02f70363          	beq	a4,a5,80004224 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004202:	ffffd097          	auipc	ra,0xffffd
    80004206:	7e8080e7          	jalr	2024(ra) # 800019ea <myproc>
    8000420a:	15053503          	ld	a0,336(a0)
    8000420e:	00000097          	auipc	ra,0x0
    80004212:	9f6080e7          	jalr	-1546(ra) # 80003c04 <idup>
    80004216:	89aa                	mv	s3,a0
  while(*path == '/')
    80004218:	02f00913          	li	s2,47
  len = path - s;
    8000421c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    8000421e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004220:	4b85                	li	s7,1
    80004222:	a865                	j	800042da <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004224:	4585                	li	a1,1
    80004226:	4505                	li	a0,1
    80004228:	fffff097          	auipc	ra,0xfffff
    8000422c:	6e2080e7          	jalr	1762(ra) # 8000390a <iget>
    80004230:	89aa                	mv	s3,a0
    80004232:	b7dd                	j	80004218 <namex+0x42>
      iunlockput(ip);
    80004234:	854e                	mv	a0,s3
    80004236:	00000097          	auipc	ra,0x0
    8000423a:	c6e080e7          	jalr	-914(ra) # 80003ea4 <iunlockput>
      return 0;
    8000423e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004240:	854e                	mv	a0,s3
    80004242:	60e6                	ld	ra,88(sp)
    80004244:	6446                	ld	s0,80(sp)
    80004246:	64a6                	ld	s1,72(sp)
    80004248:	6906                	ld	s2,64(sp)
    8000424a:	79e2                	ld	s3,56(sp)
    8000424c:	7a42                	ld	s4,48(sp)
    8000424e:	7aa2                	ld	s5,40(sp)
    80004250:	7b02                	ld	s6,32(sp)
    80004252:	6be2                	ld	s7,24(sp)
    80004254:	6c42                	ld	s8,16(sp)
    80004256:	6ca2                	ld	s9,8(sp)
    80004258:	6125                	addi	sp,sp,96
    8000425a:	8082                	ret
      iunlock(ip);
    8000425c:	854e                	mv	a0,s3
    8000425e:	00000097          	auipc	ra,0x0
    80004262:	aa6080e7          	jalr	-1370(ra) # 80003d04 <iunlock>
      return ip;
    80004266:	bfe9                	j	80004240 <namex+0x6a>
      iunlockput(ip);
    80004268:	854e                	mv	a0,s3
    8000426a:	00000097          	auipc	ra,0x0
    8000426e:	c3a080e7          	jalr	-966(ra) # 80003ea4 <iunlockput>
      return 0;
    80004272:	89e6                	mv	s3,s9
    80004274:	b7f1                	j	80004240 <namex+0x6a>
  len = path - s;
    80004276:	40b48633          	sub	a2,s1,a1
    8000427a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000427e:	099c5463          	bge	s8,s9,80004306 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004282:	4639                	li	a2,14
    80004284:	8552                	mv	a0,s4
    80004286:	ffffd097          	auipc	ra,0xffffd
    8000428a:	aa8080e7          	jalr	-1368(ra) # 80000d2e <memmove>
  while(*path == '/')
    8000428e:	0004c783          	lbu	a5,0(s1)
    80004292:	01279763          	bne	a5,s2,800042a0 <namex+0xca>
    path++;
    80004296:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004298:	0004c783          	lbu	a5,0(s1)
    8000429c:	ff278de3          	beq	a5,s2,80004296 <namex+0xc0>
    ilock(ip);
    800042a0:	854e                	mv	a0,s3
    800042a2:	00000097          	auipc	ra,0x0
    800042a6:	9a0080e7          	jalr	-1632(ra) # 80003c42 <ilock>
    if(ip->type != T_DIR){
    800042aa:	04499783          	lh	a5,68(s3)
    800042ae:	f97793e3          	bne	a5,s7,80004234 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800042b2:	000a8563          	beqz	s5,800042bc <namex+0xe6>
    800042b6:	0004c783          	lbu	a5,0(s1)
    800042ba:	d3cd                	beqz	a5,8000425c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800042bc:	865a                	mv	a2,s6
    800042be:	85d2                	mv	a1,s4
    800042c0:	854e                	mv	a0,s3
    800042c2:	00000097          	auipc	ra,0x0
    800042c6:	e64080e7          	jalr	-412(ra) # 80004126 <dirlookup>
    800042ca:	8caa                	mv	s9,a0
    800042cc:	dd51                	beqz	a0,80004268 <namex+0x92>
    iunlockput(ip);
    800042ce:	854e                	mv	a0,s3
    800042d0:	00000097          	auipc	ra,0x0
    800042d4:	bd4080e7          	jalr	-1068(ra) # 80003ea4 <iunlockput>
    ip = next;
    800042d8:	89e6                	mv	s3,s9
  while(*path == '/')
    800042da:	0004c783          	lbu	a5,0(s1)
    800042de:	05279763          	bne	a5,s2,8000432c <namex+0x156>
    path++;
    800042e2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042e4:	0004c783          	lbu	a5,0(s1)
    800042e8:	ff278de3          	beq	a5,s2,800042e2 <namex+0x10c>
  if(*path == 0)
    800042ec:	c79d                	beqz	a5,8000431a <namex+0x144>
    path++;
    800042ee:	85a6                	mv	a1,s1
  len = path - s;
    800042f0:	8cda                	mv	s9,s6
    800042f2:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800042f4:	01278963          	beq	a5,s2,80004306 <namex+0x130>
    800042f8:	dfbd                	beqz	a5,80004276 <namex+0xa0>
    path++;
    800042fa:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800042fc:	0004c783          	lbu	a5,0(s1)
    80004300:	ff279ce3          	bne	a5,s2,800042f8 <namex+0x122>
    80004304:	bf8d                	j	80004276 <namex+0xa0>
    memmove(name, s, len);
    80004306:	2601                	sext.w	a2,a2
    80004308:	8552                	mv	a0,s4
    8000430a:	ffffd097          	auipc	ra,0xffffd
    8000430e:	a24080e7          	jalr	-1500(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004312:	9cd2                	add	s9,s9,s4
    80004314:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004318:	bf9d                	j	8000428e <namex+0xb8>
  if(nameiparent){
    8000431a:	f20a83e3          	beqz	s5,80004240 <namex+0x6a>
    iput(ip);
    8000431e:	854e                	mv	a0,s3
    80004320:	00000097          	auipc	ra,0x0
    80004324:	adc080e7          	jalr	-1316(ra) # 80003dfc <iput>
    return 0;
    80004328:	4981                	li	s3,0
    8000432a:	bf19                	j	80004240 <namex+0x6a>
  if(*path == 0)
    8000432c:	d7fd                	beqz	a5,8000431a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000432e:	0004c783          	lbu	a5,0(s1)
    80004332:	85a6                	mv	a1,s1
    80004334:	b7d1                	j	800042f8 <namex+0x122>

0000000080004336 <dirlink>:
{
    80004336:	7139                	addi	sp,sp,-64
    80004338:	fc06                	sd	ra,56(sp)
    8000433a:	f822                	sd	s0,48(sp)
    8000433c:	f426                	sd	s1,40(sp)
    8000433e:	f04a                	sd	s2,32(sp)
    80004340:	ec4e                	sd	s3,24(sp)
    80004342:	e852                	sd	s4,16(sp)
    80004344:	0080                	addi	s0,sp,64
    80004346:	892a                	mv	s2,a0
    80004348:	8a2e                	mv	s4,a1
    8000434a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000434c:	4601                	li	a2,0
    8000434e:	00000097          	auipc	ra,0x0
    80004352:	dd8080e7          	jalr	-552(ra) # 80004126 <dirlookup>
    80004356:	e93d                	bnez	a0,800043cc <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004358:	04c92483          	lw	s1,76(s2)
    8000435c:	c49d                	beqz	s1,8000438a <dirlink+0x54>
    8000435e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004360:	4741                	li	a4,16
    80004362:	86a6                	mv	a3,s1
    80004364:	fc040613          	addi	a2,s0,-64
    80004368:	4581                	li	a1,0
    8000436a:	854a                	mv	a0,s2
    8000436c:	00000097          	auipc	ra,0x0
    80004370:	b8a080e7          	jalr	-1142(ra) # 80003ef6 <readi>
    80004374:	47c1                	li	a5,16
    80004376:	06f51163          	bne	a0,a5,800043d8 <dirlink+0xa2>
    if(de.inum == 0)
    8000437a:	fc045783          	lhu	a5,-64(s0)
    8000437e:	c791                	beqz	a5,8000438a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004380:	24c1                	addiw	s1,s1,16
    80004382:	04c92783          	lw	a5,76(s2)
    80004386:	fcf4ede3          	bltu	s1,a5,80004360 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000438a:	4639                	li	a2,14
    8000438c:	85d2                	mv	a1,s4
    8000438e:	fc240513          	addi	a0,s0,-62
    80004392:	ffffd097          	auipc	ra,0xffffd
    80004396:	a4c080e7          	jalr	-1460(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000439a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000439e:	4741                	li	a4,16
    800043a0:	86a6                	mv	a3,s1
    800043a2:	fc040613          	addi	a2,s0,-64
    800043a6:	4581                	li	a1,0
    800043a8:	854a                	mv	a0,s2
    800043aa:	00000097          	auipc	ra,0x0
    800043ae:	c44080e7          	jalr	-956(ra) # 80003fee <writei>
    800043b2:	1541                	addi	a0,a0,-16
    800043b4:	00a03533          	snez	a0,a0
    800043b8:	40a00533          	neg	a0,a0
}
    800043bc:	70e2                	ld	ra,56(sp)
    800043be:	7442                	ld	s0,48(sp)
    800043c0:	74a2                	ld	s1,40(sp)
    800043c2:	7902                	ld	s2,32(sp)
    800043c4:	69e2                	ld	s3,24(sp)
    800043c6:	6a42                	ld	s4,16(sp)
    800043c8:	6121                	addi	sp,sp,64
    800043ca:	8082                	ret
    iput(ip);
    800043cc:	00000097          	auipc	ra,0x0
    800043d0:	a30080e7          	jalr	-1488(ra) # 80003dfc <iput>
    return -1;
    800043d4:	557d                	li	a0,-1
    800043d6:	b7dd                	j	800043bc <dirlink+0x86>
      panic("dirlink read");
    800043d8:	00004517          	auipc	a0,0x4
    800043dc:	26850513          	addi	a0,a0,616 # 80008640 <syscalls+0x1f0>
    800043e0:	ffffc097          	auipc	ra,0xffffc
    800043e4:	15e080e7          	jalr	350(ra) # 8000053e <panic>

00000000800043e8 <namei>:

struct inode*
namei(char *path)
{
    800043e8:	1101                	addi	sp,sp,-32
    800043ea:	ec06                	sd	ra,24(sp)
    800043ec:	e822                	sd	s0,16(sp)
    800043ee:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043f0:	fe040613          	addi	a2,s0,-32
    800043f4:	4581                	li	a1,0
    800043f6:	00000097          	auipc	ra,0x0
    800043fa:	de0080e7          	jalr	-544(ra) # 800041d6 <namex>
}
    800043fe:	60e2                	ld	ra,24(sp)
    80004400:	6442                	ld	s0,16(sp)
    80004402:	6105                	addi	sp,sp,32
    80004404:	8082                	ret

0000000080004406 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004406:	1141                	addi	sp,sp,-16
    80004408:	e406                	sd	ra,8(sp)
    8000440a:	e022                	sd	s0,0(sp)
    8000440c:	0800                	addi	s0,sp,16
    8000440e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004410:	4585                	li	a1,1
    80004412:	00000097          	auipc	ra,0x0
    80004416:	dc4080e7          	jalr	-572(ra) # 800041d6 <namex>
}
    8000441a:	60a2                	ld	ra,8(sp)
    8000441c:	6402                	ld	s0,0(sp)
    8000441e:	0141                	addi	sp,sp,16
    80004420:	8082                	ret

0000000080004422 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004422:	1101                	addi	sp,sp,-32
    80004424:	ec06                	sd	ra,24(sp)
    80004426:	e822                	sd	s0,16(sp)
    80004428:	e426                	sd	s1,8(sp)
    8000442a:	e04a                	sd	s2,0(sp)
    8000442c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000442e:	0001f917          	auipc	s2,0x1f
    80004432:	51290913          	addi	s2,s2,1298 # 80023940 <log>
    80004436:	01892583          	lw	a1,24(s2)
    8000443a:	02892503          	lw	a0,40(s2)
    8000443e:	fffff097          	auipc	ra,0xfffff
    80004442:	fea080e7          	jalr	-22(ra) # 80003428 <bread>
    80004446:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004448:	02c92683          	lw	a3,44(s2)
    8000444c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000444e:	02d05763          	blez	a3,8000447c <write_head+0x5a>
    80004452:	0001f797          	auipc	a5,0x1f
    80004456:	51e78793          	addi	a5,a5,1310 # 80023970 <log+0x30>
    8000445a:	05c50713          	addi	a4,a0,92
    8000445e:	36fd                	addiw	a3,a3,-1
    80004460:	1682                	slli	a3,a3,0x20
    80004462:	9281                	srli	a3,a3,0x20
    80004464:	068a                	slli	a3,a3,0x2
    80004466:	0001f617          	auipc	a2,0x1f
    8000446a:	50e60613          	addi	a2,a2,1294 # 80023974 <log+0x34>
    8000446e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004470:	4390                	lw	a2,0(a5)
    80004472:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004474:	0791                	addi	a5,a5,4
    80004476:	0711                	addi	a4,a4,4
    80004478:	fed79ce3          	bne	a5,a3,80004470 <write_head+0x4e>
  }
  bwrite(buf);
    8000447c:	8526                	mv	a0,s1
    8000447e:	fffff097          	auipc	ra,0xfffff
    80004482:	09c080e7          	jalr	156(ra) # 8000351a <bwrite>
  brelse(buf);
    80004486:	8526                	mv	a0,s1
    80004488:	fffff097          	auipc	ra,0xfffff
    8000448c:	0d0080e7          	jalr	208(ra) # 80003558 <brelse>
}
    80004490:	60e2                	ld	ra,24(sp)
    80004492:	6442                	ld	s0,16(sp)
    80004494:	64a2                	ld	s1,8(sp)
    80004496:	6902                	ld	s2,0(sp)
    80004498:	6105                	addi	sp,sp,32
    8000449a:	8082                	ret

000000008000449c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000449c:	0001f797          	auipc	a5,0x1f
    800044a0:	4d07a783          	lw	a5,1232(a5) # 8002396c <log+0x2c>
    800044a4:	0af05d63          	blez	a5,8000455e <install_trans+0xc2>
{
    800044a8:	7139                	addi	sp,sp,-64
    800044aa:	fc06                	sd	ra,56(sp)
    800044ac:	f822                	sd	s0,48(sp)
    800044ae:	f426                	sd	s1,40(sp)
    800044b0:	f04a                	sd	s2,32(sp)
    800044b2:	ec4e                	sd	s3,24(sp)
    800044b4:	e852                	sd	s4,16(sp)
    800044b6:	e456                	sd	s5,8(sp)
    800044b8:	e05a                	sd	s6,0(sp)
    800044ba:	0080                	addi	s0,sp,64
    800044bc:	8b2a                	mv	s6,a0
    800044be:	0001fa97          	auipc	s5,0x1f
    800044c2:	4b2a8a93          	addi	s5,s5,1202 # 80023970 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044c6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044c8:	0001f997          	auipc	s3,0x1f
    800044cc:	47898993          	addi	s3,s3,1144 # 80023940 <log>
    800044d0:	a00d                	j	800044f2 <install_trans+0x56>
    brelse(lbuf);
    800044d2:	854a                	mv	a0,s2
    800044d4:	fffff097          	auipc	ra,0xfffff
    800044d8:	084080e7          	jalr	132(ra) # 80003558 <brelse>
    brelse(dbuf);
    800044dc:	8526                	mv	a0,s1
    800044de:	fffff097          	auipc	ra,0xfffff
    800044e2:	07a080e7          	jalr	122(ra) # 80003558 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044e6:	2a05                	addiw	s4,s4,1
    800044e8:	0a91                	addi	s5,s5,4
    800044ea:	02c9a783          	lw	a5,44(s3)
    800044ee:	04fa5e63          	bge	s4,a5,8000454a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044f2:	0189a583          	lw	a1,24(s3)
    800044f6:	014585bb          	addw	a1,a1,s4
    800044fa:	2585                	addiw	a1,a1,1
    800044fc:	0289a503          	lw	a0,40(s3)
    80004500:	fffff097          	auipc	ra,0xfffff
    80004504:	f28080e7          	jalr	-216(ra) # 80003428 <bread>
    80004508:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000450a:	000aa583          	lw	a1,0(s5)
    8000450e:	0289a503          	lw	a0,40(s3)
    80004512:	fffff097          	auipc	ra,0xfffff
    80004516:	f16080e7          	jalr	-234(ra) # 80003428 <bread>
    8000451a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000451c:	40000613          	li	a2,1024
    80004520:	05890593          	addi	a1,s2,88
    80004524:	05850513          	addi	a0,a0,88
    80004528:	ffffd097          	auipc	ra,0xffffd
    8000452c:	806080e7          	jalr	-2042(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004530:	8526                	mv	a0,s1
    80004532:	fffff097          	auipc	ra,0xfffff
    80004536:	fe8080e7          	jalr	-24(ra) # 8000351a <bwrite>
    if(recovering == 0)
    8000453a:	f80b1ce3          	bnez	s6,800044d2 <install_trans+0x36>
      bunpin(dbuf);
    8000453e:	8526                	mv	a0,s1
    80004540:	fffff097          	auipc	ra,0xfffff
    80004544:	0f2080e7          	jalr	242(ra) # 80003632 <bunpin>
    80004548:	b769                	j	800044d2 <install_trans+0x36>
}
    8000454a:	70e2                	ld	ra,56(sp)
    8000454c:	7442                	ld	s0,48(sp)
    8000454e:	74a2                	ld	s1,40(sp)
    80004550:	7902                	ld	s2,32(sp)
    80004552:	69e2                	ld	s3,24(sp)
    80004554:	6a42                	ld	s4,16(sp)
    80004556:	6aa2                	ld	s5,8(sp)
    80004558:	6b02                	ld	s6,0(sp)
    8000455a:	6121                	addi	sp,sp,64
    8000455c:	8082                	ret
    8000455e:	8082                	ret

0000000080004560 <initlog>:
{
    80004560:	7179                	addi	sp,sp,-48
    80004562:	f406                	sd	ra,40(sp)
    80004564:	f022                	sd	s0,32(sp)
    80004566:	ec26                	sd	s1,24(sp)
    80004568:	e84a                	sd	s2,16(sp)
    8000456a:	e44e                	sd	s3,8(sp)
    8000456c:	1800                	addi	s0,sp,48
    8000456e:	892a                	mv	s2,a0
    80004570:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004572:	0001f497          	auipc	s1,0x1f
    80004576:	3ce48493          	addi	s1,s1,974 # 80023940 <log>
    8000457a:	00004597          	auipc	a1,0x4
    8000457e:	0d658593          	addi	a1,a1,214 # 80008650 <syscalls+0x200>
    80004582:	8526                	mv	a0,s1
    80004584:	ffffc097          	auipc	ra,0xffffc
    80004588:	5c2080e7          	jalr	1474(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    8000458c:	0149a583          	lw	a1,20(s3)
    80004590:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004592:	0109a783          	lw	a5,16(s3)
    80004596:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004598:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000459c:	854a                	mv	a0,s2
    8000459e:	fffff097          	auipc	ra,0xfffff
    800045a2:	e8a080e7          	jalr	-374(ra) # 80003428 <bread>
  log.lh.n = lh->n;
    800045a6:	4d34                	lw	a3,88(a0)
    800045a8:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800045aa:	02d05563          	blez	a3,800045d4 <initlog+0x74>
    800045ae:	05c50793          	addi	a5,a0,92
    800045b2:	0001f717          	auipc	a4,0x1f
    800045b6:	3be70713          	addi	a4,a4,958 # 80023970 <log+0x30>
    800045ba:	36fd                	addiw	a3,a3,-1
    800045bc:	1682                	slli	a3,a3,0x20
    800045be:	9281                	srli	a3,a3,0x20
    800045c0:	068a                	slli	a3,a3,0x2
    800045c2:	06050613          	addi	a2,a0,96
    800045c6:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800045c8:	4390                	lw	a2,0(a5)
    800045ca:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045cc:	0791                	addi	a5,a5,4
    800045ce:	0711                	addi	a4,a4,4
    800045d0:	fed79ce3          	bne	a5,a3,800045c8 <initlog+0x68>
  brelse(buf);
    800045d4:	fffff097          	auipc	ra,0xfffff
    800045d8:	f84080e7          	jalr	-124(ra) # 80003558 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800045dc:	4505                	li	a0,1
    800045de:	00000097          	auipc	ra,0x0
    800045e2:	ebe080e7          	jalr	-322(ra) # 8000449c <install_trans>
  log.lh.n = 0;
    800045e6:	0001f797          	auipc	a5,0x1f
    800045ea:	3807a323          	sw	zero,902(a5) # 8002396c <log+0x2c>
  write_head(); // clear the log
    800045ee:	00000097          	auipc	ra,0x0
    800045f2:	e34080e7          	jalr	-460(ra) # 80004422 <write_head>
}
    800045f6:	70a2                	ld	ra,40(sp)
    800045f8:	7402                	ld	s0,32(sp)
    800045fa:	64e2                	ld	s1,24(sp)
    800045fc:	6942                	ld	s2,16(sp)
    800045fe:	69a2                	ld	s3,8(sp)
    80004600:	6145                	addi	sp,sp,48
    80004602:	8082                	ret

0000000080004604 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004604:	1101                	addi	sp,sp,-32
    80004606:	ec06                	sd	ra,24(sp)
    80004608:	e822                	sd	s0,16(sp)
    8000460a:	e426                	sd	s1,8(sp)
    8000460c:	e04a                	sd	s2,0(sp)
    8000460e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004610:	0001f517          	auipc	a0,0x1f
    80004614:	33050513          	addi	a0,a0,816 # 80023940 <log>
    80004618:	ffffc097          	auipc	ra,0xffffc
    8000461c:	5be080e7          	jalr	1470(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004620:	0001f497          	auipc	s1,0x1f
    80004624:	32048493          	addi	s1,s1,800 # 80023940 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004628:	4979                	li	s2,30
    8000462a:	a039                	j	80004638 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000462c:	85a6                	mv	a1,s1
    8000462e:	8526                	mv	a0,s1
    80004630:	ffffe097          	auipc	ra,0xffffe
    80004634:	bf0080e7          	jalr	-1040(ra) # 80002220 <sleep>
    if(log.committing){
    80004638:	50dc                	lw	a5,36(s1)
    8000463a:	fbed                	bnez	a5,8000462c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000463c:	509c                	lw	a5,32(s1)
    8000463e:	0017871b          	addiw	a4,a5,1
    80004642:	0007069b          	sext.w	a3,a4
    80004646:	0027179b          	slliw	a5,a4,0x2
    8000464a:	9fb9                	addw	a5,a5,a4
    8000464c:	0017979b          	slliw	a5,a5,0x1
    80004650:	54d8                	lw	a4,44(s1)
    80004652:	9fb9                	addw	a5,a5,a4
    80004654:	00f95963          	bge	s2,a5,80004666 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004658:	85a6                	mv	a1,s1
    8000465a:	8526                	mv	a0,s1
    8000465c:	ffffe097          	auipc	ra,0xffffe
    80004660:	bc4080e7          	jalr	-1084(ra) # 80002220 <sleep>
    80004664:	bfd1                	j	80004638 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004666:	0001f517          	auipc	a0,0x1f
    8000466a:	2da50513          	addi	a0,a0,730 # 80023940 <log>
    8000466e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004670:	ffffc097          	auipc	ra,0xffffc
    80004674:	61a080e7          	jalr	1562(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004678:	60e2                	ld	ra,24(sp)
    8000467a:	6442                	ld	s0,16(sp)
    8000467c:	64a2                	ld	s1,8(sp)
    8000467e:	6902                	ld	s2,0(sp)
    80004680:	6105                	addi	sp,sp,32
    80004682:	8082                	ret

0000000080004684 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004684:	7139                	addi	sp,sp,-64
    80004686:	fc06                	sd	ra,56(sp)
    80004688:	f822                	sd	s0,48(sp)
    8000468a:	f426                	sd	s1,40(sp)
    8000468c:	f04a                	sd	s2,32(sp)
    8000468e:	ec4e                	sd	s3,24(sp)
    80004690:	e852                	sd	s4,16(sp)
    80004692:	e456                	sd	s5,8(sp)
    80004694:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004696:	0001f497          	auipc	s1,0x1f
    8000469a:	2aa48493          	addi	s1,s1,682 # 80023940 <log>
    8000469e:	8526                	mv	a0,s1
    800046a0:	ffffc097          	auipc	ra,0xffffc
    800046a4:	536080e7          	jalr	1334(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800046a8:	509c                	lw	a5,32(s1)
    800046aa:	37fd                	addiw	a5,a5,-1
    800046ac:	0007891b          	sext.w	s2,a5
    800046b0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800046b2:	50dc                	lw	a5,36(s1)
    800046b4:	e7b9                	bnez	a5,80004702 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800046b6:	04091e63          	bnez	s2,80004712 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800046ba:	0001f497          	auipc	s1,0x1f
    800046be:	28648493          	addi	s1,s1,646 # 80023940 <log>
    800046c2:	4785                	li	a5,1
    800046c4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800046c6:	8526                	mv	a0,s1
    800046c8:	ffffc097          	auipc	ra,0xffffc
    800046cc:	5c2080e7          	jalr	1474(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800046d0:	54dc                	lw	a5,44(s1)
    800046d2:	06f04763          	bgtz	a5,80004740 <end_op+0xbc>
    acquire(&log.lock);
    800046d6:	0001f497          	auipc	s1,0x1f
    800046da:	26a48493          	addi	s1,s1,618 # 80023940 <log>
    800046de:	8526                	mv	a0,s1
    800046e0:	ffffc097          	auipc	ra,0xffffc
    800046e4:	4f6080e7          	jalr	1270(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800046e8:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800046ec:	8526                	mv	a0,s1
    800046ee:	ffffe097          	auipc	ra,0xffffe
    800046f2:	b96080e7          	jalr	-1130(ra) # 80002284 <wakeup>
    release(&log.lock);
    800046f6:	8526                	mv	a0,s1
    800046f8:	ffffc097          	auipc	ra,0xffffc
    800046fc:	592080e7          	jalr	1426(ra) # 80000c8a <release>
}
    80004700:	a03d                	j	8000472e <end_op+0xaa>
    panic("log.committing");
    80004702:	00004517          	auipc	a0,0x4
    80004706:	f5650513          	addi	a0,a0,-170 # 80008658 <syscalls+0x208>
    8000470a:	ffffc097          	auipc	ra,0xffffc
    8000470e:	e34080e7          	jalr	-460(ra) # 8000053e <panic>
    wakeup(&log);
    80004712:	0001f497          	auipc	s1,0x1f
    80004716:	22e48493          	addi	s1,s1,558 # 80023940 <log>
    8000471a:	8526                	mv	a0,s1
    8000471c:	ffffe097          	auipc	ra,0xffffe
    80004720:	b68080e7          	jalr	-1176(ra) # 80002284 <wakeup>
  release(&log.lock);
    80004724:	8526                	mv	a0,s1
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	564080e7          	jalr	1380(ra) # 80000c8a <release>
}
    8000472e:	70e2                	ld	ra,56(sp)
    80004730:	7442                	ld	s0,48(sp)
    80004732:	74a2                	ld	s1,40(sp)
    80004734:	7902                	ld	s2,32(sp)
    80004736:	69e2                	ld	s3,24(sp)
    80004738:	6a42                	ld	s4,16(sp)
    8000473a:	6aa2                	ld	s5,8(sp)
    8000473c:	6121                	addi	sp,sp,64
    8000473e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004740:	0001fa97          	auipc	s5,0x1f
    80004744:	230a8a93          	addi	s5,s5,560 # 80023970 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004748:	0001fa17          	auipc	s4,0x1f
    8000474c:	1f8a0a13          	addi	s4,s4,504 # 80023940 <log>
    80004750:	018a2583          	lw	a1,24(s4)
    80004754:	012585bb          	addw	a1,a1,s2
    80004758:	2585                	addiw	a1,a1,1
    8000475a:	028a2503          	lw	a0,40(s4)
    8000475e:	fffff097          	auipc	ra,0xfffff
    80004762:	cca080e7          	jalr	-822(ra) # 80003428 <bread>
    80004766:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004768:	000aa583          	lw	a1,0(s5)
    8000476c:	028a2503          	lw	a0,40(s4)
    80004770:	fffff097          	auipc	ra,0xfffff
    80004774:	cb8080e7          	jalr	-840(ra) # 80003428 <bread>
    80004778:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000477a:	40000613          	li	a2,1024
    8000477e:	05850593          	addi	a1,a0,88
    80004782:	05848513          	addi	a0,s1,88
    80004786:	ffffc097          	auipc	ra,0xffffc
    8000478a:	5a8080e7          	jalr	1448(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    8000478e:	8526                	mv	a0,s1
    80004790:	fffff097          	auipc	ra,0xfffff
    80004794:	d8a080e7          	jalr	-630(ra) # 8000351a <bwrite>
    brelse(from);
    80004798:	854e                	mv	a0,s3
    8000479a:	fffff097          	auipc	ra,0xfffff
    8000479e:	dbe080e7          	jalr	-578(ra) # 80003558 <brelse>
    brelse(to);
    800047a2:	8526                	mv	a0,s1
    800047a4:	fffff097          	auipc	ra,0xfffff
    800047a8:	db4080e7          	jalr	-588(ra) # 80003558 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047ac:	2905                	addiw	s2,s2,1
    800047ae:	0a91                	addi	s5,s5,4
    800047b0:	02ca2783          	lw	a5,44(s4)
    800047b4:	f8f94ee3          	blt	s2,a5,80004750 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800047b8:	00000097          	auipc	ra,0x0
    800047bc:	c6a080e7          	jalr	-918(ra) # 80004422 <write_head>
    install_trans(0); // Now install writes to home locations
    800047c0:	4501                	li	a0,0
    800047c2:	00000097          	auipc	ra,0x0
    800047c6:	cda080e7          	jalr	-806(ra) # 8000449c <install_trans>
    log.lh.n = 0;
    800047ca:	0001f797          	auipc	a5,0x1f
    800047ce:	1a07a123          	sw	zero,418(a5) # 8002396c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800047d2:	00000097          	auipc	ra,0x0
    800047d6:	c50080e7          	jalr	-944(ra) # 80004422 <write_head>
    800047da:	bdf5                	j	800046d6 <end_op+0x52>

00000000800047dc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800047dc:	1101                	addi	sp,sp,-32
    800047de:	ec06                	sd	ra,24(sp)
    800047e0:	e822                	sd	s0,16(sp)
    800047e2:	e426                	sd	s1,8(sp)
    800047e4:	e04a                	sd	s2,0(sp)
    800047e6:	1000                	addi	s0,sp,32
    800047e8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800047ea:	0001f917          	auipc	s2,0x1f
    800047ee:	15690913          	addi	s2,s2,342 # 80023940 <log>
    800047f2:	854a                	mv	a0,s2
    800047f4:	ffffc097          	auipc	ra,0xffffc
    800047f8:	3e2080e7          	jalr	994(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047fc:	02c92603          	lw	a2,44(s2)
    80004800:	47f5                	li	a5,29
    80004802:	06c7c563          	blt	a5,a2,8000486c <log_write+0x90>
    80004806:	0001f797          	auipc	a5,0x1f
    8000480a:	1567a783          	lw	a5,342(a5) # 8002395c <log+0x1c>
    8000480e:	37fd                	addiw	a5,a5,-1
    80004810:	04f65e63          	bge	a2,a5,8000486c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004814:	0001f797          	auipc	a5,0x1f
    80004818:	14c7a783          	lw	a5,332(a5) # 80023960 <log+0x20>
    8000481c:	06f05063          	blez	a5,8000487c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004820:	4781                	li	a5,0
    80004822:	06c05563          	blez	a2,8000488c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004826:	44cc                	lw	a1,12(s1)
    80004828:	0001f717          	auipc	a4,0x1f
    8000482c:	14870713          	addi	a4,a4,328 # 80023970 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004830:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004832:	4314                	lw	a3,0(a4)
    80004834:	04b68c63          	beq	a3,a1,8000488c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004838:	2785                	addiw	a5,a5,1
    8000483a:	0711                	addi	a4,a4,4
    8000483c:	fef61be3          	bne	a2,a5,80004832 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004840:	0621                	addi	a2,a2,8
    80004842:	060a                	slli	a2,a2,0x2
    80004844:	0001f797          	auipc	a5,0x1f
    80004848:	0fc78793          	addi	a5,a5,252 # 80023940 <log>
    8000484c:	963e                	add	a2,a2,a5
    8000484e:	44dc                	lw	a5,12(s1)
    80004850:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004852:	8526                	mv	a0,s1
    80004854:	fffff097          	auipc	ra,0xfffff
    80004858:	da2080e7          	jalr	-606(ra) # 800035f6 <bpin>
    log.lh.n++;
    8000485c:	0001f717          	auipc	a4,0x1f
    80004860:	0e470713          	addi	a4,a4,228 # 80023940 <log>
    80004864:	575c                	lw	a5,44(a4)
    80004866:	2785                	addiw	a5,a5,1
    80004868:	d75c                	sw	a5,44(a4)
    8000486a:	a835                	j	800048a6 <log_write+0xca>
    panic("too big a transaction");
    8000486c:	00004517          	auipc	a0,0x4
    80004870:	dfc50513          	addi	a0,a0,-516 # 80008668 <syscalls+0x218>
    80004874:	ffffc097          	auipc	ra,0xffffc
    80004878:	cca080e7          	jalr	-822(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    8000487c:	00004517          	auipc	a0,0x4
    80004880:	e0450513          	addi	a0,a0,-508 # 80008680 <syscalls+0x230>
    80004884:	ffffc097          	auipc	ra,0xffffc
    80004888:	cba080e7          	jalr	-838(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    8000488c:	00878713          	addi	a4,a5,8
    80004890:	00271693          	slli	a3,a4,0x2
    80004894:	0001f717          	auipc	a4,0x1f
    80004898:	0ac70713          	addi	a4,a4,172 # 80023940 <log>
    8000489c:	9736                	add	a4,a4,a3
    8000489e:	44d4                	lw	a3,12(s1)
    800048a0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800048a2:	faf608e3          	beq	a2,a5,80004852 <log_write+0x76>
  }
  release(&log.lock);
    800048a6:	0001f517          	auipc	a0,0x1f
    800048aa:	09a50513          	addi	a0,a0,154 # 80023940 <log>
    800048ae:	ffffc097          	auipc	ra,0xffffc
    800048b2:	3dc080e7          	jalr	988(ra) # 80000c8a <release>
}
    800048b6:	60e2                	ld	ra,24(sp)
    800048b8:	6442                	ld	s0,16(sp)
    800048ba:	64a2                	ld	s1,8(sp)
    800048bc:	6902                	ld	s2,0(sp)
    800048be:	6105                	addi	sp,sp,32
    800048c0:	8082                	ret

00000000800048c2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800048c2:	1101                	addi	sp,sp,-32
    800048c4:	ec06                	sd	ra,24(sp)
    800048c6:	e822                	sd	s0,16(sp)
    800048c8:	e426                	sd	s1,8(sp)
    800048ca:	e04a                	sd	s2,0(sp)
    800048cc:	1000                	addi	s0,sp,32
    800048ce:	84aa                	mv	s1,a0
    800048d0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048d2:	00004597          	auipc	a1,0x4
    800048d6:	dce58593          	addi	a1,a1,-562 # 800086a0 <syscalls+0x250>
    800048da:	0521                	addi	a0,a0,8
    800048dc:	ffffc097          	auipc	ra,0xffffc
    800048e0:	26a080e7          	jalr	618(ra) # 80000b46 <initlock>
  lk->name = name;
    800048e4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800048e8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048ec:	0204a423          	sw	zero,40(s1)
}
    800048f0:	60e2                	ld	ra,24(sp)
    800048f2:	6442                	ld	s0,16(sp)
    800048f4:	64a2                	ld	s1,8(sp)
    800048f6:	6902                	ld	s2,0(sp)
    800048f8:	6105                	addi	sp,sp,32
    800048fa:	8082                	ret

00000000800048fc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048fc:	1101                	addi	sp,sp,-32
    800048fe:	ec06                	sd	ra,24(sp)
    80004900:	e822                	sd	s0,16(sp)
    80004902:	e426                	sd	s1,8(sp)
    80004904:	e04a                	sd	s2,0(sp)
    80004906:	1000                	addi	s0,sp,32
    80004908:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000490a:	00850913          	addi	s2,a0,8
    8000490e:	854a                	mv	a0,s2
    80004910:	ffffc097          	auipc	ra,0xffffc
    80004914:	2c6080e7          	jalr	710(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004918:	409c                	lw	a5,0(s1)
    8000491a:	cb89                	beqz	a5,8000492c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000491c:	85ca                	mv	a1,s2
    8000491e:	8526                	mv	a0,s1
    80004920:	ffffe097          	auipc	ra,0xffffe
    80004924:	900080e7          	jalr	-1792(ra) # 80002220 <sleep>
  while (lk->locked) {
    80004928:	409c                	lw	a5,0(s1)
    8000492a:	fbed                	bnez	a5,8000491c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000492c:	4785                	li	a5,1
    8000492e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004930:	ffffd097          	auipc	ra,0xffffd
    80004934:	0ba080e7          	jalr	186(ra) # 800019ea <myproc>
    80004938:	591c                	lw	a5,48(a0)
    8000493a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000493c:	854a                	mv	a0,s2
    8000493e:	ffffc097          	auipc	ra,0xffffc
    80004942:	34c080e7          	jalr	844(ra) # 80000c8a <release>
}
    80004946:	60e2                	ld	ra,24(sp)
    80004948:	6442                	ld	s0,16(sp)
    8000494a:	64a2                	ld	s1,8(sp)
    8000494c:	6902                	ld	s2,0(sp)
    8000494e:	6105                	addi	sp,sp,32
    80004950:	8082                	ret

0000000080004952 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004952:	1101                	addi	sp,sp,-32
    80004954:	ec06                	sd	ra,24(sp)
    80004956:	e822                	sd	s0,16(sp)
    80004958:	e426                	sd	s1,8(sp)
    8000495a:	e04a                	sd	s2,0(sp)
    8000495c:	1000                	addi	s0,sp,32
    8000495e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004960:	00850913          	addi	s2,a0,8
    80004964:	854a                	mv	a0,s2
    80004966:	ffffc097          	auipc	ra,0xffffc
    8000496a:	270080e7          	jalr	624(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    8000496e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004972:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004976:	8526                	mv	a0,s1
    80004978:	ffffe097          	auipc	ra,0xffffe
    8000497c:	90c080e7          	jalr	-1780(ra) # 80002284 <wakeup>
  release(&lk->lk);
    80004980:	854a                	mv	a0,s2
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	308080e7          	jalr	776(ra) # 80000c8a <release>
}
    8000498a:	60e2                	ld	ra,24(sp)
    8000498c:	6442                	ld	s0,16(sp)
    8000498e:	64a2                	ld	s1,8(sp)
    80004990:	6902                	ld	s2,0(sp)
    80004992:	6105                	addi	sp,sp,32
    80004994:	8082                	ret

0000000080004996 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004996:	7179                	addi	sp,sp,-48
    80004998:	f406                	sd	ra,40(sp)
    8000499a:	f022                	sd	s0,32(sp)
    8000499c:	ec26                	sd	s1,24(sp)
    8000499e:	e84a                	sd	s2,16(sp)
    800049a0:	e44e                	sd	s3,8(sp)
    800049a2:	1800                	addi	s0,sp,48
    800049a4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800049a6:	00850913          	addi	s2,a0,8
    800049aa:	854a                	mv	a0,s2
    800049ac:	ffffc097          	auipc	ra,0xffffc
    800049b0:	22a080e7          	jalr	554(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049b4:	409c                	lw	a5,0(s1)
    800049b6:	ef99                	bnez	a5,800049d4 <holdingsleep+0x3e>
    800049b8:	4481                	li	s1,0
  release(&lk->lk);
    800049ba:	854a                	mv	a0,s2
    800049bc:	ffffc097          	auipc	ra,0xffffc
    800049c0:	2ce080e7          	jalr	718(ra) # 80000c8a <release>
  return r;
}
    800049c4:	8526                	mv	a0,s1
    800049c6:	70a2                	ld	ra,40(sp)
    800049c8:	7402                	ld	s0,32(sp)
    800049ca:	64e2                	ld	s1,24(sp)
    800049cc:	6942                	ld	s2,16(sp)
    800049ce:	69a2                	ld	s3,8(sp)
    800049d0:	6145                	addi	sp,sp,48
    800049d2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800049d4:	0284a983          	lw	s3,40(s1)
    800049d8:	ffffd097          	auipc	ra,0xffffd
    800049dc:	012080e7          	jalr	18(ra) # 800019ea <myproc>
    800049e0:	5904                	lw	s1,48(a0)
    800049e2:	413484b3          	sub	s1,s1,s3
    800049e6:	0014b493          	seqz	s1,s1
    800049ea:	bfc1                	j	800049ba <holdingsleep+0x24>

00000000800049ec <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800049ec:	1141                	addi	sp,sp,-16
    800049ee:	e406                	sd	ra,8(sp)
    800049f0:	e022                	sd	s0,0(sp)
    800049f2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049f4:	00004597          	auipc	a1,0x4
    800049f8:	cbc58593          	addi	a1,a1,-836 # 800086b0 <syscalls+0x260>
    800049fc:	0001f517          	auipc	a0,0x1f
    80004a00:	08c50513          	addi	a0,a0,140 # 80023a88 <ftable>
    80004a04:	ffffc097          	auipc	ra,0xffffc
    80004a08:	142080e7          	jalr	322(ra) # 80000b46 <initlock>
}
    80004a0c:	60a2                	ld	ra,8(sp)
    80004a0e:	6402                	ld	s0,0(sp)
    80004a10:	0141                	addi	sp,sp,16
    80004a12:	8082                	ret

0000000080004a14 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a14:	1101                	addi	sp,sp,-32
    80004a16:	ec06                	sd	ra,24(sp)
    80004a18:	e822                	sd	s0,16(sp)
    80004a1a:	e426                	sd	s1,8(sp)
    80004a1c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a1e:	0001f517          	auipc	a0,0x1f
    80004a22:	06a50513          	addi	a0,a0,106 # 80023a88 <ftable>
    80004a26:	ffffc097          	auipc	ra,0xffffc
    80004a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a2e:	0001f497          	auipc	s1,0x1f
    80004a32:	07248493          	addi	s1,s1,114 # 80023aa0 <ftable+0x18>
    80004a36:	00020717          	auipc	a4,0x20
    80004a3a:	00a70713          	addi	a4,a4,10 # 80024a40 <disk>
    if(f->ref == 0){
    80004a3e:	40dc                	lw	a5,4(s1)
    80004a40:	cf99                	beqz	a5,80004a5e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a42:	02848493          	addi	s1,s1,40
    80004a46:	fee49ce3          	bne	s1,a4,80004a3e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a4a:	0001f517          	auipc	a0,0x1f
    80004a4e:	03e50513          	addi	a0,a0,62 # 80023a88 <ftable>
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	238080e7          	jalr	568(ra) # 80000c8a <release>
  return 0;
    80004a5a:	4481                	li	s1,0
    80004a5c:	a819                	j	80004a72 <filealloc+0x5e>
      f->ref = 1;
    80004a5e:	4785                	li	a5,1
    80004a60:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a62:	0001f517          	auipc	a0,0x1f
    80004a66:	02650513          	addi	a0,a0,38 # 80023a88 <ftable>
    80004a6a:	ffffc097          	auipc	ra,0xffffc
    80004a6e:	220080e7          	jalr	544(ra) # 80000c8a <release>
}
    80004a72:	8526                	mv	a0,s1
    80004a74:	60e2                	ld	ra,24(sp)
    80004a76:	6442                	ld	s0,16(sp)
    80004a78:	64a2                	ld	s1,8(sp)
    80004a7a:	6105                	addi	sp,sp,32
    80004a7c:	8082                	ret

0000000080004a7e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a7e:	1101                	addi	sp,sp,-32
    80004a80:	ec06                	sd	ra,24(sp)
    80004a82:	e822                	sd	s0,16(sp)
    80004a84:	e426                	sd	s1,8(sp)
    80004a86:	1000                	addi	s0,sp,32
    80004a88:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a8a:	0001f517          	auipc	a0,0x1f
    80004a8e:	ffe50513          	addi	a0,a0,-2 # 80023a88 <ftable>
    80004a92:	ffffc097          	auipc	ra,0xffffc
    80004a96:	144080e7          	jalr	324(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a9a:	40dc                	lw	a5,4(s1)
    80004a9c:	02f05263          	blez	a5,80004ac0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004aa0:	2785                	addiw	a5,a5,1
    80004aa2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004aa4:	0001f517          	auipc	a0,0x1f
    80004aa8:	fe450513          	addi	a0,a0,-28 # 80023a88 <ftable>
    80004aac:	ffffc097          	auipc	ra,0xffffc
    80004ab0:	1de080e7          	jalr	478(ra) # 80000c8a <release>
  return f;
}
    80004ab4:	8526                	mv	a0,s1
    80004ab6:	60e2                	ld	ra,24(sp)
    80004ab8:	6442                	ld	s0,16(sp)
    80004aba:	64a2                	ld	s1,8(sp)
    80004abc:	6105                	addi	sp,sp,32
    80004abe:	8082                	ret
    panic("filedup");
    80004ac0:	00004517          	auipc	a0,0x4
    80004ac4:	bf850513          	addi	a0,a0,-1032 # 800086b8 <syscalls+0x268>
    80004ac8:	ffffc097          	auipc	ra,0xffffc
    80004acc:	a76080e7          	jalr	-1418(ra) # 8000053e <panic>

0000000080004ad0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004ad0:	7139                	addi	sp,sp,-64
    80004ad2:	fc06                	sd	ra,56(sp)
    80004ad4:	f822                	sd	s0,48(sp)
    80004ad6:	f426                	sd	s1,40(sp)
    80004ad8:	f04a                	sd	s2,32(sp)
    80004ada:	ec4e                	sd	s3,24(sp)
    80004adc:	e852                	sd	s4,16(sp)
    80004ade:	e456                	sd	s5,8(sp)
    80004ae0:	0080                	addi	s0,sp,64
    80004ae2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004ae4:	0001f517          	auipc	a0,0x1f
    80004ae8:	fa450513          	addi	a0,a0,-92 # 80023a88 <ftable>
    80004aec:	ffffc097          	auipc	ra,0xffffc
    80004af0:	0ea080e7          	jalr	234(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004af4:	40dc                	lw	a5,4(s1)
    80004af6:	06f05163          	blez	a5,80004b58 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004afa:	37fd                	addiw	a5,a5,-1
    80004afc:	0007871b          	sext.w	a4,a5
    80004b00:	c0dc                	sw	a5,4(s1)
    80004b02:	06e04363          	bgtz	a4,80004b68 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b06:	0004a903          	lw	s2,0(s1)
    80004b0a:	0094ca83          	lbu	s5,9(s1)
    80004b0e:	0104ba03          	ld	s4,16(s1)
    80004b12:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b16:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b1a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b1e:	0001f517          	auipc	a0,0x1f
    80004b22:	f6a50513          	addi	a0,a0,-150 # 80023a88 <ftable>
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	164080e7          	jalr	356(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004b2e:	4785                	li	a5,1
    80004b30:	04f90d63          	beq	s2,a5,80004b8a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b34:	3979                	addiw	s2,s2,-2
    80004b36:	4785                	li	a5,1
    80004b38:	0527e063          	bltu	a5,s2,80004b78 <fileclose+0xa8>
    begin_op();
    80004b3c:	00000097          	auipc	ra,0x0
    80004b40:	ac8080e7          	jalr	-1336(ra) # 80004604 <begin_op>
    iput(ff.ip);
    80004b44:	854e                	mv	a0,s3
    80004b46:	fffff097          	auipc	ra,0xfffff
    80004b4a:	2b6080e7          	jalr	694(ra) # 80003dfc <iput>
    end_op();
    80004b4e:	00000097          	auipc	ra,0x0
    80004b52:	b36080e7          	jalr	-1226(ra) # 80004684 <end_op>
    80004b56:	a00d                	j	80004b78 <fileclose+0xa8>
    panic("fileclose");
    80004b58:	00004517          	auipc	a0,0x4
    80004b5c:	b6850513          	addi	a0,a0,-1176 # 800086c0 <syscalls+0x270>
    80004b60:	ffffc097          	auipc	ra,0xffffc
    80004b64:	9de080e7          	jalr	-1570(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004b68:	0001f517          	auipc	a0,0x1f
    80004b6c:	f2050513          	addi	a0,a0,-224 # 80023a88 <ftable>
    80004b70:	ffffc097          	auipc	ra,0xffffc
    80004b74:	11a080e7          	jalr	282(ra) # 80000c8a <release>
  }
}
    80004b78:	70e2                	ld	ra,56(sp)
    80004b7a:	7442                	ld	s0,48(sp)
    80004b7c:	74a2                	ld	s1,40(sp)
    80004b7e:	7902                	ld	s2,32(sp)
    80004b80:	69e2                	ld	s3,24(sp)
    80004b82:	6a42                	ld	s4,16(sp)
    80004b84:	6aa2                	ld	s5,8(sp)
    80004b86:	6121                	addi	sp,sp,64
    80004b88:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b8a:	85d6                	mv	a1,s5
    80004b8c:	8552                	mv	a0,s4
    80004b8e:	00000097          	auipc	ra,0x0
    80004b92:	34c080e7          	jalr	844(ra) # 80004eda <pipeclose>
    80004b96:	b7cd                	j	80004b78 <fileclose+0xa8>

0000000080004b98 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b98:	715d                	addi	sp,sp,-80
    80004b9a:	e486                	sd	ra,72(sp)
    80004b9c:	e0a2                	sd	s0,64(sp)
    80004b9e:	fc26                	sd	s1,56(sp)
    80004ba0:	f84a                	sd	s2,48(sp)
    80004ba2:	f44e                	sd	s3,40(sp)
    80004ba4:	0880                	addi	s0,sp,80
    80004ba6:	84aa                	mv	s1,a0
    80004ba8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004baa:	ffffd097          	auipc	ra,0xffffd
    80004bae:	e40080e7          	jalr	-448(ra) # 800019ea <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004bb2:	409c                	lw	a5,0(s1)
    80004bb4:	37f9                	addiw	a5,a5,-2
    80004bb6:	4705                	li	a4,1
    80004bb8:	04f76763          	bltu	a4,a5,80004c06 <filestat+0x6e>
    80004bbc:	892a                	mv	s2,a0
    ilock(f->ip);
    80004bbe:	6c88                	ld	a0,24(s1)
    80004bc0:	fffff097          	auipc	ra,0xfffff
    80004bc4:	082080e7          	jalr	130(ra) # 80003c42 <ilock>
    stati(f->ip, &st);
    80004bc8:	fb840593          	addi	a1,s0,-72
    80004bcc:	6c88                	ld	a0,24(s1)
    80004bce:	fffff097          	auipc	ra,0xfffff
    80004bd2:	2fe080e7          	jalr	766(ra) # 80003ecc <stati>
    iunlock(f->ip);
    80004bd6:	6c88                	ld	a0,24(s1)
    80004bd8:	fffff097          	auipc	ra,0xfffff
    80004bdc:	12c080e7          	jalr	300(ra) # 80003d04 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004be0:	46e1                	li	a3,24
    80004be2:	fb840613          	addi	a2,s0,-72
    80004be6:	85ce                	mv	a1,s3
    80004be8:	05093503          	ld	a0,80(s2)
    80004bec:	ffffd097          	auipc	ra,0xffffd
    80004bf0:	a7c080e7          	jalr	-1412(ra) # 80001668 <copyout>
    80004bf4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004bf8:	60a6                	ld	ra,72(sp)
    80004bfa:	6406                	ld	s0,64(sp)
    80004bfc:	74e2                	ld	s1,56(sp)
    80004bfe:	7942                	ld	s2,48(sp)
    80004c00:	79a2                	ld	s3,40(sp)
    80004c02:	6161                	addi	sp,sp,80
    80004c04:	8082                	ret
  return -1;
    80004c06:	557d                	li	a0,-1
    80004c08:	bfc5                	j	80004bf8 <filestat+0x60>

0000000080004c0a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c0a:	7179                	addi	sp,sp,-48
    80004c0c:	f406                	sd	ra,40(sp)
    80004c0e:	f022                	sd	s0,32(sp)
    80004c10:	ec26                	sd	s1,24(sp)
    80004c12:	e84a                	sd	s2,16(sp)
    80004c14:	e44e                	sd	s3,8(sp)
    80004c16:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c18:	00854783          	lbu	a5,8(a0)
    80004c1c:	c3d5                	beqz	a5,80004cc0 <fileread+0xb6>
    80004c1e:	84aa                	mv	s1,a0
    80004c20:	89ae                	mv	s3,a1
    80004c22:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c24:	411c                	lw	a5,0(a0)
    80004c26:	4705                	li	a4,1
    80004c28:	04e78963          	beq	a5,a4,80004c7a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c2c:	470d                	li	a4,3
    80004c2e:	04e78d63          	beq	a5,a4,80004c88 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c32:	4709                	li	a4,2
    80004c34:	06e79e63          	bne	a5,a4,80004cb0 <fileread+0xa6>
    ilock(f->ip);
    80004c38:	6d08                	ld	a0,24(a0)
    80004c3a:	fffff097          	auipc	ra,0xfffff
    80004c3e:	008080e7          	jalr	8(ra) # 80003c42 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c42:	874a                	mv	a4,s2
    80004c44:	5094                	lw	a3,32(s1)
    80004c46:	864e                	mv	a2,s3
    80004c48:	4585                	li	a1,1
    80004c4a:	6c88                	ld	a0,24(s1)
    80004c4c:	fffff097          	auipc	ra,0xfffff
    80004c50:	2aa080e7          	jalr	682(ra) # 80003ef6 <readi>
    80004c54:	892a                	mv	s2,a0
    80004c56:	00a05563          	blez	a0,80004c60 <fileread+0x56>
      f->off += r;
    80004c5a:	509c                	lw	a5,32(s1)
    80004c5c:	9fa9                	addw	a5,a5,a0
    80004c5e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c60:	6c88                	ld	a0,24(s1)
    80004c62:	fffff097          	auipc	ra,0xfffff
    80004c66:	0a2080e7          	jalr	162(ra) # 80003d04 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c6a:	854a                	mv	a0,s2
    80004c6c:	70a2                	ld	ra,40(sp)
    80004c6e:	7402                	ld	s0,32(sp)
    80004c70:	64e2                	ld	s1,24(sp)
    80004c72:	6942                	ld	s2,16(sp)
    80004c74:	69a2                	ld	s3,8(sp)
    80004c76:	6145                	addi	sp,sp,48
    80004c78:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c7a:	6908                	ld	a0,16(a0)
    80004c7c:	00000097          	auipc	ra,0x0
    80004c80:	3c6080e7          	jalr	966(ra) # 80005042 <piperead>
    80004c84:	892a                	mv	s2,a0
    80004c86:	b7d5                	j	80004c6a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c88:	02451783          	lh	a5,36(a0)
    80004c8c:	03079693          	slli	a3,a5,0x30
    80004c90:	92c1                	srli	a3,a3,0x30
    80004c92:	4725                	li	a4,9
    80004c94:	02d76863          	bltu	a4,a3,80004cc4 <fileread+0xba>
    80004c98:	0792                	slli	a5,a5,0x4
    80004c9a:	0001f717          	auipc	a4,0x1f
    80004c9e:	d4e70713          	addi	a4,a4,-690 # 800239e8 <devsw>
    80004ca2:	97ba                	add	a5,a5,a4
    80004ca4:	639c                	ld	a5,0(a5)
    80004ca6:	c38d                	beqz	a5,80004cc8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004ca8:	4505                	li	a0,1
    80004caa:	9782                	jalr	a5
    80004cac:	892a                	mv	s2,a0
    80004cae:	bf75                	j	80004c6a <fileread+0x60>
    panic("fileread");
    80004cb0:	00004517          	auipc	a0,0x4
    80004cb4:	a2050513          	addi	a0,a0,-1504 # 800086d0 <syscalls+0x280>
    80004cb8:	ffffc097          	auipc	ra,0xffffc
    80004cbc:	886080e7          	jalr	-1914(ra) # 8000053e <panic>
    return -1;
    80004cc0:	597d                	li	s2,-1
    80004cc2:	b765                	j	80004c6a <fileread+0x60>
      return -1;
    80004cc4:	597d                	li	s2,-1
    80004cc6:	b755                	j	80004c6a <fileread+0x60>
    80004cc8:	597d                	li	s2,-1
    80004cca:	b745                	j	80004c6a <fileread+0x60>

0000000080004ccc <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004ccc:	715d                	addi	sp,sp,-80
    80004cce:	e486                	sd	ra,72(sp)
    80004cd0:	e0a2                	sd	s0,64(sp)
    80004cd2:	fc26                	sd	s1,56(sp)
    80004cd4:	f84a                	sd	s2,48(sp)
    80004cd6:	f44e                	sd	s3,40(sp)
    80004cd8:	f052                	sd	s4,32(sp)
    80004cda:	ec56                	sd	s5,24(sp)
    80004cdc:	e85a                	sd	s6,16(sp)
    80004cde:	e45e                	sd	s7,8(sp)
    80004ce0:	e062                	sd	s8,0(sp)
    80004ce2:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004ce4:	00954783          	lbu	a5,9(a0)
    80004ce8:	10078663          	beqz	a5,80004df4 <filewrite+0x128>
    80004cec:	892a                	mv	s2,a0
    80004cee:	8aae                	mv	s5,a1
    80004cf0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cf2:	411c                	lw	a5,0(a0)
    80004cf4:	4705                	li	a4,1
    80004cf6:	02e78263          	beq	a5,a4,80004d1a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cfa:	470d                	li	a4,3
    80004cfc:	02e78663          	beq	a5,a4,80004d28 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d00:	4709                	li	a4,2
    80004d02:	0ee79163          	bne	a5,a4,80004de4 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d06:	0ac05d63          	blez	a2,80004dc0 <filewrite+0xf4>
    int i = 0;
    80004d0a:	4981                	li	s3,0
    80004d0c:	6b05                	lui	s6,0x1
    80004d0e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d12:	6b85                	lui	s7,0x1
    80004d14:	c00b8b9b          	addiw	s7,s7,-1024
    80004d18:	a861                	j	80004db0 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004d1a:	6908                	ld	a0,16(a0)
    80004d1c:	00000097          	auipc	ra,0x0
    80004d20:	22e080e7          	jalr	558(ra) # 80004f4a <pipewrite>
    80004d24:	8a2a                	mv	s4,a0
    80004d26:	a045                	j	80004dc6 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d28:	02451783          	lh	a5,36(a0)
    80004d2c:	03079693          	slli	a3,a5,0x30
    80004d30:	92c1                	srli	a3,a3,0x30
    80004d32:	4725                	li	a4,9
    80004d34:	0cd76263          	bltu	a4,a3,80004df8 <filewrite+0x12c>
    80004d38:	0792                	slli	a5,a5,0x4
    80004d3a:	0001f717          	auipc	a4,0x1f
    80004d3e:	cae70713          	addi	a4,a4,-850 # 800239e8 <devsw>
    80004d42:	97ba                	add	a5,a5,a4
    80004d44:	679c                	ld	a5,8(a5)
    80004d46:	cbdd                	beqz	a5,80004dfc <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004d48:	4505                	li	a0,1
    80004d4a:	9782                	jalr	a5
    80004d4c:	8a2a                	mv	s4,a0
    80004d4e:	a8a5                	j	80004dc6 <filewrite+0xfa>
    80004d50:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004d54:	00000097          	auipc	ra,0x0
    80004d58:	8b0080e7          	jalr	-1872(ra) # 80004604 <begin_op>
      ilock(f->ip);
    80004d5c:	01893503          	ld	a0,24(s2)
    80004d60:	fffff097          	auipc	ra,0xfffff
    80004d64:	ee2080e7          	jalr	-286(ra) # 80003c42 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d68:	8762                	mv	a4,s8
    80004d6a:	02092683          	lw	a3,32(s2)
    80004d6e:	01598633          	add	a2,s3,s5
    80004d72:	4585                	li	a1,1
    80004d74:	01893503          	ld	a0,24(s2)
    80004d78:	fffff097          	auipc	ra,0xfffff
    80004d7c:	276080e7          	jalr	630(ra) # 80003fee <writei>
    80004d80:	84aa                	mv	s1,a0
    80004d82:	00a05763          	blez	a0,80004d90 <filewrite+0xc4>
        f->off += r;
    80004d86:	02092783          	lw	a5,32(s2)
    80004d8a:	9fa9                	addw	a5,a5,a0
    80004d8c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d90:	01893503          	ld	a0,24(s2)
    80004d94:	fffff097          	auipc	ra,0xfffff
    80004d98:	f70080e7          	jalr	-144(ra) # 80003d04 <iunlock>
      end_op();
    80004d9c:	00000097          	auipc	ra,0x0
    80004da0:	8e8080e7          	jalr	-1816(ra) # 80004684 <end_op>

      if(r != n1){
    80004da4:	009c1f63          	bne	s8,s1,80004dc2 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004da8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004dac:	0149db63          	bge	s3,s4,80004dc2 <filewrite+0xf6>
      int n1 = n - i;
    80004db0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004db4:	84be                	mv	s1,a5
    80004db6:	2781                	sext.w	a5,a5
    80004db8:	f8fb5ce3          	bge	s6,a5,80004d50 <filewrite+0x84>
    80004dbc:	84de                	mv	s1,s7
    80004dbe:	bf49                	j	80004d50 <filewrite+0x84>
    int i = 0;
    80004dc0:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004dc2:	013a1f63          	bne	s4,s3,80004de0 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004dc6:	8552                	mv	a0,s4
    80004dc8:	60a6                	ld	ra,72(sp)
    80004dca:	6406                	ld	s0,64(sp)
    80004dcc:	74e2                	ld	s1,56(sp)
    80004dce:	7942                	ld	s2,48(sp)
    80004dd0:	79a2                	ld	s3,40(sp)
    80004dd2:	7a02                	ld	s4,32(sp)
    80004dd4:	6ae2                	ld	s5,24(sp)
    80004dd6:	6b42                	ld	s6,16(sp)
    80004dd8:	6ba2                	ld	s7,8(sp)
    80004dda:	6c02                	ld	s8,0(sp)
    80004ddc:	6161                	addi	sp,sp,80
    80004dde:	8082                	ret
    ret = (i == n ? n : -1);
    80004de0:	5a7d                	li	s4,-1
    80004de2:	b7d5                	j	80004dc6 <filewrite+0xfa>
    panic("filewrite");
    80004de4:	00004517          	auipc	a0,0x4
    80004de8:	8fc50513          	addi	a0,a0,-1796 # 800086e0 <syscalls+0x290>
    80004dec:	ffffb097          	auipc	ra,0xffffb
    80004df0:	752080e7          	jalr	1874(ra) # 8000053e <panic>
    return -1;
    80004df4:	5a7d                	li	s4,-1
    80004df6:	bfc1                	j	80004dc6 <filewrite+0xfa>
      return -1;
    80004df8:	5a7d                	li	s4,-1
    80004dfa:	b7f1                	j	80004dc6 <filewrite+0xfa>
    80004dfc:	5a7d                	li	s4,-1
    80004dfe:	b7e1                	j	80004dc6 <filewrite+0xfa>

0000000080004e00 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e00:	7179                	addi	sp,sp,-48
    80004e02:	f406                	sd	ra,40(sp)
    80004e04:	f022                	sd	s0,32(sp)
    80004e06:	ec26                	sd	s1,24(sp)
    80004e08:	e84a                	sd	s2,16(sp)
    80004e0a:	e44e                	sd	s3,8(sp)
    80004e0c:	e052                	sd	s4,0(sp)
    80004e0e:	1800                	addi	s0,sp,48
    80004e10:	84aa                	mv	s1,a0
    80004e12:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e14:	0005b023          	sd	zero,0(a1)
    80004e18:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e1c:	00000097          	auipc	ra,0x0
    80004e20:	bf8080e7          	jalr	-1032(ra) # 80004a14 <filealloc>
    80004e24:	e088                	sd	a0,0(s1)
    80004e26:	c551                	beqz	a0,80004eb2 <pipealloc+0xb2>
    80004e28:	00000097          	auipc	ra,0x0
    80004e2c:	bec080e7          	jalr	-1044(ra) # 80004a14 <filealloc>
    80004e30:	00aa3023          	sd	a0,0(s4)
    80004e34:	c92d                	beqz	a0,80004ea6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e36:	ffffc097          	auipc	ra,0xffffc
    80004e3a:	cb0080e7          	jalr	-848(ra) # 80000ae6 <kalloc>
    80004e3e:	892a                	mv	s2,a0
    80004e40:	c125                	beqz	a0,80004ea0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e42:	4985                	li	s3,1
    80004e44:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e48:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004e4c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004e50:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004e54:	00004597          	auipc	a1,0x4
    80004e58:	89c58593          	addi	a1,a1,-1892 # 800086f0 <syscalls+0x2a0>
    80004e5c:	ffffc097          	auipc	ra,0xffffc
    80004e60:	cea080e7          	jalr	-790(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004e64:	609c                	ld	a5,0(s1)
    80004e66:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e6a:	609c                	ld	a5,0(s1)
    80004e6c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e70:	609c                	ld	a5,0(s1)
    80004e72:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e76:	609c                	ld	a5,0(s1)
    80004e78:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e7c:	000a3783          	ld	a5,0(s4)
    80004e80:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e84:	000a3783          	ld	a5,0(s4)
    80004e88:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e8c:	000a3783          	ld	a5,0(s4)
    80004e90:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e94:	000a3783          	ld	a5,0(s4)
    80004e98:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e9c:	4501                	li	a0,0
    80004e9e:	a025                	j	80004ec6 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ea0:	6088                	ld	a0,0(s1)
    80004ea2:	e501                	bnez	a0,80004eaa <pipealloc+0xaa>
    80004ea4:	a039                	j	80004eb2 <pipealloc+0xb2>
    80004ea6:	6088                	ld	a0,0(s1)
    80004ea8:	c51d                	beqz	a0,80004ed6 <pipealloc+0xd6>
    fileclose(*f0);
    80004eaa:	00000097          	auipc	ra,0x0
    80004eae:	c26080e7          	jalr	-986(ra) # 80004ad0 <fileclose>
  if(*f1)
    80004eb2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004eb6:	557d                	li	a0,-1
  if(*f1)
    80004eb8:	c799                	beqz	a5,80004ec6 <pipealloc+0xc6>
    fileclose(*f1);
    80004eba:	853e                	mv	a0,a5
    80004ebc:	00000097          	auipc	ra,0x0
    80004ec0:	c14080e7          	jalr	-1004(ra) # 80004ad0 <fileclose>
  return -1;
    80004ec4:	557d                	li	a0,-1
}
    80004ec6:	70a2                	ld	ra,40(sp)
    80004ec8:	7402                	ld	s0,32(sp)
    80004eca:	64e2                	ld	s1,24(sp)
    80004ecc:	6942                	ld	s2,16(sp)
    80004ece:	69a2                	ld	s3,8(sp)
    80004ed0:	6a02                	ld	s4,0(sp)
    80004ed2:	6145                	addi	sp,sp,48
    80004ed4:	8082                	ret
  return -1;
    80004ed6:	557d                	li	a0,-1
    80004ed8:	b7fd                	j	80004ec6 <pipealloc+0xc6>

0000000080004eda <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004eda:	1101                	addi	sp,sp,-32
    80004edc:	ec06                	sd	ra,24(sp)
    80004ede:	e822                	sd	s0,16(sp)
    80004ee0:	e426                	sd	s1,8(sp)
    80004ee2:	e04a                	sd	s2,0(sp)
    80004ee4:	1000                	addi	s0,sp,32
    80004ee6:	84aa                	mv	s1,a0
    80004ee8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004eea:	ffffc097          	auipc	ra,0xffffc
    80004eee:	cec080e7          	jalr	-788(ra) # 80000bd6 <acquire>
  if(writable){
    80004ef2:	02090d63          	beqz	s2,80004f2c <pipeclose+0x52>
    pi->writeopen = 0;
    80004ef6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004efa:	21848513          	addi	a0,s1,536
    80004efe:	ffffd097          	auipc	ra,0xffffd
    80004f02:	386080e7          	jalr	902(ra) # 80002284 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f06:	2204b783          	ld	a5,544(s1)
    80004f0a:	eb95                	bnez	a5,80004f3e <pipeclose+0x64>
    release(&pi->lock);
    80004f0c:	8526                	mv	a0,s1
    80004f0e:	ffffc097          	auipc	ra,0xffffc
    80004f12:	d7c080e7          	jalr	-644(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004f16:	8526                	mv	a0,s1
    80004f18:	ffffc097          	auipc	ra,0xffffc
    80004f1c:	ad2080e7          	jalr	-1326(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004f20:	60e2                	ld	ra,24(sp)
    80004f22:	6442                	ld	s0,16(sp)
    80004f24:	64a2                	ld	s1,8(sp)
    80004f26:	6902                	ld	s2,0(sp)
    80004f28:	6105                	addi	sp,sp,32
    80004f2a:	8082                	ret
    pi->readopen = 0;
    80004f2c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f30:	21c48513          	addi	a0,s1,540
    80004f34:	ffffd097          	auipc	ra,0xffffd
    80004f38:	350080e7          	jalr	848(ra) # 80002284 <wakeup>
    80004f3c:	b7e9                	j	80004f06 <pipeclose+0x2c>
    release(&pi->lock);
    80004f3e:	8526                	mv	a0,s1
    80004f40:	ffffc097          	auipc	ra,0xffffc
    80004f44:	d4a080e7          	jalr	-694(ra) # 80000c8a <release>
}
    80004f48:	bfe1                	j	80004f20 <pipeclose+0x46>

0000000080004f4a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f4a:	711d                	addi	sp,sp,-96
    80004f4c:	ec86                	sd	ra,88(sp)
    80004f4e:	e8a2                	sd	s0,80(sp)
    80004f50:	e4a6                	sd	s1,72(sp)
    80004f52:	e0ca                	sd	s2,64(sp)
    80004f54:	fc4e                	sd	s3,56(sp)
    80004f56:	f852                	sd	s4,48(sp)
    80004f58:	f456                	sd	s5,40(sp)
    80004f5a:	f05a                	sd	s6,32(sp)
    80004f5c:	ec5e                	sd	s7,24(sp)
    80004f5e:	e862                	sd	s8,16(sp)
    80004f60:	1080                	addi	s0,sp,96
    80004f62:	84aa                	mv	s1,a0
    80004f64:	8aae                	mv	s5,a1
    80004f66:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f68:	ffffd097          	auipc	ra,0xffffd
    80004f6c:	a82080e7          	jalr	-1406(ra) # 800019ea <myproc>
    80004f70:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f72:	8526                	mv	a0,s1
    80004f74:	ffffc097          	auipc	ra,0xffffc
    80004f78:	c62080e7          	jalr	-926(ra) # 80000bd6 <acquire>
  while(i < n){
    80004f7c:	0b405663          	blez	s4,80005028 <pipewrite+0xde>
  int i = 0;
    80004f80:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f82:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f84:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f88:	21c48b93          	addi	s7,s1,540
    80004f8c:	a089                	j	80004fce <pipewrite+0x84>
      release(&pi->lock);
    80004f8e:	8526                	mv	a0,s1
    80004f90:	ffffc097          	auipc	ra,0xffffc
    80004f94:	cfa080e7          	jalr	-774(ra) # 80000c8a <release>
      return -1;
    80004f98:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f9a:	854a                	mv	a0,s2
    80004f9c:	60e6                	ld	ra,88(sp)
    80004f9e:	6446                	ld	s0,80(sp)
    80004fa0:	64a6                	ld	s1,72(sp)
    80004fa2:	6906                	ld	s2,64(sp)
    80004fa4:	79e2                	ld	s3,56(sp)
    80004fa6:	7a42                	ld	s4,48(sp)
    80004fa8:	7aa2                	ld	s5,40(sp)
    80004faa:	7b02                	ld	s6,32(sp)
    80004fac:	6be2                	ld	s7,24(sp)
    80004fae:	6c42                	ld	s8,16(sp)
    80004fb0:	6125                	addi	sp,sp,96
    80004fb2:	8082                	ret
      wakeup(&pi->nread);
    80004fb4:	8562                	mv	a0,s8
    80004fb6:	ffffd097          	auipc	ra,0xffffd
    80004fba:	2ce080e7          	jalr	718(ra) # 80002284 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004fbe:	85a6                	mv	a1,s1
    80004fc0:	855e                	mv	a0,s7
    80004fc2:	ffffd097          	auipc	ra,0xffffd
    80004fc6:	25e080e7          	jalr	606(ra) # 80002220 <sleep>
  while(i < n){
    80004fca:	07495063          	bge	s2,s4,8000502a <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004fce:	2204a783          	lw	a5,544(s1)
    80004fd2:	dfd5                	beqz	a5,80004f8e <pipewrite+0x44>
    80004fd4:	854e                	mv	a0,s3
    80004fd6:	ffffd097          	auipc	ra,0xffffd
    80004fda:	51a080e7          	jalr	1306(ra) # 800024f0 <killed>
    80004fde:	f945                	bnez	a0,80004f8e <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004fe0:	2184a783          	lw	a5,536(s1)
    80004fe4:	21c4a703          	lw	a4,540(s1)
    80004fe8:	2007879b          	addiw	a5,a5,512
    80004fec:	fcf704e3          	beq	a4,a5,80004fb4 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ff0:	4685                	li	a3,1
    80004ff2:	01590633          	add	a2,s2,s5
    80004ff6:	faf40593          	addi	a1,s0,-81
    80004ffa:	0509b503          	ld	a0,80(s3)
    80004ffe:	ffffc097          	auipc	ra,0xffffc
    80005002:	6f6080e7          	jalr	1782(ra) # 800016f4 <copyin>
    80005006:	03650263          	beq	a0,s6,8000502a <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000500a:	21c4a783          	lw	a5,540(s1)
    8000500e:	0017871b          	addiw	a4,a5,1
    80005012:	20e4ae23          	sw	a4,540(s1)
    80005016:	1ff7f793          	andi	a5,a5,511
    8000501a:	97a6                	add	a5,a5,s1
    8000501c:	faf44703          	lbu	a4,-81(s0)
    80005020:	00e78c23          	sb	a4,24(a5)
      i++;
    80005024:	2905                	addiw	s2,s2,1
    80005026:	b755                	j	80004fca <pipewrite+0x80>
  int i = 0;
    80005028:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000502a:	21848513          	addi	a0,s1,536
    8000502e:	ffffd097          	auipc	ra,0xffffd
    80005032:	256080e7          	jalr	598(ra) # 80002284 <wakeup>
  release(&pi->lock);
    80005036:	8526                	mv	a0,s1
    80005038:	ffffc097          	auipc	ra,0xffffc
    8000503c:	c52080e7          	jalr	-942(ra) # 80000c8a <release>
  return i;
    80005040:	bfa9                	j	80004f9a <pipewrite+0x50>

0000000080005042 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005042:	715d                	addi	sp,sp,-80
    80005044:	e486                	sd	ra,72(sp)
    80005046:	e0a2                	sd	s0,64(sp)
    80005048:	fc26                	sd	s1,56(sp)
    8000504a:	f84a                	sd	s2,48(sp)
    8000504c:	f44e                	sd	s3,40(sp)
    8000504e:	f052                	sd	s4,32(sp)
    80005050:	ec56                	sd	s5,24(sp)
    80005052:	e85a                	sd	s6,16(sp)
    80005054:	0880                	addi	s0,sp,80
    80005056:	84aa                	mv	s1,a0
    80005058:	892e                	mv	s2,a1
    8000505a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000505c:	ffffd097          	auipc	ra,0xffffd
    80005060:	98e080e7          	jalr	-1650(ra) # 800019ea <myproc>
    80005064:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005066:	8526                	mv	a0,s1
    80005068:	ffffc097          	auipc	ra,0xffffc
    8000506c:	b6e080e7          	jalr	-1170(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005070:	2184a703          	lw	a4,536(s1)
    80005074:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005078:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000507c:	02f71763          	bne	a4,a5,800050aa <piperead+0x68>
    80005080:	2244a783          	lw	a5,548(s1)
    80005084:	c39d                	beqz	a5,800050aa <piperead+0x68>
    if(killed(pr)){
    80005086:	8552                	mv	a0,s4
    80005088:	ffffd097          	auipc	ra,0xffffd
    8000508c:	468080e7          	jalr	1128(ra) # 800024f0 <killed>
    80005090:	e941                	bnez	a0,80005120 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005092:	85a6                	mv	a1,s1
    80005094:	854e                	mv	a0,s3
    80005096:	ffffd097          	auipc	ra,0xffffd
    8000509a:	18a080e7          	jalr	394(ra) # 80002220 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000509e:	2184a703          	lw	a4,536(s1)
    800050a2:	21c4a783          	lw	a5,540(s1)
    800050a6:	fcf70de3          	beq	a4,a5,80005080 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050aa:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050ac:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050ae:	05505363          	blez	s5,800050f4 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800050b2:	2184a783          	lw	a5,536(s1)
    800050b6:	21c4a703          	lw	a4,540(s1)
    800050ba:	02f70d63          	beq	a4,a5,800050f4 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800050be:	0017871b          	addiw	a4,a5,1
    800050c2:	20e4ac23          	sw	a4,536(s1)
    800050c6:	1ff7f793          	andi	a5,a5,511
    800050ca:	97a6                	add	a5,a5,s1
    800050cc:	0187c783          	lbu	a5,24(a5)
    800050d0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050d4:	4685                	li	a3,1
    800050d6:	fbf40613          	addi	a2,s0,-65
    800050da:	85ca                	mv	a1,s2
    800050dc:	050a3503          	ld	a0,80(s4)
    800050e0:	ffffc097          	auipc	ra,0xffffc
    800050e4:	588080e7          	jalr	1416(ra) # 80001668 <copyout>
    800050e8:	01650663          	beq	a0,s6,800050f4 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050ec:	2985                	addiw	s3,s3,1
    800050ee:	0905                	addi	s2,s2,1
    800050f0:	fd3a91e3          	bne	s5,s3,800050b2 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050f4:	21c48513          	addi	a0,s1,540
    800050f8:	ffffd097          	auipc	ra,0xffffd
    800050fc:	18c080e7          	jalr	396(ra) # 80002284 <wakeup>
  release(&pi->lock);
    80005100:	8526                	mv	a0,s1
    80005102:	ffffc097          	auipc	ra,0xffffc
    80005106:	b88080e7          	jalr	-1144(ra) # 80000c8a <release>
  return i;
}
    8000510a:	854e                	mv	a0,s3
    8000510c:	60a6                	ld	ra,72(sp)
    8000510e:	6406                	ld	s0,64(sp)
    80005110:	74e2                	ld	s1,56(sp)
    80005112:	7942                	ld	s2,48(sp)
    80005114:	79a2                	ld	s3,40(sp)
    80005116:	7a02                	ld	s4,32(sp)
    80005118:	6ae2                	ld	s5,24(sp)
    8000511a:	6b42                	ld	s6,16(sp)
    8000511c:	6161                	addi	sp,sp,80
    8000511e:	8082                	ret
      release(&pi->lock);
    80005120:	8526                	mv	a0,s1
    80005122:	ffffc097          	auipc	ra,0xffffc
    80005126:	b68080e7          	jalr	-1176(ra) # 80000c8a <release>
      return -1;
    8000512a:	59fd                	li	s3,-1
    8000512c:	bff9                	j	8000510a <piperead+0xc8>

000000008000512e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000512e:	1141                	addi	sp,sp,-16
    80005130:	e422                	sd	s0,8(sp)
    80005132:	0800                	addi	s0,sp,16
    80005134:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005136:	8905                	andi	a0,a0,1
    80005138:	c111                	beqz	a0,8000513c <flags2perm+0xe>
      perm = PTE_X;
    8000513a:	4521                	li	a0,8
    if(flags & 0x2)
    8000513c:	8b89                	andi	a5,a5,2
    8000513e:	c399                	beqz	a5,80005144 <flags2perm+0x16>
      perm |= PTE_W;
    80005140:	00456513          	ori	a0,a0,4
    return perm;
}
    80005144:	6422                	ld	s0,8(sp)
    80005146:	0141                	addi	sp,sp,16
    80005148:	8082                	ret

000000008000514a <exec>:

int
exec(char *path, char **argv)
{
    8000514a:	de010113          	addi	sp,sp,-544
    8000514e:	20113c23          	sd	ra,536(sp)
    80005152:	20813823          	sd	s0,528(sp)
    80005156:	20913423          	sd	s1,520(sp)
    8000515a:	21213023          	sd	s2,512(sp)
    8000515e:	ffce                	sd	s3,504(sp)
    80005160:	fbd2                	sd	s4,496(sp)
    80005162:	f7d6                	sd	s5,488(sp)
    80005164:	f3da                	sd	s6,480(sp)
    80005166:	efde                	sd	s7,472(sp)
    80005168:	ebe2                	sd	s8,464(sp)
    8000516a:	e7e6                	sd	s9,456(sp)
    8000516c:	e3ea                	sd	s10,448(sp)
    8000516e:	ff6e                	sd	s11,440(sp)
    80005170:	1400                	addi	s0,sp,544
    80005172:	892a                	mv	s2,a0
    80005174:	dea43423          	sd	a0,-536(s0)
    80005178:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000517c:	ffffd097          	auipc	ra,0xffffd
    80005180:	86e080e7          	jalr	-1938(ra) # 800019ea <myproc>
    80005184:	84aa                	mv	s1,a0

  begin_op();
    80005186:	fffff097          	auipc	ra,0xfffff
    8000518a:	47e080e7          	jalr	1150(ra) # 80004604 <begin_op>

  if((ip = namei(path)) == 0){
    8000518e:	854a                	mv	a0,s2
    80005190:	fffff097          	auipc	ra,0xfffff
    80005194:	258080e7          	jalr	600(ra) # 800043e8 <namei>
    80005198:	c93d                	beqz	a0,8000520e <exec+0xc4>
    8000519a:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000519c:	fffff097          	auipc	ra,0xfffff
    800051a0:	aa6080e7          	jalr	-1370(ra) # 80003c42 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800051a4:	04000713          	li	a4,64
    800051a8:	4681                	li	a3,0
    800051aa:	e5040613          	addi	a2,s0,-432
    800051ae:	4581                	li	a1,0
    800051b0:	8556                	mv	a0,s5
    800051b2:	fffff097          	auipc	ra,0xfffff
    800051b6:	d44080e7          	jalr	-700(ra) # 80003ef6 <readi>
    800051ba:	04000793          	li	a5,64
    800051be:	00f51a63          	bne	a0,a5,800051d2 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800051c2:	e5042703          	lw	a4,-432(s0)
    800051c6:	464c47b7          	lui	a5,0x464c4
    800051ca:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051ce:	04f70663          	beq	a4,a5,8000521a <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051d2:	8556                	mv	a0,s5
    800051d4:	fffff097          	auipc	ra,0xfffff
    800051d8:	cd0080e7          	jalr	-816(ra) # 80003ea4 <iunlockput>
    end_op();
    800051dc:	fffff097          	auipc	ra,0xfffff
    800051e0:	4a8080e7          	jalr	1192(ra) # 80004684 <end_op>
  }
  return -1;
    800051e4:	557d                	li	a0,-1
}
    800051e6:	21813083          	ld	ra,536(sp)
    800051ea:	21013403          	ld	s0,528(sp)
    800051ee:	20813483          	ld	s1,520(sp)
    800051f2:	20013903          	ld	s2,512(sp)
    800051f6:	79fe                	ld	s3,504(sp)
    800051f8:	7a5e                	ld	s4,496(sp)
    800051fa:	7abe                	ld	s5,488(sp)
    800051fc:	7b1e                	ld	s6,480(sp)
    800051fe:	6bfe                	ld	s7,472(sp)
    80005200:	6c5e                	ld	s8,464(sp)
    80005202:	6cbe                	ld	s9,456(sp)
    80005204:	6d1e                	ld	s10,448(sp)
    80005206:	7dfa                	ld	s11,440(sp)
    80005208:	22010113          	addi	sp,sp,544
    8000520c:	8082                	ret
    end_op();
    8000520e:	fffff097          	auipc	ra,0xfffff
    80005212:	476080e7          	jalr	1142(ra) # 80004684 <end_op>
    return -1;
    80005216:	557d                	li	a0,-1
    80005218:	b7f9                	j	800051e6 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000521a:	8526                	mv	a0,s1
    8000521c:	ffffd097          	auipc	ra,0xffffd
    80005220:	892080e7          	jalr	-1902(ra) # 80001aae <proc_pagetable>
    80005224:	8b2a                	mv	s6,a0
    80005226:	d555                	beqz	a0,800051d2 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005228:	e7042783          	lw	a5,-400(s0)
    8000522c:	e8845703          	lhu	a4,-376(s0)
    80005230:	c735                	beqz	a4,8000529c <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005232:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005234:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005238:	6a05                	lui	s4,0x1
    8000523a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000523e:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005242:	6d85                	lui	s11,0x1
    80005244:	7d7d                	lui	s10,0xfffff
    80005246:	a481                	j	80005486 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005248:	00003517          	auipc	a0,0x3
    8000524c:	4b050513          	addi	a0,a0,1200 # 800086f8 <syscalls+0x2a8>
    80005250:	ffffb097          	auipc	ra,0xffffb
    80005254:	2ee080e7          	jalr	750(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005258:	874a                	mv	a4,s2
    8000525a:	009c86bb          	addw	a3,s9,s1
    8000525e:	4581                	li	a1,0
    80005260:	8556                	mv	a0,s5
    80005262:	fffff097          	auipc	ra,0xfffff
    80005266:	c94080e7          	jalr	-876(ra) # 80003ef6 <readi>
    8000526a:	2501                	sext.w	a0,a0
    8000526c:	1aa91a63          	bne	s2,a0,80005420 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80005270:	009d84bb          	addw	s1,s11,s1
    80005274:	013d09bb          	addw	s3,s10,s3
    80005278:	1f74f763          	bgeu	s1,s7,80005466 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    8000527c:	02049593          	slli	a1,s1,0x20
    80005280:	9181                	srli	a1,a1,0x20
    80005282:	95e2                	add	a1,a1,s8
    80005284:	855a                	mv	a0,s6
    80005286:	ffffc097          	auipc	ra,0xffffc
    8000528a:	dd6080e7          	jalr	-554(ra) # 8000105c <walkaddr>
    8000528e:	862a                	mv	a2,a0
    if(pa == 0)
    80005290:	dd45                	beqz	a0,80005248 <exec+0xfe>
      n = PGSIZE;
    80005292:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005294:	fd49f2e3          	bgeu	s3,s4,80005258 <exec+0x10e>
      n = sz - i;
    80005298:	894e                	mv	s2,s3
    8000529a:	bf7d                	j	80005258 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000529c:	4901                	li	s2,0
  iunlockput(ip);
    8000529e:	8556                	mv	a0,s5
    800052a0:	fffff097          	auipc	ra,0xfffff
    800052a4:	c04080e7          	jalr	-1020(ra) # 80003ea4 <iunlockput>
  end_op();
    800052a8:	fffff097          	auipc	ra,0xfffff
    800052ac:	3dc080e7          	jalr	988(ra) # 80004684 <end_op>
  p = myproc();
    800052b0:	ffffc097          	auipc	ra,0xffffc
    800052b4:	73a080e7          	jalr	1850(ra) # 800019ea <myproc>
    800052b8:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800052ba:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800052be:	6785                	lui	a5,0x1
    800052c0:	17fd                	addi	a5,a5,-1
    800052c2:	993e                	add	s2,s2,a5
    800052c4:	77fd                	lui	a5,0xfffff
    800052c6:	00f977b3          	and	a5,s2,a5
    800052ca:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052ce:	4691                	li	a3,4
    800052d0:	6609                	lui	a2,0x2
    800052d2:	963e                	add	a2,a2,a5
    800052d4:	85be                	mv	a1,a5
    800052d6:	855a                	mv	a0,s6
    800052d8:	ffffc097          	auipc	ra,0xffffc
    800052dc:	138080e7          	jalr	312(ra) # 80001410 <uvmalloc>
    800052e0:	8c2a                	mv	s8,a0
  ip = 0;
    800052e2:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800052e4:	12050e63          	beqz	a0,80005420 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    800052e8:	75f9                	lui	a1,0xffffe
    800052ea:	95aa                	add	a1,a1,a0
    800052ec:	855a                	mv	a0,s6
    800052ee:	ffffc097          	auipc	ra,0xffffc
    800052f2:	348080e7          	jalr	840(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    800052f6:	7afd                	lui	s5,0xfffff
    800052f8:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800052fa:	df043783          	ld	a5,-528(s0)
    800052fe:	6388                	ld	a0,0(a5)
    80005300:	c925                	beqz	a0,80005370 <exec+0x226>
    80005302:	e9040993          	addi	s3,s0,-368
    80005306:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000530a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000530c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000530e:	ffffc097          	auipc	ra,0xffffc
    80005312:	b40080e7          	jalr	-1216(ra) # 80000e4e <strlen>
    80005316:	0015079b          	addiw	a5,a0,1
    8000531a:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000531e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005322:	13596663          	bltu	s2,s5,8000544e <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005326:	df043d83          	ld	s11,-528(s0)
    8000532a:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000532e:	8552                	mv	a0,s4
    80005330:	ffffc097          	auipc	ra,0xffffc
    80005334:	b1e080e7          	jalr	-1250(ra) # 80000e4e <strlen>
    80005338:	0015069b          	addiw	a3,a0,1
    8000533c:	8652                	mv	a2,s4
    8000533e:	85ca                	mv	a1,s2
    80005340:	855a                	mv	a0,s6
    80005342:	ffffc097          	auipc	ra,0xffffc
    80005346:	326080e7          	jalr	806(ra) # 80001668 <copyout>
    8000534a:	10054663          	bltz	a0,80005456 <exec+0x30c>
    ustack[argc] = sp;
    8000534e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005352:	0485                	addi	s1,s1,1
    80005354:	008d8793          	addi	a5,s11,8
    80005358:	def43823          	sd	a5,-528(s0)
    8000535c:	008db503          	ld	a0,8(s11)
    80005360:	c911                	beqz	a0,80005374 <exec+0x22a>
    if(argc >= MAXARG)
    80005362:	09a1                	addi	s3,s3,8
    80005364:	fb3c95e3          	bne	s9,s3,8000530e <exec+0x1c4>
  sz = sz1;
    80005368:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000536c:	4a81                	li	s5,0
    8000536e:	a84d                	j	80005420 <exec+0x2d6>
  sp = sz;
    80005370:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005372:	4481                	li	s1,0
  ustack[argc] = 0;
    80005374:	00349793          	slli	a5,s1,0x3
    80005378:	f9040713          	addi	a4,s0,-112
    8000537c:	97ba                	add	a5,a5,a4
    8000537e:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffda380>
  sp -= (argc+1) * sizeof(uint64);
    80005382:	00148693          	addi	a3,s1,1
    80005386:	068e                	slli	a3,a3,0x3
    80005388:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000538c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005390:	01597663          	bgeu	s2,s5,8000539c <exec+0x252>
  sz = sz1;
    80005394:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005398:	4a81                	li	s5,0
    8000539a:	a059                	j	80005420 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000539c:	e9040613          	addi	a2,s0,-368
    800053a0:	85ca                	mv	a1,s2
    800053a2:	855a                	mv	a0,s6
    800053a4:	ffffc097          	auipc	ra,0xffffc
    800053a8:	2c4080e7          	jalr	708(ra) # 80001668 <copyout>
    800053ac:	0a054963          	bltz	a0,8000545e <exec+0x314>
  p->trapframe->a1 = sp;
    800053b0:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800053b4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800053b8:	de843783          	ld	a5,-536(s0)
    800053bc:	0007c703          	lbu	a4,0(a5)
    800053c0:	cf11                	beqz	a4,800053dc <exec+0x292>
    800053c2:	0785                	addi	a5,a5,1
    if(*s == '/')
    800053c4:	02f00693          	li	a3,47
    800053c8:	a039                	j	800053d6 <exec+0x28c>
      last = s+1;
    800053ca:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800053ce:	0785                	addi	a5,a5,1
    800053d0:	fff7c703          	lbu	a4,-1(a5)
    800053d4:	c701                	beqz	a4,800053dc <exec+0x292>
    if(*s == '/')
    800053d6:	fed71ce3          	bne	a4,a3,800053ce <exec+0x284>
    800053da:	bfc5                	j	800053ca <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    800053dc:	4641                	li	a2,16
    800053de:	de843583          	ld	a1,-536(s0)
    800053e2:	158b8513          	addi	a0,s7,344
    800053e6:	ffffc097          	auipc	ra,0xffffc
    800053ea:	a36080e7          	jalr	-1482(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800053ee:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800053f2:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800053f6:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053fa:	058bb783          	ld	a5,88(s7)
    800053fe:	e6843703          	ld	a4,-408(s0)
    80005402:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005404:	058bb783          	ld	a5,88(s7)
    80005408:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000540c:	85ea                	mv	a1,s10
    8000540e:	ffffc097          	auipc	ra,0xffffc
    80005412:	73c080e7          	jalr	1852(ra) # 80001b4a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005416:	0004851b          	sext.w	a0,s1
    8000541a:	b3f1                	j	800051e6 <exec+0x9c>
    8000541c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005420:	df843583          	ld	a1,-520(s0)
    80005424:	855a                	mv	a0,s6
    80005426:	ffffc097          	auipc	ra,0xffffc
    8000542a:	724080e7          	jalr	1828(ra) # 80001b4a <proc_freepagetable>
  if(ip){
    8000542e:	da0a92e3          	bnez	s5,800051d2 <exec+0x88>
  return -1;
    80005432:	557d                	li	a0,-1
    80005434:	bb4d                	j	800051e6 <exec+0x9c>
    80005436:	df243c23          	sd	s2,-520(s0)
    8000543a:	b7dd                	j	80005420 <exec+0x2d6>
    8000543c:	df243c23          	sd	s2,-520(s0)
    80005440:	b7c5                	j	80005420 <exec+0x2d6>
    80005442:	df243c23          	sd	s2,-520(s0)
    80005446:	bfe9                	j	80005420 <exec+0x2d6>
    80005448:	df243c23          	sd	s2,-520(s0)
    8000544c:	bfd1                	j	80005420 <exec+0x2d6>
  sz = sz1;
    8000544e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005452:	4a81                	li	s5,0
    80005454:	b7f1                	j	80005420 <exec+0x2d6>
  sz = sz1;
    80005456:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000545a:	4a81                	li	s5,0
    8000545c:	b7d1                	j	80005420 <exec+0x2d6>
  sz = sz1;
    8000545e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005462:	4a81                	li	s5,0
    80005464:	bf75                	j	80005420 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005466:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000546a:	e0843783          	ld	a5,-504(s0)
    8000546e:	0017869b          	addiw	a3,a5,1
    80005472:	e0d43423          	sd	a3,-504(s0)
    80005476:	e0043783          	ld	a5,-512(s0)
    8000547a:	0387879b          	addiw	a5,a5,56
    8000547e:	e8845703          	lhu	a4,-376(s0)
    80005482:	e0e6dee3          	bge	a3,a4,8000529e <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005486:	2781                	sext.w	a5,a5
    80005488:	e0f43023          	sd	a5,-512(s0)
    8000548c:	03800713          	li	a4,56
    80005490:	86be                	mv	a3,a5
    80005492:	e1840613          	addi	a2,s0,-488
    80005496:	4581                	li	a1,0
    80005498:	8556                	mv	a0,s5
    8000549a:	fffff097          	auipc	ra,0xfffff
    8000549e:	a5c080e7          	jalr	-1444(ra) # 80003ef6 <readi>
    800054a2:	03800793          	li	a5,56
    800054a6:	f6f51be3          	bne	a0,a5,8000541c <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    800054aa:	e1842783          	lw	a5,-488(s0)
    800054ae:	4705                	li	a4,1
    800054b0:	fae79de3          	bne	a5,a4,8000546a <exec+0x320>
    if(ph.memsz < ph.filesz)
    800054b4:	e4043483          	ld	s1,-448(s0)
    800054b8:	e3843783          	ld	a5,-456(s0)
    800054bc:	f6f4ede3          	bltu	s1,a5,80005436 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800054c0:	e2843783          	ld	a5,-472(s0)
    800054c4:	94be                	add	s1,s1,a5
    800054c6:	f6f4ebe3          	bltu	s1,a5,8000543c <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    800054ca:	de043703          	ld	a4,-544(s0)
    800054ce:	8ff9                	and	a5,a5,a4
    800054d0:	fbad                	bnez	a5,80005442 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054d2:	e1c42503          	lw	a0,-484(s0)
    800054d6:	00000097          	auipc	ra,0x0
    800054da:	c58080e7          	jalr	-936(ra) # 8000512e <flags2perm>
    800054de:	86aa                	mv	a3,a0
    800054e0:	8626                	mv	a2,s1
    800054e2:	85ca                	mv	a1,s2
    800054e4:	855a                	mv	a0,s6
    800054e6:	ffffc097          	auipc	ra,0xffffc
    800054ea:	f2a080e7          	jalr	-214(ra) # 80001410 <uvmalloc>
    800054ee:	dea43c23          	sd	a0,-520(s0)
    800054f2:	d939                	beqz	a0,80005448 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800054f4:	e2843c03          	ld	s8,-472(s0)
    800054f8:	e2042c83          	lw	s9,-480(s0)
    800054fc:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005500:	f60b83e3          	beqz	s7,80005466 <exec+0x31c>
    80005504:	89de                	mv	s3,s7
    80005506:	4481                	li	s1,0
    80005508:	bb95                	j	8000527c <exec+0x132>

000000008000550a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000550a:	7179                	addi	sp,sp,-48
    8000550c:	f406                	sd	ra,40(sp)
    8000550e:	f022                	sd	s0,32(sp)
    80005510:	ec26                	sd	s1,24(sp)
    80005512:	e84a                	sd	s2,16(sp)
    80005514:	1800                	addi	s0,sp,48
    80005516:	892e                	mv	s2,a1
    80005518:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000551a:	fdc40593          	addi	a1,s0,-36
    8000551e:	ffffe097          	auipc	ra,0xffffe
    80005522:	9ba080e7          	jalr	-1606(ra) # 80002ed8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005526:	fdc42703          	lw	a4,-36(s0)
    8000552a:	47bd                	li	a5,15
    8000552c:	02e7eb63          	bltu	a5,a4,80005562 <argfd+0x58>
    80005530:	ffffc097          	auipc	ra,0xffffc
    80005534:	4ba080e7          	jalr	1210(ra) # 800019ea <myproc>
    80005538:	fdc42703          	lw	a4,-36(s0)
    8000553c:	01a70793          	addi	a5,a4,26
    80005540:	078e                	slli	a5,a5,0x3
    80005542:	953e                	add	a0,a0,a5
    80005544:	611c                	ld	a5,0(a0)
    80005546:	c385                	beqz	a5,80005566 <argfd+0x5c>
    return -1;
  if(pfd)
    80005548:	00090463          	beqz	s2,80005550 <argfd+0x46>
    *pfd = fd;
    8000554c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005550:	4501                	li	a0,0
  if(pf)
    80005552:	c091                	beqz	s1,80005556 <argfd+0x4c>
    *pf = f;
    80005554:	e09c                	sd	a5,0(s1)
}
    80005556:	70a2                	ld	ra,40(sp)
    80005558:	7402                	ld	s0,32(sp)
    8000555a:	64e2                	ld	s1,24(sp)
    8000555c:	6942                	ld	s2,16(sp)
    8000555e:	6145                	addi	sp,sp,48
    80005560:	8082                	ret
    return -1;
    80005562:	557d                	li	a0,-1
    80005564:	bfcd                	j	80005556 <argfd+0x4c>
    80005566:	557d                	li	a0,-1
    80005568:	b7fd                	j	80005556 <argfd+0x4c>

000000008000556a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000556a:	1101                	addi	sp,sp,-32
    8000556c:	ec06                	sd	ra,24(sp)
    8000556e:	e822                	sd	s0,16(sp)
    80005570:	e426                	sd	s1,8(sp)
    80005572:	1000                	addi	s0,sp,32
    80005574:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005576:	ffffc097          	auipc	ra,0xffffc
    8000557a:	474080e7          	jalr	1140(ra) # 800019ea <myproc>
    8000557e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005580:	0d050793          	addi	a5,a0,208
    80005584:	4501                	li	a0,0
    80005586:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005588:	6398                	ld	a4,0(a5)
    8000558a:	cb19                	beqz	a4,800055a0 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000558c:	2505                	addiw	a0,a0,1
    8000558e:	07a1                	addi	a5,a5,8
    80005590:	fed51ce3          	bne	a0,a3,80005588 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005594:	557d                	li	a0,-1
}
    80005596:	60e2                	ld	ra,24(sp)
    80005598:	6442                	ld	s0,16(sp)
    8000559a:	64a2                	ld	s1,8(sp)
    8000559c:	6105                	addi	sp,sp,32
    8000559e:	8082                	ret
      p->ofile[fd] = f;
    800055a0:	01a50793          	addi	a5,a0,26
    800055a4:	078e                	slli	a5,a5,0x3
    800055a6:	963e                	add	a2,a2,a5
    800055a8:	e204                	sd	s1,0(a2)
      return fd;
    800055aa:	b7f5                	j	80005596 <fdalloc+0x2c>

00000000800055ac <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055ac:	715d                	addi	sp,sp,-80
    800055ae:	e486                	sd	ra,72(sp)
    800055b0:	e0a2                	sd	s0,64(sp)
    800055b2:	fc26                	sd	s1,56(sp)
    800055b4:	f84a                	sd	s2,48(sp)
    800055b6:	f44e                	sd	s3,40(sp)
    800055b8:	f052                	sd	s4,32(sp)
    800055ba:	ec56                	sd	s5,24(sp)
    800055bc:	e85a                	sd	s6,16(sp)
    800055be:	0880                	addi	s0,sp,80
    800055c0:	8b2e                	mv	s6,a1
    800055c2:	89b2                	mv	s3,a2
    800055c4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800055c6:	fb040593          	addi	a1,s0,-80
    800055ca:	fffff097          	auipc	ra,0xfffff
    800055ce:	e3c080e7          	jalr	-452(ra) # 80004406 <nameiparent>
    800055d2:	84aa                	mv	s1,a0
    800055d4:	14050f63          	beqz	a0,80005732 <create+0x186>
    return 0;

  ilock(dp);
    800055d8:	ffffe097          	auipc	ra,0xffffe
    800055dc:	66a080e7          	jalr	1642(ra) # 80003c42 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800055e0:	4601                	li	a2,0
    800055e2:	fb040593          	addi	a1,s0,-80
    800055e6:	8526                	mv	a0,s1
    800055e8:	fffff097          	auipc	ra,0xfffff
    800055ec:	b3e080e7          	jalr	-1218(ra) # 80004126 <dirlookup>
    800055f0:	8aaa                	mv	s5,a0
    800055f2:	c931                	beqz	a0,80005646 <create+0x9a>
    iunlockput(dp);
    800055f4:	8526                	mv	a0,s1
    800055f6:	fffff097          	auipc	ra,0xfffff
    800055fa:	8ae080e7          	jalr	-1874(ra) # 80003ea4 <iunlockput>
    ilock(ip);
    800055fe:	8556                	mv	a0,s5
    80005600:	ffffe097          	auipc	ra,0xffffe
    80005604:	642080e7          	jalr	1602(ra) # 80003c42 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005608:	000b059b          	sext.w	a1,s6
    8000560c:	4789                	li	a5,2
    8000560e:	02f59563          	bne	a1,a5,80005638 <create+0x8c>
    80005612:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffda4c4>
    80005616:	37f9                	addiw	a5,a5,-2
    80005618:	17c2                	slli	a5,a5,0x30
    8000561a:	93c1                	srli	a5,a5,0x30
    8000561c:	4705                	li	a4,1
    8000561e:	00f76d63          	bltu	a4,a5,80005638 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005622:	8556                	mv	a0,s5
    80005624:	60a6                	ld	ra,72(sp)
    80005626:	6406                	ld	s0,64(sp)
    80005628:	74e2                	ld	s1,56(sp)
    8000562a:	7942                	ld	s2,48(sp)
    8000562c:	79a2                	ld	s3,40(sp)
    8000562e:	7a02                	ld	s4,32(sp)
    80005630:	6ae2                	ld	s5,24(sp)
    80005632:	6b42                	ld	s6,16(sp)
    80005634:	6161                	addi	sp,sp,80
    80005636:	8082                	ret
    iunlockput(ip);
    80005638:	8556                	mv	a0,s5
    8000563a:	fffff097          	auipc	ra,0xfffff
    8000563e:	86a080e7          	jalr	-1942(ra) # 80003ea4 <iunlockput>
    return 0;
    80005642:	4a81                	li	s5,0
    80005644:	bff9                	j	80005622 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005646:	85da                	mv	a1,s6
    80005648:	4088                	lw	a0,0(s1)
    8000564a:	ffffe097          	auipc	ra,0xffffe
    8000564e:	45c080e7          	jalr	1116(ra) # 80003aa6 <ialloc>
    80005652:	8a2a                	mv	s4,a0
    80005654:	c539                	beqz	a0,800056a2 <create+0xf6>
  ilock(ip);
    80005656:	ffffe097          	auipc	ra,0xffffe
    8000565a:	5ec080e7          	jalr	1516(ra) # 80003c42 <ilock>
  ip->major = major;
    8000565e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005662:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005666:	4905                	li	s2,1
    80005668:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000566c:	8552                	mv	a0,s4
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	50a080e7          	jalr	1290(ra) # 80003b78 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005676:	000b059b          	sext.w	a1,s6
    8000567a:	03258b63          	beq	a1,s2,800056b0 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000567e:	004a2603          	lw	a2,4(s4)
    80005682:	fb040593          	addi	a1,s0,-80
    80005686:	8526                	mv	a0,s1
    80005688:	fffff097          	auipc	ra,0xfffff
    8000568c:	cae080e7          	jalr	-850(ra) # 80004336 <dirlink>
    80005690:	06054f63          	bltz	a0,8000570e <create+0x162>
  iunlockput(dp);
    80005694:	8526                	mv	a0,s1
    80005696:	fffff097          	auipc	ra,0xfffff
    8000569a:	80e080e7          	jalr	-2034(ra) # 80003ea4 <iunlockput>
  return ip;
    8000569e:	8ad2                	mv	s5,s4
    800056a0:	b749                	j	80005622 <create+0x76>
    iunlockput(dp);
    800056a2:	8526                	mv	a0,s1
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	800080e7          	jalr	-2048(ra) # 80003ea4 <iunlockput>
    return 0;
    800056ac:	8ad2                	mv	s5,s4
    800056ae:	bf95                	j	80005622 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800056b0:	004a2603          	lw	a2,4(s4)
    800056b4:	00003597          	auipc	a1,0x3
    800056b8:	06458593          	addi	a1,a1,100 # 80008718 <syscalls+0x2c8>
    800056bc:	8552                	mv	a0,s4
    800056be:	fffff097          	auipc	ra,0xfffff
    800056c2:	c78080e7          	jalr	-904(ra) # 80004336 <dirlink>
    800056c6:	04054463          	bltz	a0,8000570e <create+0x162>
    800056ca:	40d0                	lw	a2,4(s1)
    800056cc:	00003597          	auipc	a1,0x3
    800056d0:	05458593          	addi	a1,a1,84 # 80008720 <syscalls+0x2d0>
    800056d4:	8552                	mv	a0,s4
    800056d6:	fffff097          	auipc	ra,0xfffff
    800056da:	c60080e7          	jalr	-928(ra) # 80004336 <dirlink>
    800056de:	02054863          	bltz	a0,8000570e <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800056e2:	004a2603          	lw	a2,4(s4)
    800056e6:	fb040593          	addi	a1,s0,-80
    800056ea:	8526                	mv	a0,s1
    800056ec:	fffff097          	auipc	ra,0xfffff
    800056f0:	c4a080e7          	jalr	-950(ra) # 80004336 <dirlink>
    800056f4:	00054d63          	bltz	a0,8000570e <create+0x162>
    dp->nlink++;  // for ".."
    800056f8:	04a4d783          	lhu	a5,74(s1)
    800056fc:	2785                	addiw	a5,a5,1
    800056fe:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005702:	8526                	mv	a0,s1
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	474080e7          	jalr	1140(ra) # 80003b78 <iupdate>
    8000570c:	b761                	j	80005694 <create+0xe8>
  ip->nlink = 0;
    8000570e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005712:	8552                	mv	a0,s4
    80005714:	ffffe097          	auipc	ra,0xffffe
    80005718:	464080e7          	jalr	1124(ra) # 80003b78 <iupdate>
  iunlockput(ip);
    8000571c:	8552                	mv	a0,s4
    8000571e:	ffffe097          	auipc	ra,0xffffe
    80005722:	786080e7          	jalr	1926(ra) # 80003ea4 <iunlockput>
  iunlockput(dp);
    80005726:	8526                	mv	a0,s1
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	77c080e7          	jalr	1916(ra) # 80003ea4 <iunlockput>
  return 0;
    80005730:	bdcd                	j	80005622 <create+0x76>
    return 0;
    80005732:	8aaa                	mv	s5,a0
    80005734:	b5fd                	j	80005622 <create+0x76>

0000000080005736 <sys_dup>:
{
    80005736:	7179                	addi	sp,sp,-48
    80005738:	f406                	sd	ra,40(sp)
    8000573a:	f022                	sd	s0,32(sp)
    8000573c:	ec26                	sd	s1,24(sp)
    8000573e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005740:	fd840613          	addi	a2,s0,-40
    80005744:	4581                	li	a1,0
    80005746:	4501                	li	a0,0
    80005748:	00000097          	auipc	ra,0x0
    8000574c:	dc2080e7          	jalr	-574(ra) # 8000550a <argfd>
    return -1;
    80005750:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005752:	02054363          	bltz	a0,80005778 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005756:	fd843503          	ld	a0,-40(s0)
    8000575a:	00000097          	auipc	ra,0x0
    8000575e:	e10080e7          	jalr	-496(ra) # 8000556a <fdalloc>
    80005762:	84aa                	mv	s1,a0
    return -1;
    80005764:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005766:	00054963          	bltz	a0,80005778 <sys_dup+0x42>
  filedup(f);
    8000576a:	fd843503          	ld	a0,-40(s0)
    8000576e:	fffff097          	auipc	ra,0xfffff
    80005772:	310080e7          	jalr	784(ra) # 80004a7e <filedup>
  return fd;
    80005776:	87a6                	mv	a5,s1
}
    80005778:	853e                	mv	a0,a5
    8000577a:	70a2                	ld	ra,40(sp)
    8000577c:	7402                	ld	s0,32(sp)
    8000577e:	64e2                	ld	s1,24(sp)
    80005780:	6145                	addi	sp,sp,48
    80005782:	8082                	ret

0000000080005784 <sys_read>:
{
    80005784:	7179                	addi	sp,sp,-48
    80005786:	f406                	sd	ra,40(sp)
    80005788:	f022                	sd	s0,32(sp)
    8000578a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000578c:	fd840593          	addi	a1,s0,-40
    80005790:	4505                	li	a0,1
    80005792:	ffffd097          	auipc	ra,0xffffd
    80005796:	766080e7          	jalr	1894(ra) # 80002ef8 <argaddr>
  argint(2, &n);
    8000579a:	fe440593          	addi	a1,s0,-28
    8000579e:	4509                	li	a0,2
    800057a0:	ffffd097          	auipc	ra,0xffffd
    800057a4:	738080e7          	jalr	1848(ra) # 80002ed8 <argint>
  if(argfd(0, 0, &f) < 0)
    800057a8:	fe840613          	addi	a2,s0,-24
    800057ac:	4581                	li	a1,0
    800057ae:	4501                	li	a0,0
    800057b0:	00000097          	auipc	ra,0x0
    800057b4:	d5a080e7          	jalr	-678(ra) # 8000550a <argfd>
    800057b8:	87aa                	mv	a5,a0
    return -1;
    800057ba:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057bc:	0007cc63          	bltz	a5,800057d4 <sys_read+0x50>
  return fileread(f, p, n);
    800057c0:	fe442603          	lw	a2,-28(s0)
    800057c4:	fd843583          	ld	a1,-40(s0)
    800057c8:	fe843503          	ld	a0,-24(s0)
    800057cc:	fffff097          	auipc	ra,0xfffff
    800057d0:	43e080e7          	jalr	1086(ra) # 80004c0a <fileread>
}
    800057d4:	70a2                	ld	ra,40(sp)
    800057d6:	7402                	ld	s0,32(sp)
    800057d8:	6145                	addi	sp,sp,48
    800057da:	8082                	ret

00000000800057dc <sys_write>:
{
    800057dc:	7179                	addi	sp,sp,-48
    800057de:	f406                	sd	ra,40(sp)
    800057e0:	f022                	sd	s0,32(sp)
    800057e2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800057e4:	fd840593          	addi	a1,s0,-40
    800057e8:	4505                	li	a0,1
    800057ea:	ffffd097          	auipc	ra,0xffffd
    800057ee:	70e080e7          	jalr	1806(ra) # 80002ef8 <argaddr>
  argint(2, &n);
    800057f2:	fe440593          	addi	a1,s0,-28
    800057f6:	4509                	li	a0,2
    800057f8:	ffffd097          	auipc	ra,0xffffd
    800057fc:	6e0080e7          	jalr	1760(ra) # 80002ed8 <argint>
  if(argfd(0, 0, &f) < 0)
    80005800:	fe840613          	addi	a2,s0,-24
    80005804:	4581                	li	a1,0
    80005806:	4501                	li	a0,0
    80005808:	00000097          	auipc	ra,0x0
    8000580c:	d02080e7          	jalr	-766(ra) # 8000550a <argfd>
    80005810:	87aa                	mv	a5,a0
    return -1;
    80005812:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005814:	0007cc63          	bltz	a5,8000582c <sys_write+0x50>
  return filewrite(f, p, n);
    80005818:	fe442603          	lw	a2,-28(s0)
    8000581c:	fd843583          	ld	a1,-40(s0)
    80005820:	fe843503          	ld	a0,-24(s0)
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	4a8080e7          	jalr	1192(ra) # 80004ccc <filewrite>
}
    8000582c:	70a2                	ld	ra,40(sp)
    8000582e:	7402                	ld	s0,32(sp)
    80005830:	6145                	addi	sp,sp,48
    80005832:	8082                	ret

0000000080005834 <sys_close>:
{
    80005834:	1101                	addi	sp,sp,-32
    80005836:	ec06                	sd	ra,24(sp)
    80005838:	e822                	sd	s0,16(sp)
    8000583a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000583c:	fe040613          	addi	a2,s0,-32
    80005840:	fec40593          	addi	a1,s0,-20
    80005844:	4501                	li	a0,0
    80005846:	00000097          	auipc	ra,0x0
    8000584a:	cc4080e7          	jalr	-828(ra) # 8000550a <argfd>
    return -1;
    8000584e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005850:	02054463          	bltz	a0,80005878 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005854:	ffffc097          	auipc	ra,0xffffc
    80005858:	196080e7          	jalr	406(ra) # 800019ea <myproc>
    8000585c:	fec42783          	lw	a5,-20(s0)
    80005860:	07e9                	addi	a5,a5,26
    80005862:	078e                	slli	a5,a5,0x3
    80005864:	97aa                	add	a5,a5,a0
    80005866:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000586a:	fe043503          	ld	a0,-32(s0)
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	262080e7          	jalr	610(ra) # 80004ad0 <fileclose>
  return 0;
    80005876:	4781                	li	a5,0
}
    80005878:	853e                	mv	a0,a5
    8000587a:	60e2                	ld	ra,24(sp)
    8000587c:	6442                	ld	s0,16(sp)
    8000587e:	6105                	addi	sp,sp,32
    80005880:	8082                	ret

0000000080005882 <sys_fstat>:
{
    80005882:	1101                	addi	sp,sp,-32
    80005884:	ec06                	sd	ra,24(sp)
    80005886:	e822                	sd	s0,16(sp)
    80005888:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000588a:	fe040593          	addi	a1,s0,-32
    8000588e:	4505                	li	a0,1
    80005890:	ffffd097          	auipc	ra,0xffffd
    80005894:	668080e7          	jalr	1640(ra) # 80002ef8 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005898:	fe840613          	addi	a2,s0,-24
    8000589c:	4581                	li	a1,0
    8000589e:	4501                	li	a0,0
    800058a0:	00000097          	auipc	ra,0x0
    800058a4:	c6a080e7          	jalr	-918(ra) # 8000550a <argfd>
    800058a8:	87aa                	mv	a5,a0
    return -1;
    800058aa:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800058ac:	0007ca63          	bltz	a5,800058c0 <sys_fstat+0x3e>
  return filestat(f, st);
    800058b0:	fe043583          	ld	a1,-32(s0)
    800058b4:	fe843503          	ld	a0,-24(s0)
    800058b8:	fffff097          	auipc	ra,0xfffff
    800058bc:	2e0080e7          	jalr	736(ra) # 80004b98 <filestat>
}
    800058c0:	60e2                	ld	ra,24(sp)
    800058c2:	6442                	ld	s0,16(sp)
    800058c4:	6105                	addi	sp,sp,32
    800058c6:	8082                	ret

00000000800058c8 <sys_link>:
{
    800058c8:	7169                	addi	sp,sp,-304
    800058ca:	f606                	sd	ra,296(sp)
    800058cc:	f222                	sd	s0,288(sp)
    800058ce:	ee26                	sd	s1,280(sp)
    800058d0:	ea4a                	sd	s2,272(sp)
    800058d2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058d4:	08000613          	li	a2,128
    800058d8:	ed040593          	addi	a1,s0,-304
    800058dc:	4501                	li	a0,0
    800058de:	ffffd097          	auipc	ra,0xffffd
    800058e2:	63a080e7          	jalr	1594(ra) # 80002f18 <argstr>
    return -1;
    800058e6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058e8:	10054e63          	bltz	a0,80005a04 <sys_link+0x13c>
    800058ec:	08000613          	li	a2,128
    800058f0:	f5040593          	addi	a1,s0,-176
    800058f4:	4505                	li	a0,1
    800058f6:	ffffd097          	auipc	ra,0xffffd
    800058fa:	622080e7          	jalr	1570(ra) # 80002f18 <argstr>
    return -1;
    800058fe:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005900:	10054263          	bltz	a0,80005a04 <sys_link+0x13c>
  begin_op();
    80005904:	fffff097          	auipc	ra,0xfffff
    80005908:	d00080e7          	jalr	-768(ra) # 80004604 <begin_op>
  if((ip = namei(old)) == 0){
    8000590c:	ed040513          	addi	a0,s0,-304
    80005910:	fffff097          	auipc	ra,0xfffff
    80005914:	ad8080e7          	jalr	-1320(ra) # 800043e8 <namei>
    80005918:	84aa                	mv	s1,a0
    8000591a:	c551                	beqz	a0,800059a6 <sys_link+0xde>
  ilock(ip);
    8000591c:	ffffe097          	auipc	ra,0xffffe
    80005920:	326080e7          	jalr	806(ra) # 80003c42 <ilock>
  if(ip->type == T_DIR){
    80005924:	04449703          	lh	a4,68(s1)
    80005928:	4785                	li	a5,1
    8000592a:	08f70463          	beq	a4,a5,800059b2 <sys_link+0xea>
  ip->nlink++;
    8000592e:	04a4d783          	lhu	a5,74(s1)
    80005932:	2785                	addiw	a5,a5,1
    80005934:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005938:	8526                	mv	a0,s1
    8000593a:	ffffe097          	auipc	ra,0xffffe
    8000593e:	23e080e7          	jalr	574(ra) # 80003b78 <iupdate>
  iunlock(ip);
    80005942:	8526                	mv	a0,s1
    80005944:	ffffe097          	auipc	ra,0xffffe
    80005948:	3c0080e7          	jalr	960(ra) # 80003d04 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000594c:	fd040593          	addi	a1,s0,-48
    80005950:	f5040513          	addi	a0,s0,-176
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	ab2080e7          	jalr	-1358(ra) # 80004406 <nameiparent>
    8000595c:	892a                	mv	s2,a0
    8000595e:	c935                	beqz	a0,800059d2 <sys_link+0x10a>
  ilock(dp);
    80005960:	ffffe097          	auipc	ra,0xffffe
    80005964:	2e2080e7          	jalr	738(ra) # 80003c42 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005968:	00092703          	lw	a4,0(s2)
    8000596c:	409c                	lw	a5,0(s1)
    8000596e:	04f71d63          	bne	a4,a5,800059c8 <sys_link+0x100>
    80005972:	40d0                	lw	a2,4(s1)
    80005974:	fd040593          	addi	a1,s0,-48
    80005978:	854a                	mv	a0,s2
    8000597a:	fffff097          	auipc	ra,0xfffff
    8000597e:	9bc080e7          	jalr	-1604(ra) # 80004336 <dirlink>
    80005982:	04054363          	bltz	a0,800059c8 <sys_link+0x100>
  iunlockput(dp);
    80005986:	854a                	mv	a0,s2
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	51c080e7          	jalr	1308(ra) # 80003ea4 <iunlockput>
  iput(ip);
    80005990:	8526                	mv	a0,s1
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	46a080e7          	jalr	1130(ra) # 80003dfc <iput>
  end_op();
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	cea080e7          	jalr	-790(ra) # 80004684 <end_op>
  return 0;
    800059a2:	4781                	li	a5,0
    800059a4:	a085                	j	80005a04 <sys_link+0x13c>
    end_op();
    800059a6:	fffff097          	auipc	ra,0xfffff
    800059aa:	cde080e7          	jalr	-802(ra) # 80004684 <end_op>
    return -1;
    800059ae:	57fd                	li	a5,-1
    800059b0:	a891                	j	80005a04 <sys_link+0x13c>
    iunlockput(ip);
    800059b2:	8526                	mv	a0,s1
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	4f0080e7          	jalr	1264(ra) # 80003ea4 <iunlockput>
    end_op();
    800059bc:	fffff097          	auipc	ra,0xfffff
    800059c0:	cc8080e7          	jalr	-824(ra) # 80004684 <end_op>
    return -1;
    800059c4:	57fd                	li	a5,-1
    800059c6:	a83d                	j	80005a04 <sys_link+0x13c>
    iunlockput(dp);
    800059c8:	854a                	mv	a0,s2
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	4da080e7          	jalr	1242(ra) # 80003ea4 <iunlockput>
  ilock(ip);
    800059d2:	8526                	mv	a0,s1
    800059d4:	ffffe097          	auipc	ra,0xffffe
    800059d8:	26e080e7          	jalr	622(ra) # 80003c42 <ilock>
  ip->nlink--;
    800059dc:	04a4d783          	lhu	a5,74(s1)
    800059e0:	37fd                	addiw	a5,a5,-1
    800059e2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059e6:	8526                	mv	a0,s1
    800059e8:	ffffe097          	auipc	ra,0xffffe
    800059ec:	190080e7          	jalr	400(ra) # 80003b78 <iupdate>
  iunlockput(ip);
    800059f0:	8526                	mv	a0,s1
    800059f2:	ffffe097          	auipc	ra,0xffffe
    800059f6:	4b2080e7          	jalr	1202(ra) # 80003ea4 <iunlockput>
  end_op();
    800059fa:	fffff097          	auipc	ra,0xfffff
    800059fe:	c8a080e7          	jalr	-886(ra) # 80004684 <end_op>
  return -1;
    80005a02:	57fd                	li	a5,-1
}
    80005a04:	853e                	mv	a0,a5
    80005a06:	70b2                	ld	ra,296(sp)
    80005a08:	7412                	ld	s0,288(sp)
    80005a0a:	64f2                	ld	s1,280(sp)
    80005a0c:	6952                	ld	s2,272(sp)
    80005a0e:	6155                	addi	sp,sp,304
    80005a10:	8082                	ret

0000000080005a12 <sys_unlink>:
{
    80005a12:	7151                	addi	sp,sp,-240
    80005a14:	f586                	sd	ra,232(sp)
    80005a16:	f1a2                	sd	s0,224(sp)
    80005a18:	eda6                	sd	s1,216(sp)
    80005a1a:	e9ca                	sd	s2,208(sp)
    80005a1c:	e5ce                	sd	s3,200(sp)
    80005a1e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a20:	08000613          	li	a2,128
    80005a24:	f3040593          	addi	a1,s0,-208
    80005a28:	4501                	li	a0,0
    80005a2a:	ffffd097          	auipc	ra,0xffffd
    80005a2e:	4ee080e7          	jalr	1262(ra) # 80002f18 <argstr>
    80005a32:	18054163          	bltz	a0,80005bb4 <sys_unlink+0x1a2>
  begin_op();
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	bce080e7          	jalr	-1074(ra) # 80004604 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a3e:	fb040593          	addi	a1,s0,-80
    80005a42:	f3040513          	addi	a0,s0,-208
    80005a46:	fffff097          	auipc	ra,0xfffff
    80005a4a:	9c0080e7          	jalr	-1600(ra) # 80004406 <nameiparent>
    80005a4e:	84aa                	mv	s1,a0
    80005a50:	c979                	beqz	a0,80005b26 <sys_unlink+0x114>
  ilock(dp);
    80005a52:	ffffe097          	auipc	ra,0xffffe
    80005a56:	1f0080e7          	jalr	496(ra) # 80003c42 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a5a:	00003597          	auipc	a1,0x3
    80005a5e:	cbe58593          	addi	a1,a1,-834 # 80008718 <syscalls+0x2c8>
    80005a62:	fb040513          	addi	a0,s0,-80
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	6a6080e7          	jalr	1702(ra) # 8000410c <namecmp>
    80005a6e:	14050a63          	beqz	a0,80005bc2 <sys_unlink+0x1b0>
    80005a72:	00003597          	auipc	a1,0x3
    80005a76:	cae58593          	addi	a1,a1,-850 # 80008720 <syscalls+0x2d0>
    80005a7a:	fb040513          	addi	a0,s0,-80
    80005a7e:	ffffe097          	auipc	ra,0xffffe
    80005a82:	68e080e7          	jalr	1678(ra) # 8000410c <namecmp>
    80005a86:	12050e63          	beqz	a0,80005bc2 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a8a:	f2c40613          	addi	a2,s0,-212
    80005a8e:	fb040593          	addi	a1,s0,-80
    80005a92:	8526                	mv	a0,s1
    80005a94:	ffffe097          	auipc	ra,0xffffe
    80005a98:	692080e7          	jalr	1682(ra) # 80004126 <dirlookup>
    80005a9c:	892a                	mv	s2,a0
    80005a9e:	12050263          	beqz	a0,80005bc2 <sys_unlink+0x1b0>
  ilock(ip);
    80005aa2:	ffffe097          	auipc	ra,0xffffe
    80005aa6:	1a0080e7          	jalr	416(ra) # 80003c42 <ilock>
  if(ip->nlink < 1)
    80005aaa:	04a91783          	lh	a5,74(s2)
    80005aae:	08f05263          	blez	a5,80005b32 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005ab2:	04491703          	lh	a4,68(s2)
    80005ab6:	4785                	li	a5,1
    80005ab8:	08f70563          	beq	a4,a5,80005b42 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005abc:	4641                	li	a2,16
    80005abe:	4581                	li	a1,0
    80005ac0:	fc040513          	addi	a0,s0,-64
    80005ac4:	ffffb097          	auipc	ra,0xffffb
    80005ac8:	20e080e7          	jalr	526(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005acc:	4741                	li	a4,16
    80005ace:	f2c42683          	lw	a3,-212(s0)
    80005ad2:	fc040613          	addi	a2,s0,-64
    80005ad6:	4581                	li	a1,0
    80005ad8:	8526                	mv	a0,s1
    80005ada:	ffffe097          	auipc	ra,0xffffe
    80005ade:	514080e7          	jalr	1300(ra) # 80003fee <writei>
    80005ae2:	47c1                	li	a5,16
    80005ae4:	0af51563          	bne	a0,a5,80005b8e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005ae8:	04491703          	lh	a4,68(s2)
    80005aec:	4785                	li	a5,1
    80005aee:	0af70863          	beq	a4,a5,80005b9e <sys_unlink+0x18c>
  iunlockput(dp);
    80005af2:	8526                	mv	a0,s1
    80005af4:	ffffe097          	auipc	ra,0xffffe
    80005af8:	3b0080e7          	jalr	944(ra) # 80003ea4 <iunlockput>
  ip->nlink--;
    80005afc:	04a95783          	lhu	a5,74(s2)
    80005b00:	37fd                	addiw	a5,a5,-1
    80005b02:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b06:	854a                	mv	a0,s2
    80005b08:	ffffe097          	auipc	ra,0xffffe
    80005b0c:	070080e7          	jalr	112(ra) # 80003b78 <iupdate>
  iunlockput(ip);
    80005b10:	854a                	mv	a0,s2
    80005b12:	ffffe097          	auipc	ra,0xffffe
    80005b16:	392080e7          	jalr	914(ra) # 80003ea4 <iunlockput>
  end_op();
    80005b1a:	fffff097          	auipc	ra,0xfffff
    80005b1e:	b6a080e7          	jalr	-1174(ra) # 80004684 <end_op>
  return 0;
    80005b22:	4501                	li	a0,0
    80005b24:	a84d                	j	80005bd6 <sys_unlink+0x1c4>
    end_op();
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	b5e080e7          	jalr	-1186(ra) # 80004684 <end_op>
    return -1;
    80005b2e:	557d                	li	a0,-1
    80005b30:	a05d                	j	80005bd6 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b32:	00003517          	auipc	a0,0x3
    80005b36:	bf650513          	addi	a0,a0,-1034 # 80008728 <syscalls+0x2d8>
    80005b3a:	ffffb097          	auipc	ra,0xffffb
    80005b3e:	a04080e7          	jalr	-1532(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b42:	04c92703          	lw	a4,76(s2)
    80005b46:	02000793          	li	a5,32
    80005b4a:	f6e7f9e3          	bgeu	a5,a4,80005abc <sys_unlink+0xaa>
    80005b4e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b52:	4741                	li	a4,16
    80005b54:	86ce                	mv	a3,s3
    80005b56:	f1840613          	addi	a2,s0,-232
    80005b5a:	4581                	li	a1,0
    80005b5c:	854a                	mv	a0,s2
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	398080e7          	jalr	920(ra) # 80003ef6 <readi>
    80005b66:	47c1                	li	a5,16
    80005b68:	00f51b63          	bne	a0,a5,80005b7e <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b6c:	f1845783          	lhu	a5,-232(s0)
    80005b70:	e7a1                	bnez	a5,80005bb8 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b72:	29c1                	addiw	s3,s3,16
    80005b74:	04c92783          	lw	a5,76(s2)
    80005b78:	fcf9ede3          	bltu	s3,a5,80005b52 <sys_unlink+0x140>
    80005b7c:	b781                	j	80005abc <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b7e:	00003517          	auipc	a0,0x3
    80005b82:	bc250513          	addi	a0,a0,-1086 # 80008740 <syscalls+0x2f0>
    80005b86:	ffffb097          	auipc	ra,0xffffb
    80005b8a:	9b8080e7          	jalr	-1608(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005b8e:	00003517          	auipc	a0,0x3
    80005b92:	bca50513          	addi	a0,a0,-1078 # 80008758 <syscalls+0x308>
    80005b96:	ffffb097          	auipc	ra,0xffffb
    80005b9a:	9a8080e7          	jalr	-1624(ra) # 8000053e <panic>
    dp->nlink--;
    80005b9e:	04a4d783          	lhu	a5,74(s1)
    80005ba2:	37fd                	addiw	a5,a5,-1
    80005ba4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005ba8:	8526                	mv	a0,s1
    80005baa:	ffffe097          	auipc	ra,0xffffe
    80005bae:	fce080e7          	jalr	-50(ra) # 80003b78 <iupdate>
    80005bb2:	b781                	j	80005af2 <sys_unlink+0xe0>
    return -1;
    80005bb4:	557d                	li	a0,-1
    80005bb6:	a005                	j	80005bd6 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005bb8:	854a                	mv	a0,s2
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	2ea080e7          	jalr	746(ra) # 80003ea4 <iunlockput>
  iunlockput(dp);
    80005bc2:	8526                	mv	a0,s1
    80005bc4:	ffffe097          	auipc	ra,0xffffe
    80005bc8:	2e0080e7          	jalr	736(ra) # 80003ea4 <iunlockput>
  end_op();
    80005bcc:	fffff097          	auipc	ra,0xfffff
    80005bd0:	ab8080e7          	jalr	-1352(ra) # 80004684 <end_op>
  return -1;
    80005bd4:	557d                	li	a0,-1
}
    80005bd6:	70ae                	ld	ra,232(sp)
    80005bd8:	740e                	ld	s0,224(sp)
    80005bda:	64ee                	ld	s1,216(sp)
    80005bdc:	694e                	ld	s2,208(sp)
    80005bde:	69ae                	ld	s3,200(sp)
    80005be0:	616d                	addi	sp,sp,240
    80005be2:	8082                	ret

0000000080005be4 <sys_open>:

uint64
sys_open(void)
{
    80005be4:	7131                	addi	sp,sp,-192
    80005be6:	fd06                	sd	ra,184(sp)
    80005be8:	f922                	sd	s0,176(sp)
    80005bea:	f526                	sd	s1,168(sp)
    80005bec:	f14a                	sd	s2,160(sp)
    80005bee:	ed4e                	sd	s3,152(sp)
    80005bf0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005bf2:	f4c40593          	addi	a1,s0,-180
    80005bf6:	4505                	li	a0,1
    80005bf8:	ffffd097          	auipc	ra,0xffffd
    80005bfc:	2e0080e7          	jalr	736(ra) # 80002ed8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c00:	08000613          	li	a2,128
    80005c04:	f5040593          	addi	a1,s0,-176
    80005c08:	4501                	li	a0,0
    80005c0a:	ffffd097          	auipc	ra,0xffffd
    80005c0e:	30e080e7          	jalr	782(ra) # 80002f18 <argstr>
    80005c12:	87aa                	mv	a5,a0
    return -1;
    80005c14:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c16:	0a07c963          	bltz	a5,80005cc8 <sys_open+0xe4>

  begin_op();
    80005c1a:	fffff097          	auipc	ra,0xfffff
    80005c1e:	9ea080e7          	jalr	-1558(ra) # 80004604 <begin_op>

  if(omode & O_CREATE){
    80005c22:	f4c42783          	lw	a5,-180(s0)
    80005c26:	2007f793          	andi	a5,a5,512
    80005c2a:	cfc5                	beqz	a5,80005ce2 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c2c:	4681                	li	a3,0
    80005c2e:	4601                	li	a2,0
    80005c30:	4589                	li	a1,2
    80005c32:	f5040513          	addi	a0,s0,-176
    80005c36:	00000097          	auipc	ra,0x0
    80005c3a:	976080e7          	jalr	-1674(ra) # 800055ac <create>
    80005c3e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005c40:	c959                	beqz	a0,80005cd6 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c42:	04449703          	lh	a4,68(s1)
    80005c46:	478d                	li	a5,3
    80005c48:	00f71763          	bne	a4,a5,80005c56 <sys_open+0x72>
    80005c4c:	0464d703          	lhu	a4,70(s1)
    80005c50:	47a5                	li	a5,9
    80005c52:	0ce7ed63          	bltu	a5,a4,80005d2c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c56:	fffff097          	auipc	ra,0xfffff
    80005c5a:	dbe080e7          	jalr	-578(ra) # 80004a14 <filealloc>
    80005c5e:	89aa                	mv	s3,a0
    80005c60:	10050363          	beqz	a0,80005d66 <sys_open+0x182>
    80005c64:	00000097          	auipc	ra,0x0
    80005c68:	906080e7          	jalr	-1786(ra) # 8000556a <fdalloc>
    80005c6c:	892a                	mv	s2,a0
    80005c6e:	0e054763          	bltz	a0,80005d5c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c72:	04449703          	lh	a4,68(s1)
    80005c76:	478d                	li	a5,3
    80005c78:	0cf70563          	beq	a4,a5,80005d42 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c7c:	4789                	li	a5,2
    80005c7e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c82:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c86:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c8a:	f4c42783          	lw	a5,-180(s0)
    80005c8e:	0017c713          	xori	a4,a5,1
    80005c92:	8b05                	andi	a4,a4,1
    80005c94:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c98:	0037f713          	andi	a4,a5,3
    80005c9c:	00e03733          	snez	a4,a4
    80005ca0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005ca4:	4007f793          	andi	a5,a5,1024
    80005ca8:	c791                	beqz	a5,80005cb4 <sys_open+0xd0>
    80005caa:	04449703          	lh	a4,68(s1)
    80005cae:	4789                	li	a5,2
    80005cb0:	0af70063          	beq	a4,a5,80005d50 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005cb4:	8526                	mv	a0,s1
    80005cb6:	ffffe097          	auipc	ra,0xffffe
    80005cba:	04e080e7          	jalr	78(ra) # 80003d04 <iunlock>
  end_op();
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	9c6080e7          	jalr	-1594(ra) # 80004684 <end_op>

  return fd;
    80005cc6:	854a                	mv	a0,s2
}
    80005cc8:	70ea                	ld	ra,184(sp)
    80005cca:	744a                	ld	s0,176(sp)
    80005ccc:	74aa                	ld	s1,168(sp)
    80005cce:	790a                	ld	s2,160(sp)
    80005cd0:	69ea                	ld	s3,152(sp)
    80005cd2:	6129                	addi	sp,sp,192
    80005cd4:	8082                	ret
      end_op();
    80005cd6:	fffff097          	auipc	ra,0xfffff
    80005cda:	9ae080e7          	jalr	-1618(ra) # 80004684 <end_op>
      return -1;
    80005cde:	557d                	li	a0,-1
    80005ce0:	b7e5                	j	80005cc8 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005ce2:	f5040513          	addi	a0,s0,-176
    80005ce6:	ffffe097          	auipc	ra,0xffffe
    80005cea:	702080e7          	jalr	1794(ra) # 800043e8 <namei>
    80005cee:	84aa                	mv	s1,a0
    80005cf0:	c905                	beqz	a0,80005d20 <sys_open+0x13c>
    ilock(ip);
    80005cf2:	ffffe097          	auipc	ra,0xffffe
    80005cf6:	f50080e7          	jalr	-176(ra) # 80003c42 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005cfa:	04449703          	lh	a4,68(s1)
    80005cfe:	4785                	li	a5,1
    80005d00:	f4f711e3          	bne	a4,a5,80005c42 <sys_open+0x5e>
    80005d04:	f4c42783          	lw	a5,-180(s0)
    80005d08:	d7b9                	beqz	a5,80005c56 <sys_open+0x72>
      iunlockput(ip);
    80005d0a:	8526                	mv	a0,s1
    80005d0c:	ffffe097          	auipc	ra,0xffffe
    80005d10:	198080e7          	jalr	408(ra) # 80003ea4 <iunlockput>
      end_op();
    80005d14:	fffff097          	auipc	ra,0xfffff
    80005d18:	970080e7          	jalr	-1680(ra) # 80004684 <end_op>
      return -1;
    80005d1c:	557d                	li	a0,-1
    80005d1e:	b76d                	j	80005cc8 <sys_open+0xe4>
      end_op();
    80005d20:	fffff097          	auipc	ra,0xfffff
    80005d24:	964080e7          	jalr	-1692(ra) # 80004684 <end_op>
      return -1;
    80005d28:	557d                	li	a0,-1
    80005d2a:	bf79                	j	80005cc8 <sys_open+0xe4>
    iunlockput(ip);
    80005d2c:	8526                	mv	a0,s1
    80005d2e:	ffffe097          	auipc	ra,0xffffe
    80005d32:	176080e7          	jalr	374(ra) # 80003ea4 <iunlockput>
    end_op();
    80005d36:	fffff097          	auipc	ra,0xfffff
    80005d3a:	94e080e7          	jalr	-1714(ra) # 80004684 <end_op>
    return -1;
    80005d3e:	557d                	li	a0,-1
    80005d40:	b761                	j	80005cc8 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d42:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d46:	04649783          	lh	a5,70(s1)
    80005d4a:	02f99223          	sh	a5,36(s3)
    80005d4e:	bf25                	j	80005c86 <sys_open+0xa2>
    itrunc(ip);
    80005d50:	8526                	mv	a0,s1
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	ffe080e7          	jalr	-2(ra) # 80003d50 <itrunc>
    80005d5a:	bfa9                	j	80005cb4 <sys_open+0xd0>
      fileclose(f);
    80005d5c:	854e                	mv	a0,s3
    80005d5e:	fffff097          	auipc	ra,0xfffff
    80005d62:	d72080e7          	jalr	-654(ra) # 80004ad0 <fileclose>
    iunlockput(ip);
    80005d66:	8526                	mv	a0,s1
    80005d68:	ffffe097          	auipc	ra,0xffffe
    80005d6c:	13c080e7          	jalr	316(ra) # 80003ea4 <iunlockput>
    end_op();
    80005d70:	fffff097          	auipc	ra,0xfffff
    80005d74:	914080e7          	jalr	-1772(ra) # 80004684 <end_op>
    return -1;
    80005d78:	557d                	li	a0,-1
    80005d7a:	b7b9                	j	80005cc8 <sys_open+0xe4>

0000000080005d7c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d7c:	7175                	addi	sp,sp,-144
    80005d7e:	e506                	sd	ra,136(sp)
    80005d80:	e122                	sd	s0,128(sp)
    80005d82:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	880080e7          	jalr	-1920(ra) # 80004604 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d8c:	08000613          	li	a2,128
    80005d90:	f7040593          	addi	a1,s0,-144
    80005d94:	4501                	li	a0,0
    80005d96:	ffffd097          	auipc	ra,0xffffd
    80005d9a:	182080e7          	jalr	386(ra) # 80002f18 <argstr>
    80005d9e:	02054963          	bltz	a0,80005dd0 <sys_mkdir+0x54>
    80005da2:	4681                	li	a3,0
    80005da4:	4601                	li	a2,0
    80005da6:	4585                	li	a1,1
    80005da8:	f7040513          	addi	a0,s0,-144
    80005dac:	00000097          	auipc	ra,0x0
    80005db0:	800080e7          	jalr	-2048(ra) # 800055ac <create>
    80005db4:	cd11                	beqz	a0,80005dd0 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005db6:	ffffe097          	auipc	ra,0xffffe
    80005dba:	0ee080e7          	jalr	238(ra) # 80003ea4 <iunlockput>
  end_op();
    80005dbe:	fffff097          	auipc	ra,0xfffff
    80005dc2:	8c6080e7          	jalr	-1850(ra) # 80004684 <end_op>
  return 0;
    80005dc6:	4501                	li	a0,0
}
    80005dc8:	60aa                	ld	ra,136(sp)
    80005dca:	640a                	ld	s0,128(sp)
    80005dcc:	6149                	addi	sp,sp,144
    80005dce:	8082                	ret
    end_op();
    80005dd0:	fffff097          	auipc	ra,0xfffff
    80005dd4:	8b4080e7          	jalr	-1868(ra) # 80004684 <end_op>
    return -1;
    80005dd8:	557d                	li	a0,-1
    80005dda:	b7fd                	j	80005dc8 <sys_mkdir+0x4c>

0000000080005ddc <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ddc:	7135                	addi	sp,sp,-160
    80005dde:	ed06                	sd	ra,152(sp)
    80005de0:	e922                	sd	s0,144(sp)
    80005de2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005de4:	fffff097          	auipc	ra,0xfffff
    80005de8:	820080e7          	jalr	-2016(ra) # 80004604 <begin_op>
  argint(1, &major);
    80005dec:	f6c40593          	addi	a1,s0,-148
    80005df0:	4505                	li	a0,1
    80005df2:	ffffd097          	auipc	ra,0xffffd
    80005df6:	0e6080e7          	jalr	230(ra) # 80002ed8 <argint>
  argint(2, &minor);
    80005dfa:	f6840593          	addi	a1,s0,-152
    80005dfe:	4509                	li	a0,2
    80005e00:	ffffd097          	auipc	ra,0xffffd
    80005e04:	0d8080e7          	jalr	216(ra) # 80002ed8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e08:	08000613          	li	a2,128
    80005e0c:	f7040593          	addi	a1,s0,-144
    80005e10:	4501                	li	a0,0
    80005e12:	ffffd097          	auipc	ra,0xffffd
    80005e16:	106080e7          	jalr	262(ra) # 80002f18 <argstr>
    80005e1a:	02054b63          	bltz	a0,80005e50 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e1e:	f6841683          	lh	a3,-152(s0)
    80005e22:	f6c41603          	lh	a2,-148(s0)
    80005e26:	458d                	li	a1,3
    80005e28:	f7040513          	addi	a0,s0,-144
    80005e2c:	fffff097          	auipc	ra,0xfffff
    80005e30:	780080e7          	jalr	1920(ra) # 800055ac <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e34:	cd11                	beqz	a0,80005e50 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e36:	ffffe097          	auipc	ra,0xffffe
    80005e3a:	06e080e7          	jalr	110(ra) # 80003ea4 <iunlockput>
  end_op();
    80005e3e:	fffff097          	auipc	ra,0xfffff
    80005e42:	846080e7          	jalr	-1978(ra) # 80004684 <end_op>
  return 0;
    80005e46:	4501                	li	a0,0
}
    80005e48:	60ea                	ld	ra,152(sp)
    80005e4a:	644a                	ld	s0,144(sp)
    80005e4c:	610d                	addi	sp,sp,160
    80005e4e:	8082                	ret
    end_op();
    80005e50:	fffff097          	auipc	ra,0xfffff
    80005e54:	834080e7          	jalr	-1996(ra) # 80004684 <end_op>
    return -1;
    80005e58:	557d                	li	a0,-1
    80005e5a:	b7fd                	j	80005e48 <sys_mknod+0x6c>

0000000080005e5c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e5c:	7135                	addi	sp,sp,-160
    80005e5e:	ed06                	sd	ra,152(sp)
    80005e60:	e922                	sd	s0,144(sp)
    80005e62:	e526                	sd	s1,136(sp)
    80005e64:	e14a                	sd	s2,128(sp)
    80005e66:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e68:	ffffc097          	auipc	ra,0xffffc
    80005e6c:	b82080e7          	jalr	-1150(ra) # 800019ea <myproc>
    80005e70:	892a                	mv	s2,a0
  
  begin_op();
    80005e72:	ffffe097          	auipc	ra,0xffffe
    80005e76:	792080e7          	jalr	1938(ra) # 80004604 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e7a:	08000613          	li	a2,128
    80005e7e:	f6040593          	addi	a1,s0,-160
    80005e82:	4501                	li	a0,0
    80005e84:	ffffd097          	auipc	ra,0xffffd
    80005e88:	094080e7          	jalr	148(ra) # 80002f18 <argstr>
    80005e8c:	04054b63          	bltz	a0,80005ee2 <sys_chdir+0x86>
    80005e90:	f6040513          	addi	a0,s0,-160
    80005e94:	ffffe097          	auipc	ra,0xffffe
    80005e98:	554080e7          	jalr	1364(ra) # 800043e8 <namei>
    80005e9c:	84aa                	mv	s1,a0
    80005e9e:	c131                	beqz	a0,80005ee2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ea0:	ffffe097          	auipc	ra,0xffffe
    80005ea4:	da2080e7          	jalr	-606(ra) # 80003c42 <ilock>
  if(ip->type != T_DIR){
    80005ea8:	04449703          	lh	a4,68(s1)
    80005eac:	4785                	li	a5,1
    80005eae:	04f71063          	bne	a4,a5,80005eee <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005eb2:	8526                	mv	a0,s1
    80005eb4:	ffffe097          	auipc	ra,0xffffe
    80005eb8:	e50080e7          	jalr	-432(ra) # 80003d04 <iunlock>
  iput(p->cwd);
    80005ebc:	15093503          	ld	a0,336(s2)
    80005ec0:	ffffe097          	auipc	ra,0xffffe
    80005ec4:	f3c080e7          	jalr	-196(ra) # 80003dfc <iput>
  end_op();
    80005ec8:	ffffe097          	auipc	ra,0xffffe
    80005ecc:	7bc080e7          	jalr	1980(ra) # 80004684 <end_op>
  p->cwd = ip;
    80005ed0:	14993823          	sd	s1,336(s2)
  return 0;
    80005ed4:	4501                	li	a0,0
}
    80005ed6:	60ea                	ld	ra,152(sp)
    80005ed8:	644a                	ld	s0,144(sp)
    80005eda:	64aa                	ld	s1,136(sp)
    80005edc:	690a                	ld	s2,128(sp)
    80005ede:	610d                	addi	sp,sp,160
    80005ee0:	8082                	ret
    end_op();
    80005ee2:	ffffe097          	auipc	ra,0xffffe
    80005ee6:	7a2080e7          	jalr	1954(ra) # 80004684 <end_op>
    return -1;
    80005eea:	557d                	li	a0,-1
    80005eec:	b7ed                	j	80005ed6 <sys_chdir+0x7a>
    iunlockput(ip);
    80005eee:	8526                	mv	a0,s1
    80005ef0:	ffffe097          	auipc	ra,0xffffe
    80005ef4:	fb4080e7          	jalr	-76(ra) # 80003ea4 <iunlockput>
    end_op();
    80005ef8:	ffffe097          	auipc	ra,0xffffe
    80005efc:	78c080e7          	jalr	1932(ra) # 80004684 <end_op>
    return -1;
    80005f00:	557d                	li	a0,-1
    80005f02:	bfd1                	j	80005ed6 <sys_chdir+0x7a>

0000000080005f04 <sys_exec>:

uint64
sys_exec(void)
{
    80005f04:	7145                	addi	sp,sp,-464
    80005f06:	e786                	sd	ra,456(sp)
    80005f08:	e3a2                	sd	s0,448(sp)
    80005f0a:	ff26                	sd	s1,440(sp)
    80005f0c:	fb4a                	sd	s2,432(sp)
    80005f0e:	f74e                	sd	s3,424(sp)
    80005f10:	f352                	sd	s4,416(sp)
    80005f12:	ef56                	sd	s5,408(sp)
    80005f14:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005f16:	e3840593          	addi	a1,s0,-456
    80005f1a:	4505                	li	a0,1
    80005f1c:	ffffd097          	auipc	ra,0xffffd
    80005f20:	fdc080e7          	jalr	-36(ra) # 80002ef8 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005f24:	08000613          	li	a2,128
    80005f28:	f4040593          	addi	a1,s0,-192
    80005f2c:	4501                	li	a0,0
    80005f2e:	ffffd097          	auipc	ra,0xffffd
    80005f32:	fea080e7          	jalr	-22(ra) # 80002f18 <argstr>
    80005f36:	87aa                	mv	a5,a0
    return -1;
    80005f38:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005f3a:	0c07c263          	bltz	a5,80005ffe <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005f3e:	10000613          	li	a2,256
    80005f42:	4581                	li	a1,0
    80005f44:	e4040513          	addi	a0,s0,-448
    80005f48:	ffffb097          	auipc	ra,0xffffb
    80005f4c:	d8a080e7          	jalr	-630(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f50:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f54:	89a6                	mv	s3,s1
    80005f56:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f58:	02000a13          	li	s4,32
    80005f5c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f60:	00391793          	slli	a5,s2,0x3
    80005f64:	e3040593          	addi	a1,s0,-464
    80005f68:	e3843503          	ld	a0,-456(s0)
    80005f6c:	953e                	add	a0,a0,a5
    80005f6e:	ffffd097          	auipc	ra,0xffffd
    80005f72:	ecc080e7          	jalr	-308(ra) # 80002e3a <fetchaddr>
    80005f76:	02054a63          	bltz	a0,80005faa <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f7a:	e3043783          	ld	a5,-464(s0)
    80005f7e:	c3b9                	beqz	a5,80005fc4 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f80:	ffffb097          	auipc	ra,0xffffb
    80005f84:	b66080e7          	jalr	-1178(ra) # 80000ae6 <kalloc>
    80005f88:	85aa                	mv	a1,a0
    80005f8a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f8e:	cd11                	beqz	a0,80005faa <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f90:	6605                	lui	a2,0x1
    80005f92:	e3043503          	ld	a0,-464(s0)
    80005f96:	ffffd097          	auipc	ra,0xffffd
    80005f9a:	ef6080e7          	jalr	-266(ra) # 80002e8c <fetchstr>
    80005f9e:	00054663          	bltz	a0,80005faa <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005fa2:	0905                	addi	s2,s2,1
    80005fa4:	09a1                	addi	s3,s3,8
    80005fa6:	fb491be3          	bne	s2,s4,80005f5c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005faa:	10048913          	addi	s2,s1,256
    80005fae:	6088                	ld	a0,0(s1)
    80005fb0:	c531                	beqz	a0,80005ffc <sys_exec+0xf8>
    kfree(argv[i]);
    80005fb2:	ffffb097          	auipc	ra,0xffffb
    80005fb6:	a38080e7          	jalr	-1480(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fba:	04a1                	addi	s1,s1,8
    80005fbc:	ff2499e3          	bne	s1,s2,80005fae <sys_exec+0xaa>
  return -1;
    80005fc0:	557d                	li	a0,-1
    80005fc2:	a835                	j	80005ffe <sys_exec+0xfa>
      argv[i] = 0;
    80005fc4:	0a8e                	slli	s5,s5,0x3
    80005fc6:	fc040793          	addi	a5,s0,-64
    80005fca:	9abe                	add	s5,s5,a5
    80005fcc:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005fd0:	e4040593          	addi	a1,s0,-448
    80005fd4:	f4040513          	addi	a0,s0,-192
    80005fd8:	fffff097          	auipc	ra,0xfffff
    80005fdc:	172080e7          	jalr	370(ra) # 8000514a <exec>
    80005fe0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fe2:	10048993          	addi	s3,s1,256
    80005fe6:	6088                	ld	a0,0(s1)
    80005fe8:	c901                	beqz	a0,80005ff8 <sys_exec+0xf4>
    kfree(argv[i]);
    80005fea:	ffffb097          	auipc	ra,0xffffb
    80005fee:	a00080e7          	jalr	-1536(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ff2:	04a1                	addi	s1,s1,8
    80005ff4:	ff3499e3          	bne	s1,s3,80005fe6 <sys_exec+0xe2>
  return ret;
    80005ff8:	854a                	mv	a0,s2
    80005ffa:	a011                	j	80005ffe <sys_exec+0xfa>
  return -1;
    80005ffc:	557d                	li	a0,-1
}
    80005ffe:	60be                	ld	ra,456(sp)
    80006000:	641e                	ld	s0,448(sp)
    80006002:	74fa                	ld	s1,440(sp)
    80006004:	795a                	ld	s2,432(sp)
    80006006:	79ba                	ld	s3,424(sp)
    80006008:	7a1a                	ld	s4,416(sp)
    8000600a:	6afa                	ld	s5,408(sp)
    8000600c:	6179                	addi	sp,sp,464
    8000600e:	8082                	ret

0000000080006010 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006010:	7139                	addi	sp,sp,-64
    80006012:	fc06                	sd	ra,56(sp)
    80006014:	f822                	sd	s0,48(sp)
    80006016:	f426                	sd	s1,40(sp)
    80006018:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000601a:	ffffc097          	auipc	ra,0xffffc
    8000601e:	9d0080e7          	jalr	-1584(ra) # 800019ea <myproc>
    80006022:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006024:	fd840593          	addi	a1,s0,-40
    80006028:	4501                	li	a0,0
    8000602a:	ffffd097          	auipc	ra,0xffffd
    8000602e:	ece080e7          	jalr	-306(ra) # 80002ef8 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006032:	fc840593          	addi	a1,s0,-56
    80006036:	fd040513          	addi	a0,s0,-48
    8000603a:	fffff097          	auipc	ra,0xfffff
    8000603e:	dc6080e7          	jalr	-570(ra) # 80004e00 <pipealloc>
    return -1;
    80006042:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006044:	0c054463          	bltz	a0,8000610c <sys_pipe+0xfc>
  fd0 = -1;
    80006048:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000604c:	fd043503          	ld	a0,-48(s0)
    80006050:	fffff097          	auipc	ra,0xfffff
    80006054:	51a080e7          	jalr	1306(ra) # 8000556a <fdalloc>
    80006058:	fca42223          	sw	a0,-60(s0)
    8000605c:	08054b63          	bltz	a0,800060f2 <sys_pipe+0xe2>
    80006060:	fc843503          	ld	a0,-56(s0)
    80006064:	fffff097          	auipc	ra,0xfffff
    80006068:	506080e7          	jalr	1286(ra) # 8000556a <fdalloc>
    8000606c:	fca42023          	sw	a0,-64(s0)
    80006070:	06054863          	bltz	a0,800060e0 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006074:	4691                	li	a3,4
    80006076:	fc440613          	addi	a2,s0,-60
    8000607a:	fd843583          	ld	a1,-40(s0)
    8000607e:	68a8                	ld	a0,80(s1)
    80006080:	ffffb097          	auipc	ra,0xffffb
    80006084:	5e8080e7          	jalr	1512(ra) # 80001668 <copyout>
    80006088:	02054063          	bltz	a0,800060a8 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000608c:	4691                	li	a3,4
    8000608e:	fc040613          	addi	a2,s0,-64
    80006092:	fd843583          	ld	a1,-40(s0)
    80006096:	0591                	addi	a1,a1,4
    80006098:	68a8                	ld	a0,80(s1)
    8000609a:	ffffb097          	auipc	ra,0xffffb
    8000609e:	5ce080e7          	jalr	1486(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800060a2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060a4:	06055463          	bgez	a0,8000610c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800060a8:	fc442783          	lw	a5,-60(s0)
    800060ac:	07e9                	addi	a5,a5,26
    800060ae:	078e                	slli	a5,a5,0x3
    800060b0:	97a6                	add	a5,a5,s1
    800060b2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800060b6:	fc042503          	lw	a0,-64(s0)
    800060ba:	0569                	addi	a0,a0,26
    800060bc:	050e                	slli	a0,a0,0x3
    800060be:	94aa                	add	s1,s1,a0
    800060c0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800060c4:	fd043503          	ld	a0,-48(s0)
    800060c8:	fffff097          	auipc	ra,0xfffff
    800060cc:	a08080e7          	jalr	-1528(ra) # 80004ad0 <fileclose>
    fileclose(wf);
    800060d0:	fc843503          	ld	a0,-56(s0)
    800060d4:	fffff097          	auipc	ra,0xfffff
    800060d8:	9fc080e7          	jalr	-1540(ra) # 80004ad0 <fileclose>
    return -1;
    800060dc:	57fd                	li	a5,-1
    800060de:	a03d                	j	8000610c <sys_pipe+0xfc>
    if(fd0 >= 0)
    800060e0:	fc442783          	lw	a5,-60(s0)
    800060e4:	0007c763          	bltz	a5,800060f2 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800060e8:	07e9                	addi	a5,a5,26
    800060ea:	078e                	slli	a5,a5,0x3
    800060ec:	94be                	add	s1,s1,a5
    800060ee:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800060f2:	fd043503          	ld	a0,-48(s0)
    800060f6:	fffff097          	auipc	ra,0xfffff
    800060fa:	9da080e7          	jalr	-1574(ra) # 80004ad0 <fileclose>
    fileclose(wf);
    800060fe:	fc843503          	ld	a0,-56(s0)
    80006102:	fffff097          	auipc	ra,0xfffff
    80006106:	9ce080e7          	jalr	-1586(ra) # 80004ad0 <fileclose>
    return -1;
    8000610a:	57fd                	li	a5,-1
}
    8000610c:	853e                	mv	a0,a5
    8000610e:	70e2                	ld	ra,56(sp)
    80006110:	7442                	ld	s0,48(sp)
    80006112:	74a2                	ld	s1,40(sp)
    80006114:	6121                	addi	sp,sp,64
    80006116:	8082                	ret
	...

0000000080006120 <kernelvec>:
    80006120:	7111                	addi	sp,sp,-256
    80006122:	e006                	sd	ra,0(sp)
    80006124:	e40a                	sd	sp,8(sp)
    80006126:	e80e                	sd	gp,16(sp)
    80006128:	ec12                	sd	tp,24(sp)
    8000612a:	f016                	sd	t0,32(sp)
    8000612c:	f41a                	sd	t1,40(sp)
    8000612e:	f81e                	sd	t2,48(sp)
    80006130:	fc22                	sd	s0,56(sp)
    80006132:	e0a6                	sd	s1,64(sp)
    80006134:	e4aa                	sd	a0,72(sp)
    80006136:	e8ae                	sd	a1,80(sp)
    80006138:	ecb2                	sd	a2,88(sp)
    8000613a:	f0b6                	sd	a3,96(sp)
    8000613c:	f4ba                	sd	a4,104(sp)
    8000613e:	f8be                	sd	a5,112(sp)
    80006140:	fcc2                	sd	a6,120(sp)
    80006142:	e146                	sd	a7,128(sp)
    80006144:	e54a                	sd	s2,136(sp)
    80006146:	e94e                	sd	s3,144(sp)
    80006148:	ed52                	sd	s4,152(sp)
    8000614a:	f156                	sd	s5,160(sp)
    8000614c:	f55a                	sd	s6,168(sp)
    8000614e:	f95e                	sd	s7,176(sp)
    80006150:	fd62                	sd	s8,184(sp)
    80006152:	e1e6                	sd	s9,192(sp)
    80006154:	e5ea                	sd	s10,200(sp)
    80006156:	e9ee                	sd	s11,208(sp)
    80006158:	edf2                	sd	t3,216(sp)
    8000615a:	f1f6                	sd	t4,224(sp)
    8000615c:	f5fa                	sd	t5,232(sp)
    8000615e:	f9fe                	sd	t6,240(sp)
    80006160:	ba7fc0ef          	jal	ra,80002d06 <kerneltrap>
    80006164:	6082                	ld	ra,0(sp)
    80006166:	6122                	ld	sp,8(sp)
    80006168:	61c2                	ld	gp,16(sp)
    8000616a:	7282                	ld	t0,32(sp)
    8000616c:	7322                	ld	t1,40(sp)
    8000616e:	73c2                	ld	t2,48(sp)
    80006170:	7462                	ld	s0,56(sp)
    80006172:	6486                	ld	s1,64(sp)
    80006174:	6526                	ld	a0,72(sp)
    80006176:	65c6                	ld	a1,80(sp)
    80006178:	6666                	ld	a2,88(sp)
    8000617a:	7686                	ld	a3,96(sp)
    8000617c:	7726                	ld	a4,104(sp)
    8000617e:	77c6                	ld	a5,112(sp)
    80006180:	7866                	ld	a6,120(sp)
    80006182:	688a                	ld	a7,128(sp)
    80006184:	692a                	ld	s2,136(sp)
    80006186:	69ca                	ld	s3,144(sp)
    80006188:	6a6a                	ld	s4,152(sp)
    8000618a:	7a8a                	ld	s5,160(sp)
    8000618c:	7b2a                	ld	s6,168(sp)
    8000618e:	7bca                	ld	s7,176(sp)
    80006190:	7c6a                	ld	s8,184(sp)
    80006192:	6c8e                	ld	s9,192(sp)
    80006194:	6d2e                	ld	s10,200(sp)
    80006196:	6dce                	ld	s11,208(sp)
    80006198:	6e6e                	ld	t3,216(sp)
    8000619a:	7e8e                	ld	t4,224(sp)
    8000619c:	7f2e                	ld	t5,232(sp)
    8000619e:	7fce                	ld	t6,240(sp)
    800061a0:	6111                	addi	sp,sp,256
    800061a2:	10200073          	sret
    800061a6:	00000013          	nop
    800061aa:	00000013          	nop
    800061ae:	0001                	nop

00000000800061b0 <timervec>:
    800061b0:	34051573          	csrrw	a0,mscratch,a0
    800061b4:	e10c                	sd	a1,0(a0)
    800061b6:	e510                	sd	a2,8(a0)
    800061b8:	e914                	sd	a3,16(a0)
    800061ba:	6d0c                	ld	a1,24(a0)
    800061bc:	7110                	ld	a2,32(a0)
    800061be:	6194                	ld	a3,0(a1)
    800061c0:	96b2                	add	a3,a3,a2
    800061c2:	e194                	sd	a3,0(a1)
    800061c4:	4589                	li	a1,2
    800061c6:	14459073          	csrw	sip,a1
    800061ca:	6914                	ld	a3,16(a0)
    800061cc:	6510                	ld	a2,8(a0)
    800061ce:	610c                	ld	a1,0(a0)
    800061d0:	34051573          	csrrw	a0,mscratch,a0
    800061d4:	30200073          	mret
	...

00000000800061da <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800061da:	1141                	addi	sp,sp,-16
    800061dc:	e422                	sd	s0,8(sp)
    800061de:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800061e0:	0c0007b7          	lui	a5,0xc000
    800061e4:	4705                	li	a4,1
    800061e6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800061e8:	c3d8                	sw	a4,4(a5)
}
    800061ea:	6422                	ld	s0,8(sp)
    800061ec:	0141                	addi	sp,sp,16
    800061ee:	8082                	ret

00000000800061f0 <plicinithart>:

void
plicinithart(void)
{
    800061f0:	1141                	addi	sp,sp,-16
    800061f2:	e406                	sd	ra,8(sp)
    800061f4:	e022                	sd	s0,0(sp)
    800061f6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061f8:	ffffb097          	auipc	ra,0xffffb
    800061fc:	7c6080e7          	jalr	1990(ra) # 800019be <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006200:	0085171b          	slliw	a4,a0,0x8
    80006204:	0c0027b7          	lui	a5,0xc002
    80006208:	97ba                	add	a5,a5,a4
    8000620a:	40200713          	li	a4,1026
    8000620e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006212:	00d5151b          	slliw	a0,a0,0xd
    80006216:	0c2017b7          	lui	a5,0xc201
    8000621a:	953e                	add	a0,a0,a5
    8000621c:	00052023          	sw	zero,0(a0)
}
    80006220:	60a2                	ld	ra,8(sp)
    80006222:	6402                	ld	s0,0(sp)
    80006224:	0141                	addi	sp,sp,16
    80006226:	8082                	ret

0000000080006228 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006228:	1141                	addi	sp,sp,-16
    8000622a:	e406                	sd	ra,8(sp)
    8000622c:	e022                	sd	s0,0(sp)
    8000622e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006230:	ffffb097          	auipc	ra,0xffffb
    80006234:	78e080e7          	jalr	1934(ra) # 800019be <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006238:	00d5179b          	slliw	a5,a0,0xd
    8000623c:	0c201537          	lui	a0,0xc201
    80006240:	953e                	add	a0,a0,a5
  return irq;
}
    80006242:	4148                	lw	a0,4(a0)
    80006244:	60a2                	ld	ra,8(sp)
    80006246:	6402                	ld	s0,0(sp)
    80006248:	0141                	addi	sp,sp,16
    8000624a:	8082                	ret

000000008000624c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000624c:	1101                	addi	sp,sp,-32
    8000624e:	ec06                	sd	ra,24(sp)
    80006250:	e822                	sd	s0,16(sp)
    80006252:	e426                	sd	s1,8(sp)
    80006254:	1000                	addi	s0,sp,32
    80006256:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006258:	ffffb097          	auipc	ra,0xffffb
    8000625c:	766080e7          	jalr	1894(ra) # 800019be <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006260:	00d5151b          	slliw	a0,a0,0xd
    80006264:	0c2017b7          	lui	a5,0xc201
    80006268:	97aa                	add	a5,a5,a0
    8000626a:	c3c4                	sw	s1,4(a5)
}
    8000626c:	60e2                	ld	ra,24(sp)
    8000626e:	6442                	ld	s0,16(sp)
    80006270:	64a2                	ld	s1,8(sp)
    80006272:	6105                	addi	sp,sp,32
    80006274:	8082                	ret

0000000080006276 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006276:	1141                	addi	sp,sp,-16
    80006278:	e406                	sd	ra,8(sp)
    8000627a:	e022                	sd	s0,0(sp)
    8000627c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000627e:	479d                	li	a5,7
    80006280:	04a7cc63          	blt	a5,a0,800062d8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006284:	0001e797          	auipc	a5,0x1e
    80006288:	7bc78793          	addi	a5,a5,1980 # 80024a40 <disk>
    8000628c:	97aa                	add	a5,a5,a0
    8000628e:	0187c783          	lbu	a5,24(a5)
    80006292:	ebb9                	bnez	a5,800062e8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006294:	00451613          	slli	a2,a0,0x4
    80006298:	0001e797          	auipc	a5,0x1e
    8000629c:	7a878793          	addi	a5,a5,1960 # 80024a40 <disk>
    800062a0:	6394                	ld	a3,0(a5)
    800062a2:	96b2                	add	a3,a3,a2
    800062a4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800062a8:	6398                	ld	a4,0(a5)
    800062aa:	9732                	add	a4,a4,a2
    800062ac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800062b0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800062b4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800062b8:	953e                	add	a0,a0,a5
    800062ba:	4785                	li	a5,1
    800062bc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800062c0:	0001e517          	auipc	a0,0x1e
    800062c4:	79850513          	addi	a0,a0,1944 # 80024a58 <disk+0x18>
    800062c8:	ffffc097          	auipc	ra,0xffffc
    800062cc:	fbc080e7          	jalr	-68(ra) # 80002284 <wakeup>
}
    800062d0:	60a2                	ld	ra,8(sp)
    800062d2:	6402                	ld	s0,0(sp)
    800062d4:	0141                	addi	sp,sp,16
    800062d6:	8082                	ret
    panic("free_desc 1");
    800062d8:	00002517          	auipc	a0,0x2
    800062dc:	49050513          	addi	a0,a0,1168 # 80008768 <syscalls+0x318>
    800062e0:	ffffa097          	auipc	ra,0xffffa
    800062e4:	25e080e7          	jalr	606(ra) # 8000053e <panic>
    panic("free_desc 2");
    800062e8:	00002517          	auipc	a0,0x2
    800062ec:	49050513          	addi	a0,a0,1168 # 80008778 <syscalls+0x328>
    800062f0:	ffffa097          	auipc	ra,0xffffa
    800062f4:	24e080e7          	jalr	590(ra) # 8000053e <panic>

00000000800062f8 <virtio_disk_init>:
{
    800062f8:	1101                	addi	sp,sp,-32
    800062fa:	ec06                	sd	ra,24(sp)
    800062fc:	e822                	sd	s0,16(sp)
    800062fe:	e426                	sd	s1,8(sp)
    80006300:	e04a                	sd	s2,0(sp)
    80006302:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006304:	00002597          	auipc	a1,0x2
    80006308:	48458593          	addi	a1,a1,1156 # 80008788 <syscalls+0x338>
    8000630c:	0001f517          	auipc	a0,0x1f
    80006310:	85c50513          	addi	a0,a0,-1956 # 80024b68 <disk+0x128>
    80006314:	ffffb097          	auipc	ra,0xffffb
    80006318:	832080e7          	jalr	-1998(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000631c:	100017b7          	lui	a5,0x10001
    80006320:	4398                	lw	a4,0(a5)
    80006322:	2701                	sext.w	a4,a4
    80006324:	747277b7          	lui	a5,0x74727
    80006328:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000632c:	14f71c63          	bne	a4,a5,80006484 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006330:	100017b7          	lui	a5,0x10001
    80006334:	43dc                	lw	a5,4(a5)
    80006336:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006338:	4709                	li	a4,2
    8000633a:	14e79563          	bne	a5,a4,80006484 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000633e:	100017b7          	lui	a5,0x10001
    80006342:	479c                	lw	a5,8(a5)
    80006344:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006346:	12e79f63          	bne	a5,a4,80006484 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000634a:	100017b7          	lui	a5,0x10001
    8000634e:	47d8                	lw	a4,12(a5)
    80006350:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006352:	554d47b7          	lui	a5,0x554d4
    80006356:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000635a:	12f71563          	bne	a4,a5,80006484 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000635e:	100017b7          	lui	a5,0x10001
    80006362:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006366:	4705                	li	a4,1
    80006368:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000636a:	470d                	li	a4,3
    8000636c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000636e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006370:	c7ffe737          	lui	a4,0xc7ffe
    80006374:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd9bdf>
    80006378:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000637a:	2701                	sext.w	a4,a4
    8000637c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000637e:	472d                	li	a4,11
    80006380:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006382:	5bbc                	lw	a5,112(a5)
    80006384:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006388:	8ba1                	andi	a5,a5,8
    8000638a:	10078563          	beqz	a5,80006494 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000638e:	100017b7          	lui	a5,0x10001
    80006392:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006396:	43fc                	lw	a5,68(a5)
    80006398:	2781                	sext.w	a5,a5
    8000639a:	10079563          	bnez	a5,800064a4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000639e:	100017b7          	lui	a5,0x10001
    800063a2:	5bdc                	lw	a5,52(a5)
    800063a4:	2781                	sext.w	a5,a5
  if(max == 0)
    800063a6:	10078763          	beqz	a5,800064b4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800063aa:	471d                	li	a4,7
    800063ac:	10f77c63          	bgeu	a4,a5,800064c4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800063b0:	ffffa097          	auipc	ra,0xffffa
    800063b4:	736080e7          	jalr	1846(ra) # 80000ae6 <kalloc>
    800063b8:	0001e497          	auipc	s1,0x1e
    800063bc:	68848493          	addi	s1,s1,1672 # 80024a40 <disk>
    800063c0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800063c2:	ffffa097          	auipc	ra,0xffffa
    800063c6:	724080e7          	jalr	1828(ra) # 80000ae6 <kalloc>
    800063ca:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800063cc:	ffffa097          	auipc	ra,0xffffa
    800063d0:	71a080e7          	jalr	1818(ra) # 80000ae6 <kalloc>
    800063d4:	87aa                	mv	a5,a0
    800063d6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800063d8:	6088                	ld	a0,0(s1)
    800063da:	cd6d                	beqz	a0,800064d4 <virtio_disk_init+0x1dc>
    800063dc:	0001e717          	auipc	a4,0x1e
    800063e0:	66c73703          	ld	a4,1644(a4) # 80024a48 <disk+0x8>
    800063e4:	cb65                	beqz	a4,800064d4 <virtio_disk_init+0x1dc>
    800063e6:	c7fd                	beqz	a5,800064d4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800063e8:	6605                	lui	a2,0x1
    800063ea:	4581                	li	a1,0
    800063ec:	ffffb097          	auipc	ra,0xffffb
    800063f0:	8e6080e7          	jalr	-1818(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800063f4:	0001e497          	auipc	s1,0x1e
    800063f8:	64c48493          	addi	s1,s1,1612 # 80024a40 <disk>
    800063fc:	6605                	lui	a2,0x1
    800063fe:	4581                	li	a1,0
    80006400:	6488                	ld	a0,8(s1)
    80006402:	ffffb097          	auipc	ra,0xffffb
    80006406:	8d0080e7          	jalr	-1840(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000640a:	6605                	lui	a2,0x1
    8000640c:	4581                	li	a1,0
    8000640e:	6888                	ld	a0,16(s1)
    80006410:	ffffb097          	auipc	ra,0xffffb
    80006414:	8c2080e7          	jalr	-1854(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006418:	100017b7          	lui	a5,0x10001
    8000641c:	4721                	li	a4,8
    8000641e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006420:	4098                	lw	a4,0(s1)
    80006422:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006426:	40d8                	lw	a4,4(s1)
    80006428:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000642c:	6498                	ld	a4,8(s1)
    8000642e:	0007069b          	sext.w	a3,a4
    80006432:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006436:	9701                	srai	a4,a4,0x20
    80006438:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000643c:	6898                	ld	a4,16(s1)
    8000643e:	0007069b          	sext.w	a3,a4
    80006442:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006446:	9701                	srai	a4,a4,0x20
    80006448:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000644c:	4705                	li	a4,1
    8000644e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006450:	00e48c23          	sb	a4,24(s1)
    80006454:	00e48ca3          	sb	a4,25(s1)
    80006458:	00e48d23          	sb	a4,26(s1)
    8000645c:	00e48da3          	sb	a4,27(s1)
    80006460:	00e48e23          	sb	a4,28(s1)
    80006464:	00e48ea3          	sb	a4,29(s1)
    80006468:	00e48f23          	sb	a4,30(s1)
    8000646c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006470:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006474:	0727a823          	sw	s2,112(a5)
}
    80006478:	60e2                	ld	ra,24(sp)
    8000647a:	6442                	ld	s0,16(sp)
    8000647c:	64a2                	ld	s1,8(sp)
    8000647e:	6902                	ld	s2,0(sp)
    80006480:	6105                	addi	sp,sp,32
    80006482:	8082                	ret
    panic("could not find virtio disk");
    80006484:	00002517          	auipc	a0,0x2
    80006488:	31450513          	addi	a0,a0,788 # 80008798 <syscalls+0x348>
    8000648c:	ffffa097          	auipc	ra,0xffffa
    80006490:	0b2080e7          	jalr	178(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006494:	00002517          	auipc	a0,0x2
    80006498:	32450513          	addi	a0,a0,804 # 800087b8 <syscalls+0x368>
    8000649c:	ffffa097          	auipc	ra,0xffffa
    800064a0:	0a2080e7          	jalr	162(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    800064a4:	00002517          	auipc	a0,0x2
    800064a8:	33450513          	addi	a0,a0,820 # 800087d8 <syscalls+0x388>
    800064ac:	ffffa097          	auipc	ra,0xffffa
    800064b0:	092080e7          	jalr	146(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800064b4:	00002517          	auipc	a0,0x2
    800064b8:	34450513          	addi	a0,a0,836 # 800087f8 <syscalls+0x3a8>
    800064bc:	ffffa097          	auipc	ra,0xffffa
    800064c0:	082080e7          	jalr	130(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    800064c4:	00002517          	auipc	a0,0x2
    800064c8:	35450513          	addi	a0,a0,852 # 80008818 <syscalls+0x3c8>
    800064cc:	ffffa097          	auipc	ra,0xffffa
    800064d0:	072080e7          	jalr	114(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    800064d4:	00002517          	auipc	a0,0x2
    800064d8:	36450513          	addi	a0,a0,868 # 80008838 <syscalls+0x3e8>
    800064dc:	ffffa097          	auipc	ra,0xffffa
    800064e0:	062080e7          	jalr	98(ra) # 8000053e <panic>

00000000800064e4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800064e4:	7119                	addi	sp,sp,-128
    800064e6:	fc86                	sd	ra,120(sp)
    800064e8:	f8a2                	sd	s0,112(sp)
    800064ea:	f4a6                	sd	s1,104(sp)
    800064ec:	f0ca                	sd	s2,96(sp)
    800064ee:	ecce                	sd	s3,88(sp)
    800064f0:	e8d2                	sd	s4,80(sp)
    800064f2:	e4d6                	sd	s5,72(sp)
    800064f4:	e0da                	sd	s6,64(sp)
    800064f6:	fc5e                	sd	s7,56(sp)
    800064f8:	f862                	sd	s8,48(sp)
    800064fa:	f466                	sd	s9,40(sp)
    800064fc:	f06a                	sd	s10,32(sp)
    800064fe:	ec6e                	sd	s11,24(sp)
    80006500:	0100                	addi	s0,sp,128
    80006502:	8aaa                	mv	s5,a0
    80006504:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006506:	00c52d03          	lw	s10,12(a0)
    8000650a:	001d1d1b          	slliw	s10,s10,0x1
    8000650e:	1d02                	slli	s10,s10,0x20
    80006510:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006514:	0001e517          	auipc	a0,0x1e
    80006518:	65450513          	addi	a0,a0,1620 # 80024b68 <disk+0x128>
    8000651c:	ffffa097          	auipc	ra,0xffffa
    80006520:	6ba080e7          	jalr	1722(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006524:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006526:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006528:	0001eb97          	auipc	s7,0x1e
    8000652c:	518b8b93          	addi	s7,s7,1304 # 80024a40 <disk>
  for(int i = 0; i < 3; i++){
    80006530:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006532:	0001ec97          	auipc	s9,0x1e
    80006536:	636c8c93          	addi	s9,s9,1590 # 80024b68 <disk+0x128>
    8000653a:	a08d                	j	8000659c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000653c:	00fb8733          	add	a4,s7,a5
    80006540:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006544:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006546:	0207c563          	bltz	a5,80006570 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000654a:	2905                	addiw	s2,s2,1
    8000654c:	0611                	addi	a2,a2,4
    8000654e:	05690c63          	beq	s2,s6,800065a6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006552:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006554:	0001e717          	auipc	a4,0x1e
    80006558:	4ec70713          	addi	a4,a4,1260 # 80024a40 <disk>
    8000655c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000655e:	01874683          	lbu	a3,24(a4)
    80006562:	fee9                	bnez	a3,8000653c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006564:	2785                	addiw	a5,a5,1
    80006566:	0705                	addi	a4,a4,1
    80006568:	fe979be3          	bne	a5,s1,8000655e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000656c:	57fd                	li	a5,-1
    8000656e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006570:	01205d63          	blez	s2,8000658a <virtio_disk_rw+0xa6>
    80006574:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006576:	000a2503          	lw	a0,0(s4)
    8000657a:	00000097          	auipc	ra,0x0
    8000657e:	cfc080e7          	jalr	-772(ra) # 80006276 <free_desc>
      for(int j = 0; j < i; j++)
    80006582:	2d85                	addiw	s11,s11,1
    80006584:	0a11                	addi	s4,s4,4
    80006586:	ffb918e3          	bne	s2,s11,80006576 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000658a:	85e6                	mv	a1,s9
    8000658c:	0001e517          	auipc	a0,0x1e
    80006590:	4cc50513          	addi	a0,a0,1228 # 80024a58 <disk+0x18>
    80006594:	ffffc097          	auipc	ra,0xffffc
    80006598:	c8c080e7          	jalr	-884(ra) # 80002220 <sleep>
  for(int i = 0; i < 3; i++){
    8000659c:	f8040a13          	addi	s4,s0,-128
{
    800065a0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800065a2:	894e                	mv	s2,s3
    800065a4:	b77d                	j	80006552 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800065a6:	f8042583          	lw	a1,-128(s0)
    800065aa:	00a58793          	addi	a5,a1,10
    800065ae:	0792                	slli	a5,a5,0x4

  if(write)
    800065b0:	0001e617          	auipc	a2,0x1e
    800065b4:	49060613          	addi	a2,a2,1168 # 80024a40 <disk>
    800065b8:	00f60733          	add	a4,a2,a5
    800065bc:	018036b3          	snez	a3,s8
    800065c0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800065c2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800065c6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800065ca:	f6078693          	addi	a3,a5,-160
    800065ce:	6218                	ld	a4,0(a2)
    800065d0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800065d2:	00878513          	addi	a0,a5,8
    800065d6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800065d8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800065da:	6208                	ld	a0,0(a2)
    800065dc:	96aa                	add	a3,a3,a0
    800065de:	4741                	li	a4,16
    800065e0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800065e2:	4705                	li	a4,1
    800065e4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800065e8:	f8442703          	lw	a4,-124(s0)
    800065ec:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800065f0:	0712                	slli	a4,a4,0x4
    800065f2:	953a                	add	a0,a0,a4
    800065f4:	058a8693          	addi	a3,s5,88
    800065f8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800065fa:	6208                	ld	a0,0(a2)
    800065fc:	972a                	add	a4,a4,a0
    800065fe:	40000693          	li	a3,1024
    80006602:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006604:	001c3c13          	seqz	s8,s8
    80006608:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000660a:	001c6c13          	ori	s8,s8,1
    8000660e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006612:	f8842603          	lw	a2,-120(s0)
    80006616:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000661a:	0001e697          	auipc	a3,0x1e
    8000661e:	42668693          	addi	a3,a3,1062 # 80024a40 <disk>
    80006622:	00258713          	addi	a4,a1,2
    80006626:	0712                	slli	a4,a4,0x4
    80006628:	9736                	add	a4,a4,a3
    8000662a:	587d                	li	a6,-1
    8000662c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006630:	0612                	slli	a2,a2,0x4
    80006632:	9532                	add	a0,a0,a2
    80006634:	f9078793          	addi	a5,a5,-112
    80006638:	97b6                	add	a5,a5,a3
    8000663a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000663c:	629c                	ld	a5,0(a3)
    8000663e:	97b2                	add	a5,a5,a2
    80006640:	4605                	li	a2,1
    80006642:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006644:	4509                	li	a0,2
    80006646:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000664a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000664e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006652:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006656:	6698                	ld	a4,8(a3)
    80006658:	00275783          	lhu	a5,2(a4)
    8000665c:	8b9d                	andi	a5,a5,7
    8000665e:	0786                	slli	a5,a5,0x1
    80006660:	97ba                	add	a5,a5,a4
    80006662:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006666:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000666a:	6698                	ld	a4,8(a3)
    8000666c:	00275783          	lhu	a5,2(a4)
    80006670:	2785                	addiw	a5,a5,1
    80006672:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006676:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000667a:	100017b7          	lui	a5,0x10001
    8000667e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006682:	004aa783          	lw	a5,4(s5)
    80006686:	02c79163          	bne	a5,a2,800066a8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000668a:	0001e917          	auipc	s2,0x1e
    8000668e:	4de90913          	addi	s2,s2,1246 # 80024b68 <disk+0x128>
  while(b->disk == 1) {
    80006692:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006694:	85ca                	mv	a1,s2
    80006696:	8556                	mv	a0,s5
    80006698:	ffffc097          	auipc	ra,0xffffc
    8000669c:	b88080e7          	jalr	-1144(ra) # 80002220 <sleep>
  while(b->disk == 1) {
    800066a0:	004aa783          	lw	a5,4(s5)
    800066a4:	fe9788e3          	beq	a5,s1,80006694 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800066a8:	f8042903          	lw	s2,-128(s0)
    800066ac:	00290793          	addi	a5,s2,2
    800066b0:	00479713          	slli	a4,a5,0x4
    800066b4:	0001e797          	auipc	a5,0x1e
    800066b8:	38c78793          	addi	a5,a5,908 # 80024a40 <disk>
    800066bc:	97ba                	add	a5,a5,a4
    800066be:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800066c2:	0001e997          	auipc	s3,0x1e
    800066c6:	37e98993          	addi	s3,s3,894 # 80024a40 <disk>
    800066ca:	00491713          	slli	a4,s2,0x4
    800066ce:	0009b783          	ld	a5,0(s3)
    800066d2:	97ba                	add	a5,a5,a4
    800066d4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800066d8:	854a                	mv	a0,s2
    800066da:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800066de:	00000097          	auipc	ra,0x0
    800066e2:	b98080e7          	jalr	-1128(ra) # 80006276 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800066e6:	8885                	andi	s1,s1,1
    800066e8:	f0ed                	bnez	s1,800066ca <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800066ea:	0001e517          	auipc	a0,0x1e
    800066ee:	47e50513          	addi	a0,a0,1150 # 80024b68 <disk+0x128>
    800066f2:	ffffa097          	auipc	ra,0xffffa
    800066f6:	598080e7          	jalr	1432(ra) # 80000c8a <release>
}
    800066fa:	70e6                	ld	ra,120(sp)
    800066fc:	7446                	ld	s0,112(sp)
    800066fe:	74a6                	ld	s1,104(sp)
    80006700:	7906                	ld	s2,96(sp)
    80006702:	69e6                	ld	s3,88(sp)
    80006704:	6a46                	ld	s4,80(sp)
    80006706:	6aa6                	ld	s5,72(sp)
    80006708:	6b06                	ld	s6,64(sp)
    8000670a:	7be2                	ld	s7,56(sp)
    8000670c:	7c42                	ld	s8,48(sp)
    8000670e:	7ca2                	ld	s9,40(sp)
    80006710:	7d02                	ld	s10,32(sp)
    80006712:	6de2                	ld	s11,24(sp)
    80006714:	6109                	addi	sp,sp,128
    80006716:	8082                	ret

0000000080006718 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006718:	1101                	addi	sp,sp,-32
    8000671a:	ec06                	sd	ra,24(sp)
    8000671c:	e822                	sd	s0,16(sp)
    8000671e:	e426                	sd	s1,8(sp)
    80006720:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006722:	0001e497          	auipc	s1,0x1e
    80006726:	31e48493          	addi	s1,s1,798 # 80024a40 <disk>
    8000672a:	0001e517          	auipc	a0,0x1e
    8000672e:	43e50513          	addi	a0,a0,1086 # 80024b68 <disk+0x128>
    80006732:	ffffa097          	auipc	ra,0xffffa
    80006736:	4a4080e7          	jalr	1188(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000673a:	10001737          	lui	a4,0x10001
    8000673e:	533c                	lw	a5,96(a4)
    80006740:	8b8d                	andi	a5,a5,3
    80006742:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006744:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006748:	689c                	ld	a5,16(s1)
    8000674a:	0204d703          	lhu	a4,32(s1)
    8000674e:	0027d783          	lhu	a5,2(a5)
    80006752:	04f70863          	beq	a4,a5,800067a2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006756:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000675a:	6898                	ld	a4,16(s1)
    8000675c:	0204d783          	lhu	a5,32(s1)
    80006760:	8b9d                	andi	a5,a5,7
    80006762:	078e                	slli	a5,a5,0x3
    80006764:	97ba                	add	a5,a5,a4
    80006766:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006768:	00278713          	addi	a4,a5,2
    8000676c:	0712                	slli	a4,a4,0x4
    8000676e:	9726                	add	a4,a4,s1
    80006770:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006774:	e721                	bnez	a4,800067bc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006776:	0789                	addi	a5,a5,2
    80006778:	0792                	slli	a5,a5,0x4
    8000677a:	97a6                	add	a5,a5,s1
    8000677c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000677e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006782:	ffffc097          	auipc	ra,0xffffc
    80006786:	b02080e7          	jalr	-1278(ra) # 80002284 <wakeup>

    disk.used_idx += 1;
    8000678a:	0204d783          	lhu	a5,32(s1)
    8000678e:	2785                	addiw	a5,a5,1
    80006790:	17c2                	slli	a5,a5,0x30
    80006792:	93c1                	srli	a5,a5,0x30
    80006794:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006798:	6898                	ld	a4,16(s1)
    8000679a:	00275703          	lhu	a4,2(a4)
    8000679e:	faf71ce3          	bne	a4,a5,80006756 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800067a2:	0001e517          	auipc	a0,0x1e
    800067a6:	3c650513          	addi	a0,a0,966 # 80024b68 <disk+0x128>
    800067aa:	ffffa097          	auipc	ra,0xffffa
    800067ae:	4e0080e7          	jalr	1248(ra) # 80000c8a <release>
}
    800067b2:	60e2                	ld	ra,24(sp)
    800067b4:	6442                	ld	s0,16(sp)
    800067b6:	64a2                	ld	s1,8(sp)
    800067b8:	6105                	addi	sp,sp,32
    800067ba:	8082                	ret
      panic("virtio_disk_intr status");
    800067bc:	00002517          	auipc	a0,0x2
    800067c0:	09450513          	addi	a0,a0,148 # 80008850 <syscalls+0x400>
    800067c4:	ffffa097          	auipc	ra,0xffffa
    800067c8:	d7a080e7          	jalr	-646(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
