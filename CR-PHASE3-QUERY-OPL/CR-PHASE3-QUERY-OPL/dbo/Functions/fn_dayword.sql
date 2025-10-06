CREATE FUNCTION [dbo].[fn_dayword] 
	(
		@p_day as VARCHAR(20)
	) 
RETURNS nvarchar (20) AS 
BEGIN
	declare @hasil	nvarchar(20)
	
	if @p_day		= 'SUNDAY'
		set @hasil	= 'Minggu'
	else if @p_day	= 'MONDAY'
		set @hasil	= 'Senin'
	else if @p_day	= 'TUESDAY'
		set @hasil	= 'Selasa'
	else if @p_day	= 'WEDNESDAY'
		set @hasil	= 'Rabu'
	else if @p_day	= 'THURSDAY'
		set @hasil	= 'Kamis'
	else if @p_day	= 'FRIDAY'
		set @hasil	= 'Jumat'
	else if @p_day	= 'SATURDAY'
		set @hasil	= 'Sabtu'
		
return (@hasil)
END

