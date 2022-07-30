addi s0, zero, 0
addi s1, zero, 0
addi t0, zero, 0
addi t1, zero, 0


# LED address
li s0, 0x2004

# counter threashold
#li s1, 50_000_000
li s1, 5

main:
	addi t0, zero, 0
    sw t0, 0(s0)
	call delay
    
	addi t0, x0, 3
    sw t0, 0(s0)
    call delay
   	j main

delay:
	addi t1, s1, 0
delay_loop:
	beq t1, zero, exit_delay
    addi t1, t1, -1
    j delay_loop
exit_delay:
	ret