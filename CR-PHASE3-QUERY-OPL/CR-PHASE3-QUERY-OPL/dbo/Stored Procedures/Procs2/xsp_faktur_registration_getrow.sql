
create procedure xsp_faktur_registration_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,status
			,remark
			,year
			,faktur_prefix
			,faktur_running_no
			,faktur_postfix
			,count
	from	faktur_registration
	where	code = @p_code ;
end ;
