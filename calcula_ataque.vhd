library work;
use work.BattleShip.ALL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity calcula_ataque is
    Port ( clk : in STD_LOGIC;
           ataque : out coordenada;
           prob_ataque : out integer;
           dados_recebidos : in resposta_serial;
           ready : in STD_LOGIC);
end calcula_ataque;


architecture Behavioral of calcula_ataque is


--Sinais Gerais----
signal ataques_feitos : table; -- Sinal para gravar onde já foi feito os ataques
signal s_ready: std_logic :='0';
signal atacou: boolean := FALSE;
signal s_atacou: boolean := FALSE;
signal flag_atacou: boolean := TRUE;
signal s_ataque :coordenada := (others => '0');

signal resposta_do_ataque :  resposta_serial;
signal localizacao_do_ataque :  coordenada;

    
----Definição para a probabilidade inicial------------

--Modelo Jhonathan:

--signal likehood_current : table_likehood := ((20, 10, 10, 10,30, 10, 10, 10, 20, 20),(10, 20, 10, 10, 30, 10, 10, 20, 10, 10),(10, 10, 20, 10,30, 10, 20, 10, 10, 10),(10, 10, 10, 20,30, 20, 10, 10, 10, 10),(30, 30, 30, 30, 40, 30, 30, 30, 30, 30),(10, 10, 20, 10,30, 10, 20, 10, 10, 10),(10, 20, 10, 10,30, 10, 10, 20, 10, 10),(20, 10, 10, 10,30, 10, 10, 10, 20, 10),(20, 10, 10, 10, 30, 10, 10, 10, 10, 20), (20, 10, 10, 10,30, 10, 10, 10, 10, 20)) ;
--constant likehood_Start : table_likehood := ((20, 10, 10, 10,30, 10, 10, 10, 20, 20),(10, 20, 10, 10, 30, 10, 10, 20, 10, 10),(10, 10, 20, 10,30, 10, 20, 10, 10, 10),(10, 10, 10, 20,30, 20, 10, 10, 10, 10),(30, 30, 30, 30, 40, 30, 30, 30, 30, 30),(10, 10, 20, 10,30, 10, 20, 10, 10, 10),(10, 20, 10, 10,30, 10, 10, 20, 10, 10),(20, 10, 10, 10,30, 10, 10, 10, 20, 10),(20, 10, 10, 10, 30, 10, 10, 10, 10, 20), (20, 10, 10, 10,30, 10, 10, 10, 10, 20)) ;
--signal total: integer := 1580;
----------------------Total = 1580


---Modelo Misael:
--signal likehood_Start : table_likehood := ((20, 10, 10, 10,30, 10, 10, 10, 20, 20),(10, 20, 10, 10, 30, 10, 10, 20, 10, 10),(10, 10, 20, 10,30, 10, 20, 10, 10, 10),(30, 30, 30, 30, 40, 30, 30, 30, 30, 30),(10, 10, 10, 20,30, 20, 10, 10, 10, 10),(10, 10, 20, 10,30, 10, 20, 10, 10, 10),(10, 20, 10, 10,30, 10, 10, 20, 10, 10),(20, 10, 10, 10,30, 10, 10, 10, 20, 10),(20, 10, 10, 10, 30, 10, 10, 10, 10, 20), (20, 10, 10, 10,30, 10, 10, 10, 10, 20)) ;
--signal total: integer := 1056;
--Total

