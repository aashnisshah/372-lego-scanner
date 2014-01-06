// This is the primary (and the only one, for now) file that 
// contains all the code for the audio scanner

// This module is included for testing purposes.
// It's not used for the main functionality
#include "stdio.h"

// audio_ptr is used to point to the device to which
// the read value would be written to eventually
volatile int * audio_ptr;
// audibuf is used to store the actual values which
// would be written to the device
long audiobuf;
// fifospace is the register that directs where to 
// write the values to.
// counter just determines what value is written when
int fifospace, counter;

void run_motor(){
	asm(".equ ADDR_JP2, 0x10000070");
	asm("movia r8, ADDR_JP2");

	asm("movia r9, 0x07f557ff");
	asm("stwio r9, 4(r8)");
	asm("movia r9, 0xfffffffc");
	asm("stwio r9, 0(r8)");
	
}

void sensor(){
	asm(".equ ADDR_JP2, 0x10000070");
	asm("movia r8, ADDR_JP2");

	asm("movia r10, 0x07f557ff");
	asm("stwio r10, 4(r8)");

	asm("loop:");
		asm("movia r11, 0xfffeffff");
		asm("stwio r11, 0(r8)");
		asm("ldwio r5, 0(r8)");
		asm("srli r5, r5,17");
		asm("andi r5, r5,0x1");
		asm("bne r0, r5,loop");
	asm("good:");
		asm("ldwio r10, 0(r8)");
		asm("srli r10, r10, 27");
		asm("andi r10, r10, 0x0f");

		asm("movia r6, 0x5");
		asm("bgt r10, r6, playnote");

}

void sensor2(){
	// change registers to not screw up the two different 
	// sensor interactions

	asm(".equ ADDR_JP2, 0x10000070");
	asm("movia r7, ADDR_JP2");

	asm("movia r9, 0x07f557ff");
	asm("stwio r9, 4(r7)");

	asm("loop2:");
		asm("movia r12, 0xfffbffff");
		asm("stwio r12, 0(r7)");
		asm("ldwio r13, 0(r7)");
		asm("srli r13, r13,19");
		asm("andi r13, r13,0x1");
		asm("bne r0, r13,loop2");
	asm("good2:");
		asm("ldwio r9, 0(r7)");
		asm("srli r9, r9, 27");
		asm("andi r9, r9, 0x0f");
		// r6 is not changed as we're using the same values for
		// both the sensors
		asm("movia r6, 0x5");
		asm("bgt r9, r6, playnote2");

}

void playnote(){
       
       fifospace = *(audio_ptr+1); // read the audio port fifospace register

       if(counter < 22){
   			audiobuf = 500032100;
   			counter++;
   		} else {
   			audiobuf = -500032100;
   			counter++;
   			if(counter == 44){
   				counter = 0;
   			}
   		}

   		fifospace = *(audio_ptr + 1);

	   if (((fifospace & 0x00ff0000)>>16) > 96){
	   		// write to both channels
		   *(audio_ptr + 2) = audiobuf;
		   *(audio_ptr + 3) = audiobuf;
		   // *(audio_ptr + 3) = 0;	   		
	   }
}

void playnote2(){
       
       fifospace = *(audio_ptr+1); // read the audio port fifospace register

       if(counter < 22){
   			audiobuf = 250000000;
       		// audiobuf = 500032100;
   			counter++;
   		} else {
   			audiobuf = -250000000;
   			// audiobuf = -500032100;
   			counter++;
   			if(counter == 44){
   				counter = 0;
   			}
   		}

   		fifospace = *(audio_ptr + 1);

	   if (((fifospace & 0x00ff0000)>>16) > 96){
	   		// write to both channels
		   *(audio_ptr + 2) = audiobuf;
		   *(audio_ptr + 3) = audiobuf;	   		
	   }
}

int main(){
	audio_ptr = (int *) 0x10003040;
	counter = 0;

	while(1){
		/* 	Recommendation:
		 *  First test if the 2nd sensor is working properly
		 *  and then try running em both
		 */
		run_motor();
		sensor();
		sensor2();
	}
	return 0;
}
