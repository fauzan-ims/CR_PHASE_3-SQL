
CREATE PROCEDURE dbo.xsp_dashboard_chart_pending_document
as
begin

	declare @msg			 nvarchar(max);
	
	select count(branch_code) 'total_data',
	       branch_name 'reff_name'
	from dbo.document_pending
	where document_status = 'HOLD'
	group by branch_code,branch_name
		
end ;
