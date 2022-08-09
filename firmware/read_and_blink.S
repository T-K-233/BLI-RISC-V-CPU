addi s0, zero, 0
addi s1, zero, 0
addi t0, zero, 0
addi t1, zero, 0


# counter threashold
#li s1, 50_000_000
li s1, 5

main:
	call HAL_readSW
	call HAL_writeLED
	mv a0, s1
	call HAL_delay
    
   	j main

HAL_delay:
	addi t1, a0, 0
delay_loop:
	beq t1, zero, exit_delay
    addi t1, t1, -1
    j delay_loop
exit_delay:
	ret
	
	
HAL_readSW:
	li t0, 0x2000
	lw a0, 0(t0)
	ret
	
HAL_writeLED:
	li t0, 0x2004
	sw a0, 0(t0)
	ret