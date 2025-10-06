CREATE procedure dbo.xsp_fin_interface_agreement_update_getrow
(
	@p_id bigint
)
as
begin
	declare @table_name nvarchar(250)
			,@sp_name	nvarchar(250) ;

	select	@table_name = table_name
			,@sp_name = sp_name
	from	dbo.sys_report
	where	table_name = 'RPT_INFO_KONTRAK' ;

	select	id
			,au.agreement_no
			,am.agreement_external_no
			,au.agreement_status
			,au.agreement_sub_status
			,au.termination_date
			,au.termination_status
			--,au.last_paid_installment_no
			,au.overdue_period
			--,au.is_remedial
			,au.is_wo
			,au.overdue_days
			,au.job_status
			,au.failed_remarks
			,@table_name 'table_name'
			,@sp_name 'sp_name'
	from	dbo.fin_interface_agreement_update au
			inner join dbo.agreement_main am on (am.agreement_no = au.agreement_no)
	where	id = @p_id ;
end ;
