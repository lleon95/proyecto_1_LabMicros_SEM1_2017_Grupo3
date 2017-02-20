addi $t0, $zero, 10
addi $t1, $zero, 0
bne $t1, $t0, increase
j exit

increase:
  addi $t1, $t1, 1

exit:
  add $v0, $zero, $t1
