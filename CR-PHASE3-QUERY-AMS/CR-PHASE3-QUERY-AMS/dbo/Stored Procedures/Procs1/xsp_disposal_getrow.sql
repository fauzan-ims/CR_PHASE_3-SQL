CREATE PROCEDURE dbo.xsp_disposal_getrow
(
	@p_code nvarchar(50)
)
as
begin

	declare @table_name					nvarchar(250)
			,@sp_name					nvarchar(250) 
			,@rpt_code					nvarchar(50)
			,@report_name				nvarchar(250) 
			,@total_net_book_value		decimal(18,2);

	select	@table_name		= table_name
			,@sp_name		= sp_name
			,@rpt_code		= code
			,@report_name	= name
	from	dbo.sys_report
	where	table_name = 'RPT_CETAKAN_BAST' ;
	
	select	@total_net_book_value = isnull(sum(net_book_value),0)
	from	dbo.disposal_detail 
	where	disposal_code = @p_code

	select	ds.code
			,ds.company_code
			,disposal_date
			,ds.branch_code
			,ds.branch_name
			,ds.description
			,reason_type
			,sgs.description 'general_subcode_desc'
			,remarks
			,status
			,@table_name	'table_name'
			,@sp_name		'sp_name'
			,@rpt_code		'rpt_code'
			,@report_name	'report_name'
			,@total_net_book_value 'total_net_book_value'
	from	disposal ds
			left join dbo.sys_general_subcode sgs on (sgs.code = ds.reason_type)
	where	ds.code = @p_code ;
end ;
