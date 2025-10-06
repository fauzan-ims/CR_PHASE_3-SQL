CREATE PROCEDURE dbo.xsp_warning_letter_delivery_getrow
(
	@p_code nvarchar(50)
)
as
begin
	declare @table_name		  nvarchar(250)
			,@sp_name		  nvarchar(250)
			,@report_code	  nvarchar(50)
			,@table_name_sp1  nvarchar(250)
			,@sp_name_sp1	  nvarchar(250)
			,@report_code_sp1 nvarchar(50)
			,@report_name_sp1 nvarchar(250)
			,@table_name_sp2  nvarchar(250)
			,@sp_name_sp2	  nvarchar(250)
			,@report_code_sp2 nvarchar(50)
			,@report_name_sp2 nvarchar(250)
			,@table_name_sp3  nvarchar(250)
			,@sp_name_sp3	  nvarchar(250)
			,@report_code_sp3 nvarchar(50)
			,@report_name_sp3 nvarchar(250)
			,@table_name_sp  nvarchar(250)
			,@sp_name_sp	  nvarchar(250)
			,@report_code_sp nvarchar(50)
			,@report_name_sp nvarchar(250);

	--select	@report_code_sp		= code
	--		,@table_name_sp		= table_name
	--		,@sp_name_sp		= sp_name
	--		,@report_name_sp	= name
	--from	dbo.sys_report
	--where	table_name			= 'rpt_surat_peringatan' ;

	--select	@report_code_sp1	= code
	--		,@table_name_sp1	= table_name
	--		,@sp_name_sp1		= sp_name
	--		,@report_name_sp1	= name
	--from	dbo.sys_report
	--where	table_name			= 'rpt_surat_peringatan_i' ;

	--select	@report_code_sp2	= code
	--		,@table_name_sp2	= table_name
	--		,@sp_name_sp2		= sp_name
	--		,@report_name_sp2	= name
	--from	dbo.sys_report
	--where	table_name			= 'rpt_surat_peringatan_ii' ;

	--select	@report_code_sp3	= code
	--		,@table_name_sp3	= table_name
	--		,@sp_name_sp3		= sp_name
	--		,@report_name_sp3	= name
	--from	dbo.sys_report
	--where	table_name			= 'rpt_surat_somasi' ;

	select	wld.code
			,wld.branch_code
			,wld.branch_name
			,wld.client_no
			,delivery_status
			,wld.delivery_date
			,delivery_courier_type
			,delivery_courier_code
			,delivery_collector_code
			,delivery_collector_name
			,delivery_remarks
			,wld.delivery_address
			,wld.delivery_to_name
			,wld.client_phone_no
			,wld.client_npwp
			,wld.client_email
			,wld.client_name
			,wld.letter_date
			,wld.letter_type
			,wld.generate_type
			,wld.overdue_days
			,wld.total_agreement		'total_agreement_count'
			,wld.total_overdue_amount
			,wld.total_asset			'total_asset_count'
			,wld.total_monthly_rental_amount
			,warning_letter.last_print_by
			,warning_letter.print_count
			,sgs.description 'courier'
			--,@table_name 'table_name'
			--,@sp_name 'sp_name'
			--,@report_code 'report_code'
			--,@table_name_sp 'table_name_sp'
			--,@sp_name_sp 'sp_name_sp'
			--,@report_code_sp 'report_code_sp'
			--,@report_name_sp 'report_name_sp'
			--,@table_name_sp1 'table_name_sp1'
			--,@sp_name_sp1 'sp_name_sp1'
			--,@report_code_sp1 'report_code_sp1'
			--,@report_name_sp1 'report_name_sp1'
			--,@table_name_sp2 'table_name_sp2'
			--,@sp_name_sp2 'sp_name_sp2'
			--,@report_code_sp2 'report_code_sp2'
			--,@report_name_sp2 'report_name_sp2'
			--,@table_name_sp3 'table_name_sp3'
			--,@sp_name_sp3 'sp_name_sp3'
			--,@report_code_sp3 'report_code_sp3'
			--,@report_name_sp3 'report_name_sp3'
			--,@table_name_sp 'table_name_sp'
			--,@sp_name_sp 'sp_name_sp'
			--,@report_code_sp 'report_code_sp'
			--,@report_name_sp 'report_name_sp'
			,mc.collector_name
			,wld.result
			,wld.received_date
			,wld.received_by
			,wld.resi_no
			,wld.reject_date
			,wld.reason_code
			,wld.reason_desc
			,wld.result_remark
			,wld.file_name
			,wld.path
			,letter_no
			,wld.up_print_sp
	from	dbo.warning_letter_delivery wld
			left join dbo.warning_letter on warning_letter.delivery_code = wld.code
			left join dbo.sys_general_subcode sgs on (sgs.code = wld.delivery_courier_code)
			left join dbo.master_collector mc on (mc.code	   = wld.delivery_collector_code)
	where	wld.code = @p_code;

end ;
