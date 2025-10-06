--created by, Rian at 16/05/2023 

CREATE PROCEDURE dbo.xsp_sys_area_blacklist_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,status
			,source
			,zip_code
			,sub_district
			,village
			,entry_date
			,entry_reason
			,exit_date
			,exit_reason
	from	sys_area_blacklist
	where	code = @p_code ;
end ;
