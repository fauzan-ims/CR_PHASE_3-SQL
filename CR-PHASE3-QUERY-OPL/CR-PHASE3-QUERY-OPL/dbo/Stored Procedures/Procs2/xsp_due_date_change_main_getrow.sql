CREATE PROCEDURE dbo.xsp_due_date_change_main_getrow
(
	@p_code nvarchar(50)
)
as
BEGIN

	declare @table_name		nvarchar(250)
			,@sp_name		nvarchar(250) 
			,@rpt_code		nvarchar(50)
			,@report_name	nvarchar(250)

	select	@table_name		= table_name
			,@sp_name		= sp_name
			,@rpt_code		= code
			,@report_name	= name
	from	dbo.sys_report
	where	table_name		= 'RPT_LEMBAR_PERSETUJUAN_OR_SIMULASI_ADJUSTMENT_DUEDATE' ;

	select	dcm.code
			,dcm.branch_code
			,dcm.branch_name
			,dcm.change_status
			,dcm.change_date
			,dcm.change_exp_date
			,dcm.change_amount
			,dcm.change_remarks
			,dcm.agreement_no
			,dcm.received_request_code
			,dcm.received_voucher_no
			,dcm.received_voucher_date
			,dcm.billing_type
			,dcm.billing_mode
			,dcm.is_prorate
			,amn.agreement_external_no
			,amn.client_name
			,@table_name	'table_name'
			,@sp_name		'sp_name'
			,@rpt_code		'rpt_code'
			,@report_name	'report_name'
			,billing_mode_date
	from	due_date_change_main dcm
			left join dbo.agreement_main amn on (amn.agreement_no = dcm.agreement_no)
	where	dcm.code = @p_code ;
end ;
