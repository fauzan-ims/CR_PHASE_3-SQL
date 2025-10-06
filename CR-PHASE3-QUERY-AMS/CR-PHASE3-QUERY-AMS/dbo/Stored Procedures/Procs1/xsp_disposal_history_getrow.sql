CREATE PROCEDURE dbo.xsp_disposal_history_getrow
(
	@p_code nvarchar(50)
)
as
begin

	declare @table_name			nvarchar(250)
			,@sp_name			nvarchar(250) 
			,@rpt_code			nvarchar(50)
			,@report_name		nvarchar(250);

	select	@table_name		= table_name
			,@sp_name		= sp_name
			,@rpt_code		= code
			,@report_name	= name
	from	dbo.sys_report
	where	table_name = 'RPT_CETAKAN_BAST' ;

	select	ds.code
			,ds.company_code
			,disposal_date
			,ds.branch_code
			,ds.branch_name
			,location_code
			,ds.description
			,reason_type
			,sgs.description 'general_subcode_desc'
			,remarks
			,status
			,@table_name	'table_name'
			,@sp_name		'sp_name'
			,@rpt_code		'rpt_code'
			,@report_name	'report_name'
	from	dbo.disposal_history ds
			left join dbo.sys_general_subcode sgs on (sgs.code = ds.reason_type)
	where	ds.code = @p_code ;
end ;
