
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_agreement_main_lookup_for_wo_recovery]
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_branch_code		 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	agreement_main am
	where	am.branch_code	= case @p_branch_code
							  	when 'ALL' then am.branch_code
							  	else @p_branch_code
							  end
	and		agreement_status in ('TERMINATE')
	and		am.termination_status in ('WO')
	and		(
				am.agreement_external_no	like '%' + @p_keywords + '%'
				or	am.client_name			like '%' + @p_keywords + '%'
			) ;

	select	am.agreement_no
			,am.agreement_external_no
			,am.client_name
			,am.client_no
			,am.facility_code
			,am.facility_name 
			,@rows_count 'rowcount'
	from	agreement_main am
	where	am.branch_code	= case @p_branch_code
							  	when 'ALL' then am.branch_code
							  	else @p_branch_code
							  end
	and		agreement_status in ('TERMINATE')
	and		am.termination_status in ('WO')
	and		(
				am.agreement_external_no	like '%' + @p_keywords + '%'
				or	am.client_name			like '%' + @p_keywords + '%'
			) 

	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then am.agreement_external_no
														when 2 then am.client_name
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then am.agreement_external_no
														when 2 then am.client_name
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
