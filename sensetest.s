
.include "nios_macros.s"
.equ GPIO_JP1,	 0x10000060         /*GPIO_JP1*/
.equ GPIO_JP2,	 0x10000070         /*GPIO_JP2*/
.equ ADDR_GREENLEDS, 0x10000010	 	/* green LEDs*/
.equ ADDR_SWITCHES,  0x10000040	 	/* switches*/
.equ ADDR_7SEGS_low, 0x10000020	 	/* 7 segment display 0-3*/
.equ ADDR_7SEGS_high,0x10000030	 	/* 7 segment display 4-7*/
.global start

start:
/*r2 data register GPIO JP2*/
/*r3 motor register (bits 0-9)*/
/*r4 sensor register (bits 10,12,14,16,18)*/
/*r5 valid sensor data bit (11,13,15,17,19)*/
/*r6 sensor 1*/
/*r7 sensor 2*/
/*r8 sensor 3*/
/*r9 sensor 4*/
/*r10 sensor 5*/
/*r11 4 bit HEX value*/


  
 movia  r2, GPIO_JP2              /* set (motors, sensors and control (bits 0-17,19-25,30,31) as output, set (control bits 18, 26-29) as inputs*/
 movia  r3, 0x07f557ff              /* direction register GPIO JP2*/
 stwio  r3, 4(r2)
 
loop: 
 movia  r4, 0xfffffbff               /* enable sensor 0 lego controller disable motors */
 stwio  r4, 0(r2)
 ldwio r5, 0(r2)
 srli  r5, r5,11
 andi  r5, r5,0x1
 cmpeqi r12, r5,0x1
 beq    r0, r12,good
 br 	loop 
 good: 
 ldwio  r6, 0(r2)               	 /* get sensor0 value from GPIO JP2*/
 #movia  r4, 0xffffffff               /* disable sensor lego controller disable motors */ 
 #stwio  r4, 0(r2)
loop2: 
 movia  r4, 0xffffefff               /* enable sensor 1 lego controller disable motors */ 
 stwio  r4, 0(r2)
 ldwio r5, 0(r2)
 srli  r5, r5,13
 andi  r5, r5,0x1
 cmpeqi r12, r5,0x1
 beq    r0, r12,good1
 br 	loop2 
 good1: 
 ldwio  r7, 0(r2)               	 /* get sensor1 value from GPIO JP2*/
 # movia  r4, 0xffffffff               /* disable sensor lego controller disable motors */
 # stwio  r4, 0(r2) 
loop3:
 movia  r4, 0xffffbfff              /* enable sensor 2 lego controller disable motors */
 stwio  r4, 0(r2) 
 ldwio r5, 0(r2)
 srli  r5, r5,15
 andi  r5, r5,0x1
 cmpeqi r12, r5,0x1
 beq    r0, r12,good2
 br 	loop3 
 good2: 
 ldwio  r8, 0(r2)               	 /* get sensor2 value from GPIO JP2*/
 # movia  r4, 0xffffffff               /* disable sensor lego controller disable motors */
 #stwio  r4, 0(r2)
loop4:
 movia  r4, 0xfffeffff               /* enable sensor 3 lego controller disable motors */	 
 stwio  r4, 0(r2) 
 ldwio r5, 0(r2)
 srli  r5, r5,17
 andi  r5, r5,0x1
 cmpeqi r12, r5,0x1
 beq    r0, r12,good3
 br 	loop4 
 good3: 
 ldwio  r9, 0(r2)                	/* get sensor3 value from GPIO JP2 */
 #movia  r4, 0xffffffff               /* disable sensor lego controller disable motors */ 
 #stwio  r4, 0(r2)
