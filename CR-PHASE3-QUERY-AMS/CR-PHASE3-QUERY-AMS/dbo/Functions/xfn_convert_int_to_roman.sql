CREATE FUNCTION [dbo].[xfn_convert_int_to_roman](@i INT)  
RETURNS VARCHAR(100)  
AS  
BEGIN  
    RETURN    Replicate('M', @i/1000)  
            + REPLACE(REPLACE(REPLACE(  
                  Replicate('C', @i%1000/100),  
                  Replicate('C', 9), 'CM'),  
                  Replicate('C', 5), 'D'),  
                  Replicate('C', 4), 'CD')  
             + REPLACE(REPLACE(REPLACE(  
                  Replicate('X', @i%100 / 10),  
                  Replicate('X', 9),'XC'),  
                  Replicate('X', 5), 'L'),  
                  Replicate('X', 4), 'XL')  
             + REPLACE(REPLACE(REPLACE(  
                  Replicate('I', @i%10),  
                  Replicate('I', 9),'IX'),  
                  Replicate('I', 5), 'V'),  
                  Replicate('I', 4),'IV')  
  
END  