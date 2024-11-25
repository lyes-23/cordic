
-- description generated by Pat driver

--			date     : Tue Nov 26 19:01:57 2024
--			revision : v109

--			sequence : cordic_par

-- input / output list :
in       ck B;;
in       nreset B;;
in       a B;;
in       x B;;
in       y B;;
in       wr_axy_p B;;
in       power ( vss, vdd ) X;;
out      wok_axy_p B;;
out      a_p (7 downto 0) X;;
out      x_p (7 downto 0) X;;
out      y_p (7 downto 0) X;;

begin

-- Pattern description :

--                                 c n a x y w p  w  a   x   y   
--                                 k r       r o  o  _   _   _   
--                                   e       _ w  k  p   p   p   
--                                   s       a e  _              
--                                   e       x r  a              
--                                   t       y    x              
--                                           _    y              
--                                           p    _              
--                                                p              

                                 : 1 1 0 0 0 0 1 ?u ?uu ?uu ?uu ;
                                 : 0 1 0 0 0 0 1 ?u ?uu ?uu ?uu ;
                                 : 1 0 1 0 0 0 1 ?u ?00 ?00 ?00 ;
                                 : 0 0 0 0 0 0 1 ?u ?00 ?00 ?00 ;
                                 : 1 0 1 0 0 1 1 ?0 ?00 ?00 ?00 ;
                                 : 0 0 1 0 0 1 1 ?0 ?00 ?00 ?00 ;
                                 : 1 0 0 1 0 1 1 ?0 ?01 ?00 ?00 ;
                                 : 0 0 0 1 0 1 1 ?0 ?01 ?00 ?00 ;
                                 : 1 0 1 1 0 1 1 ?0 ?02 ?01 ?00 ;
                                 : 0 0 1 1 0 1 1 ?0 ?02 ?01 ?00 ;
                                 : 1 0 1 0 1 1 1 ?0 ?05 ?03 ?00 ;
                                 : 0 0 1 0 1 1 1 ?0 ?05 ?03 ?00 ;
                                 : 1 0 1 1 0 1 1 ?0 ?0b ?06 ?01 ;
                                 : 0 0 1 1 0 1 1 ?0 ?0b ?06 ?01 ;
                                 : 1 0 0 0 1 1 1 ?0 ?17 ?0d ?02 ;
                                 : 0 0 0 0 1 1 1 ?0 ?17 ?0d ?02 ;
                                 : 1 0 1 0 1 1 1 ?0 ?2e ?1a ?05 ;
                                 : 0 0 1 0 1 1 1 ?0 ?2e ?1a ?05 ;
                                 : 1 0 1 0 1 1 1 ?1 ?5d ?34 ?0b ;
                                 : 0 0 1 0 1 1 1 ?1 ?5d ?34 ?0b ;
                                 : 1 0 0 1 0 0 1 ?1 ?bb ?68 ?17 ;
                                 : 0 0 0 1 0 0 1 ?1 ?bb ?68 ?17 ;
                                 : 1 0 0 0 1 0 1 ?1 ?00 ?00 ?00 ;
                                 : 0 0 0 0 1 0 1 ?1 ?00 ?00 ?00 ;
                                 : 1 0 1 0 0 0 1 ?1 ?00 ?00 ?00 ;

end;
