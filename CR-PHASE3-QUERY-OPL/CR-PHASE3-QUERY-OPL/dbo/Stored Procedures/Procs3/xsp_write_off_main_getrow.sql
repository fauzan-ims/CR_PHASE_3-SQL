CREATE PROCEDURE dbo.xsp_write_off_main_getrow
(
	@p_code nvarchar(50)
)
as
begin

	declare	@tabel_name	nvarchar(250)
			,@sp_name	nvarchar(250)

		select	@tabel_name = table_name
				,@sp_name	= sp_name
		from	dbo.sys_report
		where	sp_name = 'xsp_rpt_somasi' ;

	select	wom.code
			,wom.branch_code
			,wom.branch_name
			,wom.wo_status
			,wom.wo_date
			,wom.wo_amount
			,wom.wo_remarks
			,wom.agreement_no
			,am.agreement_external_no
			,am.client_name 
			,wom.wo_type
			,isnull(am.agreement_sub_status,'') 'agreement_sub_status'
			,@tabel_name 'table_name'
			,@sp_name 'sp_name'
	from	write_off_main wom
			inner join dbo.agreement_main am on (am.agreement_no = wom.agreement_no)
	where	code = @p_code ;
end ;

