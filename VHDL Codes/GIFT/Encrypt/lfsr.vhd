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

entity lfsr is
Port ( clk : in  STD_LOGIC;
           reset,enable : in  STD_LOGIC;
			  ld_rc : in  STD_LOGIC;
           output : out  STD_LOGIC_VECTOR (5 downto 0));
end lfsr;

architecture Behavioral of lfsr is
signal y:std_logic_vector (5 downto 0);
            begin
				
                process (clk,reset)
                    variable temp:std_logic;
						  
                      begin
                       if(reset='1') then
							  y<="000000";
                        elsif ( clk'event and clk='1')  then 
                         if enable='1' then
								if(ld_rc='0') then
								y<="000000";
								else
                        temp:=y(5) xnor y(4);
                        y(5 downto 0)<=y(4 downto 0) & temp;
                end if;      
                end if;
                end if;
                end process;	
                output<=y;



end Behavioral;

