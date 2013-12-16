library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;

package wb_arria_reset_pkg is

component arria_reset
	PORT
	(
		clock		: IN STD_LOGIC ;
		param		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		read_param		: IN STD_LOGIC ;
		reconfig		: IN STD_LOGIC ;
		reset		: IN STD_LOGIC ;
		reset_timer		: IN STD_LOGIC ;
		busy		: OUT STD_LOGIC ;
		data_out		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
	);
end component;

component arria5_reset
	PORT
	(
		clock		: IN STD_LOGIC ;
		param		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		read_param		: IN STD_LOGIC ;
		reconfig		: IN STD_LOGIC ;
		reset		: IN STD_LOGIC ;
		reset_timer		: IN STD_LOGIC ;
		busy		: OUT STD_LOGIC ;
		data_out		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component wb_arria_reset is
  generic (
            arria_family: string  := "arria";
            rst_channels: integer range 1 to 7 := 2
          );
  port (
          clk:      in std_logic;
          nrst:     in std_logic;
          
          slave_o:  out t_wishbone_slave_out;
          slave_i:  in t_wishbone_slave_in;
          
          reset_out:  out std_logic_vector(rst_channels-1 downto 0)
  
      );
end component;

constant c_arria_reset : t_sdb_device := (
    abi_class     => x"0000", -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7", -- 8/16/32-bit port granularity
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"000000000000000f",
    product => (
    vendor_id     => x"0000000000000651", -- GSI
    device_id     => x"3a362063",
    version       => x"00000001",
    date          => x"20131213",
    name          => "FPGA_RESET         ")));


end package;