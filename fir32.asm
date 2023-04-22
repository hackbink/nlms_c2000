;;#############################################################################
;; \file \cs30_f2837x\F2837xD_examples_Cpu1\cla_adc_fir32\cpu01\fir32.asm
;;
;; \brief  5-Tap FIR Filter Example
;; \date   September 26, 2013
;;
;;
;; Group: 			C2000
;; Target Family:	F2837x
;;
;;(C)Copyright 2013, Texas Instruments, Inc.
;;#############################################################################
;;$TI Release: F2837xD Support Library v3.04.00.00 $
;;$Release Date: Sun Mar 25 13:26:04 CDT 2018 $
;;$Copyright:
;// Copyright (C) 2013-2018 Texas Instruments Incorporated - http://www.ti.com/
;//
;// Redistribution and use in source and binary forms, with or without
;// modification, are permitted provided that the following conditions
;// are met:
;//
;//   Redistributions of source code must retain the above copyright
;//   notice, this list of conditions and the following disclaimer.
;//
;//   Redistributions in binary form must reproduce the above copyright
;//   notice, this list of conditions and the following disclaimer in the
;//   documentation and/or other materials provided with the
;//   distribution.
;//
;//   Neither the name of Texas Instruments Incorporated nor the names of
;//   its contributors may be used to endorse or promote products derived
;//   from this software without specific prior written permission.
;//
;// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;// $
;;#############################################################################

;;*****************************************************************************
;; includes
;;*****************************************************************************
	.cdecls C, LIST, "cla_adc_fir32_shared.h"
;;*****************************************************************************
;; defines
;;*****************************************************************************
;// To include an MDEBUGSTOP (CLA breakpoint) as the first instruction
;// of each task, set CLA_DEBUG to 1.  Use any other value to leave out
;// the MDEBUGSTOP instruction.

CLA_DEBUG .set  1

;;*****************************************************************************
;; function definitions
;;*****************************************************************************
;// CLA code must be within its own assembly section and must be
;// even aligned.  Note: since all CLA instructions are 32-bit
;// this alignment naturally occurs and the .align 2 is most likely
;// redundant

       .sect        "Cla1Prog"
_Cla1Prog_Start
       .align       2

_Cla1Task1:
    MSTOP
    MNOP
    MNOP
    MNOP
_Cla1T1End:


_Cla1Task2:
    MSTOP
    MNOP
    MNOP
    MNOP
_Cla1T2End:

_Cla1Task3:
    MSTOP
    MNOP
    MNOP
    MNOP
_Cla1T3End:


_Cla1Task4:
    MSTOP
    MNOP
    MNOP
    MNOP
_Cla1T4End:


_Cla1Task5:
    MSTOP
    MNOP
    MNOP
    MNOP
_Cla1T5End:

_Cla1Task6:
    MSTOP
    MNOP
    MNOP
    MNOP
_Cla1T6End:

_Cla1Task7:

        .if CLA_DEBUG == 1
        MDEBUGSTOP
       .endif

;//==============================================
;// CLA Task 7
;//
;// This task:
;//
;// 1. Is triggered by the late ADC interrupt.
;//    This interrupt occurs at the end of the
;//    sample conversion
;// 2. Reads the ADC B RESULT4 register as soon
;//    as it is available
;// 3. It will then run a FIR filter and places the
;//    result into VoltFilt.
;// 4. The main CPU will take an interrupt at the
;//    end of the task. It will log the
;//    ADC RESULT1 register for comparison as
;//    well as the CLA generated VoltFilt value
;//
;// Before starting the ADC conversions, force
;// Task 8 to initialize the filter states and
;// coefficients.
;//
;//==============================================


; X and A are arrays of 32-bit float (i.e. 2 words)
; Use these defines to make the code easier to read
;
_X12  .set _X+24
_X11  .set _X+22
_X10  .set _X+20
_X9  .set _X+18
_X8  .set _X+16
_X7  .set _X+14
_X6  .set _X+12
_X5  .set _X+10