---Modelo Battle Ship Calculator:
signal likehood_current : table_likehood := ((300, 115, 143, 159,167, 167, 159, 143, 115, 80),(115, 143, 166, 178, 184, 184, 178, 166, 143, 115),(143, 166, 184, 194, 199, 199, 194, 184, 166, 143),(159, 178, 194, 203, 208, 208, 203, 194, 178, 159),(159, 178, 194, 203,208, 208, 203, 194, 178, 159),(167, 184, 199, 208,214,214, 208, 199, 184, 167),(167, 184, 199, 208,214, 214, 208, 199, 184, 167),(159, 178, 194, 203,208, 208, 203, 194, 178, 159),(143, 166, 184, 194, 199, 199, 194, 184, 166, 143), (80, 115, 143, 159,167, 167, 159, 143, 115, 80)) ;
signal nova_probabilidade : table_likehood := ((300, 115, 143, 159,167, 167, 159, 143, 115, 80),(115, 143, 166, 178, 184, 184, 178, 166, 143, 115),(143, 166, 184, 194, 199, 199, 194, 184, 166, 143),(159, 178, 194, 203, 208, 208, 203, 194, 178, 159),(159, 178, 194, 203,208, 208, 203, 194, 178, 159),(167, 184, 199, 208,214,214, 208, 199, 184, 167),(167, 184, 199, 208,214, 214, 208, 199, 184, 167),(159, 178, 194, 203,208, 208, 203, 194, 178, 159),(143, 166, 184, 194, 199, 199, 194, 184, 166, 143), (80, 115, 143, 159,167, 167, 159, 143, 115, 80)) ;
constant likehood_Start : table_likehood := ((300, 115, 143, 159,167, 167, 159, 143, 115, 80),(115, 143, 166, 178, 184, 184, 178, 166, 143, 115),(143, 166, 184, 194, 199, 199, 194, 184, 166, 143),(159, 178, 194, 203, 208, 208, 203, 194, 178, 159),(159, 178, 194, 203,208, 208, 203, 194, 178, 159),(167, 184, 199, 208,214,214, 208, 199, 184, 167),(167, 184, 199, 208,214, 214, 208, 199, 184, 167),(159, 178, 194, 203,208, 208, 203, 194, 178, 159),(143, 166, 184, 194, 199, 199, 194, 184, 166, 143), (80, 115, 143, 159,167, 167, 159, 143, 115, 80)) ;
signal total: integer := 17000;
--Total
begin

ATACAR:process(clk,likehood_current)
begin
    if(rising_edge(clk)) then
        if(s_ready = '1') then
            procura_maior_probabilidade(s_ataque,likehood_current,prob_ataque);
            s_atacou <=TRUE;
        else
            s_atacou <=FALSE;
        end if;
        
    end if;
end process ATACAR;

--CALCULA_PROBABILIDADE: process(clk,atacou,dados_recebidos)
--begin
--    if(rising_edge(clk)) then
--        if(atacou) then
--             calcula_nova_probabilidade(likehood_current, dados_recebidos,s_ataque,likehood_Start);      
--             flag_atacou <=FALSE;
--        else
--              flag_atacou <=TRUE;
           
--        end if;
--    end if;

--end process CALCULA_PROBABILIDADE ;
localizacao_do_ataque <= s_ataque;
resposta_do_ataque <= dados_recebidos;

process(clk)
    
variable linha : integer := 0;
variable coluna : integer := 0;
variable distancia : integer := 0;
                            
     
 variable linhap1 : integer := 0;    
 variable linham1 : integer := 0;    
 
 variable colunap1 : integer := 0;
 variable colunam1 : integer := 0; 
 
 variable prob_linhap1: integer := 0;    
 variable prob_linham1: integer := 0;    
 variable prob_colunap1: integer := 0;    
 variable prob_colunam1: integer := 0;    
                            
 variable total_retirado : integer := 0;                          
 variable flag_retirado : integer := 0;                          
 
                      
                            
               
 constant peso0: integer := -3;                         
 constant peso1: integer := -1;                         
 constant peso2: integer := 0;                         
 constant peso3: integer := 1;                         
 constant peso4: integer := 2;                         
 constant peso5: integer := 1;                         
 constant peso6: integer := 0;                         
 constant peso7: integer := -1;                         
 constant peso8: integer := -2;                         
 constant peso9: integer := -2;                         
    
 variable peso_linhap1: integer := 0;                        
 variable peso_colunam1: integer := 0;                        
 variable peso_colunap1: integer := 0;                        
 variable peso_linham1: integer := 0;                        
                          
