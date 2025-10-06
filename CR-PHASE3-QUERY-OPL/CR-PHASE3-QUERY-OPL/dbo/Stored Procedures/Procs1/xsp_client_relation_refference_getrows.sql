CREATE PROCEDURE dbo.xsp_client_relation_refference_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_client_code	  nvarchar(50)
	,@p_relation_type nvarchar(15) = ''
	,@p_is_latest	  nvarchar(1)  = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_relation cr 
	where	cr.client_code		 = @p_client_code
			and cr.relation_type = case @p_relation_type
										when '' then cr.relation_type
										else @p_relation_type
									end
			and cr.is_latest	 = case @p_is_latest
										when '' then cr.is_latest
										else @p_is_latest
									end
			and (
					cr.reference_type_code	like '%' + @p_keywords + '%' 
					or	cr.full_name		like '%' + @p_keywords + '%'
				) ;

	select		cr.id
				,cr.reference_type_code						
				,cr.full_name				 
				,@rows_count 'rowcount'
	from		client_relation cr 
	where		cr.client_code		 = @p_client_code
				and cr.relation_type = case @p_relation_type
											when '' then cr.relation_type
											else @p_relation_type
										end
				and cr.is_latest	 = case @p_is_latest
											when '' then cr.is_latest
											else @p_is_latest
										end
				and ( 
						cr.reference_type_code	like '%' + @p_keywords + '%' 
						or	cr.full_name		like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then cr.reference_type_code						
														when 2 then cr.full_name				 		 
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cr.reference_type_code					
														when 2 then cr.full_name							 
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

