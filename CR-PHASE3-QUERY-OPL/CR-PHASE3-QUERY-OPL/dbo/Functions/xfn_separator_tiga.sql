create function [dbo].[xfn_separator_tiga] (@p_angka as decimal(18,2)) 
RETURNS nvarchar (50) AS 
BEGIN
	declare @hasil	nvarchar(50)
	
	set @hasil = format(@p_angka, 'N', 'de-de')
		
return (@hasil)
END

