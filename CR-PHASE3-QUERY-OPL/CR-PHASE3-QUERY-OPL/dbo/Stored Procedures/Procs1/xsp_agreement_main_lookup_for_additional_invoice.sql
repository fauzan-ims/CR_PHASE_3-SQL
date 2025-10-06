CREATE PROCEDURE dbo.xsp_agreement_main_lookup_for_additional_invoice
(
	@p_keywords			NVARCHAR(50)
	,@p_pagenumber		INT
	,@p_rowspage		INT
	,@p_order_by		INT
	,@p_sort_by			NVARCHAR(5)
	--
	,@p_branch_code		NVARCHAR(50) ='ALL'
	,@p_client_no		NVARCHAR(50) = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	agreement_main
	where	agreement_status = 'GO LIVE'
	AND		client_no = @p_client_no
	AND		branch_code =	CASE @p_branch_code
								WHEN 'ALL' THEN branch_code 
								ELSE @p_branch_code
							END	
	and		(
				AGREEMENT_EXTERNAL_NO				                like '%' + @p_keywords + '%'
				or	client_name				                    like '%' + @p_keywords + '%'
			) ;

	select	agreement_no
			,agreement_external_no	 
			,client_no                   
			,client_name				                    
			,@rows_count 'rowcount'
	from	agreement_main
	where	agreement_status = 'GO LIVE'
	and		client_no = @p_client_no
	and		branch_code =	case @p_branch_code
								when 'ALL' then branch_code 
								else @p_branch_code
							END	
	and		(
				AGREEMENT_EXTERNAL_NO				                    like '%' + @p_keywords + '%'
				or	client_name				                    like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by = 'asc' then 
												case @p_order_by
													when 1 then agreement_external_no	                    
													when 2 then client_name  
												end
												end asc, 
				case
					when @p_sort_by = 'desc' then 
												case @p_order_by
													when 1 then agreement_external_no	                    
													when 2 then client_name  	
												end
											end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
