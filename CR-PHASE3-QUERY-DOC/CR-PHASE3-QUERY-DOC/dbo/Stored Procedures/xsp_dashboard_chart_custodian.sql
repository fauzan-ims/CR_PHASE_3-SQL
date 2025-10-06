
CREATE PROCEDURE dbo.xsp_dashboard_chart_custodian
as
begin

	declare @msg	nvarchar(max);
	
	select		count(dm.branch_code) 'total_data',
				dm.branch_name 'reff_name'
	from		dbo.document_main dm
	where	dm.document_status = 'ON HAND' 
			and dm.branch_code	   <> dm.custody_branch_code
			and dm.code not in
				(
					select isnull(dmv.document_code,'') from dbo.document_movement_detail dmv
					inner join dbo.document_movement dm on dm.code = dmv.movement_code
					where dm.movement_status in ('HOLD', 'ON PROCESS')
				)
	group by	branch_name;

end ;