begin
    linha := conveter_std_logic_int_3bits(localizacao_do_ataque(7 downto 4));
    coluna := conveter_std_logic_int_3bits(localizacao_do_ataque(3 downto 0));
    linhap1 := linha + 1;
    linham1 := linha - 1;
    colunap1 := coluna + 1;
    colunam1 := coluna - 1;
    
    case linhap1 is
        when 0  => peso_linhap1 := peso0;
        when 1  => peso_linhap1 := peso1;
        when 2  => peso_linhap1 := peso2;
        when 3  => peso_linhap1 := peso3;
        when 4  => peso_linhap1 := peso4;
        when 5  => peso_linhap1 := peso5;
        when 6  => peso_linhap1 := peso6;
        when 7  => peso_linhap1 := peso7;
        when 8  => peso_linhap1 := peso8;
        when 9  => peso_linhap1 := peso9;
        when others  => NULL;
     end case;

    
    case linham1 is
        when 0  => peso_linham1 := peso0;
        when 1  => peso_linham1 := peso1;
        when 2  => peso_linham1 := peso2;
        when 3  => peso_linham1 := peso3;
        when 4  => peso_linham1 := peso4;
        when 5  => peso_linham1 := peso5;
        when 6  => peso_linham1 := peso6;
        when 7  => peso_linham1 := peso7;
        when 8  => peso_linham1 := peso8;
        when 9  => peso_linham1 := peso9;
        when others  => NULL;
     end case;

    
    case colunap1 is
        when 0  => peso_colunap1 := peso0;
        when 1  => peso_colunap1 := peso1;
        when 2  => peso_colunap1 := peso2;
        when 3  => peso_colunap1 := peso3;
        when 4  => peso_colunap1 := peso4;
        when 5  => peso_colunap1 := peso5;
        when 6  => peso_colunap1 := peso6;
        when 7  => peso_colunap1 := peso7;
        when 8  => peso_colunap1 := peso8;
        when 9  => peso_colunap1 := peso9;
        when others  => NULL;
     end case;

    
    case colunam1 is
        when 0  => peso_colunam1 := peso0;
        when 1  => peso_colunam1 := peso1;
        when 2  => peso_colunam1 := peso2;
        when 3  => peso_colunam1 := peso3;
        when 4  => peso_colunam1 := peso4;
        when 5  => peso_colunam1 := peso5;
        when 6  => peso_colunam1 := peso6;
        when 7  => peso_colunam1 := peso7;
        when 8  => peso_colunam1 := peso8;
        when 9  => peso_colunam1 := peso9;
        when others  => NULL;
     end case;



    if(resposta_do_ataque = O) then
        total_retirado := nova_probabilidade(linha,coluna) ;
        nova_probabilidade(linha,coluna) <= 0;
        if(coluna = 0) then
           if(linhap1 /= 10) then
                 if(linham1 /= -1) then
                       flag_retirado := (likehood_start(linhap1,coluna) * 15) / 10;
                       prob_linhap1 :=    nova_probabilidade(linhap1,coluna) - flag_retirado + peso_linhap1;
                       total_retirado := total_retirado + flag_retirado;
                       flag_retirado := (likehood_start(linha,colunap1)* 15) / 10;
                       prob_colunap1 :=    nova_probabilidade(linha,colunap1) - flag_retirado + peso_colunap1 ;
                       total_retirado := total_retirado + flag_retirado;
                       flag_retirado := (likehood_start(linham1,coluna) * 15) / 10;
                       prob_linham1 :=    nova_probabilidade(linham1,coluna) - flag_retirado + peso_linham1  ;
                       total_retirado := total_retirado + flag_retirado;
                       total_retirado:= ((total_retirado - (peso_linham1 + peso_linhap1 + peso_colunap1))* 10) / 96;
                        nova_probabilidade(linhap1,coluna) <= -prob_linhap1;
                        nova_probabilidade(linha,colunap1) <= -prob_colunap1;
                        nova_probabilidade(linham1,coluna) <= -prob_linham1;
                       
                  for i in 0 to 9 loop
                             for j in 0 to 9 loop
                               distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));
                                if(not((i = linhap1 and j = coluna) or (i = linham1 and j = coluna)  or (i = linha and j = coluna) or ( j = colunam1 and i = linha)   )) then
                               if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                                       nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  + (total_retirado *( distancia/100));  
                               else
                                     NULL;
                               end if;         
                         else
                            NULL;  
                         end if;  
                 end loop;
                     end loop;
    
            end if;  
    else
          NULL;          
     end if;
 else
     NULL;     
 end if; 
 
       if(linha = 9) then
  if(colunap1 /= 10) then
        if(colunam1 /= -1) then
              flag_retirado := (likehood_start(linham1,coluna) ) / 2;
              prob_linham1 :=    nova_probabilidade(linham1,coluna) - flag_retirado + peso_linham1;
              total_retirado := total_retirado + flag_retirado;
              flag_retirado := (likehood_start(linha,colunam1)) / 2;
              prob_colunam1 :=    nova_probabilidade(linha,colunam1) - flag_retirado + peso_colunam1 ;
              total_retirado := total_retirado + flag_retirado;
              flag_retirado := (likehood_start(linha,colunap1) ) / 2;
              prob_colunap1 :=    nova_probabilidade(linha,colunap1) - flag_retirado + peso_colunap1  ;
              total_retirado := total_retirado + flag_retirado;
              total_retirado:= ((total_retirado - (peso_colunap1 + peso_linham1 + peso_colunam1))* 10) / 96;
               nova_probabilidade(linham1,coluna) <=prob_linham1;
               nova_probabilidade(linha,colunam1) <= prob_colunam1;
               nova_probabilidade(linha,colunap1) <= prob_colunap1;
              
         for i in 0 to 9 loop
                    for j in 0 to 9 loop
                       if(not((i = linham1 and j = coluna) or (i = linha and j = colunap1)  or (i = linha and j = coluna) or ( j = colunam1 and i = linha)   )) then
                       distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                              nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  + (total_retirado *( distancia)/1000);
                      else
                            NULL;
                      end if;         
                else
                   NULL;  
                end if;  
        end loop;
            end loop;

   end if;  
