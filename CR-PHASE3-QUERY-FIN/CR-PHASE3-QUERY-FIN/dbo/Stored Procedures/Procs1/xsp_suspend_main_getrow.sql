CREATE PROCEDURE dbo.xsp_suspend_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
		   ,branch_code
		   ,branch_name
		   ,suspend_currency_code
		   ,suspend_date
		   ,suspend_amount
		   ,suspend_remarks
		   ,used_amount
		   ,remaining_amount
		   ,reff_name
		   ,reff_no
		   ,transaction_code
		   ,transaction_name
	from	suspend_main
	where	code = @p_code ;
end ;
