CREATE PROCEDURE dbo.xsp_dashboard_pie_status
as
begin

	declare @msg			 nvarchar(max);
	
	select count(1) 'total_data'
	    ,document_status 'reff_name'
	from dbo.document_main
	where document_status <> 'RELEASE'
	group by document_status
		
end ;
