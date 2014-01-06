// Similar to the other interrupt file, this file is not used

.include "nios_macros.s"
.equ GPIO_JP1,	 0x10000060         /*GPIO_JP1*/
.equ GPIO_JP2,	 0x10000070         /*GPIO_JP2*/
.equ ADDR_JP1_IRQ, 0x0800           /* IRQ line for for GPIO JP1 (bit 11) */
.equ ADDR_JP1_Edge, 0x1000006C      /* address Edge Capture register GPIO JP1 */
.equ ADDR_JP2_IRQ, 0x1000           /* IRQ line for for GPIO JP2 (bit 12) */
.equ ADDR_JP2_Edge, 0x1000007C      /* address Edge Capture register GPIO JP2 */
.equ ADDR_GREENLEDS, 0x10000010	 	/* green LEDs*/
.equ ADDR_SWITCHES,  0x10000040	 	/* switches*/
.equ ADDR_7SEGS_low, 0x10000020	 	/* 7 segment display 0-3*/
.equ ADDR_7SEGS_high,0x10000030	 	/* 7 segment display 4-7*/
.global _start



 /* interrupt routine*/
 
.section .exceptions, "ax"
IHANDLER:

 addi	sp,sp, -8
 stw	r2,0(sp)
 stw 	r3,4(sp)		        #save registers for main routine

 rdctl  et,ctl4
 beq	et, r0,exit_handler

 movia 	r7, ADDR_JP2_IRQ	    /* check to make sure GPIO_JP2 interrupt*/
 and	r7, et,r7
 beq	r7, r0,exit_handler


 movia	r7,ADDR_JP2_Edge	    /* clear interrupts at NIOS processor*/
 stwio	r0,0(r7)


 movia  r2,GPIO_JP2             /* load GPIO JP2 into r2*/
 movia  r3, ADDR_7SEGS_low      /* load lower seven segment display to r3*/
 ldwio	r4,0(r2)
 srli   r4,r4,27
 andi	r4,r4,0x01f
 cmpeqi r5,r4,0x01f
 bne	r5,r0,exit_handler	    /*false interrupt*/
	
 cmpeqi	r5,r4,0x01e             /*check sensor 1 */
 bne	r5,r0,forprep1
	
 cmpeqi	r5,r4,0x01d             /*check sensor 2 */
 bne	r5,r0,revprep1

 cmpeqi	r5,r4,0x01b             /*check sensor 3 */
 bne	r5,r0,forprep2			
	
 cmpeqi	r5,r4,0x017             /*check sensor4 */
 bne	r5,r0,revprep2
 
 cmpeqi	r5,r4,0x00f             /*check sensor5 */
 bne	r5,r0,forprep3

forprep1:
 movia 	r6, 0x6d793706
 stwio  r6, 0(r3)              /* load value into LOWERR HEX display*/
 movia	r7,0xffdffffc
 br	load			           /*turn motor1 forward*/

forprep2:
 movia  r6, 0x6d79374f        
 stwio  r6, 0(r3)              /* load value into LOWERR HEX display*/
 movia	r7,0xffdfffcf
 br	load			           /*turn motor3 forward*/
 
forprep3:
 movia  r6, 0x6d79376d       
 stwio  r6, 0(r3)              /* load value into LOWERR HEX display*/
 movia	r7,0xffdffeff
 br	load			           /*turn motor5 forward*/

revprep1:
 movia 	r6, 0x6d79375b
 stwio  r6, 0(r3)              /* load value into LOWERR HEX display*/
 movia	r7,0xffdffffb
 br	load			           /*turn motor2 reverse*/

revprep2:
 movia 	r6, 0x6d793766
 stwio  r6, 0(r3)              /* load value into LOWERR HEX display*/
 movia	r7,0xffdfffbf	
 br	load       		           /*turn motor4 reverse*/
  
load:
 stwio  r7, 0(r2)              /* turn on one of the motors based on value in r7  */
 ldwio	r4, 0(r2)
 srli   r4,r4,27
 andi	r4, r4,0x01f
 cmpeqi r5, r4,0x01f	       /*check if interrupt has end*/
 bne	r5, r0,exit_handler
 br	load
 
 exit_handler:

 ldw  	r2,0(sp)
 ldw	r3,0(sp)
 addi	sp,sp,8
 subi ea,ea,4 			       /* unload stack to regular routine*/
 eret


/********************** main program ************************/

.text
_start:
 
 movia  r2, GPIO_JP2              /* load GPIO JP2 into r2 */
 movia  r4, ADDR_7SEGS_low        /* load low 4 HEX display into r4*/
 movia  r3, 0x07f557ff
 stwio  r3, 4(r2)                 /* set direction register for motors and sensors */           
            
 movia  r3, 0xffffffff            /* set all motors off and disable all sensors */
 stwio  r3, 0(r2)

#load threshold value into sensors
#sensor 1

 movia  r3,0xfabffbff			/* load threshold value HEX 5 for sensor 1 on lego controller*/
 stwio r3,0(r2)		        

#sensor 2

 movia  r3,0xfabfefff			/* load threshold value HEX 5 for sensor 2 on lego controller*/
 stwio r3,0(r2)	

#sensor 3

 movia  r3,0xfabfbfff			/* load threshold value HEX 5 for sensor 3 on lego controller*/
 stwio r3,0(r2)	

#sensor 4

 movia  r3,0xfabeffff			/* load threshold value HEX 5 for sensor 4 on lego controller*/
 stwio r3,0(r2)	
 
 #sensor 5

 movia  r3,0xfabbffff			/* load threshold value HEX 5 for sensor 5 on lego controller*/
 stwio r3,0(r2)	

 movia  r3,0xffdfffff           /* turn on state mode */		   
 stwio  r3, 0(r2) 
	

#enable interrupts DE2 boards

 movia	r3,0xf8000000
 stwio	r3,8(r2)		        /* Enable sensor1-5 interrupts */

 movia  r3,ADDR_JP2_IRQ	        /* enable bit 11 interrupts(GPIO JP2) on NIOS processor*/
 wrctl	ctl3,r3			

 movia 	r3,1
 wrctl 	ctl0,r3			        /* enable global interrupts*/
 
#  main routine

again:

 movia  r2, GPIO_JP2              /* load GPIO JP2 into r2 */
 movia  r4, ADDR_7SEGS_low        /* load low 4 HEX display into r4*/
 
 movia 	r5, 0x6d073f73			  /* load value into lower HEX display*/
 stwio  r5, 0(r4)
              
 movia   r3, 0xffdfffff           /* keep motors off when no interrupts enable state bit*/
 stwio  r3, 0(r2)                 
 
 br again

