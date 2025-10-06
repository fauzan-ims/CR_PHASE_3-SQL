CREATE FUNCTION [dbo].[fn_bulaninword] (@p_bulan as int) 
RETURNS nvarchar (20) AS 
BEGIN
	declare @hasil	nvarchar(20)
	
	if @p_bulan = 1	
		set @hasil = 'Januari'
	else if @p_bulan = 2
		set @hasil = 'Februari'
	else if @p_bulan = 3
		set @hasil = 'Maret'
	else if @p_bulan = 4
		set @hasil = 'April'
	else if @p_bulan = 5
		set @hasil = 'Mei'
	else if @p_bulan = 6
		set @hasil = 'Juni'
	else if @p_bulan = 7
		set @hasil = 'Juli'
	else if @p_bulan = 8
		set @hasil = 'Agustus'
	else if @p_bulan = 9
		set @hasil = 'September'
	else if @p_bulan = 10
		set @hasil = 'Oktober'
	else if @p_bulan = 11
		set @hasil = 'November'
	else if @p_bulan = 12
		set @hasil = 'Desember'
		
		 
		
return (@hasil)
END

