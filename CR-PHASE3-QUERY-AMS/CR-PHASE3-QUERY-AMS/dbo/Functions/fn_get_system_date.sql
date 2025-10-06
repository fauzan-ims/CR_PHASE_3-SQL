
CREATE function dbo.fn_get_system_date ()
returns datetime
as
begin

	---- ======================================
	---- author	: chandra aripin
	---- created	: 10-dec-2015, 9:47:55 am
	---- for		: for getting system datetime
	---- ======================================

	--return	(select convert(datetime,cast(cast(system_date as date) as nvarchar(19)) + ' ' + left(cast(cast(getdate() as time) as nvarchar(19)),12),120) from sys_it_param)

	-- Hari - 22.Jun.2023 10:18 AM --	CHANGE MEKANISME GET DAT KE GLOBAL PARAM
	declare @date_string datetime ;

	select	@date_string = cast(value as datetime)
	from	[dbo].[sys_global_param]
	where	code = 'SYSDATE' ;                     

	return @date_string ;
end ;