_X4  .set _X+8
_X3  .set _X+6
_X2  .set _X+4
_X1  .set _X+2
_X0  .set _X+0

_A12  .set _A+24
_A11  .set _A+22
_A10  .set _A+20
_A9  .set _A+18
_A8  .set _A+16
_A7  .set _A+14
_A6  .set _A+12
_A5  .set _A+10

_A4  .set _A+8
_A3  .set _A+6
_A2  .set _A+4
_A1  .set _A+2
_A0  .set _A+0

_A_12  .set _A_+24
_A_11  .set _A_+22
_A_10  .set _A_+20
_A_9  .set _A_+18
_A_8  .set _A_+16
_A_7  .set _A_+14
_A_6  .set _A_+12
_A_5  .set _A_+10

_A_4  .set _A_+8
_A_3  .set _A_+6
_A_2  .set _A_+4
_A_1  .set _A_+2
_A_0  .set _A_+0

; CLA 13-tap FIR Filter
;
; Coefficients A[0, 1, 2, 3, 4 .. 12]
; Data         X[0, 1, 2, 3, 4 .. 12] (Delay Line - X[0] is newest value)
;
; Equations
;
; Y = A4 * X4      First Calculation of sum of products.
; X4 = X3          X4 can now be updated, because it has been used.
; Y = Y + A3 * X3  Second product, 1st add.
; X3 = X2          X3 update
; Y = Y + A2 * X2  Third product, 2nd add.
; X2 = X1
; Y = Y + A1 * X1  Fourth product, 3rd add.
; X1 = X0
; Y = Y = A0 * X0
;

