CREATE PROCEDURE dbo.xsp_sys_global_param_getrow_for_general
(
	@p_type nvarchar(50)
)
as
begin
	declare @all_code nvarchar(4000)
			,@query	  nvarchar(max) ;

	if (@p_type = 'DEFAULT')
	begin
		set @all_code = N'''BANK'',''BANKCODE'',''BANKNAME'',''BANKCRY'',''BANKNO'',''BANKGLLINK'',''HO''' ;
	end ;

	set @query = N'select code , value, description from	dbo.sys_global_param where	code IN (' + @all_code + N')' ;

	execute sp_executesql @query ;
end ;
