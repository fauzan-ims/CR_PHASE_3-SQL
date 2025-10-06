CREATE PROCEDURE dbo.xsp_client_personal_info_matching_getrows
(
	@p_keywords				    nvarchar(50)
	,@p_pagenumber			    int
	,@p_rowspage			    int
	,@p_order_by			    int
	,@p_sort_by				    nvarchar(5)
	----
	,@p_full_name				nvarchar(250)
	,@p_alias_name				nvarchar(250)
	,@p_mother_maiden_name		nvarchar(250)
	,@p_date_of_birth			datetime	
	,@p_place_of_birth			nvarchar(250)	
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_personal_info cpi
			inner join client_main cm on (cm.code = cpi.client_code)
	where	full_name = @p_full_name 
			and alias_name = @p_alias_name 
			and mother_maiden_name = @p_mother_maiden_name 
			and date_of_birth = @p_date_of_birth 
			and place_of_birth = @p_place_of_birth 
			and (
				cpi.client_code										like '%' + @p_keywords + '%'
				or	cm.client_type									like '%' + @p_keywords + '%'
				or	cpi.full_name									like '%' + @p_keywords + '%'
				or	cpi.mother_maiden_name							like '%' + @p_keywords + '%'
				or	cpi.place_of_birth								like '%' + @p_keywords + '%'
				or	convert(varchar(30), cpi.date_of_birth, 103)	like '%' + @p_keywords + '%'
			) ;

		select		cpi.client_code
					,cm.client_type			
					,cpi.full_name			
					,cpi.mother_maiden_name	
					,cpi.place_of_birth		
					,convert(varchar(30), cpi.date_of_birth, 103) 'date_of_birth'		
					,@rows_count 'rowcount'
		from		client_personal_info cpi
					inner join client_main cm on (cm.code = cpi.client_code)
		where		full_name = @p_full_name 
					and alias_name = @p_alias_name 
					and mother_maiden_name = @p_mother_maiden_name 
					and date_of_birth = @p_date_of_birth 
					and place_of_birth = @p_place_of_birth 
					and (
						cpi.client_code										like '%' + @p_keywords + '%'
						or	cm.client_type									like '%' + @p_keywords + '%'
						or	cpi.full_name									like '%' + @p_keywords + '%'
						or	cpi.mother_maiden_name							like '%' + @p_keywords + '%'
						or	cpi.place_of_birth								like '%' + @p_keywords + '%'
						or	convert(varchar(30), cpi.date_of_birth, 103)	like '%' + @p_keywords + '%'
					)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cpi.client_code
													when 2 then cm.client_type			
													when 3 then cpi.full_name			
													when 4 then cpi.mother_maiden_name	
													when 5 then cpi.place_of_birth		
													when 6 then cast(cpi.date_of_birth as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cpi.client_code
														when 2 then cm.client_type			
														when 3 then cpi.full_name			
														when 4 then cpi.mother_maiden_name	
														when 5 then cpi.place_of_birth		
														when 6 then cast(cpi.date_of_birth as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

