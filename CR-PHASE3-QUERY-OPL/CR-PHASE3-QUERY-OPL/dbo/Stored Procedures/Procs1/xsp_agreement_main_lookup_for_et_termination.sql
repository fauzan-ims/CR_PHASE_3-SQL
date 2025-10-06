CREATE PROCEDURE dbo.xsp_agreement_main_lookup_for_et_termination
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_branch_code		nvarchar(50) 
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	agreement_main
	where	agreement_status = 'GO LIVE'
	and		isnull(termination_status,'') = ''
	--and		agreement_sub_status = '' raffi : diganti dikarnakan jika termination status sudah wo atau sudah proses apapun itu, data tidak akan muncul
	and		(agreement_no not in (select agreement_no from dbo.write_off_main where wo_status not in ('REJECT', 'CANCEL'))
			or agreement_no not in (select agreement_no from dbo.due_date_change_main where change_status not in ('REJECT', 'CANCEL')))
	and		branch_code =	case @p_branch_code
								when 'ALL' then branch_code 
								else @p_branch_code
							END	
	and		(
				agreement_no				                    like '%' + @p_keywords + '%'
				or	agreement_external_no	                    like '%' + @p_keywords + '%'
				or	client_name				                    like '%' + @p_keywords + '%'
			) ;

	select	agreement_no
			,agreement_external_no	 
			,client_no                   
			,client_name				                    
			,@rows_count 'rowcount'
	from	agreement_main
	where	agreement_status = 'GO LIVE'
	and		isnull(termination_status,'') = ''
	--and		agreement_sub_status = '' raffi : diganti dikarnakan jika termination status sudah wo atau sudah proses apapun itu, data tidak akan muncul
	and		(agreement_no not in (select agreement_no from dbo.write_off_main where wo_status not in ('REJECT', 'CANCEL'))
			or agreement_no not in (select agreement_no from dbo.due_date_change_main where change_status not in ('REJECT', 'CANCEL')))
	and		branch_code =	case @p_branch_code
								when 'ALL' then branch_code 
								else @p_branch_code
							END	
	and		(
				agreement_no				                    like '%' + @p_keywords + '%'
				or	agreement_external_no	                    like '%' + @p_keywords + '%'
				or	client_name				                    like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by = 'asc' then 
												case @p_order_by
													when 1 then agreement_no	                    
													when 2 then client_name  
												end
												end asc, 
				case
					when @p_sort_by = 'desc' then 
												case @p_order_by
													when 1 then agreement_no	                    
													when 2 then client_name  	
												end
											end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
