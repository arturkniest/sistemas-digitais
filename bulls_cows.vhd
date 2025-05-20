library ieee;--									Bibliotecas padrão
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity entidade is
    port (
        clk           										: in std_logic;--
        rst           										: in std_logic;--							
        pushBtn       										: in std_logic;--
        toggle_um, toggle_dois, toggle_tres, toggle_quatro 	: in std_logic_vector(3 downto 0);
        digito1_j1, digito2_j1, digito3_j1, digito4_j1 		: in std_logic_vector(3 downto 0);
        digito1_j2, digito2_j2, digito3_j2, digito4_j2 		: in std_logic_vector(3 downto 0);
        contador_j1     								 	: out std_logic_vector(7 downto 0);--Saídas   
        contador_j2      									: out std_logic_vector(7 downto 0);--Saídas
        display       										: out std_logic_vector(7 downto 0);--Saídas
        );
end entidade; 

package func is 
    function tem_duplicados(
        v1, v2, v3, v4 : std_logic_vector(7 downto)
    )

architecture arq of entidade is -- Por ser um circuito sequencial, architecture recebe os estados
    type state is (j1setup, j2setup, j1guess, j2guess, bullseye);-- e não como a maquina funciona,
    signal EA, PE: state;--										como seria em um sequencial.
    signal saida: state;
    
begin

    seq: process(clk, rst)--  por ser sequencial é nescessário um process
    begin  
        if rst = '1' then 
            EA <= j1setup;
        elsif risign_edge(clk) then
            EA <= PE;
        end if;
    end process;
    
	--Parte Combinacional
    comb: process(EA, pushBtn, toggle_um, toggle_dois, toggle_tres, toggle_quatro)
    
    begin   
            case EA is -- Como funciona o estado atual:
            
            -- SETUP JOGADOR 1 
            when j1setup =>
            -- Display mostra: "J1 SETUP"
				if pushBtn = '1' and --/Condicional(código válido)/                               Se o jogador clicou "pushBtn" AND código válido 
				then 
                    PE              <= j2setup--                                                    ENTÃO próx estado J2SETUP
                    toggle_um       <= digito1_j1,  --                                               Guardar toggles em variáveis
                    toggle_dois     <= digito2_j1, 
                    toggle_tres     <= digito3_j1, 
                    toggle_quatro   <= digito4_j1; 
				else PE <= j1setup;	
				end if;


			--SETUP JOGADOR 2	
			when j2setup =>
            -- Dispaly mostra: "J2 SETUP"
				if pushBtn = '1' and --/Condicional(código válido)/
				then 
                    PE              <= j1guess
                    toggle_um       <= digito1_j2,  --                                               Guardar toggles em variáveis
                    toggle_dois     <= digito2_j2, 
                    toggle_tres     <= digito3_j2, 
                    toggle_quatro   <= digito4_j2; 
				else PE <= j2setup;
				end if;


			-- GUESS DO JOFGADOR 1	
			when j1guess =>
        
            -- Display mostra: "J1 GUESS"    
				if pushBtn = '1' and /Condicional(código válido)/ and /Código correto/ 
				then 
                    PE <= bullseye;
				elsif pushBtn = '1' and /Condicional(código INVÁLIDO)/
                then
                    PE <= j1guess;
                elsif pushBtn ='1' and /Condicional(códigoválido)/ and /Código INCORRETO/
                then
                    PE <= j2 guess;
				end if;


			--Display mostra: "J2GUESS"	
			when j2guess =>
				if pushBtn = '1' and /Condicional(código válido)/ and /Código correto/
				then PE <= bullseye;
				elsif pushBtn = '1' and /Condicional(código INVÁLIDO)/
                 PE <= j2guess;
                elsif pushBtn = '1' and /Condicional(código válido)/ and /Código INCORRETO/ 
				 PE <= j1guess
                end if;


			--Display mostra: "BULLSEYE"			
			when bullseye =>
				if /j2guess (vamos fazer a variável de estado atual), ex: estAtual = '1'/
				then /Aumenta contador do jogador 2/;
				else /Aumenta contador do joagaor 1/ ;
                /Bullseye no display/ and /variáveis de estado atual dos guess, e do cógido entregue nos setups ZERADAS/ and 
                PE <= j1guess;
				end if;
