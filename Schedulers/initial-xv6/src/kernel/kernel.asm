
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
    80000068:	f8c78793          	addi	a5,a5,-116 # 80005ff0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd79ff>
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
    80000130:	40a080e7          	jalr	1034(ra) # 80002536 <either_copyin>
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
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7ec080e7          	jalr	2028(ra) # 800019ac <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	1b8080e7          	jalr	440(ra) # 80002380 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	ef6080e7          	jalr	-266(ra) # 800020cc <sleep>
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
    80000216:	2ce080e7          	jalr	718(ra) # 800024e0 <either_copyout>
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
    800002f6:	29a080e7          	jalr	666(ra) # 8000258c <procdump>
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
    8000044a:	cea080e7          	jalr	-790(ra) # 80002130 <wakeup>
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
    80000478:	00025797          	auipc	a5,0x25
    8000047c:	7f078793          	addi	a5,a5,2032 # 80025c68 <devsw>
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
    80000582:	32f72923          	sw	a5,818(a4) # 800088b0 <panicked>
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
    80000802:	0b27a783          	lw	a5,178(a5) # 800088b0 <panicked>
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
    8000083a:	0827b783          	ld	a5,130(a5) # 800088b8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	08273703          	ld	a4,130(a4) # 800088c0 <uart_tx_w>
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
    8000086c:	05048493          	addi	s1,s1,80 # 800088b8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	05098993          	addi	s3,s3,80 # 800088c0 <uart_tx_w>
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
    80000896:	89e080e7          	jalr	-1890(ra) # 80002130 <wakeup>
    
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
    800008e2:	fd27a783          	lw	a5,-46(a5) # 800088b0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	fd873703          	ld	a4,-40(a4) # 800088c0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fc87b783          	ld	a5,-56(a5) # 800088b8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	21c98993          	addi	s3,s3,540 # 80010b18 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fb448493          	addi	s1,s1,-76 # 800088b8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fb490913          	addi	s2,s2,-76 # 800088c0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	7b0080e7          	jalr	1968(ra) # 800020cc <sleep>
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
    8000094a:	f6e7bd23          	sd	a4,-134(a5) # 800088c0 <uart_tx_w>
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
    800009fe:	00026797          	auipc	a5,0x26
    80000a02:	40278793          	addi	a5,a5,1026 # 80026e00 <end>
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
    80000ace:	00026517          	auipc	a0,0x26
    80000ad2:	33250513          	addi	a0,a0,818 # 80026e00 <end>
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
    80000b74:	e20080e7          	jalr	-480(ra) # 80001990 <mycpu>
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
    80000ba6:	dee080e7          	jalr	-530(ra) # 80001990 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	de2080e7          	jalr	-542(ra) # 80001990 <mycpu>
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
    80000bca:	dca080e7          	jalr	-566(ra) # 80001990 <mycpu>
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
    80000c0a:	d8a080e7          	jalr	-630(ra) # 80001990 <mycpu>
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
    80000c36:	d5e080e7          	jalr	-674(ra) # 80001990 <mycpu>
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
    80000e84:	b00080e7          	jalr	-1280(ra) # 80001980 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a4070713          	addi	a4,a4,-1472 # 800088c8 <started>
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
    80000ea0:	ae4080e7          	jalr	-1308(ra) # 80001980 <cpuid>
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
    80000ec2:	9b8080e7          	jalr	-1608(ra) # 80002876 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	16a080e7          	jalr	362(ra) # 80006030 <plicinithart>
  }

   scheduler();   
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	04c080e7          	jalr	76(ra) # 80001f1a <scheduler>
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
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	918080e7          	jalr	-1768(ra) # 8000284e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	938080e7          	jalr	-1736(ra) # 80002876 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	0d4080e7          	jalr	212(ra) # 8000601a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	0e2080e7          	jalr	226(ra) # 80006030 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	198080e7          	jalr	408(ra) # 800030ee <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	83c080e7          	jalr	-1988(ra) # 8000379a <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	7da080e7          	jalr	2010(ra) # 80004740 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	1ca080e7          	jalr	458(ra) # 80006138 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d40080e7          	jalr	-704(ra) # 80001cb6 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	94f72223          	sw	a5,-1724(a4) # 800088c8 <started>
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
    80000f9c:	9387b783          	ld	a5,-1736(a5) # 800088d0 <kernel_pagetable>
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
    80001258:	66a7be23          	sd	a0,1660(a5) # 800088d0 <kernel_pagetable>
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
    8000184c:	00013497          	auipc	s1,0x13
    80001850:	5d448493          	addi	s1,s1,1492 # 80014e20 <proc>
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
    80001866:	0001aa17          	auipc	s4,0x1a
    8000186a:	1baa0a13          	addi	s4,s4,442 # 8001ba20 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if (pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	8591                	srai	a1,a1,0x4
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
    800018a0:	1b048493          	addi	s1,s1,432
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

00000000800018cc <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	28850513          	addi	a0,a0,648 # 80010b70 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	28850513          	addi	a0,a0,648 # 80010b88 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001910:	00013497          	auipc	s1,0x13
    80001914:	51048493          	addi	s1,s1,1296 # 80014e20 <proc>
  {
    initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1
    80001930:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001932:	0001a997          	auipc	s3,0x1a
    80001936:	0ee98993          	addi	s3,s3,238 # 8001ba20 <tickslock>
    initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	8791                	srai	a5,a5,0x4
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001964:	1b048493          	addi	s1,s1,432
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
}
    8000196c:	70e2                	ld	ra,56(sp)
    8000196e:	7442                	ld	s0,48(sp)
    80001970:	74a2                	ld	s1,40(sp)
    80001972:	7902                	ld	s2,32(sp)
    80001974:	69e2                	ld	s3,24(sp)
    80001976:	6a42                	ld	s4,16(sp)
    80001978:	6aa2                	ld	s5,8(sp)
    8000197a:	6b02                	ld	s6,0(sp)
    8000197c:	6121                	addi	sp,sp,64
    8000197e:	8082                	ret

0000000080001980 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001980:	1141                	addi	sp,sp,-16
    80001982:	e422                	sd	s0,8(sp)
    80001984:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001986:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001988:	2501                	sext.w	a0,a0
    8000198a:	6422                	ld	s0,8(sp)
    8000198c:	0141                	addi	sp,sp,16
    8000198e:	8082                	ret

0000000080001990 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
    80001996:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001998:	2781                	sext.w	a5,a5
    8000199a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199c:	0000f517          	auipc	a0,0xf
    800019a0:	20450513          	addi	a0,a0,516 # 80010ba0 <cpus>
    800019a4:	953e                	add	a0,a0,a5
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	1d4080e7          	jalr	468(ra) # 80000b8a <push_off>
    800019be:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c0:	2781                	sext.w	a5,a5
    800019c2:	079e                	slli	a5,a5,0x7
    800019c4:	0000f717          	auipc	a4,0xf
    800019c8:	1ac70713          	addi	a4,a4,428 # 80010b70 <pid_lock>
    800019cc:	97ba                	add	a5,a5,a4
    800019ce:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	25a080e7          	jalr	602(ra) # 80000c2a <pop_off>
  return p;
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6105                	addi	sp,sp,32
    800019e2:	8082                	ret

00000000800019e4 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    800019e4:	1141                	addi	sp,sp,-16
    800019e6:	e406                	sd	ra,8(sp)
    800019e8:	e022                	sd	s0,0(sp)
    800019ea:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019ec:	00000097          	auipc	ra,0x0
    800019f0:	fc0080e7          	jalr	-64(ra) # 800019ac <myproc>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	296080e7          	jalr	662(ra) # 80000c8a <release>

  if (first)
    800019fc:	00007797          	auipc	a5,0x7
    80001a00:	e647a783          	lw	a5,-412(a5) # 80008860 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	e88080e7          	jalr	-376(ra) # 8000288e <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e407a523          	sw	zero,-438(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	cfa080e7          	jalr	-774(ra) # 8000371a <fsinit>
    80001a28:	bff9                	j	80001a06 <forkret+0x22>

0000000080001a2a <allocpid>:
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	e04a                	sd	s2,0(sp)
    80001a34:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a36:	0000f917          	auipc	s2,0xf
    80001a3a:	13a90913          	addi	s2,s2,314 # 80010b70 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e1c78793          	addi	a5,a5,-484 # 80008864 <nextpid>
    80001a50:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a52:	0014871b          	addiw	a4,s1,1
    80001a56:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	230080e7          	jalr	560(ra) # 80000c8a <release>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6902                	ld	s2,0(sp)
    80001a6c:	6105                	addi	sp,sp,32
    80001a6e:	8082                	ret

0000000080001a70 <proc_pagetable>:
{
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
    80001a7c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	8aa080e7          	jalr	-1878(ra) # 80001328 <uvmcreate>
    80001a86:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a88:	c121                	beqz	a0,80001ac8 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8a:	4729                	li	a4,10
    80001a8c:	00005697          	auipc	a3,0x5
    80001a90:	57468693          	addi	a3,a3,1396 # 80007000 <_trampoline>
    80001a94:	6605                	lui	a2,0x1
    80001a96:	040005b7          	lui	a1,0x4000
    80001a9a:	15fd                	addi	a1,a1,-1
    80001a9c:	05b2                	slli	a1,a1,0xc
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	600080e7          	jalr	1536(ra) # 8000109e <mappages>
    80001aa6:	02054863          	bltz	a0,80001ad6 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aaa:	4719                	li	a4,6
    80001aac:	05893683          	ld	a3,88(s2)
    80001ab0:	6605                	lui	a2,0x1
    80001ab2:	020005b7          	lui	a1,0x2000
    80001ab6:	15fd                	addi	a1,a1,-1
    80001ab8:	05b6                	slli	a1,a1,0xd
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	5e2080e7          	jalr	1506(ra) # 8000109e <mappages>
    80001ac4:	02054163          	bltz	a0,80001ae6 <proc_pagetable+0x76>
}
    80001ac8:	8526                	mv	a0,s1
    80001aca:	60e2                	ld	ra,24(sp)
    80001acc:	6442                	ld	s0,16(sp)
    80001ace:	64a2                	ld	s1,8(sp)
    80001ad0:	6902                	ld	s2,0(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad6:	4581                	li	a1,0
    80001ad8:	8526                	mv	a0,s1
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	a52080e7          	jalr	-1454(ra) # 8000152c <uvmfree>
    return 0;
    80001ae2:	4481                	li	s1,0
    80001ae4:	b7d5                	j	80001ac8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae6:	4681                	li	a3,0
    80001ae8:	4605                	li	a2,1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	8526                	mv	a0,s1
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	770080e7          	jalr	1904(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001afc:	4581                	li	a1,0
    80001afe:	8526                	mv	a0,s1
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	a2c080e7          	jalr	-1492(ra) # 8000152c <uvmfree>
    return 0;
    80001b08:	4481                	li	s1,0
    80001b0a:	bf7d                	j	80001ac8 <proc_pagetable+0x58>

0000000080001b0c <proc_freepagetable>:
{
    80001b0c:	1101                	addi	sp,sp,-32
    80001b0e:	ec06                	sd	ra,24(sp)
    80001b10:	e822                	sd	s0,16(sp)
    80001b12:	e426                	sd	s1,8(sp)
    80001b14:	e04a                	sd	s2,0(sp)
    80001b16:	1000                	addi	s0,sp,32
    80001b18:	84aa                	mv	s1,a0
    80001b1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	73c080e7          	jalr	1852(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b30:	4681                	li	a3,0
    80001b32:	4605                	li	a2,1
    80001b34:	020005b7          	lui	a1,0x2000
    80001b38:	15fd                	addi	a1,a1,-1
    80001b3a:	05b6                	slli	a1,a1,0xd
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	726080e7          	jalr	1830(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b46:	85ca                	mv	a1,s2
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00000097          	auipc	ra,0x0
    80001b4e:	9e2080e7          	jalr	-1566(ra) # 8000152c <uvmfree>
}
    80001b52:	60e2                	ld	ra,24(sp)
    80001b54:	6442                	ld	s0,16(sp)
    80001b56:	64a2                	ld	s1,8(sp)
    80001b58:	6902                	ld	s2,0(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret

0000000080001b5e <freeproc>:
{
    80001b5e:	1101                	addi	sp,sp,-32
    80001b60:	ec06                	sd	ra,24(sp)
    80001b62:	e822                	sd	s0,16(sp)
    80001b64:	e426                	sd	s1,8(sp)
    80001b66:	1000                	addi	s0,sp,32
    80001b68:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b6a:	6d28                	ld	a0,88(a0)
    80001b6c:	c509                	beqz	a0,80001b76 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	e7c080e7          	jalr	-388(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b7a:	68a8                	ld	a0,80(s1)
    80001b7c:	c511                	beqz	a0,80001b88 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7e:	64ac                	ld	a1,72(s1)
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	f8c080e7          	jalr	-116(ra) # 80001b0c <proc_freepagetable>
  p->pagetable = 0;
    80001b88:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b8c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b90:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b94:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b98:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b9c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba8:	0004ac23          	sw	zero,24(s1)
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <allocproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001bc2:	00013497          	auipc	s1,0x13
    80001bc6:	25e48493          	addi	s1,s1,606 # 80014e20 <proc>
    80001bca:	0001a917          	auipc	s2,0x1a
    80001bce:	e5690913          	addi	s2,s2,-426 # 8001ba20 <tickslock>
    acquire(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001bdc:	4c9c                	lw	a5,24(s1)
    80001bde:	cf81                	beqz	a5,80001bf6 <allocproc+0x40>
      release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	0a8080e7          	jalr	168(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001bea:	1b048493          	addi	s1,s1,432
    80001bee:	ff2492e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	a051                	j	80001c78 <allocproc+0xc2>
  p->pid = allocpid();
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	e34080e7          	jalr	-460(ra) # 80001a2a <allocpid>
    80001bfe:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c00:	4785                	li	a5,1
    80001c02:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	ee2080e7          	jalr	-286(ra) # 80000ae6 <kalloc>
    80001c0c:	892a                	mv	s2,a0
    80001c0e:	eca8                	sd	a0,88(s1)
    80001c10:	c93d                	beqz	a0,80001c86 <allocproc+0xd0>
  p->pagetable = proc_pagetable(p);
    80001c12:	8526                	mv	a0,s1
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	e5c080e7          	jalr	-420(ra) # 80001a70 <proc_pagetable>
    80001c1c:	892a                	mv	s2,a0
    80001c1e:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c20:	cd3d                	beqz	a0,80001c9e <allocproc+0xe8>
  memset(&p->context, 0, sizeof(p->context));
    80001c22:	07000613          	li	a2,112
    80001c26:	4581                	li	a1,0
    80001c28:	06048513          	addi	a0,s1,96
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	0a6080e7          	jalr	166(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c34:	00000797          	auipc	a5,0x0
    80001c38:	db078793          	addi	a5,a5,-592 # 800019e4 <forkret>
    80001c3c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c3e:	60bc                	ld	a5,64(s1)
    80001c40:	6705                	lui	a4,0x1
    80001c42:	97ba                	add	a5,a5,a4
    80001c44:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001c46:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001c4a:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001c4e:	00007797          	auipc	a5,0x7
    80001c52:	cae7a783          	lw	a5,-850(a5) # 800088fc <ticks>
    80001c56:	16f4a623          	sw	a5,364(s1)
  p->readcount = 0;
    80001c5a:	1604aa23          	sw	zero,372(s1)
  p->arrival = ticks;
    80001c5e:	2781                	sext.w	a5,a5
    80001c60:	18f4aa23          	sw	a5,404(s1)
  p->numticks = 0;
    80001c64:	1804ac23          	sw	zero,408(s1)
  p->priority=0;
    80001c68:	1804ae23          	sw	zero,412(s1)
  p->boost=0;
    80001c6c:	1a04a023          	sw	zero,416(s1)
  p->enter=ticks;
    80001c70:	1af4a223          	sw	a5,420(s1)
  p->numticks5=0;
    80001c74:	1a04a423          	sw	zero,424(s1)
}
    80001c78:	8526                	mv	a0,s1
    80001c7a:	60e2                	ld	ra,24(sp)
    80001c7c:	6442                	ld	s0,16(sp)
    80001c7e:	64a2                	ld	s1,8(sp)
    80001c80:	6902                	ld	s2,0(sp)
    80001c82:	6105                	addi	sp,sp,32
    80001c84:	8082                	ret
    freeproc(p);
    80001c86:	8526                	mv	a0,s1
    80001c88:	00000097          	auipc	ra,0x0
    80001c8c:	ed6080e7          	jalr	-298(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c90:	8526                	mv	a0,s1
    80001c92:	fffff097          	auipc	ra,0xfffff
    80001c96:	ff8080e7          	jalr	-8(ra) # 80000c8a <release>
    return 0;
    80001c9a:	84ca                	mv	s1,s2
    80001c9c:	bff1                	j	80001c78 <allocproc+0xc2>
    freeproc(p);
    80001c9e:	8526                	mv	a0,s1
    80001ca0:	00000097          	auipc	ra,0x0
    80001ca4:	ebe080e7          	jalr	-322(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001ca8:	8526                	mv	a0,s1
    80001caa:	fffff097          	auipc	ra,0xfffff
    80001cae:	fe0080e7          	jalr	-32(ra) # 80000c8a <release>
    return 0;
    80001cb2:	84ca                	mv	s1,s2
    80001cb4:	b7d1                	j	80001c78 <allocproc+0xc2>

0000000080001cb6 <userinit>:
{
    80001cb6:	1101                	addi	sp,sp,-32
    80001cb8:	ec06                	sd	ra,24(sp)
    80001cba:	e822                	sd	s0,16(sp)
    80001cbc:	e426                	sd	s1,8(sp)
    80001cbe:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cc0:	00000097          	auipc	ra,0x0
    80001cc4:	ef6080e7          	jalr	-266(ra) # 80001bb6 <allocproc>
    80001cc8:	84aa                	mv	s1,a0
  initproc = p;
    80001cca:	00007797          	auipc	a5,0x7
    80001cce:	c0a7bf23          	sd	a0,-994(a5) # 800088e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cd2:	03400613          	li	a2,52
    80001cd6:	00007597          	auipc	a1,0x7
    80001cda:	b9a58593          	addi	a1,a1,-1126 # 80008870 <initcode>
    80001cde:	6928                	ld	a0,80(a0)
    80001ce0:	fffff097          	auipc	ra,0xfffff
    80001ce4:	676080e7          	jalr	1654(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001ce8:	6785                	lui	a5,0x1
    80001cea:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001cec:	6cb8                	ld	a4,88(s1)
    80001cee:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001cf2:	6cb8                	ld	a4,88(s1)
    80001cf4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cf6:	4641                	li	a2,16
    80001cf8:	00006597          	auipc	a1,0x6
    80001cfc:	50858593          	addi	a1,a1,1288 # 80008200 <digits+0x1c0>
    80001d00:	15848513          	addi	a0,s1,344
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	118080e7          	jalr	280(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d0c:	00006517          	auipc	a0,0x6
    80001d10:	50450513          	addi	a0,a0,1284 # 80008210 <digits+0x1d0>
    80001d14:	00002097          	auipc	ra,0x2
    80001d18:	428080e7          	jalr	1064(ra) # 8000413c <namei>
    80001d1c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d20:	478d                	li	a5,3
    80001d22:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d24:	8526                	mv	a0,s1
    80001d26:	fffff097          	auipc	ra,0xfffff
    80001d2a:	f64080e7          	jalr	-156(ra) # 80000c8a <release>
}
    80001d2e:	60e2                	ld	ra,24(sp)
    80001d30:	6442                	ld	s0,16(sp)
    80001d32:	64a2                	ld	s1,8(sp)
    80001d34:	6105                	addi	sp,sp,32
    80001d36:	8082                	ret

0000000080001d38 <growproc>:
{
    80001d38:	1101                	addi	sp,sp,-32
    80001d3a:	ec06                	sd	ra,24(sp)
    80001d3c:	e822                	sd	s0,16(sp)
    80001d3e:	e426                	sd	s1,8(sp)
    80001d40:	e04a                	sd	s2,0(sp)
    80001d42:	1000                	addi	s0,sp,32
    80001d44:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d46:	00000097          	auipc	ra,0x0
    80001d4a:	c66080e7          	jalr	-922(ra) # 800019ac <myproc>
    80001d4e:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d50:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001d52:	01204c63          	bgtz	s2,80001d6a <growproc+0x32>
  else if (n < 0)
    80001d56:	02094663          	bltz	s2,80001d82 <growproc+0x4a>
  p->sz = sz;
    80001d5a:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d5c:	4501                	li	a0,0
}
    80001d5e:	60e2                	ld	ra,24(sp)
    80001d60:	6442                	ld	s0,16(sp)
    80001d62:	64a2                	ld	s1,8(sp)
    80001d64:	6902                	ld	s2,0(sp)
    80001d66:	6105                	addi	sp,sp,32
    80001d68:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001d6a:	4691                	li	a3,4
    80001d6c:	00b90633          	add	a2,s2,a1
    80001d70:	6928                	ld	a0,80(a0)
    80001d72:	fffff097          	auipc	ra,0xfffff
    80001d76:	69e080e7          	jalr	1694(ra) # 80001410 <uvmalloc>
    80001d7a:	85aa                	mv	a1,a0
    80001d7c:	fd79                	bnez	a0,80001d5a <growproc+0x22>
      return -1;
    80001d7e:	557d                	li	a0,-1
    80001d80:	bff9                	j	80001d5e <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d82:	00b90633          	add	a2,s2,a1
    80001d86:	6928                	ld	a0,80(a0)
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	640080e7          	jalr	1600(ra) # 800013c8 <uvmdealloc>
    80001d90:	85aa                	mv	a1,a0
    80001d92:	b7e1                	j	80001d5a <growproc+0x22>

0000000080001d94 <fork>:
{
    80001d94:	7139                	addi	sp,sp,-64
    80001d96:	fc06                	sd	ra,56(sp)
    80001d98:	f822                	sd	s0,48(sp)
    80001d9a:	f426                	sd	s1,40(sp)
    80001d9c:	f04a                	sd	s2,32(sp)
    80001d9e:	ec4e                	sd	s3,24(sp)
    80001da0:	e852                	sd	s4,16(sp)
    80001da2:	e456                	sd	s5,8(sp)
    80001da4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001da6:	00000097          	auipc	ra,0x0
    80001daa:	c06080e7          	jalr	-1018(ra) # 800019ac <myproc>
    80001dae:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001db0:	00000097          	auipc	ra,0x0
    80001db4:	e06080e7          	jalr	-506(ra) # 80001bb6 <allocproc>
    80001db8:	10050c63          	beqz	a0,80001ed0 <fork+0x13c>
    80001dbc:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001dbe:	048ab603          	ld	a2,72(s5)
    80001dc2:	692c                	ld	a1,80(a0)
    80001dc4:	050ab503          	ld	a0,80(s5)
    80001dc8:	fffff097          	auipc	ra,0xfffff
    80001dcc:	79c080e7          	jalr	1948(ra) # 80001564 <uvmcopy>
    80001dd0:	04054863          	bltz	a0,80001e20 <fork+0x8c>
  np->sz = p->sz;
    80001dd4:	048ab783          	ld	a5,72(s5)
    80001dd8:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ddc:	058ab683          	ld	a3,88(s5)
    80001de0:	87b6                	mv	a5,a3
    80001de2:	058a3703          	ld	a4,88(s4)
    80001de6:	12068693          	addi	a3,a3,288
    80001dea:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dee:	6788                	ld	a0,8(a5)
    80001df0:	6b8c                	ld	a1,16(a5)
    80001df2:	6f90                	ld	a2,24(a5)
    80001df4:	01073023          	sd	a6,0(a4)
    80001df8:	e708                	sd	a0,8(a4)
    80001dfa:	eb0c                	sd	a1,16(a4)
    80001dfc:	ef10                	sd	a2,24(a4)
    80001dfe:	02078793          	addi	a5,a5,32
    80001e02:	02070713          	addi	a4,a4,32
    80001e06:	fed792e3          	bne	a5,a3,80001dea <fork+0x56>
  np->trapframe->a0 = 0;
    80001e0a:	058a3783          	ld	a5,88(s4)
    80001e0e:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e12:	0d0a8493          	addi	s1,s5,208
    80001e16:	0d0a0913          	addi	s2,s4,208
    80001e1a:	150a8993          	addi	s3,s5,336
    80001e1e:	a00d                	j	80001e40 <fork+0xac>
    freeproc(np);
    80001e20:	8552                	mv	a0,s4
    80001e22:	00000097          	auipc	ra,0x0
    80001e26:	d3c080e7          	jalr	-708(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001e2a:	8552                	mv	a0,s4
    80001e2c:	fffff097          	auipc	ra,0xfffff
    80001e30:	e5e080e7          	jalr	-418(ra) # 80000c8a <release>
    return -1;
    80001e34:	597d                	li	s2,-1
    80001e36:	a059                	j	80001ebc <fork+0x128>
  for (i = 0; i < NOFILE; i++)
    80001e38:	04a1                	addi	s1,s1,8
    80001e3a:	0921                	addi	s2,s2,8
    80001e3c:	01348b63          	beq	s1,s3,80001e52 <fork+0xbe>
    if (p->ofile[i])
    80001e40:	6088                	ld	a0,0(s1)
    80001e42:	d97d                	beqz	a0,80001e38 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e44:	00003097          	auipc	ra,0x3
    80001e48:	98e080e7          	jalr	-1650(ra) # 800047d2 <filedup>
    80001e4c:	00a93023          	sd	a0,0(s2)
    80001e50:	b7e5                	j	80001e38 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e52:	150ab503          	ld	a0,336(s5)
    80001e56:	00002097          	auipc	ra,0x2
    80001e5a:	b02080e7          	jalr	-1278(ra) # 80003958 <idup>
    80001e5e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e62:	4641                	li	a2,16
    80001e64:	158a8593          	addi	a1,s5,344
    80001e68:	158a0513          	addi	a0,s4,344
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	fb0080e7          	jalr	-80(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e74:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e78:	8552                	mv	a0,s4
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	e10080e7          	jalr	-496(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e82:	0000f497          	auipc	s1,0xf
    80001e86:	d0648493          	addi	s1,s1,-762 # 80010b88 <wait_lock>
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	fffff097          	auipc	ra,0xfffff
    80001e90:	d4a080e7          	jalr	-694(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e94:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e98:	8526                	mv	a0,s1
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	df0080e7          	jalr	-528(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001ea2:	8552                	mv	a0,s4
    80001ea4:	fffff097          	auipc	ra,0xfffff
    80001ea8:	d32080e7          	jalr	-718(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001eac:	478d                	li	a5,3
    80001eae:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001eb2:	8552                	mv	a0,s4
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	dd6080e7          	jalr	-554(ra) # 80000c8a <release>
}
    80001ebc:	854a                	mv	a0,s2
    80001ebe:	70e2                	ld	ra,56(sp)
    80001ec0:	7442                	ld	s0,48(sp)
    80001ec2:	74a2                	ld	s1,40(sp)
    80001ec4:	7902                	ld	s2,32(sp)
    80001ec6:	69e2                	ld	s3,24(sp)
    80001ec8:	6a42                	ld	s4,16(sp)
    80001eca:	6aa2                	ld	s5,8(sp)
    80001ecc:	6121                	addi	sp,sp,64
    80001ece:	8082                	ret
    return -1;
    80001ed0:	597d                	li	s2,-1
    80001ed2:	b7ed                	j	80001ebc <fork+0x128>

0000000080001ed4 <minproc>:
struct proc* minproc(void){
    80001ed4:	1141                	addi	sp,sp,-16
    80001ed6:	e422                	sd	s0,8(sp)
    80001ed8:	0800                	addi	s0,sp,16
    struct proc* temp = 0; 
    80001eda:	4501                	li	a0,0
    int min = __INT_MAX__;
    80001edc:	800005b7          	lui	a1,0x80000
    80001ee0:	fff5c593          	not	a1,a1
    for(p = proc; p < &proc[NPROC]; p++){
    80001ee4:	00013797          	auipc	a5,0x13
    80001ee8:	f3c78793          	addi	a5,a5,-196 # 80014e20 <proc>
        if(p->state == RUNNABLE && p->arrival < min){
    80001eec:	460d                	li	a2,3
    for(p = proc; p < &proc[NPROC]; p++){
    80001eee:	0001a697          	auipc	a3,0x1a
    80001ef2:	b3268693          	addi	a3,a3,-1230 # 8001ba20 <tickslock>
    80001ef6:	a029                	j	80001f00 <minproc+0x2c>
    80001ef8:	1b078793          	addi	a5,a5,432
    80001efc:	00d78c63          	beq	a5,a3,80001f14 <minproc+0x40>
        if(p->state == RUNNABLE && p->arrival < min){
    80001f00:	4f98                	lw	a4,24(a5)
    80001f02:	fec71be3          	bne	a4,a2,80001ef8 <minproc+0x24>
    80001f06:	1947a703          	lw	a4,404(a5)
    80001f0a:	feb757e3          	bge	a4,a1,80001ef8 <minproc+0x24>
    80001f0e:	853e                	mv	a0,a5
            min = p->arrival;
    80001f10:	85ba                	mv	a1,a4
    80001f12:	b7dd                	j	80001ef8 <minproc+0x24>
}
    80001f14:	6422                	ld	s0,8(sp)
    80001f16:	0141                	addi	sp,sp,16
    80001f18:	8082                	ret

0000000080001f1a <scheduler>:
{
    80001f1a:	7139                	addi	sp,sp,-64
    80001f1c:	fc06                	sd	ra,56(sp)
    80001f1e:	f822                	sd	s0,48(sp)
    80001f20:	f426                	sd	s1,40(sp)
    80001f22:	f04a                	sd	s2,32(sp)
    80001f24:	ec4e                	sd	s3,24(sp)
    80001f26:	e852                	sd	s4,16(sp)
    80001f28:	e456                	sd	s5,8(sp)
    80001f2a:	e05a                	sd	s6,0(sp)
    80001f2c:	0080                	addi	s0,sp,64
    80001f2e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f30:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f32:	00779a93          	slli	s5,a5,0x7
    80001f36:	0000f717          	auipc	a4,0xf
    80001f3a:	c3a70713          	addi	a4,a4,-966 # 80010b70 <pid_lock>
    80001f3e:	9756                	add	a4,a4,s5
    80001f40:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f44:	0000f717          	auipc	a4,0xf
    80001f48:	c6470713          	addi	a4,a4,-924 # 80010ba8 <cpus+0x8>
    80001f4c:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80001f4e:	498d                	li	s3,3
        p->state = RUNNING;
    80001f50:	4b11                	li	s6,4
        c->proc = p;
    80001f52:	079e                	slli	a5,a5,0x7
    80001f54:	0000fa17          	auipc	s4,0xf
    80001f58:	c1ca0a13          	addi	s4,s4,-996 # 80010b70 <pid_lock>
    80001f5c:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001f5e:	0001a917          	auipc	s2,0x1a
    80001f62:	ac290913          	addi	s2,s2,-1342 # 8001ba20 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f66:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f6a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f6e:	10079073          	csrw	sstatus,a5
    80001f72:	00013497          	auipc	s1,0x13
    80001f76:	eae48493          	addi	s1,s1,-338 # 80014e20 <proc>
    80001f7a:	a811                	j	80001f8e <scheduler+0x74>
      release(&p->lock);
    80001f7c:	8526                	mv	a0,s1
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	d0c080e7          	jalr	-756(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f86:	1b048493          	addi	s1,s1,432
    80001f8a:	fd248ee3          	beq	s1,s2,80001f66 <scheduler+0x4c>
      acquire(&p->lock);
    80001f8e:	8526                	mv	a0,s1
    80001f90:	fffff097          	auipc	ra,0xfffff
    80001f94:	c46080e7          	jalr	-954(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE)
    80001f98:	4c9c                	lw	a5,24(s1)
    80001f9a:	ff3791e3          	bne	a5,s3,80001f7c <scheduler+0x62>
        p->state = RUNNING;
    80001f9e:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fa2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fa6:	06048593          	addi	a1,s1,96
    80001faa:	8556                	mv	a0,s5
    80001fac:	00001097          	auipc	ra,0x1
    80001fb0:	838080e7          	jalr	-1992(ra) # 800027e4 <swtch>
        c->proc = 0;
    80001fb4:	020a3823          	sd	zero,48(s4)
    80001fb8:	b7d1                	j	80001f7c <scheduler+0x62>

0000000080001fba <sched>:
{
    80001fba:	7179                	addi	sp,sp,-48
    80001fbc:	f406                	sd	ra,40(sp)
    80001fbe:	f022                	sd	s0,32(sp)
    80001fc0:	ec26                	sd	s1,24(sp)
    80001fc2:	e84a                	sd	s2,16(sp)
    80001fc4:	e44e                	sd	s3,8(sp)
    80001fc6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fc8:	00000097          	auipc	ra,0x0
    80001fcc:	9e4080e7          	jalr	-1564(ra) # 800019ac <myproc>
    80001fd0:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	b8a080e7          	jalr	-1142(ra) # 80000b5c <holding>
    80001fda:	c93d                	beqz	a0,80002050 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fdc:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001fde:	2781                	sext.w	a5,a5
    80001fe0:	079e                	slli	a5,a5,0x7
    80001fe2:	0000f717          	auipc	a4,0xf
    80001fe6:	b8e70713          	addi	a4,a4,-1138 # 80010b70 <pid_lock>
    80001fea:	97ba                	add	a5,a5,a4
    80001fec:	0a87a703          	lw	a4,168(a5)
    80001ff0:	4785                	li	a5,1
    80001ff2:	06f71763          	bne	a4,a5,80002060 <sched+0xa6>
  if (p->state == RUNNING)
    80001ff6:	4c98                	lw	a4,24(s1)
    80001ff8:	4791                	li	a5,4
    80001ffa:	06f70b63          	beq	a4,a5,80002070 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ffe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002002:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002004:	efb5                	bnez	a5,80002080 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002006:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002008:	0000f917          	auipc	s2,0xf
    8000200c:	b6890913          	addi	s2,s2,-1176 # 80010b70 <pid_lock>
    80002010:	2781                	sext.w	a5,a5
    80002012:	079e                	slli	a5,a5,0x7
    80002014:	97ca                	add	a5,a5,s2
    80002016:	0ac7a983          	lw	s3,172(a5)
    8000201a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000201c:	2781                	sext.w	a5,a5
    8000201e:	079e                	slli	a5,a5,0x7
    80002020:	0000f597          	auipc	a1,0xf
    80002024:	b8858593          	addi	a1,a1,-1144 # 80010ba8 <cpus+0x8>
    80002028:	95be                	add	a1,a1,a5
    8000202a:	06048513          	addi	a0,s1,96
    8000202e:	00000097          	auipc	ra,0x0
    80002032:	7b6080e7          	jalr	1974(ra) # 800027e4 <swtch>
    80002036:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002038:	2781                	sext.w	a5,a5
    8000203a:	079e                	slli	a5,a5,0x7
    8000203c:	97ca                	add	a5,a5,s2
    8000203e:	0b37a623          	sw	s3,172(a5)
}
    80002042:	70a2                	ld	ra,40(sp)
    80002044:	7402                	ld	s0,32(sp)
    80002046:	64e2                	ld	s1,24(sp)
    80002048:	6942                	ld	s2,16(sp)
    8000204a:	69a2                	ld	s3,8(sp)
    8000204c:	6145                	addi	sp,sp,48
    8000204e:	8082                	ret
    panic("sched p->lock");
    80002050:	00006517          	auipc	a0,0x6
    80002054:	1c850513          	addi	a0,a0,456 # 80008218 <digits+0x1d8>
    80002058:	ffffe097          	auipc	ra,0xffffe
    8000205c:	4e6080e7          	jalr	1254(ra) # 8000053e <panic>
    panic("sched locks");
    80002060:	00006517          	auipc	a0,0x6
    80002064:	1c850513          	addi	a0,a0,456 # 80008228 <digits+0x1e8>
    80002068:	ffffe097          	auipc	ra,0xffffe
    8000206c:	4d6080e7          	jalr	1238(ra) # 8000053e <panic>
    panic("sched running");
    80002070:	00006517          	auipc	a0,0x6
    80002074:	1c850513          	addi	a0,a0,456 # 80008238 <digits+0x1f8>
    80002078:	ffffe097          	auipc	ra,0xffffe
    8000207c:	4c6080e7          	jalr	1222(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002080:	00006517          	auipc	a0,0x6
    80002084:	1c850513          	addi	a0,a0,456 # 80008248 <digits+0x208>
    80002088:	ffffe097          	auipc	ra,0xffffe
    8000208c:	4b6080e7          	jalr	1206(ra) # 8000053e <panic>

0000000080002090 <yield>:
{
    80002090:	1101                	addi	sp,sp,-32
    80002092:	ec06                	sd	ra,24(sp)
    80002094:	e822                	sd	s0,16(sp)
    80002096:	e426                	sd	s1,8(sp)
    80002098:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000209a:	00000097          	auipc	ra,0x0
    8000209e:	912080e7          	jalr	-1774(ra) # 800019ac <myproc>
    800020a2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	b32080e7          	jalr	-1230(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800020ac:	478d                	li	a5,3
    800020ae:	cc9c                	sw	a5,24(s1)
  sched();
    800020b0:	00000097          	auipc	ra,0x0
    800020b4:	f0a080e7          	jalr	-246(ra) # 80001fba <sched>
  release(&p->lock);
    800020b8:	8526                	mv	a0,s1
    800020ba:	fffff097          	auipc	ra,0xfffff
    800020be:	bd0080e7          	jalr	-1072(ra) # 80000c8a <release>
}
    800020c2:	60e2                	ld	ra,24(sp)
    800020c4:	6442                	ld	s0,16(sp)
    800020c6:	64a2                	ld	s1,8(sp)
    800020c8:	6105                	addi	sp,sp,32
    800020ca:	8082                	ret

00000000800020cc <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800020cc:	7179                	addi	sp,sp,-48
    800020ce:	f406                	sd	ra,40(sp)
    800020d0:	f022                	sd	s0,32(sp)
    800020d2:	ec26                	sd	s1,24(sp)
    800020d4:	e84a                	sd	s2,16(sp)
    800020d6:	e44e                	sd	s3,8(sp)
    800020d8:	1800                	addi	s0,sp,48
    800020da:	89aa                	mv	s3,a0
    800020dc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020de:	00000097          	auipc	ra,0x0
    800020e2:	8ce080e7          	jalr	-1842(ra) # 800019ac <myproc>
    800020e6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	aee080e7          	jalr	-1298(ra) # 80000bd6 <acquire>
  release(lk);
    800020f0:	854a                	mv	a0,s2
    800020f2:	fffff097          	auipc	ra,0xfffff
    800020f6:	b98080e7          	jalr	-1128(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800020fa:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020fe:	4789                	li	a5,2
    80002100:	cc9c                	sw	a5,24(s1)

  sched();
    80002102:	00000097          	auipc	ra,0x0
    80002106:	eb8080e7          	jalr	-328(ra) # 80001fba <sched>

  // Tidy up.
  p->chan = 0;
    8000210a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000210e:	8526                	mv	a0,s1
    80002110:	fffff097          	auipc	ra,0xfffff
    80002114:	b7a080e7          	jalr	-1158(ra) # 80000c8a <release>
  acquire(lk);
    80002118:	854a                	mv	a0,s2
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	abc080e7          	jalr	-1348(ra) # 80000bd6 <acquire>
}
    80002122:	70a2                	ld	ra,40(sp)
    80002124:	7402                	ld	s0,32(sp)
    80002126:	64e2                	ld	s1,24(sp)
    80002128:	6942                	ld	s2,16(sp)
    8000212a:	69a2                	ld	s3,8(sp)
    8000212c:	6145                	addi	sp,sp,48
    8000212e:	8082                	ret

0000000080002130 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002130:	7139                	addi	sp,sp,-64
    80002132:	fc06                	sd	ra,56(sp)
    80002134:	f822                	sd	s0,48(sp)
    80002136:	f426                	sd	s1,40(sp)
    80002138:	f04a                	sd	s2,32(sp)
    8000213a:	ec4e                	sd	s3,24(sp)
    8000213c:	e852                	sd	s4,16(sp)
    8000213e:	e456                	sd	s5,8(sp)
    80002140:	0080                	addi	s0,sp,64
    80002142:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002144:	00013497          	auipc	s1,0x13
    80002148:	cdc48493          	addi	s1,s1,-804 # 80014e20 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    8000214c:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    8000214e:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002150:	0001a917          	auipc	s2,0x1a
    80002154:	8d090913          	addi	s2,s2,-1840 # 8001ba20 <tickslock>
    80002158:	a811                	j	8000216c <wakeup+0x3c>
      }
      release(&p->lock);
    8000215a:	8526                	mv	a0,s1
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	b2e080e7          	jalr	-1234(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002164:	1b048493          	addi	s1,s1,432
    80002168:	03248663          	beq	s1,s2,80002194 <wakeup+0x64>
    if (p != myproc())
    8000216c:	00000097          	auipc	ra,0x0
    80002170:	840080e7          	jalr	-1984(ra) # 800019ac <myproc>
    80002174:	fea488e3          	beq	s1,a0,80002164 <wakeup+0x34>
      acquire(&p->lock);
    80002178:	8526                	mv	a0,s1
    8000217a:	fffff097          	auipc	ra,0xfffff
    8000217e:	a5c080e7          	jalr	-1444(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002182:	4c9c                	lw	a5,24(s1)
    80002184:	fd379be3          	bne	a5,s3,8000215a <wakeup+0x2a>
    80002188:	709c                	ld	a5,32(s1)
    8000218a:	fd4798e3          	bne	a5,s4,8000215a <wakeup+0x2a>
        p->state = RUNNABLE;
    8000218e:	0154ac23          	sw	s5,24(s1)
    80002192:	b7e1                	j	8000215a <wakeup+0x2a>
    }
  }
}
    80002194:	70e2                	ld	ra,56(sp)
    80002196:	7442                	ld	s0,48(sp)
    80002198:	74a2                	ld	s1,40(sp)
    8000219a:	7902                	ld	s2,32(sp)
    8000219c:	69e2                	ld	s3,24(sp)
    8000219e:	6a42                	ld	s4,16(sp)
    800021a0:	6aa2                	ld	s5,8(sp)
    800021a2:	6121                	addi	sp,sp,64
    800021a4:	8082                	ret

00000000800021a6 <reparent>:
{
    800021a6:	7179                	addi	sp,sp,-48
    800021a8:	f406                	sd	ra,40(sp)
    800021aa:	f022                	sd	s0,32(sp)
    800021ac:	ec26                	sd	s1,24(sp)
    800021ae:	e84a                	sd	s2,16(sp)
    800021b0:	e44e                	sd	s3,8(sp)
    800021b2:	e052                	sd	s4,0(sp)
    800021b4:	1800                	addi	s0,sp,48
    800021b6:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800021b8:	00013497          	auipc	s1,0x13
    800021bc:	c6848493          	addi	s1,s1,-920 # 80014e20 <proc>
      pp->parent = initproc;
    800021c0:	00006a17          	auipc	s4,0x6
    800021c4:	728a0a13          	addi	s4,s4,1832 # 800088e8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800021c8:	0001a997          	auipc	s3,0x1a
    800021cc:	85898993          	addi	s3,s3,-1960 # 8001ba20 <tickslock>
    800021d0:	a029                	j	800021da <reparent+0x34>
    800021d2:	1b048493          	addi	s1,s1,432
    800021d6:	01348d63          	beq	s1,s3,800021f0 <reparent+0x4a>
    if (pp->parent == p)
    800021da:	7c9c                	ld	a5,56(s1)
    800021dc:	ff279be3          	bne	a5,s2,800021d2 <reparent+0x2c>
      pp->parent = initproc;
    800021e0:	000a3503          	ld	a0,0(s4)
    800021e4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021e6:	00000097          	auipc	ra,0x0
    800021ea:	f4a080e7          	jalr	-182(ra) # 80002130 <wakeup>
    800021ee:	b7d5                	j	800021d2 <reparent+0x2c>
}
    800021f0:	70a2                	ld	ra,40(sp)
    800021f2:	7402                	ld	s0,32(sp)
    800021f4:	64e2                	ld	s1,24(sp)
    800021f6:	6942                	ld	s2,16(sp)
    800021f8:	69a2                	ld	s3,8(sp)
    800021fa:	6a02                	ld	s4,0(sp)
    800021fc:	6145                	addi	sp,sp,48
    800021fe:	8082                	ret

0000000080002200 <exit>:
{
    80002200:	7179                	addi	sp,sp,-48
    80002202:	f406                	sd	ra,40(sp)
    80002204:	f022                	sd	s0,32(sp)
    80002206:	ec26                	sd	s1,24(sp)
    80002208:	e84a                	sd	s2,16(sp)
    8000220a:	e44e                	sd	s3,8(sp)
    8000220c:	e052                	sd	s4,0(sp)
    8000220e:	1800                	addi	s0,sp,48
    80002210:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	79a080e7          	jalr	1946(ra) # 800019ac <myproc>
    8000221a:	89aa                	mv	s3,a0
  if (p == initproc)
    8000221c:	00006797          	auipc	a5,0x6
    80002220:	6cc7b783          	ld	a5,1740(a5) # 800088e8 <initproc>
    80002224:	0d050493          	addi	s1,a0,208
    80002228:	15050913          	addi	s2,a0,336
    8000222c:	02a79363          	bne	a5,a0,80002252 <exit+0x52>
    panic("init exiting");
    80002230:	00006517          	auipc	a0,0x6
    80002234:	03050513          	addi	a0,a0,48 # 80008260 <digits+0x220>
    80002238:	ffffe097          	auipc	ra,0xffffe
    8000223c:	306080e7          	jalr	774(ra) # 8000053e <panic>
      fileclose(f);
    80002240:	00002097          	auipc	ra,0x2
    80002244:	5e4080e7          	jalr	1508(ra) # 80004824 <fileclose>
      p->ofile[fd] = 0;
    80002248:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    8000224c:	04a1                	addi	s1,s1,8
    8000224e:	01248563          	beq	s1,s2,80002258 <exit+0x58>
    if (p->ofile[fd])
    80002252:	6088                	ld	a0,0(s1)
    80002254:	f575                	bnez	a0,80002240 <exit+0x40>
    80002256:	bfdd                	j	8000224c <exit+0x4c>
  begin_op();
    80002258:	00002097          	auipc	ra,0x2
    8000225c:	100080e7          	jalr	256(ra) # 80004358 <begin_op>
  iput(p->cwd);
    80002260:	1509b503          	ld	a0,336(s3)
    80002264:	00002097          	auipc	ra,0x2
    80002268:	8ec080e7          	jalr	-1812(ra) # 80003b50 <iput>
  end_op();
    8000226c:	00002097          	auipc	ra,0x2
    80002270:	16c080e7          	jalr	364(ra) # 800043d8 <end_op>
  p->cwd = 0;
    80002274:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002278:	0000f497          	auipc	s1,0xf
    8000227c:	91048493          	addi	s1,s1,-1776 # 80010b88 <wait_lock>
    80002280:	8526                	mv	a0,s1
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	954080e7          	jalr	-1708(ra) # 80000bd6 <acquire>
  reparent(p);
    8000228a:	854e                	mv	a0,s3
    8000228c:	00000097          	auipc	ra,0x0
    80002290:	f1a080e7          	jalr	-230(ra) # 800021a6 <reparent>
  wakeup(p->parent);
    80002294:	0389b503          	ld	a0,56(s3)
    80002298:	00000097          	auipc	ra,0x0
    8000229c:	e98080e7          	jalr	-360(ra) # 80002130 <wakeup>
  acquire(&p->lock);
    800022a0:	854e                	mv	a0,s3
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	934080e7          	jalr	-1740(ra) # 80000bd6 <acquire>
  p->xstate = status;
    800022aa:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022ae:	4795                	li	a5,5
    800022b0:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    800022b4:	00006797          	auipc	a5,0x6
    800022b8:	6487a783          	lw	a5,1608(a5) # 800088fc <ticks>
    800022bc:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    800022c0:	8526                	mv	a0,s1
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	9c8080e7          	jalr	-1592(ra) # 80000c8a <release>
  sched();
    800022ca:	00000097          	auipc	ra,0x0
    800022ce:	cf0080e7          	jalr	-784(ra) # 80001fba <sched>
  panic("zombie exit");
    800022d2:	00006517          	auipc	a0,0x6
    800022d6:	f9e50513          	addi	a0,a0,-98 # 80008270 <digits+0x230>
    800022da:	ffffe097          	auipc	ra,0xffffe
    800022de:	264080e7          	jalr	612(ra) # 8000053e <panic>

00000000800022e2 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800022e2:	7179                	addi	sp,sp,-48
    800022e4:	f406                	sd	ra,40(sp)
    800022e6:	f022                	sd	s0,32(sp)
    800022e8:	ec26                	sd	s1,24(sp)
    800022ea:	e84a                	sd	s2,16(sp)
    800022ec:	e44e                	sd	s3,8(sp)
    800022ee:	1800                	addi	s0,sp,48
    800022f0:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800022f2:	00013497          	auipc	s1,0x13
    800022f6:	b2e48493          	addi	s1,s1,-1234 # 80014e20 <proc>
    800022fa:	00019997          	auipc	s3,0x19
    800022fe:	72698993          	addi	s3,s3,1830 # 8001ba20 <tickslock>
  {
    acquire(&p->lock);
    80002302:	8526                	mv	a0,s1
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	8d2080e7          	jalr	-1838(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    8000230c:	589c                	lw	a5,48(s1)
    8000230e:	01278d63          	beq	a5,s2,80002328 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002312:	8526                	mv	a0,s1
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	976080e7          	jalr	-1674(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000231c:	1b048493          	addi	s1,s1,432
    80002320:	ff3491e3          	bne	s1,s3,80002302 <kill+0x20>
  }
  return -1;
    80002324:	557d                	li	a0,-1
    80002326:	a829                	j	80002340 <kill+0x5e>
      p->killed = 1;
    80002328:	4785                	li	a5,1
    8000232a:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    8000232c:	4c98                	lw	a4,24(s1)
    8000232e:	4789                	li	a5,2
    80002330:	00f70f63          	beq	a4,a5,8000234e <kill+0x6c>
      release(&p->lock);
    80002334:	8526                	mv	a0,s1
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	954080e7          	jalr	-1708(ra) # 80000c8a <release>
      return 0;
    8000233e:	4501                	li	a0,0
}
    80002340:	70a2                	ld	ra,40(sp)
    80002342:	7402                	ld	s0,32(sp)
    80002344:	64e2                	ld	s1,24(sp)
    80002346:	6942                	ld	s2,16(sp)
    80002348:	69a2                	ld	s3,8(sp)
    8000234a:	6145                	addi	sp,sp,48
    8000234c:	8082                	ret
        p->state = RUNNABLE;
    8000234e:	478d                	li	a5,3
    80002350:	cc9c                	sw	a5,24(s1)
    80002352:	b7cd                	j	80002334 <kill+0x52>

0000000080002354 <setkilled>:

void setkilled(struct proc *p)
{
    80002354:	1101                	addi	sp,sp,-32
    80002356:	ec06                	sd	ra,24(sp)
    80002358:	e822                	sd	s0,16(sp)
    8000235a:	e426                	sd	s1,8(sp)
    8000235c:	1000                	addi	s0,sp,32
    8000235e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	876080e7          	jalr	-1930(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002368:	4785                	li	a5,1
    8000236a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000236c:	8526                	mv	a0,s1
    8000236e:	fffff097          	auipc	ra,0xfffff
    80002372:	91c080e7          	jalr	-1764(ra) # 80000c8a <release>
}
    80002376:	60e2                	ld	ra,24(sp)
    80002378:	6442                	ld	s0,16(sp)
    8000237a:	64a2                	ld	s1,8(sp)
    8000237c:	6105                	addi	sp,sp,32
    8000237e:	8082                	ret

0000000080002380 <killed>:

int killed(struct proc *p)
{
    80002380:	1101                	addi	sp,sp,-32
    80002382:	ec06                	sd	ra,24(sp)
    80002384:	e822                	sd	s0,16(sp)
    80002386:	e426                	sd	s1,8(sp)
    80002388:	e04a                	sd	s2,0(sp)
    8000238a:	1000                	addi	s0,sp,32
    8000238c:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	848080e7          	jalr	-1976(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002396:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000239a:	8526                	mv	a0,s1
    8000239c:	fffff097          	auipc	ra,0xfffff
    800023a0:	8ee080e7          	jalr	-1810(ra) # 80000c8a <release>
  return k;
}
    800023a4:	854a                	mv	a0,s2
    800023a6:	60e2                	ld	ra,24(sp)
    800023a8:	6442                	ld	s0,16(sp)
    800023aa:	64a2                	ld	s1,8(sp)
    800023ac:	6902                	ld	s2,0(sp)
    800023ae:	6105                	addi	sp,sp,32
    800023b0:	8082                	ret

00000000800023b2 <wait>:
{
    800023b2:	715d                	addi	sp,sp,-80
    800023b4:	e486                	sd	ra,72(sp)
    800023b6:	e0a2                	sd	s0,64(sp)
    800023b8:	fc26                	sd	s1,56(sp)
    800023ba:	f84a                	sd	s2,48(sp)
    800023bc:	f44e                	sd	s3,40(sp)
    800023be:	f052                	sd	s4,32(sp)
    800023c0:	ec56                	sd	s5,24(sp)
    800023c2:	e85a                	sd	s6,16(sp)
    800023c4:	e45e                	sd	s7,8(sp)
    800023c6:	e062                	sd	s8,0(sp)
    800023c8:	0880                	addi	s0,sp,80
    800023ca:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	5e0080e7          	jalr	1504(ra) # 800019ac <myproc>
    800023d4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023d6:	0000e517          	auipc	a0,0xe
    800023da:	7b250513          	addi	a0,a0,1970 # 80010b88 <wait_lock>
    800023de:	ffffe097          	auipc	ra,0xffffe
    800023e2:	7f8080e7          	jalr	2040(ra) # 80000bd6 <acquire>
    havekids = 0;
    800023e6:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    800023e8:	4a15                	li	s4,5
        havekids = 1;
    800023ea:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800023ec:	00019997          	auipc	s3,0x19
    800023f0:	63498993          	addi	s3,s3,1588 # 8001ba20 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800023f4:	0000ec17          	auipc	s8,0xe
    800023f8:	794c0c13          	addi	s8,s8,1940 # 80010b88 <wait_lock>
    havekids = 0;
    800023fc:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800023fe:	00013497          	auipc	s1,0x13
    80002402:	a2248493          	addi	s1,s1,-1502 # 80014e20 <proc>
    80002406:	a0bd                	j	80002474 <wait+0xc2>
          pid = pp->pid;
    80002408:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000240c:	000b0e63          	beqz	s6,80002428 <wait+0x76>
    80002410:	4691                	li	a3,4
    80002412:	02c48613          	addi	a2,s1,44
    80002416:	85da                	mv	a1,s6
    80002418:	05093503          	ld	a0,80(s2)
    8000241c:	fffff097          	auipc	ra,0xfffff
    80002420:	24c080e7          	jalr	588(ra) # 80001668 <copyout>
    80002424:	02054563          	bltz	a0,8000244e <wait+0x9c>
          freeproc(pp);
    80002428:	8526                	mv	a0,s1
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	734080e7          	jalr	1844(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    80002432:	8526                	mv	a0,s1
    80002434:	fffff097          	auipc	ra,0xfffff
    80002438:	856080e7          	jalr	-1962(ra) # 80000c8a <release>
          release(&wait_lock);
    8000243c:	0000e517          	auipc	a0,0xe
    80002440:	74c50513          	addi	a0,a0,1868 # 80010b88 <wait_lock>
    80002444:	fffff097          	auipc	ra,0xfffff
    80002448:	846080e7          	jalr	-1978(ra) # 80000c8a <release>
          return pid;
    8000244c:	a0b5                	j	800024b8 <wait+0x106>
            release(&pp->lock);
    8000244e:	8526                	mv	a0,s1
    80002450:	fffff097          	auipc	ra,0xfffff
    80002454:	83a080e7          	jalr	-1990(ra) # 80000c8a <release>
            release(&wait_lock);
    80002458:	0000e517          	auipc	a0,0xe
    8000245c:	73050513          	addi	a0,a0,1840 # 80010b88 <wait_lock>
    80002460:	fffff097          	auipc	ra,0xfffff
    80002464:	82a080e7          	jalr	-2006(ra) # 80000c8a <release>
            return -1;
    80002468:	59fd                	li	s3,-1
    8000246a:	a0b9                	j	800024b8 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000246c:	1b048493          	addi	s1,s1,432
    80002470:	03348463          	beq	s1,s3,80002498 <wait+0xe6>
      if (pp->parent == p)
    80002474:	7c9c                	ld	a5,56(s1)
    80002476:	ff279be3          	bne	a5,s2,8000246c <wait+0xba>
        acquire(&pp->lock);
    8000247a:	8526                	mv	a0,s1
    8000247c:	ffffe097          	auipc	ra,0xffffe
    80002480:	75a080e7          	jalr	1882(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    80002484:	4c9c                	lw	a5,24(s1)
    80002486:	f94781e3          	beq	a5,s4,80002408 <wait+0x56>
        release(&pp->lock);
    8000248a:	8526                	mv	a0,s1
    8000248c:	ffffe097          	auipc	ra,0xffffe
    80002490:	7fe080e7          	jalr	2046(ra) # 80000c8a <release>
        havekids = 1;
    80002494:	8756                	mv	a4,s5
    80002496:	bfd9                	j	8000246c <wait+0xba>
    if (!havekids || killed(p))
    80002498:	c719                	beqz	a4,800024a6 <wait+0xf4>
    8000249a:	854a                	mv	a0,s2
    8000249c:	00000097          	auipc	ra,0x0
    800024a0:	ee4080e7          	jalr	-284(ra) # 80002380 <killed>
    800024a4:	c51d                	beqz	a0,800024d2 <wait+0x120>
      release(&wait_lock);
    800024a6:	0000e517          	auipc	a0,0xe
    800024aa:	6e250513          	addi	a0,a0,1762 # 80010b88 <wait_lock>
    800024ae:	ffffe097          	auipc	ra,0xffffe
    800024b2:	7dc080e7          	jalr	2012(ra) # 80000c8a <release>
      return -1;
    800024b6:	59fd                	li	s3,-1
}
    800024b8:	854e                	mv	a0,s3
    800024ba:	60a6                	ld	ra,72(sp)
    800024bc:	6406                	ld	s0,64(sp)
    800024be:	74e2                	ld	s1,56(sp)
    800024c0:	7942                	ld	s2,48(sp)
    800024c2:	79a2                	ld	s3,40(sp)
    800024c4:	7a02                	ld	s4,32(sp)
    800024c6:	6ae2                	ld	s5,24(sp)
    800024c8:	6b42                	ld	s6,16(sp)
    800024ca:	6ba2                	ld	s7,8(sp)
    800024cc:	6c02                	ld	s8,0(sp)
    800024ce:	6161                	addi	sp,sp,80
    800024d0:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024d2:	85e2                	mv	a1,s8
    800024d4:	854a                	mv	a0,s2
    800024d6:	00000097          	auipc	ra,0x0
    800024da:	bf6080e7          	jalr	-1034(ra) # 800020cc <sleep>
    havekids = 0;
    800024de:	bf39                	j	800023fc <wait+0x4a>

00000000800024e0 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024e0:	7179                	addi	sp,sp,-48
    800024e2:	f406                	sd	ra,40(sp)
    800024e4:	f022                	sd	s0,32(sp)
    800024e6:	ec26                	sd	s1,24(sp)
    800024e8:	e84a                	sd	s2,16(sp)
    800024ea:	e44e                	sd	s3,8(sp)
    800024ec:	e052                	sd	s4,0(sp)
    800024ee:	1800                	addi	s0,sp,48
    800024f0:	84aa                	mv	s1,a0
    800024f2:	892e                	mv	s2,a1
    800024f4:	89b2                	mv	s3,a2
    800024f6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024f8:	fffff097          	auipc	ra,0xfffff
    800024fc:	4b4080e7          	jalr	1204(ra) # 800019ac <myproc>
  if (user_dst)
    80002500:	c08d                	beqz	s1,80002522 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    80002502:	86d2                	mv	a3,s4
    80002504:	864e                	mv	a2,s3
    80002506:	85ca                	mv	a1,s2
    80002508:	6928                	ld	a0,80(a0)
    8000250a:	fffff097          	auipc	ra,0xfffff
    8000250e:	15e080e7          	jalr	350(ra) # 80001668 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002512:	70a2                	ld	ra,40(sp)
    80002514:	7402                	ld	s0,32(sp)
    80002516:	64e2                	ld	s1,24(sp)
    80002518:	6942                	ld	s2,16(sp)
    8000251a:	69a2                	ld	s3,8(sp)
    8000251c:	6a02                	ld	s4,0(sp)
    8000251e:	6145                	addi	sp,sp,48
    80002520:	8082                	ret
    memmove((char *)dst, src, len);
    80002522:	000a061b          	sext.w	a2,s4
    80002526:	85ce                	mv	a1,s3
    80002528:	854a                	mv	a0,s2
    8000252a:	fffff097          	auipc	ra,0xfffff
    8000252e:	804080e7          	jalr	-2044(ra) # 80000d2e <memmove>
    return 0;
    80002532:	8526                	mv	a0,s1
    80002534:	bff9                	j	80002512 <either_copyout+0x32>

0000000080002536 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002536:	7179                	addi	sp,sp,-48
    80002538:	f406                	sd	ra,40(sp)
    8000253a:	f022                	sd	s0,32(sp)
    8000253c:	ec26                	sd	s1,24(sp)
    8000253e:	e84a                	sd	s2,16(sp)
    80002540:	e44e                	sd	s3,8(sp)
    80002542:	e052                	sd	s4,0(sp)
    80002544:	1800                	addi	s0,sp,48
    80002546:	892a                	mv	s2,a0
    80002548:	84ae                	mv	s1,a1
    8000254a:	89b2                	mv	s3,a2
    8000254c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000254e:	fffff097          	auipc	ra,0xfffff
    80002552:	45e080e7          	jalr	1118(ra) # 800019ac <myproc>
  if (user_src)
    80002556:	c08d                	beqz	s1,80002578 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002558:	86d2                	mv	a3,s4
    8000255a:	864e                	mv	a2,s3
    8000255c:	85ca                	mv	a1,s2
    8000255e:	6928                	ld	a0,80(a0)
    80002560:	fffff097          	auipc	ra,0xfffff
    80002564:	194080e7          	jalr	404(ra) # 800016f4 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002568:	70a2                	ld	ra,40(sp)
    8000256a:	7402                	ld	s0,32(sp)
    8000256c:	64e2                	ld	s1,24(sp)
    8000256e:	6942                	ld	s2,16(sp)
    80002570:	69a2                	ld	s3,8(sp)
    80002572:	6a02                	ld	s4,0(sp)
    80002574:	6145                	addi	sp,sp,48
    80002576:	8082                	ret
    memmove(dst, (char *)src, len);
    80002578:	000a061b          	sext.w	a2,s4
    8000257c:	85ce                	mv	a1,s3
    8000257e:	854a                	mv	a0,s2
    80002580:	ffffe097          	auipc	ra,0xffffe
    80002584:	7ae080e7          	jalr	1966(ra) # 80000d2e <memmove>
    return 0;
    80002588:	8526                	mv	a0,s1
    8000258a:	bff9                	j	80002568 <either_copyin+0x32>

000000008000258c <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    8000258c:	715d                	addi	sp,sp,-80
    8000258e:	e486                	sd	ra,72(sp)
    80002590:	e0a2                	sd	s0,64(sp)
    80002592:	fc26                	sd	s1,56(sp)
    80002594:	f84a                	sd	s2,48(sp)
    80002596:	f44e                	sd	s3,40(sp)
    80002598:	f052                	sd	s4,32(sp)
    8000259a:	ec56                	sd	s5,24(sp)
    8000259c:	e85a                	sd	s6,16(sp)
    8000259e:	e45e                	sd	s7,8(sp)
    800025a0:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800025a2:	00006517          	auipc	a0,0x6
    800025a6:	b2650513          	addi	a0,a0,-1242 # 800080c8 <digits+0x88>
    800025aa:	ffffe097          	auipc	ra,0xffffe
    800025ae:	fde080e7          	jalr	-34(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800025b2:	00013497          	auipc	s1,0x13
    800025b6:	9c648493          	addi	s1,s1,-1594 # 80014f78 <proc+0x158>
    800025ba:	00019917          	auipc	s2,0x19
    800025be:	5be90913          	addi	s2,s2,1470 # 8001bb78 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025c2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025c4:	00006997          	auipc	s3,0x6
    800025c8:	cbc98993          	addi	s3,s3,-836 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800025cc:	00006a97          	auipc	s5,0x6
    800025d0:	cbca8a93          	addi	s5,s5,-836 # 80008288 <digits+0x248>
    printf("\n");
    800025d4:	00006a17          	auipc	s4,0x6
    800025d8:	af4a0a13          	addi	s4,s4,-1292 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025dc:	00006b97          	auipc	s7,0x6
    800025e0:	cecb8b93          	addi	s7,s7,-788 # 800082c8 <states.0>
    800025e4:	a00d                	j	80002606 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025e6:	ed86a583          	lw	a1,-296(a3)
    800025ea:	8556                	mv	a0,s5
    800025ec:	ffffe097          	auipc	ra,0xffffe
    800025f0:	f9c080e7          	jalr	-100(ra) # 80000588 <printf>
    printf("\n");
    800025f4:	8552                	mv	a0,s4
    800025f6:	ffffe097          	auipc	ra,0xffffe
    800025fa:	f92080e7          	jalr	-110(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800025fe:	1b048493          	addi	s1,s1,432
    80002602:	03248163          	beq	s1,s2,80002624 <procdump+0x98>
    if (p->state == UNUSED)
    80002606:	86a6                	mv	a3,s1
    80002608:	ec04a783          	lw	a5,-320(s1)
    8000260c:	dbed                	beqz	a5,800025fe <procdump+0x72>
      state = "???";
    8000260e:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002610:	fcfb6be3          	bltu	s6,a5,800025e6 <procdump+0x5a>
    80002614:	1782                	slli	a5,a5,0x20
    80002616:	9381                	srli	a5,a5,0x20
    80002618:	078e                	slli	a5,a5,0x3
    8000261a:	97de                	add	a5,a5,s7
    8000261c:	6390                	ld	a2,0(a5)
    8000261e:	f661                	bnez	a2,800025e6 <procdump+0x5a>
      state = "???";
    80002620:	864e                	mv	a2,s3
    80002622:	b7d1                	j	800025e6 <procdump+0x5a>
  }
}
    80002624:	60a6                	ld	ra,72(sp)
    80002626:	6406                	ld	s0,64(sp)
    80002628:	74e2                	ld	s1,56(sp)
    8000262a:	7942                	ld	s2,48(sp)
    8000262c:	79a2                	ld	s3,40(sp)
    8000262e:	7a02                	ld	s4,32(sp)
    80002630:	6ae2                	ld	s5,24(sp)
    80002632:	6b42                	ld	s6,16(sp)
    80002634:	6ba2                	ld	s7,8(sp)
    80002636:	6161                	addi	sp,sp,80
    80002638:	8082                	ret

000000008000263a <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    8000263a:	711d                	addi	sp,sp,-96
    8000263c:	ec86                	sd	ra,88(sp)
    8000263e:	e8a2                	sd	s0,80(sp)
    80002640:	e4a6                	sd	s1,72(sp)
    80002642:	e0ca                	sd	s2,64(sp)
    80002644:	fc4e                	sd	s3,56(sp)
    80002646:	f852                	sd	s4,48(sp)
    80002648:	f456                	sd	s5,40(sp)
    8000264a:	f05a                	sd	s6,32(sp)
    8000264c:	ec5e                	sd	s7,24(sp)
    8000264e:	e862                	sd	s8,16(sp)
    80002650:	e466                	sd	s9,8(sp)
    80002652:	e06a                	sd	s10,0(sp)
    80002654:	1080                	addi	s0,sp,96
    80002656:	8b2a                	mv	s6,a0
    80002658:	8bae                	mv	s7,a1
    8000265a:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    8000265c:	fffff097          	auipc	ra,0xfffff
    80002660:	350080e7          	jalr	848(ra) # 800019ac <myproc>
    80002664:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002666:	0000e517          	auipc	a0,0xe
    8000266a:	52250513          	addi	a0,a0,1314 # 80010b88 <wait_lock>
    8000266e:	ffffe097          	auipc	ra,0xffffe
    80002672:	568080e7          	jalr	1384(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    80002676:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002678:	4a15                	li	s4,5
        havekids = 1;
    8000267a:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    8000267c:	00019997          	auipc	s3,0x19
    80002680:	3a498993          	addi	s3,s3,932 # 8001ba20 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002684:	0000ed17          	auipc	s10,0xe
    80002688:	504d0d13          	addi	s10,s10,1284 # 80010b88 <wait_lock>
    havekids = 0;
    8000268c:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    8000268e:	00012497          	auipc	s1,0x12
    80002692:	79248493          	addi	s1,s1,1938 # 80014e20 <proc>
    80002696:	a059                	j	8000271c <waitx+0xe2>
          pid = np->pid;
    80002698:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    8000269c:	1684a703          	lw	a4,360(s1)
    800026a0:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800026a4:	16c4a783          	lw	a5,364(s1)
    800026a8:	9f3d                	addw	a4,a4,a5
    800026aa:	1704a783          	lw	a5,368(s1)
    800026ae:	9f99                	subw	a5,a5,a4
    800026b0:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800026b4:	000b0e63          	beqz	s6,800026d0 <waitx+0x96>
    800026b8:	4691                	li	a3,4
    800026ba:	02c48613          	addi	a2,s1,44
    800026be:	85da                	mv	a1,s6
    800026c0:	05093503          	ld	a0,80(s2)
    800026c4:	fffff097          	auipc	ra,0xfffff
    800026c8:	fa4080e7          	jalr	-92(ra) # 80001668 <copyout>
    800026cc:	02054563          	bltz	a0,800026f6 <waitx+0xbc>
          freeproc(np);
    800026d0:	8526                	mv	a0,s1
    800026d2:	fffff097          	auipc	ra,0xfffff
    800026d6:	48c080e7          	jalr	1164(ra) # 80001b5e <freeproc>
          release(&np->lock);
    800026da:	8526                	mv	a0,s1
    800026dc:	ffffe097          	auipc	ra,0xffffe
    800026e0:	5ae080e7          	jalr	1454(ra) # 80000c8a <release>
          release(&wait_lock);
    800026e4:	0000e517          	auipc	a0,0xe
    800026e8:	4a450513          	addi	a0,a0,1188 # 80010b88 <wait_lock>
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	59e080e7          	jalr	1438(ra) # 80000c8a <release>
          return pid;
    800026f4:	a09d                	j	8000275a <waitx+0x120>
            release(&np->lock);
    800026f6:	8526                	mv	a0,s1
    800026f8:	ffffe097          	auipc	ra,0xffffe
    800026fc:	592080e7          	jalr	1426(ra) # 80000c8a <release>
            release(&wait_lock);
    80002700:	0000e517          	auipc	a0,0xe
    80002704:	48850513          	addi	a0,a0,1160 # 80010b88 <wait_lock>
    80002708:	ffffe097          	auipc	ra,0xffffe
    8000270c:	582080e7          	jalr	1410(ra) # 80000c8a <release>
            return -1;
    80002710:	59fd                	li	s3,-1
    80002712:	a0a1                	j	8000275a <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002714:	1b048493          	addi	s1,s1,432
    80002718:	03348463          	beq	s1,s3,80002740 <waitx+0x106>
      if (np->parent == p)
    8000271c:	7c9c                	ld	a5,56(s1)
    8000271e:	ff279be3          	bne	a5,s2,80002714 <waitx+0xda>
        acquire(&np->lock);
    80002722:	8526                	mv	a0,s1
    80002724:	ffffe097          	auipc	ra,0xffffe
    80002728:	4b2080e7          	jalr	1202(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    8000272c:	4c9c                	lw	a5,24(s1)
    8000272e:	f74785e3          	beq	a5,s4,80002698 <waitx+0x5e>
        release(&np->lock);
    80002732:	8526                	mv	a0,s1
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	556080e7          	jalr	1366(ra) # 80000c8a <release>
        havekids = 1;
    8000273c:	8756                	mv	a4,s5
    8000273e:	bfd9                	j	80002714 <waitx+0xda>
    if (!havekids || p->killed)
    80002740:	c701                	beqz	a4,80002748 <waitx+0x10e>
    80002742:	02892783          	lw	a5,40(s2)
    80002746:	cb8d                	beqz	a5,80002778 <waitx+0x13e>
      release(&wait_lock);
    80002748:	0000e517          	auipc	a0,0xe
    8000274c:	44050513          	addi	a0,a0,1088 # 80010b88 <wait_lock>
    80002750:	ffffe097          	auipc	ra,0xffffe
    80002754:	53a080e7          	jalr	1338(ra) # 80000c8a <release>
      return -1;
    80002758:	59fd                	li	s3,-1
  }
}
    8000275a:	854e                	mv	a0,s3
    8000275c:	60e6                	ld	ra,88(sp)
    8000275e:	6446                	ld	s0,80(sp)
    80002760:	64a6                	ld	s1,72(sp)
    80002762:	6906                	ld	s2,64(sp)
    80002764:	79e2                	ld	s3,56(sp)
    80002766:	7a42                	ld	s4,48(sp)
    80002768:	7aa2                	ld	s5,40(sp)
    8000276a:	7b02                	ld	s6,32(sp)
    8000276c:	6be2                	ld	s7,24(sp)
    8000276e:	6c42                	ld	s8,16(sp)
    80002770:	6ca2                	ld	s9,8(sp)
    80002772:	6d02                	ld	s10,0(sp)
    80002774:	6125                	addi	sp,sp,96
    80002776:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002778:	85ea                	mv	a1,s10
    8000277a:	854a                	mv	a0,s2
    8000277c:	00000097          	auipc	ra,0x0
    80002780:	950080e7          	jalr	-1712(ra) # 800020cc <sleep>
    havekids = 0;
    80002784:	b721                	j	8000268c <waitx+0x52>

0000000080002786 <update_time>:

void update_time()
{
    80002786:	7179                	addi	sp,sp,-48
    80002788:	f406                	sd	ra,40(sp)
    8000278a:	f022                	sd	s0,32(sp)
    8000278c:	ec26                	sd	s1,24(sp)
    8000278e:	e84a                	sd	s2,16(sp)
    80002790:	e44e                	sd	s3,8(sp)
    80002792:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002794:	00012497          	auipc	s1,0x12
    80002798:	68c48493          	addi	s1,s1,1676 # 80014e20 <proc>
  { 
    acquire(&p->lock);
    if (p->state == RUNNING)
    8000279c:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    8000279e:	00019917          	auipc	s2,0x19
    800027a2:	28290913          	addi	s2,s2,642 # 8001ba20 <tickslock>
    800027a6:	a811                	j	800027ba <update_time+0x34>
      
      
      
      
    }
    release(&p->lock);
    800027a8:	8526                	mv	a0,s1
    800027aa:	ffffe097          	auipc	ra,0xffffe
    800027ae:	4e0080e7          	jalr	1248(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800027b2:	1b048493          	addi	s1,s1,432
    800027b6:	03248063          	beq	s1,s2,800027d6 <update_time+0x50>
    acquire(&p->lock);
    800027ba:	8526                	mv	a0,s1
    800027bc:	ffffe097          	auipc	ra,0xffffe
    800027c0:	41a080e7          	jalr	1050(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    800027c4:	4c9c                	lw	a5,24(s1)
    800027c6:	ff3791e3          	bne	a5,s3,800027a8 <update_time+0x22>
      p->rtime++;
    800027ca:	1684a783          	lw	a5,360(s1)
    800027ce:	2785                	addiw	a5,a5,1
    800027d0:	16f4a423          	sw	a5,360(s1)
    800027d4:	bfd1                	j	800027a8 <update_time+0x22>
  }

}
    800027d6:	70a2                	ld	ra,40(sp)
    800027d8:	7402                	ld	s0,32(sp)
    800027da:	64e2                	ld	s1,24(sp)
    800027dc:	6942                	ld	s2,16(sp)
    800027de:	69a2                	ld	s3,8(sp)
    800027e0:	6145                	addi	sp,sp,48
    800027e2:	8082                	ret

00000000800027e4 <swtch>:
    800027e4:	00153023          	sd	ra,0(a0)
    800027e8:	00253423          	sd	sp,8(a0)
    800027ec:	e900                	sd	s0,16(a0)
    800027ee:	ed04                	sd	s1,24(a0)
    800027f0:	03253023          	sd	s2,32(a0)
    800027f4:	03353423          	sd	s3,40(a0)
    800027f8:	03453823          	sd	s4,48(a0)
    800027fc:	03553c23          	sd	s5,56(a0)
    80002800:	05653023          	sd	s6,64(a0)
    80002804:	05753423          	sd	s7,72(a0)
    80002808:	05853823          	sd	s8,80(a0)
    8000280c:	05953c23          	sd	s9,88(a0)
    80002810:	07a53023          	sd	s10,96(a0)
    80002814:	07b53423          	sd	s11,104(a0)
    80002818:	0005b083          	ld	ra,0(a1)
    8000281c:	0085b103          	ld	sp,8(a1)
    80002820:	6980                	ld	s0,16(a1)
    80002822:	6d84                	ld	s1,24(a1)
    80002824:	0205b903          	ld	s2,32(a1)
    80002828:	0285b983          	ld	s3,40(a1)
    8000282c:	0305ba03          	ld	s4,48(a1)
    80002830:	0385ba83          	ld	s5,56(a1)
    80002834:	0405bb03          	ld	s6,64(a1)
    80002838:	0485bb83          	ld	s7,72(a1)
    8000283c:	0505bc03          	ld	s8,80(a1)
    80002840:	0585bc83          	ld	s9,88(a1)
    80002844:	0605bd03          	ld	s10,96(a1)
    80002848:	0685bd83          	ld	s11,104(a1)
    8000284c:	8082                	ret

000000008000284e <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    8000284e:	1141                	addi	sp,sp,-16
    80002850:	e406                	sd	ra,8(sp)
    80002852:	e022                	sd	s0,0(sp)
    80002854:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002856:	00006597          	auipc	a1,0x6
    8000285a:	aa258593          	addi	a1,a1,-1374 # 800082f8 <states.0+0x30>
    8000285e:	00019517          	auipc	a0,0x19
    80002862:	1c250513          	addi	a0,a0,450 # 8001ba20 <tickslock>
    80002866:	ffffe097          	auipc	ra,0xffffe
    8000286a:	2e0080e7          	jalr	736(ra) # 80000b46 <initlock>
}
    8000286e:	60a2                	ld	ra,8(sp)
    80002870:	6402                	ld	s0,0(sp)
    80002872:	0141                	addi	sp,sp,16
    80002874:	8082                	ret

0000000080002876 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002876:	1141                	addi	sp,sp,-16
    80002878:	e422                	sd	s0,8(sp)
    8000287a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000287c:	00003797          	auipc	a5,0x3
    80002880:	6e478793          	addi	a5,a5,1764 # 80005f60 <kernelvec>
    80002884:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002888:	6422                	ld	s0,8(sp)
    8000288a:	0141                	addi	sp,sp,16
    8000288c:	8082                	ret

000000008000288e <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    8000288e:	1141                	addi	sp,sp,-16
    80002890:	e406                	sd	ra,8(sp)
    80002892:	e022                	sd	s0,0(sp)
    80002894:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002896:	fffff097          	auipc	ra,0xfffff
    8000289a:	116080e7          	jalr	278(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000289e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028a2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028a4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800028a8:	00004617          	auipc	a2,0x4
    800028ac:	75860613          	addi	a2,a2,1880 # 80007000 <_trampoline>
    800028b0:	00004697          	auipc	a3,0x4
    800028b4:	75068693          	addi	a3,a3,1872 # 80007000 <_trampoline>
    800028b8:	8e91                	sub	a3,a3,a2
    800028ba:	040007b7          	lui	a5,0x4000
    800028be:	17fd                	addi	a5,a5,-1
    800028c0:	07b2                	slli	a5,a5,0xc
    800028c2:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028c4:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028c8:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028ca:	180026f3          	csrr	a3,satp
    800028ce:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028d0:	6d38                	ld	a4,88(a0)
    800028d2:	6134                	ld	a3,64(a0)
    800028d4:	6585                	lui	a1,0x1
    800028d6:	96ae                	add	a3,a3,a1
    800028d8:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028da:	6d38                	ld	a4,88(a0)
    800028dc:	00000697          	auipc	a3,0x0
    800028e0:	13e68693          	addi	a3,a3,318 # 80002a1a <usertrap>
    800028e4:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800028e6:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028e8:	8692                	mv	a3,tp
    800028ea:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ec:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028f0:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028f4:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028f8:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028fc:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028fe:	6f18                	ld	a4,24(a4)
    80002900:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002904:	6928                	ld	a0,80(a0)
    80002906:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002908:	00004717          	auipc	a4,0x4
    8000290c:	79470713          	addi	a4,a4,1940 # 8000709c <userret>
    80002910:	8f11                	sub	a4,a4,a2
    80002912:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002914:	577d                	li	a4,-1
    80002916:	177e                	slli	a4,a4,0x3f
    80002918:	8d59                	or	a0,a0,a4
    8000291a:	9782                	jalr	a5

 
  

 
}
    8000291c:	60a2                	ld	ra,8(sp)
    8000291e:	6402                	ld	s0,0(sp)
    80002920:	0141                	addi	sp,sp,16
    80002922:	8082                	ret

0000000080002924 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002924:	1101                	addi	sp,sp,-32
    80002926:	ec06                	sd	ra,24(sp)
    80002928:	e822                	sd	s0,16(sp)
    8000292a:	e426                	sd	s1,8(sp)
    8000292c:	e04a                	sd	s2,0(sp)
    8000292e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002930:	00019917          	auipc	s2,0x19
    80002934:	0f090913          	addi	s2,s2,240 # 8001ba20 <tickslock>
    80002938:	854a                	mv	a0,s2
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	29c080e7          	jalr	668(ra) # 80000bd6 <acquire>
  ticks++;
    80002942:	00006497          	auipc	s1,0x6
    80002946:	fba48493          	addi	s1,s1,-70 # 800088fc <ticks>
    8000294a:	409c                	lw	a5,0(s1)
    8000294c:	2785                	addiw	a5,a5,1
    8000294e:	c09c                	sw	a5,0(s1)
  update_time();
    80002950:	00000097          	auipc	ra,0x0
    80002954:	e36080e7          	jalr	-458(ra) # 80002786 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002958:	8526                	mv	a0,s1
    8000295a:	fffff097          	auipc	ra,0xfffff
    8000295e:	7d6080e7          	jalr	2006(ra) # 80002130 <wakeup>
  release(&tickslock);
    80002962:	854a                	mv	a0,s2
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	326080e7          	jalr	806(ra) # 80000c8a <release>
}
    8000296c:	60e2                	ld	ra,24(sp)
    8000296e:	6442                	ld	s0,16(sp)
    80002970:	64a2                	ld	s1,8(sp)
    80002972:	6902                	ld	s2,0(sp)
    80002974:	6105                	addi	sp,sp,32
    80002976:	8082                	ret

0000000080002978 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002978:	1101                	addi	sp,sp,-32
    8000297a:	ec06                	sd	ra,24(sp)
    8000297c:	e822                	sd	s0,16(sp)
    8000297e:	e426                	sd	s1,8(sp)
    80002980:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002982:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002986:	00074d63          	bltz	a4,800029a0 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    8000298a:	57fd                	li	a5,-1
    8000298c:	17fe                	slli	a5,a5,0x3f
    8000298e:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002990:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002992:	06f70363          	beq	a4,a5,800029f8 <devintr+0x80>
  }
}
    80002996:	60e2                	ld	ra,24(sp)
    80002998:	6442                	ld	s0,16(sp)
    8000299a:	64a2                	ld	s1,8(sp)
    8000299c:	6105                	addi	sp,sp,32
    8000299e:	8082                	ret
      (scause & 0xff) == 9)
    800029a0:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    800029a4:	46a5                	li	a3,9
    800029a6:	fed792e3          	bne	a5,a3,8000298a <devintr+0x12>
    int irq = plic_claim();
    800029aa:	00003097          	auipc	ra,0x3
    800029ae:	6be080e7          	jalr	1726(ra) # 80006068 <plic_claim>
    800029b2:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    800029b4:	47a9                	li	a5,10
    800029b6:	02f50763          	beq	a0,a5,800029e4 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    800029ba:	4785                	li	a5,1
    800029bc:	02f50963          	beq	a0,a5,800029ee <devintr+0x76>
    return 1;
    800029c0:	4505                	li	a0,1
    else if (irq)
    800029c2:	d8f1                	beqz	s1,80002996 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800029c4:	85a6                	mv	a1,s1
    800029c6:	00006517          	auipc	a0,0x6
    800029ca:	93a50513          	addi	a0,a0,-1734 # 80008300 <states.0+0x38>
    800029ce:	ffffe097          	auipc	ra,0xffffe
    800029d2:	bba080e7          	jalr	-1094(ra) # 80000588 <printf>
      plic_complete(irq);
    800029d6:	8526                	mv	a0,s1
    800029d8:	00003097          	auipc	ra,0x3
    800029dc:	6b4080e7          	jalr	1716(ra) # 8000608c <plic_complete>
    return 1;
    800029e0:	4505                	li	a0,1
    800029e2:	bf55                	j	80002996 <devintr+0x1e>
      uartintr();
    800029e4:	ffffe097          	auipc	ra,0xffffe
    800029e8:	fb6080e7          	jalr	-74(ra) # 8000099a <uartintr>
    800029ec:	b7ed                	j	800029d6 <devintr+0x5e>
      virtio_disk_intr();
    800029ee:	00004097          	auipc	ra,0x4
    800029f2:	b6a080e7          	jalr	-1174(ra) # 80006558 <virtio_disk_intr>
    800029f6:	b7c5                	j	800029d6 <devintr+0x5e>
    if (cpuid() == 0)
    800029f8:	fffff097          	auipc	ra,0xfffff
    800029fc:	f88080e7          	jalr	-120(ra) # 80001980 <cpuid>
    80002a00:	c901                	beqz	a0,80002a10 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a02:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a06:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a08:	14479073          	csrw	sip,a5
    return 2;
    80002a0c:	4509                	li	a0,2
    80002a0e:	b761                	j	80002996 <devintr+0x1e>
      clockintr();
    80002a10:	00000097          	auipc	ra,0x0
    80002a14:	f14080e7          	jalr	-236(ra) # 80002924 <clockintr>
    80002a18:	b7ed                	j	80002a02 <devintr+0x8a>

0000000080002a1a <usertrap>:
{
    80002a1a:	1101                	addi	sp,sp,-32
    80002a1c:	ec06                	sd	ra,24(sp)
    80002a1e:	e822                	sd	s0,16(sp)
    80002a20:	e426                	sd	s1,8(sp)
    80002a22:	e04a                	sd	s2,0(sp)
    80002a24:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a26:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002a2a:	1007f793          	andi	a5,a5,256
    80002a2e:	efb1                	bnez	a5,80002a8a <usertrap+0x70>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a30:	00003797          	auipc	a5,0x3
    80002a34:	53078793          	addi	a5,a5,1328 # 80005f60 <kernelvec>
    80002a38:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a3c:	fffff097          	auipc	ra,0xfffff
    80002a40:	f70080e7          	jalr	-144(ra) # 800019ac <myproc>
    80002a44:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a46:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a48:	14102773          	csrr	a4,sepc
    80002a4c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a4e:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002a52:	47a1                	li	a5,8
    80002a54:	04f70363          	beq	a4,a5,80002a9a <usertrap+0x80>
  else if ((which_dev = devintr()) != 0)
    80002a58:	00000097          	auipc	ra,0x0
    80002a5c:	f20080e7          	jalr	-224(ra) # 80002978 <devintr>
    80002a60:	cd6d                	beqz	a0,80002b5a <usertrap+0x140>
    else if (which_dev == 2 && p->alarm_on == 0) {
    80002a62:	4789                	li	a5,2
    80002a64:	06f50563          	beq	a0,a5,80002ace <usertrap+0xb4>
  if (killed(p))
    80002a68:	8526                	mv	a0,s1
    80002a6a:	00000097          	auipc	ra,0x0
    80002a6e:	916080e7          	jalr	-1770(ra) # 80002380 <killed>
    80002a72:	12051163          	bnez	a0,80002b94 <usertrap+0x17a>
  usertrapret();
    80002a76:	00000097          	auipc	ra,0x0
    80002a7a:	e18080e7          	jalr	-488(ra) # 8000288e <usertrapret>
}
    80002a7e:	60e2                	ld	ra,24(sp)
    80002a80:	6442                	ld	s0,16(sp)
    80002a82:	64a2                	ld	s1,8(sp)
    80002a84:	6902                	ld	s2,0(sp)
    80002a86:	6105                	addi	sp,sp,32
    80002a88:	8082                	ret
    panic("usertrap: not from user mode");
    80002a8a:	00006517          	auipc	a0,0x6
    80002a8e:	89650513          	addi	a0,a0,-1898 # 80008320 <states.0+0x58>
    80002a92:	ffffe097          	auipc	ra,0xffffe
    80002a96:	aac080e7          	jalr	-1364(ra) # 8000053e <panic>
    if (killed(p))
    80002a9a:	00000097          	auipc	ra,0x0
    80002a9e:	8e6080e7          	jalr	-1818(ra) # 80002380 <killed>
    80002aa2:	e105                	bnez	a0,80002ac2 <usertrap+0xa8>
    p->trapframe->epc += 4;
    80002aa4:	6cb8                	ld	a4,88(s1)
    80002aa6:	6f1c                	ld	a5,24(a4)
    80002aa8:	0791                	addi	a5,a5,4
    80002aaa:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ab0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ab4:	10079073          	csrw	sstatus,a5
    syscall();
    80002ab8:	00000097          	auipc	ra,0x0
    80002abc:	332080e7          	jalr	818(ra) # 80002dea <syscall>
    80002ac0:	b765                	j	80002a68 <usertrap+0x4e>
      exit(-1);
    80002ac2:	557d                	li	a0,-1
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	73c080e7          	jalr	1852(ra) # 80002200 <exit>
    80002acc:	bfe1                	j	80002aa4 <usertrap+0x8a>
    else if (which_dev == 2 && p->alarm_on == 0) {
    80002ace:	1884a903          	lw	s2,392(s1)
    80002ad2:	04091863          	bnez	s2,80002b22 <usertrap+0x108>
      p->alarm_on = 1;
    80002ad6:	4785                	li	a5,1
    80002ad8:	18f4a423          	sw	a5,392(s1)
     if ((p->temp_ticks - ticks) >= p->maxticks){
    80002adc:	18c4a783          	lw	a5,396(s1)
    80002ae0:	00006717          	auipc	a4,0x6
    80002ae4:	e1c72703          	lw	a4,-484(a4) # 800088fc <ticks>
    80002ae8:	9f99                	subw	a5,a5,a4
    80002aea:	1784a703          	lw	a4,376(s1)
    80002aee:	00e7e963          	bltu	a5,a4,80002b00 <usertrap+0xe6>
          p->address = 0;
    80002af2:	1604ae23          	sw	zero,380(s1)
          p->temp_ticks = 0;
    80002af6:	1804a623          	sw	zero,396(s1)
          p->maxticks = 0;
    80002afa:	1604ac23          	sw	zero,376(s1)
          flag = 1;
    80002afe:	4905                	li	s2,1
      p->temp_trapframe = kalloc();
    80002b00:	ffffe097          	auipc	ra,0xffffe
    80002b04:	fe6080e7          	jalr	-26(ra) # 80000ae6 <kalloc>
    80002b08:	18a4b023          	sd	a0,384(s1)
     if(p->temp_trapframe && p->trapframe){
    80002b0c:	d92d                	beqz	a0,80002a7e <usertrap+0x64>
    80002b0e:	6cac                	ld	a1,88(s1)
    80002b10:	d5bd                	beqz	a1,80002a7e <usertrap+0x64>
     memmove(p->temp_trapframe, p->trapframe, 4096);
    80002b12:	6605                	lui	a2,0x1
    80002b14:	ffffe097          	auipc	ra,0xffffe
    80002b18:	21a080e7          	jalr	538(ra) # 80000d2e <memmove>
     if(flag == 1){
    80002b1c:	4785                	li	a5,1
    80002b1e:	00f90d63          	beq	s2,a5,80002b38 <usertrap+0x11e>
  if (killed(p))
    80002b22:	8526                	mv	a0,s1
    80002b24:	00000097          	auipc	ra,0x0
    80002b28:	85c080e7          	jalr	-1956(ra) # 80002380 <killed>
    80002b2c:	e525                	bnez	a0,80002b94 <usertrap+0x17a>
  yield();
    80002b2e:	fffff097          	auipc	ra,0xfffff
    80002b32:	562080e7          	jalr	1378(ra) # 80002090 <yield>
    80002b36:	b781                	j	80002a76 <usertrap+0x5c>
      p->trapframe->a0 = tf_a0;
    80002b38:	6cbc                	ld	a5,88(s1)
      int tf_a0 = p->temp_trapframe->a0;
    80002b3a:	1804b703          	ld	a4,384(s1)
      p->trapframe->a0 = tf_a0;
    80002b3e:	5b38                	lw	a4,112(a4)
    80002b40:	fbb8                	sd	a4,112(a5)
      if(p->temp_address!=p->address){
    80002b42:	1904a783          	lw	a5,400(s1)
    80002b46:	17c4a703          	lw	a4,380(s1)
    80002b4a:	00e78563          	beq	a5,a4,80002b54 <usertrap+0x13a>
       p->trapframe->epc = p->temp_address;
    80002b4e:	6cb8                	ld	a4,88(s1)
    80002b50:	ef1c                	sd	a5,24(a4)
    80002b52:	bfc1                	j	80002b22 <usertrap+0x108>
         p->trapframe->epc = p->address;
    80002b54:	6cbc                	ld	a5,88(s1)
    80002b56:	ef98                	sd	a4,24(a5)
    80002b58:	b7e9                	j	80002b22 <usertrap+0x108>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b5a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b5e:	5890                	lw	a2,48(s1)
    80002b60:	00005517          	auipc	a0,0x5
    80002b64:	7e050513          	addi	a0,a0,2016 # 80008340 <states.0+0x78>
    80002b68:	ffffe097          	auipc	ra,0xffffe
    80002b6c:	a20080e7          	jalr	-1504(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b70:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b74:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b78:	00005517          	auipc	a0,0x5
    80002b7c:	7f850513          	addi	a0,a0,2040 # 80008370 <states.0+0xa8>
    80002b80:	ffffe097          	auipc	ra,0xffffe
    80002b84:	a08080e7          	jalr	-1528(ra) # 80000588 <printf>
    setkilled(p);
    80002b88:	8526                	mv	a0,s1
    80002b8a:	fffff097          	auipc	ra,0xfffff
    80002b8e:	7ca080e7          	jalr	1994(ra) # 80002354 <setkilled>
    80002b92:	bdd9                	j	80002a68 <usertrap+0x4e>
    exit(-1);
    80002b94:	557d                	li	a0,-1
    80002b96:	fffff097          	auipc	ra,0xfffff
    80002b9a:	66a080e7          	jalr	1642(ra) # 80002200 <exit>
    80002b9e:	bde1                	j	80002a76 <usertrap+0x5c>

0000000080002ba0 <kerneltrap>:
{
    80002ba0:	7179                	addi	sp,sp,-48
    80002ba2:	f406                	sd	ra,40(sp)
    80002ba4:	f022                	sd	s0,32(sp)
    80002ba6:	ec26                	sd	s1,24(sp)
    80002ba8:	e84a                	sd	s2,16(sp)
    80002baa:	e44e                	sd	s3,8(sp)
    80002bac:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bae:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bb2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bb6:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002bba:	1004f793          	andi	a5,s1,256
    80002bbe:	cb85                	beqz	a5,80002bee <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bc0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bc4:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002bc6:	ef85                	bnez	a5,80002bfe <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002bc8:	00000097          	auipc	ra,0x0
    80002bcc:	db0080e7          	jalr	-592(ra) # 80002978 <devintr>
    80002bd0:	cd1d                	beqz	a0,80002c0e <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bd2:	4789                	li	a5,2
    80002bd4:	06f50a63          	beq	a0,a5,80002c48 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bd8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bdc:	10049073          	csrw	sstatus,s1
}
    80002be0:	70a2                	ld	ra,40(sp)
    80002be2:	7402                	ld	s0,32(sp)
    80002be4:	64e2                	ld	s1,24(sp)
    80002be6:	6942                	ld	s2,16(sp)
    80002be8:	69a2                	ld	s3,8(sp)
    80002bea:	6145                	addi	sp,sp,48
    80002bec:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bee:	00005517          	auipc	a0,0x5
    80002bf2:	7a250513          	addi	a0,a0,1954 # 80008390 <states.0+0xc8>
    80002bf6:	ffffe097          	auipc	ra,0xffffe
    80002bfa:	948080e7          	jalr	-1720(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002bfe:	00005517          	auipc	a0,0x5
    80002c02:	7ba50513          	addi	a0,a0,1978 # 800083b8 <states.0+0xf0>
    80002c06:	ffffe097          	auipc	ra,0xffffe
    80002c0a:	938080e7          	jalr	-1736(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002c0e:	85ce                	mv	a1,s3
    80002c10:	00005517          	auipc	a0,0x5
    80002c14:	7c850513          	addi	a0,a0,1992 # 800083d8 <states.0+0x110>
    80002c18:	ffffe097          	auipc	ra,0xffffe
    80002c1c:	970080e7          	jalr	-1680(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c20:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c24:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c28:	00005517          	auipc	a0,0x5
    80002c2c:	7c050513          	addi	a0,a0,1984 # 800083e8 <states.0+0x120>
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	958080e7          	jalr	-1704(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002c38:	00005517          	auipc	a0,0x5
    80002c3c:	7c850513          	addi	a0,a0,1992 # 80008400 <states.0+0x138>
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	8fe080e7          	jalr	-1794(ra) # 8000053e <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c48:	fffff097          	auipc	ra,0xfffff
    80002c4c:	d64080e7          	jalr	-668(ra) # 800019ac <myproc>
    80002c50:	d541                	beqz	a0,80002bd8 <kerneltrap+0x38>
    80002c52:	fffff097          	auipc	ra,0xfffff
    80002c56:	d5a080e7          	jalr	-678(ra) # 800019ac <myproc>
    80002c5a:	4d18                	lw	a4,24(a0)
    80002c5c:	4791                	li	a5,4
    80002c5e:	f6f71de3          	bne	a4,a5,80002bd8 <kerneltrap+0x38>
  yield();
    80002c62:	fffff097          	auipc	ra,0xfffff
    80002c66:	42e080e7          	jalr	1070(ra) # 80002090 <yield>
    80002c6a:	b7bd                	j	80002bd8 <kerneltrap+0x38>

0000000080002c6c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c6c:	1101                	addi	sp,sp,-32
    80002c6e:	ec06                	sd	ra,24(sp)
    80002c70:	e822                	sd	s0,16(sp)
    80002c72:	e426                	sd	s1,8(sp)
    80002c74:	1000                	addi	s0,sp,32
    80002c76:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c78:	fffff097          	auipc	ra,0xfffff
    80002c7c:	d34080e7          	jalr	-716(ra) # 800019ac <myproc>
  switch (n) {
    80002c80:	4795                	li	a5,5
    80002c82:	0497e163          	bltu	a5,s1,80002cc4 <argraw+0x58>
    80002c86:	048a                	slli	s1,s1,0x2
    80002c88:	00005717          	auipc	a4,0x5
    80002c8c:	7b070713          	addi	a4,a4,1968 # 80008438 <states.0+0x170>
    80002c90:	94ba                	add	s1,s1,a4
    80002c92:	409c                	lw	a5,0(s1)
    80002c94:	97ba                	add	a5,a5,a4
    80002c96:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c98:	6d3c                	ld	a5,88(a0)
    80002c9a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c9c:	60e2                	ld	ra,24(sp)
    80002c9e:	6442                	ld	s0,16(sp)
    80002ca0:	64a2                	ld	s1,8(sp)
    80002ca2:	6105                	addi	sp,sp,32
    80002ca4:	8082                	ret
    return p->trapframe->a1;
    80002ca6:	6d3c                	ld	a5,88(a0)
    80002ca8:	7fa8                	ld	a0,120(a5)
    80002caa:	bfcd                	j	80002c9c <argraw+0x30>
    return p->trapframe->a2;
    80002cac:	6d3c                	ld	a5,88(a0)
    80002cae:	63c8                	ld	a0,128(a5)
    80002cb0:	b7f5                	j	80002c9c <argraw+0x30>
    return p->trapframe->a3;
    80002cb2:	6d3c                	ld	a5,88(a0)
    80002cb4:	67c8                	ld	a0,136(a5)
    80002cb6:	b7dd                	j	80002c9c <argraw+0x30>
    return p->trapframe->a4;
    80002cb8:	6d3c                	ld	a5,88(a0)
    80002cba:	6bc8                	ld	a0,144(a5)
    80002cbc:	b7c5                	j	80002c9c <argraw+0x30>
    return p->trapframe->a5;
    80002cbe:	6d3c                	ld	a5,88(a0)
    80002cc0:	6fc8                	ld	a0,152(a5)
    80002cc2:	bfe9                	j	80002c9c <argraw+0x30>
  panic("argraw");
    80002cc4:	00005517          	auipc	a0,0x5
    80002cc8:	74c50513          	addi	a0,a0,1868 # 80008410 <states.0+0x148>
    80002ccc:	ffffe097          	auipc	ra,0xffffe
    80002cd0:	872080e7          	jalr	-1934(ra) # 8000053e <panic>

0000000080002cd4 <fetchaddr>:
{
    80002cd4:	1101                	addi	sp,sp,-32
    80002cd6:	ec06                	sd	ra,24(sp)
    80002cd8:	e822                	sd	s0,16(sp)
    80002cda:	e426                	sd	s1,8(sp)
    80002cdc:	e04a                	sd	s2,0(sp)
    80002cde:	1000                	addi	s0,sp,32
    80002ce0:	84aa                	mv	s1,a0
    80002ce2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	cc8080e7          	jalr	-824(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002cec:	653c                	ld	a5,72(a0)
    80002cee:	02f4f863          	bgeu	s1,a5,80002d1e <fetchaddr+0x4a>
    80002cf2:	00848713          	addi	a4,s1,8
    80002cf6:	02e7e663          	bltu	a5,a4,80002d22 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cfa:	46a1                	li	a3,8
    80002cfc:	8626                	mv	a2,s1
    80002cfe:	85ca                	mv	a1,s2
    80002d00:	6928                	ld	a0,80(a0)
    80002d02:	fffff097          	auipc	ra,0xfffff
    80002d06:	9f2080e7          	jalr	-1550(ra) # 800016f4 <copyin>
    80002d0a:	00a03533          	snez	a0,a0
    80002d0e:	40a00533          	neg	a0,a0
}
    80002d12:	60e2                	ld	ra,24(sp)
    80002d14:	6442                	ld	s0,16(sp)
    80002d16:	64a2                	ld	s1,8(sp)
    80002d18:	6902                	ld	s2,0(sp)
    80002d1a:	6105                	addi	sp,sp,32
    80002d1c:	8082                	ret
    return -1;
    80002d1e:	557d                	li	a0,-1
    80002d20:	bfcd                	j	80002d12 <fetchaddr+0x3e>
    80002d22:	557d                	li	a0,-1
    80002d24:	b7fd                	j	80002d12 <fetchaddr+0x3e>

0000000080002d26 <fetchstr>:
{
    80002d26:	7179                	addi	sp,sp,-48
    80002d28:	f406                	sd	ra,40(sp)
    80002d2a:	f022                	sd	s0,32(sp)
    80002d2c:	ec26                	sd	s1,24(sp)
    80002d2e:	e84a                	sd	s2,16(sp)
    80002d30:	e44e                	sd	s3,8(sp)
    80002d32:	1800                	addi	s0,sp,48
    80002d34:	892a                	mv	s2,a0
    80002d36:	84ae                	mv	s1,a1
    80002d38:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	c72080e7          	jalr	-910(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d42:	86ce                	mv	a3,s3
    80002d44:	864a                	mv	a2,s2
    80002d46:	85a6                	mv	a1,s1
    80002d48:	6928                	ld	a0,80(a0)
    80002d4a:	fffff097          	auipc	ra,0xfffff
    80002d4e:	a38080e7          	jalr	-1480(ra) # 80001782 <copyinstr>
    80002d52:	00054e63          	bltz	a0,80002d6e <fetchstr+0x48>
  return strlen(buf);
    80002d56:	8526                	mv	a0,s1
    80002d58:	ffffe097          	auipc	ra,0xffffe
    80002d5c:	0f6080e7          	jalr	246(ra) # 80000e4e <strlen>
}
    80002d60:	70a2                	ld	ra,40(sp)
    80002d62:	7402                	ld	s0,32(sp)
    80002d64:	64e2                	ld	s1,24(sp)
    80002d66:	6942                	ld	s2,16(sp)
    80002d68:	69a2                	ld	s3,8(sp)
    80002d6a:	6145                	addi	sp,sp,48
    80002d6c:	8082                	ret
    return -1;
    80002d6e:	557d                	li	a0,-1
    80002d70:	bfc5                	j	80002d60 <fetchstr+0x3a>

0000000080002d72 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d72:	1101                	addi	sp,sp,-32
    80002d74:	ec06                	sd	ra,24(sp)
    80002d76:	e822                	sd	s0,16(sp)
    80002d78:	e426                	sd	s1,8(sp)
    80002d7a:	1000                	addi	s0,sp,32
    80002d7c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d7e:	00000097          	auipc	ra,0x0
    80002d82:	eee080e7          	jalr	-274(ra) # 80002c6c <argraw>
    80002d86:	c088                	sw	a0,0(s1)
}
    80002d88:	60e2                	ld	ra,24(sp)
    80002d8a:	6442                	ld	s0,16(sp)
    80002d8c:	64a2                	ld	s1,8(sp)
    80002d8e:	6105                	addi	sp,sp,32
    80002d90:	8082                	ret

0000000080002d92 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d92:	1101                	addi	sp,sp,-32
    80002d94:	ec06                	sd	ra,24(sp)
    80002d96:	e822                	sd	s0,16(sp)
    80002d98:	e426                	sd	s1,8(sp)
    80002d9a:	1000                	addi	s0,sp,32
    80002d9c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d9e:	00000097          	auipc	ra,0x0
    80002da2:	ece080e7          	jalr	-306(ra) # 80002c6c <argraw>
    80002da6:	e088                	sd	a0,0(s1)
}
    80002da8:	60e2                	ld	ra,24(sp)
    80002daa:	6442                	ld	s0,16(sp)
    80002dac:	64a2                	ld	s1,8(sp)
    80002dae:	6105                	addi	sp,sp,32
    80002db0:	8082                	ret

0000000080002db2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002db2:	7179                	addi	sp,sp,-48
    80002db4:	f406                	sd	ra,40(sp)
    80002db6:	f022                	sd	s0,32(sp)
    80002db8:	ec26                	sd	s1,24(sp)
    80002dba:	e84a                	sd	s2,16(sp)
    80002dbc:	1800                	addi	s0,sp,48
    80002dbe:	84ae                	mv	s1,a1
    80002dc0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002dc2:	fd840593          	addi	a1,s0,-40
    80002dc6:	00000097          	auipc	ra,0x0
    80002dca:	fcc080e7          	jalr	-52(ra) # 80002d92 <argaddr>
  return fetchstr(addr, buf, max);
    80002dce:	864a                	mv	a2,s2
    80002dd0:	85a6                	mv	a1,s1
    80002dd2:	fd843503          	ld	a0,-40(s0)
    80002dd6:	00000097          	auipc	ra,0x0
    80002dda:	f50080e7          	jalr	-176(ra) # 80002d26 <fetchstr>
}
    80002dde:	70a2                	ld	ra,40(sp)
    80002de0:	7402                	ld	s0,32(sp)
    80002de2:	64e2                	ld	s1,24(sp)
    80002de4:	6942                	ld	s2,16(sp)
    80002de6:	6145                	addi	sp,sp,48
    80002de8:	8082                	ret

0000000080002dea <syscall>:



void
syscall(void)
{
    80002dea:	1101                	addi	sp,sp,-32
    80002dec:	ec06                	sd	ra,24(sp)
    80002dee:	e822                	sd	s0,16(sp)
    80002df0:	e426                	sd	s1,8(sp)
    80002df2:	e04a                	sd	s2,0(sp)
    80002df4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002df6:	fffff097          	auipc	ra,0xfffff
    80002dfa:	bb6080e7          	jalr	-1098(ra) # 800019ac <myproc>
    80002dfe:	84aa                	mv	s1,a0
  

  num = p->trapframe->a7;
    80002e00:	05853903          	ld	s2,88(a0)
    80002e04:	0a893783          	ld	a5,168(s2)
    80002e08:	0007869b          	sext.w	a3,a5
  
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e0c:	37fd                	addiw	a5,a5,-1
    80002e0e:	4761                	li	a4,24
    80002e10:	02f76d63          	bltu	a4,a5,80002e4a <syscall+0x60>
    80002e14:	00369713          	slli	a4,a3,0x3
    80002e18:	00005797          	auipc	a5,0x5
    80002e1c:	63878793          	addi	a5,a5,1592 # 80008450 <syscalls>
    80002e20:	97ba                	add	a5,a5,a4
    80002e22:	639c                	ld	a5,0(a5)
    80002e24:	c39d                	beqz	a5,80002e4a <syscall+0x60>
    if(syscalls[num]==sys_read){
    80002e26:	00002717          	auipc	a4,0x2
    80002e2a:	6b270713          	addi	a4,a4,1714 # 800054d8 <sys_read>
    80002e2e:	00e78663          	beq	a5,a4,80002e3a <syscall+0x50>
     // p->readcount+=1;
      readcount1+=1;
    }
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e32:	9782                	jalr	a5
    80002e34:	06a93823          	sd	a0,112(s2)
    80002e38:	a03d                	j	80002e66 <syscall+0x7c>
      readcount1+=1;
    80002e3a:	00006697          	auipc	a3,0x6
    80002e3e:	ac668693          	addi	a3,a3,-1338 # 80008900 <readcount1>
    80002e42:	4298                	lw	a4,0(a3)
    80002e44:	2705                	addiw	a4,a4,1
    80002e46:	c298                	sw	a4,0(a3)
    80002e48:	b7ed                	j	80002e32 <syscall+0x48>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e4a:	15848613          	addi	a2,s1,344
    80002e4e:	588c                	lw	a1,48(s1)
    80002e50:	00005517          	auipc	a0,0x5
    80002e54:	5c850513          	addi	a0,a0,1480 # 80008418 <states.0+0x150>
    80002e58:	ffffd097          	auipc	ra,0xffffd
    80002e5c:	730080e7          	jalr	1840(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e60:	6cbc                	ld	a5,88(s1)
    80002e62:	577d                	li	a4,-1
    80002e64:	fbb8                	sd	a4,112(a5)
  }
}
    80002e66:	60e2                	ld	ra,24(sp)
    80002e68:	6442                	ld	s0,16(sp)
    80002e6a:	64a2                	ld	s1,8(sp)
    80002e6c:	6902                	ld	s2,0(sp)
    80002e6e:	6105                	addi	sp,sp,32
    80002e70:	8082                	ret

0000000080002e72 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e72:	1101                	addi	sp,sp,-32
    80002e74:	ec06                	sd	ra,24(sp)
    80002e76:	e822                	sd	s0,16(sp)
    80002e78:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e7a:	fec40593          	addi	a1,s0,-20
    80002e7e:	4501                	li	a0,0
    80002e80:	00000097          	auipc	ra,0x0
    80002e84:	ef2080e7          	jalr	-270(ra) # 80002d72 <argint>
  exit(n);
    80002e88:	fec42503          	lw	a0,-20(s0)
    80002e8c:	fffff097          	auipc	ra,0xfffff
    80002e90:	374080e7          	jalr	884(ra) # 80002200 <exit>
  return 0; // not reached
}
    80002e94:	4501                	li	a0,0
    80002e96:	60e2                	ld	ra,24(sp)
    80002e98:	6442                	ld	s0,16(sp)
    80002e9a:	6105                	addi	sp,sp,32
    80002e9c:	8082                	ret

0000000080002e9e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e9e:	1141                	addi	sp,sp,-16
    80002ea0:	e406                	sd	ra,8(sp)
    80002ea2:	e022                	sd	s0,0(sp)
    80002ea4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ea6:	fffff097          	auipc	ra,0xfffff
    80002eaa:	b06080e7          	jalr	-1274(ra) # 800019ac <myproc>
}
    80002eae:	5908                	lw	a0,48(a0)
    80002eb0:	60a2                	ld	ra,8(sp)
    80002eb2:	6402                	ld	s0,0(sp)
    80002eb4:	0141                	addi	sp,sp,16
    80002eb6:	8082                	ret

0000000080002eb8 <sys_fork>:

uint64
sys_fork(void)
{
    80002eb8:	1141                	addi	sp,sp,-16
    80002eba:	e406                	sd	ra,8(sp)
    80002ebc:	e022                	sd	s0,0(sp)
    80002ebe:	0800                	addi	s0,sp,16
  return fork();
    80002ec0:	fffff097          	auipc	ra,0xfffff
    80002ec4:	ed4080e7          	jalr	-300(ra) # 80001d94 <fork>
}
    80002ec8:	60a2                	ld	ra,8(sp)
    80002eca:	6402                	ld	s0,0(sp)
    80002ecc:	0141                	addi	sp,sp,16
    80002ece:	8082                	ret

0000000080002ed0 <sys_wait>:

uint64
sys_wait(void)
{
    80002ed0:	1101                	addi	sp,sp,-32
    80002ed2:	ec06                	sd	ra,24(sp)
    80002ed4:	e822                	sd	s0,16(sp)
    80002ed6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ed8:	fe840593          	addi	a1,s0,-24
    80002edc:	4501                	li	a0,0
    80002ede:	00000097          	auipc	ra,0x0
    80002ee2:	eb4080e7          	jalr	-332(ra) # 80002d92 <argaddr>
  return wait(p);
    80002ee6:	fe843503          	ld	a0,-24(s0)
    80002eea:	fffff097          	auipc	ra,0xfffff
    80002eee:	4c8080e7          	jalr	1224(ra) # 800023b2 <wait>
}
    80002ef2:	60e2                	ld	ra,24(sp)
    80002ef4:	6442                	ld	s0,16(sp)
    80002ef6:	6105                	addi	sp,sp,32
    80002ef8:	8082                	ret

0000000080002efa <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002efa:	7179                	addi	sp,sp,-48
    80002efc:	f406                	sd	ra,40(sp)
    80002efe:	f022                	sd	s0,32(sp)
    80002f00:	ec26                	sd	s1,24(sp)
    80002f02:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f04:	fdc40593          	addi	a1,s0,-36
    80002f08:	4501                	li	a0,0
    80002f0a:	00000097          	auipc	ra,0x0
    80002f0e:	e68080e7          	jalr	-408(ra) # 80002d72 <argint>
  addr = myproc()->sz;
    80002f12:	fffff097          	auipc	ra,0xfffff
    80002f16:	a9a080e7          	jalr	-1382(ra) # 800019ac <myproc>
    80002f1a:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002f1c:	fdc42503          	lw	a0,-36(s0)
    80002f20:	fffff097          	auipc	ra,0xfffff
    80002f24:	e18080e7          	jalr	-488(ra) # 80001d38 <growproc>
    80002f28:	00054863          	bltz	a0,80002f38 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f2c:	8526                	mv	a0,s1
    80002f2e:	70a2                	ld	ra,40(sp)
    80002f30:	7402                	ld	s0,32(sp)
    80002f32:	64e2                	ld	s1,24(sp)
    80002f34:	6145                	addi	sp,sp,48
    80002f36:	8082                	ret
    return -1;
    80002f38:	54fd                	li	s1,-1
    80002f3a:	bfcd                	j	80002f2c <sys_sbrk+0x32>

0000000080002f3c <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f3c:	7139                	addi	sp,sp,-64
    80002f3e:	fc06                	sd	ra,56(sp)
    80002f40:	f822                	sd	s0,48(sp)
    80002f42:	f426                	sd	s1,40(sp)
    80002f44:	f04a                	sd	s2,32(sp)
    80002f46:	ec4e                	sd	s3,24(sp)
    80002f48:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f4a:	fcc40593          	addi	a1,s0,-52
    80002f4e:	4501                	li	a0,0
    80002f50:	00000097          	auipc	ra,0x0
    80002f54:	e22080e7          	jalr	-478(ra) # 80002d72 <argint>
  acquire(&tickslock);
    80002f58:	00019517          	auipc	a0,0x19
    80002f5c:	ac850513          	addi	a0,a0,-1336 # 8001ba20 <tickslock>
    80002f60:	ffffe097          	auipc	ra,0xffffe
    80002f64:	c76080e7          	jalr	-906(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002f68:	00006917          	auipc	s2,0x6
    80002f6c:	99492903          	lw	s2,-1644(s2) # 800088fc <ticks>
  while (ticks - ticks0 < n)
    80002f70:	fcc42783          	lw	a5,-52(s0)
    80002f74:	cf9d                	beqz	a5,80002fb2 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f76:	00019997          	auipc	s3,0x19
    80002f7a:	aaa98993          	addi	s3,s3,-1366 # 8001ba20 <tickslock>
    80002f7e:	00006497          	auipc	s1,0x6
    80002f82:	97e48493          	addi	s1,s1,-1666 # 800088fc <ticks>
    if (killed(myproc()))
    80002f86:	fffff097          	auipc	ra,0xfffff
    80002f8a:	a26080e7          	jalr	-1498(ra) # 800019ac <myproc>
    80002f8e:	fffff097          	auipc	ra,0xfffff
    80002f92:	3f2080e7          	jalr	1010(ra) # 80002380 <killed>
    80002f96:	ed15                	bnez	a0,80002fd2 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002f98:	85ce                	mv	a1,s3
    80002f9a:	8526                	mv	a0,s1
    80002f9c:	fffff097          	auipc	ra,0xfffff
    80002fa0:	130080e7          	jalr	304(ra) # 800020cc <sleep>
  while (ticks - ticks0 < n)
    80002fa4:	409c                	lw	a5,0(s1)
    80002fa6:	412787bb          	subw	a5,a5,s2
    80002faa:	fcc42703          	lw	a4,-52(s0)
    80002fae:	fce7ece3          	bltu	a5,a4,80002f86 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002fb2:	00019517          	auipc	a0,0x19
    80002fb6:	a6e50513          	addi	a0,a0,-1426 # 8001ba20 <tickslock>
    80002fba:	ffffe097          	auipc	ra,0xffffe
    80002fbe:	cd0080e7          	jalr	-816(ra) # 80000c8a <release>
  return 0;
    80002fc2:	4501                	li	a0,0
}
    80002fc4:	70e2                	ld	ra,56(sp)
    80002fc6:	7442                	ld	s0,48(sp)
    80002fc8:	74a2                	ld	s1,40(sp)
    80002fca:	7902                	ld	s2,32(sp)
    80002fcc:	69e2                	ld	s3,24(sp)
    80002fce:	6121                	addi	sp,sp,64
    80002fd0:	8082                	ret
      release(&tickslock);
    80002fd2:	00019517          	auipc	a0,0x19
    80002fd6:	a4e50513          	addi	a0,a0,-1458 # 8001ba20 <tickslock>
    80002fda:	ffffe097          	auipc	ra,0xffffe
    80002fde:	cb0080e7          	jalr	-848(ra) # 80000c8a <release>
      return -1;
    80002fe2:	557d                	li	a0,-1
    80002fe4:	b7c5                	j	80002fc4 <sys_sleep+0x88>

0000000080002fe6 <sys_kill>:

uint64
sys_kill(void)
{
    80002fe6:	1101                	addi	sp,sp,-32
    80002fe8:	ec06                	sd	ra,24(sp)
    80002fea:	e822                	sd	s0,16(sp)
    80002fec:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002fee:	fec40593          	addi	a1,s0,-20
    80002ff2:	4501                	li	a0,0
    80002ff4:	00000097          	auipc	ra,0x0
    80002ff8:	d7e080e7          	jalr	-642(ra) # 80002d72 <argint>
  return kill(pid);
    80002ffc:	fec42503          	lw	a0,-20(s0)
    80003000:	fffff097          	auipc	ra,0xfffff
    80003004:	2e2080e7          	jalr	738(ra) # 800022e2 <kill>
}
    80003008:	60e2                	ld	ra,24(sp)
    8000300a:	6442                	ld	s0,16(sp)
    8000300c:	6105                	addi	sp,sp,32
    8000300e:	8082                	ret

0000000080003010 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003010:	1101                	addi	sp,sp,-32
    80003012:	ec06                	sd	ra,24(sp)
    80003014:	e822                	sd	s0,16(sp)
    80003016:	e426                	sd	s1,8(sp)
    80003018:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000301a:	00019517          	auipc	a0,0x19
    8000301e:	a0650513          	addi	a0,a0,-1530 # 8001ba20 <tickslock>
    80003022:	ffffe097          	auipc	ra,0xffffe
    80003026:	bb4080e7          	jalr	-1100(ra) # 80000bd6 <acquire>
  xticks = ticks;
    8000302a:	00006497          	auipc	s1,0x6
    8000302e:	8d24a483          	lw	s1,-1838(s1) # 800088fc <ticks>
  release(&tickslock);
    80003032:	00019517          	auipc	a0,0x19
    80003036:	9ee50513          	addi	a0,a0,-1554 # 8001ba20 <tickslock>
    8000303a:	ffffe097          	auipc	ra,0xffffe
    8000303e:	c50080e7          	jalr	-944(ra) # 80000c8a <release>
  return xticks;
}
    80003042:	02049513          	slli	a0,s1,0x20
    80003046:	9101                	srli	a0,a0,0x20
    80003048:	60e2                	ld	ra,24(sp)
    8000304a:	6442                	ld	s0,16(sp)
    8000304c:	64a2                	ld	s1,8(sp)
    8000304e:	6105                	addi	sp,sp,32
    80003050:	8082                	ret

0000000080003052 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003052:	7139                	addi	sp,sp,-64
    80003054:	fc06                	sd	ra,56(sp)
    80003056:	f822                	sd	s0,48(sp)
    80003058:	f426                	sd	s1,40(sp)
    8000305a:	f04a                	sd	s2,32(sp)
    8000305c:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000305e:	fd840593          	addi	a1,s0,-40
    80003062:	4501                	li	a0,0
    80003064:	00000097          	auipc	ra,0x0
    80003068:	d2e080e7          	jalr	-722(ra) # 80002d92 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    8000306c:	fd040593          	addi	a1,s0,-48
    80003070:	4505                	li	a0,1
    80003072:	00000097          	auipc	ra,0x0
    80003076:	d20080e7          	jalr	-736(ra) # 80002d92 <argaddr>
  argaddr(2, &addr2);
    8000307a:	fc840593          	addi	a1,s0,-56
    8000307e:	4509                	li	a0,2
    80003080:	00000097          	auipc	ra,0x0
    80003084:	d12080e7          	jalr	-750(ra) # 80002d92 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003088:	fc040613          	addi	a2,s0,-64
    8000308c:	fc440593          	addi	a1,s0,-60
    80003090:	fd843503          	ld	a0,-40(s0)
    80003094:	fffff097          	auipc	ra,0xfffff
    80003098:	5a6080e7          	jalr	1446(ra) # 8000263a <waitx>
    8000309c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000309e:	fffff097          	auipc	ra,0xfffff
    800030a2:	90e080e7          	jalr	-1778(ra) # 800019ac <myproc>
    800030a6:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800030a8:	4691                	li	a3,4
    800030aa:	fc440613          	addi	a2,s0,-60
    800030ae:	fd043583          	ld	a1,-48(s0)
    800030b2:	6928                	ld	a0,80(a0)
    800030b4:	ffffe097          	auipc	ra,0xffffe
    800030b8:	5b4080e7          	jalr	1460(ra) # 80001668 <copyout>
    return -1;
    800030bc:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800030be:	00054f63          	bltz	a0,800030dc <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    800030c2:	4691                	li	a3,4
    800030c4:	fc040613          	addi	a2,s0,-64
    800030c8:	fc843583          	ld	a1,-56(s0)
    800030cc:	68a8                	ld	a0,80(s1)
    800030ce:	ffffe097          	auipc	ra,0xffffe
    800030d2:	59a080e7          	jalr	1434(ra) # 80001668 <copyout>
    800030d6:	00054a63          	bltz	a0,800030ea <sys_waitx+0x98>
    return -1;
  return ret;
    800030da:	87ca                	mv	a5,s2
}
    800030dc:	853e                	mv	a0,a5
    800030de:	70e2                	ld	ra,56(sp)
    800030e0:	7442                	ld	s0,48(sp)
    800030e2:	74a2                	ld	s1,40(sp)
    800030e4:	7902                	ld	s2,32(sp)
    800030e6:	6121                	addi	sp,sp,64
    800030e8:	8082                	ret
    return -1;
    800030ea:	57fd                	li	a5,-1
    800030ec:	bfc5                	j	800030dc <sys_waitx+0x8a>

00000000800030ee <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030ee:	7179                	addi	sp,sp,-48
    800030f0:	f406                	sd	ra,40(sp)
    800030f2:	f022                	sd	s0,32(sp)
    800030f4:	ec26                	sd	s1,24(sp)
    800030f6:	e84a                	sd	s2,16(sp)
    800030f8:	e44e                	sd	s3,8(sp)
    800030fa:	e052                	sd	s4,0(sp)
    800030fc:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030fe:	00005597          	auipc	a1,0x5
    80003102:	42258593          	addi	a1,a1,1058 # 80008520 <syscalls+0xd0>
    80003106:	00019517          	auipc	a0,0x19
    8000310a:	93250513          	addi	a0,a0,-1742 # 8001ba38 <bcache>
    8000310e:	ffffe097          	auipc	ra,0xffffe
    80003112:	a38080e7          	jalr	-1480(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003116:	00021797          	auipc	a5,0x21
    8000311a:	92278793          	addi	a5,a5,-1758 # 80023a38 <bcache+0x8000>
    8000311e:	00021717          	auipc	a4,0x21
    80003122:	b8270713          	addi	a4,a4,-1150 # 80023ca0 <bcache+0x8268>
    80003126:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000312a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000312e:	00019497          	auipc	s1,0x19
    80003132:	92248493          	addi	s1,s1,-1758 # 8001ba50 <bcache+0x18>
    b->next = bcache.head.next;
    80003136:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003138:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000313a:	00005a17          	auipc	s4,0x5
    8000313e:	3eea0a13          	addi	s4,s4,1006 # 80008528 <syscalls+0xd8>
    b->next = bcache.head.next;
    80003142:	2b893783          	ld	a5,696(s2)
    80003146:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003148:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000314c:	85d2                	mv	a1,s4
    8000314e:	01048513          	addi	a0,s1,16
    80003152:	00001097          	auipc	ra,0x1
    80003156:	4c4080e7          	jalr	1220(ra) # 80004616 <initsleeplock>
    bcache.head.next->prev = b;
    8000315a:	2b893783          	ld	a5,696(s2)
    8000315e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003160:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003164:	45848493          	addi	s1,s1,1112
    80003168:	fd349de3          	bne	s1,s3,80003142 <binit+0x54>
  }
}
    8000316c:	70a2                	ld	ra,40(sp)
    8000316e:	7402                	ld	s0,32(sp)
    80003170:	64e2                	ld	s1,24(sp)
    80003172:	6942                	ld	s2,16(sp)
    80003174:	69a2                	ld	s3,8(sp)
    80003176:	6a02                	ld	s4,0(sp)
    80003178:	6145                	addi	sp,sp,48
    8000317a:	8082                	ret

000000008000317c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000317c:	7179                	addi	sp,sp,-48
    8000317e:	f406                	sd	ra,40(sp)
    80003180:	f022                	sd	s0,32(sp)
    80003182:	ec26                	sd	s1,24(sp)
    80003184:	e84a                	sd	s2,16(sp)
    80003186:	e44e                	sd	s3,8(sp)
    80003188:	1800                	addi	s0,sp,48
    8000318a:	892a                	mv	s2,a0
    8000318c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000318e:	00019517          	auipc	a0,0x19
    80003192:	8aa50513          	addi	a0,a0,-1878 # 8001ba38 <bcache>
    80003196:	ffffe097          	auipc	ra,0xffffe
    8000319a:	a40080e7          	jalr	-1472(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000319e:	00021497          	auipc	s1,0x21
    800031a2:	b524b483          	ld	s1,-1198(s1) # 80023cf0 <bcache+0x82b8>
    800031a6:	00021797          	auipc	a5,0x21
    800031aa:	afa78793          	addi	a5,a5,-1286 # 80023ca0 <bcache+0x8268>
    800031ae:	02f48f63          	beq	s1,a5,800031ec <bread+0x70>
    800031b2:	873e                	mv	a4,a5
    800031b4:	a021                	j	800031bc <bread+0x40>
    800031b6:	68a4                	ld	s1,80(s1)
    800031b8:	02e48a63          	beq	s1,a4,800031ec <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031bc:	449c                	lw	a5,8(s1)
    800031be:	ff279ce3          	bne	a5,s2,800031b6 <bread+0x3a>
    800031c2:	44dc                	lw	a5,12(s1)
    800031c4:	ff3799e3          	bne	a5,s3,800031b6 <bread+0x3a>
      b->refcnt++;
    800031c8:	40bc                	lw	a5,64(s1)
    800031ca:	2785                	addiw	a5,a5,1
    800031cc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031ce:	00019517          	auipc	a0,0x19
    800031d2:	86a50513          	addi	a0,a0,-1942 # 8001ba38 <bcache>
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	ab4080e7          	jalr	-1356(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800031de:	01048513          	addi	a0,s1,16
    800031e2:	00001097          	auipc	ra,0x1
    800031e6:	46e080e7          	jalr	1134(ra) # 80004650 <acquiresleep>
      return b;
    800031ea:	a8b9                	j	80003248 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031ec:	00021497          	auipc	s1,0x21
    800031f0:	afc4b483          	ld	s1,-1284(s1) # 80023ce8 <bcache+0x82b0>
    800031f4:	00021797          	auipc	a5,0x21
    800031f8:	aac78793          	addi	a5,a5,-1364 # 80023ca0 <bcache+0x8268>
    800031fc:	00f48863          	beq	s1,a5,8000320c <bread+0x90>
    80003200:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003202:	40bc                	lw	a5,64(s1)
    80003204:	cf81                	beqz	a5,8000321c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003206:	64a4                	ld	s1,72(s1)
    80003208:	fee49de3          	bne	s1,a4,80003202 <bread+0x86>
  panic("bget: no buffers");
    8000320c:	00005517          	auipc	a0,0x5
    80003210:	32450513          	addi	a0,a0,804 # 80008530 <syscalls+0xe0>
    80003214:	ffffd097          	auipc	ra,0xffffd
    80003218:	32a080e7          	jalr	810(ra) # 8000053e <panic>
      b->dev = dev;
    8000321c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003220:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003224:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003228:	4785                	li	a5,1
    8000322a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000322c:	00019517          	auipc	a0,0x19
    80003230:	80c50513          	addi	a0,a0,-2036 # 8001ba38 <bcache>
    80003234:	ffffe097          	auipc	ra,0xffffe
    80003238:	a56080e7          	jalr	-1450(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000323c:	01048513          	addi	a0,s1,16
    80003240:	00001097          	auipc	ra,0x1
    80003244:	410080e7          	jalr	1040(ra) # 80004650 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003248:	409c                	lw	a5,0(s1)
    8000324a:	cb89                	beqz	a5,8000325c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000324c:	8526                	mv	a0,s1
    8000324e:	70a2                	ld	ra,40(sp)
    80003250:	7402                	ld	s0,32(sp)
    80003252:	64e2                	ld	s1,24(sp)
    80003254:	6942                	ld	s2,16(sp)
    80003256:	69a2                	ld	s3,8(sp)
    80003258:	6145                	addi	sp,sp,48
    8000325a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000325c:	4581                	li	a1,0
    8000325e:	8526                	mv	a0,s1
    80003260:	00003097          	auipc	ra,0x3
    80003264:	0c4080e7          	jalr	196(ra) # 80006324 <virtio_disk_rw>
    b->valid = 1;
    80003268:	4785                	li	a5,1
    8000326a:	c09c                	sw	a5,0(s1)
  return b;
    8000326c:	b7c5                	j	8000324c <bread+0xd0>

000000008000326e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000326e:	1101                	addi	sp,sp,-32
    80003270:	ec06                	sd	ra,24(sp)
    80003272:	e822                	sd	s0,16(sp)
    80003274:	e426                	sd	s1,8(sp)
    80003276:	1000                	addi	s0,sp,32
    80003278:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000327a:	0541                	addi	a0,a0,16
    8000327c:	00001097          	auipc	ra,0x1
    80003280:	46e080e7          	jalr	1134(ra) # 800046ea <holdingsleep>
    80003284:	cd01                	beqz	a0,8000329c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003286:	4585                	li	a1,1
    80003288:	8526                	mv	a0,s1
    8000328a:	00003097          	auipc	ra,0x3
    8000328e:	09a080e7          	jalr	154(ra) # 80006324 <virtio_disk_rw>
}
    80003292:	60e2                	ld	ra,24(sp)
    80003294:	6442                	ld	s0,16(sp)
    80003296:	64a2                	ld	s1,8(sp)
    80003298:	6105                	addi	sp,sp,32
    8000329a:	8082                	ret
    panic("bwrite");
    8000329c:	00005517          	auipc	a0,0x5
    800032a0:	2ac50513          	addi	a0,a0,684 # 80008548 <syscalls+0xf8>
    800032a4:	ffffd097          	auipc	ra,0xffffd
    800032a8:	29a080e7          	jalr	666(ra) # 8000053e <panic>

00000000800032ac <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032ac:	1101                	addi	sp,sp,-32
    800032ae:	ec06                	sd	ra,24(sp)
    800032b0:	e822                	sd	s0,16(sp)
    800032b2:	e426                	sd	s1,8(sp)
    800032b4:	e04a                	sd	s2,0(sp)
    800032b6:	1000                	addi	s0,sp,32
    800032b8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032ba:	01050913          	addi	s2,a0,16
    800032be:	854a                	mv	a0,s2
    800032c0:	00001097          	auipc	ra,0x1
    800032c4:	42a080e7          	jalr	1066(ra) # 800046ea <holdingsleep>
    800032c8:	c92d                	beqz	a0,8000333a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800032ca:	854a                	mv	a0,s2
    800032cc:	00001097          	auipc	ra,0x1
    800032d0:	3da080e7          	jalr	986(ra) # 800046a6 <releasesleep>

  acquire(&bcache.lock);
    800032d4:	00018517          	auipc	a0,0x18
    800032d8:	76450513          	addi	a0,a0,1892 # 8001ba38 <bcache>
    800032dc:	ffffe097          	auipc	ra,0xffffe
    800032e0:	8fa080e7          	jalr	-1798(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800032e4:	40bc                	lw	a5,64(s1)
    800032e6:	37fd                	addiw	a5,a5,-1
    800032e8:	0007871b          	sext.w	a4,a5
    800032ec:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032ee:	eb05                	bnez	a4,8000331e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800032f0:	68bc                	ld	a5,80(s1)
    800032f2:	64b8                	ld	a4,72(s1)
    800032f4:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800032f6:	64bc                	ld	a5,72(s1)
    800032f8:	68b8                	ld	a4,80(s1)
    800032fa:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032fc:	00020797          	auipc	a5,0x20
    80003300:	73c78793          	addi	a5,a5,1852 # 80023a38 <bcache+0x8000>
    80003304:	2b87b703          	ld	a4,696(a5)
    80003308:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000330a:	00021717          	auipc	a4,0x21
    8000330e:	99670713          	addi	a4,a4,-1642 # 80023ca0 <bcache+0x8268>
    80003312:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003314:	2b87b703          	ld	a4,696(a5)
    80003318:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000331a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000331e:	00018517          	auipc	a0,0x18
    80003322:	71a50513          	addi	a0,a0,1818 # 8001ba38 <bcache>
    80003326:	ffffe097          	auipc	ra,0xffffe
    8000332a:	964080e7          	jalr	-1692(ra) # 80000c8a <release>
}
    8000332e:	60e2                	ld	ra,24(sp)
    80003330:	6442                	ld	s0,16(sp)
    80003332:	64a2                	ld	s1,8(sp)
    80003334:	6902                	ld	s2,0(sp)
    80003336:	6105                	addi	sp,sp,32
    80003338:	8082                	ret
    panic("brelse");
    8000333a:	00005517          	auipc	a0,0x5
    8000333e:	21650513          	addi	a0,a0,534 # 80008550 <syscalls+0x100>
    80003342:	ffffd097          	auipc	ra,0xffffd
    80003346:	1fc080e7          	jalr	508(ra) # 8000053e <panic>

000000008000334a <bpin>:

void
bpin(struct buf *b) {
    8000334a:	1101                	addi	sp,sp,-32
    8000334c:	ec06                	sd	ra,24(sp)
    8000334e:	e822                	sd	s0,16(sp)
    80003350:	e426                	sd	s1,8(sp)
    80003352:	1000                	addi	s0,sp,32
    80003354:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003356:	00018517          	auipc	a0,0x18
    8000335a:	6e250513          	addi	a0,a0,1762 # 8001ba38 <bcache>
    8000335e:	ffffe097          	auipc	ra,0xffffe
    80003362:	878080e7          	jalr	-1928(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003366:	40bc                	lw	a5,64(s1)
    80003368:	2785                	addiw	a5,a5,1
    8000336a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000336c:	00018517          	auipc	a0,0x18
    80003370:	6cc50513          	addi	a0,a0,1740 # 8001ba38 <bcache>
    80003374:	ffffe097          	auipc	ra,0xffffe
    80003378:	916080e7          	jalr	-1770(ra) # 80000c8a <release>
}
    8000337c:	60e2                	ld	ra,24(sp)
    8000337e:	6442                	ld	s0,16(sp)
    80003380:	64a2                	ld	s1,8(sp)
    80003382:	6105                	addi	sp,sp,32
    80003384:	8082                	ret

0000000080003386 <bunpin>:

void
bunpin(struct buf *b) {
    80003386:	1101                	addi	sp,sp,-32
    80003388:	ec06                	sd	ra,24(sp)
    8000338a:	e822                	sd	s0,16(sp)
    8000338c:	e426                	sd	s1,8(sp)
    8000338e:	1000                	addi	s0,sp,32
    80003390:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003392:	00018517          	auipc	a0,0x18
    80003396:	6a650513          	addi	a0,a0,1702 # 8001ba38 <bcache>
    8000339a:	ffffe097          	auipc	ra,0xffffe
    8000339e:	83c080e7          	jalr	-1988(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800033a2:	40bc                	lw	a5,64(s1)
    800033a4:	37fd                	addiw	a5,a5,-1
    800033a6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033a8:	00018517          	auipc	a0,0x18
    800033ac:	69050513          	addi	a0,a0,1680 # 8001ba38 <bcache>
    800033b0:	ffffe097          	auipc	ra,0xffffe
    800033b4:	8da080e7          	jalr	-1830(ra) # 80000c8a <release>
}
    800033b8:	60e2                	ld	ra,24(sp)
    800033ba:	6442                	ld	s0,16(sp)
    800033bc:	64a2                	ld	s1,8(sp)
    800033be:	6105                	addi	sp,sp,32
    800033c0:	8082                	ret

00000000800033c2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033c2:	1101                	addi	sp,sp,-32
    800033c4:	ec06                	sd	ra,24(sp)
    800033c6:	e822                	sd	s0,16(sp)
    800033c8:	e426                	sd	s1,8(sp)
    800033ca:	e04a                	sd	s2,0(sp)
    800033cc:	1000                	addi	s0,sp,32
    800033ce:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033d0:	00d5d59b          	srliw	a1,a1,0xd
    800033d4:	00021797          	auipc	a5,0x21
    800033d8:	d407a783          	lw	a5,-704(a5) # 80024114 <sb+0x1c>
    800033dc:	9dbd                	addw	a1,a1,a5
    800033de:	00000097          	auipc	ra,0x0
    800033e2:	d9e080e7          	jalr	-610(ra) # 8000317c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033e6:	0074f713          	andi	a4,s1,7
    800033ea:	4785                	li	a5,1
    800033ec:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800033f0:	14ce                	slli	s1,s1,0x33
    800033f2:	90d9                	srli	s1,s1,0x36
    800033f4:	00950733          	add	a4,a0,s1
    800033f8:	05874703          	lbu	a4,88(a4)
    800033fc:	00e7f6b3          	and	a3,a5,a4
    80003400:	c69d                	beqz	a3,8000342e <bfree+0x6c>
    80003402:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003404:	94aa                	add	s1,s1,a0
    80003406:	fff7c793          	not	a5,a5
    8000340a:	8ff9                	and	a5,a5,a4
    8000340c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003410:	00001097          	auipc	ra,0x1
    80003414:	120080e7          	jalr	288(ra) # 80004530 <log_write>
  brelse(bp);
    80003418:	854a                	mv	a0,s2
    8000341a:	00000097          	auipc	ra,0x0
    8000341e:	e92080e7          	jalr	-366(ra) # 800032ac <brelse>
}
    80003422:	60e2                	ld	ra,24(sp)
    80003424:	6442                	ld	s0,16(sp)
    80003426:	64a2                	ld	s1,8(sp)
    80003428:	6902                	ld	s2,0(sp)
    8000342a:	6105                	addi	sp,sp,32
    8000342c:	8082                	ret
    panic("freeing free block");
    8000342e:	00005517          	auipc	a0,0x5
    80003432:	12a50513          	addi	a0,a0,298 # 80008558 <syscalls+0x108>
    80003436:	ffffd097          	auipc	ra,0xffffd
    8000343a:	108080e7          	jalr	264(ra) # 8000053e <panic>

000000008000343e <balloc>:
{
    8000343e:	711d                	addi	sp,sp,-96
    80003440:	ec86                	sd	ra,88(sp)
    80003442:	e8a2                	sd	s0,80(sp)
    80003444:	e4a6                	sd	s1,72(sp)
    80003446:	e0ca                	sd	s2,64(sp)
    80003448:	fc4e                	sd	s3,56(sp)
    8000344a:	f852                	sd	s4,48(sp)
    8000344c:	f456                	sd	s5,40(sp)
    8000344e:	f05a                	sd	s6,32(sp)
    80003450:	ec5e                	sd	s7,24(sp)
    80003452:	e862                	sd	s8,16(sp)
    80003454:	e466                	sd	s9,8(sp)
    80003456:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003458:	00021797          	auipc	a5,0x21
    8000345c:	ca47a783          	lw	a5,-860(a5) # 800240fc <sb+0x4>
    80003460:	10078163          	beqz	a5,80003562 <balloc+0x124>
    80003464:	8baa                	mv	s7,a0
    80003466:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003468:	00021b17          	auipc	s6,0x21
    8000346c:	c90b0b13          	addi	s6,s6,-880 # 800240f8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003470:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003472:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003474:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003476:	6c89                	lui	s9,0x2
    80003478:	a061                	j	80003500 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000347a:	974a                	add	a4,a4,s2
    8000347c:	8fd5                	or	a5,a5,a3
    8000347e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003482:	854a                	mv	a0,s2
    80003484:	00001097          	auipc	ra,0x1
    80003488:	0ac080e7          	jalr	172(ra) # 80004530 <log_write>
        brelse(bp);
    8000348c:	854a                	mv	a0,s2
    8000348e:	00000097          	auipc	ra,0x0
    80003492:	e1e080e7          	jalr	-482(ra) # 800032ac <brelse>
  bp = bread(dev, bno);
    80003496:	85a6                	mv	a1,s1
    80003498:	855e                	mv	a0,s7
    8000349a:	00000097          	auipc	ra,0x0
    8000349e:	ce2080e7          	jalr	-798(ra) # 8000317c <bread>
    800034a2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034a4:	40000613          	li	a2,1024
    800034a8:	4581                	li	a1,0
    800034aa:	05850513          	addi	a0,a0,88
    800034ae:	ffffe097          	auipc	ra,0xffffe
    800034b2:	824080e7          	jalr	-2012(ra) # 80000cd2 <memset>
  log_write(bp);
    800034b6:	854a                	mv	a0,s2
    800034b8:	00001097          	auipc	ra,0x1
    800034bc:	078080e7          	jalr	120(ra) # 80004530 <log_write>
  brelse(bp);
    800034c0:	854a                	mv	a0,s2
    800034c2:	00000097          	auipc	ra,0x0
    800034c6:	dea080e7          	jalr	-534(ra) # 800032ac <brelse>
}
    800034ca:	8526                	mv	a0,s1
    800034cc:	60e6                	ld	ra,88(sp)
    800034ce:	6446                	ld	s0,80(sp)
    800034d0:	64a6                	ld	s1,72(sp)
    800034d2:	6906                	ld	s2,64(sp)
    800034d4:	79e2                	ld	s3,56(sp)
    800034d6:	7a42                	ld	s4,48(sp)
    800034d8:	7aa2                	ld	s5,40(sp)
    800034da:	7b02                	ld	s6,32(sp)
    800034dc:	6be2                	ld	s7,24(sp)
    800034de:	6c42                	ld	s8,16(sp)
    800034e0:	6ca2                	ld	s9,8(sp)
    800034e2:	6125                	addi	sp,sp,96
    800034e4:	8082                	ret
    brelse(bp);
    800034e6:	854a                	mv	a0,s2
    800034e8:	00000097          	auipc	ra,0x0
    800034ec:	dc4080e7          	jalr	-572(ra) # 800032ac <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034f0:	015c87bb          	addw	a5,s9,s5
    800034f4:	00078a9b          	sext.w	s5,a5
    800034f8:	004b2703          	lw	a4,4(s6)
    800034fc:	06eaf363          	bgeu	s5,a4,80003562 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003500:	41fad79b          	sraiw	a5,s5,0x1f
    80003504:	0137d79b          	srliw	a5,a5,0x13
    80003508:	015787bb          	addw	a5,a5,s5
    8000350c:	40d7d79b          	sraiw	a5,a5,0xd
    80003510:	01cb2583          	lw	a1,28(s6)
    80003514:	9dbd                	addw	a1,a1,a5
    80003516:	855e                	mv	a0,s7
    80003518:	00000097          	auipc	ra,0x0
    8000351c:	c64080e7          	jalr	-924(ra) # 8000317c <bread>
    80003520:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003522:	004b2503          	lw	a0,4(s6)
    80003526:	000a849b          	sext.w	s1,s5
    8000352a:	8662                	mv	a2,s8
    8000352c:	faa4fde3          	bgeu	s1,a0,800034e6 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003530:	41f6579b          	sraiw	a5,a2,0x1f
    80003534:	01d7d69b          	srliw	a3,a5,0x1d
    80003538:	00c6873b          	addw	a4,a3,a2
    8000353c:	00777793          	andi	a5,a4,7
    80003540:	9f95                	subw	a5,a5,a3
    80003542:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003546:	4037571b          	sraiw	a4,a4,0x3
    8000354a:	00e906b3          	add	a3,s2,a4
    8000354e:	0586c683          	lbu	a3,88(a3)
    80003552:	00d7f5b3          	and	a1,a5,a3
    80003556:	d195                	beqz	a1,8000347a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003558:	2605                	addiw	a2,a2,1
    8000355a:	2485                	addiw	s1,s1,1
    8000355c:	fd4618e3          	bne	a2,s4,8000352c <balloc+0xee>
    80003560:	b759                	j	800034e6 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003562:	00005517          	auipc	a0,0x5
    80003566:	00e50513          	addi	a0,a0,14 # 80008570 <syscalls+0x120>
    8000356a:	ffffd097          	auipc	ra,0xffffd
    8000356e:	01e080e7          	jalr	30(ra) # 80000588 <printf>
  return 0;
    80003572:	4481                	li	s1,0
    80003574:	bf99                	j	800034ca <balloc+0x8c>

0000000080003576 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003576:	7179                	addi	sp,sp,-48
    80003578:	f406                	sd	ra,40(sp)
    8000357a:	f022                	sd	s0,32(sp)
    8000357c:	ec26                	sd	s1,24(sp)
    8000357e:	e84a                	sd	s2,16(sp)
    80003580:	e44e                	sd	s3,8(sp)
    80003582:	e052                	sd	s4,0(sp)
    80003584:	1800                	addi	s0,sp,48
    80003586:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003588:	47ad                	li	a5,11
    8000358a:	02b7e763          	bltu	a5,a1,800035b8 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000358e:	02059493          	slli	s1,a1,0x20
    80003592:	9081                	srli	s1,s1,0x20
    80003594:	048a                	slli	s1,s1,0x2
    80003596:	94aa                	add	s1,s1,a0
    80003598:	0504a903          	lw	s2,80(s1)
    8000359c:	06091e63          	bnez	s2,80003618 <bmap+0xa2>
      addr = balloc(ip->dev);
    800035a0:	4108                	lw	a0,0(a0)
    800035a2:	00000097          	auipc	ra,0x0
    800035a6:	e9c080e7          	jalr	-356(ra) # 8000343e <balloc>
    800035aa:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035ae:	06090563          	beqz	s2,80003618 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800035b2:	0524a823          	sw	s2,80(s1)
    800035b6:	a08d                	j	80003618 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800035b8:	ff45849b          	addiw	s1,a1,-12
    800035bc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035c0:	0ff00793          	li	a5,255
    800035c4:	08e7e563          	bltu	a5,a4,8000364e <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800035c8:	08052903          	lw	s2,128(a0)
    800035cc:	00091d63          	bnez	s2,800035e6 <bmap+0x70>
      addr = balloc(ip->dev);
    800035d0:	4108                	lw	a0,0(a0)
    800035d2:	00000097          	auipc	ra,0x0
    800035d6:	e6c080e7          	jalr	-404(ra) # 8000343e <balloc>
    800035da:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800035de:	02090d63          	beqz	s2,80003618 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800035e2:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800035e6:	85ca                	mv	a1,s2
    800035e8:	0009a503          	lw	a0,0(s3)
    800035ec:	00000097          	auipc	ra,0x0
    800035f0:	b90080e7          	jalr	-1136(ra) # 8000317c <bread>
    800035f4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035f6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800035fa:	02049593          	slli	a1,s1,0x20
    800035fe:	9181                	srli	a1,a1,0x20
    80003600:	058a                	slli	a1,a1,0x2
    80003602:	00b784b3          	add	s1,a5,a1
    80003606:	0004a903          	lw	s2,0(s1)
    8000360a:	02090063          	beqz	s2,8000362a <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000360e:	8552                	mv	a0,s4
    80003610:	00000097          	auipc	ra,0x0
    80003614:	c9c080e7          	jalr	-868(ra) # 800032ac <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003618:	854a                	mv	a0,s2
    8000361a:	70a2                	ld	ra,40(sp)
    8000361c:	7402                	ld	s0,32(sp)
    8000361e:	64e2                	ld	s1,24(sp)
    80003620:	6942                	ld	s2,16(sp)
    80003622:	69a2                	ld	s3,8(sp)
    80003624:	6a02                	ld	s4,0(sp)
    80003626:	6145                	addi	sp,sp,48
    80003628:	8082                	ret
      addr = balloc(ip->dev);
    8000362a:	0009a503          	lw	a0,0(s3)
    8000362e:	00000097          	auipc	ra,0x0
    80003632:	e10080e7          	jalr	-496(ra) # 8000343e <balloc>
    80003636:	0005091b          	sext.w	s2,a0
      if(addr){
    8000363a:	fc090ae3          	beqz	s2,8000360e <bmap+0x98>
        a[bn] = addr;
    8000363e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003642:	8552                	mv	a0,s4
    80003644:	00001097          	auipc	ra,0x1
    80003648:	eec080e7          	jalr	-276(ra) # 80004530 <log_write>
    8000364c:	b7c9                	j	8000360e <bmap+0x98>
  panic("bmap: out of range");
    8000364e:	00005517          	auipc	a0,0x5
    80003652:	f3a50513          	addi	a0,a0,-198 # 80008588 <syscalls+0x138>
    80003656:	ffffd097          	auipc	ra,0xffffd
    8000365a:	ee8080e7          	jalr	-280(ra) # 8000053e <panic>

000000008000365e <iget>:
{
    8000365e:	7179                	addi	sp,sp,-48
    80003660:	f406                	sd	ra,40(sp)
    80003662:	f022                	sd	s0,32(sp)
    80003664:	ec26                	sd	s1,24(sp)
    80003666:	e84a                	sd	s2,16(sp)
    80003668:	e44e                	sd	s3,8(sp)
    8000366a:	e052                	sd	s4,0(sp)
    8000366c:	1800                	addi	s0,sp,48
    8000366e:	89aa                	mv	s3,a0
    80003670:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003672:	00021517          	auipc	a0,0x21
    80003676:	aa650513          	addi	a0,a0,-1370 # 80024118 <itable>
    8000367a:	ffffd097          	auipc	ra,0xffffd
    8000367e:	55c080e7          	jalr	1372(ra) # 80000bd6 <acquire>
  empty = 0;
    80003682:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003684:	00021497          	auipc	s1,0x21
    80003688:	aac48493          	addi	s1,s1,-1364 # 80024130 <itable+0x18>
    8000368c:	00022697          	auipc	a3,0x22
    80003690:	53468693          	addi	a3,a3,1332 # 80025bc0 <log>
    80003694:	a039                	j	800036a2 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003696:	02090b63          	beqz	s2,800036cc <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000369a:	08848493          	addi	s1,s1,136
    8000369e:	02d48a63          	beq	s1,a3,800036d2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036a2:	449c                	lw	a5,8(s1)
    800036a4:	fef059e3          	blez	a5,80003696 <iget+0x38>
    800036a8:	4098                	lw	a4,0(s1)
    800036aa:	ff3716e3          	bne	a4,s3,80003696 <iget+0x38>
    800036ae:	40d8                	lw	a4,4(s1)
    800036b0:	ff4713e3          	bne	a4,s4,80003696 <iget+0x38>
      ip->ref++;
    800036b4:	2785                	addiw	a5,a5,1
    800036b6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800036b8:	00021517          	auipc	a0,0x21
    800036bc:	a6050513          	addi	a0,a0,-1440 # 80024118 <itable>
    800036c0:	ffffd097          	auipc	ra,0xffffd
    800036c4:	5ca080e7          	jalr	1482(ra) # 80000c8a <release>
      return ip;
    800036c8:	8926                	mv	s2,s1
    800036ca:	a03d                	j	800036f8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036cc:	f7f9                	bnez	a5,8000369a <iget+0x3c>
    800036ce:	8926                	mv	s2,s1
    800036d0:	b7e9                	j	8000369a <iget+0x3c>
  if(empty == 0)
    800036d2:	02090c63          	beqz	s2,8000370a <iget+0xac>
  ip->dev = dev;
    800036d6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800036da:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800036de:	4785                	li	a5,1
    800036e0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800036e4:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800036e8:	00021517          	auipc	a0,0x21
    800036ec:	a3050513          	addi	a0,a0,-1488 # 80024118 <itable>
    800036f0:	ffffd097          	auipc	ra,0xffffd
    800036f4:	59a080e7          	jalr	1434(ra) # 80000c8a <release>
}
    800036f8:	854a                	mv	a0,s2
    800036fa:	70a2                	ld	ra,40(sp)
    800036fc:	7402                	ld	s0,32(sp)
    800036fe:	64e2                	ld	s1,24(sp)
    80003700:	6942                	ld	s2,16(sp)
    80003702:	69a2                	ld	s3,8(sp)
    80003704:	6a02                	ld	s4,0(sp)
    80003706:	6145                	addi	sp,sp,48
    80003708:	8082                	ret
    panic("iget: no inodes");
    8000370a:	00005517          	auipc	a0,0x5
    8000370e:	e9650513          	addi	a0,a0,-362 # 800085a0 <syscalls+0x150>
    80003712:	ffffd097          	auipc	ra,0xffffd
    80003716:	e2c080e7          	jalr	-468(ra) # 8000053e <panic>

000000008000371a <fsinit>:
fsinit(int dev) {
    8000371a:	7179                	addi	sp,sp,-48
    8000371c:	f406                	sd	ra,40(sp)
    8000371e:	f022                	sd	s0,32(sp)
    80003720:	ec26                	sd	s1,24(sp)
    80003722:	e84a                	sd	s2,16(sp)
    80003724:	e44e                	sd	s3,8(sp)
    80003726:	1800                	addi	s0,sp,48
    80003728:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000372a:	4585                	li	a1,1
    8000372c:	00000097          	auipc	ra,0x0
    80003730:	a50080e7          	jalr	-1456(ra) # 8000317c <bread>
    80003734:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003736:	00021997          	auipc	s3,0x21
    8000373a:	9c298993          	addi	s3,s3,-1598 # 800240f8 <sb>
    8000373e:	02000613          	li	a2,32
    80003742:	05850593          	addi	a1,a0,88
    80003746:	854e                	mv	a0,s3
    80003748:	ffffd097          	auipc	ra,0xffffd
    8000374c:	5e6080e7          	jalr	1510(ra) # 80000d2e <memmove>
  brelse(bp);
    80003750:	8526                	mv	a0,s1
    80003752:	00000097          	auipc	ra,0x0
    80003756:	b5a080e7          	jalr	-1190(ra) # 800032ac <brelse>
  if(sb.magic != FSMAGIC)
    8000375a:	0009a703          	lw	a4,0(s3)
    8000375e:	102037b7          	lui	a5,0x10203
    80003762:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003766:	02f71263          	bne	a4,a5,8000378a <fsinit+0x70>
  initlog(dev, &sb);
    8000376a:	00021597          	auipc	a1,0x21
    8000376e:	98e58593          	addi	a1,a1,-1650 # 800240f8 <sb>
    80003772:	854a                	mv	a0,s2
    80003774:	00001097          	auipc	ra,0x1
    80003778:	b40080e7          	jalr	-1216(ra) # 800042b4 <initlog>
}
    8000377c:	70a2                	ld	ra,40(sp)
    8000377e:	7402                	ld	s0,32(sp)
    80003780:	64e2                	ld	s1,24(sp)
    80003782:	6942                	ld	s2,16(sp)
    80003784:	69a2                	ld	s3,8(sp)
    80003786:	6145                	addi	sp,sp,48
    80003788:	8082                	ret
    panic("invalid file system");
    8000378a:	00005517          	auipc	a0,0x5
    8000378e:	e2650513          	addi	a0,a0,-474 # 800085b0 <syscalls+0x160>
    80003792:	ffffd097          	auipc	ra,0xffffd
    80003796:	dac080e7          	jalr	-596(ra) # 8000053e <panic>

000000008000379a <iinit>:
{
    8000379a:	7179                	addi	sp,sp,-48
    8000379c:	f406                	sd	ra,40(sp)
    8000379e:	f022                	sd	s0,32(sp)
    800037a0:	ec26                	sd	s1,24(sp)
    800037a2:	e84a                	sd	s2,16(sp)
    800037a4:	e44e                	sd	s3,8(sp)
    800037a6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800037a8:	00005597          	auipc	a1,0x5
    800037ac:	e2058593          	addi	a1,a1,-480 # 800085c8 <syscalls+0x178>
    800037b0:	00021517          	auipc	a0,0x21
    800037b4:	96850513          	addi	a0,a0,-1688 # 80024118 <itable>
    800037b8:	ffffd097          	auipc	ra,0xffffd
    800037bc:	38e080e7          	jalr	910(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    800037c0:	00021497          	auipc	s1,0x21
    800037c4:	98048493          	addi	s1,s1,-1664 # 80024140 <itable+0x28>
    800037c8:	00022997          	auipc	s3,0x22
    800037cc:	40898993          	addi	s3,s3,1032 # 80025bd0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800037d0:	00005917          	auipc	s2,0x5
    800037d4:	e0090913          	addi	s2,s2,-512 # 800085d0 <syscalls+0x180>
    800037d8:	85ca                	mv	a1,s2
    800037da:	8526                	mv	a0,s1
    800037dc:	00001097          	auipc	ra,0x1
    800037e0:	e3a080e7          	jalr	-454(ra) # 80004616 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800037e4:	08848493          	addi	s1,s1,136
    800037e8:	ff3498e3          	bne	s1,s3,800037d8 <iinit+0x3e>
}
    800037ec:	70a2                	ld	ra,40(sp)
    800037ee:	7402                	ld	s0,32(sp)
    800037f0:	64e2                	ld	s1,24(sp)
    800037f2:	6942                	ld	s2,16(sp)
    800037f4:	69a2                	ld	s3,8(sp)
    800037f6:	6145                	addi	sp,sp,48
    800037f8:	8082                	ret

00000000800037fa <ialloc>:
{
    800037fa:	715d                	addi	sp,sp,-80
    800037fc:	e486                	sd	ra,72(sp)
    800037fe:	e0a2                	sd	s0,64(sp)
    80003800:	fc26                	sd	s1,56(sp)
    80003802:	f84a                	sd	s2,48(sp)
    80003804:	f44e                	sd	s3,40(sp)
    80003806:	f052                	sd	s4,32(sp)
    80003808:	ec56                	sd	s5,24(sp)
    8000380a:	e85a                	sd	s6,16(sp)
    8000380c:	e45e                	sd	s7,8(sp)
    8000380e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003810:	00021717          	auipc	a4,0x21
    80003814:	8f472703          	lw	a4,-1804(a4) # 80024104 <sb+0xc>
    80003818:	4785                	li	a5,1
    8000381a:	04e7fa63          	bgeu	a5,a4,8000386e <ialloc+0x74>
    8000381e:	8aaa                	mv	s5,a0
    80003820:	8bae                	mv	s7,a1
    80003822:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003824:	00021a17          	auipc	s4,0x21
    80003828:	8d4a0a13          	addi	s4,s4,-1836 # 800240f8 <sb>
    8000382c:	00048b1b          	sext.w	s6,s1
    80003830:	0044d793          	srli	a5,s1,0x4
    80003834:	018a2583          	lw	a1,24(s4)
    80003838:	9dbd                	addw	a1,a1,a5
    8000383a:	8556                	mv	a0,s5
    8000383c:	00000097          	auipc	ra,0x0
    80003840:	940080e7          	jalr	-1728(ra) # 8000317c <bread>
    80003844:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003846:	05850993          	addi	s3,a0,88
    8000384a:	00f4f793          	andi	a5,s1,15
    8000384e:	079a                	slli	a5,a5,0x6
    80003850:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003852:	00099783          	lh	a5,0(s3)
    80003856:	c3a1                	beqz	a5,80003896 <ialloc+0x9c>
    brelse(bp);
    80003858:	00000097          	auipc	ra,0x0
    8000385c:	a54080e7          	jalr	-1452(ra) # 800032ac <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003860:	0485                	addi	s1,s1,1
    80003862:	00ca2703          	lw	a4,12(s4)
    80003866:	0004879b          	sext.w	a5,s1
    8000386a:	fce7e1e3          	bltu	a5,a4,8000382c <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000386e:	00005517          	auipc	a0,0x5
    80003872:	d6a50513          	addi	a0,a0,-662 # 800085d8 <syscalls+0x188>
    80003876:	ffffd097          	auipc	ra,0xffffd
    8000387a:	d12080e7          	jalr	-750(ra) # 80000588 <printf>
  return 0;
    8000387e:	4501                	li	a0,0
}
    80003880:	60a6                	ld	ra,72(sp)
    80003882:	6406                	ld	s0,64(sp)
    80003884:	74e2                	ld	s1,56(sp)
    80003886:	7942                	ld	s2,48(sp)
    80003888:	79a2                	ld	s3,40(sp)
    8000388a:	7a02                	ld	s4,32(sp)
    8000388c:	6ae2                	ld	s5,24(sp)
    8000388e:	6b42                	ld	s6,16(sp)
    80003890:	6ba2                	ld	s7,8(sp)
    80003892:	6161                	addi	sp,sp,80
    80003894:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003896:	04000613          	li	a2,64
    8000389a:	4581                	li	a1,0
    8000389c:	854e                	mv	a0,s3
    8000389e:	ffffd097          	auipc	ra,0xffffd
    800038a2:	434080e7          	jalr	1076(ra) # 80000cd2 <memset>
      dip->type = type;
    800038a6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038aa:	854a                	mv	a0,s2
    800038ac:	00001097          	auipc	ra,0x1
    800038b0:	c84080e7          	jalr	-892(ra) # 80004530 <log_write>
      brelse(bp);
    800038b4:	854a                	mv	a0,s2
    800038b6:	00000097          	auipc	ra,0x0
    800038ba:	9f6080e7          	jalr	-1546(ra) # 800032ac <brelse>
      return iget(dev, inum);
    800038be:	85da                	mv	a1,s6
    800038c0:	8556                	mv	a0,s5
    800038c2:	00000097          	auipc	ra,0x0
    800038c6:	d9c080e7          	jalr	-612(ra) # 8000365e <iget>
    800038ca:	bf5d                	j	80003880 <ialloc+0x86>

00000000800038cc <iupdate>:
{
    800038cc:	1101                	addi	sp,sp,-32
    800038ce:	ec06                	sd	ra,24(sp)
    800038d0:	e822                	sd	s0,16(sp)
    800038d2:	e426                	sd	s1,8(sp)
    800038d4:	e04a                	sd	s2,0(sp)
    800038d6:	1000                	addi	s0,sp,32
    800038d8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038da:	415c                	lw	a5,4(a0)
    800038dc:	0047d79b          	srliw	a5,a5,0x4
    800038e0:	00021597          	auipc	a1,0x21
    800038e4:	8305a583          	lw	a1,-2000(a1) # 80024110 <sb+0x18>
    800038e8:	9dbd                	addw	a1,a1,a5
    800038ea:	4108                	lw	a0,0(a0)
    800038ec:	00000097          	auipc	ra,0x0
    800038f0:	890080e7          	jalr	-1904(ra) # 8000317c <bread>
    800038f4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038f6:	05850793          	addi	a5,a0,88
    800038fa:	40c8                	lw	a0,4(s1)
    800038fc:	893d                	andi	a0,a0,15
    800038fe:	051a                	slli	a0,a0,0x6
    80003900:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003902:	04449703          	lh	a4,68(s1)
    80003906:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000390a:	04649703          	lh	a4,70(s1)
    8000390e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003912:	04849703          	lh	a4,72(s1)
    80003916:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000391a:	04a49703          	lh	a4,74(s1)
    8000391e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003922:	44f8                	lw	a4,76(s1)
    80003924:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003926:	03400613          	li	a2,52
    8000392a:	05048593          	addi	a1,s1,80
    8000392e:	0531                	addi	a0,a0,12
    80003930:	ffffd097          	auipc	ra,0xffffd
    80003934:	3fe080e7          	jalr	1022(ra) # 80000d2e <memmove>
  log_write(bp);
    80003938:	854a                	mv	a0,s2
    8000393a:	00001097          	auipc	ra,0x1
    8000393e:	bf6080e7          	jalr	-1034(ra) # 80004530 <log_write>
  brelse(bp);
    80003942:	854a                	mv	a0,s2
    80003944:	00000097          	auipc	ra,0x0
    80003948:	968080e7          	jalr	-1688(ra) # 800032ac <brelse>
}
    8000394c:	60e2                	ld	ra,24(sp)
    8000394e:	6442                	ld	s0,16(sp)
    80003950:	64a2                	ld	s1,8(sp)
    80003952:	6902                	ld	s2,0(sp)
    80003954:	6105                	addi	sp,sp,32
    80003956:	8082                	ret

0000000080003958 <idup>:
{
    80003958:	1101                	addi	sp,sp,-32
    8000395a:	ec06                	sd	ra,24(sp)
    8000395c:	e822                	sd	s0,16(sp)
    8000395e:	e426                	sd	s1,8(sp)
    80003960:	1000                	addi	s0,sp,32
    80003962:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003964:	00020517          	auipc	a0,0x20
    80003968:	7b450513          	addi	a0,a0,1972 # 80024118 <itable>
    8000396c:	ffffd097          	auipc	ra,0xffffd
    80003970:	26a080e7          	jalr	618(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003974:	449c                	lw	a5,8(s1)
    80003976:	2785                	addiw	a5,a5,1
    80003978:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000397a:	00020517          	auipc	a0,0x20
    8000397e:	79e50513          	addi	a0,a0,1950 # 80024118 <itable>
    80003982:	ffffd097          	auipc	ra,0xffffd
    80003986:	308080e7          	jalr	776(ra) # 80000c8a <release>
}
    8000398a:	8526                	mv	a0,s1
    8000398c:	60e2                	ld	ra,24(sp)
    8000398e:	6442                	ld	s0,16(sp)
    80003990:	64a2                	ld	s1,8(sp)
    80003992:	6105                	addi	sp,sp,32
    80003994:	8082                	ret

0000000080003996 <ilock>:
{
    80003996:	1101                	addi	sp,sp,-32
    80003998:	ec06                	sd	ra,24(sp)
    8000399a:	e822                	sd	s0,16(sp)
    8000399c:	e426                	sd	s1,8(sp)
    8000399e:	e04a                	sd	s2,0(sp)
    800039a0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039a2:	c115                	beqz	a0,800039c6 <ilock+0x30>
    800039a4:	84aa                	mv	s1,a0
    800039a6:	451c                	lw	a5,8(a0)
    800039a8:	00f05f63          	blez	a5,800039c6 <ilock+0x30>
  acquiresleep(&ip->lock);
    800039ac:	0541                	addi	a0,a0,16
    800039ae:	00001097          	auipc	ra,0x1
    800039b2:	ca2080e7          	jalr	-862(ra) # 80004650 <acquiresleep>
  if(ip->valid == 0){
    800039b6:	40bc                	lw	a5,64(s1)
    800039b8:	cf99                	beqz	a5,800039d6 <ilock+0x40>
}
    800039ba:	60e2                	ld	ra,24(sp)
    800039bc:	6442                	ld	s0,16(sp)
    800039be:	64a2                	ld	s1,8(sp)
    800039c0:	6902                	ld	s2,0(sp)
    800039c2:	6105                	addi	sp,sp,32
    800039c4:	8082                	ret
    panic("ilock");
    800039c6:	00005517          	auipc	a0,0x5
    800039ca:	c2a50513          	addi	a0,a0,-982 # 800085f0 <syscalls+0x1a0>
    800039ce:	ffffd097          	auipc	ra,0xffffd
    800039d2:	b70080e7          	jalr	-1168(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039d6:	40dc                	lw	a5,4(s1)
    800039d8:	0047d79b          	srliw	a5,a5,0x4
    800039dc:	00020597          	auipc	a1,0x20
    800039e0:	7345a583          	lw	a1,1844(a1) # 80024110 <sb+0x18>
    800039e4:	9dbd                	addw	a1,a1,a5
    800039e6:	4088                	lw	a0,0(s1)
    800039e8:	fffff097          	auipc	ra,0xfffff
    800039ec:	794080e7          	jalr	1940(ra) # 8000317c <bread>
    800039f0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039f2:	05850593          	addi	a1,a0,88
    800039f6:	40dc                	lw	a5,4(s1)
    800039f8:	8bbd                	andi	a5,a5,15
    800039fa:	079a                	slli	a5,a5,0x6
    800039fc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039fe:	00059783          	lh	a5,0(a1)
    80003a02:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a06:	00259783          	lh	a5,2(a1)
    80003a0a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a0e:	00459783          	lh	a5,4(a1)
    80003a12:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a16:	00659783          	lh	a5,6(a1)
    80003a1a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a1e:	459c                	lw	a5,8(a1)
    80003a20:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a22:	03400613          	li	a2,52
    80003a26:	05b1                	addi	a1,a1,12
    80003a28:	05048513          	addi	a0,s1,80
    80003a2c:	ffffd097          	auipc	ra,0xffffd
    80003a30:	302080e7          	jalr	770(ra) # 80000d2e <memmove>
    brelse(bp);
    80003a34:	854a                	mv	a0,s2
    80003a36:	00000097          	auipc	ra,0x0
    80003a3a:	876080e7          	jalr	-1930(ra) # 800032ac <brelse>
    ip->valid = 1;
    80003a3e:	4785                	li	a5,1
    80003a40:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a42:	04449783          	lh	a5,68(s1)
    80003a46:	fbb5                	bnez	a5,800039ba <ilock+0x24>
      panic("ilock: no type");
    80003a48:	00005517          	auipc	a0,0x5
    80003a4c:	bb050513          	addi	a0,a0,-1104 # 800085f8 <syscalls+0x1a8>
    80003a50:	ffffd097          	auipc	ra,0xffffd
    80003a54:	aee080e7          	jalr	-1298(ra) # 8000053e <panic>

0000000080003a58 <iunlock>:
{
    80003a58:	1101                	addi	sp,sp,-32
    80003a5a:	ec06                	sd	ra,24(sp)
    80003a5c:	e822                	sd	s0,16(sp)
    80003a5e:	e426                	sd	s1,8(sp)
    80003a60:	e04a                	sd	s2,0(sp)
    80003a62:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a64:	c905                	beqz	a0,80003a94 <iunlock+0x3c>
    80003a66:	84aa                	mv	s1,a0
    80003a68:	01050913          	addi	s2,a0,16
    80003a6c:	854a                	mv	a0,s2
    80003a6e:	00001097          	auipc	ra,0x1
    80003a72:	c7c080e7          	jalr	-900(ra) # 800046ea <holdingsleep>
    80003a76:	cd19                	beqz	a0,80003a94 <iunlock+0x3c>
    80003a78:	449c                	lw	a5,8(s1)
    80003a7a:	00f05d63          	blez	a5,80003a94 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a7e:	854a                	mv	a0,s2
    80003a80:	00001097          	auipc	ra,0x1
    80003a84:	c26080e7          	jalr	-986(ra) # 800046a6 <releasesleep>
}
    80003a88:	60e2                	ld	ra,24(sp)
    80003a8a:	6442                	ld	s0,16(sp)
    80003a8c:	64a2                	ld	s1,8(sp)
    80003a8e:	6902                	ld	s2,0(sp)
    80003a90:	6105                	addi	sp,sp,32
    80003a92:	8082                	ret
    panic("iunlock");
    80003a94:	00005517          	auipc	a0,0x5
    80003a98:	b7450513          	addi	a0,a0,-1164 # 80008608 <syscalls+0x1b8>
    80003a9c:	ffffd097          	auipc	ra,0xffffd
    80003aa0:	aa2080e7          	jalr	-1374(ra) # 8000053e <panic>

0000000080003aa4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003aa4:	7179                	addi	sp,sp,-48
    80003aa6:	f406                	sd	ra,40(sp)
    80003aa8:	f022                	sd	s0,32(sp)
    80003aaa:	ec26                	sd	s1,24(sp)
    80003aac:	e84a                	sd	s2,16(sp)
    80003aae:	e44e                	sd	s3,8(sp)
    80003ab0:	e052                	sd	s4,0(sp)
    80003ab2:	1800                	addi	s0,sp,48
    80003ab4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ab6:	05050493          	addi	s1,a0,80
    80003aba:	08050913          	addi	s2,a0,128
    80003abe:	a021                	j	80003ac6 <itrunc+0x22>
    80003ac0:	0491                	addi	s1,s1,4
    80003ac2:	01248d63          	beq	s1,s2,80003adc <itrunc+0x38>
    if(ip->addrs[i]){
    80003ac6:	408c                	lw	a1,0(s1)
    80003ac8:	dde5                	beqz	a1,80003ac0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003aca:	0009a503          	lw	a0,0(s3)
    80003ace:	00000097          	auipc	ra,0x0
    80003ad2:	8f4080e7          	jalr	-1804(ra) # 800033c2 <bfree>
      ip->addrs[i] = 0;
    80003ad6:	0004a023          	sw	zero,0(s1)
    80003ada:	b7dd                	j	80003ac0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003adc:	0809a583          	lw	a1,128(s3)
    80003ae0:	e185                	bnez	a1,80003b00 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ae2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ae6:	854e                	mv	a0,s3
    80003ae8:	00000097          	auipc	ra,0x0
    80003aec:	de4080e7          	jalr	-540(ra) # 800038cc <iupdate>
}
    80003af0:	70a2                	ld	ra,40(sp)
    80003af2:	7402                	ld	s0,32(sp)
    80003af4:	64e2                	ld	s1,24(sp)
    80003af6:	6942                	ld	s2,16(sp)
    80003af8:	69a2                	ld	s3,8(sp)
    80003afa:	6a02                	ld	s4,0(sp)
    80003afc:	6145                	addi	sp,sp,48
    80003afe:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b00:	0009a503          	lw	a0,0(s3)
    80003b04:	fffff097          	auipc	ra,0xfffff
    80003b08:	678080e7          	jalr	1656(ra) # 8000317c <bread>
    80003b0c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b0e:	05850493          	addi	s1,a0,88
    80003b12:	45850913          	addi	s2,a0,1112
    80003b16:	a021                	j	80003b1e <itrunc+0x7a>
    80003b18:	0491                	addi	s1,s1,4
    80003b1a:	01248b63          	beq	s1,s2,80003b30 <itrunc+0x8c>
      if(a[j])
    80003b1e:	408c                	lw	a1,0(s1)
    80003b20:	dde5                	beqz	a1,80003b18 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b22:	0009a503          	lw	a0,0(s3)
    80003b26:	00000097          	auipc	ra,0x0
    80003b2a:	89c080e7          	jalr	-1892(ra) # 800033c2 <bfree>
    80003b2e:	b7ed                	j	80003b18 <itrunc+0x74>
    brelse(bp);
    80003b30:	8552                	mv	a0,s4
    80003b32:	fffff097          	auipc	ra,0xfffff
    80003b36:	77a080e7          	jalr	1914(ra) # 800032ac <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b3a:	0809a583          	lw	a1,128(s3)
    80003b3e:	0009a503          	lw	a0,0(s3)
    80003b42:	00000097          	auipc	ra,0x0
    80003b46:	880080e7          	jalr	-1920(ra) # 800033c2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b4a:	0809a023          	sw	zero,128(s3)
    80003b4e:	bf51                	j	80003ae2 <itrunc+0x3e>

0000000080003b50 <iput>:
{
    80003b50:	1101                	addi	sp,sp,-32
    80003b52:	ec06                	sd	ra,24(sp)
    80003b54:	e822                	sd	s0,16(sp)
    80003b56:	e426                	sd	s1,8(sp)
    80003b58:	e04a                	sd	s2,0(sp)
    80003b5a:	1000                	addi	s0,sp,32
    80003b5c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b5e:	00020517          	auipc	a0,0x20
    80003b62:	5ba50513          	addi	a0,a0,1466 # 80024118 <itable>
    80003b66:	ffffd097          	auipc	ra,0xffffd
    80003b6a:	070080e7          	jalr	112(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b6e:	4498                	lw	a4,8(s1)
    80003b70:	4785                	li	a5,1
    80003b72:	02f70363          	beq	a4,a5,80003b98 <iput+0x48>
  ip->ref--;
    80003b76:	449c                	lw	a5,8(s1)
    80003b78:	37fd                	addiw	a5,a5,-1
    80003b7a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b7c:	00020517          	auipc	a0,0x20
    80003b80:	59c50513          	addi	a0,a0,1436 # 80024118 <itable>
    80003b84:	ffffd097          	auipc	ra,0xffffd
    80003b88:	106080e7          	jalr	262(ra) # 80000c8a <release>
}
    80003b8c:	60e2                	ld	ra,24(sp)
    80003b8e:	6442                	ld	s0,16(sp)
    80003b90:	64a2                	ld	s1,8(sp)
    80003b92:	6902                	ld	s2,0(sp)
    80003b94:	6105                	addi	sp,sp,32
    80003b96:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b98:	40bc                	lw	a5,64(s1)
    80003b9a:	dff1                	beqz	a5,80003b76 <iput+0x26>
    80003b9c:	04a49783          	lh	a5,74(s1)
    80003ba0:	fbf9                	bnez	a5,80003b76 <iput+0x26>
    acquiresleep(&ip->lock);
    80003ba2:	01048913          	addi	s2,s1,16
    80003ba6:	854a                	mv	a0,s2
    80003ba8:	00001097          	auipc	ra,0x1
    80003bac:	aa8080e7          	jalr	-1368(ra) # 80004650 <acquiresleep>
    release(&itable.lock);
    80003bb0:	00020517          	auipc	a0,0x20
    80003bb4:	56850513          	addi	a0,a0,1384 # 80024118 <itable>
    80003bb8:	ffffd097          	auipc	ra,0xffffd
    80003bbc:	0d2080e7          	jalr	210(ra) # 80000c8a <release>
    itrunc(ip);
    80003bc0:	8526                	mv	a0,s1
    80003bc2:	00000097          	auipc	ra,0x0
    80003bc6:	ee2080e7          	jalr	-286(ra) # 80003aa4 <itrunc>
    ip->type = 0;
    80003bca:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003bce:	8526                	mv	a0,s1
    80003bd0:	00000097          	auipc	ra,0x0
    80003bd4:	cfc080e7          	jalr	-772(ra) # 800038cc <iupdate>
    ip->valid = 0;
    80003bd8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003bdc:	854a                	mv	a0,s2
    80003bde:	00001097          	auipc	ra,0x1
    80003be2:	ac8080e7          	jalr	-1336(ra) # 800046a6 <releasesleep>
    acquire(&itable.lock);
    80003be6:	00020517          	auipc	a0,0x20
    80003bea:	53250513          	addi	a0,a0,1330 # 80024118 <itable>
    80003bee:	ffffd097          	auipc	ra,0xffffd
    80003bf2:	fe8080e7          	jalr	-24(ra) # 80000bd6 <acquire>
    80003bf6:	b741                	j	80003b76 <iput+0x26>

0000000080003bf8 <iunlockput>:
{
    80003bf8:	1101                	addi	sp,sp,-32
    80003bfa:	ec06                	sd	ra,24(sp)
    80003bfc:	e822                	sd	s0,16(sp)
    80003bfe:	e426                	sd	s1,8(sp)
    80003c00:	1000                	addi	s0,sp,32
    80003c02:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c04:	00000097          	auipc	ra,0x0
    80003c08:	e54080e7          	jalr	-428(ra) # 80003a58 <iunlock>
  iput(ip);
    80003c0c:	8526                	mv	a0,s1
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	f42080e7          	jalr	-190(ra) # 80003b50 <iput>
}
    80003c16:	60e2                	ld	ra,24(sp)
    80003c18:	6442                	ld	s0,16(sp)
    80003c1a:	64a2                	ld	s1,8(sp)
    80003c1c:	6105                	addi	sp,sp,32
    80003c1e:	8082                	ret

0000000080003c20 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c20:	1141                	addi	sp,sp,-16
    80003c22:	e422                	sd	s0,8(sp)
    80003c24:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c26:	411c                	lw	a5,0(a0)
    80003c28:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c2a:	415c                	lw	a5,4(a0)
    80003c2c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c2e:	04451783          	lh	a5,68(a0)
    80003c32:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c36:	04a51783          	lh	a5,74(a0)
    80003c3a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c3e:	04c56783          	lwu	a5,76(a0)
    80003c42:	e99c                	sd	a5,16(a1)
}
    80003c44:	6422                	ld	s0,8(sp)
    80003c46:	0141                	addi	sp,sp,16
    80003c48:	8082                	ret

0000000080003c4a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c4a:	457c                	lw	a5,76(a0)
    80003c4c:	0ed7e963          	bltu	a5,a3,80003d3e <readi+0xf4>
{
    80003c50:	7159                	addi	sp,sp,-112
    80003c52:	f486                	sd	ra,104(sp)
    80003c54:	f0a2                	sd	s0,96(sp)
    80003c56:	eca6                	sd	s1,88(sp)
    80003c58:	e8ca                	sd	s2,80(sp)
    80003c5a:	e4ce                	sd	s3,72(sp)
    80003c5c:	e0d2                	sd	s4,64(sp)
    80003c5e:	fc56                	sd	s5,56(sp)
    80003c60:	f85a                	sd	s6,48(sp)
    80003c62:	f45e                	sd	s7,40(sp)
    80003c64:	f062                	sd	s8,32(sp)
    80003c66:	ec66                	sd	s9,24(sp)
    80003c68:	e86a                	sd	s10,16(sp)
    80003c6a:	e46e                	sd	s11,8(sp)
    80003c6c:	1880                	addi	s0,sp,112
    80003c6e:	8b2a                	mv	s6,a0
    80003c70:	8bae                	mv	s7,a1
    80003c72:	8a32                	mv	s4,a2
    80003c74:	84b6                	mv	s1,a3
    80003c76:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c78:	9f35                	addw	a4,a4,a3
    return 0;
    80003c7a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c7c:	0ad76063          	bltu	a4,a3,80003d1c <readi+0xd2>
  if(off + n > ip->size)
    80003c80:	00e7f463          	bgeu	a5,a4,80003c88 <readi+0x3e>
    n = ip->size - off;
    80003c84:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c88:	0a0a8963          	beqz	s5,80003d3a <readi+0xf0>
    80003c8c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c8e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c92:	5c7d                	li	s8,-1
    80003c94:	a82d                	j	80003cce <readi+0x84>
    80003c96:	020d1d93          	slli	s11,s10,0x20
    80003c9a:	020ddd93          	srli	s11,s11,0x20
    80003c9e:	05890793          	addi	a5,s2,88
    80003ca2:	86ee                	mv	a3,s11
    80003ca4:	963e                	add	a2,a2,a5
    80003ca6:	85d2                	mv	a1,s4
    80003ca8:	855e                	mv	a0,s7
    80003caa:	fffff097          	auipc	ra,0xfffff
    80003cae:	836080e7          	jalr	-1994(ra) # 800024e0 <either_copyout>
    80003cb2:	05850d63          	beq	a0,s8,80003d0c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003cb6:	854a                	mv	a0,s2
    80003cb8:	fffff097          	auipc	ra,0xfffff
    80003cbc:	5f4080e7          	jalr	1524(ra) # 800032ac <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cc0:	013d09bb          	addw	s3,s10,s3
    80003cc4:	009d04bb          	addw	s1,s10,s1
    80003cc8:	9a6e                	add	s4,s4,s11
    80003cca:	0559f763          	bgeu	s3,s5,80003d18 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003cce:	00a4d59b          	srliw	a1,s1,0xa
    80003cd2:	855a                	mv	a0,s6
    80003cd4:	00000097          	auipc	ra,0x0
    80003cd8:	8a2080e7          	jalr	-1886(ra) # 80003576 <bmap>
    80003cdc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ce0:	cd85                	beqz	a1,80003d18 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003ce2:	000b2503          	lw	a0,0(s6)
    80003ce6:	fffff097          	auipc	ra,0xfffff
    80003cea:	496080e7          	jalr	1174(ra) # 8000317c <bread>
    80003cee:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cf0:	3ff4f613          	andi	a2,s1,1023
    80003cf4:	40cc87bb          	subw	a5,s9,a2
    80003cf8:	413a873b          	subw	a4,s5,s3
    80003cfc:	8d3e                	mv	s10,a5
    80003cfe:	2781                	sext.w	a5,a5
    80003d00:	0007069b          	sext.w	a3,a4
    80003d04:	f8f6f9e3          	bgeu	a3,a5,80003c96 <readi+0x4c>
    80003d08:	8d3a                	mv	s10,a4
    80003d0a:	b771                	j	80003c96 <readi+0x4c>
      brelse(bp);
    80003d0c:	854a                	mv	a0,s2
    80003d0e:	fffff097          	auipc	ra,0xfffff
    80003d12:	59e080e7          	jalr	1438(ra) # 800032ac <brelse>
      tot = -1;
    80003d16:	59fd                	li	s3,-1
  }
  return tot;
    80003d18:	0009851b          	sext.w	a0,s3
}
    80003d1c:	70a6                	ld	ra,104(sp)
    80003d1e:	7406                	ld	s0,96(sp)
    80003d20:	64e6                	ld	s1,88(sp)
    80003d22:	6946                	ld	s2,80(sp)
    80003d24:	69a6                	ld	s3,72(sp)
    80003d26:	6a06                	ld	s4,64(sp)
    80003d28:	7ae2                	ld	s5,56(sp)
    80003d2a:	7b42                	ld	s6,48(sp)
    80003d2c:	7ba2                	ld	s7,40(sp)
    80003d2e:	7c02                	ld	s8,32(sp)
    80003d30:	6ce2                	ld	s9,24(sp)
    80003d32:	6d42                	ld	s10,16(sp)
    80003d34:	6da2                	ld	s11,8(sp)
    80003d36:	6165                	addi	sp,sp,112
    80003d38:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d3a:	89d6                	mv	s3,s5
    80003d3c:	bff1                	j	80003d18 <readi+0xce>
    return 0;
    80003d3e:	4501                	li	a0,0
}
    80003d40:	8082                	ret

0000000080003d42 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d42:	457c                	lw	a5,76(a0)
    80003d44:	10d7e863          	bltu	a5,a3,80003e54 <writei+0x112>
{
    80003d48:	7159                	addi	sp,sp,-112
    80003d4a:	f486                	sd	ra,104(sp)
    80003d4c:	f0a2                	sd	s0,96(sp)
    80003d4e:	eca6                	sd	s1,88(sp)
    80003d50:	e8ca                	sd	s2,80(sp)
    80003d52:	e4ce                	sd	s3,72(sp)
    80003d54:	e0d2                	sd	s4,64(sp)
    80003d56:	fc56                	sd	s5,56(sp)
    80003d58:	f85a                	sd	s6,48(sp)
    80003d5a:	f45e                	sd	s7,40(sp)
    80003d5c:	f062                	sd	s8,32(sp)
    80003d5e:	ec66                	sd	s9,24(sp)
    80003d60:	e86a                	sd	s10,16(sp)
    80003d62:	e46e                	sd	s11,8(sp)
    80003d64:	1880                	addi	s0,sp,112
    80003d66:	8aaa                	mv	s5,a0
    80003d68:	8bae                	mv	s7,a1
    80003d6a:	8a32                	mv	s4,a2
    80003d6c:	8936                	mv	s2,a3
    80003d6e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d70:	00e687bb          	addw	a5,a3,a4
    80003d74:	0ed7e263          	bltu	a5,a3,80003e58 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d78:	00043737          	lui	a4,0x43
    80003d7c:	0ef76063          	bltu	a4,a5,80003e5c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d80:	0c0b0863          	beqz	s6,80003e50 <writei+0x10e>
    80003d84:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d86:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d8a:	5c7d                	li	s8,-1
    80003d8c:	a091                	j	80003dd0 <writei+0x8e>
    80003d8e:	020d1d93          	slli	s11,s10,0x20
    80003d92:	020ddd93          	srli	s11,s11,0x20
    80003d96:	05848793          	addi	a5,s1,88
    80003d9a:	86ee                	mv	a3,s11
    80003d9c:	8652                	mv	a2,s4
    80003d9e:	85de                	mv	a1,s7
    80003da0:	953e                	add	a0,a0,a5
    80003da2:	ffffe097          	auipc	ra,0xffffe
    80003da6:	794080e7          	jalr	1940(ra) # 80002536 <either_copyin>
    80003daa:	07850263          	beq	a0,s8,80003e0e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003dae:	8526                	mv	a0,s1
    80003db0:	00000097          	auipc	ra,0x0
    80003db4:	780080e7          	jalr	1920(ra) # 80004530 <log_write>
    brelse(bp);
    80003db8:	8526                	mv	a0,s1
    80003dba:	fffff097          	auipc	ra,0xfffff
    80003dbe:	4f2080e7          	jalr	1266(ra) # 800032ac <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dc2:	013d09bb          	addw	s3,s10,s3
    80003dc6:	012d093b          	addw	s2,s10,s2
    80003dca:	9a6e                	add	s4,s4,s11
    80003dcc:	0569f663          	bgeu	s3,s6,80003e18 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003dd0:	00a9559b          	srliw	a1,s2,0xa
    80003dd4:	8556                	mv	a0,s5
    80003dd6:	fffff097          	auipc	ra,0xfffff
    80003dda:	7a0080e7          	jalr	1952(ra) # 80003576 <bmap>
    80003dde:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003de2:	c99d                	beqz	a1,80003e18 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003de4:	000aa503          	lw	a0,0(s5)
    80003de8:	fffff097          	auipc	ra,0xfffff
    80003dec:	394080e7          	jalr	916(ra) # 8000317c <bread>
    80003df0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003df2:	3ff97513          	andi	a0,s2,1023
    80003df6:	40ac87bb          	subw	a5,s9,a0
    80003dfa:	413b073b          	subw	a4,s6,s3
    80003dfe:	8d3e                	mv	s10,a5
    80003e00:	2781                	sext.w	a5,a5
    80003e02:	0007069b          	sext.w	a3,a4
    80003e06:	f8f6f4e3          	bgeu	a3,a5,80003d8e <writei+0x4c>
    80003e0a:	8d3a                	mv	s10,a4
    80003e0c:	b749                	j	80003d8e <writei+0x4c>
      brelse(bp);
    80003e0e:	8526                	mv	a0,s1
    80003e10:	fffff097          	auipc	ra,0xfffff
    80003e14:	49c080e7          	jalr	1180(ra) # 800032ac <brelse>
  }

  if(off > ip->size)
    80003e18:	04caa783          	lw	a5,76(s5)
    80003e1c:	0127f463          	bgeu	a5,s2,80003e24 <writei+0xe2>
    ip->size = off;
    80003e20:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e24:	8556                	mv	a0,s5
    80003e26:	00000097          	auipc	ra,0x0
    80003e2a:	aa6080e7          	jalr	-1370(ra) # 800038cc <iupdate>

  return tot;
    80003e2e:	0009851b          	sext.w	a0,s3
}
    80003e32:	70a6                	ld	ra,104(sp)
    80003e34:	7406                	ld	s0,96(sp)
    80003e36:	64e6                	ld	s1,88(sp)
    80003e38:	6946                	ld	s2,80(sp)
    80003e3a:	69a6                	ld	s3,72(sp)
    80003e3c:	6a06                	ld	s4,64(sp)
    80003e3e:	7ae2                	ld	s5,56(sp)
    80003e40:	7b42                	ld	s6,48(sp)
    80003e42:	7ba2                	ld	s7,40(sp)
    80003e44:	7c02                	ld	s8,32(sp)
    80003e46:	6ce2                	ld	s9,24(sp)
    80003e48:	6d42                	ld	s10,16(sp)
    80003e4a:	6da2                	ld	s11,8(sp)
    80003e4c:	6165                	addi	sp,sp,112
    80003e4e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e50:	89da                	mv	s3,s6
    80003e52:	bfc9                	j	80003e24 <writei+0xe2>
    return -1;
    80003e54:	557d                	li	a0,-1
}
    80003e56:	8082                	ret
    return -1;
    80003e58:	557d                	li	a0,-1
    80003e5a:	bfe1                	j	80003e32 <writei+0xf0>
    return -1;
    80003e5c:	557d                	li	a0,-1
    80003e5e:	bfd1                	j	80003e32 <writei+0xf0>

0000000080003e60 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e60:	1141                	addi	sp,sp,-16
    80003e62:	e406                	sd	ra,8(sp)
    80003e64:	e022                	sd	s0,0(sp)
    80003e66:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e68:	4639                	li	a2,14
    80003e6a:	ffffd097          	auipc	ra,0xffffd
    80003e6e:	f38080e7          	jalr	-200(ra) # 80000da2 <strncmp>
}
    80003e72:	60a2                	ld	ra,8(sp)
    80003e74:	6402                	ld	s0,0(sp)
    80003e76:	0141                	addi	sp,sp,16
    80003e78:	8082                	ret

0000000080003e7a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e7a:	7139                	addi	sp,sp,-64
    80003e7c:	fc06                	sd	ra,56(sp)
    80003e7e:	f822                	sd	s0,48(sp)
    80003e80:	f426                	sd	s1,40(sp)
    80003e82:	f04a                	sd	s2,32(sp)
    80003e84:	ec4e                	sd	s3,24(sp)
    80003e86:	e852                	sd	s4,16(sp)
    80003e88:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e8a:	04451703          	lh	a4,68(a0)
    80003e8e:	4785                	li	a5,1
    80003e90:	00f71a63          	bne	a4,a5,80003ea4 <dirlookup+0x2a>
    80003e94:	892a                	mv	s2,a0
    80003e96:	89ae                	mv	s3,a1
    80003e98:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e9a:	457c                	lw	a5,76(a0)
    80003e9c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e9e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ea0:	e79d                	bnez	a5,80003ece <dirlookup+0x54>
    80003ea2:	a8a5                	j	80003f1a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ea4:	00004517          	auipc	a0,0x4
    80003ea8:	76c50513          	addi	a0,a0,1900 # 80008610 <syscalls+0x1c0>
    80003eac:	ffffc097          	auipc	ra,0xffffc
    80003eb0:	692080e7          	jalr	1682(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003eb4:	00004517          	auipc	a0,0x4
    80003eb8:	77450513          	addi	a0,a0,1908 # 80008628 <syscalls+0x1d8>
    80003ebc:	ffffc097          	auipc	ra,0xffffc
    80003ec0:	682080e7          	jalr	1666(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ec4:	24c1                	addiw	s1,s1,16
    80003ec6:	04c92783          	lw	a5,76(s2)
    80003eca:	04f4f763          	bgeu	s1,a5,80003f18 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ece:	4741                	li	a4,16
    80003ed0:	86a6                	mv	a3,s1
    80003ed2:	fc040613          	addi	a2,s0,-64
    80003ed6:	4581                	li	a1,0
    80003ed8:	854a                	mv	a0,s2
    80003eda:	00000097          	auipc	ra,0x0
    80003ede:	d70080e7          	jalr	-656(ra) # 80003c4a <readi>
    80003ee2:	47c1                	li	a5,16
    80003ee4:	fcf518e3          	bne	a0,a5,80003eb4 <dirlookup+0x3a>
    if(de.inum == 0)
    80003ee8:	fc045783          	lhu	a5,-64(s0)
    80003eec:	dfe1                	beqz	a5,80003ec4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003eee:	fc240593          	addi	a1,s0,-62
    80003ef2:	854e                	mv	a0,s3
    80003ef4:	00000097          	auipc	ra,0x0
    80003ef8:	f6c080e7          	jalr	-148(ra) # 80003e60 <namecmp>
    80003efc:	f561                	bnez	a0,80003ec4 <dirlookup+0x4a>
      if(poff)
    80003efe:	000a0463          	beqz	s4,80003f06 <dirlookup+0x8c>
        *poff = off;
    80003f02:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f06:	fc045583          	lhu	a1,-64(s0)
    80003f0a:	00092503          	lw	a0,0(s2)
    80003f0e:	fffff097          	auipc	ra,0xfffff
    80003f12:	750080e7          	jalr	1872(ra) # 8000365e <iget>
    80003f16:	a011                	j	80003f1a <dirlookup+0xa0>
  return 0;
    80003f18:	4501                	li	a0,0
}
    80003f1a:	70e2                	ld	ra,56(sp)
    80003f1c:	7442                	ld	s0,48(sp)
    80003f1e:	74a2                	ld	s1,40(sp)
    80003f20:	7902                	ld	s2,32(sp)
    80003f22:	69e2                	ld	s3,24(sp)
    80003f24:	6a42                	ld	s4,16(sp)
    80003f26:	6121                	addi	sp,sp,64
    80003f28:	8082                	ret

0000000080003f2a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f2a:	711d                	addi	sp,sp,-96
    80003f2c:	ec86                	sd	ra,88(sp)
    80003f2e:	e8a2                	sd	s0,80(sp)
    80003f30:	e4a6                	sd	s1,72(sp)
    80003f32:	e0ca                	sd	s2,64(sp)
    80003f34:	fc4e                	sd	s3,56(sp)
    80003f36:	f852                	sd	s4,48(sp)
    80003f38:	f456                	sd	s5,40(sp)
    80003f3a:	f05a                	sd	s6,32(sp)
    80003f3c:	ec5e                	sd	s7,24(sp)
    80003f3e:	e862                	sd	s8,16(sp)
    80003f40:	e466                	sd	s9,8(sp)
    80003f42:	1080                	addi	s0,sp,96
    80003f44:	84aa                	mv	s1,a0
    80003f46:	8aae                	mv	s5,a1
    80003f48:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f4a:	00054703          	lbu	a4,0(a0)
    80003f4e:	02f00793          	li	a5,47
    80003f52:	02f70363          	beq	a4,a5,80003f78 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f56:	ffffe097          	auipc	ra,0xffffe
    80003f5a:	a56080e7          	jalr	-1450(ra) # 800019ac <myproc>
    80003f5e:	15053503          	ld	a0,336(a0)
    80003f62:	00000097          	auipc	ra,0x0
    80003f66:	9f6080e7          	jalr	-1546(ra) # 80003958 <idup>
    80003f6a:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f6c:	02f00913          	li	s2,47
  len = path - s;
    80003f70:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f72:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f74:	4b85                	li	s7,1
    80003f76:	a865                	j	8000402e <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f78:	4585                	li	a1,1
    80003f7a:	4505                	li	a0,1
    80003f7c:	fffff097          	auipc	ra,0xfffff
    80003f80:	6e2080e7          	jalr	1762(ra) # 8000365e <iget>
    80003f84:	89aa                	mv	s3,a0
    80003f86:	b7dd                	j	80003f6c <namex+0x42>
      iunlockput(ip);
    80003f88:	854e                	mv	a0,s3
    80003f8a:	00000097          	auipc	ra,0x0
    80003f8e:	c6e080e7          	jalr	-914(ra) # 80003bf8 <iunlockput>
      return 0;
    80003f92:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f94:	854e                	mv	a0,s3
    80003f96:	60e6                	ld	ra,88(sp)
    80003f98:	6446                	ld	s0,80(sp)
    80003f9a:	64a6                	ld	s1,72(sp)
    80003f9c:	6906                	ld	s2,64(sp)
    80003f9e:	79e2                	ld	s3,56(sp)
    80003fa0:	7a42                	ld	s4,48(sp)
    80003fa2:	7aa2                	ld	s5,40(sp)
    80003fa4:	7b02                	ld	s6,32(sp)
    80003fa6:	6be2                	ld	s7,24(sp)
    80003fa8:	6c42                	ld	s8,16(sp)
    80003faa:	6ca2                	ld	s9,8(sp)
    80003fac:	6125                	addi	sp,sp,96
    80003fae:	8082                	ret
      iunlock(ip);
    80003fb0:	854e                	mv	a0,s3
    80003fb2:	00000097          	auipc	ra,0x0
    80003fb6:	aa6080e7          	jalr	-1370(ra) # 80003a58 <iunlock>
      return ip;
    80003fba:	bfe9                	j	80003f94 <namex+0x6a>
      iunlockput(ip);
    80003fbc:	854e                	mv	a0,s3
    80003fbe:	00000097          	auipc	ra,0x0
    80003fc2:	c3a080e7          	jalr	-966(ra) # 80003bf8 <iunlockput>
      return 0;
    80003fc6:	89e6                	mv	s3,s9
    80003fc8:	b7f1                	j	80003f94 <namex+0x6a>
  len = path - s;
    80003fca:	40b48633          	sub	a2,s1,a1
    80003fce:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003fd2:	099c5463          	bge	s8,s9,8000405a <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003fd6:	4639                	li	a2,14
    80003fd8:	8552                	mv	a0,s4
    80003fda:	ffffd097          	auipc	ra,0xffffd
    80003fde:	d54080e7          	jalr	-684(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003fe2:	0004c783          	lbu	a5,0(s1)
    80003fe6:	01279763          	bne	a5,s2,80003ff4 <namex+0xca>
    path++;
    80003fea:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fec:	0004c783          	lbu	a5,0(s1)
    80003ff0:	ff278de3          	beq	a5,s2,80003fea <namex+0xc0>
    ilock(ip);
    80003ff4:	854e                	mv	a0,s3
    80003ff6:	00000097          	auipc	ra,0x0
    80003ffa:	9a0080e7          	jalr	-1632(ra) # 80003996 <ilock>
    if(ip->type != T_DIR){
    80003ffe:	04499783          	lh	a5,68(s3)
    80004002:	f97793e3          	bne	a5,s7,80003f88 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004006:	000a8563          	beqz	s5,80004010 <namex+0xe6>
    8000400a:	0004c783          	lbu	a5,0(s1)
    8000400e:	d3cd                	beqz	a5,80003fb0 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004010:	865a                	mv	a2,s6
    80004012:	85d2                	mv	a1,s4
    80004014:	854e                	mv	a0,s3
    80004016:	00000097          	auipc	ra,0x0
    8000401a:	e64080e7          	jalr	-412(ra) # 80003e7a <dirlookup>
    8000401e:	8caa                	mv	s9,a0
    80004020:	dd51                	beqz	a0,80003fbc <namex+0x92>
    iunlockput(ip);
    80004022:	854e                	mv	a0,s3
    80004024:	00000097          	auipc	ra,0x0
    80004028:	bd4080e7          	jalr	-1068(ra) # 80003bf8 <iunlockput>
    ip = next;
    8000402c:	89e6                	mv	s3,s9
  while(*path == '/')
    8000402e:	0004c783          	lbu	a5,0(s1)
    80004032:	05279763          	bne	a5,s2,80004080 <namex+0x156>
    path++;
    80004036:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004038:	0004c783          	lbu	a5,0(s1)
    8000403c:	ff278de3          	beq	a5,s2,80004036 <namex+0x10c>
  if(*path == 0)
    80004040:	c79d                	beqz	a5,8000406e <namex+0x144>
    path++;
    80004042:	85a6                	mv	a1,s1
  len = path - s;
    80004044:	8cda                	mv	s9,s6
    80004046:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004048:	01278963          	beq	a5,s2,8000405a <namex+0x130>
    8000404c:	dfbd                	beqz	a5,80003fca <namex+0xa0>
    path++;
    8000404e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004050:	0004c783          	lbu	a5,0(s1)
    80004054:	ff279ce3          	bne	a5,s2,8000404c <namex+0x122>
    80004058:	bf8d                	j	80003fca <namex+0xa0>
    memmove(name, s, len);
    8000405a:	2601                	sext.w	a2,a2
    8000405c:	8552                	mv	a0,s4
    8000405e:	ffffd097          	auipc	ra,0xffffd
    80004062:	cd0080e7          	jalr	-816(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004066:	9cd2                	add	s9,s9,s4
    80004068:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000406c:	bf9d                	j	80003fe2 <namex+0xb8>
  if(nameiparent){
    8000406e:	f20a83e3          	beqz	s5,80003f94 <namex+0x6a>
    iput(ip);
    80004072:	854e                	mv	a0,s3
    80004074:	00000097          	auipc	ra,0x0
    80004078:	adc080e7          	jalr	-1316(ra) # 80003b50 <iput>
    return 0;
    8000407c:	4981                	li	s3,0
    8000407e:	bf19                	j	80003f94 <namex+0x6a>
  if(*path == 0)
    80004080:	d7fd                	beqz	a5,8000406e <namex+0x144>
  while(*path != '/' && *path != 0)
    80004082:	0004c783          	lbu	a5,0(s1)
    80004086:	85a6                	mv	a1,s1
    80004088:	b7d1                	j	8000404c <namex+0x122>

000000008000408a <dirlink>:
{
    8000408a:	7139                	addi	sp,sp,-64
    8000408c:	fc06                	sd	ra,56(sp)
    8000408e:	f822                	sd	s0,48(sp)
    80004090:	f426                	sd	s1,40(sp)
    80004092:	f04a                	sd	s2,32(sp)
    80004094:	ec4e                	sd	s3,24(sp)
    80004096:	e852                	sd	s4,16(sp)
    80004098:	0080                	addi	s0,sp,64
    8000409a:	892a                	mv	s2,a0
    8000409c:	8a2e                	mv	s4,a1
    8000409e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040a0:	4601                	li	a2,0
    800040a2:	00000097          	auipc	ra,0x0
    800040a6:	dd8080e7          	jalr	-552(ra) # 80003e7a <dirlookup>
    800040aa:	e93d                	bnez	a0,80004120 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040ac:	04c92483          	lw	s1,76(s2)
    800040b0:	c49d                	beqz	s1,800040de <dirlink+0x54>
    800040b2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040b4:	4741                	li	a4,16
    800040b6:	86a6                	mv	a3,s1
    800040b8:	fc040613          	addi	a2,s0,-64
    800040bc:	4581                	li	a1,0
    800040be:	854a                	mv	a0,s2
    800040c0:	00000097          	auipc	ra,0x0
    800040c4:	b8a080e7          	jalr	-1142(ra) # 80003c4a <readi>
    800040c8:	47c1                	li	a5,16
    800040ca:	06f51163          	bne	a0,a5,8000412c <dirlink+0xa2>
    if(de.inum == 0)
    800040ce:	fc045783          	lhu	a5,-64(s0)
    800040d2:	c791                	beqz	a5,800040de <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040d4:	24c1                	addiw	s1,s1,16
    800040d6:	04c92783          	lw	a5,76(s2)
    800040da:	fcf4ede3          	bltu	s1,a5,800040b4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800040de:	4639                	li	a2,14
    800040e0:	85d2                	mv	a1,s4
    800040e2:	fc240513          	addi	a0,s0,-62
    800040e6:	ffffd097          	auipc	ra,0xffffd
    800040ea:	cf8080e7          	jalr	-776(ra) # 80000dde <strncpy>
  de.inum = inum;
    800040ee:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040f2:	4741                	li	a4,16
    800040f4:	86a6                	mv	a3,s1
    800040f6:	fc040613          	addi	a2,s0,-64
    800040fa:	4581                	li	a1,0
    800040fc:	854a                	mv	a0,s2
    800040fe:	00000097          	auipc	ra,0x0
    80004102:	c44080e7          	jalr	-956(ra) # 80003d42 <writei>
    80004106:	1541                	addi	a0,a0,-16
    80004108:	00a03533          	snez	a0,a0
    8000410c:	40a00533          	neg	a0,a0
}
    80004110:	70e2                	ld	ra,56(sp)
    80004112:	7442                	ld	s0,48(sp)
    80004114:	74a2                	ld	s1,40(sp)
    80004116:	7902                	ld	s2,32(sp)
    80004118:	69e2                	ld	s3,24(sp)
    8000411a:	6a42                	ld	s4,16(sp)
    8000411c:	6121                	addi	sp,sp,64
    8000411e:	8082                	ret
    iput(ip);
    80004120:	00000097          	auipc	ra,0x0
    80004124:	a30080e7          	jalr	-1488(ra) # 80003b50 <iput>
    return -1;
    80004128:	557d                	li	a0,-1
    8000412a:	b7dd                	j	80004110 <dirlink+0x86>
      panic("dirlink read");
    8000412c:	00004517          	auipc	a0,0x4
    80004130:	50c50513          	addi	a0,a0,1292 # 80008638 <syscalls+0x1e8>
    80004134:	ffffc097          	auipc	ra,0xffffc
    80004138:	40a080e7          	jalr	1034(ra) # 8000053e <panic>

000000008000413c <namei>:

struct inode*
namei(char *path)
{
    8000413c:	1101                	addi	sp,sp,-32
    8000413e:	ec06                	sd	ra,24(sp)
    80004140:	e822                	sd	s0,16(sp)
    80004142:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004144:	fe040613          	addi	a2,s0,-32
    80004148:	4581                	li	a1,0
    8000414a:	00000097          	auipc	ra,0x0
    8000414e:	de0080e7          	jalr	-544(ra) # 80003f2a <namex>
}
    80004152:	60e2                	ld	ra,24(sp)
    80004154:	6442                	ld	s0,16(sp)
    80004156:	6105                	addi	sp,sp,32
    80004158:	8082                	ret

000000008000415a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000415a:	1141                	addi	sp,sp,-16
    8000415c:	e406                	sd	ra,8(sp)
    8000415e:	e022                	sd	s0,0(sp)
    80004160:	0800                	addi	s0,sp,16
    80004162:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004164:	4585                	li	a1,1
    80004166:	00000097          	auipc	ra,0x0
    8000416a:	dc4080e7          	jalr	-572(ra) # 80003f2a <namex>
}
    8000416e:	60a2                	ld	ra,8(sp)
    80004170:	6402                	ld	s0,0(sp)
    80004172:	0141                	addi	sp,sp,16
    80004174:	8082                	ret

0000000080004176 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004176:	1101                	addi	sp,sp,-32
    80004178:	ec06                	sd	ra,24(sp)
    8000417a:	e822                	sd	s0,16(sp)
    8000417c:	e426                	sd	s1,8(sp)
    8000417e:	e04a                	sd	s2,0(sp)
    80004180:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004182:	00022917          	auipc	s2,0x22
    80004186:	a3e90913          	addi	s2,s2,-1474 # 80025bc0 <log>
    8000418a:	01892583          	lw	a1,24(s2)
    8000418e:	02892503          	lw	a0,40(s2)
    80004192:	fffff097          	auipc	ra,0xfffff
    80004196:	fea080e7          	jalr	-22(ra) # 8000317c <bread>
    8000419a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000419c:	02c92683          	lw	a3,44(s2)
    800041a0:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800041a2:	02d05763          	blez	a3,800041d0 <write_head+0x5a>
    800041a6:	00022797          	auipc	a5,0x22
    800041aa:	a4a78793          	addi	a5,a5,-1462 # 80025bf0 <log+0x30>
    800041ae:	05c50713          	addi	a4,a0,92
    800041b2:	36fd                	addiw	a3,a3,-1
    800041b4:	1682                	slli	a3,a3,0x20
    800041b6:	9281                	srli	a3,a3,0x20
    800041b8:	068a                	slli	a3,a3,0x2
    800041ba:	00022617          	auipc	a2,0x22
    800041be:	a3a60613          	addi	a2,a2,-1478 # 80025bf4 <log+0x34>
    800041c2:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800041c4:	4390                	lw	a2,0(a5)
    800041c6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041c8:	0791                	addi	a5,a5,4
    800041ca:	0711                	addi	a4,a4,4
    800041cc:	fed79ce3          	bne	a5,a3,800041c4 <write_head+0x4e>
  }
  bwrite(buf);
    800041d0:	8526                	mv	a0,s1
    800041d2:	fffff097          	auipc	ra,0xfffff
    800041d6:	09c080e7          	jalr	156(ra) # 8000326e <bwrite>
  brelse(buf);
    800041da:	8526                	mv	a0,s1
    800041dc:	fffff097          	auipc	ra,0xfffff
    800041e0:	0d0080e7          	jalr	208(ra) # 800032ac <brelse>
}
    800041e4:	60e2                	ld	ra,24(sp)
    800041e6:	6442                	ld	s0,16(sp)
    800041e8:	64a2                	ld	s1,8(sp)
    800041ea:	6902                	ld	s2,0(sp)
    800041ec:	6105                	addi	sp,sp,32
    800041ee:	8082                	ret

00000000800041f0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041f0:	00022797          	auipc	a5,0x22
    800041f4:	9fc7a783          	lw	a5,-1540(a5) # 80025bec <log+0x2c>
    800041f8:	0af05d63          	blez	a5,800042b2 <install_trans+0xc2>
{
    800041fc:	7139                	addi	sp,sp,-64
    800041fe:	fc06                	sd	ra,56(sp)
    80004200:	f822                	sd	s0,48(sp)
    80004202:	f426                	sd	s1,40(sp)
    80004204:	f04a                	sd	s2,32(sp)
    80004206:	ec4e                	sd	s3,24(sp)
    80004208:	e852                	sd	s4,16(sp)
    8000420a:	e456                	sd	s5,8(sp)
    8000420c:	e05a                	sd	s6,0(sp)
    8000420e:	0080                	addi	s0,sp,64
    80004210:	8b2a                	mv	s6,a0
    80004212:	00022a97          	auipc	s5,0x22
    80004216:	9dea8a93          	addi	s5,s5,-1570 # 80025bf0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000421a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000421c:	00022997          	auipc	s3,0x22
    80004220:	9a498993          	addi	s3,s3,-1628 # 80025bc0 <log>
    80004224:	a00d                	j	80004246 <install_trans+0x56>
    brelse(lbuf);
    80004226:	854a                	mv	a0,s2
    80004228:	fffff097          	auipc	ra,0xfffff
    8000422c:	084080e7          	jalr	132(ra) # 800032ac <brelse>
    brelse(dbuf);
    80004230:	8526                	mv	a0,s1
    80004232:	fffff097          	auipc	ra,0xfffff
    80004236:	07a080e7          	jalr	122(ra) # 800032ac <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000423a:	2a05                	addiw	s4,s4,1
    8000423c:	0a91                	addi	s5,s5,4
    8000423e:	02c9a783          	lw	a5,44(s3)
    80004242:	04fa5e63          	bge	s4,a5,8000429e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004246:	0189a583          	lw	a1,24(s3)
    8000424a:	014585bb          	addw	a1,a1,s4
    8000424e:	2585                	addiw	a1,a1,1
    80004250:	0289a503          	lw	a0,40(s3)
    80004254:	fffff097          	auipc	ra,0xfffff
    80004258:	f28080e7          	jalr	-216(ra) # 8000317c <bread>
    8000425c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000425e:	000aa583          	lw	a1,0(s5)
    80004262:	0289a503          	lw	a0,40(s3)
    80004266:	fffff097          	auipc	ra,0xfffff
    8000426a:	f16080e7          	jalr	-234(ra) # 8000317c <bread>
    8000426e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004270:	40000613          	li	a2,1024
    80004274:	05890593          	addi	a1,s2,88
    80004278:	05850513          	addi	a0,a0,88
    8000427c:	ffffd097          	auipc	ra,0xffffd
    80004280:	ab2080e7          	jalr	-1358(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004284:	8526                	mv	a0,s1
    80004286:	fffff097          	auipc	ra,0xfffff
    8000428a:	fe8080e7          	jalr	-24(ra) # 8000326e <bwrite>
    if(recovering == 0)
    8000428e:	f80b1ce3          	bnez	s6,80004226 <install_trans+0x36>
      bunpin(dbuf);
    80004292:	8526                	mv	a0,s1
    80004294:	fffff097          	auipc	ra,0xfffff
    80004298:	0f2080e7          	jalr	242(ra) # 80003386 <bunpin>
    8000429c:	b769                	j	80004226 <install_trans+0x36>
}
    8000429e:	70e2                	ld	ra,56(sp)
    800042a0:	7442                	ld	s0,48(sp)
    800042a2:	74a2                	ld	s1,40(sp)
    800042a4:	7902                	ld	s2,32(sp)
    800042a6:	69e2                	ld	s3,24(sp)
    800042a8:	6a42                	ld	s4,16(sp)
    800042aa:	6aa2                	ld	s5,8(sp)
    800042ac:	6b02                	ld	s6,0(sp)
    800042ae:	6121                	addi	sp,sp,64
    800042b0:	8082                	ret
    800042b2:	8082                	ret

00000000800042b4 <initlog>:
{
    800042b4:	7179                	addi	sp,sp,-48
    800042b6:	f406                	sd	ra,40(sp)
    800042b8:	f022                	sd	s0,32(sp)
    800042ba:	ec26                	sd	s1,24(sp)
    800042bc:	e84a                	sd	s2,16(sp)
    800042be:	e44e                	sd	s3,8(sp)
    800042c0:	1800                	addi	s0,sp,48
    800042c2:	892a                	mv	s2,a0
    800042c4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042c6:	00022497          	auipc	s1,0x22
    800042ca:	8fa48493          	addi	s1,s1,-1798 # 80025bc0 <log>
    800042ce:	00004597          	auipc	a1,0x4
    800042d2:	37a58593          	addi	a1,a1,890 # 80008648 <syscalls+0x1f8>
    800042d6:	8526                	mv	a0,s1
    800042d8:	ffffd097          	auipc	ra,0xffffd
    800042dc:	86e080e7          	jalr	-1938(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800042e0:	0149a583          	lw	a1,20(s3)
    800042e4:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800042e6:	0109a783          	lw	a5,16(s3)
    800042ea:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800042ec:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042f0:	854a                	mv	a0,s2
    800042f2:	fffff097          	auipc	ra,0xfffff
    800042f6:	e8a080e7          	jalr	-374(ra) # 8000317c <bread>
  log.lh.n = lh->n;
    800042fa:	4d34                	lw	a3,88(a0)
    800042fc:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042fe:	02d05563          	blez	a3,80004328 <initlog+0x74>
    80004302:	05c50793          	addi	a5,a0,92
    80004306:	00022717          	auipc	a4,0x22
    8000430a:	8ea70713          	addi	a4,a4,-1814 # 80025bf0 <log+0x30>
    8000430e:	36fd                	addiw	a3,a3,-1
    80004310:	1682                	slli	a3,a3,0x20
    80004312:	9281                	srli	a3,a3,0x20
    80004314:	068a                	slli	a3,a3,0x2
    80004316:	06050613          	addi	a2,a0,96
    8000431a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000431c:	4390                	lw	a2,0(a5)
    8000431e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004320:	0791                	addi	a5,a5,4
    80004322:	0711                	addi	a4,a4,4
    80004324:	fed79ce3          	bne	a5,a3,8000431c <initlog+0x68>
  brelse(buf);
    80004328:	fffff097          	auipc	ra,0xfffff
    8000432c:	f84080e7          	jalr	-124(ra) # 800032ac <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004330:	4505                	li	a0,1
    80004332:	00000097          	auipc	ra,0x0
    80004336:	ebe080e7          	jalr	-322(ra) # 800041f0 <install_trans>
  log.lh.n = 0;
    8000433a:	00022797          	auipc	a5,0x22
    8000433e:	8a07a923          	sw	zero,-1870(a5) # 80025bec <log+0x2c>
  write_head(); // clear the log
    80004342:	00000097          	auipc	ra,0x0
    80004346:	e34080e7          	jalr	-460(ra) # 80004176 <write_head>
}
    8000434a:	70a2                	ld	ra,40(sp)
    8000434c:	7402                	ld	s0,32(sp)
    8000434e:	64e2                	ld	s1,24(sp)
    80004350:	6942                	ld	s2,16(sp)
    80004352:	69a2                	ld	s3,8(sp)
    80004354:	6145                	addi	sp,sp,48
    80004356:	8082                	ret

0000000080004358 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004358:	1101                	addi	sp,sp,-32
    8000435a:	ec06                	sd	ra,24(sp)
    8000435c:	e822                	sd	s0,16(sp)
    8000435e:	e426                	sd	s1,8(sp)
    80004360:	e04a                	sd	s2,0(sp)
    80004362:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004364:	00022517          	auipc	a0,0x22
    80004368:	85c50513          	addi	a0,a0,-1956 # 80025bc0 <log>
    8000436c:	ffffd097          	auipc	ra,0xffffd
    80004370:	86a080e7          	jalr	-1942(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004374:	00022497          	auipc	s1,0x22
    80004378:	84c48493          	addi	s1,s1,-1972 # 80025bc0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000437c:	4979                	li	s2,30
    8000437e:	a039                	j	8000438c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004380:	85a6                	mv	a1,s1
    80004382:	8526                	mv	a0,s1
    80004384:	ffffe097          	auipc	ra,0xffffe
    80004388:	d48080e7          	jalr	-696(ra) # 800020cc <sleep>
    if(log.committing){
    8000438c:	50dc                	lw	a5,36(s1)
    8000438e:	fbed                	bnez	a5,80004380 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004390:	509c                	lw	a5,32(s1)
    80004392:	0017871b          	addiw	a4,a5,1
    80004396:	0007069b          	sext.w	a3,a4
    8000439a:	0027179b          	slliw	a5,a4,0x2
    8000439e:	9fb9                	addw	a5,a5,a4
    800043a0:	0017979b          	slliw	a5,a5,0x1
    800043a4:	54d8                	lw	a4,44(s1)
    800043a6:	9fb9                	addw	a5,a5,a4
    800043a8:	00f95963          	bge	s2,a5,800043ba <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043ac:	85a6                	mv	a1,s1
    800043ae:	8526                	mv	a0,s1
    800043b0:	ffffe097          	auipc	ra,0xffffe
    800043b4:	d1c080e7          	jalr	-740(ra) # 800020cc <sleep>
    800043b8:	bfd1                	j	8000438c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800043ba:	00022517          	auipc	a0,0x22
    800043be:	80650513          	addi	a0,a0,-2042 # 80025bc0 <log>
    800043c2:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800043c4:	ffffd097          	auipc	ra,0xffffd
    800043c8:	8c6080e7          	jalr	-1850(ra) # 80000c8a <release>
      break;
    }
  }
}
    800043cc:	60e2                	ld	ra,24(sp)
    800043ce:	6442                	ld	s0,16(sp)
    800043d0:	64a2                	ld	s1,8(sp)
    800043d2:	6902                	ld	s2,0(sp)
    800043d4:	6105                	addi	sp,sp,32
    800043d6:	8082                	ret

00000000800043d8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800043d8:	7139                	addi	sp,sp,-64
    800043da:	fc06                	sd	ra,56(sp)
    800043dc:	f822                	sd	s0,48(sp)
    800043de:	f426                	sd	s1,40(sp)
    800043e0:	f04a                	sd	s2,32(sp)
    800043e2:	ec4e                	sd	s3,24(sp)
    800043e4:	e852                	sd	s4,16(sp)
    800043e6:	e456                	sd	s5,8(sp)
    800043e8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800043ea:	00021497          	auipc	s1,0x21
    800043ee:	7d648493          	addi	s1,s1,2006 # 80025bc0 <log>
    800043f2:	8526                	mv	a0,s1
    800043f4:	ffffc097          	auipc	ra,0xffffc
    800043f8:	7e2080e7          	jalr	2018(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800043fc:	509c                	lw	a5,32(s1)
    800043fe:	37fd                	addiw	a5,a5,-1
    80004400:	0007891b          	sext.w	s2,a5
    80004404:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004406:	50dc                	lw	a5,36(s1)
    80004408:	e7b9                	bnez	a5,80004456 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000440a:	04091e63          	bnez	s2,80004466 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000440e:	00021497          	auipc	s1,0x21
    80004412:	7b248493          	addi	s1,s1,1970 # 80025bc0 <log>
    80004416:	4785                	li	a5,1
    80004418:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000441a:	8526                	mv	a0,s1
    8000441c:	ffffd097          	auipc	ra,0xffffd
    80004420:	86e080e7          	jalr	-1938(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004424:	54dc                	lw	a5,44(s1)
    80004426:	06f04763          	bgtz	a5,80004494 <end_op+0xbc>
    acquire(&log.lock);
    8000442a:	00021497          	auipc	s1,0x21
    8000442e:	79648493          	addi	s1,s1,1942 # 80025bc0 <log>
    80004432:	8526                	mv	a0,s1
    80004434:	ffffc097          	auipc	ra,0xffffc
    80004438:	7a2080e7          	jalr	1954(ra) # 80000bd6 <acquire>
    log.committing = 0;
    8000443c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004440:	8526                	mv	a0,s1
    80004442:	ffffe097          	auipc	ra,0xffffe
    80004446:	cee080e7          	jalr	-786(ra) # 80002130 <wakeup>
    release(&log.lock);
    8000444a:	8526                	mv	a0,s1
    8000444c:	ffffd097          	auipc	ra,0xffffd
    80004450:	83e080e7          	jalr	-1986(ra) # 80000c8a <release>
}
    80004454:	a03d                	j	80004482 <end_op+0xaa>
    panic("log.committing");
    80004456:	00004517          	auipc	a0,0x4
    8000445a:	1fa50513          	addi	a0,a0,506 # 80008650 <syscalls+0x200>
    8000445e:	ffffc097          	auipc	ra,0xffffc
    80004462:	0e0080e7          	jalr	224(ra) # 8000053e <panic>
    wakeup(&log);
    80004466:	00021497          	auipc	s1,0x21
    8000446a:	75a48493          	addi	s1,s1,1882 # 80025bc0 <log>
    8000446e:	8526                	mv	a0,s1
    80004470:	ffffe097          	auipc	ra,0xffffe
    80004474:	cc0080e7          	jalr	-832(ra) # 80002130 <wakeup>
  release(&log.lock);
    80004478:	8526                	mv	a0,s1
    8000447a:	ffffd097          	auipc	ra,0xffffd
    8000447e:	810080e7          	jalr	-2032(ra) # 80000c8a <release>
}
    80004482:	70e2                	ld	ra,56(sp)
    80004484:	7442                	ld	s0,48(sp)
    80004486:	74a2                	ld	s1,40(sp)
    80004488:	7902                	ld	s2,32(sp)
    8000448a:	69e2                	ld	s3,24(sp)
    8000448c:	6a42                	ld	s4,16(sp)
    8000448e:	6aa2                	ld	s5,8(sp)
    80004490:	6121                	addi	sp,sp,64
    80004492:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004494:	00021a97          	auipc	s5,0x21
    80004498:	75ca8a93          	addi	s5,s5,1884 # 80025bf0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000449c:	00021a17          	auipc	s4,0x21
    800044a0:	724a0a13          	addi	s4,s4,1828 # 80025bc0 <log>
    800044a4:	018a2583          	lw	a1,24(s4)
    800044a8:	012585bb          	addw	a1,a1,s2
    800044ac:	2585                	addiw	a1,a1,1
    800044ae:	028a2503          	lw	a0,40(s4)
    800044b2:	fffff097          	auipc	ra,0xfffff
    800044b6:	cca080e7          	jalr	-822(ra) # 8000317c <bread>
    800044ba:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044bc:	000aa583          	lw	a1,0(s5)
    800044c0:	028a2503          	lw	a0,40(s4)
    800044c4:	fffff097          	auipc	ra,0xfffff
    800044c8:	cb8080e7          	jalr	-840(ra) # 8000317c <bread>
    800044cc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800044ce:	40000613          	li	a2,1024
    800044d2:	05850593          	addi	a1,a0,88
    800044d6:	05848513          	addi	a0,s1,88
    800044da:	ffffd097          	auipc	ra,0xffffd
    800044de:	854080e7          	jalr	-1964(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800044e2:	8526                	mv	a0,s1
    800044e4:	fffff097          	auipc	ra,0xfffff
    800044e8:	d8a080e7          	jalr	-630(ra) # 8000326e <bwrite>
    brelse(from);
    800044ec:	854e                	mv	a0,s3
    800044ee:	fffff097          	auipc	ra,0xfffff
    800044f2:	dbe080e7          	jalr	-578(ra) # 800032ac <brelse>
    brelse(to);
    800044f6:	8526                	mv	a0,s1
    800044f8:	fffff097          	auipc	ra,0xfffff
    800044fc:	db4080e7          	jalr	-588(ra) # 800032ac <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004500:	2905                	addiw	s2,s2,1
    80004502:	0a91                	addi	s5,s5,4
    80004504:	02ca2783          	lw	a5,44(s4)
    80004508:	f8f94ee3          	blt	s2,a5,800044a4 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000450c:	00000097          	auipc	ra,0x0
    80004510:	c6a080e7          	jalr	-918(ra) # 80004176 <write_head>
    install_trans(0); // Now install writes to home locations
    80004514:	4501                	li	a0,0
    80004516:	00000097          	auipc	ra,0x0
    8000451a:	cda080e7          	jalr	-806(ra) # 800041f0 <install_trans>
    log.lh.n = 0;
    8000451e:	00021797          	auipc	a5,0x21
    80004522:	6c07a723          	sw	zero,1742(a5) # 80025bec <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004526:	00000097          	auipc	ra,0x0
    8000452a:	c50080e7          	jalr	-944(ra) # 80004176 <write_head>
    8000452e:	bdf5                	j	8000442a <end_op+0x52>

0000000080004530 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004530:	1101                	addi	sp,sp,-32
    80004532:	ec06                	sd	ra,24(sp)
    80004534:	e822                	sd	s0,16(sp)
    80004536:	e426                	sd	s1,8(sp)
    80004538:	e04a                	sd	s2,0(sp)
    8000453a:	1000                	addi	s0,sp,32
    8000453c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000453e:	00021917          	auipc	s2,0x21
    80004542:	68290913          	addi	s2,s2,1666 # 80025bc0 <log>
    80004546:	854a                	mv	a0,s2
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	68e080e7          	jalr	1678(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004550:	02c92603          	lw	a2,44(s2)
    80004554:	47f5                	li	a5,29
    80004556:	06c7c563          	blt	a5,a2,800045c0 <log_write+0x90>
    8000455a:	00021797          	auipc	a5,0x21
    8000455e:	6827a783          	lw	a5,1666(a5) # 80025bdc <log+0x1c>
    80004562:	37fd                	addiw	a5,a5,-1
    80004564:	04f65e63          	bge	a2,a5,800045c0 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004568:	00021797          	auipc	a5,0x21
    8000456c:	6787a783          	lw	a5,1656(a5) # 80025be0 <log+0x20>
    80004570:	06f05063          	blez	a5,800045d0 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004574:	4781                	li	a5,0
    80004576:	06c05563          	blez	a2,800045e0 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000457a:	44cc                	lw	a1,12(s1)
    8000457c:	00021717          	auipc	a4,0x21
    80004580:	67470713          	addi	a4,a4,1652 # 80025bf0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004584:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004586:	4314                	lw	a3,0(a4)
    80004588:	04b68c63          	beq	a3,a1,800045e0 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000458c:	2785                	addiw	a5,a5,1
    8000458e:	0711                	addi	a4,a4,4
    80004590:	fef61be3          	bne	a2,a5,80004586 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004594:	0621                	addi	a2,a2,8
    80004596:	060a                	slli	a2,a2,0x2
    80004598:	00021797          	auipc	a5,0x21
    8000459c:	62878793          	addi	a5,a5,1576 # 80025bc0 <log>
    800045a0:	963e                	add	a2,a2,a5
    800045a2:	44dc                	lw	a5,12(s1)
    800045a4:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800045a6:	8526                	mv	a0,s1
    800045a8:	fffff097          	auipc	ra,0xfffff
    800045ac:	da2080e7          	jalr	-606(ra) # 8000334a <bpin>
    log.lh.n++;
    800045b0:	00021717          	auipc	a4,0x21
    800045b4:	61070713          	addi	a4,a4,1552 # 80025bc0 <log>
    800045b8:	575c                	lw	a5,44(a4)
    800045ba:	2785                	addiw	a5,a5,1
    800045bc:	d75c                	sw	a5,44(a4)
    800045be:	a835                	j	800045fa <log_write+0xca>
    panic("too big a transaction");
    800045c0:	00004517          	auipc	a0,0x4
    800045c4:	0a050513          	addi	a0,a0,160 # 80008660 <syscalls+0x210>
    800045c8:	ffffc097          	auipc	ra,0xffffc
    800045cc:	f76080e7          	jalr	-138(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800045d0:	00004517          	auipc	a0,0x4
    800045d4:	0a850513          	addi	a0,a0,168 # 80008678 <syscalls+0x228>
    800045d8:	ffffc097          	auipc	ra,0xffffc
    800045dc:	f66080e7          	jalr	-154(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    800045e0:	00878713          	addi	a4,a5,8
    800045e4:	00271693          	slli	a3,a4,0x2
    800045e8:	00021717          	auipc	a4,0x21
    800045ec:	5d870713          	addi	a4,a4,1496 # 80025bc0 <log>
    800045f0:	9736                	add	a4,a4,a3
    800045f2:	44d4                	lw	a3,12(s1)
    800045f4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045f6:	faf608e3          	beq	a2,a5,800045a6 <log_write+0x76>
  }
  release(&log.lock);
    800045fa:	00021517          	auipc	a0,0x21
    800045fe:	5c650513          	addi	a0,a0,1478 # 80025bc0 <log>
    80004602:	ffffc097          	auipc	ra,0xffffc
    80004606:	688080e7          	jalr	1672(ra) # 80000c8a <release>
}
    8000460a:	60e2                	ld	ra,24(sp)
    8000460c:	6442                	ld	s0,16(sp)
    8000460e:	64a2                	ld	s1,8(sp)
    80004610:	6902                	ld	s2,0(sp)
    80004612:	6105                	addi	sp,sp,32
    80004614:	8082                	ret

0000000080004616 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004616:	1101                	addi	sp,sp,-32
    80004618:	ec06                	sd	ra,24(sp)
    8000461a:	e822                	sd	s0,16(sp)
    8000461c:	e426                	sd	s1,8(sp)
    8000461e:	e04a                	sd	s2,0(sp)
    80004620:	1000                	addi	s0,sp,32
    80004622:	84aa                	mv	s1,a0
    80004624:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004626:	00004597          	auipc	a1,0x4
    8000462a:	07258593          	addi	a1,a1,114 # 80008698 <syscalls+0x248>
    8000462e:	0521                	addi	a0,a0,8
    80004630:	ffffc097          	auipc	ra,0xffffc
    80004634:	516080e7          	jalr	1302(ra) # 80000b46 <initlock>
  lk->name = name;
    80004638:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000463c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004640:	0204a423          	sw	zero,40(s1)
}
    80004644:	60e2                	ld	ra,24(sp)
    80004646:	6442                	ld	s0,16(sp)
    80004648:	64a2                	ld	s1,8(sp)
    8000464a:	6902                	ld	s2,0(sp)
    8000464c:	6105                	addi	sp,sp,32
    8000464e:	8082                	ret

0000000080004650 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004650:	1101                	addi	sp,sp,-32
    80004652:	ec06                	sd	ra,24(sp)
    80004654:	e822                	sd	s0,16(sp)
    80004656:	e426                	sd	s1,8(sp)
    80004658:	e04a                	sd	s2,0(sp)
    8000465a:	1000                	addi	s0,sp,32
    8000465c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000465e:	00850913          	addi	s2,a0,8
    80004662:	854a                	mv	a0,s2
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	572080e7          	jalr	1394(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000466c:	409c                	lw	a5,0(s1)
    8000466e:	cb89                	beqz	a5,80004680 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004670:	85ca                	mv	a1,s2
    80004672:	8526                	mv	a0,s1
    80004674:	ffffe097          	auipc	ra,0xffffe
    80004678:	a58080e7          	jalr	-1448(ra) # 800020cc <sleep>
  while (lk->locked) {
    8000467c:	409c                	lw	a5,0(s1)
    8000467e:	fbed                	bnez	a5,80004670 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004680:	4785                	li	a5,1
    80004682:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004684:	ffffd097          	auipc	ra,0xffffd
    80004688:	328080e7          	jalr	808(ra) # 800019ac <myproc>
    8000468c:	591c                	lw	a5,48(a0)
    8000468e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004690:	854a                	mv	a0,s2
    80004692:	ffffc097          	auipc	ra,0xffffc
    80004696:	5f8080e7          	jalr	1528(ra) # 80000c8a <release>
}
    8000469a:	60e2                	ld	ra,24(sp)
    8000469c:	6442                	ld	s0,16(sp)
    8000469e:	64a2                	ld	s1,8(sp)
    800046a0:	6902                	ld	s2,0(sp)
    800046a2:	6105                	addi	sp,sp,32
    800046a4:	8082                	ret

00000000800046a6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046a6:	1101                	addi	sp,sp,-32
    800046a8:	ec06                	sd	ra,24(sp)
    800046aa:	e822                	sd	s0,16(sp)
    800046ac:	e426                	sd	s1,8(sp)
    800046ae:	e04a                	sd	s2,0(sp)
    800046b0:	1000                	addi	s0,sp,32
    800046b2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046b4:	00850913          	addi	s2,a0,8
    800046b8:	854a                	mv	a0,s2
    800046ba:	ffffc097          	auipc	ra,0xffffc
    800046be:	51c080e7          	jalr	1308(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    800046c2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046c6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800046ca:	8526                	mv	a0,s1
    800046cc:	ffffe097          	auipc	ra,0xffffe
    800046d0:	a64080e7          	jalr	-1436(ra) # 80002130 <wakeup>
  release(&lk->lk);
    800046d4:	854a                	mv	a0,s2
    800046d6:	ffffc097          	auipc	ra,0xffffc
    800046da:	5b4080e7          	jalr	1460(ra) # 80000c8a <release>
}
    800046de:	60e2                	ld	ra,24(sp)
    800046e0:	6442                	ld	s0,16(sp)
    800046e2:	64a2                	ld	s1,8(sp)
    800046e4:	6902                	ld	s2,0(sp)
    800046e6:	6105                	addi	sp,sp,32
    800046e8:	8082                	ret

00000000800046ea <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046ea:	7179                	addi	sp,sp,-48
    800046ec:	f406                	sd	ra,40(sp)
    800046ee:	f022                	sd	s0,32(sp)
    800046f0:	ec26                	sd	s1,24(sp)
    800046f2:	e84a                	sd	s2,16(sp)
    800046f4:	e44e                	sd	s3,8(sp)
    800046f6:	1800                	addi	s0,sp,48
    800046f8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046fa:	00850913          	addi	s2,a0,8
    800046fe:	854a                	mv	a0,s2
    80004700:	ffffc097          	auipc	ra,0xffffc
    80004704:	4d6080e7          	jalr	1238(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004708:	409c                	lw	a5,0(s1)
    8000470a:	ef99                	bnez	a5,80004728 <holdingsleep+0x3e>
    8000470c:	4481                	li	s1,0
  release(&lk->lk);
    8000470e:	854a                	mv	a0,s2
    80004710:	ffffc097          	auipc	ra,0xffffc
    80004714:	57a080e7          	jalr	1402(ra) # 80000c8a <release>
  return r;
}
    80004718:	8526                	mv	a0,s1
    8000471a:	70a2                	ld	ra,40(sp)
    8000471c:	7402                	ld	s0,32(sp)
    8000471e:	64e2                	ld	s1,24(sp)
    80004720:	6942                	ld	s2,16(sp)
    80004722:	69a2                	ld	s3,8(sp)
    80004724:	6145                	addi	sp,sp,48
    80004726:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004728:	0284a983          	lw	s3,40(s1)
    8000472c:	ffffd097          	auipc	ra,0xffffd
    80004730:	280080e7          	jalr	640(ra) # 800019ac <myproc>
    80004734:	5904                	lw	s1,48(a0)
    80004736:	413484b3          	sub	s1,s1,s3
    8000473a:	0014b493          	seqz	s1,s1
    8000473e:	bfc1                	j	8000470e <holdingsleep+0x24>

0000000080004740 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004740:	1141                	addi	sp,sp,-16
    80004742:	e406                	sd	ra,8(sp)
    80004744:	e022                	sd	s0,0(sp)
    80004746:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004748:	00004597          	auipc	a1,0x4
    8000474c:	f6058593          	addi	a1,a1,-160 # 800086a8 <syscalls+0x258>
    80004750:	00021517          	auipc	a0,0x21
    80004754:	5b850513          	addi	a0,a0,1464 # 80025d08 <ftable>
    80004758:	ffffc097          	auipc	ra,0xffffc
    8000475c:	3ee080e7          	jalr	1006(ra) # 80000b46 <initlock>
}
    80004760:	60a2                	ld	ra,8(sp)
    80004762:	6402                	ld	s0,0(sp)
    80004764:	0141                	addi	sp,sp,16
    80004766:	8082                	ret

0000000080004768 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004768:	1101                	addi	sp,sp,-32
    8000476a:	ec06                	sd	ra,24(sp)
    8000476c:	e822                	sd	s0,16(sp)
    8000476e:	e426                	sd	s1,8(sp)
    80004770:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004772:	00021517          	auipc	a0,0x21
    80004776:	59650513          	addi	a0,a0,1430 # 80025d08 <ftable>
    8000477a:	ffffc097          	auipc	ra,0xffffc
    8000477e:	45c080e7          	jalr	1116(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004782:	00021497          	auipc	s1,0x21
    80004786:	59e48493          	addi	s1,s1,1438 # 80025d20 <ftable+0x18>
    8000478a:	00022717          	auipc	a4,0x22
    8000478e:	53670713          	addi	a4,a4,1334 # 80026cc0 <disk>
    if(f->ref == 0){
    80004792:	40dc                	lw	a5,4(s1)
    80004794:	cf99                	beqz	a5,800047b2 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004796:	02848493          	addi	s1,s1,40
    8000479a:	fee49ce3          	bne	s1,a4,80004792 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000479e:	00021517          	auipc	a0,0x21
    800047a2:	56a50513          	addi	a0,a0,1386 # 80025d08 <ftable>
    800047a6:	ffffc097          	auipc	ra,0xffffc
    800047aa:	4e4080e7          	jalr	1252(ra) # 80000c8a <release>
  return 0;
    800047ae:	4481                	li	s1,0
    800047b0:	a819                	j	800047c6 <filealloc+0x5e>
      f->ref = 1;
    800047b2:	4785                	li	a5,1
    800047b4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047b6:	00021517          	auipc	a0,0x21
    800047ba:	55250513          	addi	a0,a0,1362 # 80025d08 <ftable>
    800047be:	ffffc097          	auipc	ra,0xffffc
    800047c2:	4cc080e7          	jalr	1228(ra) # 80000c8a <release>
}
    800047c6:	8526                	mv	a0,s1
    800047c8:	60e2                	ld	ra,24(sp)
    800047ca:	6442                	ld	s0,16(sp)
    800047cc:	64a2                	ld	s1,8(sp)
    800047ce:	6105                	addi	sp,sp,32
    800047d0:	8082                	ret

00000000800047d2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047d2:	1101                	addi	sp,sp,-32
    800047d4:	ec06                	sd	ra,24(sp)
    800047d6:	e822                	sd	s0,16(sp)
    800047d8:	e426                	sd	s1,8(sp)
    800047da:	1000                	addi	s0,sp,32
    800047dc:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047de:	00021517          	auipc	a0,0x21
    800047e2:	52a50513          	addi	a0,a0,1322 # 80025d08 <ftable>
    800047e6:	ffffc097          	auipc	ra,0xffffc
    800047ea:	3f0080e7          	jalr	1008(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800047ee:	40dc                	lw	a5,4(s1)
    800047f0:	02f05263          	blez	a5,80004814 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047f4:	2785                	addiw	a5,a5,1
    800047f6:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047f8:	00021517          	auipc	a0,0x21
    800047fc:	51050513          	addi	a0,a0,1296 # 80025d08 <ftable>
    80004800:	ffffc097          	auipc	ra,0xffffc
    80004804:	48a080e7          	jalr	1162(ra) # 80000c8a <release>
  return f;
}
    80004808:	8526                	mv	a0,s1
    8000480a:	60e2                	ld	ra,24(sp)
    8000480c:	6442                	ld	s0,16(sp)
    8000480e:	64a2                	ld	s1,8(sp)
    80004810:	6105                	addi	sp,sp,32
    80004812:	8082                	ret
    panic("filedup");
    80004814:	00004517          	auipc	a0,0x4
    80004818:	e9c50513          	addi	a0,a0,-356 # 800086b0 <syscalls+0x260>
    8000481c:	ffffc097          	auipc	ra,0xffffc
    80004820:	d22080e7          	jalr	-734(ra) # 8000053e <panic>

0000000080004824 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004824:	7139                	addi	sp,sp,-64
    80004826:	fc06                	sd	ra,56(sp)
    80004828:	f822                	sd	s0,48(sp)
    8000482a:	f426                	sd	s1,40(sp)
    8000482c:	f04a                	sd	s2,32(sp)
    8000482e:	ec4e                	sd	s3,24(sp)
    80004830:	e852                	sd	s4,16(sp)
    80004832:	e456                	sd	s5,8(sp)
    80004834:	0080                	addi	s0,sp,64
    80004836:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004838:	00021517          	auipc	a0,0x21
    8000483c:	4d050513          	addi	a0,a0,1232 # 80025d08 <ftable>
    80004840:	ffffc097          	auipc	ra,0xffffc
    80004844:	396080e7          	jalr	918(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004848:	40dc                	lw	a5,4(s1)
    8000484a:	06f05163          	blez	a5,800048ac <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000484e:	37fd                	addiw	a5,a5,-1
    80004850:	0007871b          	sext.w	a4,a5
    80004854:	c0dc                	sw	a5,4(s1)
    80004856:	06e04363          	bgtz	a4,800048bc <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000485a:	0004a903          	lw	s2,0(s1)
    8000485e:	0094ca83          	lbu	s5,9(s1)
    80004862:	0104ba03          	ld	s4,16(s1)
    80004866:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000486a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000486e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004872:	00021517          	auipc	a0,0x21
    80004876:	49650513          	addi	a0,a0,1174 # 80025d08 <ftable>
    8000487a:	ffffc097          	auipc	ra,0xffffc
    8000487e:	410080e7          	jalr	1040(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004882:	4785                	li	a5,1
    80004884:	04f90d63          	beq	s2,a5,800048de <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004888:	3979                	addiw	s2,s2,-2
    8000488a:	4785                	li	a5,1
    8000488c:	0527e063          	bltu	a5,s2,800048cc <fileclose+0xa8>
    begin_op();
    80004890:	00000097          	auipc	ra,0x0
    80004894:	ac8080e7          	jalr	-1336(ra) # 80004358 <begin_op>
    iput(ff.ip);
    80004898:	854e                	mv	a0,s3
    8000489a:	fffff097          	auipc	ra,0xfffff
    8000489e:	2b6080e7          	jalr	694(ra) # 80003b50 <iput>
    end_op();
    800048a2:	00000097          	auipc	ra,0x0
    800048a6:	b36080e7          	jalr	-1226(ra) # 800043d8 <end_op>
    800048aa:	a00d                	j	800048cc <fileclose+0xa8>
    panic("fileclose");
    800048ac:	00004517          	auipc	a0,0x4
    800048b0:	e0c50513          	addi	a0,a0,-500 # 800086b8 <syscalls+0x268>
    800048b4:	ffffc097          	auipc	ra,0xffffc
    800048b8:	c8a080e7          	jalr	-886(ra) # 8000053e <panic>
    release(&ftable.lock);
    800048bc:	00021517          	auipc	a0,0x21
    800048c0:	44c50513          	addi	a0,a0,1100 # 80025d08 <ftable>
    800048c4:	ffffc097          	auipc	ra,0xffffc
    800048c8:	3c6080e7          	jalr	966(ra) # 80000c8a <release>
  }
}
    800048cc:	70e2                	ld	ra,56(sp)
    800048ce:	7442                	ld	s0,48(sp)
    800048d0:	74a2                	ld	s1,40(sp)
    800048d2:	7902                	ld	s2,32(sp)
    800048d4:	69e2                	ld	s3,24(sp)
    800048d6:	6a42                	ld	s4,16(sp)
    800048d8:	6aa2                	ld	s5,8(sp)
    800048da:	6121                	addi	sp,sp,64
    800048dc:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048de:	85d6                	mv	a1,s5
    800048e0:	8552                	mv	a0,s4
    800048e2:	00000097          	auipc	ra,0x0
    800048e6:	34c080e7          	jalr	844(ra) # 80004c2e <pipeclose>
    800048ea:	b7cd                	j	800048cc <fileclose+0xa8>

00000000800048ec <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048ec:	715d                	addi	sp,sp,-80
    800048ee:	e486                	sd	ra,72(sp)
    800048f0:	e0a2                	sd	s0,64(sp)
    800048f2:	fc26                	sd	s1,56(sp)
    800048f4:	f84a                	sd	s2,48(sp)
    800048f6:	f44e                	sd	s3,40(sp)
    800048f8:	0880                	addi	s0,sp,80
    800048fa:	84aa                	mv	s1,a0
    800048fc:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048fe:	ffffd097          	auipc	ra,0xffffd
    80004902:	0ae080e7          	jalr	174(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004906:	409c                	lw	a5,0(s1)
    80004908:	37f9                	addiw	a5,a5,-2
    8000490a:	4705                	li	a4,1
    8000490c:	04f76763          	bltu	a4,a5,8000495a <filestat+0x6e>
    80004910:	892a                	mv	s2,a0
    ilock(f->ip);
    80004912:	6c88                	ld	a0,24(s1)
    80004914:	fffff097          	auipc	ra,0xfffff
    80004918:	082080e7          	jalr	130(ra) # 80003996 <ilock>
    stati(f->ip, &st);
    8000491c:	fb840593          	addi	a1,s0,-72
    80004920:	6c88                	ld	a0,24(s1)
    80004922:	fffff097          	auipc	ra,0xfffff
    80004926:	2fe080e7          	jalr	766(ra) # 80003c20 <stati>
    iunlock(f->ip);
    8000492a:	6c88                	ld	a0,24(s1)
    8000492c:	fffff097          	auipc	ra,0xfffff
    80004930:	12c080e7          	jalr	300(ra) # 80003a58 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004934:	46e1                	li	a3,24
    80004936:	fb840613          	addi	a2,s0,-72
    8000493a:	85ce                	mv	a1,s3
    8000493c:	05093503          	ld	a0,80(s2)
    80004940:	ffffd097          	auipc	ra,0xffffd
    80004944:	d28080e7          	jalr	-728(ra) # 80001668 <copyout>
    80004948:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000494c:	60a6                	ld	ra,72(sp)
    8000494e:	6406                	ld	s0,64(sp)
    80004950:	74e2                	ld	s1,56(sp)
    80004952:	7942                	ld	s2,48(sp)
    80004954:	79a2                	ld	s3,40(sp)
    80004956:	6161                	addi	sp,sp,80
    80004958:	8082                	ret
  return -1;
    8000495a:	557d                	li	a0,-1
    8000495c:	bfc5                	j	8000494c <filestat+0x60>

000000008000495e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000495e:	7179                	addi	sp,sp,-48
    80004960:	f406                	sd	ra,40(sp)
    80004962:	f022                	sd	s0,32(sp)
    80004964:	ec26                	sd	s1,24(sp)
    80004966:	e84a                	sd	s2,16(sp)
    80004968:	e44e                	sd	s3,8(sp)
    8000496a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000496c:	00854783          	lbu	a5,8(a0)
    80004970:	c3d5                	beqz	a5,80004a14 <fileread+0xb6>
    80004972:	84aa                	mv	s1,a0
    80004974:	89ae                	mv	s3,a1
    80004976:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004978:	411c                	lw	a5,0(a0)
    8000497a:	4705                	li	a4,1
    8000497c:	04e78963          	beq	a5,a4,800049ce <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004980:	470d                	li	a4,3
    80004982:	04e78d63          	beq	a5,a4,800049dc <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004986:	4709                	li	a4,2
    80004988:	06e79e63          	bne	a5,a4,80004a04 <fileread+0xa6>
    ilock(f->ip);
    8000498c:	6d08                	ld	a0,24(a0)
    8000498e:	fffff097          	auipc	ra,0xfffff
    80004992:	008080e7          	jalr	8(ra) # 80003996 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004996:	874a                	mv	a4,s2
    80004998:	5094                	lw	a3,32(s1)
    8000499a:	864e                	mv	a2,s3
    8000499c:	4585                	li	a1,1
    8000499e:	6c88                	ld	a0,24(s1)
    800049a0:	fffff097          	auipc	ra,0xfffff
    800049a4:	2aa080e7          	jalr	682(ra) # 80003c4a <readi>
    800049a8:	892a                	mv	s2,a0
    800049aa:	00a05563          	blez	a0,800049b4 <fileread+0x56>
      f->off += r;
    800049ae:	509c                	lw	a5,32(s1)
    800049b0:	9fa9                	addw	a5,a5,a0
    800049b2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049b4:	6c88                	ld	a0,24(s1)
    800049b6:	fffff097          	auipc	ra,0xfffff
    800049ba:	0a2080e7          	jalr	162(ra) # 80003a58 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049be:	854a                	mv	a0,s2
    800049c0:	70a2                	ld	ra,40(sp)
    800049c2:	7402                	ld	s0,32(sp)
    800049c4:	64e2                	ld	s1,24(sp)
    800049c6:	6942                	ld	s2,16(sp)
    800049c8:	69a2                	ld	s3,8(sp)
    800049ca:	6145                	addi	sp,sp,48
    800049cc:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049ce:	6908                	ld	a0,16(a0)
    800049d0:	00000097          	auipc	ra,0x0
    800049d4:	3c6080e7          	jalr	966(ra) # 80004d96 <piperead>
    800049d8:	892a                	mv	s2,a0
    800049da:	b7d5                	j	800049be <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049dc:	02451783          	lh	a5,36(a0)
    800049e0:	03079693          	slli	a3,a5,0x30
    800049e4:	92c1                	srli	a3,a3,0x30
    800049e6:	4725                	li	a4,9
    800049e8:	02d76863          	bltu	a4,a3,80004a18 <fileread+0xba>
    800049ec:	0792                	slli	a5,a5,0x4
    800049ee:	00021717          	auipc	a4,0x21
    800049f2:	27a70713          	addi	a4,a4,634 # 80025c68 <devsw>
    800049f6:	97ba                	add	a5,a5,a4
    800049f8:	639c                	ld	a5,0(a5)
    800049fa:	c38d                	beqz	a5,80004a1c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800049fc:	4505                	li	a0,1
    800049fe:	9782                	jalr	a5
    80004a00:	892a                	mv	s2,a0
    80004a02:	bf75                	j	800049be <fileread+0x60>
    panic("fileread");
    80004a04:	00004517          	auipc	a0,0x4
    80004a08:	cc450513          	addi	a0,a0,-828 # 800086c8 <syscalls+0x278>
    80004a0c:	ffffc097          	auipc	ra,0xffffc
    80004a10:	b32080e7          	jalr	-1230(ra) # 8000053e <panic>
    return -1;
    80004a14:	597d                	li	s2,-1
    80004a16:	b765                	j	800049be <fileread+0x60>
      return -1;
    80004a18:	597d                	li	s2,-1
    80004a1a:	b755                	j	800049be <fileread+0x60>
    80004a1c:	597d                	li	s2,-1
    80004a1e:	b745                	j	800049be <fileread+0x60>

0000000080004a20 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a20:	715d                	addi	sp,sp,-80
    80004a22:	e486                	sd	ra,72(sp)
    80004a24:	e0a2                	sd	s0,64(sp)
    80004a26:	fc26                	sd	s1,56(sp)
    80004a28:	f84a                	sd	s2,48(sp)
    80004a2a:	f44e                	sd	s3,40(sp)
    80004a2c:	f052                	sd	s4,32(sp)
    80004a2e:	ec56                	sd	s5,24(sp)
    80004a30:	e85a                	sd	s6,16(sp)
    80004a32:	e45e                	sd	s7,8(sp)
    80004a34:	e062                	sd	s8,0(sp)
    80004a36:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004a38:	00954783          	lbu	a5,9(a0)
    80004a3c:	10078663          	beqz	a5,80004b48 <filewrite+0x128>
    80004a40:	892a                	mv	s2,a0
    80004a42:	8aae                	mv	s5,a1
    80004a44:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a46:	411c                	lw	a5,0(a0)
    80004a48:	4705                	li	a4,1
    80004a4a:	02e78263          	beq	a5,a4,80004a6e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a4e:	470d                	li	a4,3
    80004a50:	02e78663          	beq	a5,a4,80004a7c <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a54:	4709                	li	a4,2
    80004a56:	0ee79163          	bne	a5,a4,80004b38 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a5a:	0ac05d63          	blez	a2,80004b14 <filewrite+0xf4>
    int i = 0;
    80004a5e:	4981                	li	s3,0
    80004a60:	6b05                	lui	s6,0x1
    80004a62:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a66:	6b85                	lui	s7,0x1
    80004a68:	c00b8b9b          	addiw	s7,s7,-1024
    80004a6c:	a861                	j	80004b04 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004a6e:	6908                	ld	a0,16(a0)
    80004a70:	00000097          	auipc	ra,0x0
    80004a74:	22e080e7          	jalr	558(ra) # 80004c9e <pipewrite>
    80004a78:	8a2a                	mv	s4,a0
    80004a7a:	a045                	j	80004b1a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a7c:	02451783          	lh	a5,36(a0)
    80004a80:	03079693          	slli	a3,a5,0x30
    80004a84:	92c1                	srli	a3,a3,0x30
    80004a86:	4725                	li	a4,9
    80004a88:	0cd76263          	bltu	a4,a3,80004b4c <filewrite+0x12c>
    80004a8c:	0792                	slli	a5,a5,0x4
    80004a8e:	00021717          	auipc	a4,0x21
    80004a92:	1da70713          	addi	a4,a4,474 # 80025c68 <devsw>
    80004a96:	97ba                	add	a5,a5,a4
    80004a98:	679c                	ld	a5,8(a5)
    80004a9a:	cbdd                	beqz	a5,80004b50 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a9c:	4505                	li	a0,1
    80004a9e:	9782                	jalr	a5
    80004aa0:	8a2a                	mv	s4,a0
    80004aa2:	a8a5                	j	80004b1a <filewrite+0xfa>
    80004aa4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004aa8:	00000097          	auipc	ra,0x0
    80004aac:	8b0080e7          	jalr	-1872(ra) # 80004358 <begin_op>
      ilock(f->ip);
    80004ab0:	01893503          	ld	a0,24(s2)
    80004ab4:	fffff097          	auipc	ra,0xfffff
    80004ab8:	ee2080e7          	jalr	-286(ra) # 80003996 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004abc:	8762                	mv	a4,s8
    80004abe:	02092683          	lw	a3,32(s2)
    80004ac2:	01598633          	add	a2,s3,s5
    80004ac6:	4585                	li	a1,1
    80004ac8:	01893503          	ld	a0,24(s2)
    80004acc:	fffff097          	auipc	ra,0xfffff
    80004ad0:	276080e7          	jalr	630(ra) # 80003d42 <writei>
    80004ad4:	84aa                	mv	s1,a0
    80004ad6:	00a05763          	blez	a0,80004ae4 <filewrite+0xc4>
        f->off += r;
    80004ada:	02092783          	lw	a5,32(s2)
    80004ade:	9fa9                	addw	a5,a5,a0
    80004ae0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ae4:	01893503          	ld	a0,24(s2)
    80004ae8:	fffff097          	auipc	ra,0xfffff
    80004aec:	f70080e7          	jalr	-144(ra) # 80003a58 <iunlock>
      end_op();
    80004af0:	00000097          	auipc	ra,0x0
    80004af4:	8e8080e7          	jalr	-1816(ra) # 800043d8 <end_op>

      if(r != n1){
    80004af8:	009c1f63          	bne	s8,s1,80004b16 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004afc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b00:	0149db63          	bge	s3,s4,80004b16 <filewrite+0xf6>
      int n1 = n - i;
    80004b04:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004b08:	84be                	mv	s1,a5
    80004b0a:	2781                	sext.w	a5,a5
    80004b0c:	f8fb5ce3          	bge	s6,a5,80004aa4 <filewrite+0x84>
    80004b10:	84de                	mv	s1,s7
    80004b12:	bf49                	j	80004aa4 <filewrite+0x84>
    int i = 0;
    80004b14:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b16:	013a1f63          	bne	s4,s3,80004b34 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b1a:	8552                	mv	a0,s4
    80004b1c:	60a6                	ld	ra,72(sp)
    80004b1e:	6406                	ld	s0,64(sp)
    80004b20:	74e2                	ld	s1,56(sp)
    80004b22:	7942                	ld	s2,48(sp)
    80004b24:	79a2                	ld	s3,40(sp)
    80004b26:	7a02                	ld	s4,32(sp)
    80004b28:	6ae2                	ld	s5,24(sp)
    80004b2a:	6b42                	ld	s6,16(sp)
    80004b2c:	6ba2                	ld	s7,8(sp)
    80004b2e:	6c02                	ld	s8,0(sp)
    80004b30:	6161                	addi	sp,sp,80
    80004b32:	8082                	ret
    ret = (i == n ? n : -1);
    80004b34:	5a7d                	li	s4,-1
    80004b36:	b7d5                	j	80004b1a <filewrite+0xfa>
    panic("filewrite");
    80004b38:	00004517          	auipc	a0,0x4
    80004b3c:	ba050513          	addi	a0,a0,-1120 # 800086d8 <syscalls+0x288>
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	9fe080e7          	jalr	-1538(ra) # 8000053e <panic>
    return -1;
    80004b48:	5a7d                	li	s4,-1
    80004b4a:	bfc1                	j	80004b1a <filewrite+0xfa>
      return -1;
    80004b4c:	5a7d                	li	s4,-1
    80004b4e:	b7f1                	j	80004b1a <filewrite+0xfa>
    80004b50:	5a7d                	li	s4,-1
    80004b52:	b7e1                	j	80004b1a <filewrite+0xfa>

0000000080004b54 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b54:	7179                	addi	sp,sp,-48
    80004b56:	f406                	sd	ra,40(sp)
    80004b58:	f022                	sd	s0,32(sp)
    80004b5a:	ec26                	sd	s1,24(sp)
    80004b5c:	e84a                	sd	s2,16(sp)
    80004b5e:	e44e                	sd	s3,8(sp)
    80004b60:	e052                	sd	s4,0(sp)
    80004b62:	1800                	addi	s0,sp,48
    80004b64:	84aa                	mv	s1,a0
    80004b66:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b68:	0005b023          	sd	zero,0(a1)
    80004b6c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b70:	00000097          	auipc	ra,0x0
    80004b74:	bf8080e7          	jalr	-1032(ra) # 80004768 <filealloc>
    80004b78:	e088                	sd	a0,0(s1)
    80004b7a:	c551                	beqz	a0,80004c06 <pipealloc+0xb2>
    80004b7c:	00000097          	auipc	ra,0x0
    80004b80:	bec080e7          	jalr	-1044(ra) # 80004768 <filealloc>
    80004b84:	00aa3023          	sd	a0,0(s4)
    80004b88:	c92d                	beqz	a0,80004bfa <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b8a:	ffffc097          	auipc	ra,0xffffc
    80004b8e:	f5c080e7          	jalr	-164(ra) # 80000ae6 <kalloc>
    80004b92:	892a                	mv	s2,a0
    80004b94:	c125                	beqz	a0,80004bf4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b96:	4985                	li	s3,1
    80004b98:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b9c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ba0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ba4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ba8:	00004597          	auipc	a1,0x4
    80004bac:	b4058593          	addi	a1,a1,-1216 # 800086e8 <syscalls+0x298>
    80004bb0:	ffffc097          	auipc	ra,0xffffc
    80004bb4:	f96080e7          	jalr	-106(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004bb8:	609c                	ld	a5,0(s1)
    80004bba:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004bbe:	609c                	ld	a5,0(s1)
    80004bc0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bc4:	609c                	ld	a5,0(s1)
    80004bc6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bca:	609c                	ld	a5,0(s1)
    80004bcc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bd0:	000a3783          	ld	a5,0(s4)
    80004bd4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004bd8:	000a3783          	ld	a5,0(s4)
    80004bdc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004be0:	000a3783          	ld	a5,0(s4)
    80004be4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004be8:	000a3783          	ld	a5,0(s4)
    80004bec:	0127b823          	sd	s2,16(a5)
  return 0;
    80004bf0:	4501                	li	a0,0
    80004bf2:	a025                	j	80004c1a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004bf4:	6088                	ld	a0,0(s1)
    80004bf6:	e501                	bnez	a0,80004bfe <pipealloc+0xaa>
    80004bf8:	a039                	j	80004c06 <pipealloc+0xb2>
    80004bfa:	6088                	ld	a0,0(s1)
    80004bfc:	c51d                	beqz	a0,80004c2a <pipealloc+0xd6>
    fileclose(*f0);
    80004bfe:	00000097          	auipc	ra,0x0
    80004c02:	c26080e7          	jalr	-986(ra) # 80004824 <fileclose>
  if(*f1)
    80004c06:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c0a:	557d                	li	a0,-1
  if(*f1)
    80004c0c:	c799                	beqz	a5,80004c1a <pipealloc+0xc6>
    fileclose(*f1);
    80004c0e:	853e                	mv	a0,a5
    80004c10:	00000097          	auipc	ra,0x0
    80004c14:	c14080e7          	jalr	-1004(ra) # 80004824 <fileclose>
  return -1;
    80004c18:	557d                	li	a0,-1
}
    80004c1a:	70a2                	ld	ra,40(sp)
    80004c1c:	7402                	ld	s0,32(sp)
    80004c1e:	64e2                	ld	s1,24(sp)
    80004c20:	6942                	ld	s2,16(sp)
    80004c22:	69a2                	ld	s3,8(sp)
    80004c24:	6a02                	ld	s4,0(sp)
    80004c26:	6145                	addi	sp,sp,48
    80004c28:	8082                	ret
  return -1;
    80004c2a:	557d                	li	a0,-1
    80004c2c:	b7fd                	j	80004c1a <pipealloc+0xc6>

0000000080004c2e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c2e:	1101                	addi	sp,sp,-32
    80004c30:	ec06                	sd	ra,24(sp)
    80004c32:	e822                	sd	s0,16(sp)
    80004c34:	e426                	sd	s1,8(sp)
    80004c36:	e04a                	sd	s2,0(sp)
    80004c38:	1000                	addi	s0,sp,32
    80004c3a:	84aa                	mv	s1,a0
    80004c3c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c3e:	ffffc097          	auipc	ra,0xffffc
    80004c42:	f98080e7          	jalr	-104(ra) # 80000bd6 <acquire>
  if(writable){
    80004c46:	02090d63          	beqz	s2,80004c80 <pipeclose+0x52>
    pi->writeopen = 0;
    80004c4a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c4e:	21848513          	addi	a0,s1,536
    80004c52:	ffffd097          	auipc	ra,0xffffd
    80004c56:	4de080e7          	jalr	1246(ra) # 80002130 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c5a:	2204b783          	ld	a5,544(s1)
    80004c5e:	eb95                	bnez	a5,80004c92 <pipeclose+0x64>
    release(&pi->lock);
    80004c60:	8526                	mv	a0,s1
    80004c62:	ffffc097          	auipc	ra,0xffffc
    80004c66:	028080e7          	jalr	40(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004c6a:	8526                	mv	a0,s1
    80004c6c:	ffffc097          	auipc	ra,0xffffc
    80004c70:	d7e080e7          	jalr	-642(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004c74:	60e2                	ld	ra,24(sp)
    80004c76:	6442                	ld	s0,16(sp)
    80004c78:	64a2                	ld	s1,8(sp)
    80004c7a:	6902                	ld	s2,0(sp)
    80004c7c:	6105                	addi	sp,sp,32
    80004c7e:	8082                	ret
    pi->readopen = 0;
    80004c80:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c84:	21c48513          	addi	a0,s1,540
    80004c88:	ffffd097          	auipc	ra,0xffffd
    80004c8c:	4a8080e7          	jalr	1192(ra) # 80002130 <wakeup>
    80004c90:	b7e9                	j	80004c5a <pipeclose+0x2c>
    release(&pi->lock);
    80004c92:	8526                	mv	a0,s1
    80004c94:	ffffc097          	auipc	ra,0xffffc
    80004c98:	ff6080e7          	jalr	-10(ra) # 80000c8a <release>
}
    80004c9c:	bfe1                	j	80004c74 <pipeclose+0x46>

0000000080004c9e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c9e:	711d                	addi	sp,sp,-96
    80004ca0:	ec86                	sd	ra,88(sp)
    80004ca2:	e8a2                	sd	s0,80(sp)
    80004ca4:	e4a6                	sd	s1,72(sp)
    80004ca6:	e0ca                	sd	s2,64(sp)
    80004ca8:	fc4e                	sd	s3,56(sp)
    80004caa:	f852                	sd	s4,48(sp)
    80004cac:	f456                	sd	s5,40(sp)
    80004cae:	f05a                	sd	s6,32(sp)
    80004cb0:	ec5e                	sd	s7,24(sp)
    80004cb2:	e862                	sd	s8,16(sp)
    80004cb4:	1080                	addi	s0,sp,96
    80004cb6:	84aa                	mv	s1,a0
    80004cb8:	8aae                	mv	s5,a1
    80004cba:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004cbc:	ffffd097          	auipc	ra,0xffffd
    80004cc0:	cf0080e7          	jalr	-784(ra) # 800019ac <myproc>
    80004cc4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004cc6:	8526                	mv	a0,s1
    80004cc8:	ffffc097          	auipc	ra,0xffffc
    80004ccc:	f0e080e7          	jalr	-242(ra) # 80000bd6 <acquire>
  while(i < n){
    80004cd0:	0b405663          	blez	s4,80004d7c <pipewrite+0xde>
  int i = 0;
    80004cd4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cd6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004cd8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004cdc:	21c48b93          	addi	s7,s1,540
    80004ce0:	a089                	j	80004d22 <pipewrite+0x84>
      release(&pi->lock);
    80004ce2:	8526                	mv	a0,s1
    80004ce4:	ffffc097          	auipc	ra,0xffffc
    80004ce8:	fa6080e7          	jalr	-90(ra) # 80000c8a <release>
      return -1;
    80004cec:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004cee:	854a                	mv	a0,s2
    80004cf0:	60e6                	ld	ra,88(sp)
    80004cf2:	6446                	ld	s0,80(sp)
    80004cf4:	64a6                	ld	s1,72(sp)
    80004cf6:	6906                	ld	s2,64(sp)
    80004cf8:	79e2                	ld	s3,56(sp)
    80004cfa:	7a42                	ld	s4,48(sp)
    80004cfc:	7aa2                	ld	s5,40(sp)
    80004cfe:	7b02                	ld	s6,32(sp)
    80004d00:	6be2                	ld	s7,24(sp)
    80004d02:	6c42                	ld	s8,16(sp)
    80004d04:	6125                	addi	sp,sp,96
    80004d06:	8082                	ret
      wakeup(&pi->nread);
    80004d08:	8562                	mv	a0,s8
    80004d0a:	ffffd097          	auipc	ra,0xffffd
    80004d0e:	426080e7          	jalr	1062(ra) # 80002130 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d12:	85a6                	mv	a1,s1
    80004d14:	855e                	mv	a0,s7
    80004d16:	ffffd097          	auipc	ra,0xffffd
    80004d1a:	3b6080e7          	jalr	950(ra) # 800020cc <sleep>
  while(i < n){
    80004d1e:	07495063          	bge	s2,s4,80004d7e <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004d22:	2204a783          	lw	a5,544(s1)
    80004d26:	dfd5                	beqz	a5,80004ce2 <pipewrite+0x44>
    80004d28:	854e                	mv	a0,s3
    80004d2a:	ffffd097          	auipc	ra,0xffffd
    80004d2e:	656080e7          	jalr	1622(ra) # 80002380 <killed>
    80004d32:	f945                	bnez	a0,80004ce2 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d34:	2184a783          	lw	a5,536(s1)
    80004d38:	21c4a703          	lw	a4,540(s1)
    80004d3c:	2007879b          	addiw	a5,a5,512
    80004d40:	fcf704e3          	beq	a4,a5,80004d08 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d44:	4685                	li	a3,1
    80004d46:	01590633          	add	a2,s2,s5
    80004d4a:	faf40593          	addi	a1,s0,-81
    80004d4e:	0509b503          	ld	a0,80(s3)
    80004d52:	ffffd097          	auipc	ra,0xffffd
    80004d56:	9a2080e7          	jalr	-1630(ra) # 800016f4 <copyin>
    80004d5a:	03650263          	beq	a0,s6,80004d7e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d5e:	21c4a783          	lw	a5,540(s1)
    80004d62:	0017871b          	addiw	a4,a5,1
    80004d66:	20e4ae23          	sw	a4,540(s1)
    80004d6a:	1ff7f793          	andi	a5,a5,511
    80004d6e:	97a6                	add	a5,a5,s1
    80004d70:	faf44703          	lbu	a4,-81(s0)
    80004d74:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d78:	2905                	addiw	s2,s2,1
    80004d7a:	b755                	j	80004d1e <pipewrite+0x80>
  int i = 0;
    80004d7c:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d7e:	21848513          	addi	a0,s1,536
    80004d82:	ffffd097          	auipc	ra,0xffffd
    80004d86:	3ae080e7          	jalr	942(ra) # 80002130 <wakeup>
  release(&pi->lock);
    80004d8a:	8526                	mv	a0,s1
    80004d8c:	ffffc097          	auipc	ra,0xffffc
    80004d90:	efe080e7          	jalr	-258(ra) # 80000c8a <release>
  return i;
    80004d94:	bfa9                	j	80004cee <pipewrite+0x50>

0000000080004d96 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d96:	715d                	addi	sp,sp,-80
    80004d98:	e486                	sd	ra,72(sp)
    80004d9a:	e0a2                	sd	s0,64(sp)
    80004d9c:	fc26                	sd	s1,56(sp)
    80004d9e:	f84a                	sd	s2,48(sp)
    80004da0:	f44e                	sd	s3,40(sp)
    80004da2:	f052                	sd	s4,32(sp)
    80004da4:	ec56                	sd	s5,24(sp)
    80004da6:	e85a                	sd	s6,16(sp)
    80004da8:	0880                	addi	s0,sp,80
    80004daa:	84aa                	mv	s1,a0
    80004dac:	892e                	mv	s2,a1
    80004dae:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004db0:	ffffd097          	auipc	ra,0xffffd
    80004db4:	bfc080e7          	jalr	-1028(ra) # 800019ac <myproc>
    80004db8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004dba:	8526                	mv	a0,s1
    80004dbc:	ffffc097          	auipc	ra,0xffffc
    80004dc0:	e1a080e7          	jalr	-486(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dc4:	2184a703          	lw	a4,536(s1)
    80004dc8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dcc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dd0:	02f71763          	bne	a4,a5,80004dfe <piperead+0x68>
    80004dd4:	2244a783          	lw	a5,548(s1)
    80004dd8:	c39d                	beqz	a5,80004dfe <piperead+0x68>
    if(killed(pr)){
    80004dda:	8552                	mv	a0,s4
    80004ddc:	ffffd097          	auipc	ra,0xffffd
    80004de0:	5a4080e7          	jalr	1444(ra) # 80002380 <killed>
    80004de4:	e941                	bnez	a0,80004e74 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004de6:	85a6                	mv	a1,s1
    80004de8:	854e                	mv	a0,s3
    80004dea:	ffffd097          	auipc	ra,0xffffd
    80004dee:	2e2080e7          	jalr	738(ra) # 800020cc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004df2:	2184a703          	lw	a4,536(s1)
    80004df6:	21c4a783          	lw	a5,540(s1)
    80004dfa:	fcf70de3          	beq	a4,a5,80004dd4 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dfe:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e00:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e02:	05505363          	blez	s5,80004e48 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004e06:	2184a783          	lw	a5,536(s1)
    80004e0a:	21c4a703          	lw	a4,540(s1)
    80004e0e:	02f70d63          	beq	a4,a5,80004e48 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e12:	0017871b          	addiw	a4,a5,1
    80004e16:	20e4ac23          	sw	a4,536(s1)
    80004e1a:	1ff7f793          	andi	a5,a5,511
    80004e1e:	97a6                	add	a5,a5,s1
    80004e20:	0187c783          	lbu	a5,24(a5)
    80004e24:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e28:	4685                	li	a3,1
    80004e2a:	fbf40613          	addi	a2,s0,-65
    80004e2e:	85ca                	mv	a1,s2
    80004e30:	050a3503          	ld	a0,80(s4)
    80004e34:	ffffd097          	auipc	ra,0xffffd
    80004e38:	834080e7          	jalr	-1996(ra) # 80001668 <copyout>
    80004e3c:	01650663          	beq	a0,s6,80004e48 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e40:	2985                	addiw	s3,s3,1
    80004e42:	0905                	addi	s2,s2,1
    80004e44:	fd3a91e3          	bne	s5,s3,80004e06 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e48:	21c48513          	addi	a0,s1,540
    80004e4c:	ffffd097          	auipc	ra,0xffffd
    80004e50:	2e4080e7          	jalr	740(ra) # 80002130 <wakeup>
  release(&pi->lock);
    80004e54:	8526                	mv	a0,s1
    80004e56:	ffffc097          	auipc	ra,0xffffc
    80004e5a:	e34080e7          	jalr	-460(ra) # 80000c8a <release>
  return i;
}
    80004e5e:	854e                	mv	a0,s3
    80004e60:	60a6                	ld	ra,72(sp)
    80004e62:	6406                	ld	s0,64(sp)
    80004e64:	74e2                	ld	s1,56(sp)
    80004e66:	7942                	ld	s2,48(sp)
    80004e68:	79a2                	ld	s3,40(sp)
    80004e6a:	7a02                	ld	s4,32(sp)
    80004e6c:	6ae2                	ld	s5,24(sp)
    80004e6e:	6b42                	ld	s6,16(sp)
    80004e70:	6161                	addi	sp,sp,80
    80004e72:	8082                	ret
      release(&pi->lock);
    80004e74:	8526                	mv	a0,s1
    80004e76:	ffffc097          	auipc	ra,0xffffc
    80004e7a:	e14080e7          	jalr	-492(ra) # 80000c8a <release>
      return -1;
    80004e7e:	59fd                	li	s3,-1
    80004e80:	bff9                	j	80004e5e <piperead+0xc8>

0000000080004e82 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e82:	1141                	addi	sp,sp,-16
    80004e84:	e422                	sd	s0,8(sp)
    80004e86:	0800                	addi	s0,sp,16
    80004e88:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e8a:	8905                	andi	a0,a0,1
    80004e8c:	c111                	beqz	a0,80004e90 <flags2perm+0xe>
      perm = PTE_X;
    80004e8e:	4521                	li	a0,8
    if(flags & 0x2)
    80004e90:	8b89                	andi	a5,a5,2
    80004e92:	c399                	beqz	a5,80004e98 <flags2perm+0x16>
      perm |= PTE_W;
    80004e94:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e98:	6422                	ld	s0,8(sp)
    80004e9a:	0141                	addi	sp,sp,16
    80004e9c:	8082                	ret

0000000080004e9e <exec>:

int
exec(char *path, char **argv)
{
    80004e9e:	de010113          	addi	sp,sp,-544
    80004ea2:	20113c23          	sd	ra,536(sp)
    80004ea6:	20813823          	sd	s0,528(sp)
    80004eaa:	20913423          	sd	s1,520(sp)
    80004eae:	21213023          	sd	s2,512(sp)
    80004eb2:	ffce                	sd	s3,504(sp)
    80004eb4:	fbd2                	sd	s4,496(sp)
    80004eb6:	f7d6                	sd	s5,488(sp)
    80004eb8:	f3da                	sd	s6,480(sp)
    80004eba:	efde                	sd	s7,472(sp)
    80004ebc:	ebe2                	sd	s8,464(sp)
    80004ebe:	e7e6                	sd	s9,456(sp)
    80004ec0:	e3ea                	sd	s10,448(sp)
    80004ec2:	ff6e                	sd	s11,440(sp)
    80004ec4:	1400                	addi	s0,sp,544
    80004ec6:	892a                	mv	s2,a0
    80004ec8:	dea43423          	sd	a0,-536(s0)
    80004ecc:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ed0:	ffffd097          	auipc	ra,0xffffd
    80004ed4:	adc080e7          	jalr	-1316(ra) # 800019ac <myproc>
    80004ed8:	84aa                	mv	s1,a0

  begin_op();
    80004eda:	fffff097          	auipc	ra,0xfffff
    80004ede:	47e080e7          	jalr	1150(ra) # 80004358 <begin_op>

  if((ip = namei(path)) == 0){
    80004ee2:	854a                	mv	a0,s2
    80004ee4:	fffff097          	auipc	ra,0xfffff
    80004ee8:	258080e7          	jalr	600(ra) # 8000413c <namei>
    80004eec:	c93d                	beqz	a0,80004f62 <exec+0xc4>
    80004eee:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ef0:	fffff097          	auipc	ra,0xfffff
    80004ef4:	aa6080e7          	jalr	-1370(ra) # 80003996 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ef8:	04000713          	li	a4,64
    80004efc:	4681                	li	a3,0
    80004efe:	e5040613          	addi	a2,s0,-432
    80004f02:	4581                	li	a1,0
    80004f04:	8556                	mv	a0,s5
    80004f06:	fffff097          	auipc	ra,0xfffff
    80004f0a:	d44080e7          	jalr	-700(ra) # 80003c4a <readi>
    80004f0e:	04000793          	li	a5,64
    80004f12:	00f51a63          	bne	a0,a5,80004f26 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004f16:	e5042703          	lw	a4,-432(s0)
    80004f1a:	464c47b7          	lui	a5,0x464c4
    80004f1e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f22:	04f70663          	beq	a4,a5,80004f6e <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f26:	8556                	mv	a0,s5
    80004f28:	fffff097          	auipc	ra,0xfffff
    80004f2c:	cd0080e7          	jalr	-816(ra) # 80003bf8 <iunlockput>
    end_op();
    80004f30:	fffff097          	auipc	ra,0xfffff
    80004f34:	4a8080e7          	jalr	1192(ra) # 800043d8 <end_op>
  }
  return -1;
    80004f38:	557d                	li	a0,-1
}
    80004f3a:	21813083          	ld	ra,536(sp)
    80004f3e:	21013403          	ld	s0,528(sp)
    80004f42:	20813483          	ld	s1,520(sp)
    80004f46:	20013903          	ld	s2,512(sp)
    80004f4a:	79fe                	ld	s3,504(sp)
    80004f4c:	7a5e                	ld	s4,496(sp)
    80004f4e:	7abe                	ld	s5,488(sp)
    80004f50:	7b1e                	ld	s6,480(sp)
    80004f52:	6bfe                	ld	s7,472(sp)
    80004f54:	6c5e                	ld	s8,464(sp)
    80004f56:	6cbe                	ld	s9,456(sp)
    80004f58:	6d1e                	ld	s10,448(sp)
    80004f5a:	7dfa                	ld	s11,440(sp)
    80004f5c:	22010113          	addi	sp,sp,544
    80004f60:	8082                	ret
    end_op();
    80004f62:	fffff097          	auipc	ra,0xfffff
    80004f66:	476080e7          	jalr	1142(ra) # 800043d8 <end_op>
    return -1;
    80004f6a:	557d                	li	a0,-1
    80004f6c:	b7f9                	j	80004f3a <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f6e:	8526                	mv	a0,s1
    80004f70:	ffffd097          	auipc	ra,0xffffd
    80004f74:	b00080e7          	jalr	-1280(ra) # 80001a70 <proc_pagetable>
    80004f78:	8b2a                	mv	s6,a0
    80004f7a:	d555                	beqz	a0,80004f26 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f7c:	e7042783          	lw	a5,-400(s0)
    80004f80:	e8845703          	lhu	a4,-376(s0)
    80004f84:	c735                	beqz	a4,80004ff0 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f86:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f88:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f8c:	6a05                	lui	s4,0x1
    80004f8e:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f92:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f96:	6d85                	lui	s11,0x1
    80004f98:	7d7d                	lui	s10,0xfffff
    80004f9a:	a481                	j	800051da <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f9c:	00003517          	auipc	a0,0x3
    80004fa0:	75450513          	addi	a0,a0,1876 # 800086f0 <syscalls+0x2a0>
    80004fa4:	ffffb097          	auipc	ra,0xffffb
    80004fa8:	59a080e7          	jalr	1434(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004fac:	874a                	mv	a4,s2
    80004fae:	009c86bb          	addw	a3,s9,s1
    80004fb2:	4581                	li	a1,0
    80004fb4:	8556                	mv	a0,s5
    80004fb6:	fffff097          	auipc	ra,0xfffff
    80004fba:	c94080e7          	jalr	-876(ra) # 80003c4a <readi>
    80004fbe:	2501                	sext.w	a0,a0
    80004fc0:	1aa91a63          	bne	s2,a0,80005174 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80004fc4:	009d84bb          	addw	s1,s11,s1
    80004fc8:	013d09bb          	addw	s3,s10,s3
    80004fcc:	1f74f763          	bgeu	s1,s7,800051ba <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80004fd0:	02049593          	slli	a1,s1,0x20
    80004fd4:	9181                	srli	a1,a1,0x20
    80004fd6:	95e2                	add	a1,a1,s8
    80004fd8:	855a                	mv	a0,s6
    80004fda:	ffffc097          	auipc	ra,0xffffc
    80004fde:	082080e7          	jalr	130(ra) # 8000105c <walkaddr>
    80004fe2:	862a                	mv	a2,a0
    if(pa == 0)
    80004fe4:	dd45                	beqz	a0,80004f9c <exec+0xfe>
      n = PGSIZE;
    80004fe6:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004fe8:	fd49f2e3          	bgeu	s3,s4,80004fac <exec+0x10e>
      n = sz - i;
    80004fec:	894e                	mv	s2,s3
    80004fee:	bf7d                	j	80004fac <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ff0:	4901                	li	s2,0
  iunlockput(ip);
    80004ff2:	8556                	mv	a0,s5
    80004ff4:	fffff097          	auipc	ra,0xfffff
    80004ff8:	c04080e7          	jalr	-1020(ra) # 80003bf8 <iunlockput>
  end_op();
    80004ffc:	fffff097          	auipc	ra,0xfffff
    80005000:	3dc080e7          	jalr	988(ra) # 800043d8 <end_op>
  p = myproc();
    80005004:	ffffd097          	auipc	ra,0xffffd
    80005008:	9a8080e7          	jalr	-1624(ra) # 800019ac <myproc>
    8000500c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000500e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005012:	6785                	lui	a5,0x1
    80005014:	17fd                	addi	a5,a5,-1
    80005016:	993e                	add	s2,s2,a5
    80005018:	77fd                	lui	a5,0xfffff
    8000501a:	00f977b3          	and	a5,s2,a5
    8000501e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005022:	4691                	li	a3,4
    80005024:	6609                	lui	a2,0x2
    80005026:	963e                	add	a2,a2,a5
    80005028:	85be                	mv	a1,a5
    8000502a:	855a                	mv	a0,s6
    8000502c:	ffffc097          	auipc	ra,0xffffc
    80005030:	3e4080e7          	jalr	996(ra) # 80001410 <uvmalloc>
    80005034:	8c2a                	mv	s8,a0
  ip = 0;
    80005036:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005038:	12050e63          	beqz	a0,80005174 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000503c:	75f9                	lui	a1,0xffffe
    8000503e:	95aa                	add	a1,a1,a0
    80005040:	855a                	mv	a0,s6
    80005042:	ffffc097          	auipc	ra,0xffffc
    80005046:	5f4080e7          	jalr	1524(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    8000504a:	7afd                	lui	s5,0xfffff
    8000504c:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000504e:	df043783          	ld	a5,-528(s0)
    80005052:	6388                	ld	a0,0(a5)
    80005054:	c925                	beqz	a0,800050c4 <exec+0x226>
    80005056:	e9040993          	addi	s3,s0,-368
    8000505a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000505e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005060:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005062:	ffffc097          	auipc	ra,0xffffc
    80005066:	dec080e7          	jalr	-532(ra) # 80000e4e <strlen>
    8000506a:	0015079b          	addiw	a5,a0,1
    8000506e:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005072:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005076:	13596663          	bltu	s2,s5,800051a2 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000507a:	df043d83          	ld	s11,-528(s0)
    8000507e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005082:	8552                	mv	a0,s4
    80005084:	ffffc097          	auipc	ra,0xffffc
    80005088:	dca080e7          	jalr	-566(ra) # 80000e4e <strlen>
    8000508c:	0015069b          	addiw	a3,a0,1
    80005090:	8652                	mv	a2,s4
    80005092:	85ca                	mv	a1,s2
    80005094:	855a                	mv	a0,s6
    80005096:	ffffc097          	auipc	ra,0xffffc
    8000509a:	5d2080e7          	jalr	1490(ra) # 80001668 <copyout>
    8000509e:	10054663          	bltz	a0,800051aa <exec+0x30c>
    ustack[argc] = sp;
    800050a2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050a6:	0485                	addi	s1,s1,1
    800050a8:	008d8793          	addi	a5,s11,8
    800050ac:	def43823          	sd	a5,-528(s0)
    800050b0:	008db503          	ld	a0,8(s11)
    800050b4:	c911                	beqz	a0,800050c8 <exec+0x22a>
    if(argc >= MAXARG)
    800050b6:	09a1                	addi	s3,s3,8
    800050b8:	fb3c95e3          	bne	s9,s3,80005062 <exec+0x1c4>
  sz = sz1;
    800050bc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050c0:	4a81                	li	s5,0
    800050c2:	a84d                	j	80005174 <exec+0x2d6>
  sp = sz;
    800050c4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800050c6:	4481                	li	s1,0
  ustack[argc] = 0;
    800050c8:	00349793          	slli	a5,s1,0x3
    800050cc:	f9040713          	addi	a4,s0,-112
    800050d0:	97ba                	add	a5,a5,a4
    800050d2:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffd8100>
  sp -= (argc+1) * sizeof(uint64);
    800050d6:	00148693          	addi	a3,s1,1
    800050da:	068e                	slli	a3,a3,0x3
    800050dc:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050e0:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800050e4:	01597663          	bgeu	s2,s5,800050f0 <exec+0x252>
  sz = sz1;
    800050e8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050ec:	4a81                	li	s5,0
    800050ee:	a059                	j	80005174 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050f0:	e9040613          	addi	a2,s0,-368
    800050f4:	85ca                	mv	a1,s2
    800050f6:	855a                	mv	a0,s6
    800050f8:	ffffc097          	auipc	ra,0xffffc
    800050fc:	570080e7          	jalr	1392(ra) # 80001668 <copyout>
    80005100:	0a054963          	bltz	a0,800051b2 <exec+0x314>
  p->trapframe->a1 = sp;
    80005104:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005108:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000510c:	de843783          	ld	a5,-536(s0)
    80005110:	0007c703          	lbu	a4,0(a5)
    80005114:	cf11                	beqz	a4,80005130 <exec+0x292>
    80005116:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005118:	02f00693          	li	a3,47
    8000511c:	a039                	j	8000512a <exec+0x28c>
      last = s+1;
    8000511e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005122:	0785                	addi	a5,a5,1
    80005124:	fff7c703          	lbu	a4,-1(a5)
    80005128:	c701                	beqz	a4,80005130 <exec+0x292>
    if(*s == '/')
    8000512a:	fed71ce3          	bne	a4,a3,80005122 <exec+0x284>
    8000512e:	bfc5                	j	8000511e <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80005130:	4641                	li	a2,16
    80005132:	de843583          	ld	a1,-536(s0)
    80005136:	158b8513          	addi	a0,s7,344
    8000513a:	ffffc097          	auipc	ra,0xffffc
    8000513e:	ce2080e7          	jalr	-798(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005142:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005146:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000514a:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000514e:	058bb783          	ld	a5,88(s7)
    80005152:	e6843703          	ld	a4,-408(s0)
    80005156:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005158:	058bb783          	ld	a5,88(s7)
    8000515c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005160:	85ea                	mv	a1,s10
    80005162:	ffffd097          	auipc	ra,0xffffd
    80005166:	9aa080e7          	jalr	-1622(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000516a:	0004851b          	sext.w	a0,s1
    8000516e:	b3f1                	j	80004f3a <exec+0x9c>
    80005170:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005174:	df843583          	ld	a1,-520(s0)
    80005178:	855a                	mv	a0,s6
    8000517a:	ffffd097          	auipc	ra,0xffffd
    8000517e:	992080e7          	jalr	-1646(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    80005182:	da0a92e3          	bnez	s5,80004f26 <exec+0x88>
  return -1;
    80005186:	557d                	li	a0,-1
    80005188:	bb4d                	j	80004f3a <exec+0x9c>
    8000518a:	df243c23          	sd	s2,-520(s0)
    8000518e:	b7dd                	j	80005174 <exec+0x2d6>
    80005190:	df243c23          	sd	s2,-520(s0)
    80005194:	b7c5                	j	80005174 <exec+0x2d6>
    80005196:	df243c23          	sd	s2,-520(s0)
    8000519a:	bfe9                	j	80005174 <exec+0x2d6>
    8000519c:	df243c23          	sd	s2,-520(s0)
    800051a0:	bfd1                	j	80005174 <exec+0x2d6>
  sz = sz1;
    800051a2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051a6:	4a81                	li	s5,0
    800051a8:	b7f1                	j	80005174 <exec+0x2d6>
  sz = sz1;
    800051aa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051ae:	4a81                	li	s5,0
    800051b0:	b7d1                	j	80005174 <exec+0x2d6>
  sz = sz1;
    800051b2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051b6:	4a81                	li	s5,0
    800051b8:	bf75                	j	80005174 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051ba:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051be:	e0843783          	ld	a5,-504(s0)
    800051c2:	0017869b          	addiw	a3,a5,1
    800051c6:	e0d43423          	sd	a3,-504(s0)
    800051ca:	e0043783          	ld	a5,-512(s0)
    800051ce:	0387879b          	addiw	a5,a5,56
    800051d2:	e8845703          	lhu	a4,-376(s0)
    800051d6:	e0e6dee3          	bge	a3,a4,80004ff2 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051da:	2781                	sext.w	a5,a5
    800051dc:	e0f43023          	sd	a5,-512(s0)
    800051e0:	03800713          	li	a4,56
    800051e4:	86be                	mv	a3,a5
    800051e6:	e1840613          	addi	a2,s0,-488
    800051ea:	4581                	li	a1,0
    800051ec:	8556                	mv	a0,s5
    800051ee:	fffff097          	auipc	ra,0xfffff
    800051f2:	a5c080e7          	jalr	-1444(ra) # 80003c4a <readi>
    800051f6:	03800793          	li	a5,56
    800051fa:	f6f51be3          	bne	a0,a5,80005170 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    800051fe:	e1842783          	lw	a5,-488(s0)
    80005202:	4705                	li	a4,1
    80005204:	fae79de3          	bne	a5,a4,800051be <exec+0x320>
    if(ph.memsz < ph.filesz)
    80005208:	e4043483          	ld	s1,-448(s0)
    8000520c:	e3843783          	ld	a5,-456(s0)
    80005210:	f6f4ede3          	bltu	s1,a5,8000518a <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005214:	e2843783          	ld	a5,-472(s0)
    80005218:	94be                	add	s1,s1,a5
    8000521a:	f6f4ebe3          	bltu	s1,a5,80005190 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    8000521e:	de043703          	ld	a4,-544(s0)
    80005222:	8ff9                	and	a5,a5,a4
    80005224:	fbad                	bnez	a5,80005196 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005226:	e1c42503          	lw	a0,-484(s0)
    8000522a:	00000097          	auipc	ra,0x0
    8000522e:	c58080e7          	jalr	-936(ra) # 80004e82 <flags2perm>
    80005232:	86aa                	mv	a3,a0
    80005234:	8626                	mv	a2,s1
    80005236:	85ca                	mv	a1,s2
    80005238:	855a                	mv	a0,s6
    8000523a:	ffffc097          	auipc	ra,0xffffc
    8000523e:	1d6080e7          	jalr	470(ra) # 80001410 <uvmalloc>
    80005242:	dea43c23          	sd	a0,-520(s0)
    80005246:	d939                	beqz	a0,8000519c <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005248:	e2843c03          	ld	s8,-472(s0)
    8000524c:	e2042c83          	lw	s9,-480(s0)
    80005250:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005254:	f60b83e3          	beqz	s7,800051ba <exec+0x31c>
    80005258:	89de                	mv	s3,s7
    8000525a:	4481                	li	s1,0
    8000525c:	bb95                	j	80004fd0 <exec+0x132>

000000008000525e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000525e:	7179                	addi	sp,sp,-48
    80005260:	f406                	sd	ra,40(sp)
    80005262:	f022                	sd	s0,32(sp)
    80005264:	ec26                	sd	s1,24(sp)
    80005266:	e84a                	sd	s2,16(sp)
    80005268:	1800                	addi	s0,sp,48
    8000526a:	892e                	mv	s2,a1
    8000526c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000526e:	fdc40593          	addi	a1,s0,-36
    80005272:	ffffe097          	auipc	ra,0xffffe
    80005276:	b00080e7          	jalr	-1280(ra) # 80002d72 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000527a:	fdc42703          	lw	a4,-36(s0)
    8000527e:	47bd                	li	a5,15
    80005280:	02e7eb63          	bltu	a5,a4,800052b6 <argfd+0x58>
    80005284:	ffffc097          	auipc	ra,0xffffc
    80005288:	728080e7          	jalr	1832(ra) # 800019ac <myproc>
    8000528c:	fdc42703          	lw	a4,-36(s0)
    80005290:	01a70793          	addi	a5,a4,26
    80005294:	078e                	slli	a5,a5,0x3
    80005296:	953e                	add	a0,a0,a5
    80005298:	611c                	ld	a5,0(a0)
    8000529a:	c385                	beqz	a5,800052ba <argfd+0x5c>
    return -1;
  if(pfd)
    8000529c:	00090463          	beqz	s2,800052a4 <argfd+0x46>
    *pfd = fd;
    800052a0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800052a4:	4501                	li	a0,0
  if(pf)
    800052a6:	c091                	beqz	s1,800052aa <argfd+0x4c>
    *pf = f;
    800052a8:	e09c                	sd	a5,0(s1)
}
    800052aa:	70a2                	ld	ra,40(sp)
    800052ac:	7402                	ld	s0,32(sp)
    800052ae:	64e2                	ld	s1,24(sp)
    800052b0:	6942                	ld	s2,16(sp)
    800052b2:	6145                	addi	sp,sp,48
    800052b4:	8082                	ret
    return -1;
    800052b6:	557d                	li	a0,-1
    800052b8:	bfcd                	j	800052aa <argfd+0x4c>
    800052ba:	557d                	li	a0,-1
    800052bc:	b7fd                	j	800052aa <argfd+0x4c>

00000000800052be <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052be:	1101                	addi	sp,sp,-32
    800052c0:	ec06                	sd	ra,24(sp)
    800052c2:	e822                	sd	s0,16(sp)
    800052c4:	e426                	sd	s1,8(sp)
    800052c6:	1000                	addi	s0,sp,32
    800052c8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052ca:	ffffc097          	auipc	ra,0xffffc
    800052ce:	6e2080e7          	jalr	1762(ra) # 800019ac <myproc>
    800052d2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052d4:	0d050793          	addi	a5,a0,208
    800052d8:	4501                	li	a0,0
    800052da:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052dc:	6398                	ld	a4,0(a5)
    800052de:	cb19                	beqz	a4,800052f4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052e0:	2505                	addiw	a0,a0,1
    800052e2:	07a1                	addi	a5,a5,8
    800052e4:	fed51ce3          	bne	a0,a3,800052dc <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052e8:	557d                	li	a0,-1
}
    800052ea:	60e2                	ld	ra,24(sp)
    800052ec:	6442                	ld	s0,16(sp)
    800052ee:	64a2                	ld	s1,8(sp)
    800052f0:	6105                	addi	sp,sp,32
    800052f2:	8082                	ret
      p->ofile[fd] = f;
    800052f4:	01a50793          	addi	a5,a0,26
    800052f8:	078e                	slli	a5,a5,0x3
    800052fa:	963e                	add	a2,a2,a5
    800052fc:	e204                	sd	s1,0(a2)
      return fd;
    800052fe:	b7f5                	j	800052ea <fdalloc+0x2c>

0000000080005300 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005300:	715d                	addi	sp,sp,-80
    80005302:	e486                	sd	ra,72(sp)
    80005304:	e0a2                	sd	s0,64(sp)
    80005306:	fc26                	sd	s1,56(sp)
    80005308:	f84a                	sd	s2,48(sp)
    8000530a:	f44e                	sd	s3,40(sp)
    8000530c:	f052                	sd	s4,32(sp)
    8000530e:	ec56                	sd	s5,24(sp)
    80005310:	e85a                	sd	s6,16(sp)
    80005312:	0880                	addi	s0,sp,80
    80005314:	8b2e                	mv	s6,a1
    80005316:	89b2                	mv	s3,a2
    80005318:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000531a:	fb040593          	addi	a1,s0,-80
    8000531e:	fffff097          	auipc	ra,0xfffff
    80005322:	e3c080e7          	jalr	-452(ra) # 8000415a <nameiparent>
    80005326:	84aa                	mv	s1,a0
    80005328:	14050f63          	beqz	a0,80005486 <create+0x186>
    return 0;

  ilock(dp);
    8000532c:	ffffe097          	auipc	ra,0xffffe
    80005330:	66a080e7          	jalr	1642(ra) # 80003996 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005334:	4601                	li	a2,0
    80005336:	fb040593          	addi	a1,s0,-80
    8000533a:	8526                	mv	a0,s1
    8000533c:	fffff097          	auipc	ra,0xfffff
    80005340:	b3e080e7          	jalr	-1218(ra) # 80003e7a <dirlookup>
    80005344:	8aaa                	mv	s5,a0
    80005346:	c931                	beqz	a0,8000539a <create+0x9a>
    iunlockput(dp);
    80005348:	8526                	mv	a0,s1
    8000534a:	fffff097          	auipc	ra,0xfffff
    8000534e:	8ae080e7          	jalr	-1874(ra) # 80003bf8 <iunlockput>
    ilock(ip);
    80005352:	8556                	mv	a0,s5
    80005354:	ffffe097          	auipc	ra,0xffffe
    80005358:	642080e7          	jalr	1602(ra) # 80003996 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000535c:	000b059b          	sext.w	a1,s6
    80005360:	4789                	li	a5,2
    80005362:	02f59563          	bne	a1,a5,8000538c <create+0x8c>
    80005366:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffd8244>
    8000536a:	37f9                	addiw	a5,a5,-2
    8000536c:	17c2                	slli	a5,a5,0x30
    8000536e:	93c1                	srli	a5,a5,0x30
    80005370:	4705                	li	a4,1
    80005372:	00f76d63          	bltu	a4,a5,8000538c <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005376:	8556                	mv	a0,s5
    80005378:	60a6                	ld	ra,72(sp)
    8000537a:	6406                	ld	s0,64(sp)
    8000537c:	74e2                	ld	s1,56(sp)
    8000537e:	7942                	ld	s2,48(sp)
    80005380:	79a2                	ld	s3,40(sp)
    80005382:	7a02                	ld	s4,32(sp)
    80005384:	6ae2                	ld	s5,24(sp)
    80005386:	6b42                	ld	s6,16(sp)
    80005388:	6161                	addi	sp,sp,80
    8000538a:	8082                	ret
    iunlockput(ip);
    8000538c:	8556                	mv	a0,s5
    8000538e:	fffff097          	auipc	ra,0xfffff
    80005392:	86a080e7          	jalr	-1942(ra) # 80003bf8 <iunlockput>
    return 0;
    80005396:	4a81                	li	s5,0
    80005398:	bff9                	j	80005376 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000539a:	85da                	mv	a1,s6
    8000539c:	4088                	lw	a0,0(s1)
    8000539e:	ffffe097          	auipc	ra,0xffffe
    800053a2:	45c080e7          	jalr	1116(ra) # 800037fa <ialloc>
    800053a6:	8a2a                	mv	s4,a0
    800053a8:	c539                	beqz	a0,800053f6 <create+0xf6>
  ilock(ip);
    800053aa:	ffffe097          	auipc	ra,0xffffe
    800053ae:	5ec080e7          	jalr	1516(ra) # 80003996 <ilock>
  ip->major = major;
    800053b2:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800053b6:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800053ba:	4905                	li	s2,1
    800053bc:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800053c0:	8552                	mv	a0,s4
    800053c2:	ffffe097          	auipc	ra,0xffffe
    800053c6:	50a080e7          	jalr	1290(ra) # 800038cc <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053ca:	000b059b          	sext.w	a1,s6
    800053ce:	03258b63          	beq	a1,s2,80005404 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800053d2:	004a2603          	lw	a2,4(s4)
    800053d6:	fb040593          	addi	a1,s0,-80
    800053da:	8526                	mv	a0,s1
    800053dc:	fffff097          	auipc	ra,0xfffff
    800053e0:	cae080e7          	jalr	-850(ra) # 8000408a <dirlink>
    800053e4:	06054f63          	bltz	a0,80005462 <create+0x162>
  iunlockput(dp);
    800053e8:	8526                	mv	a0,s1
    800053ea:	fffff097          	auipc	ra,0xfffff
    800053ee:	80e080e7          	jalr	-2034(ra) # 80003bf8 <iunlockput>
  return ip;
    800053f2:	8ad2                	mv	s5,s4
    800053f4:	b749                	j	80005376 <create+0x76>
    iunlockput(dp);
    800053f6:	8526                	mv	a0,s1
    800053f8:	fffff097          	auipc	ra,0xfffff
    800053fc:	800080e7          	jalr	-2048(ra) # 80003bf8 <iunlockput>
    return 0;
    80005400:	8ad2                	mv	s5,s4
    80005402:	bf95                	j	80005376 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005404:	004a2603          	lw	a2,4(s4)
    80005408:	00003597          	auipc	a1,0x3
    8000540c:	30858593          	addi	a1,a1,776 # 80008710 <syscalls+0x2c0>
    80005410:	8552                	mv	a0,s4
    80005412:	fffff097          	auipc	ra,0xfffff
    80005416:	c78080e7          	jalr	-904(ra) # 8000408a <dirlink>
    8000541a:	04054463          	bltz	a0,80005462 <create+0x162>
    8000541e:	40d0                	lw	a2,4(s1)
    80005420:	00003597          	auipc	a1,0x3
    80005424:	2f858593          	addi	a1,a1,760 # 80008718 <syscalls+0x2c8>
    80005428:	8552                	mv	a0,s4
    8000542a:	fffff097          	auipc	ra,0xfffff
    8000542e:	c60080e7          	jalr	-928(ra) # 8000408a <dirlink>
    80005432:	02054863          	bltz	a0,80005462 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005436:	004a2603          	lw	a2,4(s4)
    8000543a:	fb040593          	addi	a1,s0,-80
    8000543e:	8526                	mv	a0,s1
    80005440:	fffff097          	auipc	ra,0xfffff
    80005444:	c4a080e7          	jalr	-950(ra) # 8000408a <dirlink>
    80005448:	00054d63          	bltz	a0,80005462 <create+0x162>
    dp->nlink++;  // for ".."
    8000544c:	04a4d783          	lhu	a5,74(s1)
    80005450:	2785                	addiw	a5,a5,1
    80005452:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005456:	8526                	mv	a0,s1
    80005458:	ffffe097          	auipc	ra,0xffffe
    8000545c:	474080e7          	jalr	1140(ra) # 800038cc <iupdate>
    80005460:	b761                	j	800053e8 <create+0xe8>
  ip->nlink = 0;
    80005462:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005466:	8552                	mv	a0,s4
    80005468:	ffffe097          	auipc	ra,0xffffe
    8000546c:	464080e7          	jalr	1124(ra) # 800038cc <iupdate>
  iunlockput(ip);
    80005470:	8552                	mv	a0,s4
    80005472:	ffffe097          	auipc	ra,0xffffe
    80005476:	786080e7          	jalr	1926(ra) # 80003bf8 <iunlockput>
  iunlockput(dp);
    8000547a:	8526                	mv	a0,s1
    8000547c:	ffffe097          	auipc	ra,0xffffe
    80005480:	77c080e7          	jalr	1916(ra) # 80003bf8 <iunlockput>
  return 0;
    80005484:	bdcd                	j	80005376 <create+0x76>
    return 0;
    80005486:	8aaa                	mv	s5,a0
    80005488:	b5fd                	j	80005376 <create+0x76>

000000008000548a <sys_dup>:
{
    8000548a:	7179                	addi	sp,sp,-48
    8000548c:	f406                	sd	ra,40(sp)
    8000548e:	f022                	sd	s0,32(sp)
    80005490:	ec26                	sd	s1,24(sp)
    80005492:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005494:	fd840613          	addi	a2,s0,-40
    80005498:	4581                	li	a1,0
    8000549a:	4501                	li	a0,0
    8000549c:	00000097          	auipc	ra,0x0
    800054a0:	dc2080e7          	jalr	-574(ra) # 8000525e <argfd>
    return -1;
    800054a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800054a6:	02054363          	bltz	a0,800054cc <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800054aa:	fd843503          	ld	a0,-40(s0)
    800054ae:	00000097          	auipc	ra,0x0
    800054b2:	e10080e7          	jalr	-496(ra) # 800052be <fdalloc>
    800054b6:	84aa                	mv	s1,a0
    return -1;
    800054b8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054ba:	00054963          	bltz	a0,800054cc <sys_dup+0x42>
  filedup(f);
    800054be:	fd843503          	ld	a0,-40(s0)
    800054c2:	fffff097          	auipc	ra,0xfffff
    800054c6:	310080e7          	jalr	784(ra) # 800047d2 <filedup>
  return fd;
    800054ca:	87a6                	mv	a5,s1
}
    800054cc:	853e                	mv	a0,a5
    800054ce:	70a2                	ld	ra,40(sp)
    800054d0:	7402                	ld	s0,32(sp)
    800054d2:	64e2                	ld	s1,24(sp)
    800054d4:	6145                	addi	sp,sp,48
    800054d6:	8082                	ret

00000000800054d8 <sys_read>:
{
    800054d8:	7179                	addi	sp,sp,-48
    800054da:	f406                	sd	ra,40(sp)
    800054dc:	f022                	sd	s0,32(sp)
    800054de:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054e0:	fd840593          	addi	a1,s0,-40
    800054e4:	4505                	li	a0,1
    800054e6:	ffffe097          	auipc	ra,0xffffe
    800054ea:	8ac080e7          	jalr	-1876(ra) # 80002d92 <argaddr>
  argint(2, &n);
    800054ee:	fe440593          	addi	a1,s0,-28
    800054f2:	4509                	li	a0,2
    800054f4:	ffffe097          	auipc	ra,0xffffe
    800054f8:	87e080e7          	jalr	-1922(ra) # 80002d72 <argint>
  if(argfd(0, 0, &f) < 0)
    800054fc:	fe840613          	addi	a2,s0,-24
    80005500:	4581                	li	a1,0
    80005502:	4501                	li	a0,0
    80005504:	00000097          	auipc	ra,0x0
    80005508:	d5a080e7          	jalr	-678(ra) # 8000525e <argfd>
    8000550c:	87aa                	mv	a5,a0
    return -1;
    8000550e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005510:	0007cc63          	bltz	a5,80005528 <sys_read+0x50>
  return fileread(f, p, n);
    80005514:	fe442603          	lw	a2,-28(s0)
    80005518:	fd843583          	ld	a1,-40(s0)
    8000551c:	fe843503          	ld	a0,-24(s0)
    80005520:	fffff097          	auipc	ra,0xfffff
    80005524:	43e080e7          	jalr	1086(ra) # 8000495e <fileread>
}
    80005528:	70a2                	ld	ra,40(sp)
    8000552a:	7402                	ld	s0,32(sp)
    8000552c:	6145                	addi	sp,sp,48
    8000552e:	8082                	ret

0000000080005530 <sys_write>:
{
    80005530:	7179                	addi	sp,sp,-48
    80005532:	f406                	sd	ra,40(sp)
    80005534:	f022                	sd	s0,32(sp)
    80005536:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005538:	fd840593          	addi	a1,s0,-40
    8000553c:	4505                	li	a0,1
    8000553e:	ffffe097          	auipc	ra,0xffffe
    80005542:	854080e7          	jalr	-1964(ra) # 80002d92 <argaddr>
  argint(2, &n);
    80005546:	fe440593          	addi	a1,s0,-28
    8000554a:	4509                	li	a0,2
    8000554c:	ffffe097          	auipc	ra,0xffffe
    80005550:	826080e7          	jalr	-2010(ra) # 80002d72 <argint>
  if(argfd(0, 0, &f) < 0)
    80005554:	fe840613          	addi	a2,s0,-24
    80005558:	4581                	li	a1,0
    8000555a:	4501                	li	a0,0
    8000555c:	00000097          	auipc	ra,0x0
    80005560:	d02080e7          	jalr	-766(ra) # 8000525e <argfd>
    80005564:	87aa                	mv	a5,a0
    return -1;
    80005566:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005568:	0007cc63          	bltz	a5,80005580 <sys_write+0x50>
  return filewrite(f, p, n);
    8000556c:	fe442603          	lw	a2,-28(s0)
    80005570:	fd843583          	ld	a1,-40(s0)
    80005574:	fe843503          	ld	a0,-24(s0)
    80005578:	fffff097          	auipc	ra,0xfffff
    8000557c:	4a8080e7          	jalr	1192(ra) # 80004a20 <filewrite>
}
    80005580:	70a2                	ld	ra,40(sp)
    80005582:	7402                	ld	s0,32(sp)
    80005584:	6145                	addi	sp,sp,48
    80005586:	8082                	ret

0000000080005588 <sys_close>:
{
    80005588:	1101                	addi	sp,sp,-32
    8000558a:	ec06                	sd	ra,24(sp)
    8000558c:	e822                	sd	s0,16(sp)
    8000558e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005590:	fe040613          	addi	a2,s0,-32
    80005594:	fec40593          	addi	a1,s0,-20
    80005598:	4501                	li	a0,0
    8000559a:	00000097          	auipc	ra,0x0
    8000559e:	cc4080e7          	jalr	-828(ra) # 8000525e <argfd>
    return -1;
    800055a2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800055a4:	02054463          	bltz	a0,800055cc <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800055a8:	ffffc097          	auipc	ra,0xffffc
    800055ac:	404080e7          	jalr	1028(ra) # 800019ac <myproc>
    800055b0:	fec42783          	lw	a5,-20(s0)
    800055b4:	07e9                	addi	a5,a5,26
    800055b6:	078e                	slli	a5,a5,0x3
    800055b8:	97aa                	add	a5,a5,a0
    800055ba:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800055be:	fe043503          	ld	a0,-32(s0)
    800055c2:	fffff097          	auipc	ra,0xfffff
    800055c6:	262080e7          	jalr	610(ra) # 80004824 <fileclose>
  return 0;
    800055ca:	4781                	li	a5,0
}
    800055cc:	853e                	mv	a0,a5
    800055ce:	60e2                	ld	ra,24(sp)
    800055d0:	6442                	ld	s0,16(sp)
    800055d2:	6105                	addi	sp,sp,32
    800055d4:	8082                	ret

00000000800055d6 <sys_fstat>:
{
    800055d6:	1101                	addi	sp,sp,-32
    800055d8:	ec06                	sd	ra,24(sp)
    800055da:	e822                	sd	s0,16(sp)
    800055dc:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800055de:	fe040593          	addi	a1,s0,-32
    800055e2:	4505                	li	a0,1
    800055e4:	ffffd097          	auipc	ra,0xffffd
    800055e8:	7ae080e7          	jalr	1966(ra) # 80002d92 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800055ec:	fe840613          	addi	a2,s0,-24
    800055f0:	4581                	li	a1,0
    800055f2:	4501                	li	a0,0
    800055f4:	00000097          	auipc	ra,0x0
    800055f8:	c6a080e7          	jalr	-918(ra) # 8000525e <argfd>
    800055fc:	87aa                	mv	a5,a0
    return -1;
    800055fe:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005600:	0007ca63          	bltz	a5,80005614 <sys_fstat+0x3e>
  return filestat(f, st);
    80005604:	fe043583          	ld	a1,-32(s0)
    80005608:	fe843503          	ld	a0,-24(s0)
    8000560c:	fffff097          	auipc	ra,0xfffff
    80005610:	2e0080e7          	jalr	736(ra) # 800048ec <filestat>
}
    80005614:	60e2                	ld	ra,24(sp)
    80005616:	6442                	ld	s0,16(sp)
    80005618:	6105                	addi	sp,sp,32
    8000561a:	8082                	ret

000000008000561c <sys_link>:
{
    8000561c:	7169                	addi	sp,sp,-304
    8000561e:	f606                	sd	ra,296(sp)
    80005620:	f222                	sd	s0,288(sp)
    80005622:	ee26                	sd	s1,280(sp)
    80005624:	ea4a                	sd	s2,272(sp)
    80005626:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005628:	08000613          	li	a2,128
    8000562c:	ed040593          	addi	a1,s0,-304
    80005630:	4501                	li	a0,0
    80005632:	ffffd097          	auipc	ra,0xffffd
    80005636:	780080e7          	jalr	1920(ra) # 80002db2 <argstr>
    return -1;
    8000563a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000563c:	10054e63          	bltz	a0,80005758 <sys_link+0x13c>
    80005640:	08000613          	li	a2,128
    80005644:	f5040593          	addi	a1,s0,-176
    80005648:	4505                	li	a0,1
    8000564a:	ffffd097          	auipc	ra,0xffffd
    8000564e:	768080e7          	jalr	1896(ra) # 80002db2 <argstr>
    return -1;
    80005652:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005654:	10054263          	bltz	a0,80005758 <sys_link+0x13c>
  begin_op();
    80005658:	fffff097          	auipc	ra,0xfffff
    8000565c:	d00080e7          	jalr	-768(ra) # 80004358 <begin_op>
  if((ip = namei(old)) == 0){
    80005660:	ed040513          	addi	a0,s0,-304
    80005664:	fffff097          	auipc	ra,0xfffff
    80005668:	ad8080e7          	jalr	-1320(ra) # 8000413c <namei>
    8000566c:	84aa                	mv	s1,a0
    8000566e:	c551                	beqz	a0,800056fa <sys_link+0xde>
  ilock(ip);
    80005670:	ffffe097          	auipc	ra,0xffffe
    80005674:	326080e7          	jalr	806(ra) # 80003996 <ilock>
  if(ip->type == T_DIR){
    80005678:	04449703          	lh	a4,68(s1)
    8000567c:	4785                	li	a5,1
    8000567e:	08f70463          	beq	a4,a5,80005706 <sys_link+0xea>
  ip->nlink++;
    80005682:	04a4d783          	lhu	a5,74(s1)
    80005686:	2785                	addiw	a5,a5,1
    80005688:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000568c:	8526                	mv	a0,s1
    8000568e:	ffffe097          	auipc	ra,0xffffe
    80005692:	23e080e7          	jalr	574(ra) # 800038cc <iupdate>
  iunlock(ip);
    80005696:	8526                	mv	a0,s1
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	3c0080e7          	jalr	960(ra) # 80003a58 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800056a0:	fd040593          	addi	a1,s0,-48
    800056a4:	f5040513          	addi	a0,s0,-176
    800056a8:	fffff097          	auipc	ra,0xfffff
    800056ac:	ab2080e7          	jalr	-1358(ra) # 8000415a <nameiparent>
    800056b0:	892a                	mv	s2,a0
    800056b2:	c935                	beqz	a0,80005726 <sys_link+0x10a>
  ilock(dp);
    800056b4:	ffffe097          	auipc	ra,0xffffe
    800056b8:	2e2080e7          	jalr	738(ra) # 80003996 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056bc:	00092703          	lw	a4,0(s2)
    800056c0:	409c                	lw	a5,0(s1)
    800056c2:	04f71d63          	bne	a4,a5,8000571c <sys_link+0x100>
    800056c6:	40d0                	lw	a2,4(s1)
    800056c8:	fd040593          	addi	a1,s0,-48
    800056cc:	854a                	mv	a0,s2
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	9bc080e7          	jalr	-1604(ra) # 8000408a <dirlink>
    800056d6:	04054363          	bltz	a0,8000571c <sys_link+0x100>
  iunlockput(dp);
    800056da:	854a                	mv	a0,s2
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	51c080e7          	jalr	1308(ra) # 80003bf8 <iunlockput>
  iput(ip);
    800056e4:	8526                	mv	a0,s1
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	46a080e7          	jalr	1130(ra) # 80003b50 <iput>
  end_op();
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	cea080e7          	jalr	-790(ra) # 800043d8 <end_op>
  return 0;
    800056f6:	4781                	li	a5,0
    800056f8:	a085                	j	80005758 <sys_link+0x13c>
    end_op();
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	cde080e7          	jalr	-802(ra) # 800043d8 <end_op>
    return -1;
    80005702:	57fd                	li	a5,-1
    80005704:	a891                	j	80005758 <sys_link+0x13c>
    iunlockput(ip);
    80005706:	8526                	mv	a0,s1
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	4f0080e7          	jalr	1264(ra) # 80003bf8 <iunlockput>
    end_op();
    80005710:	fffff097          	auipc	ra,0xfffff
    80005714:	cc8080e7          	jalr	-824(ra) # 800043d8 <end_op>
    return -1;
    80005718:	57fd                	li	a5,-1
    8000571a:	a83d                	j	80005758 <sys_link+0x13c>
    iunlockput(dp);
    8000571c:	854a                	mv	a0,s2
    8000571e:	ffffe097          	auipc	ra,0xffffe
    80005722:	4da080e7          	jalr	1242(ra) # 80003bf8 <iunlockput>
  ilock(ip);
    80005726:	8526                	mv	a0,s1
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	26e080e7          	jalr	622(ra) # 80003996 <ilock>
  ip->nlink--;
    80005730:	04a4d783          	lhu	a5,74(s1)
    80005734:	37fd                	addiw	a5,a5,-1
    80005736:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000573a:	8526                	mv	a0,s1
    8000573c:	ffffe097          	auipc	ra,0xffffe
    80005740:	190080e7          	jalr	400(ra) # 800038cc <iupdate>
  iunlockput(ip);
    80005744:	8526                	mv	a0,s1
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	4b2080e7          	jalr	1202(ra) # 80003bf8 <iunlockput>
  end_op();
    8000574e:	fffff097          	auipc	ra,0xfffff
    80005752:	c8a080e7          	jalr	-886(ra) # 800043d8 <end_op>
  return -1;
    80005756:	57fd                	li	a5,-1
}
    80005758:	853e                	mv	a0,a5
    8000575a:	70b2                	ld	ra,296(sp)
    8000575c:	7412                	ld	s0,288(sp)
    8000575e:	64f2                	ld	s1,280(sp)
    80005760:	6952                	ld	s2,272(sp)
    80005762:	6155                	addi	sp,sp,304
    80005764:	8082                	ret

0000000080005766 <sys_unlink>:
{
    80005766:	7151                	addi	sp,sp,-240
    80005768:	f586                	sd	ra,232(sp)
    8000576a:	f1a2                	sd	s0,224(sp)
    8000576c:	eda6                	sd	s1,216(sp)
    8000576e:	e9ca                	sd	s2,208(sp)
    80005770:	e5ce                	sd	s3,200(sp)
    80005772:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005774:	08000613          	li	a2,128
    80005778:	f3040593          	addi	a1,s0,-208
    8000577c:	4501                	li	a0,0
    8000577e:	ffffd097          	auipc	ra,0xffffd
    80005782:	634080e7          	jalr	1588(ra) # 80002db2 <argstr>
    80005786:	18054163          	bltz	a0,80005908 <sys_unlink+0x1a2>
  begin_op();
    8000578a:	fffff097          	auipc	ra,0xfffff
    8000578e:	bce080e7          	jalr	-1074(ra) # 80004358 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005792:	fb040593          	addi	a1,s0,-80
    80005796:	f3040513          	addi	a0,s0,-208
    8000579a:	fffff097          	auipc	ra,0xfffff
    8000579e:	9c0080e7          	jalr	-1600(ra) # 8000415a <nameiparent>
    800057a2:	84aa                	mv	s1,a0
    800057a4:	c979                	beqz	a0,8000587a <sys_unlink+0x114>
  ilock(dp);
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	1f0080e7          	jalr	496(ra) # 80003996 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057ae:	00003597          	auipc	a1,0x3
    800057b2:	f6258593          	addi	a1,a1,-158 # 80008710 <syscalls+0x2c0>
    800057b6:	fb040513          	addi	a0,s0,-80
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	6a6080e7          	jalr	1702(ra) # 80003e60 <namecmp>
    800057c2:	14050a63          	beqz	a0,80005916 <sys_unlink+0x1b0>
    800057c6:	00003597          	auipc	a1,0x3
    800057ca:	f5258593          	addi	a1,a1,-174 # 80008718 <syscalls+0x2c8>
    800057ce:	fb040513          	addi	a0,s0,-80
    800057d2:	ffffe097          	auipc	ra,0xffffe
    800057d6:	68e080e7          	jalr	1678(ra) # 80003e60 <namecmp>
    800057da:	12050e63          	beqz	a0,80005916 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057de:	f2c40613          	addi	a2,s0,-212
    800057e2:	fb040593          	addi	a1,s0,-80
    800057e6:	8526                	mv	a0,s1
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	692080e7          	jalr	1682(ra) # 80003e7a <dirlookup>
    800057f0:	892a                	mv	s2,a0
    800057f2:	12050263          	beqz	a0,80005916 <sys_unlink+0x1b0>
  ilock(ip);
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	1a0080e7          	jalr	416(ra) # 80003996 <ilock>
  if(ip->nlink < 1)
    800057fe:	04a91783          	lh	a5,74(s2)
    80005802:	08f05263          	blez	a5,80005886 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005806:	04491703          	lh	a4,68(s2)
    8000580a:	4785                	li	a5,1
    8000580c:	08f70563          	beq	a4,a5,80005896 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005810:	4641                	li	a2,16
    80005812:	4581                	li	a1,0
    80005814:	fc040513          	addi	a0,s0,-64
    80005818:	ffffb097          	auipc	ra,0xffffb
    8000581c:	4ba080e7          	jalr	1210(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005820:	4741                	li	a4,16
    80005822:	f2c42683          	lw	a3,-212(s0)
    80005826:	fc040613          	addi	a2,s0,-64
    8000582a:	4581                	li	a1,0
    8000582c:	8526                	mv	a0,s1
    8000582e:	ffffe097          	auipc	ra,0xffffe
    80005832:	514080e7          	jalr	1300(ra) # 80003d42 <writei>
    80005836:	47c1                	li	a5,16
    80005838:	0af51563          	bne	a0,a5,800058e2 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000583c:	04491703          	lh	a4,68(s2)
    80005840:	4785                	li	a5,1
    80005842:	0af70863          	beq	a4,a5,800058f2 <sys_unlink+0x18c>
  iunlockput(dp);
    80005846:	8526                	mv	a0,s1
    80005848:	ffffe097          	auipc	ra,0xffffe
    8000584c:	3b0080e7          	jalr	944(ra) # 80003bf8 <iunlockput>
  ip->nlink--;
    80005850:	04a95783          	lhu	a5,74(s2)
    80005854:	37fd                	addiw	a5,a5,-1
    80005856:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000585a:	854a                	mv	a0,s2
    8000585c:	ffffe097          	auipc	ra,0xffffe
    80005860:	070080e7          	jalr	112(ra) # 800038cc <iupdate>
  iunlockput(ip);
    80005864:	854a                	mv	a0,s2
    80005866:	ffffe097          	auipc	ra,0xffffe
    8000586a:	392080e7          	jalr	914(ra) # 80003bf8 <iunlockput>
  end_op();
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	b6a080e7          	jalr	-1174(ra) # 800043d8 <end_op>
  return 0;
    80005876:	4501                	li	a0,0
    80005878:	a84d                	j	8000592a <sys_unlink+0x1c4>
    end_op();
    8000587a:	fffff097          	auipc	ra,0xfffff
    8000587e:	b5e080e7          	jalr	-1186(ra) # 800043d8 <end_op>
    return -1;
    80005882:	557d                	li	a0,-1
    80005884:	a05d                	j	8000592a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005886:	00003517          	auipc	a0,0x3
    8000588a:	e9a50513          	addi	a0,a0,-358 # 80008720 <syscalls+0x2d0>
    8000588e:	ffffb097          	auipc	ra,0xffffb
    80005892:	cb0080e7          	jalr	-848(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005896:	04c92703          	lw	a4,76(s2)
    8000589a:	02000793          	li	a5,32
    8000589e:	f6e7f9e3          	bgeu	a5,a4,80005810 <sys_unlink+0xaa>
    800058a2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058a6:	4741                	li	a4,16
    800058a8:	86ce                	mv	a3,s3
    800058aa:	f1840613          	addi	a2,s0,-232
    800058ae:	4581                	li	a1,0
    800058b0:	854a                	mv	a0,s2
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	398080e7          	jalr	920(ra) # 80003c4a <readi>
    800058ba:	47c1                	li	a5,16
    800058bc:	00f51b63          	bne	a0,a5,800058d2 <sys_unlink+0x16c>
    if(de.inum != 0)
    800058c0:	f1845783          	lhu	a5,-232(s0)
    800058c4:	e7a1                	bnez	a5,8000590c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058c6:	29c1                	addiw	s3,s3,16
    800058c8:	04c92783          	lw	a5,76(s2)
    800058cc:	fcf9ede3          	bltu	s3,a5,800058a6 <sys_unlink+0x140>
    800058d0:	b781                	j	80005810 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058d2:	00003517          	auipc	a0,0x3
    800058d6:	e6650513          	addi	a0,a0,-410 # 80008738 <syscalls+0x2e8>
    800058da:	ffffb097          	auipc	ra,0xffffb
    800058de:	c64080e7          	jalr	-924(ra) # 8000053e <panic>
    panic("unlink: writei");
    800058e2:	00003517          	auipc	a0,0x3
    800058e6:	e6e50513          	addi	a0,a0,-402 # 80008750 <syscalls+0x300>
    800058ea:	ffffb097          	auipc	ra,0xffffb
    800058ee:	c54080e7          	jalr	-940(ra) # 8000053e <panic>
    dp->nlink--;
    800058f2:	04a4d783          	lhu	a5,74(s1)
    800058f6:	37fd                	addiw	a5,a5,-1
    800058f8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058fc:	8526                	mv	a0,s1
    800058fe:	ffffe097          	auipc	ra,0xffffe
    80005902:	fce080e7          	jalr	-50(ra) # 800038cc <iupdate>
    80005906:	b781                	j	80005846 <sys_unlink+0xe0>
    return -1;
    80005908:	557d                	li	a0,-1
    8000590a:	a005                	j	8000592a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000590c:	854a                	mv	a0,s2
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	2ea080e7          	jalr	746(ra) # 80003bf8 <iunlockput>
  iunlockput(dp);
    80005916:	8526                	mv	a0,s1
    80005918:	ffffe097          	auipc	ra,0xffffe
    8000591c:	2e0080e7          	jalr	736(ra) # 80003bf8 <iunlockput>
  end_op();
    80005920:	fffff097          	auipc	ra,0xfffff
    80005924:	ab8080e7          	jalr	-1352(ra) # 800043d8 <end_op>
  return -1;
    80005928:	557d                	li	a0,-1
}
    8000592a:	70ae                	ld	ra,232(sp)
    8000592c:	740e                	ld	s0,224(sp)
    8000592e:	64ee                	ld	s1,216(sp)
    80005930:	694e                	ld	s2,208(sp)
    80005932:	69ae                	ld	s3,200(sp)
    80005934:	616d                	addi	sp,sp,240
    80005936:	8082                	ret

0000000080005938 <sys_open>:

uint64
sys_open(void)
{
    80005938:	7131                	addi	sp,sp,-192
    8000593a:	fd06                	sd	ra,184(sp)
    8000593c:	f922                	sd	s0,176(sp)
    8000593e:	f526                	sd	s1,168(sp)
    80005940:	f14a                	sd	s2,160(sp)
    80005942:	ed4e                	sd	s3,152(sp)
    80005944:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005946:	f4c40593          	addi	a1,s0,-180
    8000594a:	4505                	li	a0,1
    8000594c:	ffffd097          	auipc	ra,0xffffd
    80005950:	426080e7          	jalr	1062(ra) # 80002d72 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005954:	08000613          	li	a2,128
    80005958:	f5040593          	addi	a1,s0,-176
    8000595c:	4501                	li	a0,0
    8000595e:	ffffd097          	auipc	ra,0xffffd
    80005962:	454080e7          	jalr	1108(ra) # 80002db2 <argstr>
    80005966:	87aa                	mv	a5,a0
    return -1;
    80005968:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000596a:	0a07c963          	bltz	a5,80005a1c <sys_open+0xe4>

  begin_op();
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	9ea080e7          	jalr	-1558(ra) # 80004358 <begin_op>

  if(omode & O_CREATE){
    80005976:	f4c42783          	lw	a5,-180(s0)
    8000597a:	2007f793          	andi	a5,a5,512
    8000597e:	cfc5                	beqz	a5,80005a36 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005980:	4681                	li	a3,0
    80005982:	4601                	li	a2,0
    80005984:	4589                	li	a1,2
    80005986:	f5040513          	addi	a0,s0,-176
    8000598a:	00000097          	auipc	ra,0x0
    8000598e:	976080e7          	jalr	-1674(ra) # 80005300 <create>
    80005992:	84aa                	mv	s1,a0
    if(ip == 0){
    80005994:	c959                	beqz	a0,80005a2a <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005996:	04449703          	lh	a4,68(s1)
    8000599a:	478d                	li	a5,3
    8000599c:	00f71763          	bne	a4,a5,800059aa <sys_open+0x72>
    800059a0:	0464d703          	lhu	a4,70(s1)
    800059a4:	47a5                	li	a5,9
    800059a6:	0ce7ed63          	bltu	a5,a4,80005a80 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059aa:	fffff097          	auipc	ra,0xfffff
    800059ae:	dbe080e7          	jalr	-578(ra) # 80004768 <filealloc>
    800059b2:	89aa                	mv	s3,a0
    800059b4:	10050363          	beqz	a0,80005aba <sys_open+0x182>
    800059b8:	00000097          	auipc	ra,0x0
    800059bc:	906080e7          	jalr	-1786(ra) # 800052be <fdalloc>
    800059c0:	892a                	mv	s2,a0
    800059c2:	0e054763          	bltz	a0,80005ab0 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059c6:	04449703          	lh	a4,68(s1)
    800059ca:	478d                	li	a5,3
    800059cc:	0cf70563          	beq	a4,a5,80005a96 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059d0:	4789                	li	a5,2
    800059d2:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800059d6:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800059da:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800059de:	f4c42783          	lw	a5,-180(s0)
    800059e2:	0017c713          	xori	a4,a5,1
    800059e6:	8b05                	andi	a4,a4,1
    800059e8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059ec:	0037f713          	andi	a4,a5,3
    800059f0:	00e03733          	snez	a4,a4
    800059f4:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059f8:	4007f793          	andi	a5,a5,1024
    800059fc:	c791                	beqz	a5,80005a08 <sys_open+0xd0>
    800059fe:	04449703          	lh	a4,68(s1)
    80005a02:	4789                	li	a5,2
    80005a04:	0af70063          	beq	a4,a5,80005aa4 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005a08:	8526                	mv	a0,s1
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	04e080e7          	jalr	78(ra) # 80003a58 <iunlock>
  end_op();
    80005a12:	fffff097          	auipc	ra,0xfffff
    80005a16:	9c6080e7          	jalr	-1594(ra) # 800043d8 <end_op>

  return fd;
    80005a1a:	854a                	mv	a0,s2
}
    80005a1c:	70ea                	ld	ra,184(sp)
    80005a1e:	744a                	ld	s0,176(sp)
    80005a20:	74aa                	ld	s1,168(sp)
    80005a22:	790a                	ld	s2,160(sp)
    80005a24:	69ea                	ld	s3,152(sp)
    80005a26:	6129                	addi	sp,sp,192
    80005a28:	8082                	ret
      end_op();
    80005a2a:	fffff097          	auipc	ra,0xfffff
    80005a2e:	9ae080e7          	jalr	-1618(ra) # 800043d8 <end_op>
      return -1;
    80005a32:	557d                	li	a0,-1
    80005a34:	b7e5                	j	80005a1c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a36:	f5040513          	addi	a0,s0,-176
    80005a3a:	ffffe097          	auipc	ra,0xffffe
    80005a3e:	702080e7          	jalr	1794(ra) # 8000413c <namei>
    80005a42:	84aa                	mv	s1,a0
    80005a44:	c905                	beqz	a0,80005a74 <sys_open+0x13c>
    ilock(ip);
    80005a46:	ffffe097          	auipc	ra,0xffffe
    80005a4a:	f50080e7          	jalr	-176(ra) # 80003996 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a4e:	04449703          	lh	a4,68(s1)
    80005a52:	4785                	li	a5,1
    80005a54:	f4f711e3          	bne	a4,a5,80005996 <sys_open+0x5e>
    80005a58:	f4c42783          	lw	a5,-180(s0)
    80005a5c:	d7b9                	beqz	a5,800059aa <sys_open+0x72>
      iunlockput(ip);
    80005a5e:	8526                	mv	a0,s1
    80005a60:	ffffe097          	auipc	ra,0xffffe
    80005a64:	198080e7          	jalr	408(ra) # 80003bf8 <iunlockput>
      end_op();
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	970080e7          	jalr	-1680(ra) # 800043d8 <end_op>
      return -1;
    80005a70:	557d                	li	a0,-1
    80005a72:	b76d                	j	80005a1c <sys_open+0xe4>
      end_op();
    80005a74:	fffff097          	auipc	ra,0xfffff
    80005a78:	964080e7          	jalr	-1692(ra) # 800043d8 <end_op>
      return -1;
    80005a7c:	557d                	li	a0,-1
    80005a7e:	bf79                	j	80005a1c <sys_open+0xe4>
    iunlockput(ip);
    80005a80:	8526                	mv	a0,s1
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	176080e7          	jalr	374(ra) # 80003bf8 <iunlockput>
    end_op();
    80005a8a:	fffff097          	auipc	ra,0xfffff
    80005a8e:	94e080e7          	jalr	-1714(ra) # 800043d8 <end_op>
    return -1;
    80005a92:	557d                	li	a0,-1
    80005a94:	b761                	j	80005a1c <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a96:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a9a:	04649783          	lh	a5,70(s1)
    80005a9e:	02f99223          	sh	a5,36(s3)
    80005aa2:	bf25                	j	800059da <sys_open+0xa2>
    itrunc(ip);
    80005aa4:	8526                	mv	a0,s1
    80005aa6:	ffffe097          	auipc	ra,0xffffe
    80005aaa:	ffe080e7          	jalr	-2(ra) # 80003aa4 <itrunc>
    80005aae:	bfa9                	j	80005a08 <sys_open+0xd0>
      fileclose(f);
    80005ab0:	854e                	mv	a0,s3
    80005ab2:	fffff097          	auipc	ra,0xfffff
    80005ab6:	d72080e7          	jalr	-654(ra) # 80004824 <fileclose>
    iunlockput(ip);
    80005aba:	8526                	mv	a0,s1
    80005abc:	ffffe097          	auipc	ra,0xffffe
    80005ac0:	13c080e7          	jalr	316(ra) # 80003bf8 <iunlockput>
    end_op();
    80005ac4:	fffff097          	auipc	ra,0xfffff
    80005ac8:	914080e7          	jalr	-1772(ra) # 800043d8 <end_op>
    return -1;
    80005acc:	557d                	li	a0,-1
    80005ace:	b7b9                	j	80005a1c <sys_open+0xe4>

0000000080005ad0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ad0:	7175                	addi	sp,sp,-144
    80005ad2:	e506                	sd	ra,136(sp)
    80005ad4:	e122                	sd	s0,128(sp)
    80005ad6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	880080e7          	jalr	-1920(ra) # 80004358 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ae0:	08000613          	li	a2,128
    80005ae4:	f7040593          	addi	a1,s0,-144
    80005ae8:	4501                	li	a0,0
    80005aea:	ffffd097          	auipc	ra,0xffffd
    80005aee:	2c8080e7          	jalr	712(ra) # 80002db2 <argstr>
    80005af2:	02054963          	bltz	a0,80005b24 <sys_mkdir+0x54>
    80005af6:	4681                	li	a3,0
    80005af8:	4601                	li	a2,0
    80005afa:	4585                	li	a1,1
    80005afc:	f7040513          	addi	a0,s0,-144
    80005b00:	00000097          	auipc	ra,0x0
    80005b04:	800080e7          	jalr	-2048(ra) # 80005300 <create>
    80005b08:	cd11                	beqz	a0,80005b24 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b0a:	ffffe097          	auipc	ra,0xffffe
    80005b0e:	0ee080e7          	jalr	238(ra) # 80003bf8 <iunlockput>
  end_op();
    80005b12:	fffff097          	auipc	ra,0xfffff
    80005b16:	8c6080e7          	jalr	-1850(ra) # 800043d8 <end_op>
  return 0;
    80005b1a:	4501                	li	a0,0
}
    80005b1c:	60aa                	ld	ra,136(sp)
    80005b1e:	640a                	ld	s0,128(sp)
    80005b20:	6149                	addi	sp,sp,144
    80005b22:	8082                	ret
    end_op();
    80005b24:	fffff097          	auipc	ra,0xfffff
    80005b28:	8b4080e7          	jalr	-1868(ra) # 800043d8 <end_op>
    return -1;
    80005b2c:	557d                	li	a0,-1
    80005b2e:	b7fd                	j	80005b1c <sys_mkdir+0x4c>

0000000080005b30 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b30:	7135                	addi	sp,sp,-160
    80005b32:	ed06                	sd	ra,152(sp)
    80005b34:	e922                	sd	s0,144(sp)
    80005b36:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	820080e7          	jalr	-2016(ra) # 80004358 <begin_op>
  argint(1, &major);
    80005b40:	f6c40593          	addi	a1,s0,-148
    80005b44:	4505                	li	a0,1
    80005b46:	ffffd097          	auipc	ra,0xffffd
    80005b4a:	22c080e7          	jalr	556(ra) # 80002d72 <argint>
  argint(2, &minor);
    80005b4e:	f6840593          	addi	a1,s0,-152
    80005b52:	4509                	li	a0,2
    80005b54:	ffffd097          	auipc	ra,0xffffd
    80005b58:	21e080e7          	jalr	542(ra) # 80002d72 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b5c:	08000613          	li	a2,128
    80005b60:	f7040593          	addi	a1,s0,-144
    80005b64:	4501                	li	a0,0
    80005b66:	ffffd097          	auipc	ra,0xffffd
    80005b6a:	24c080e7          	jalr	588(ra) # 80002db2 <argstr>
    80005b6e:	02054b63          	bltz	a0,80005ba4 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b72:	f6841683          	lh	a3,-152(s0)
    80005b76:	f6c41603          	lh	a2,-148(s0)
    80005b7a:	458d                	li	a1,3
    80005b7c:	f7040513          	addi	a0,s0,-144
    80005b80:	fffff097          	auipc	ra,0xfffff
    80005b84:	780080e7          	jalr	1920(ra) # 80005300 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b88:	cd11                	beqz	a0,80005ba4 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	06e080e7          	jalr	110(ra) # 80003bf8 <iunlockput>
  end_op();
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	846080e7          	jalr	-1978(ra) # 800043d8 <end_op>
  return 0;
    80005b9a:	4501                	li	a0,0
}
    80005b9c:	60ea                	ld	ra,152(sp)
    80005b9e:	644a                	ld	s0,144(sp)
    80005ba0:	610d                	addi	sp,sp,160
    80005ba2:	8082                	ret
    end_op();
    80005ba4:	fffff097          	auipc	ra,0xfffff
    80005ba8:	834080e7          	jalr	-1996(ra) # 800043d8 <end_op>
    return -1;
    80005bac:	557d                	li	a0,-1
    80005bae:	b7fd                	j	80005b9c <sys_mknod+0x6c>

0000000080005bb0 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bb0:	7135                	addi	sp,sp,-160
    80005bb2:	ed06                	sd	ra,152(sp)
    80005bb4:	e922                	sd	s0,144(sp)
    80005bb6:	e526                	sd	s1,136(sp)
    80005bb8:	e14a                	sd	s2,128(sp)
    80005bba:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bbc:	ffffc097          	auipc	ra,0xffffc
    80005bc0:	df0080e7          	jalr	-528(ra) # 800019ac <myproc>
    80005bc4:	892a                	mv	s2,a0
  
  begin_op();
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	792080e7          	jalr	1938(ra) # 80004358 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bce:	08000613          	li	a2,128
    80005bd2:	f6040593          	addi	a1,s0,-160
    80005bd6:	4501                	li	a0,0
    80005bd8:	ffffd097          	auipc	ra,0xffffd
    80005bdc:	1da080e7          	jalr	474(ra) # 80002db2 <argstr>
    80005be0:	04054b63          	bltz	a0,80005c36 <sys_chdir+0x86>
    80005be4:	f6040513          	addi	a0,s0,-160
    80005be8:	ffffe097          	auipc	ra,0xffffe
    80005bec:	554080e7          	jalr	1364(ra) # 8000413c <namei>
    80005bf0:	84aa                	mv	s1,a0
    80005bf2:	c131                	beqz	a0,80005c36 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bf4:	ffffe097          	auipc	ra,0xffffe
    80005bf8:	da2080e7          	jalr	-606(ra) # 80003996 <ilock>
  if(ip->type != T_DIR){
    80005bfc:	04449703          	lh	a4,68(s1)
    80005c00:	4785                	li	a5,1
    80005c02:	04f71063          	bne	a4,a5,80005c42 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c06:	8526                	mv	a0,s1
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	e50080e7          	jalr	-432(ra) # 80003a58 <iunlock>
  iput(p->cwd);
    80005c10:	15093503          	ld	a0,336(s2)
    80005c14:	ffffe097          	auipc	ra,0xffffe
    80005c18:	f3c080e7          	jalr	-196(ra) # 80003b50 <iput>
  end_op();
    80005c1c:	ffffe097          	auipc	ra,0xffffe
    80005c20:	7bc080e7          	jalr	1980(ra) # 800043d8 <end_op>
  p->cwd = ip;
    80005c24:	14993823          	sd	s1,336(s2)
  return 0;
    80005c28:	4501                	li	a0,0
}
    80005c2a:	60ea                	ld	ra,152(sp)
    80005c2c:	644a                	ld	s0,144(sp)
    80005c2e:	64aa                	ld	s1,136(sp)
    80005c30:	690a                	ld	s2,128(sp)
    80005c32:	610d                	addi	sp,sp,160
    80005c34:	8082                	ret
    end_op();
    80005c36:	ffffe097          	auipc	ra,0xffffe
    80005c3a:	7a2080e7          	jalr	1954(ra) # 800043d8 <end_op>
    return -1;
    80005c3e:	557d                	li	a0,-1
    80005c40:	b7ed                	j	80005c2a <sys_chdir+0x7a>
    iunlockput(ip);
    80005c42:	8526                	mv	a0,s1
    80005c44:	ffffe097          	auipc	ra,0xffffe
    80005c48:	fb4080e7          	jalr	-76(ra) # 80003bf8 <iunlockput>
    end_op();
    80005c4c:	ffffe097          	auipc	ra,0xffffe
    80005c50:	78c080e7          	jalr	1932(ra) # 800043d8 <end_op>
    return -1;
    80005c54:	557d                	li	a0,-1
    80005c56:	bfd1                	j	80005c2a <sys_chdir+0x7a>

0000000080005c58 <sys_exec>:

uint64
sys_exec(void)
{
    80005c58:	7145                	addi	sp,sp,-464
    80005c5a:	e786                	sd	ra,456(sp)
    80005c5c:	e3a2                	sd	s0,448(sp)
    80005c5e:	ff26                	sd	s1,440(sp)
    80005c60:	fb4a                	sd	s2,432(sp)
    80005c62:	f74e                	sd	s3,424(sp)
    80005c64:	f352                	sd	s4,416(sp)
    80005c66:	ef56                	sd	s5,408(sp)
    80005c68:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c6a:	e3840593          	addi	a1,s0,-456
    80005c6e:	4505                	li	a0,1
    80005c70:	ffffd097          	auipc	ra,0xffffd
    80005c74:	122080e7          	jalr	290(ra) # 80002d92 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c78:	08000613          	li	a2,128
    80005c7c:	f4040593          	addi	a1,s0,-192
    80005c80:	4501                	li	a0,0
    80005c82:	ffffd097          	auipc	ra,0xffffd
    80005c86:	130080e7          	jalr	304(ra) # 80002db2 <argstr>
    80005c8a:	87aa                	mv	a5,a0
    return -1;
    80005c8c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c8e:	0c07c263          	bltz	a5,80005d52 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c92:	10000613          	li	a2,256
    80005c96:	4581                	li	a1,0
    80005c98:	e4040513          	addi	a0,s0,-448
    80005c9c:	ffffb097          	auipc	ra,0xffffb
    80005ca0:	036080e7          	jalr	54(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ca4:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005ca8:	89a6                	mv	s3,s1
    80005caa:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005cac:	02000a13          	li	s4,32
    80005cb0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cb4:	00391793          	slli	a5,s2,0x3
    80005cb8:	e3040593          	addi	a1,s0,-464
    80005cbc:	e3843503          	ld	a0,-456(s0)
    80005cc0:	953e                	add	a0,a0,a5
    80005cc2:	ffffd097          	auipc	ra,0xffffd
    80005cc6:	012080e7          	jalr	18(ra) # 80002cd4 <fetchaddr>
    80005cca:	02054a63          	bltz	a0,80005cfe <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005cce:	e3043783          	ld	a5,-464(s0)
    80005cd2:	c3b9                	beqz	a5,80005d18 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cd4:	ffffb097          	auipc	ra,0xffffb
    80005cd8:	e12080e7          	jalr	-494(ra) # 80000ae6 <kalloc>
    80005cdc:	85aa                	mv	a1,a0
    80005cde:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ce2:	cd11                	beqz	a0,80005cfe <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ce4:	6605                	lui	a2,0x1
    80005ce6:	e3043503          	ld	a0,-464(s0)
    80005cea:	ffffd097          	auipc	ra,0xffffd
    80005cee:	03c080e7          	jalr	60(ra) # 80002d26 <fetchstr>
    80005cf2:	00054663          	bltz	a0,80005cfe <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005cf6:	0905                	addi	s2,s2,1
    80005cf8:	09a1                	addi	s3,s3,8
    80005cfa:	fb491be3          	bne	s2,s4,80005cb0 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cfe:	10048913          	addi	s2,s1,256
    80005d02:	6088                	ld	a0,0(s1)
    80005d04:	c531                	beqz	a0,80005d50 <sys_exec+0xf8>
    kfree(argv[i]);
    80005d06:	ffffb097          	auipc	ra,0xffffb
    80005d0a:	ce4080e7          	jalr	-796(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d0e:	04a1                	addi	s1,s1,8
    80005d10:	ff2499e3          	bne	s1,s2,80005d02 <sys_exec+0xaa>
  return -1;
    80005d14:	557d                	li	a0,-1
    80005d16:	a835                	j	80005d52 <sys_exec+0xfa>
      argv[i] = 0;
    80005d18:	0a8e                	slli	s5,s5,0x3
    80005d1a:	fc040793          	addi	a5,s0,-64
    80005d1e:	9abe                	add	s5,s5,a5
    80005d20:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d24:	e4040593          	addi	a1,s0,-448
    80005d28:	f4040513          	addi	a0,s0,-192
    80005d2c:	fffff097          	auipc	ra,0xfffff
    80005d30:	172080e7          	jalr	370(ra) # 80004e9e <exec>
    80005d34:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d36:	10048993          	addi	s3,s1,256
    80005d3a:	6088                	ld	a0,0(s1)
    80005d3c:	c901                	beqz	a0,80005d4c <sys_exec+0xf4>
    kfree(argv[i]);
    80005d3e:	ffffb097          	auipc	ra,0xffffb
    80005d42:	cac080e7          	jalr	-852(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d46:	04a1                	addi	s1,s1,8
    80005d48:	ff3499e3          	bne	s1,s3,80005d3a <sys_exec+0xe2>
  return ret;
    80005d4c:	854a                	mv	a0,s2
    80005d4e:	a011                	j	80005d52 <sys_exec+0xfa>
  return -1;
    80005d50:	557d                	li	a0,-1
}
    80005d52:	60be                	ld	ra,456(sp)
    80005d54:	641e                	ld	s0,448(sp)
    80005d56:	74fa                	ld	s1,440(sp)
    80005d58:	795a                	ld	s2,432(sp)
    80005d5a:	79ba                	ld	s3,424(sp)
    80005d5c:	7a1a                	ld	s4,416(sp)
    80005d5e:	6afa                	ld	s5,408(sp)
    80005d60:	6179                	addi	sp,sp,464
    80005d62:	8082                	ret

0000000080005d64 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d64:	7139                	addi	sp,sp,-64
    80005d66:	fc06                	sd	ra,56(sp)
    80005d68:	f822                	sd	s0,48(sp)
    80005d6a:	f426                	sd	s1,40(sp)
    80005d6c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d6e:	ffffc097          	auipc	ra,0xffffc
    80005d72:	c3e080e7          	jalr	-962(ra) # 800019ac <myproc>
    80005d76:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d78:	fd840593          	addi	a1,s0,-40
    80005d7c:	4501                	li	a0,0
    80005d7e:	ffffd097          	auipc	ra,0xffffd
    80005d82:	014080e7          	jalr	20(ra) # 80002d92 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d86:	fc840593          	addi	a1,s0,-56
    80005d8a:	fd040513          	addi	a0,s0,-48
    80005d8e:	fffff097          	auipc	ra,0xfffff
    80005d92:	dc6080e7          	jalr	-570(ra) # 80004b54 <pipealloc>
    return -1;
    80005d96:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d98:	0c054463          	bltz	a0,80005e60 <sys_pipe+0xfc>
  fd0 = -1;
    80005d9c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005da0:	fd043503          	ld	a0,-48(s0)
    80005da4:	fffff097          	auipc	ra,0xfffff
    80005da8:	51a080e7          	jalr	1306(ra) # 800052be <fdalloc>
    80005dac:	fca42223          	sw	a0,-60(s0)
    80005db0:	08054b63          	bltz	a0,80005e46 <sys_pipe+0xe2>
    80005db4:	fc843503          	ld	a0,-56(s0)
    80005db8:	fffff097          	auipc	ra,0xfffff
    80005dbc:	506080e7          	jalr	1286(ra) # 800052be <fdalloc>
    80005dc0:	fca42023          	sw	a0,-64(s0)
    80005dc4:	06054863          	bltz	a0,80005e34 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dc8:	4691                	li	a3,4
    80005dca:	fc440613          	addi	a2,s0,-60
    80005dce:	fd843583          	ld	a1,-40(s0)
    80005dd2:	68a8                	ld	a0,80(s1)
    80005dd4:	ffffc097          	auipc	ra,0xffffc
    80005dd8:	894080e7          	jalr	-1900(ra) # 80001668 <copyout>
    80005ddc:	02054063          	bltz	a0,80005dfc <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005de0:	4691                	li	a3,4
    80005de2:	fc040613          	addi	a2,s0,-64
    80005de6:	fd843583          	ld	a1,-40(s0)
    80005dea:	0591                	addi	a1,a1,4
    80005dec:	68a8                	ld	a0,80(s1)
    80005dee:	ffffc097          	auipc	ra,0xffffc
    80005df2:	87a080e7          	jalr	-1926(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005df6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005df8:	06055463          	bgez	a0,80005e60 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005dfc:	fc442783          	lw	a5,-60(s0)
    80005e00:	07e9                	addi	a5,a5,26
    80005e02:	078e                	slli	a5,a5,0x3
    80005e04:	97a6                	add	a5,a5,s1
    80005e06:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e0a:	fc042503          	lw	a0,-64(s0)
    80005e0e:	0569                	addi	a0,a0,26
    80005e10:	050e                	slli	a0,a0,0x3
    80005e12:	94aa                	add	s1,s1,a0
    80005e14:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e18:	fd043503          	ld	a0,-48(s0)
    80005e1c:	fffff097          	auipc	ra,0xfffff
    80005e20:	a08080e7          	jalr	-1528(ra) # 80004824 <fileclose>
    fileclose(wf);
    80005e24:	fc843503          	ld	a0,-56(s0)
    80005e28:	fffff097          	auipc	ra,0xfffff
    80005e2c:	9fc080e7          	jalr	-1540(ra) # 80004824 <fileclose>
    return -1;
    80005e30:	57fd                	li	a5,-1
    80005e32:	a03d                	j	80005e60 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005e34:	fc442783          	lw	a5,-60(s0)
    80005e38:	0007c763          	bltz	a5,80005e46 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005e3c:	07e9                	addi	a5,a5,26
    80005e3e:	078e                	slli	a5,a5,0x3
    80005e40:	94be                	add	s1,s1,a5
    80005e42:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e46:	fd043503          	ld	a0,-48(s0)
    80005e4a:	fffff097          	auipc	ra,0xfffff
    80005e4e:	9da080e7          	jalr	-1574(ra) # 80004824 <fileclose>
    fileclose(wf);
    80005e52:	fc843503          	ld	a0,-56(s0)
    80005e56:	fffff097          	auipc	ra,0xfffff
    80005e5a:	9ce080e7          	jalr	-1586(ra) # 80004824 <fileclose>
    return -1;
    80005e5e:	57fd                	li	a5,-1
}
    80005e60:	853e                	mv	a0,a5
    80005e62:	70e2                	ld	ra,56(sp)
    80005e64:	7442                	ld	s0,48(sp)
    80005e66:	74a2                	ld	s1,40(sp)
    80005e68:	6121                	addi	sp,sp,64
    80005e6a:	8082                	ret

0000000080005e6c <sys_getreadcount>:

uint64 
sys_getreadcount(void)
{
    80005e6c:	1141                	addi	sp,sp,-16
    80005e6e:	e422                	sd	s0,8(sp)
    80005e70:	0800                	addi	s0,sp,16

 return readcount1;
}
    80005e72:	00003517          	auipc	a0,0x3
    80005e76:	a8e52503          	lw	a0,-1394(a0) # 80008900 <readcount1>
    80005e7a:	6422                	ld	s0,8(sp)
    80005e7c:	0141                	addi	sp,sp,16
    80005e7e:	8082                	ret

0000000080005e80 <sys_sigalarm>:




uint64
sys_sigalarm(int num, void (* handler)()){
    80005e80:	7139                	addi	sp,sp,-64
    80005e82:	fc06                	sd	ra,56(sp)
    80005e84:	f822                	sd	s0,48(sp)
    80005e86:	f426                	sd	s1,40(sp)
    80005e88:	f04a                	sd	s2,32(sp)
    80005e8a:	ec4e                	sd	s3,24(sp)
    80005e8c:	0080                	addi	s0,sp,64
    80005e8e:	892a                	mv	s2,a0
  
  struct proc *p = myproc();
    80005e90:	ffffc097          	auipc	ra,0xffffc
    80005e94:	b1c080e7          	jalr	-1252(ra) # 800019ac <myproc>
    80005e98:	84aa                	mv	s1,a0


  uint64 addr = -1;
    80005e9a:	59fd                	li	s3,-1
    80005e9c:	fd343423          	sd	s3,-56(s0)
   argaddr(1, &addr);
    80005ea0:	fc840593          	addi	a1,s0,-56
    80005ea4:	4505                	li	a0,1
    80005ea6:	ffffd097          	auipc	ra,0xffffd
    80005eaa:	eec080e7          	jalr	-276(ra) # 80002d92 <argaddr>
   
   if(addr == -1){
    80005eae:	fc843503          	ld	a0,-56(s0)
    80005eb2:	03350d63          	beq	a0,s3,80005eec <sys_sigalarm+0x6c>
   return -1;
   }
   else{
  p->maxticks = num;
    80005eb6:	1724ac23          	sw	s2,376(s1)
  p->address = addr;
    80005eba:	16a4ae23          	sw	a0,380(s1)
  // Initializing the temp trapframe
  p->temp_trapframe = kalloc();
    80005ebe:	ffffb097          	auipc	ra,0xffffb
    80005ec2:	c28080e7          	jalr	-984(ra) # 80000ae6 <kalloc>
    80005ec6:	18a4b023          	sd	a0,384(s1)
  memmove(p->temp_trapframe, p->trapframe, 4096);
    80005eca:	6605                	lui	a2,0x1
    80005ecc:	6cac                	ld	a1,88(s1)
    80005ece:	ffffb097          	auipc	ra,0xffffb
    80005ed2:	e60080e7          	jalr	-416(ra) # 80000d2e <memmove>
  p->temp_ticks = ticks;
    80005ed6:	00003797          	auipc	a5,0x3
    80005eda:	a267a783          	lw	a5,-1498(a5) # 800088fc <ticks>
    80005ede:	18f4a623          	sw	a5,396(s1)
  p->temp_address = addr;
    80005ee2:	fc843783          	ld	a5,-56(s0)
    80005ee6:	18f4a823          	sw	a5,400(s1)
  return 0;
    80005eea:	4501                	li	a0,0
   }
  
}
    80005eec:	70e2                	ld	ra,56(sp)
    80005eee:	7442                	ld	s0,48(sp)
    80005ef0:	74a2                	ld	s1,40(sp)
    80005ef2:	7902                	ld	s2,32(sp)
    80005ef4:	69e2                	ld	s3,24(sp)
    80005ef6:	6121                	addi	sp,sp,64
    80005ef8:	8082                	ret

0000000080005efa <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    80005efa:	1101                	addi	sp,sp,-32
    80005efc:	ec06                	sd	ra,24(sp)
    80005efe:	e822                	sd	s0,16(sp)
    80005f00:	e426                	sd	s1,8(sp)
    80005f02:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80005f04:	ffffc097          	auipc	ra,0xffffc
    80005f08:	aa8080e7          	jalr	-1368(ra) # 800019ac <myproc>
  if(p->trapframe && p->temp_trapframe){
    80005f0c:	6d3c                	ld	a5,88(a0)
    80005f0e:	c3a1                	beqz	a5,80005f4e <sys_sigreturn+0x54>
    80005f10:	84aa                	mv	s1,a0
    80005f12:	18053583          	ld	a1,384(a0)


  return p->trapframe->a0;
  }
  else{
    return -1;
    80005f16:	557d                	li	a0,-1
  if(p->trapframe && p->temp_trapframe){
    80005f18:	c595                	beqz	a1,80005f44 <sys_sigreturn+0x4a>
  memmove(p->trapframe, p->temp_trapframe, 4096);
    80005f1a:	6605                	lui	a2,0x1
    80005f1c:	853e                	mv	a0,a5
    80005f1e:	ffffb097          	auipc	ra,0xffffb
    80005f22:	e10080e7          	jalr	-496(ra) # 80000d2e <memmove>
  p->trapframe->a0 = tf_a0;
    80005f26:	6cbc                	ld	a5,88(s1)
  int tf_a0 = p->temp_trapframe->a0;
    80005f28:	1804b703          	ld	a4,384(s1)
  p->trapframe->a0 = tf_a0;
    80005f2c:	5b38                	lw	a4,112(a4)
    80005f2e:	fbb8                	sd	a4,112(a5)
  p->temp_trapframe = 0;
    80005f30:	1804b023          	sd	zero,384(s1)
  p->alarm_on = 0;
    80005f34:	1804a423          	sw	zero,392(s1)
  p->maxticks = 0;
    80005f38:	1604ac23          	sw	zero,376(s1)
  p->temp_ticks = 0;
    80005f3c:	1804a623          	sw	zero,396(s1)
  return p->trapframe->a0;
    80005f40:	6cbc                	ld	a5,88(s1)
    80005f42:	7ba8                	ld	a0,112(a5)
  }
  
    80005f44:	60e2                	ld	ra,24(sp)
    80005f46:	6442                	ld	s0,16(sp)
    80005f48:	64a2                	ld	s1,8(sp)
    80005f4a:	6105                	addi	sp,sp,32
    80005f4c:	8082                	ret
    return -1;
    80005f4e:	557d                	li	a0,-1
    80005f50:	bfd5                	j	80005f44 <sys_sigreturn+0x4a>
	...

0000000080005f60 <kernelvec>:
    80005f60:	7111                	addi	sp,sp,-256
    80005f62:	e006                	sd	ra,0(sp)
    80005f64:	e40a                	sd	sp,8(sp)
    80005f66:	e80e                	sd	gp,16(sp)
    80005f68:	ec12                	sd	tp,24(sp)
    80005f6a:	f016                	sd	t0,32(sp)
    80005f6c:	f41a                	sd	t1,40(sp)
    80005f6e:	f81e                	sd	t2,48(sp)
    80005f70:	fc22                	sd	s0,56(sp)
    80005f72:	e0a6                	sd	s1,64(sp)
    80005f74:	e4aa                	sd	a0,72(sp)
    80005f76:	e8ae                	sd	a1,80(sp)
    80005f78:	ecb2                	sd	a2,88(sp)
    80005f7a:	f0b6                	sd	a3,96(sp)
    80005f7c:	f4ba                	sd	a4,104(sp)
    80005f7e:	f8be                	sd	a5,112(sp)
    80005f80:	fcc2                	sd	a6,120(sp)
    80005f82:	e146                	sd	a7,128(sp)
    80005f84:	e54a                	sd	s2,136(sp)
    80005f86:	e94e                	sd	s3,144(sp)
    80005f88:	ed52                	sd	s4,152(sp)
    80005f8a:	f156                	sd	s5,160(sp)
    80005f8c:	f55a                	sd	s6,168(sp)
    80005f8e:	f95e                	sd	s7,176(sp)
    80005f90:	fd62                	sd	s8,184(sp)
    80005f92:	e1e6                	sd	s9,192(sp)
    80005f94:	e5ea                	sd	s10,200(sp)
    80005f96:	e9ee                	sd	s11,208(sp)
    80005f98:	edf2                	sd	t3,216(sp)
    80005f9a:	f1f6                	sd	t4,224(sp)
    80005f9c:	f5fa                	sd	t5,232(sp)
    80005f9e:	f9fe                	sd	t6,240(sp)
    80005fa0:	c01fc0ef          	jal	ra,80002ba0 <kerneltrap>
    80005fa4:	6082                	ld	ra,0(sp)
    80005fa6:	6122                	ld	sp,8(sp)
    80005fa8:	61c2                	ld	gp,16(sp)
    80005faa:	7282                	ld	t0,32(sp)
    80005fac:	7322                	ld	t1,40(sp)
    80005fae:	73c2                	ld	t2,48(sp)
    80005fb0:	7462                	ld	s0,56(sp)
    80005fb2:	6486                	ld	s1,64(sp)
    80005fb4:	6526                	ld	a0,72(sp)
    80005fb6:	65c6                	ld	a1,80(sp)
    80005fb8:	6666                	ld	a2,88(sp)
    80005fba:	7686                	ld	a3,96(sp)
    80005fbc:	7726                	ld	a4,104(sp)
    80005fbe:	77c6                	ld	a5,112(sp)
    80005fc0:	7866                	ld	a6,120(sp)
    80005fc2:	688a                	ld	a7,128(sp)
    80005fc4:	692a                	ld	s2,136(sp)
    80005fc6:	69ca                	ld	s3,144(sp)
    80005fc8:	6a6a                	ld	s4,152(sp)
    80005fca:	7a8a                	ld	s5,160(sp)
    80005fcc:	7b2a                	ld	s6,168(sp)
    80005fce:	7bca                	ld	s7,176(sp)
    80005fd0:	7c6a                	ld	s8,184(sp)
    80005fd2:	6c8e                	ld	s9,192(sp)
    80005fd4:	6d2e                	ld	s10,200(sp)
    80005fd6:	6dce                	ld	s11,208(sp)
    80005fd8:	6e6e                	ld	t3,216(sp)
    80005fda:	7e8e                	ld	t4,224(sp)
    80005fdc:	7f2e                	ld	t5,232(sp)
    80005fde:	7fce                	ld	t6,240(sp)
    80005fe0:	6111                	addi	sp,sp,256
    80005fe2:	10200073          	sret
    80005fe6:	00000013          	nop
    80005fea:	00000013          	nop
    80005fee:	0001                	nop

0000000080005ff0 <timervec>:
    80005ff0:	34051573          	csrrw	a0,mscratch,a0
    80005ff4:	e10c                	sd	a1,0(a0)
    80005ff6:	e510                	sd	a2,8(a0)
    80005ff8:	e914                	sd	a3,16(a0)
    80005ffa:	6d0c                	ld	a1,24(a0)
    80005ffc:	7110                	ld	a2,32(a0)
    80005ffe:	6194                	ld	a3,0(a1)
    80006000:	96b2                	add	a3,a3,a2
    80006002:	e194                	sd	a3,0(a1)
    80006004:	4589                	li	a1,2
    80006006:	14459073          	csrw	sip,a1
    8000600a:	6914                	ld	a3,16(a0)
    8000600c:	6510                	ld	a2,8(a0)
    8000600e:	610c                	ld	a1,0(a0)
    80006010:	34051573          	csrrw	a0,mscratch,a0
    80006014:	30200073          	mret
	...

000000008000601a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000601a:	1141                	addi	sp,sp,-16
    8000601c:	e422                	sd	s0,8(sp)
    8000601e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006020:	0c0007b7          	lui	a5,0xc000
    80006024:	4705                	li	a4,1
    80006026:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006028:	c3d8                	sw	a4,4(a5)
}
    8000602a:	6422                	ld	s0,8(sp)
    8000602c:	0141                	addi	sp,sp,16
    8000602e:	8082                	ret

0000000080006030 <plicinithart>:

void
plicinithart(void)
{
    80006030:	1141                	addi	sp,sp,-16
    80006032:	e406                	sd	ra,8(sp)
    80006034:	e022                	sd	s0,0(sp)
    80006036:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006038:	ffffc097          	auipc	ra,0xffffc
    8000603c:	948080e7          	jalr	-1720(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006040:	0085171b          	slliw	a4,a0,0x8
    80006044:	0c0027b7          	lui	a5,0xc002
    80006048:	97ba                	add	a5,a5,a4
    8000604a:	40200713          	li	a4,1026
    8000604e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006052:	00d5151b          	slliw	a0,a0,0xd
    80006056:	0c2017b7          	lui	a5,0xc201
    8000605a:	953e                	add	a0,a0,a5
    8000605c:	00052023          	sw	zero,0(a0)
}
    80006060:	60a2                	ld	ra,8(sp)
    80006062:	6402                	ld	s0,0(sp)
    80006064:	0141                	addi	sp,sp,16
    80006066:	8082                	ret

0000000080006068 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006068:	1141                	addi	sp,sp,-16
    8000606a:	e406                	sd	ra,8(sp)
    8000606c:	e022                	sd	s0,0(sp)
    8000606e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006070:	ffffc097          	auipc	ra,0xffffc
    80006074:	910080e7          	jalr	-1776(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006078:	00d5179b          	slliw	a5,a0,0xd
    8000607c:	0c201537          	lui	a0,0xc201
    80006080:	953e                	add	a0,a0,a5
  return irq;
}
    80006082:	4148                	lw	a0,4(a0)
    80006084:	60a2                	ld	ra,8(sp)
    80006086:	6402                	ld	s0,0(sp)
    80006088:	0141                	addi	sp,sp,16
    8000608a:	8082                	ret

000000008000608c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000608c:	1101                	addi	sp,sp,-32
    8000608e:	ec06                	sd	ra,24(sp)
    80006090:	e822                	sd	s0,16(sp)
    80006092:	e426                	sd	s1,8(sp)
    80006094:	1000                	addi	s0,sp,32
    80006096:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006098:	ffffc097          	auipc	ra,0xffffc
    8000609c:	8e8080e7          	jalr	-1816(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060a0:	00d5151b          	slliw	a0,a0,0xd
    800060a4:	0c2017b7          	lui	a5,0xc201
    800060a8:	97aa                	add	a5,a5,a0
    800060aa:	c3c4                	sw	s1,4(a5)
}
    800060ac:	60e2                	ld	ra,24(sp)
    800060ae:	6442                	ld	s0,16(sp)
    800060b0:	64a2                	ld	s1,8(sp)
    800060b2:	6105                	addi	sp,sp,32
    800060b4:	8082                	ret

00000000800060b6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060b6:	1141                	addi	sp,sp,-16
    800060b8:	e406                	sd	ra,8(sp)
    800060ba:	e022                	sd	s0,0(sp)
    800060bc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060be:	479d                	li	a5,7
    800060c0:	04a7cc63          	blt	a5,a0,80006118 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800060c4:	00021797          	auipc	a5,0x21
    800060c8:	bfc78793          	addi	a5,a5,-1028 # 80026cc0 <disk>
    800060cc:	97aa                	add	a5,a5,a0
    800060ce:	0187c783          	lbu	a5,24(a5)
    800060d2:	ebb9                	bnez	a5,80006128 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060d4:	00451613          	slli	a2,a0,0x4
    800060d8:	00021797          	auipc	a5,0x21
    800060dc:	be878793          	addi	a5,a5,-1048 # 80026cc0 <disk>
    800060e0:	6394                	ld	a3,0(a5)
    800060e2:	96b2                	add	a3,a3,a2
    800060e4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800060e8:	6398                	ld	a4,0(a5)
    800060ea:	9732                	add	a4,a4,a2
    800060ec:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800060f0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800060f4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800060f8:	953e                	add	a0,a0,a5
    800060fa:	4785                	li	a5,1
    800060fc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006100:	00021517          	auipc	a0,0x21
    80006104:	bd850513          	addi	a0,a0,-1064 # 80026cd8 <disk+0x18>
    80006108:	ffffc097          	auipc	ra,0xffffc
    8000610c:	028080e7          	jalr	40(ra) # 80002130 <wakeup>
}
    80006110:	60a2                	ld	ra,8(sp)
    80006112:	6402                	ld	s0,0(sp)
    80006114:	0141                	addi	sp,sp,16
    80006116:	8082                	ret
    panic("free_desc 1");
    80006118:	00002517          	auipc	a0,0x2
    8000611c:	64850513          	addi	a0,a0,1608 # 80008760 <syscalls+0x310>
    80006120:	ffffa097          	auipc	ra,0xffffa
    80006124:	41e080e7          	jalr	1054(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006128:	00002517          	auipc	a0,0x2
    8000612c:	64850513          	addi	a0,a0,1608 # 80008770 <syscalls+0x320>
    80006130:	ffffa097          	auipc	ra,0xffffa
    80006134:	40e080e7          	jalr	1038(ra) # 8000053e <panic>

0000000080006138 <virtio_disk_init>:
{
    80006138:	1101                	addi	sp,sp,-32
    8000613a:	ec06                	sd	ra,24(sp)
    8000613c:	e822                	sd	s0,16(sp)
    8000613e:	e426                	sd	s1,8(sp)
    80006140:	e04a                	sd	s2,0(sp)
    80006142:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006144:	00002597          	auipc	a1,0x2
    80006148:	63c58593          	addi	a1,a1,1596 # 80008780 <syscalls+0x330>
    8000614c:	00021517          	auipc	a0,0x21
    80006150:	c9c50513          	addi	a0,a0,-868 # 80026de8 <disk+0x128>
    80006154:	ffffb097          	auipc	ra,0xffffb
    80006158:	9f2080e7          	jalr	-1550(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000615c:	100017b7          	lui	a5,0x10001
    80006160:	4398                	lw	a4,0(a5)
    80006162:	2701                	sext.w	a4,a4
    80006164:	747277b7          	lui	a5,0x74727
    80006168:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000616c:	14f71c63          	bne	a4,a5,800062c4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006170:	100017b7          	lui	a5,0x10001
    80006174:	43dc                	lw	a5,4(a5)
    80006176:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006178:	4709                	li	a4,2
    8000617a:	14e79563          	bne	a5,a4,800062c4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000617e:	100017b7          	lui	a5,0x10001
    80006182:	479c                	lw	a5,8(a5)
    80006184:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006186:	12e79f63          	bne	a5,a4,800062c4 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000618a:	100017b7          	lui	a5,0x10001
    8000618e:	47d8                	lw	a4,12(a5)
    80006190:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006192:	554d47b7          	lui	a5,0x554d4
    80006196:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000619a:	12f71563          	bne	a4,a5,800062c4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000619e:	100017b7          	lui	a5,0x10001
    800061a2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061a6:	4705                	li	a4,1
    800061a8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061aa:	470d                	li	a4,3
    800061ac:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061ae:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061b0:	c7ffe737          	lui	a4,0xc7ffe
    800061b4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd795f>
    800061b8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061ba:	2701                	sext.w	a4,a4
    800061bc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061be:	472d                	li	a4,11
    800061c0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800061c2:	5bbc                	lw	a5,112(a5)
    800061c4:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800061c8:	8ba1                	andi	a5,a5,8
    800061ca:	10078563          	beqz	a5,800062d4 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061ce:	100017b7          	lui	a5,0x10001
    800061d2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800061d6:	43fc                	lw	a5,68(a5)
    800061d8:	2781                	sext.w	a5,a5
    800061da:	10079563          	bnez	a5,800062e4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061de:	100017b7          	lui	a5,0x10001
    800061e2:	5bdc                	lw	a5,52(a5)
    800061e4:	2781                	sext.w	a5,a5
  if(max == 0)
    800061e6:	10078763          	beqz	a5,800062f4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800061ea:	471d                	li	a4,7
    800061ec:	10f77c63          	bgeu	a4,a5,80006304 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800061f0:	ffffb097          	auipc	ra,0xffffb
    800061f4:	8f6080e7          	jalr	-1802(ra) # 80000ae6 <kalloc>
    800061f8:	00021497          	auipc	s1,0x21
    800061fc:	ac848493          	addi	s1,s1,-1336 # 80026cc0 <disk>
    80006200:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006202:	ffffb097          	auipc	ra,0xffffb
    80006206:	8e4080e7          	jalr	-1820(ra) # 80000ae6 <kalloc>
    8000620a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000620c:	ffffb097          	auipc	ra,0xffffb
    80006210:	8da080e7          	jalr	-1830(ra) # 80000ae6 <kalloc>
    80006214:	87aa                	mv	a5,a0
    80006216:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006218:	6088                	ld	a0,0(s1)
    8000621a:	cd6d                	beqz	a0,80006314 <virtio_disk_init+0x1dc>
    8000621c:	00021717          	auipc	a4,0x21
    80006220:	aac73703          	ld	a4,-1364(a4) # 80026cc8 <disk+0x8>
    80006224:	cb65                	beqz	a4,80006314 <virtio_disk_init+0x1dc>
    80006226:	c7fd                	beqz	a5,80006314 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006228:	6605                	lui	a2,0x1
    8000622a:	4581                	li	a1,0
    8000622c:	ffffb097          	auipc	ra,0xffffb
    80006230:	aa6080e7          	jalr	-1370(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006234:	00021497          	auipc	s1,0x21
    80006238:	a8c48493          	addi	s1,s1,-1396 # 80026cc0 <disk>
    8000623c:	6605                	lui	a2,0x1
    8000623e:	4581                	li	a1,0
    80006240:	6488                	ld	a0,8(s1)
    80006242:	ffffb097          	auipc	ra,0xffffb
    80006246:	a90080e7          	jalr	-1392(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000624a:	6605                	lui	a2,0x1
    8000624c:	4581                	li	a1,0
    8000624e:	6888                	ld	a0,16(s1)
    80006250:	ffffb097          	auipc	ra,0xffffb
    80006254:	a82080e7          	jalr	-1406(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006258:	100017b7          	lui	a5,0x10001
    8000625c:	4721                	li	a4,8
    8000625e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006260:	4098                	lw	a4,0(s1)
    80006262:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006266:	40d8                	lw	a4,4(s1)
    80006268:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000626c:	6498                	ld	a4,8(s1)
    8000626e:	0007069b          	sext.w	a3,a4
    80006272:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006276:	9701                	srai	a4,a4,0x20
    80006278:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000627c:	6898                	ld	a4,16(s1)
    8000627e:	0007069b          	sext.w	a3,a4
    80006282:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006286:	9701                	srai	a4,a4,0x20
    80006288:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000628c:	4705                	li	a4,1
    8000628e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006290:	00e48c23          	sb	a4,24(s1)
    80006294:	00e48ca3          	sb	a4,25(s1)
    80006298:	00e48d23          	sb	a4,26(s1)
    8000629c:	00e48da3          	sb	a4,27(s1)
    800062a0:	00e48e23          	sb	a4,28(s1)
    800062a4:	00e48ea3          	sb	a4,29(s1)
    800062a8:	00e48f23          	sb	a4,30(s1)
    800062ac:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800062b0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800062b4:	0727a823          	sw	s2,112(a5)
}
    800062b8:	60e2                	ld	ra,24(sp)
    800062ba:	6442                	ld	s0,16(sp)
    800062bc:	64a2                	ld	s1,8(sp)
    800062be:	6902                	ld	s2,0(sp)
    800062c0:	6105                	addi	sp,sp,32
    800062c2:	8082                	ret
    panic("could not find virtio disk");
    800062c4:	00002517          	auipc	a0,0x2
    800062c8:	4cc50513          	addi	a0,a0,1228 # 80008790 <syscalls+0x340>
    800062cc:	ffffa097          	auipc	ra,0xffffa
    800062d0:	272080e7          	jalr	626(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    800062d4:	00002517          	auipc	a0,0x2
    800062d8:	4dc50513          	addi	a0,a0,1244 # 800087b0 <syscalls+0x360>
    800062dc:	ffffa097          	auipc	ra,0xffffa
    800062e0:	262080e7          	jalr	610(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    800062e4:	00002517          	auipc	a0,0x2
    800062e8:	4ec50513          	addi	a0,a0,1260 # 800087d0 <syscalls+0x380>
    800062ec:	ffffa097          	auipc	ra,0xffffa
    800062f0:	252080e7          	jalr	594(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800062f4:	00002517          	auipc	a0,0x2
    800062f8:	4fc50513          	addi	a0,a0,1276 # 800087f0 <syscalls+0x3a0>
    800062fc:	ffffa097          	auipc	ra,0xffffa
    80006300:	242080e7          	jalr	578(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006304:	00002517          	auipc	a0,0x2
    80006308:	50c50513          	addi	a0,a0,1292 # 80008810 <syscalls+0x3c0>
    8000630c:	ffffa097          	auipc	ra,0xffffa
    80006310:	232080e7          	jalr	562(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006314:	00002517          	auipc	a0,0x2
    80006318:	51c50513          	addi	a0,a0,1308 # 80008830 <syscalls+0x3e0>
    8000631c:	ffffa097          	auipc	ra,0xffffa
    80006320:	222080e7          	jalr	546(ra) # 8000053e <panic>

0000000080006324 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006324:	7119                	addi	sp,sp,-128
    80006326:	fc86                	sd	ra,120(sp)
    80006328:	f8a2                	sd	s0,112(sp)
    8000632a:	f4a6                	sd	s1,104(sp)
    8000632c:	f0ca                	sd	s2,96(sp)
    8000632e:	ecce                	sd	s3,88(sp)
    80006330:	e8d2                	sd	s4,80(sp)
    80006332:	e4d6                	sd	s5,72(sp)
    80006334:	e0da                	sd	s6,64(sp)
    80006336:	fc5e                	sd	s7,56(sp)
    80006338:	f862                	sd	s8,48(sp)
    8000633a:	f466                	sd	s9,40(sp)
    8000633c:	f06a                	sd	s10,32(sp)
    8000633e:	ec6e                	sd	s11,24(sp)
    80006340:	0100                	addi	s0,sp,128
    80006342:	8aaa                	mv	s5,a0
    80006344:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006346:	00c52d03          	lw	s10,12(a0)
    8000634a:	001d1d1b          	slliw	s10,s10,0x1
    8000634e:	1d02                	slli	s10,s10,0x20
    80006350:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006354:	00021517          	auipc	a0,0x21
    80006358:	a9450513          	addi	a0,a0,-1388 # 80026de8 <disk+0x128>
    8000635c:	ffffb097          	auipc	ra,0xffffb
    80006360:	87a080e7          	jalr	-1926(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006364:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006366:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006368:	00021b97          	auipc	s7,0x21
    8000636c:	958b8b93          	addi	s7,s7,-1704 # 80026cc0 <disk>
  for(int i = 0; i < 3; i++){
    80006370:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006372:	00021c97          	auipc	s9,0x21
    80006376:	a76c8c93          	addi	s9,s9,-1418 # 80026de8 <disk+0x128>
    8000637a:	a08d                	j	800063dc <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000637c:	00fb8733          	add	a4,s7,a5
    80006380:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006384:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006386:	0207c563          	bltz	a5,800063b0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000638a:	2905                	addiw	s2,s2,1
    8000638c:	0611                	addi	a2,a2,4
    8000638e:	05690c63          	beq	s2,s6,800063e6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006392:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006394:	00021717          	auipc	a4,0x21
    80006398:	92c70713          	addi	a4,a4,-1748 # 80026cc0 <disk>
    8000639c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000639e:	01874683          	lbu	a3,24(a4)
    800063a2:	fee9                	bnez	a3,8000637c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800063a4:	2785                	addiw	a5,a5,1
    800063a6:	0705                	addi	a4,a4,1
    800063a8:	fe979be3          	bne	a5,s1,8000639e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800063ac:	57fd                	li	a5,-1
    800063ae:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800063b0:	01205d63          	blez	s2,800063ca <virtio_disk_rw+0xa6>
    800063b4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800063b6:	000a2503          	lw	a0,0(s4)
    800063ba:	00000097          	auipc	ra,0x0
    800063be:	cfc080e7          	jalr	-772(ra) # 800060b6 <free_desc>
      for(int j = 0; j < i; j++)
    800063c2:	2d85                	addiw	s11,s11,1
    800063c4:	0a11                	addi	s4,s4,4
    800063c6:	ffb918e3          	bne	s2,s11,800063b6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800063ca:	85e6                	mv	a1,s9
    800063cc:	00021517          	auipc	a0,0x21
    800063d0:	90c50513          	addi	a0,a0,-1780 # 80026cd8 <disk+0x18>
    800063d4:	ffffc097          	auipc	ra,0xffffc
    800063d8:	cf8080e7          	jalr	-776(ra) # 800020cc <sleep>
  for(int i = 0; i < 3; i++){
    800063dc:	f8040a13          	addi	s4,s0,-128
{
    800063e0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800063e2:	894e                	mv	s2,s3
    800063e4:	b77d                	j	80006392 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063e6:	f8042583          	lw	a1,-128(s0)
    800063ea:	00a58793          	addi	a5,a1,10
    800063ee:	0792                	slli	a5,a5,0x4

  if(write)
    800063f0:	00021617          	auipc	a2,0x21
    800063f4:	8d060613          	addi	a2,a2,-1840 # 80026cc0 <disk>
    800063f8:	00f60733          	add	a4,a2,a5
    800063fc:	018036b3          	snez	a3,s8
    80006400:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006402:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006406:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000640a:	f6078693          	addi	a3,a5,-160
    8000640e:	6218                	ld	a4,0(a2)
    80006410:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006412:	00878513          	addi	a0,a5,8
    80006416:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006418:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000641a:	6208                	ld	a0,0(a2)
    8000641c:	96aa                	add	a3,a3,a0
    8000641e:	4741                	li	a4,16
    80006420:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006422:	4705                	li	a4,1
    80006424:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006428:	f8442703          	lw	a4,-124(s0)
    8000642c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006430:	0712                	slli	a4,a4,0x4
    80006432:	953a                	add	a0,a0,a4
    80006434:	058a8693          	addi	a3,s5,88
    80006438:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000643a:	6208                	ld	a0,0(a2)
    8000643c:	972a                	add	a4,a4,a0
    8000643e:	40000693          	li	a3,1024
    80006442:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006444:	001c3c13          	seqz	s8,s8
    80006448:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000644a:	001c6c13          	ori	s8,s8,1
    8000644e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006452:	f8842603          	lw	a2,-120(s0)
    80006456:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000645a:	00021697          	auipc	a3,0x21
    8000645e:	86668693          	addi	a3,a3,-1946 # 80026cc0 <disk>
    80006462:	00258713          	addi	a4,a1,2
    80006466:	0712                	slli	a4,a4,0x4
    80006468:	9736                	add	a4,a4,a3
    8000646a:	587d                	li	a6,-1
    8000646c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006470:	0612                	slli	a2,a2,0x4
    80006472:	9532                	add	a0,a0,a2
    80006474:	f9078793          	addi	a5,a5,-112
    80006478:	97b6                	add	a5,a5,a3
    8000647a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000647c:	629c                	ld	a5,0(a3)
    8000647e:	97b2                	add	a5,a5,a2
    80006480:	4605                	li	a2,1
    80006482:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006484:	4509                	li	a0,2
    80006486:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000648a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000648e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006492:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006496:	6698                	ld	a4,8(a3)
    80006498:	00275783          	lhu	a5,2(a4)
    8000649c:	8b9d                	andi	a5,a5,7
    8000649e:	0786                	slli	a5,a5,0x1
    800064a0:	97ba                	add	a5,a5,a4
    800064a2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800064a6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800064aa:	6698                	ld	a4,8(a3)
    800064ac:	00275783          	lhu	a5,2(a4)
    800064b0:	2785                	addiw	a5,a5,1
    800064b2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800064b6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800064ba:	100017b7          	lui	a5,0x10001
    800064be:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800064c2:	004aa783          	lw	a5,4(s5)
    800064c6:	02c79163          	bne	a5,a2,800064e8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800064ca:	00021917          	auipc	s2,0x21
    800064ce:	91e90913          	addi	s2,s2,-1762 # 80026de8 <disk+0x128>
  while(b->disk == 1) {
    800064d2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800064d4:	85ca                	mv	a1,s2
    800064d6:	8556                	mv	a0,s5
    800064d8:	ffffc097          	auipc	ra,0xffffc
    800064dc:	bf4080e7          	jalr	-1036(ra) # 800020cc <sleep>
  while(b->disk == 1) {
    800064e0:	004aa783          	lw	a5,4(s5)
    800064e4:	fe9788e3          	beq	a5,s1,800064d4 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800064e8:	f8042903          	lw	s2,-128(s0)
    800064ec:	00290793          	addi	a5,s2,2
    800064f0:	00479713          	slli	a4,a5,0x4
    800064f4:	00020797          	auipc	a5,0x20
    800064f8:	7cc78793          	addi	a5,a5,1996 # 80026cc0 <disk>
    800064fc:	97ba                	add	a5,a5,a4
    800064fe:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006502:	00020997          	auipc	s3,0x20
    80006506:	7be98993          	addi	s3,s3,1982 # 80026cc0 <disk>
    8000650a:	00491713          	slli	a4,s2,0x4
    8000650e:	0009b783          	ld	a5,0(s3)
    80006512:	97ba                	add	a5,a5,a4
    80006514:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006518:	854a                	mv	a0,s2
    8000651a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000651e:	00000097          	auipc	ra,0x0
    80006522:	b98080e7          	jalr	-1128(ra) # 800060b6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006526:	8885                	andi	s1,s1,1
    80006528:	f0ed                	bnez	s1,8000650a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000652a:	00021517          	auipc	a0,0x21
    8000652e:	8be50513          	addi	a0,a0,-1858 # 80026de8 <disk+0x128>
    80006532:	ffffa097          	auipc	ra,0xffffa
    80006536:	758080e7          	jalr	1880(ra) # 80000c8a <release>
}
    8000653a:	70e6                	ld	ra,120(sp)
    8000653c:	7446                	ld	s0,112(sp)
    8000653e:	74a6                	ld	s1,104(sp)
    80006540:	7906                	ld	s2,96(sp)
    80006542:	69e6                	ld	s3,88(sp)
    80006544:	6a46                	ld	s4,80(sp)
    80006546:	6aa6                	ld	s5,72(sp)
    80006548:	6b06                	ld	s6,64(sp)
    8000654a:	7be2                	ld	s7,56(sp)
    8000654c:	7c42                	ld	s8,48(sp)
    8000654e:	7ca2                	ld	s9,40(sp)
    80006550:	7d02                	ld	s10,32(sp)
    80006552:	6de2                	ld	s11,24(sp)
    80006554:	6109                	addi	sp,sp,128
    80006556:	8082                	ret

0000000080006558 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006558:	1101                	addi	sp,sp,-32
    8000655a:	ec06                	sd	ra,24(sp)
    8000655c:	e822                	sd	s0,16(sp)
    8000655e:	e426                	sd	s1,8(sp)
    80006560:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006562:	00020497          	auipc	s1,0x20
    80006566:	75e48493          	addi	s1,s1,1886 # 80026cc0 <disk>
    8000656a:	00021517          	auipc	a0,0x21
    8000656e:	87e50513          	addi	a0,a0,-1922 # 80026de8 <disk+0x128>
    80006572:	ffffa097          	auipc	ra,0xffffa
    80006576:	664080e7          	jalr	1636(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000657a:	10001737          	lui	a4,0x10001
    8000657e:	533c                	lw	a5,96(a4)
    80006580:	8b8d                	andi	a5,a5,3
    80006582:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006584:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006588:	689c                	ld	a5,16(s1)
    8000658a:	0204d703          	lhu	a4,32(s1)
    8000658e:	0027d783          	lhu	a5,2(a5)
    80006592:	04f70863          	beq	a4,a5,800065e2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006596:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000659a:	6898                	ld	a4,16(s1)
    8000659c:	0204d783          	lhu	a5,32(s1)
    800065a0:	8b9d                	andi	a5,a5,7
    800065a2:	078e                	slli	a5,a5,0x3
    800065a4:	97ba                	add	a5,a5,a4
    800065a6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800065a8:	00278713          	addi	a4,a5,2
    800065ac:	0712                	slli	a4,a4,0x4
    800065ae:	9726                	add	a4,a4,s1
    800065b0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800065b4:	e721                	bnez	a4,800065fc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800065b6:	0789                	addi	a5,a5,2
    800065b8:	0792                	slli	a5,a5,0x4
    800065ba:	97a6                	add	a5,a5,s1
    800065bc:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800065be:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800065c2:	ffffc097          	auipc	ra,0xffffc
    800065c6:	b6e080e7          	jalr	-1170(ra) # 80002130 <wakeup>

    disk.used_idx += 1;
    800065ca:	0204d783          	lhu	a5,32(s1)
    800065ce:	2785                	addiw	a5,a5,1
    800065d0:	17c2                	slli	a5,a5,0x30
    800065d2:	93c1                	srli	a5,a5,0x30
    800065d4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800065d8:	6898                	ld	a4,16(s1)
    800065da:	00275703          	lhu	a4,2(a4)
    800065de:	faf71ce3          	bne	a4,a5,80006596 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800065e2:	00021517          	auipc	a0,0x21
    800065e6:	80650513          	addi	a0,a0,-2042 # 80026de8 <disk+0x128>
    800065ea:	ffffa097          	auipc	ra,0xffffa
    800065ee:	6a0080e7          	jalr	1696(ra) # 80000c8a <release>
}
    800065f2:	60e2                	ld	ra,24(sp)
    800065f4:	6442                	ld	s0,16(sp)
    800065f6:	64a2                	ld	s1,8(sp)
    800065f8:	6105                	addi	sp,sp,32
    800065fa:	8082                	ret
      panic("virtio_disk_intr status");
    800065fc:	00002517          	auipc	a0,0x2
    80006600:	24c50513          	addi	a0,a0,588 # 80008848 <syscalls+0x3f8>
    80006604:	ffffa097          	auipc	ra,0xffffa
    80006608:	f3a080e7          	jalr	-198(ra) # 8000053e <panic>
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
