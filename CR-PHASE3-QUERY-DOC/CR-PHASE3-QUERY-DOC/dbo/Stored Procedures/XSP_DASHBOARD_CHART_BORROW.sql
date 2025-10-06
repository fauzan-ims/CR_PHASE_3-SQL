

CREATE PROCEDURE dbo.XSP_DASHBOARD_CHART_BORROW
as
begin

	declare @msg					nvarchar(max)
			,@custody_branch_code	nvarchar(50);

	--select @custody_branch_code = custody_branch_code
	--from dbo.document_main 
	--where DOCUMENT_STATUS = 'ON BORROW';
		
	select		count(1) 'total_data'
				,mutation_location 'reff_name'
	from		dbo.document_main 
	where		DOCUMENT_STATUS = 'ON BORROW'
				and MUTATION_TYPE = 'BORROW'  
				--and custody_branch_code = @custody_branch_code
	group by	mutation_location;
		
end ;