; Perfom DC removal first.
    MMOV32     MR0, @_DcRemovalZ             ; Load MR0 with Z(n-1), DcRemovalZ
	MMOV32     MR1, @_DcRemovalAlpha         ; Load MR1 with 0.95, DcRemovalAlpha
    MUI16TOF32 MR3, @_AdcaResultRegs.ADCRESULT0  ; Read ADCRESULT0 and convert to float, MR3 = X(n)

    MMPYF32    MR2, MR1, MR0                 ; 0.95 * Z(n-1)
    MADDF32    MR3, MR3, MR2                 ; Z(n) = X(n) + Z(n-1)

    MMOV32     @_DcRemovalZ, MR3             ; Save the new Z(n)
    ; MR3 has Z(n) and MR0 has Z(n-1)
	MSUBF32	   MR2, MR3, MR0
    MMOV32     @_DcFiltered, MR2             ; Save the new Y(n)

    MMOV32 	   MR0, @_DcOffset
    MADDF32    MR0, MR0, MR2                 ; Let's add 2048 before making it unsigned integer.
    ;MMOV32     @_DebugFloat, MR0             ; Save debug variable

	MF32TOUI16 MR3, MR0                      ; Convert to Uint16 value
    MMOV16     @_DcFilteredUint16, MR3       ; Save as integer for For debug purpose.

	; Now MR2 has the float of DcFiltered.
    MMOV32     MR0,@_X12                     ; Load MR0 with X12
    MMOV32     MR1,@_A12                     ; Load MR1 with A12
    ;MUI16TOF32 MR2,  @_AdcaResultRegs.ADCRESULT0  ; Read ADCRESULT0 and convert to float

    MMPYF32    MR2, MR1, MR0                 ; MR2 (Y) = MR1 (A12) * MR0 (X12)
 || MMOV32     @_X_new, MR2                  ; MR2 gets copied to _X_new before the multiply operation

    MMOVD32    MR0,@_X11                     ; Load MR0 with X11 (X11 gets copied to X12)
    MMOV32     MR1,@_A11                     ; Load MR1 with A11

    MMPYF32    MR3, MR1, MR0                 ; MR3 (Y) = MR1 (A11) * MR0 (X11)
 || MMOV32     MR1,@_A10                     ; Load MR1 with A10
    MMOVD32    MR0,@_X10                     ; Load MR0 with X10, Load MR1 with A10 (X10 gets copied to X11)


    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A11*X11 + A12*X12
 || MMOV32     MR1,@_A9                      ; MR2 = MR1 (A10) * MR0 (X10)
    MMOVD32    MR0,@_X9                      ; Load MR0 with X9, Load MR1 with A9 (X9 gets copied to X10)

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A10*X10 + A11*X11 + A12*X12
 || MMOV32     MR1,@_A8                      ; MR2 = MR1 (A9) * MR0 (X9)
    MMOVD32    MR0,@_X8                      ; Load MR0 with X8, Load MR1 with A8 (X8 gets copied to X9)

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A9*X9 + A10*X10 ... + A12*X12
 || MMOV32     MR1,@_A7                      ; MR2 = MR1 (A8) * MR0 (X8)
    MMOVD32    MR0,@_X7                      ; Load MR0 with X7, Load MR1 with A7 (X7 gets copied to X8)

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A8*X8 + A9*X9 ... + A12*X12
 || MMOV32     MR1,@_A6                      ; MR2 = MR1 (A7) * MR0 (X7)
    MMOVD32    MR0,@_X6                      ; Load MR0 with X6, Load MR1 with A6 (X6 gets copied to X7)

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A7*X7 + A8*X8 ... + A12*X12
 || MMOV32     MR1,@_A5                      ; MR2 = MR1 (A6) * MR0 (X6)
    MMOVD32    MR0,@_X5                      ; Load MR0 with X5, Load MR1 with A5 (X5 gets copied to X6)

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A6*X6 + A7*X7 ... + A12*X12
 || MMOV32     MR1,@_A4                      ; MR2 = MR1 (A5) * MR0 (X5)
    MMOVD32    MR0,@_X4                      ; Load MR0 with X4, Load MR1 with A4 (X4 gets copied to X5)

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A5*X5 + A6*X6 ... + A12*X12
 || MMOV32     MR1,@_A3                      ; MR2 = MR1 (A4) * MR0 (X4)
    MMOVD32    MR0,@_X3                      ; Load MR0 with X3, Load MR1 with A3 (X3 gets copied to X4)

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A3*X3 + A4*X4 ... + A12*X12
 || MMOV32     MR1,@_A2                      ; MR2 = MR1 (A3) * MR0 (X3)
    MMOVD32    MR0,@_X2                      ; Load MR0 with X2, Load MR1 with A2 (X2 gets copied to X3)

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A3*X3 + A4*X4 ... + A12*X12
 || MMOV32     MR1,@_A1                      ; MR2 = MR1 (A2) * MR0 (X2)
    MMOVD32    MR0,@_X1                      ; Load MR0 with X1, Load MR1 with A1 (X1 gets copied to X2)

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A2*X2 + A3*X3 ... + A12*X12
 || MMOV32     MR1,@_A0                      ; MR2 = MR1 (A1) * MR0 (X1)
    MMOVD32    MR0,@_X0                      ; Load MR0 with X0, Load MR1 with A0 (X0 gets copied to X1)

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A1*X1 + A2*X2 ... + A12*X12
 || MMOV32     MR1,@_X_new                   ; MR2 = MR1 (A0) * MR0 (X0), Load X_new to MR1.
    MMOV32     @_X0, MR1                     ; Now update X0 with X_new.

    MADDF32    MR3, MR3, MR2                 ; MR3 = A0*X0 + (A1*X1 + A2*X2 + ... + A12*X12)

    MMOV32     @_voltFiltFloat, MR3          ; Save the voltFiltFloat.

    MMOV32 	   MR0, @_DcOffset
    MADDF32    MR3, MR3, MR0                 ; Let's add 2048 before making it unsigned integer.

	MF32TOUI16 MR2, MR3                      ; Get back to Uint16 value
    MMOV16     @_voltFilt, MR2               ; Output


