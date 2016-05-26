	.text
pq_add:                                 # @pq_add

	pushl	%ebx
	pushl	%edi
	pushl	%esi
	subl	$16, %esp
	movl	36(%esp), %edi
	movl	32(%esp), %esi
	movl	$1, %ebx
	jmp	.LBB0_1
.LBB0_3:                                # %PQadd_unlockreturn
                                        #   in Loop: Header=BB0_1 Depth=1
	movl	$0, 8(%esi)
	movl	%esi, (%esp)
	calll	switch_to
.LBB0_1:                                # %PQadd_checklock
                                        # =>This Inner Loop Header: Depth=1
	xorl	%eax, %eax
	lock
	cmpxchgl	%ebx, 8(%esi)
	jne	.LBB0_3
# BB#2:                                 # %PQadd_checkguard
                                        #   in Loop: Header=BB0_1 Depth=1
	cmpl	$0, 20(%esi)
	je	.LBB0_3
# BB#4:                                 # %PQadd_succeed
	cmpl	$0, 12(%esi)
	je	.LBB0_5
# BB#6:                                 # %false1
	movl	%edi, 24(%esi)
	movl	$1, 20(%esi)
	jmp	.LBB0_7
.LBB0_5:                                # %ture1
	movl	%edi, 28(%esi)
	calll	pq_newPQ
	movl	%eax, 12(%esi)
.LBB0_7:                                # %end1
	addl	$16, %esp
	popl	%esi
	popl	%edi
	popl	%ebx
	retl

pq_doAdd:                               # @pq_doAdd
	
	pushl	%esi

	subl	$8, %esp
	movl	16(%esp), %esi
	cmpl	$1, 20(%esi)
	jne	.LBB1_5
# BB#1:                                 # %PQdoadd_succeed
	movl	24(%esi), %eax
	movl	28(%esi), %ecx
	cmpl	%ecx, %eax
	jle	.LBB1_3
# BB#2:                                 # %true1
	movl	12(%esi), %ecx
	movl	%eax, 4(%esp)
	movl	%ecx, (%esp)
	calll	pq_add
	jmp	.LBB1_4
.LBB1_3:                                # %false1
	movl	12(%esi), %eax
	movl	%ecx, 4(%esp)
	movl	%eax, (%esp)
	calll	pq_add
	movl	24(%esi), %eax
	movl	%eax, 28(%esi)
.LBB1_4:                                # %end1
	movl	$0, 20(%esi)
.LBB1_5:                                # %PQdoadd_return
	addl	$8, %esp
	popl	%esi
	retl

pq_doAction:                            # @pq_doAction
	pushl	%edi
	pushl	%esi
	pushl	%eax

	movl	16(%esp), %esi
	movl	$1, %edi
	jmp	.LBB2_1
	.align	16, 0x90
.LBB2_3:                                # %PQdoaction_switchsched
                                        #   in Loop: Header=BB2_1 Depth=1
	calll	switch_to_sched
.LBB2_1:                                # %PQdoaction_checklock
                                        # =>This Inner Loop Header: Depth=1
	xorl	%eax, %eax
	lock
	cmpxchgl	%edi, 8(%esi)
	jne	.LBB2_3
# BB#2:                                 # %PQdoaction_exec
                                        #   in Loop: Header=BB2_1 Depth=1
	movl	%esi, (%esp)
	calll	pq_doAdd
	movl	$0, 8(%esi)
	jmp	.LBB2_3
.Ltmp17:
	.size	pq_doAction, .Ltmp17-pq_doAction
	.cfi_endproc


	.section	".note.GNU-stack","",@progbits
