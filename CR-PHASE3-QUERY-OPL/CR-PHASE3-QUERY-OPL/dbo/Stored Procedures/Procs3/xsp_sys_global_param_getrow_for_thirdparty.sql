
CREATE PROCEDURE [dbo].[xsp_sys_global_param_getrow_for_thirdparty]
(
	@p_type nvarchar(50)
)
as
begin
	declare @all_code nvarchar(4000)
			,@query	  nvarchar(max) ;

	if (@p_type = 'CLIENT')
	begin
		set @all_code = N'''ENFOU02'',''ENFOU03'',''ENFOU04'',''ENFOU05'',''ENFOU06'',''ENFOU07'',''ENLOS03''' ;
	end ;
	else if (@p_type = 'EXPOSURE')
	begin
		--set @all_code = N'''ENLOS01'',''ENLOS02''' ;
		set @all_code = N'''ENLOS01''' ;
	end ;
	else if (@p_type = 'CLIENT_IFRAME')
	begin
		set @all_code = N'''ENIFR01'',''ENIFR02'',''ENIFR03'',''ENIFR04'',''ENIFR05'',''ENIFR06'',''ENIFR07''' ;
	end
	else if (@p_type = 'OTHER')
	begin
		set @all_code = N'''ENFOU10''' ;
	end

	set @query = N'select code ,value from	dbo.sys_global_param where	code IN (' + @all_code + N')' ;

	execute sp_executesql @query ; 
end ;
