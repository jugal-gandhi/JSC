----------------------------------------------------------------------------------
-- Company:        CSIR-Central Electronics Engineering Research Institute (CSIR-CEERI), Pilani - 333031, India
-- Engineer: 	   ----
-- 
-- Create Date:    01/30/2024 
-- Design Name:    GIFT-64 Lightweight Block Cipher
-- Module Name:    Behavioral 
-- Project Name:   Lightweight Crypto Cores with Improved Security against IP Piracy
-- Target Devices: Xilinx Zynq UltraScale+ ZCU102 (xczu9eg-2ffvb1156)
-- Tool versions:  Xilinx Vivado 2021.2
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
-- This code is a part of the reference baseline implementation accompanying
-- the manuscript "Functional Obfuscation of Lightweight Crypto Cores for
-- Improved Security against IP Piracy."
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sbox is
Port ( enable: in STD_LOGIC;
	        sbox_in : in  STD_LOGIC_VECTOR (3 downto 0);
           sbox_out : out  STD_LOGIC_VECTOR (2 downto 0)); 
end sbox;

architecture Behavioral of sbox is
begin
process(enable,sbox_in)
begin
if enable='0' then
sbox_out<="0000";
else
sbox_out(3)<=((not sbox_in(3)) and sbox_in(0)) or ((not sbox_in(2)) and (not sbox_in(1)) and sbox_in(0)) or (sbox_in(2) and sbox_in(1) and sbox_in(0)) or (sbox_in(3) and sbox_in(1) and (not sbox_in(0)));

sbox_out(2)<=((not sbox_in(3))and(not sbox_in(2)) and sbox_in(1)) or ((not sbox_in(3)) and sbox_in(2) and (not sbox_in(1))) or (sbox_in(2) and (not sbox_in(1)) and (not sbox_in(0))) or (sbox_in(3) and (not sbox_in(2)) and sbox_in(0)) or (sbox_in(3) and sbox_in(1) and sbox_in(0));

sbox_out(1)<=((not sbox_in(3)) and (not sbox_in(1)) and sbox_in(0)) or ((not sbox_in(3)) and sbox_in(2) and (not sbox_in(0))) or (sbox_in(3) and (not sbox_in(2)) and (not sbox_in(0))) or ( sbox_in(3) and sbox_in(1) and sbox_in(0));

sbox_out(0)<=((not sbox_in(3)) and sbox_in(2) and sbox_in(0))or ((not sbox_in(3)) and sbox_in(2) and sbox_in(1)) or(sbox_in(3) and (not sbox_in(2)) and sbox_in(0)) or(sbox_in(3) and (not sbox_in(2)) and sbox_in(1)) or ((not sbox_in(3)) and (not sbox_in(2)) and (not sbox_in(1)) and (not sbox_in(0))) or (sbox_in(3) and sbox_in(2) and (not sbox_in(1))and(not sbox_in(0)));

end if;
end process;
end Behavioral;

