
create procedure xsp_faktur_allocation_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,date
			,status
			,remark
			,as_of_date
	from	faktur_allocation
	where	code = @p_code ;
end ;
