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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity key_ram is
  Port ( clk : in  STD_LOGIC;
           cs : in  STD_LOGIC;
           we : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (127 downto 0);
           address : in  integer range 0 to 27;
           data_out : out  STD_LOGIC_VECTOR (127 downto 0));
end key_ram;

architecture Behavioral of key_ram is
type mem_array is array(0 to 27)  of std_logic_vector(127 downto 0);
signal memory: MEM_array;-- := (others => '0');
begin
process (clk,cs,we)
begin
if clk'event and clk = '1' then
 if cs = '1' then 
  if we = '1' then
  memory(address) <= data_in;-- memory(to_integer(unsigned(address))) <= data_in;
   data_out <= data_in;
  else
  data_out <= memory(address);-- data_out <= memory( to_integer(unsigned(address)));
  end if;
 end if;
end if;
end process;


end Behavioral;
