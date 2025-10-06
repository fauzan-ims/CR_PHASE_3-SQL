--created by, Rian at 21/06/2023	

CREATE PROCEDURE [dbo].[xsp_agreement_main_marketing_lookup]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_branch_code		nvarchar(50) = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from
			(
				select distinct
						am.marketing_code
						,am.marketing_name
				from	dbo.agreement_main am
				where	am.agreement_status = 'GO LIVE'
						and am.branch_code	= case @p_branch_code
													when 'ALL' then am.branch_code
													else @p_branch_code
												end
			) agm
	where	(
				agm.marketing_code		like '%' + @p_keywords + '%'
				or	agm.marketing_name	like '%' + @p_keywords + '%'
			)

	select	agm.marketing_code
			,agm.marketing_name
			,@rows_count 'rowcount'
	from
			(
				select distinct
						am.marketing_code
						,am.marketing_name
				from	dbo.agreement_main am
				where	am.agreement_status = 'GO LIVE'
						and am.branch_code	= case @p_branch_code
													when 'ALL' then am.branch_code
													else @p_branch_code
												end
			) agm
	where	(
				agm.marketing_code		like '%' + @p_keywords + '%'
				or	agm.marketing_name	like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by = 'asc' then 
												case @p_order_by
													when 1 then agm.marketing_code	                    
													when 2 then agm.marketing_name  
												end
												end asc, 
				case
					when @p_sort_by = 'desc' then 
												case @p_order_by
													when 1 then agm.marketing_code	                    
													when 2 then agm.marketing_name  	
												end
											end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