; Now we calculate the adaptive filter output.
; No more MMOVD32 instruction as we do not need to mess with X[].
    MMOV32     MR0,@_X12                     ; Load MR0 with X12
    MMOV32     MR1,@_A_12                    ; Load MR1 with A_12

    MMPYF32    MR2, MR1, MR0                 ; MR2 (Y) = MR1 (A_12) * MR0 (X12)

    MMOV32     MR0,@_X11                     ; Load MR0 with X11
    MMOV32     MR1,@_A_11                    ; Load MR1 with A_11

    MMPYF32    MR3, MR1, MR0                 ; MR3 (Y) = MR1 (A_11) * MR0 (X11)
 || MMOV32     MR1,@_A_10                    ; Load MR1 with A_10
    MMOV32     MR0,@_X10                     ; Load MR0 with X10

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A_11*X11 + A_12*X12
 || MMOV32     MR1,@_A_9                     ; MR2 = MR1 (A_10) * MR0 (X10), Load MR1 with A_9
    MMOV32     MR0,@_X9                      ; Load MR0 with X9

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A_10*X10 + A_11*X11 + A_12*X12
 || MMOV32     MR1,@_A_8                     ; MR2 = MR1 (A_9) * MR0 (X9), Load MR1 with A_8
    MMOV32     MR0,@_X8                      ; Load MR0 with X8

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A_9*X9 + A_10*X10 ... + A_12*X12
 || MMOV32     MR1,@_A_7                     ; MR2 = MR1 (A_8) * MR0 (X8), Load MR1 with A_7
    MMOV32     MR0,@_X7                      ; Load MR0 with X7

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A_8*X8 + A_9*X9 ... + A_12*X12
 || MMOV32     MR1,@_A_6                     ; MR2 = MR1 (A_7) * MR0 (X7), Load MR1 with A_6
    MMOV32     MR0,@_X6                      ; Load MR0 with X6

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A_7*X7 + A_8*X8 ... + A_12*X12
 || MMOV32     MR1,@_A_5                     ; MR2 = MR1 (A_6) * MR0 (X6), Load MR1 with A_5
    MMOV32     MR0,@_X5                      ; Load MR0 with X5

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A_6*X6 + A_7*X7 ... + A_12*X12
 || MMOV32     MR1,@_A_4                     ; MR2 = MR1 (A_5) * MR0 (X5), Load MR1 with A_4
    MMOV32     MR0,@_X4                      ; Load MR0 with X4

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A_5*X5 + A_6*X6 ... + A_12*X12
 || MMOV32     MR1,@_A_3                     ; MR2 = MR1 (A_4) * MR0 (X4), Load MR1 with A_3
    MMOV32     MR0,@_X3                      ; Load MR0 with X3

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A_4*X4 + A_5*X5 ... + A_12*X12
 || MMOV32     MR1,@_A_2                     ; MR2 = MR1 (A_3) * MR0 (X3), Load MR1 with A_2
    MMOV32     MR0,@_X2                      ; Load MR0 with X2

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A_3*X3 + A_4*X4 ... + A_12*X12
 || MMOV32     MR1,@_A_1                     ; MR2 = MR1 (A_2) * MR0 (X2), Load MR1 with A_1
    MMOV32     MR0,@_X1                      ; Load MR0 with X1

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A_2*X2 + A_3*X3 ... + A_12*X12
 || MMOV32     MR1,@_A_0                     ; MR2 = MR1 (A_1) * MR0 (X1), Load MR1 with A_0
    MMOV32     MR0,@_X0                      ; Load MR0 with X0

    MMACF32    MR3, MR2, MR2, MR1, MR0       ; MR3 = A_1*X1 + A_2*X2 ... + A_12*X12
 || MMOV32     MR1,@_A_0                     ; MR2 = MR1 (A_0) * MR0 (X0), Dummy Load MR1 with A_0

    MADDF32    MR3, MR3, MR2                 ; MR3 = A_0*X0 + (A_1*X1 + A_2*X2 + ... + A_12*X12)
    MMOV32     @_adaptiveFiltFloat, MR3      ; Save this float value

    MMOV32 	   MR0, @_DcOffset
    MADDF32    MR3, MR3, MR0                 ; Let's add 2048 before making it unsigned integer.

	MF32TOUI16 MR2, MR3                      ; Get back to Uint16 value
    MMOV16     @_adaptiveFilt, MR2           ; Output