else
 NULL;          
end if;
else
NULL;     
end if; 
 

 
      if(linha = 0) then
       if(colunap1 /= 10) then
             if(colunam1 /= -1) then
                   flag_retirado := (likehood_start(linhap1,coluna) ) / 2;
                   prob_linhap1 :=    nova_probabilidade(linhap1,coluna) - flag_retirado + peso_linhap1;
                   total_retirado := total_retirado + flag_retirado;
                   flag_retirado := (likehood_start(linha,colunam1)) / 2;
                   prob_colunam1 :=    nova_probabilidade(linha,colunam1) - flag_retirado + peso_colunam1 ;
                   total_retirado := total_retirado + flag_retirado;
                   flag_retirado := (likehood_start(linha,colunap1) ) / 2;
                   prob_colunap1 :=    nova_probabilidade(linha,colunap1) - flag_retirado + peso_colunap1  ;
                   total_retirado := total_retirado + flag_retirado;
                   total_retirado:= ((total_retirado - (peso_colunap1 + peso_linhap1 + peso_colunam1))* 10) / 96;
                    nova_probabilidade(linhap1,coluna) <=prob_linhap1;
                    nova_probabilidade(linha,colunam1) <= prob_colunam1;
                    nova_probabilidade(linha,colunap1) <= prob_colunap1;
                   
              for i in 0 to 9 loop
                         for j in 0 to 9 loop
                            if(not((i = linhap1 and j = coluna) or (i = linha and j = colunap1)  or (i = linha and j = coluna) or ( j = colunam1 and i = linha)   )) then
                                                        distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                                   nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  + ((total_retirado * distancia) /100) ;
                           else
                                 NULL;
                           end if;         
                     else
                        NULL;  
                     end if;  
             end loop;
                 end loop;

        end if;  
else
      NULL;          
 end if;
else
 NULL;     
end if; 
  
        if(linha = 0) then
 if(coluna = 0) then
             flag_retirado := (likehood_start(linhap1,coluna) ) / 2;
             prob_linhap1 :=    nova_probabilidade(linhap1,coluna) - flag_retirado + peso_linhap1;
             total_retirado := total_retirado + flag_retirado;
             flag_retirado := (likehood_start(linha,colunap1) ) / 2;
             prob_colunap1 :=    nova_probabilidade(linha,colunap1) - flag_retirado + peso_colunap1  ;
             total_retirado := total_retirado + flag_retirado;
             total_retirado:= ((total_retirado - (peso_colunap1 + peso_linhap1 + peso_colunam1))* 10) / 96;
              nova_probabilidade(linhap1,coluna) <=prob_linhap1;
              nova_probabilidade(linha,colunap1) <= prob_colunap1;
             
        for i in 0 to 9 loop
                   for j in 0 to 9 loop
                      if(not((i = linhap1 and j = coluna) or (i = linha and j = colunap1)  or (i = linha and j = coluna)   )) then
                                                  distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                             nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  + (((total_retirado * distancia) /100));
                     else
                           NULL;
                     end if;         
               else
                  NULL;  
               end if;  
       end loop;
           end loop;

  end if;  

else
NULL;     
end if; 
  
 if(linha = 9) then
if(coluna = 0) then
            flag_retirado := (likehood_start(linham1,coluna) ) /2;
            prob_linham1 :=    nova_probabilidade(linham1,coluna) - flag_retirado + peso_linham1;
            total_retirado := total_retirado + flag_retirado;
            flag_retirado := (likehood_start(linha,colunap1) ) /2;
            prob_colunap1 :=    nova_probabilidade(linha,colunap1) - flag_retirado + peso_colunap1  ;
            total_retirado := total_retirado + flag_retirado;
            total_retirado:= ((total_retirado - (peso_colunap1 + peso_linham1 + peso_colunam1))* 10) / 96;
             nova_probabilidade(linham1,coluna) <=prob_linham1;
             nova_probabilidade(linha,colunap1) <= prob_colunap1;
            
       for i in 0 to 9 loop
                  for j in 0 to 9 loop
                     if(not((i = linham1 and j = coluna) or (i = linha and j = colunap1)  or (i = linha and j = coluna)   )) then
                                                 distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                            nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  + (((total_retirado * distancia) /100));
                    else
                          NULL;
                    end if;         
              else
                 NULL;  
              end if;  
      end loop;
          end loop;

 end if;  

