library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wishbone_pkg.all;
use work.RandomPkg.all;

library work;

package wb_testsuite_pkg is



subtype t_wb_ref        is std_logic_vector(3 + 32 + 32 + 32 -1 downto 0); -- expected result, timeout, msk, dat
subtype t_wb_ref_exres  is std_logic_vector(3 + 32 + 32 + 32 -1 downto 32 + 32 + 32); -- expected result
subtype t_wb_ref_tmo    is std_logic_vector(32 + 32 + 32 -1 downto 32 + 32); -- timeout
subtype t_wb_ref_msk    is std_logic_vector(32 + 32 -1 downto 32); -- msk
subtype t_wb_ref_dat    is std_logic_vector(32 -1 downto 0); -- dat

subtype t_wb_rx         is std_logic_vector(2 + 32 + 32 -1 downto 0); -- result, time, dat
subtype t_wb_rx_res     is std_logic_vector(2 + 32 + 32 -1 downto 32 + 32); -- result
subtype t_wb_rx_ts      is std_logic_vector(32 +32 -1 downto 32); -- timestamp
subtype t_wb_rx_dat     is std_logic_vector(32 -1 downto 0); -- dat



subtype t_slv32 is std_logic_vector(31 downto 0); 

type t_slv32_array  is array(natural range <>) of t_slv32; 

constant c_NUL : t_slv32 := (others => '0');
constant c_ALL : t_slv32 := (others => '1');
constant c_WR : std_logic := '1';
constant c_RD : std_logic := '0';
constant c_ACK : std_logic_vector := "001";
constant c_ERR : std_logic_vector := "010";
constant c_TMO : std_logic_vector := "100";
constant c_XDC : std_logic_vector := "111";


type t_wb_data_gen is record
    we      : std_logic;
    adr     : t_slv32;
    dat     : t_slv32;
    msk     : t_slv32;
    delay   : natural range 255 downto 0;
    stall   : natural range 255 downto 0;
    tmo     : natural range 65535 downto 0;
    exres   : std_logic_vector(2 downto 0);
end record t_wb_data_gen;

type t_wb_dgen_rep is record
    total         : unsigned(31 downto 0); -- total number of operations
    flag_err      : unsigned(31 downto 0); -- number of errors (unexpected err signal, freeze timeout)
    idx_1st_flag  : unsigned(31 downto 0);
    val_err       : unsigned(31 downto 0); -- number of warnings (unexpected ack signal, unexpected read value, op timeout) 
    idx_1st_val   : unsigned(31 downto 0);
end record t_wb_dgen_rep;


type t_wb_data_gen_array is array(natural range <>) of t_wb_data_gen;


component wb_data_gen is
   generic(
      g_override_rd_bsel   : std_logic_vector(3 downto 0) := x"0";
      g_freeze_timeout  : natural);
   port(
      
      
      clk_i    : in  std_logic;
      rst_n_i  : in  std_logic;
      
      start_i  : in  std_logic;
      busy_o   : out std_logic;
      done_o   : out std_logic;
      err_o    : out std_logic;
      
      data_i   : t_wb_data_gen_array;
      
      report_o : out unsigned(31 downto 0);
      
      -- Master out
      master_o : out t_wishbone_master_out;
      master_i : in  t_wishbone_master_in := ('0', '0', '0', '0', '0', x"00000000")
      );
end component;


function f_sel_2_msk          (sel     : std_logic_vector) return std_logic_vector;
function f_set_we_column      (we      : std_logic_vector; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1)   return t_wb_data_gen_array;
function f_set_adr_column     (adr     : t_slv32_array; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1)   return t_wb_data_gen_array;
function f_set_dat_column     (dat     : t_slv32_array; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1)   return t_wb_data_gen_array;
function f_set_msk_column     (msk     : t_slv32_array; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1)   return t_wb_data_gen_array;
function f_set_delay_column   (delay   : integer_vector; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1)  return t_wb_data_gen_array;
function f_set_stall_column   (stall   : integer_vector; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1)  return t_wb_data_gen_array;
function f_set_tmo_column     (tmo     : integer_vector; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1)  return t_wb_data_gen_array;
function f_set_exres_column   (exres   : integer_vector; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1)  return t_wb_data_gen_array;