; Now calculate X*X.
    MMOV32     MR0,@_X12                     ; Load MR0 with X12
    MMPYF32    MR2, MR0, MR0                 ; MR2 (Y) = MR0 (X12) * MR0 (X12)

    MMOV32     MR0,@_X11                     ; Load MR0 with X11

    MMPYF32    MR3, MR0, MR0                 ; MR3 (Y) = MR0 (X11) * MR0 (X11)
 || MMOV32     MR0,@_X10                     ; Load MR0 with X10

    MMACF32    MR3, MR2, MR2, MR0, MR0       ; MR3 = X11*X11 + X12*X12
 || MMOV32     MR0,@_X9                      ; MR2 = MR0 (X10) * MR0 (X10), Load MR0 with _X9

    MMACF32    MR3, MR2, MR2, MR0, MR0       ; MR3 = X10*X10 + X11*X11 + X12*X12
 || MMOV32     MR0,@_X8                      ; MR2 = MR0 (X9) * MR0 (X9), Load MR0 with _X8

    MMACF32    MR3, MR2, MR2, MR0, MR0       ; MR3 = X9*X9 ... + X11*X11 + X12*X12
 || MMOV32     MR0,@_X7                      ; MR2 = MR0 (X8) * MR0 (X8), Load MR0 with _X7

    MMACF32    MR3, MR2, MR2, MR0, MR0       ; MR3 = X8*X8 ... + X11*X11 + X12*X12
 || MMOV32     MR0,@_X6                      ; MR2 = MR0 (X7) * MR0 (X7), Load MR0 with _X6

    MMACF32    MR3, MR2, MR2, MR0, MR0       ; MR3 = X7*X7 ... + X11*X11 + X12*X12
 || MMOV32     MR0,@_X5                      ; MR2 = MR0 (X6) * MR0 (X6), Load MR0 with _X5

    MMACF32    MR3, MR2, MR2, MR0, MR0       ; MR3 = X6*X6 ... + X11*X11 + X12*X12
 || MMOV32     MR0,@_X4                      ; MR2 = MR0 (X5) * MR0 (X5), Load MR0 with _X4

    MMACF32    MR3, MR2, MR2, MR0, MR0       ; MR3 = X5*X5 ... + X11*X11 + X12*X12
 || MMOV32     MR0,@_X3                      ; MR2 = MR0 (X4) * MR0 (X4), Load MR0 with _X3

    MMACF32    MR3, MR2, MR2, MR0, MR0       ; MR3 = X4*X4 ... + X11*X11 + X12*X12
 || MMOV32     MR0,@_X2                      ; MR2 = MR0 (X3) * MR0 (X3), Load MR0 with _X2

    MMACF32    MR3, MR2, MR2, MR0, MR0       ; MR3 = X3*X3 ... + X11*X11 + X12*X12
 || MMOV32     MR0,@_X1                      ; MR2 = MR0 (X2) * MR0 (X2), Load MR0 with _X1

    MMACF32    MR3, MR2, MR2, MR0, MR0       ; MR3 = X2*X2 ... + X11*X11 + X12*X12
 || MMOV32     MR0,@_X0                      ; MR2 = MR0 (X1) * MR0 (X1), Load MR0 with _X0

    MMACF32    MR3, MR2, MR2, MR0, MR0       ; MR3 = X1*X1 ... + X11*X11 + X12*X12
 || MMOV32     MR0,@_X0                      ; MR2 = MR0 (X0) * MR0 (X0), Dummy Load MR0 with _X0

    MADDF32    MR3, MR3, MR2                 ; MR3 = X0*X0 + (X1*X1 + X2*X2 + ... + X12*X12)

    MMOV32 	   MR0, @_eps
    MADDF32    MR3, MR3, MR0                 ; MR3 = X*X + eps
    MMOV32     @_varianceX, MR3              ; Store this variance of X.