else
NULL;     
end if; 

 
  if(linha = 9) then
if(coluna = 9) then
           flag_retirado := (likehood_start(linham1,coluna) ) /2;
           prob_linham1 :=    nova_probabilidade(linham1,coluna) - flag_retirado + peso_linham1;
           total_retirado := total_retirado + flag_retirado;
           flag_retirado := (likehood_start(linha,colunam1) ) /2;
           prob_colunam1 :=    nova_probabilidade(linha,colunam1) - flag_retirado + peso_colunam1  ;
           total_retirado := total_retirado + flag_retirado;
           total_retirado:= ((total_retirado - (peso_colunam1 + peso_linham1 + peso_colunam1))* 10) / 96;
            nova_probabilidade(linham1,coluna) <=prob_linham1;
            nova_probabilidade(linha,colunam1) <= prob_colunam1;
           
      for i in 0 to 9 loop
                 for j in 0 to 9 loop
                    if(not((i = linham1 and j = coluna) or (i = linha and j = colunam1)  or (i = linha and j = coluna)   )) then
                                                distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                           nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  + (((total_retirado * distancia) /100));
                   else
                         NULL;
                   end if;         
             else
                NULL;  
             end if;  
     end loop;
         end loop;

end if;  

else
NULL;     
end if; 

if(linha = 0) then
 if(coluna = 9) then
             flag_retirado := (likehood_start(linhap1,coluna) ) / 2;
             prob_linhap1 :=    nova_probabilidade(linhap1,coluna) - flag_retirado + peso_linhap1;
             total_retirado := total_retirado + flag_retirado;
             flag_retirado := (likehood_start(linha,colunam1) ) / 2;
             prob_colunam1 :=    nova_probabilidade(linha,colunam1) - flag_retirado + peso_colunam1  ;
             total_retirado := total_retirado + flag_retirado;
             total_retirado:= ((total_retirado - (peso_colunam1 + peso_linhap1 + peso_colunam1))* 10) / 96;
              nova_probabilidade(linhap1,coluna) <=prob_linhap1;
              nova_probabilidade(linha,colunam1) <= prob_colunam1;
             
        for i in 0 to 9 loop
                   for j in 0 to 9 loop
                      if(not((i = linhap1 and j = coluna) or (i = linha and j = colunam1)  or (i = linha and j = coluna)   )) then
                                                  distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                             nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  + (((total_retirado * distancia) /100));
                     else
                           NULL;
                     end if;         
               else
                  NULL;  
               end if;  
       end loop;
           end loop;

  end if;  

else
NULL;     
end if; 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
  
  
  
  
  
  
     
    if(coluna = 9) then
   if(linhap1 /= 10) then
         if(linham1 /= -1) then
               flag_retirado := (likehood_start(linhap1,coluna) ) / 2;
               prob_linhap1 :=    nova_probabilidade(linhap1,coluna) - flag_retirado + peso_linhap1;
               total_retirado := total_retirado + flag_retirado;
               flag_retirado := (likehood_start(linha,colunam1)) / 2;
               prob_colunam1 :=    nova_probabilidade(linha,colunam1) - flag_retirado + peso_colunam1 ;
               total_retirado := total_retirado + flag_retirado;
               flag_retirado := (likehood_start(linham1,coluna) ) / 2;
               prob_linham1 :=    nova_probabilidade(linham1,coluna) - flag_retirado + peso_linham1  ;
               total_retirado := total_retirado + flag_retirado;
               total_retirado:= ((total_retirado - (peso_linham1 + peso_linhap1 + peso_colunam1))* 10) / 96;
                nova_probabilidade(linhap1,coluna) <=prob_linhap1;
                nova_probabilidade(linha,colunam1) <= prob_colunam1;
                nova_probabilidade(linham1,coluna) <= prob_linham1;
               
          for i in 0 to 9 loop
                     for j in 0 to 9 loop
                        if(not((i = linhap1 and j = coluna) or (i = linham1 and j = coluna)  or (i = linha and j = coluna) or ( j = colunam1 and i = linha)   )) then
                                                    distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                               nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  + (((total_retirado * distancia) /100));
                       else
                             NULL;
                       end if;         
                 else
                    NULL;  
                 end if;  
         end loop;
             end loop;

    end if;  
