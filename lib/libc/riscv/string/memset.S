/*-
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Copyright (c) 2024 Strahinja Stanisic <strajabot@FreeBSD.org>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <machine/asm.h>

/*
 * register a0 - void* s
 * register a1 - int c
 * register a2 - size_t n
 */
ENTRY(memset)
	andi a1, a1, 0xFF

	slti t1, a2, 8
	mv t0, a0
	bnez t1, .Lend

	li t1, 0x0101010101010101
	mul a1, a1, t1

	andi t1, a0, 0b111
	andi t0, a0, ~0b111

	beqz t1, .Lloop_store_64

	la t2, .Lduff_start
	slli t3, t1, 2
	add t2, t2, t3
	jr -4(t2)
.Lduff_start:
	sb a1, 1(t0)
	sb a1, 2(t0)
	sb a1, 3(t0)
	sb a1, 4(t0)
	sb a1, 5(t0)
	sb a1, 6(t0)
	sb a1, 7(t0)

	/* a3 = a3 -(8-a) <=> a3 = a3 + (a-8) */
	addi t1, t1, -8
	add a2, a2, t1
	addi t0, t0, 8

.Lloop_store_64:
	slti t1, a2, 64
	bnez t1, .Lstore_rest
	sd a1, 0(t0)
	sd a1, 8(t0)
	sd a1, 16(t0)
	sd a1, 24(t0)
	sd a1, 32(t0)
	sd a1, 40(t0)
	sd a1, 48(t0)
	sd a1, 56(t0)
	addi a2, a2, -64
	addi t0, t0, 64
	j .Lloop_store_64

.Lstore_rest:
	la t2, .Lduff_rest
	andi t3, a2, ~0b111
	srli t4, t3, 1
	sub t2, t2, t4
	jr t2
	sd a1, 56(t0)
	sd a1, 48(t0)
	sd a1, 40(t0)
	sd a1, 32(t0)
	sd a1, 24(t0)
	sd a1, 16(t0)
	sd a1, 8(t0)
	sd a1, 0(t0)
.Lduff_rest:
	add t0, t0, t3
	sub a2, a2, t3

.Lend:
	slli a2, a2, 2
	la t2, .Lduff_end
	sub t2, t2, a2
	jr t2
	sb a1, 6(t0)
	sb a1, 5(t0)
	sb a1, 4(t0)
	sb a1, 3(t0)
	sb a1, 2(t0)
	sb a1, 1(t0)
	sb a1, (t0)
.Lduff_end:
	ret
END(memset)

