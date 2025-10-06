CREATE PROCEDURE dbo.xsp_client_corporate_shareholder_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_client_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_corporate_shareholder ccs
			left join dbo.client_main cm on (cm.code			= ccs.shareholder_client_code)
			left join dbo.sys_general_subcode sgs on (sgs.code = ccs.officer_position_type_code)
	where	client_code = @p_client_code
			and (
					ccs.shareholder_client_type like '%' + @p_keywords + '%'
					or	cm.client_name			like '%' + @p_keywords + '%'
					or	ccs.shareholder_pct		like '%' + @p_keywords + '%'
					or	sgs.description			like '%' + @p_keywords + '%'
					or	case is_officer
							when '1' then 'Yes'
							else 'No'
						end						like '%' + @p_keywords + '%'
				) ;
				 
		select		id
					,ccs.shareholder_client_type
					,isnull(cm.client_name, 'PUBLIC') 'client_name'
					,ccs.shareholder_pct	
					,sgs.description 'officer_position_type_desc'
					,case is_officer
						when '1' then 'Yes'
						else 'No'
					 end 'is_officer'
					,@rows_count 'rowcount'
		from		client_corporate_shareholder ccs
					left join dbo.client_main cm on (cm.code			= ccs.shareholder_client_code)
					left join dbo.sys_general_subcode sgs on (sgs.code = ccs.officer_position_type_code)
		where		client_code = @p_client_code
					and (
							ccs.shareholder_client_type like '%' + @p_keywords + '%'
							or	cm.client_name			like '%' + @p_keywords + '%'
							or	ccs.shareholder_pct		like '%' + @p_keywords + '%'
							or	sgs.description			like '%' + @p_keywords + '%'
							or	case is_officer
									when '1' then 'Yes'
									else 'No'
								end						like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cm.client_name		
													when 2 then ccs.shareholder_client_type
													when 3 then is_officer
													when 4 then sgs.description 
													when 5 then cast(ccs.shareholder_pct as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then cm.client_name		
													when 2 then ccs.shareholder_client_type
													when 3 then is_officer
													when 4 then sgs.description 
													when 5 then cast(ccs.shareholder_pct as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