;
    MMOV32     MR1, @_voltFiltFloat          ; Load the voltFiltFloat.
    MMOV32     MR0, @_adaptiveFiltFloat      ;
    MSUBF32    MR1, MR1, MR0                 ; MR1 = X0 - estimation of X0 from adaptive filter.
    MMOV32     @_estError, MR1               ; Store this estimation error.

; To get estError/(X*X + eps), we need to use reciprocal approximation.
    MMOV32 	   MR1, MR3
    MEINVF32   MR2, MR1                      ; MR2 = Estimate(1/(X*X + eps))
	MMPYF32    MR3, MR2, MR1                 ; MR3 = Estimate(1/(X*X + eps)) * (X*X + eps)
    MSUBF32    MR3, #2.0, MR3                ; MR3 = 2.0 - Estimate(1/(X*X + eps)) * (X*X + eps)
    MMPYF32    MR2, MR2, MR3                 ; MR2 = Estimate(1/(X*X + eps)) * (2.0 - Estimate(1/(X*X + eps)) * (X*X + eps))
    MMPYF32    MR3, MR2, MR1                 ; MR3 = Ye*Den
 || MMOV32     MR0, @_estError               ; MR0 = estError
    MSUBF32    MR3, #2.0, MR3                ; MR3 = 2.0 - Ye*Den
    MMPYF32    MR2, MR2, MR3                 ; MR2 = Ye = Ye*(2.0 - Ye*Den)
 || MMOV32     MR1, @_varianceX              ; Reload _varianceX To Set Sign
    MNEGF32    MR0, MR0, EQ                  ; if(_varianceX == 0.0) Change Sign Of _estError
    MMPYF32    MR0, MR2, MR0                 ; MR0 = Y = Ye*_estError

    ;MMOV32     MR0, @_estError               ; MR0 = estError
    ;MMPYF32    MR0, MR2, MR0                 ; MR0 = estError/(X*X + eps)

    MMOV32     @_correctionFactor, MR0       ; Store result

