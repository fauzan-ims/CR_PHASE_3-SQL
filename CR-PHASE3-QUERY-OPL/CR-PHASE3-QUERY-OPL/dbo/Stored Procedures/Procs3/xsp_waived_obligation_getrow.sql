CREATE PROCEDURE [dbo].[xsp_waived_obligation_getrow]
(
	@p_code nvarchar(50)
)
as
begin

	declare @table_name		nvarchar(250)
			,@sp_name		nvarchar(250) 
			,@rpt_code		nvarchar(50)
			,@report_name	nvarchar(250);

	select	 @table_name	= table_name
			,@sp_name		= sp_name
			,@rpt_code		= code
			,@report_name	= name
	from	dbo.sys_report
	where	table_name = 'RPT_WAIVE_REQUEST' ;

	select	wo.code
			,wo.branch_code
			,wo.branch_name
			,wo.agreement_no
			,wo.waived_status
			,wo.waived_date
			,wo.waived_amount
			,wo.waived_remarks
			,wo.obligation_amount
			,am.agreement_external_no
			,am.client_name
			,@table_name	'table_name'
			,@sp_name		'sp_name'
			,@rpt_code		'rpt_code'
			,@report_name	'report_name'
	from	waived_obligation wo
			inner join dbo.agreement_main am on (am.agreement_no = wo.agreement_no)
	where	wo.code = @p_code ;
end ;

