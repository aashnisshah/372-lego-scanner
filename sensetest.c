// A primitive, 'trying out' implementation of the audio scanner which just
// checked for certain functionality required for the full working

#include "stdio.h"

int main(){

	while(1){
		run_motor();
	}

}

void run_motor(){
	printf("inside run_motor");

	asm(".equ ADDR_JP2, 0x10000070");
	asm("movia r8, ADDR_JP2");
	asm("movia r9, 0x07f557ff");
	asm("stwio r9, 4(r8)");
	asm("movia r9, oxfffffffc");
	asm("stwio r9, 0(r8)");

}

void sensor_check(){
	// enable sensor 0 
	asm("loop:");
		asm("movia r4, 0xfffffbff");
		asm("stwio r4, 0(r2)");
		asm("ldwio r5, 0(r2)");
		asm("srli r5, r5,11");
		asm("andi r5, r5,0x1");
		asm("cmpeqi r12, r5,0x1");
		asm("beq r0, r12,good");
		asm("br loop");
		
	// get sensor0's value from GPIO JP2
	asm("good:");
		asm("ldwio r6, 0(r2)");
		// disable sensor lego controller and motors
		//asm("movia r4, 0xffffffff");
		//asm("stwio r4, 0(r2)");
	
	// enable sensor 1 lego controller, disable motors
	asm("loop2");
		asm("movia r4, 0xffffefff");
		asm("stwio r4, 0(r2)");
		asm("ldwio r5, 0(r2)");
		asm("srli r5, r5, 13");
		asm("andi r5, r5, 0x1");
		asm("cmpeqi r12, r5, 0x1");
		asm("beq r0, r12, good1");
		asm("br loop2");
		
	// get sensor1 value from GPIO JP2
	asm("good1:");
		asm("ldwio r7, 0(r2)");
		//asm("movia r4, 0xffffffff");
		//asm("stwio r4, 0(r2)");

	// repeat loop/good cycle for the other sensors

		
		asm("");
		asm("");
		asm("");
		asm("");
		asm("");
		asm("");
		asm("");
		asm("");
		asm("");
		asm("");
}
