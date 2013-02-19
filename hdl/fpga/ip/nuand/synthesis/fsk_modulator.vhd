library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;
    use ieee.math_real.all ;

library work ;
    use work.nco_p.all ;

entity fsk_modulator is
  port (
    clock           :   in  std_logic ;
    reset           :   in  std_logic ;

    symbol          :   in  std_logic ;
    symbol_valid    :   in  std_logic ;

    out_real        :   out signed(15 downto 0) ;
    out_imag        :   out signed(15 downto 0) ;
    out_valid       :   out std_logic
  ) ;
end entity ; -- fsk_modulator

architecture arch of fsk_modulator is

    -- Positive deviation for ZERO and negative deviation for ONE
    constant ZERO       : signed(15 downto 0) := to_signed(integer(round(4096.0/19.2)),16) ;
    constant ONE        : signed(15 downto 0) := -ZERO ;

    signal nco_input    : nco_input_t ;
    signal nco_output   : nco_output_t ;

begin

    register_new_symbol : process(clock, reset)
        -- variable dir : std_logic ;
        -- variable dphase : signed(15 downto 0) ;
    begin
        if( reset = '1' ) then
            -- dir := '1' ;
            -- dphase := (others =>'0') ;
            nco_input.dphase <= ZERO ;
            nco_input.valid <= '0' ;
        elsif( rising_edge( clock ) ) then
            nco_input.valid <= '1' ;
            -- if( dir = '1' ) then
            --     if( dphase < 4094) then
            --         dphase := dphase + 1 ;
            --     else
            --         dphase := dphase - 1 ;
            --         dir := '0' ;
            --     end if ;
            -- else
            --     if( dphase > -4094) then
            --         dphase := dphase - 1 ;
            --     else
            --         dphase := dphase + 1 ;
            --         dir := '1' ;
            --     end if ;
            -- end if ;
            if( symbol_valid = '1' ) then
                -- nco_input.dphase <= dphase ;
                if( symbol = '0' ) then
                    nco_input.dphase <= ZERO ;
                else
                    nco_input.dphase <= ONE ;
                end if ;
            end if ;
        end if ;
    end process ;

    U_nco : entity work.nco 
      port map (
        clock   => clock,
        reset   => reset,
        inputs  => nco_input,
        outputs => nco_output
      ) ;

    out_real <= nco_output.re ;
    out_imag <= nco_output.im ;
    out_valid <= nco_output.valid ;

end architecture ; -- arch