else
  NULL;          
end if;
else
NULL;     
end if; 
 


  
  
  
  
  
  
  
  
        
        
        
elsif(resposta_do_ataque = X) then
       nova_probabilidade(linha,coluna) <= 0;
 if(colunam1 < 0) then
    if(linhap1 <= 9) then
          if(linham1 >= 0) then
                flag_retirado := (likehood_start(linhap1,coluna) * 15) / 10;
                prob_linhap1 :=    nova_probabilidade(linhap1,coluna) + flag_retirado + peso_linhap1;
                prob_linhap1 :=    nova_probabilidade(linhap1,coluna) + flag_retirado + peso_linhap1;
                total_retirado := total_retirado + flag_retirado;
                flag_retirado := (likehood_start(linha,colunap1)* 15) / 10;
                prob_colunap1 :=    nova_probabilidade(linha,colunap1) + flag_retirado + peso_colunap1 ;
                total_retirado := total_retirado + flag_retirado;
                flag_retirado := (likehood_start(linham1,coluna) * 15) / 10;
                prob_linham1 :=    nova_probabilidade(linham1,coluna) + flag_retirado + peso_linham1  ;
                total_retirado := total_retirado + flag_retirado;
                total_retirado:= ((total_retirado - (peso_linham1 + peso_linhap1 + peso_colunap1))* 10) / 96;
                 nova_probabilidade(linhap1,coluna) <= prob_linhap1;
                 nova_probabilidade(linha,colunap1) <= prob_colunap1;
                 nova_probabilidade(linham1,coluna) <= prob_linham1;
                
                for i in 0 to 9 loop
                     for j in 0 to 9 loop
                        if(not((i = linhap1 and j = coluna) or (i = linham1 and j = coluna)  or (i = linha and j = coluna) or ( j = colunap1 and i = linha)   )) then
                                      distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                                       nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  - (((total_retirado * distancia) /100));
                               else
                                     NULL;
                               end if;         
                         else
                            NULL;  
                         end if;  
                 end loop;
                     end loop;
    
            end if;  
    else
          NULL;          
     end if;
 else
     NULL;     
 end if; 

if(linha = 9) then
  if(colunap1 /= 10) then
        if(colunam1 /= -1) then
              flag_retirado := (likehood_start(linham1,coluna) ) / 2;
              prob_linham1 :=    nova_probabilidade(linham1,coluna) + flag_retirado + peso_linham1;
              total_retirado := total_retirado + flag_retirado;
              flag_retirado := (likehood_start(linha,colunam1)) / 2;
              prob_colunam1 :=    nova_probabilidade(linha,colunam1) + flag_retirado + peso_colunam1 ;
              total_retirado := total_retirado + flag_retirado;
              flag_retirado := (likehood_start(linha,colunap1) ) / 2;
              prob_colunap1 :=    nova_probabilidade(linha,colunap1) + flag_retirado + peso_colunap1  ;
              total_retirado := total_retirado + flag_retirado;
              total_retirado:= ((total_retirado - (peso_colunap1 + peso_linham1 + peso_colunam1))* 10) / 96;
               nova_probabilidade(linham1,coluna) <=prob_linham1;
               nova_probabilidade(linha,colunam1) <= prob_colunam1;
               nova_probabilidade(linha,colunap1) <= prob_colunap1;
              
         for i in 0 to 9 loop
                    for j in 0 to 9 loop
                       if(not((i = linham1 and j = coluna) or (i = linha and j = colunap1)  or (i = linha and j = coluna) or ( j = colunam1 and i = linha)   )) then
                              distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   
                              if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                              nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  - (total_retirado *( distancia/100));
                      else
                            NULL;
                      end if;         
                else
                   NULL;  
                end if;  
        end loop;
            end loop;

   end if;  
else
 NULL;          
end if;
else
NULL;     
end if; 
 