loop5:
 movia  r4, 0xfffbffff               /* enable sensor 4 lego controller disable motors */	 
 stwio  r4, 0(r2) 
 ldwio r5, 0(r2)
 srli  r5, r5,19
 andi  r5, r5,0x1
 cmpeqi r12, r5,0x1
 beq    r0, r12,good4
 br 	loop5 
 good4: 
 ldwio  r10, 0(r2)                	/* get sensor4 value from GPIO JP2 */
	
 movia  r4, 0xffffffff               /* turn  polling off and disable motors */	
 stwio  r4, 0(r2)
 
 /* display HEX value on Hex Display*/
 
 srli 	r7, r7,27              	 /* algin polling value for sensor 2 (bits 0-3)*/
 andi   r12, r7,0xf
 call	hexdisplay
 slli   r14, r12,24
 
 srli   r8, r8,27               /* algin polling value for sensor 3 (bits 0-3)*/  
 andi   r12, r8,0xf
 call	hexdisplay
 slli   r12,  r12,16
 or     r14, r14,r12
 
 srli   r9, r9,27                /* align polling value for sensor 4 (bits 0-3)*/
 andi   r12, r9,0xf
 call	hexdisplay
 slli   r12,  r12,8
 or     r14, r14,r12
 
 srli   r10, r10,27                /* align polling value for sensor 5 (bits 0-3)*/
 andi   r12, r10,0xf
 call	hexdisplay
 or     r14, r14,r12
 movia  r15, ADDR_7SEGS_low
 stwio  r14, 0(r15)
 
 srli   r6, r6,27               /* align polling value for sensor 1 (bits 0-3)*/
 andi   r12, r6,0xf
 call	hexdisplay
 movia  r14, ADDR_7SEGS_high
 
 stwio  r12, 0(r14)

 br     loop 
 

 /* find HEX value*/
 
hexdisplay:
 cmpeqi  r13, r12,0x0         /*check for HEX '0'*/
 bne     r0,  r13,zero
 cmpeqi  r13, r12,0x1         /*check for HEX '1'*/
 bne     r0,  r13,one
 cmpeqi  r13, r12,0x2       /*check for HEX '2'*/
 bne     r0,  r13,two
 cmpeqi  r13, r12,0x3         /*check for HEX '3'*/
 bne     r0,  r13,three
 cmpeqi  r13, r12,0x4         /*check for HEX '4'*/
 bne     r0,  r13,four
 cmpeqi  r13, r12,0x5        /*check for HEX '5'*/
 bne     r0,  r13,five
 cmpeqi  r13, r12,0x6         /*check for HEX '7'*/
 bne     r0,  r13,six
 cmpeqi  r13, r12,0x7         /*check for HEX '7'*/
 bne     r0,  r13,seven
 cmpeqi  r13, r12,0x8        /*check for HEX '8'*/
 bne     r0,  r13,eight
 cmpeqi  r13, r12,0x9        /*check for HEX '9'*/
 bne     r0,  r13,nine
 cmpeqi  r13, r12,0xa         /*check for HEX 'a'*/
 bne     r0,  r13,ten
 cmpeqi  r13, r12,0xb         /*check for HEX 'b'*/
 bne     r0,  r13,eleven
 cmpeqi  r13, r12,0xc         /*check for HEX 'c'*/
 bne     r0,  r13,twelve
 cmpeqi  r13, r12,0xd         /*check for HEX 'd'*/
 bne     r0,  r13,thirteen
 cmpeqi  r13, r12,0xe         /*check for HEX 'e'*/
 bne     r0,  r13,fourteen
 cmpeqi  r13, r12,0xf         /*check for HEX 'f'*/
 bne     r0,  r13,fifteen
 ret
 
zero:
 movi r12, 0x3f
 ret
 
one:
 movi r12, 0x06
 ret

two:
 movi r12, 0x56
 ret
 
three:
 movi r12, 0x4f
 ret
     
four:
 movi r12, 0x66
 ret
 
five:
 movi r12, 0x6d
 ret

six:
 movi r12, 0x7d
 ret
 
seven:
 movi r12, 0x07
 ret
 
eight:
 movi r12, 0x7f
 ret
 
nine:
 movi r12, 0x67
 ret

ten:
 movi r12, 0x77
 ret
 
eleven:
 movi r12, 0x7c
 ret
     
twelve:
 movi r12, 0x39
 ret
 
thirteen:
 movi r12, 0x5e
 ret

fourteen:
 movi r12, 0x79
 ret
 
fifteen:
 movi r12, 0x71
 ret