function f_new_dataset       (qty   : natural) return t_wb_data_gen_array;

--function f_csv_dataset    (csv : string) return t_wb_data_gen_array;

function f_concat_dataset (a : t_wb_data_gen_array; b : t_wb_data_gen_array) return t_wb_data_gen_array; 

function f_set_wb_out(a : t_wb_data_gen; enabled, send_now : std_logic; ovr_rd_bsel : std_logic_vector) return t_wishbone_master_out;
function f_set_wb_ref(a : t_wb_data_gen; rtime : unsigned) return t_wb_ref;
function f_set_wb_rx(a : t_wishbone_master_in; rtime : unsigned) return t_wb_rx;

function to_slv32_vector(a : integer_vector) return t_slv32_array;
function to_slv32(a : natural) return t_slv32;

shared variable RV : RandomPType;
-- raw data generation


--impure function f_set_seed(s : natural) return;
 


function f_lin_space(  first : natural;
                     last  : natural;
                     step  : natural;
                     qty   : natural)
return integer_vector;

impure function f_rnd_bound( lower_bound : integer;
                        upper_Bound : integer;
                        qty         : natural )
return integer_vector;


impure function f_rnd_bits(  prob_hi     : natural := 50;
                    max_streak  : integer := -1; 
                    qty         : natural)
return std_logic_vector;


 
end wb_testsuite_pkg;

package body wb_testsuite_pkg is

function f_new_dataset       (qty   : natural) return t_wb_data_gen_array is
     variable result : t_wb_data_gen_array(qty-1 downto 0);
     variable i : natural;   
   begin
     for i in result'range loop 
      result(i).we      := '0';
      result(i).adr     := (others => '0');
      result(i).dat     := (others => '0');
      result(i).msk     := (others => '1');
      result(i).delay   := 0;
      result(i).exres   := "111";
     end loop;
     return result;
end f_new_dataset;