; Now update A_. A_ = A_ + _correctionFactor * X.
    MMOV32     MR2, @_X12                    ; Load MR2 with X12
    MMOV32     MR1, @_A_12                   ; Load MR1 with A_12
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X12) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_12) + MR2(_X12 * _correctionFactor)
 || MMOV32     MR2, @_X11                    ; Load MR2 with X11
    MMOV32     @_A_12, MR1                   ; Update A_12

    MMOV32     MR1, @_A_11                   ; Load MR1 with A_11
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X11) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_11) + MR2(_X11 * _correctionFactor)
 || MMOV32     MR2, @_X10                    ; Load MR2 with X10
    MMOV32     @_A_11, MR1                   ; Update A_11

    MMOV32     MR1, @_A_10                   ; Load MR1 with A_10
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X10) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_10) + MR2(_X10 * _correctionFactor)
 || MMOV32     MR2, @_X9                     ; Load MR2 with X9
    MMOV32     @_A_10, MR1                   ; Update A_10

    MMOV32     MR1, @_A_9                    ; Load MR1 with A_9
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X9) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_9) + MR2(_X9 * _correctionFactor)
 || MMOV32     MR2, @_X8                     ; Load MR2 with X8
    MMOV32     @_A_9, MR1                    ; Update A_9

    MMOV32     MR1, @_A_8                    ; Load MR1 with A_8
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X8) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_8) + MR2(_X8 * _correctionFactor)
 || MMOV32     MR2, @_X7                     ; Load MR2 with X7
    MMOV32     @_A_8, MR1                    ; Update A_8

    MMOV32     MR1, @_A_7                    ; Load MR1 with A_7
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X7) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_7) + MR2(_X7 * _correctionFactor)
 || MMOV32     MR2, @_X6                     ; Load MR2 with X6
    MMOV32     @_A_7, MR1                    ; Update A_7

    MMOV32     MR1, @_A_6                    ; Load MR1 with A_6
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X6) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_6) + MR2(_X6 * _correctionFactor)
 || MMOV32     MR2, @_X5                     ; Load MR2 with X5
    MMOV32     @_A_6, MR1                    ; Update A_6

    MMOV32     MR1, @_A_5                    ; Load MR1 with A_5
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X5) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_5) + MR2(_X5 * _correctionFactor)
 || MMOV32     MR2, @_X4                     ; Load MR2 with X4
    MMOV32     @_A_5, MR1                    ; Update A_5

    MMOV32     MR1, @_A_4                    ; Load MR1 with A_4
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X4) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_4) + MR2(_X4 * _correctionFactor)
 || MMOV32     MR2, @_X3                     ; Load MR2 with X3
    MMOV32     @_A_4, MR1                    ; Update A_4

    MMOV32     MR1, @_A_3                    ; Load MR1 with A_3
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X3) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_3) + MR2(_X3 * _correctionFactor)
 || MMOV32     MR2, @_X2                     ; Load MR2 with X2
    MMOV32     @_A_3, MR1                    ; Update A_3

    MMOV32     MR1, @_A_2                    ; Load MR1 with A_2
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X2) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_2) + MR2(_X2 * _correctionFactor)
 || MMOV32     MR2, @_X1                     ; Load MR2 with X1
    MMOV32     @_A_2, MR1                    ; Update A_2

    MMOV32     MR1, @_A_1                    ; Load MR1 with A_1
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X1) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_1) + MR2(_X1 * _correctionFactor)
 || MMOV32     MR2, @_X0                     ; Load MR2 with X0
    MMOV32     @_A_1, MR1                    ; Update A_1

    MMOV32     MR1, @_A_0                    ; Load MR1 with A_0
    MMPYF32    MR2, MR2, MR0                 ; MR2 = MR2(_X0) * MR0 (_correctionFactor)
    MADDF32    MR1, MR1, MR2                 ; MR1 = MR1(_A_0) + MR2(_X0 * _correctionFactor)
    MMOV32     @_A_0, MR1                    ; Update A_0


almostDone:
    MNOP                                     ; Waste a cycle.
    MNOP                                     ; Waste a cycle.
    MNOP                                     ; Waste a cycle.
	MSTOP                                    ; End task

_Cla1T7End:

_Cla1Task8:

;==============================================
; This task initializes the filter input delay
; line (X0 to X4) to zero
;==============================================
    .if CLA_DEBUG == 1
    MDEBUGSTOP
    .endif
    MMOVIZ       MR0, #0.0
    MUI16TOF32   MR0, MR0
    MMOV32       @_X0, MR0
    MMOV32       @_X1, MR0
    MMOV32       @_X2, MR0
    MMOV32       @_X3, MR0
    MMOV32       @_X4, MR0
    MMOV32       @_X5, MR0
    MMOV32       @_X6, MR0
    MMOV32       @_X7, MR0
    MMOV32       @_X8, MR0
    MMOV32       @_X9, MR0
    MMOV32       @_X10, MR0
    MMOV32       @_X11, MR0
    MMOV32       @_X12, MR0
    MMOV32       @_A_0, MR0
    MMOV32       @_A_1, MR0
    MMOV32       @_A_2, MR0
    MMOV32       @_A_3, MR0
    MMOV32       @_A_4, MR0
    MMOV32       @_A_5, MR0
    MMOV32       @_A_6, MR0
    MMOV32       @_A_7, MR0
    MMOV32       @_A_8, MR0
    MMOV32       @_A_9, MR0
    MMOV32       @_A_10, MR0
    MMOV32       @_A_11, MR0
    MMOV32       @_A_12, MR0
    MSTOP
_Cla1T8End:
_Cla1Prog_End:
	.end
;; End of file
