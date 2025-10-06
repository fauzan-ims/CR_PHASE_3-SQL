CREATE PROCEDURE dbo.xsp_cashier_main_getrow
(
	@p_code nvarchar(50)
)
as
BEGIN
		
	declare @table_name		nvarchar(250)
			,@sp_name		nvarchar(250) 
			,@rpt_code		nvarchar(50)
			,@report_name	nvarchar(250);

	select	@table_name = table_name
			,@sp_name	 = sp_name
			,@rpt_code		= code
			,@report_name	= name
	from	dbo.sys_report
	where	table_name = 'RPT_CASHIER_TRANSACTION_CASH' ;

	select	code
			,branch_code
			,branch_name
			,cashier_status
			,cashier_open_date
			,cashier_close_date
			,cashier_innitial_amount
			,cashier_open_amount
			,cashier_db_amount
			,cashier_cr_amount
			,cashier_close_amount
			,employee_code
			,employee_name
			,case cashier_innitial_amount
					when 0 then '1'
				    else '0'
			end 'is_open'
			,@table_name	'table_name'
			,@sp_name		'sp_name'
			,@rpt_code		'rpt_code'
			,@report_name	'report_name'
	from	cashier_main
	where	code = @p_code ;
end ;
