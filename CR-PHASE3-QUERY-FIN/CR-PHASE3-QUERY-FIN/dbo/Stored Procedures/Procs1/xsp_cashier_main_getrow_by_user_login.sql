create procedure dbo.xsp_cashier_main_getrow_by_user_login
(
	@p_employee_code	nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,cashier_status
			,cashier_open_date
			,cashier_close_date
			,cashier_open_amount
			,cashier_db_amount
			,cashier_cr_amount
			,cashier_close_amount
			,employee_code
			,employee_name
	from	cashier_main
	where	employee_code = @p_employee_code 
end ;
