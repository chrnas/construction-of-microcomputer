library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- uMem interface
entity uMem is
  port (
    uAddr : in unsigned(7 downto 0);
    uData : out unsigned(27 downto 0));
end uMem;

architecture Behavioral of uMem is

-- micro Memory
type u_mem_t is array (0 to 99) of unsigned(27 downto 0);
constant u_mem_c : u_mem_t :=
   --OP_TB_FB_PC_uPC_uAddr
  ( 
  b"0000_0011_1010_0_0_00_0000_00000000", -- 00  | Fetchphase begins. ASR := PC 
  b"0000001000010100000000000000", -- 01  | IR := PM, PC := PC + 1 
  b"0000000000000000001000000000", -- 02  | uPC := K2 (M-fältet) 
  b"0000000110100000000100000000", -- 03  | ASR := IR, uPC := K1(OP-Fältet)
  b"0000001110100100000100000000", -- 04  | ASR := PC, PC := PC + 1, uPC := K1
  b"0000000110100000000000000000", -- 05  | ASR := IR
  b"0000001010100000000100000000", -- 06  | ASR := PM, uPC := K1(OP-Fältet)
  b"0001000100000000000000000000", -- 07  | AR := IR
  b"0100011100001000000000000000", -- 08  | AR := GR3 + AR
  b"0000010010100000000100000000", -- 09  | ASR := AR, uPC := K1(OP-Fältet)
  
  b"0000000000000000111100000000", -- 0A  | Fetchphase ends.
  b"0000001001110000001100000000", -- 0B  | LOAD
  b"0000011100100000001100000000", -- 0C  | STORE: PM(A) := GRx
  b"0001011100000000000000000000", -- 0D  | ADD: AR := GRx
  b"0100001000000000000000000000", -- 0E  | ADD: AR := AR + GRx
  b"0000010001110000001100000000", -- 0F  | ADD: GRx := AR

  b"0001011100000000000000000000", -- 10  | AND: AR := GRx
  b"0110001000000000000000000000", -- 11  | AND: AR & PM(A)
  b"0000010001110000001100000000", -- 12  | AND: GRx := AR

  b"0001011100000000000000000000", -- 13  | SUB: AR := GRx
  b"0101001000000000000000000000", -- 14  | SUB: AR := AR - PM(A)
  b"0000010001110000001100000000", -- 15  | SUB: GRx := AR

  b"0000000100000010000000000000", -- 16  | LSR: LC := IR
  b"0001011100000000000000000000", -- 17  | LSR: AR := GRx
  b"1101000000000001000000000000", -- 18  | LSR: AR >> log, LC--
  b"0000000000000000110000011011", -- 19  | LSR: Jump to $1B if LC == 0
  b"0000000000000000010100011000", -- 1A  | LSR: ELse, jump to $18
  b"0000010001110000001100000000", -- 1B  | LSR: GRx := AR

  b"0000000000000100000000000000", -- 1C | BRA: PC++
  b"0001001100000000000000000000", -- 1D | BRA: AR := PC
  b"0100000100000000000000000000", -- 1E | BRA: AR := AR + IR 
  b"0000010000110000001100000000", -- 1F | BRA: PC := AR

  -- Conditional branch.
  b"0000000000000000010000011100", -- 20 | BNE: If Z = 0, jump
  b"0000000000000000001100000000", -- 21 | BNE: Z = 1

  -- Conditional branch.
  b"0000000000000000100100011100", -- 22 | BSE: If N = 1, jump BRA
  b"0000000000000000001100000000", -- 23 | BSE: N = 0

  -- Branch if greater or equal. Uses previously defined BRA.
  b"0000000000000000100100100111", -- 24 | BGE: N = 1 jump to 27
  b"0000000000000000101100101000", -- 25 | BGE: O = 1 jump to 28
  b"0000000000000000010100011100", -- 26 | BGE: Jump to BRA   
  b"0000000000000000101100011100", -- 27 | BGE: O = 1 jump to BRA
  b"0000000000000000001100000000", -- 28 | BGE: Finish. Resets uPC to 0 
  
  b"0000000000000000100000110011", -- 29 | BEQ: If Z = 1, jump
  b"0000000000000000001100000000", -- 2A | BEQ: Z = 0

  b"0000000000000000100100101101", -- 2B | BPL: no jump. N = 1.
  b"0000000000000000010100011100", -- 2C | BPL: Jump, N = 0.
  b"0000000000000000011000000000", -- 2D | BPL: Finish. uPC = 0

  b"0001100000000000001100000000", -- 2E | LDJ: AR := JSTK

  b"0001011100000000000000000000", -- 2F | CMP: AR := GRx
  b"0101001000000000001100000000", -- 30 | CMP: AR := AR - PM(A)

  b"0101001000000000001100000000", -- 31 | CMPA: AR -= PM(A)

  b"0000001000000010001100000000", -- 32 | STRLC: LC := PM(A)

  b"0000001000110000001100000000", -- 33 | JMP: PC:=PM(A)

  b"0000111001100000001100000000", -- 34 | LDRAN: HR := Random

  b"0000011010100000000000000000", -- 35 | STRHR: ADR := HR
  b"0000011100100000001100000000", -- 36 | STRHR: PM(A) := Grx

  b"0000001001100000001100000000", -- 37 | LDHR: HR := PM(A)

  b"0000011011110000000000000000", -- 38 | VHR_STR: P_ASR := HR
  b"0000011110010000001100000000", -- 39 | VHR_STR: PICT_MEM(P_ASR) := Grx
  
  b"0000011011110000000000000000", -- 3A | VHR_LOAD : P_ASR := HR
  b"0000100101110000001100000000", -- 3B | VHR_LOAD : Grx := PICT_MEM(P_ASR)
  
  b"0000011001000000000000000000", -- 3C | ADDHR: AR := HR
  b"0100001000000000000000000000", -- 3D | ADDHR: AR+=PM(A)
  b"0000010001100000001100000000", -- 3E | ADDHR: HR:=AR

  b"0000011001000000000000000000", -- 3F | SUBHR: AR:= HR
  b"0101001000000000000000000000", -- 40 | SUBHR: AR-=PM(A)
  b"0000010001100000001100000000", -- 41 | SUBHR: HR := AR
  b"0000000000000001001100000000", -- 42 | LC--
  b"0000000000000000110000011100", -- 43 | BRL: jmp if LC = 0 to PM(A)
  b"0000000000000000001100000000", -- 44 | BRL: no jmp
  others => (others => '0') 
  );


signal u_mem : u_mem_t := u_mem_c;

begin  -- Behavioral
  uData <= u_mem(to_integer(uAddr));

end Behavioral;
