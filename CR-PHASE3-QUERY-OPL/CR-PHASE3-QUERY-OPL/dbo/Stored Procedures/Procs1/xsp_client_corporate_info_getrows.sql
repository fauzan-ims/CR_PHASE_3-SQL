CREATE PROCEDURE dbo.xsp_client_corporate_info_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_corporate_info cci
			inner join client_main cm on (cm.code			= cci.client_code)
			inner join sys_general_subcode sgs on (sgs.code = cci.corporate_status_code)
	where	(
				cm.client_no						like '%' + @p_keywords + '%'
				or	cm.client_type					like '%' + @p_keywords + '%'
				or	cci.full_name					like '%' + @p_keywords + '%'
				or	sgs.description					like '%' + @p_keywords + '%'
				or	cci.est_date					like '%' + @p_keywords + '%'
				or	case is_validate
							when '1' then 'Yes'
							else 'No'
					end 							like '%' + @p_keywords + '%'
			) ;  
		select		cci.client_code
					,cm.client_no
					,cm.client_type	
					,sgs.description 'corporate_status_desc'	
					,cci.full_name	
					,convert(varchar(30), cci.est_date, 103)'est_date'
					,case is_validate
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_validate'
					,@rows_count 'rowcount'
		from		client_corporate_info cci
					inner join client_main cm on (cm.code			= cci.client_code)
					inner join sys_general_subcode sgs on (sgs.code = cci.corporate_status_code)
		where		(
						cm.client_no								like '%' + @p_keywords + '%'
						or	cm.client_type							like '%' + @p_keywords + '%'
						or	sgs.description							like '%' + @p_keywords + '%'
						or	cci.full_name							like '%' + @p_keywords + '%'
						or	convert(varchar(30), cci.est_date, 103)	like '%' + @p_keywords + '%'
						or	case is_validate
								 when '1' then 'Yes'
								 else 'No'
							end 									like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cm.client_no
													when 2 then cm.client_type							
													when 3 then cci.full_name							
													when 4 then sgs.description							
													when 5 then	cast(cci.est_date as sql_variant)	
													when 6 then	cm.is_validate
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then cm.client_no
													when 2 then cm.client_type							
													when 3 then cci.full_name							
													when 4 then sgs.description							
													when 5 then	cast(cci.est_date as sql_variant)	
													when 6 then	cm.is_validate
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