function f_sel_2_msk (sel : std_logic_vector) return std_logic_vector is
     variable result : std_logic_vector(sel'length*8-1 downto 0);
     variable i : natural;   
   begin
     for i in result'range loop 
      result(i) := sel(i / 8);
     end loop;
     return result;
end f_sel_2_msk;

function f_msk_2_sel (msk : std_logic_vector) return std_logic_vector is
     variable result : std_logic_vector(msk'length/8-1 downto 0);
     variable i : natural;   
   begin
     for i in result'range loop 
      
      result(i) := msk(i / 8);
     end loop;
     return result;
end f_msk_2_sel;



function f_set_we_column (we : std_logic_vector; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1) return t_wb_data_gen_array is
     variable result : t_wb_data_gen_array(dataset'range);
     variable i, ne : natural;   
   begin
     result := dataset;
     if e = -1 then
      ne := we'left;
     end if; 
     
     for i in b to e loop 
      result(i).we := we(i);
     end loop;
     return result;
end f_set_we_column;

function f_set_adr_column (adr : t_slv32_array; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1) return t_wb_data_gen_array is
     variable result : t_wb_data_gen_array(dataset'range);
     variable i, ne : natural;   
   begin
     result := dataset;
     if e = -1 then
      ne := dataset'left;
     else
      ne := e;  
     end if; 
     
     for i in b to ne loop 
      result(i).adr := adr(i);
     end loop;
     return result;
end f_set_adr_column;

function f_set_dat_column    (dat : t_slv32_array; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1) return t_wb_data_gen_array is
     variable result : t_wb_data_gen_array(dataset'range);  
     variable i, ne : natural; 
   begin
     result := dataset;
     if e = -1 then
      ne := dataset'left;
     else
      ne := e; 
     end if; 
     
     for i in b to ne loop  
      result(i).dat := dat(i);
     end loop;
     return result;
end f_set_dat_column;

function f_set_msk_column    (msk : t_slv32_array; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1) return t_wb_data_gen_array is
     variable result : t_wb_data_gen_array(dataset'range);
     variable i, ne : natural;   
   begin
     result := dataset;
     if e = -1 then
      ne := dataset'left;
     else
      ne := e;  
     end if; 
     
     for i in b to ne loop 
      result(i).msk := msk(i);
     end loop;
     return result;
end f_set_msk_column;


function f_set_delay_column    (delay : integer_vector; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1) return t_wb_data_gen_array is
     variable result : t_wb_data_gen_array(dataset'range);  
     variable i, ne : natural; 
   begin
     result := dataset;
     if e = -1 then
      ne := dataset'left;
     else
      ne := e;  
     end if; 
     
     for i in b to ne loop  
      result(i).delay := delay(i);
     end loop;
     return result;
end f_set_delay_column;

function f_set_stall_column    (stall : integer_vector; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1) return t_wb_data_gen_array is
     variable result : t_wb_data_gen_array(dataset'range);  
     variable i, ne : natural; 
   begin
     result := dataset;
     if e = -1 then
      ne := dataset'left;
     else
      ne := e;  
     end if; 
     
     for i in b to ne loop  
      result(i).stall := stall(i);
     end loop;
     return result;
end f_set_stall_column;

function f_set_tmo_column    (tmo : integer_vector; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1) return t_wb_data_gen_array is
     variable result : t_wb_data_gen_array(dataset'range);  
     variable i, ne : natural; 
   begin
     result := dataset;
     if e = -1 then
      ne := dataset'left;
     else
      ne := e;  
     end if; 
     
     for i in b to ne loop  
      result(i).tmo := tmo(i);
     end loop;
     return result;
end f_set_tmo_column;

function f_set_exres_column    (exres : integer_vector; dataset : t_wb_data_gen_array; b : integer := 0; e : integer := -1) return t_wb_data_gen_array is
     variable result : t_wb_data_gen_array(dataset'range);  
     variable i, ne : natural; 
   begin
     result := dataset;
     if e = -1 then
      ne := dataset'left;
     else
      ne := e;  
     end if; 
     
     for i in b to ne loop  
      result(i).exres := std_logic_vector(to_unsigned(exres(i), t_wb_ref_exres'length));
     end loop;
     return result;
end f_set_exres_column;



function f_lin_space(     first : natural;
                        last  : natural;
                        step  : natural;
                        qty   : natural)
return integer_vector is
      variable tmp    : natural;    
      variable result : integer_vector(qty-1 downto 0);
      variable i : natural;
   begin
   
    
    tmp := first;
    
    if(first <= last) then
       for i in 0 to qty-1 loop
         result(i) := tmp;
         if (tmp + step <= last) then
           tmp := tmp + step;
         end if;
       end loop; 
    else
      for i in 0 to qty-1 loop
         result(i) := tmp;
         if (tmp - step >= last) then
           tmp := tmp - step;
         end if;
       end loop;
    end if;
    
    return result;
end f_lin_space;

impure function f_rnd_bound( lower_bound : integer;
                        upper_Bound : integer;
                        qty         : natural )
return integer_vector is
     variable tmp : integer_vector(qty-1 downto 0);
     variable result : integer_vector(qty-1 downto 0);
     variable i : natural;
   begin
     tmp := RV.RandIntV(lower_bound, upper_bound, qty);
   for i in 0 to qty-1 loop
         result(i) := tmp(i);
   end loop;  
     
   return result;
end f_rnd_bound;


impure  function f_rnd_bits(     prob_hi     : natural := 50;
                    max_streak  : integer := -1; 
                    qty         : natural)
return std_logic_vector is

 variable weight   : integer_vector( 1 downto 0) := ( prob_hi, 100 - prob_hi);  
 variable tmp      : std_logic_vector(0 downto 0);
 variable streak_cnt : natural;
 variable streak_inc : natural;
 variable result : std_logic_vector(qty-1 downto 0); 
begin
   streak_cnt := 0;
   for i in 0 to qty-1 loop
      tmp := RV.DistSlv ( weight, 1); --generate random bit
      
      if(i > 0) then
         if (result(i-1) = tmp(0)) then -- if it's same as last time, streak_inc is 1
            streak_inc := 1;
         end if;   
      else
         streak_inc := 0;
      end if;
             
      if (streak_cnt + streak_inc > max_streak) then -- if we have a longer streak than allowed, toggle bit and reset streak count
         tmp := not tmp;
         streak_cnt := 0;
      end if;   
      result(i) := tmp(0); 
   end loop;
   return result;
end f_rnd_bits;

function f_concat_dataset (a : t_wb_data_gen_array; b : t_wb_data_gen_array)
return t_wb_data_gen_array is 
   variable result : t_wb_data_gen_array( a'length + b'length -1 downto 0);  
   variable i : natural;
begin

   for i in 0 to a'length-1 loop
      result(i) := a(i);
   end loop; 
   for i in 0 to b'length-1 loop
      result(i + a'length) := b(i);
   end loop; 
   return result;
   
end f_concat_dataset;

function f_set_wb_out(a : t_wb_data_gen; enabled, send_now : std_logic; ovr_rd_bsel : std_logic_vector)
return t_wishbone_master_out is 
   variable wb : t_wishbone_master_out;  
   variable i, j : natural;
begin
   
   wb.cyc := enabled;
   wb.stb := enabled and send_now;
   wb.we  := a.we;
   wb.sel := x"0"; 
   for i in 0 to a.msk'left loop --create byte selects
      wb.sel(i/8) := wb.sel(i/8) or a.msk(i);
   end loop;
   wb.sel := wb.sel or (ovr_rd_bsel and not (a.we & a.we & a.we & a.we)); 
   wb.adr := a.adr;
   wb.dat := a.dat and a.msk;
   
   return wb;
   
end f_set_wb_out;


function f_set_wb_ref(a : t_wb_data_gen; rtime : unsigned)
return t_wb_ref is 
   variable result   : t_wb_ref;
   variable aux_msk  : t_wb_ref_msk;
begin
   
   -- if this is a write op, we are not interested in rx dat. our mask must be set to all zeroes
   if(a.we = '1') then
      aux_msk := (others => '0');
   else
      aux_msk := a.msk; 
   end if;
   
   result(t_wb_ref_exres'range)  := a.exres;
   result(t_wb_ref_tmo'range)    := std_logic_vector(to_unsigned(a.tmo, rtime'length) + rtime);
   result(t_wb_ref_msk'range)    := aux_msk;
   result(t_wb_ref_dat'range)    := (a.dat and aux_msk);
   return result;
   
end f_set_wb_ref;

function f_set_wb_rx(a : t_wishbone_master_in; rtime : unsigned)
return t_wb_rx is 
   variable result : t_wb_rx;
begin
   
   result(t_wb_rx_res'range)  := a.err & a.ack;
   result(t_wb_rx_ts'range)   := std_logic_vector(rtime);
   result(t_wb_rx_dat'range)  := a.dat;
   return result;
   
end f_set_wb_rx;

function f_set_delay(a : t_wb_data_gen; rtime : unsigned)
return natural is 
   variable result : natural;
begin
   return a.delay + to_integer(rtime);
end f_set_delay;

function f_set_tmo(a : t_wb_data_gen; rtime : unsigned)
return natural is 
   variable result : natural;
begin
   return a.tmo + to_integer(rtime);
end f_set_tmo;

function f_set_stall(a : t_wb_data_gen; rtime : unsigned)
return natural is 
   variable result : natural;
begin
   return a.stall + to_integer(rtime);
end f_set_stall;

function to_slv32_vector(a : integer_vector)
return t_slv32_array is
   variable result : t_slv32_array(a'range);
variable i : natural;
begin

   for i in 0 to a'left loop
      result(i) := std_logic_vector(to_unsigned(a(i), 32));
   end loop;
   return result;
end to_slv32_vector;


function to_slv32(a : natural)
return t_slv32 is
   variable result : t_slv32;
variable i : natural;
begin

   result := std_logic_vector(to_unsigned(a, 32));
   return result;
end to_slv32;
--function f_set_seed(s : natural) is 
--begin
--   RV.SetSeed(s);
--end f_set_seed;

--                              r_stall_tmo    <= set_stall_tmo(g_data(i), r_time);

end wb_testsuite_pkg;