if(linha = 0) then
       if(colunap1 /= 10) then
             if(colunam1 /= -1) then
                   flag_retirado := (likehood_start(linhap1,coluna) ) / 2;
                   prob_linhap1 :=    nova_probabilidade(linhap1,coluna) + flag_retirado + peso_linhap1;
                   total_retirado := total_retirado + flag_retirado;
                   flag_retirado := (likehood_start(linha,colunam1)) / 2;
                   prob_colunam1 :=    nova_probabilidade(linha,colunam1) + flag_retirado + peso_colunam1 ;
                   total_retirado := total_retirado + flag_retirado;
                   flag_retirado := (likehood_start(linha,colunap1) ) / 2;
                   prob_colunap1 :=    nova_probabilidade(linha,colunap1) + flag_retirado + peso_colunap1  ;
                   total_retirado := total_retirado + flag_retirado;
                   total_retirado:= ((total_retirado - (peso_colunap1 + peso_linhap1 + peso_colunam1))* 10) / 96;
                    nova_probabilidade(linhap1,coluna) <=prob_linhap1;
                    nova_probabilidade(linha,colunam1) <= prob_colunam1;
                    nova_probabilidade(linha,colunap1) <= prob_colunap1;
                   
              for i in 0 to 9 loop
                         for j in 0 to 9 loop
                            if(not((i = linhap1 and j = coluna) or (i = linha and j = colunap1)  or (i = linha and j = coluna) or ( j = colunam1 and i = linha)   )) then
                                   distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));
                              if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                                   nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  - ((total_retirado * distancia) /100);
                           else
                                 NULL;
                           end if;         
                     else
                        NULL;  
                     end if;  
             end loop;
                 end loop;

        end if;  
else
      NULL;          
 end if;
else
 NULL;     
end if; 


if(coluna = 9) then
       if(linhap1 /= 10) then
             if(linham1 /= -1) then
                   flag_retirado := (likehood_start(linhap1,coluna)*15 ) / 10;
                   prob_linhap1 :=    nova_probabilidade(linhap1,coluna) - flag_retirado + peso_linhap1;
                   total_retirado := total_retirado + flag_retirado;
                   flag_retirado := (likehood_start(linha,colunam1)*15 ) / 10;
                   prob_colunam1 :=    nova_probabilidade(linha,colunam1) - flag_retirado + peso_colunam1 ;
                   total_retirado := total_retirado + flag_retirado;
                   flag_retirado := (likehood_start(linham1,coluna)*15 ) / 10;
                   prob_linham1 :=    nova_probabilidade(linham1,coluna) - flag_retirado + peso_linham1  ;
                   total_retirado := total_retirado + flag_retirado;
                   total_retirado:= ((total_retirado - (peso_linham1 + peso_linhap1 + peso_colunam1))* 10) / 96;
                    nova_probabilidade(linhap1,coluna) <=prob_linhap1;
                    nova_probabilidade(linha,colunam1) <= prob_colunam1;
                    nova_probabilidade(linham1,coluna) <= prob_linham1;
                   
              for i in 0 to 9 loop
                         for j in 0 to 9 loop
                            if(not((i = linhap1 and j = coluna) or (i = linham1 and j = coluna)  or (i = linha and j = coluna) or ( j = colunam1 and i = linha)   )) then
                                                        distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                                   nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  - ((total_retirado * distancia) /100);
                           else
                                 NULL;
                           end if;         
                     else
                        NULL;  
                     end if;  
             end loop;
                 end loop;

        end if;  
else
      NULL;          
 end if;
else
 NULL;     
end if; 

if(linha = 0) then
 if(coluna = 9) then
             flag_retirado := (likehood_start(linhap1,coluna) ) / 2;
             prob_linhap1 :=    nova_probabilidade(linhap1,coluna) + flag_retirado*5 + peso_linhap1;
             total_retirado := total_retirado + flag_retirado;
             flag_retirado := (likehood_start(linha,colunam1) ) / 2;
             prob_colunam1 :=    nova_probabilidade(linha,colunam1) + flag_retirado*5 + peso_colunam1  ;
             total_retirado := total_retirado + flag_retirado;
             total_retirado:= ((total_retirado - (peso_colunam1 + peso_linhap1 + peso_colunam1))* 10) / 96;
              nova_probabilidade(linhap1,coluna) <=prob_linhap1;
              nova_probabilidade(linha,colunam1) <= prob_colunam1;
             
        for i in 0 to 9 loop
                   for j in 0 to 9 loop
                      if(not((i = linhap1 and j = coluna) or (i = linha and j = colunam1)  or (i = linha and j = coluna)   )) then
                                                  distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                             nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  - ((total_retirado * distancia) /100);
                     else
                           NULL;
                     end if;         
               else
                  NULL;  
               end if;  
       end loop;
           end loop;

  end if;  

