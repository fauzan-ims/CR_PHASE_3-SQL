CREATE FUNCTION dbo.xfn_bulan_indonesia (@p_tanggal as datetime) 
RETURNS nvarchar (50) AS 
BEGIN
	declare @hasil	nvarchar(20)
	
	set @hasil = cast(day(@p_tanggal) as nvarchar(20)) + ' ' +dbo.fn_bulaninword(datepart(month,@p_tanggal))+ ' ' +cast(year(@p_tanggal) as nvarchar(20))	 
		
return (@hasil)
END

