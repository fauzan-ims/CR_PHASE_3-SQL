create PROCEDURE [dbo].[xsp_sys_global_param_getrow_for_thirdparty]
(
	@p_type nvarchar(50)
)
as
begin
	declare @all_code nvarchar(4000)
			,@query	  nvarchar(max) ;

	if (@p_type = 'VENDOR')
	begin
		set @all_code = N'''URLVDR''' ;
	end ;
	else if (@p_type = 'VENDOR BANK')
	begin
		set @all_code = N'''URLVBK'',' ;
	end ;


	set @query = N'select code ,value from	dbo.sys_global_param where	code IN (' + @all_code + N')' ;

	execute sp_executesql @query ; 
end ;
