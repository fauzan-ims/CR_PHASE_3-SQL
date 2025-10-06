CREATE PROCEDURE [dbo].[xsp_warning_letter_delivery_backup_getrow]
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
			,@report_name_sp3 nvarchar(250) ;

	select	@report_code_sp1	= code
			,@table_name_sp1	= table_name
			,@sp_name_sp1		= sp_name
			,@report_name_sp1	= name
	from	dbo.sys_report
	where	table_name			= 'RPT_SURAT_PERINGATAN_I' ;

	select	@report_code_sp2	= code
			,@table_name_sp2	= table_name
			,@sp_name_sp2		= sp_name
			,@report_name_sp2	= name
	from	dbo.sys_report
	where	table_name			= 'RPT_SURAT_PERINGATAN_II' ;

	select	@report_code_sp3	= code
			,@table_name_sp3	= table_name
			,@sp_name_sp3		= sp_name
			,@report_name_sp3	= name
	from	dbo.sys_report
	where	table_name			= 'RPT_SURAT_SOMASI' ;

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
			,wld.last_print_by
			,wld.print_count
			,sgs.description 'courier'
			,@table_name 'table_name'
			,@sp_name 'sp_name'
			,@report_code 'report_code'
			,@table_name_sp1 'table_name_sp1'
			,@sp_name_sp1 'sp_name_sp1'
			,@report_code_sp1 'report_code_sp1'
			,@report_name_sp1 'report_name_sp1'
			,@table_name_sp2 'table_name_sp2'
			,@sp_name_sp2 'sp_name_sp2'
			,@report_code_sp2 'report_code_sp2'
			,@report_name_sp2 'report_name_sp2'
			,@table_name_sp3 'table_name_sp3'
			,@sp_name_sp3 'sp_name_sp3'
			,@report_code_sp3 'report_code_sp3'
			,@report_name_sp3 'report_name_sp3'
			,mc.collector_name
	from	dbo.WARNING_LETTER_DELIVERY_BACKUP wld
			left join dbo.sys_general_subcode sgs on (sgs.code = wld.delivery_courier_code)
			left join dbo.master_collector mc on (mc.code	   = wld.delivery_collector_code)
	where	wld.code = @p_code;

end ;
