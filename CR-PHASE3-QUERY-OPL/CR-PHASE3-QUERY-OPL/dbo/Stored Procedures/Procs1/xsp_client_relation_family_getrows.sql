CREATE PROCEDURE dbo.xsp_client_relation_family_getrows
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
			left join dbo.sys_general_subcode sgc on (cr.family_type_code = sgc.code)
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
					sgc.description						like '%' + @p_keywords + '%' 
					or	cr.full_name					like '%' + @p_keywords + '%'
						or	case cr.is_emergency_contact
								 when '1' then 'Yes'
								 else 'No'
							 end						like '%' + @p_keywords + '%'
				) ;

	select		cr.id
				,cr.reference_type_code						
				,cr.full_name				
				,sgc.description 'family_type_desc' 
				,case cr.is_emergency_contact
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_emergency_contact'
				,@rows_count 'rowcount'
	from		client_relation cr 
				left join dbo.sys_general_subcode sgc on (cr.family_type_code = sgc.code)
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
						sgc.description					like '%' + @p_keywords + '%' 
						or	cr.full_name				like '%' + @p_keywords + '%'
						or	case cr.is_emergency_contact
								 when '1' then 'Yes'
								 else 'No'
							 end						like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then sgc.description				
														when 2 then cr.full_name							 		 
														when 3 then cr.is_emergency_contact				 		 
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then sgc.description				
														when 2 then cr.full_name							 		 
														when 3 then cr.is_emergency_contact								 
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

