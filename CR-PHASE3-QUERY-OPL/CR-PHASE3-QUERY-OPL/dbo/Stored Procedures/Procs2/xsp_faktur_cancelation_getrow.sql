
create procedure xsp_faktur_cancelation_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,date
			,year
			,status
			,remark
	from	faktur_cancelation
	where	code = @p_code ;
end ;
