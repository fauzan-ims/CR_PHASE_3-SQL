CREATE PROCEDURE dbo.xsp_sys_global_param_getrow_for_thirdparty
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
	else if (@p_type = 'VENDORBANK')
	begin
		set @all_code = N'''URLVBK''' ;
	end ;
	else if (@p_type = 'OTHER')
	begin
		set @all_code = N'''ENFOU10''' ;
	end


	set @query = N'select code ,value from	dbo.sys_global_param where	code IN (' + @all_code + N')' ;

	execute sp_executesql @query ; 
end ;