else
NULL;     
end if; 














 if(linha = 0) then
 if(coluna = 0) then
             flag_retirado := (likehood_start(linhap1,coluna) ) /2;
             prob_linhap1 :=    nova_probabilidade(linhap1,coluna) + flag_retirado*5 + peso_linhap1;
             total_retirado := total_retirado + flag_retirado;
             flag_retirado := (likehood_start(linha,colunap1) ) /2;
             prob_colunap1 :=    nova_probabilidade(linha,colunap1) + flag_retirado*5 + peso_colunap1  ;
             total_retirado := total_retirado + flag_retirado;
             total_retirado:= ((total_retirado - (peso_colunap1 + peso_linhap1 + peso_colunam1))* 10) / 96;
              nova_probabilidade(linhap1,coluna) <=prob_linhap1;
              nova_probabilidade(linha,colunap1) <= prob_colunap1;
             
        for i in 0 to 9 loop
                   for j in 0 to 9 loop
                      if(not((i = linhap1 and j = coluna) or (i = linha and j = colunap1)  or (i = linha and j = coluna)   ) ) then

                            distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));
                             if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                             nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  - ((total_retirado * distancia) /100);
                     else
                           NULL;
                     end if;         
               else
                  NULL;  
               end if;  
       end loop;
           end loop;

  end if;  

else
NULL;     
end if; 
  
  if(linha = 9) then
if(coluna = 9) then
         flag_retirado := (likehood_start(linham1,coluna) ) /2;
         prob_linham1 :=    nova_probabilidade(linham1,coluna) - flag_retirado*5 + peso_linham1;
         total_retirado := total_retirado + flag_retirado;
         flag_retirado := (likehood_start(linha,colunam1) ) /2;
         prob_colunam1 :=    nova_probabilidade(linha,colunam1) - flag_retirado*5 + peso_colunam1  ;
         total_retirado := total_retirado + flag_retirado;
         total_retirado:= ((total_retirado - (peso_colunam1 + peso_linham1 + peso_colunam1))* 10) / 96;
          nova_probabilidade(linham1,coluna) <=prob_linham1;
          nova_probabilidade(linha,colunam1) <= prob_colunam1;
         
    for i in 0 to 9 loop
               for j in 0 to 9 loop
                  if(not((i = linham1 and j = coluna) or (i = linha and j = colunam1)  or (i = linha and j = coluna)   )) then
                                              distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                         nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  - ((total_retirado * distancia) /100);
                 else
                       NULL;
                 end if;         
           else
              NULL;  
           end if;  
   end loop;
       end loop;

end if;  

else
NULL;     
end if; 

 if(linha = 9) then
 if(coluna = 0) then
             flag_retirado := (likehood_start(linham1,coluna) ) /2;
             prob_linham1 :=    nova_probabilidade(linham1,coluna) + flag_retirado*5 + peso_linham1;
             total_retirado := total_retirado + flag_retirado;
             flag_retirado := (likehood_start(linha,colunap1) ) /2;
             prob_colunap1 :=    nova_probabilidade(linha,colunap1) + flag_retirado*5 + peso_colunap1  ;
             total_retirado := total_retirado + flag_retirado;
             total_retirado:= ((total_retirado - (peso_colunap1 + peso_linham1 + peso_colunam1))* 10) / 96;
              nova_probabilidade(linham1,coluna) <=prob_linham1;
              nova_probabilidade(linha,colunap1) <= prob_colunap1;
             
        for i in 0 to 9 loop
                   for j in 0 to 9 loop
                      if(not((i = linham1 and j = coluna) or (i = linha and j = colunap1)  or (i = linha and j = coluna)   )) then
                                                  distancia := ( (i-linha)*(i-linha) + (j - coluna)* (j - coluna));   if(nova_probabilidade(i,j) /= 0 and (distancia /= 2)) then
                             nova_probabilidade(i,j) <=  nova_probabilidade(i,j)  - ((total_retirado * distancia) /100);
                     else
                           NULL;
                     end if;         
               else
                  NULL;  
               end if;  
       end loop;
           end loop;

  end if;  

else
NULL;     
end if; 


 end if;
        for i in 0 to 9 loop
         for j in 0 to 9 loop
            if(nova_probabilidade(i,j) <= 1) then
                nova_probabilidade(i,j)<= 0;
            else
                NULL;  
             end if;  
     end loop;
         end loop;
         

         
end process;  




s_ready <= ready;
ataque <= s_ataque ;
atacou <= flag_atacou and s_atacou;




end Behavioral;
