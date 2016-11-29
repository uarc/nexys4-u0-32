`define I_MOVEZ 8'b000000ZZ
`define I_RAREADZ 8'b000001ZZ
`define I_REREADIZ 8'b000010ZZ
`define I_INC 8'h0C
`define I_DEC 8'h0D
`define I_CARRY 8'h0E
`define I_BORROW 8'h0F
`define I_INV 8'h10
`define I_BREAK 8'h11
`define I_RETURN 8'h12
`define I_CONTINUE 8'h13
`define I_INTEN 8'h14
`define I_INTRECV 8'h15
`define I_ILOOP 8'h16
`define I_KILL 8'h17
`define I_INTWAIT 8'h18
`define I_GETBP 8'h19
`define I_GETBA 8'h1A
`define I_CALLI 8'h1B
`define I_JMPI 8'h1C
`define I_BRA 8'h1D
`define I_DISCARD 8'h1E
`define I_CALLRI 8'h1F
`define I_CVZ 8'b0010ZZZZ
`define I_READZ 8'b001100ZZ
`define I_RAREADIZ 8'b001101ZZ
`define I_GETZ 8'b001110ZZ
`define I_IZ 8'b001111ZZ
`define I_WRITEPREM 6'b010000
`define I_WRITEPREZ 8'b010000ZZ
`define I_WRITEPSTZ 8'b010001ZZ
`define I_SETZ 8'b010010ZZ
`define I_RAWRITEIM 6'b010011
`define I_RAWRITEIZ 8'b010011ZZ
`define I_REWRITEIZ 8'b010100ZZ
`define I_REREADZ 8'b010101ZZ
`define I_ADD 8'h58
`define I_SUB 8'h59
`define I_LSL 8'h5A
`define I_LSR 8'h5B
`define I_CSL 8'h5C
`define I_CSR 8'h5D
`define I_ASR 8'h5E
`define I_AND 8'h5F
`define I_REWRITEZ 8'b011000ZZ
`define I_RAWRITEM 6'b011001
`define I_RAWRITEZ 8'b011001ZZ
`define I_WRITE 8'h68
`define I_WRITEP 8'h69
`define I_WRITEPO 8'h6A
`define I_WRITEPS 8'h6B
`define I_BEQ 8'h6C
`define I_BNE 8'h6D
`define I_BLES 8'h6E
`define I_BLEQ 8'h6F
`define I_BLESU 8'h70
`define I_BLEQU 8'h71
`define I_RECV 8'h72
`define I_SEND 8'h73
`define I_INCEPT 8'h74
`define I_SET 8'h75
`define I_SEL 8'h76
`define I_SETPA 8'h77
`define I_EXPECT 8'h78
`define I_SEF 8'h79
`define I_RESET 8'h7A
`define I_DDROP 8'h7B
`define I_SENDP 8'h7C
`define I_INCEPTP 8'h7D
//`define I_RESERVED 8'h7E
//`define I_RESERVED 8'h7F
`define I_ADDI 8'h80
`define I_ADDI8 8'h81
`define I_ADDI16 8'h82
`define I_SUBI 8'h83
`define I_LSLI 8'h84
`define I_CSLI 8'h85
`define I_ASRI 8'h86
`define I_ANDI 8'h87
`define I_ORI 8'h88
`define I_XORI 8'h89
`define I_BC 8'h8A
`define I_BNC 8'h8B
`define I_BO 8'h8C
`define I_BNO 8'h8D
`define I_BI 8'h8E
`define I_BNI 8'h8F
`define I_INDEXZ 8'b100100ZZ
`define I_IMM8 8'h94
`define I_IMM16 8'h95
`define I_IMM32 8'h96
`define I_IMM64 8'h97
`define I_GETP 8'h98
`define I_GETA 8'h99
//`define I_RESERVED 8'h9A
//`define I_RESERVED 8'h9B
//`define I_RESERVED 8'h9C
//`define I_RESERVED 8'h9D
//`define I_RESERVED 8'h9E
//`define I_RESERVED 8'h9F
`define I_OR 8'hA0
`define I_XOR 8'hA1
`define I_READ 8'hA2
`define I_CALL 8'hA3
`define I_JMP 8'hA4
`define I_INTSET 8'hA5
`define I_SEB 8'hA6
`define I_SLB 8'hA7
`define I_USB 8'hA8
`define I_INTSEND 8'hA9
`define I_LOOP 8'hAA
`define I_BZ 8'hAB
`define I_BNZ 8'hAC
`define I_WRITEPI 8'hAD
`define I_WRITEPRI 8'hAE
`define I_DROP 8'hAF
`define I_PUSHM 6'b101100
`define I_PUSHZ 8'b101100ZZ
`define I_POPM 6'b101101
`define I_POPZ 8'b101101ZZ
`define I_BA 8'hB8
`define I_BNA 8'hB9
`define I_WRITEPORI 8'hBA
`define I_WRITEPSRI 8'hBB
//`define I_RESERVED 8'hBC
//`define I_RESERVED 8'hBD
//`define I_RESERVED 8'hBE
//`define I_RESERVED 8'hBF
`define I_ROTZ 8'b110ZZZZZ
`define I_COPYZ 8'b111ZZZZZ