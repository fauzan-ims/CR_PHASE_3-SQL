
create procedure xsp_suspend_merger_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,merger_status
			,merger_date
			,merger_amount
			,merger_remarks
			,merger_currency_code
	from	suspend_merger
	where	code = @p_code ;
end ;
