CREATE PROCEDURE dbo.xsp_endorsement_detail_getrows
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
	from	endorsement_detail
	where	(
				id								like '%' + @p_keywords + '%'
				or	endorsement_code			like '%' + @p_keywords + '%'
				or	old_or_new					like '%' + @p_keywords + '%'
				or	occupation_code				like '%' + @p_keywords + '%'
				or	region_code					like '%' + @p_keywords + '%'
				or	collateral_category_code	like '%' + @p_keywords + '%'
				or	object_name					like '%' + @p_keywords + '%'
				or	insured_name				like '%' + @p_keywords + '%'
				or	insured_qq_name				like '%' + @p_keywords + '%'
				or	eff_date					like '%' + @p_keywords + '%'
				or	exp_date					like '%' + @p_keywords + '%'
			) ;

		select		id
					,endorsement_code
					,old_or_new
					,occupation_code
					,region_code
					,collateral_category_code
					,object_name
					,insured_name
					,insured_qq_name
					,eff_date
					,exp_date
					,@rows_count 'rowcount'
		from		endorsement_detail
		where		(
						id								like '%' + @p_keywords + '%'
						or	endorsement_code			like '%' + @p_keywords + '%'
						or	old_or_new					like '%' + @p_keywords + '%'
						or	occupation_code				like '%' + @p_keywords + '%'
						or	region_code					like '%' + @p_keywords + '%'
						or	collateral_category_code	like '%' + @p_keywords + '%'
						or	object_name					like '%' + @p_keywords + '%'
						or	insured_name				like '%' + @p_keywords + '%'
						or	insured_qq_name				like '%' + @p_keywords + '%'
						or	eff_date					like '%' + @p_keywords + '%'
						or	exp_date					like '%' + @p_keywords + '%'
					)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then endorsement_code
													when 2 then old_or_new
													when 3 then occupation_code
													when 4 then region_code
													when 5 then collateral_category_code
													when 6 then object_name
													when 7 then insured_name
													when 8 then insured_qq_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then endorsement_code
													when 2 then old_or_new
													when 3 then occupation_code
													when 4 then region_code
													when 5 then collateral_category_code
													when 6 then object_name
													when 7 then insured_name
													when 8 then insured_qq_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

