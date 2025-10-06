CREATE PROCEDURE dbo.xsp_replacement_detail_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_replacement_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	replacement_detail rpd 
			left join dbo.fixed_asset_main fam on (fam.asset_no = rpd.asset_no)
	where	rpd.replacement_code	= case @p_replacement_code
										  when 'ALL' then rpd.replacement_code
										  else @p_replacement_code
									  end
			and (
					rpd.asset_no		like '%' + @p_keywords + '%'
					or	fam.asset_name	like '%' + @p_keywords + '%'
					or	fam.reff_no_1	like '%' + @p_keywords + '%'
					or	fam.reff_no_2	like '%' + @p_keywords + '%'
					or	fam.reff_no_3	like '%' + @p_keywords + '%'
					or	rpd.type		like '%' + @p_keywords + '%' 
				) ;


		select		rpd.id
					,rpd.replacement_code
					,rpd.replacement_request_detail_id
					,rpd.asset_no
					,fam.asset_name
					,fam.reff_no_1
					,fam.reff_no_2
					,fam.reff_no_3
					,rpd.type
					,@rows_count 'rowcount'
		from		replacement_detail rpd 
					left join dbo.fixed_asset_main fam on (fam.asset_no = rpd.asset_no)
		where		rpd.replacement_code	= case @p_replacement_code
												  when 'ALL' then rpd.replacement_code
												  else @p_replacement_code
											  end
					and (
							rpd.asset_no		like '%' + @p_keywords + '%'
							or	fam.asset_name	like '%' + @p_keywords + '%'
							or	fam.reff_no_1	like '%' + @p_keywords + '%'
							or	fam.reff_no_2	like '%' + @p_keywords + '%'
							or	fam.reff_no_3	like '%' + @p_keywords + '%'
							or	rpd.type		like '%' + @p_keywords + '%' 
						)
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then rpd.asset_no
													when 2 then fam.reff_no_1
													when 3 then rpd.type
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then rpd.asset_no
														when 2 then fam.reff_no_1
														when 3 then rpd.type
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
