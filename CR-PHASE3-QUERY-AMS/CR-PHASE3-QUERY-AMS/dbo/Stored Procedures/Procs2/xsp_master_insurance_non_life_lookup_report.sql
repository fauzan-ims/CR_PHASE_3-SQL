CREATE PROCEDURE dbo.xsp_master_insurance_non_life_lookup_report
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_for_all		nvarchar(1)	= ''
)
as
begin
	declare @rows_count int = 0 ;

	if (@p_for_all <> '')
	begin
		select	@rows_count = count(1)
		from
				(
					select 	'ALL' as 'code'
							,'ALL' as 'insurance_name'
					union all
					select  code
							,insurance_name
					from	dbo.master_insurance
					where	is_validate	= '1'
					and		insurance_type = 'NON LIFE'
				) as mi
		where	(
					mi.code like '%' + @p_keywords + '%'
					or	mi.insurance_name like '%' + @p_keywords + '%'
				) ;
			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'insurance_name'
									,@rows_count 'rowcount'
							union all
							select  code
									,insurance_name
									,@rows_count 'rowcount'
							from	dbo.master_insurance
							where	is_validate	= '1'
							and		insurance_type = 'NON LIFE'
						) as mi
			where		(
							mi.code like '%' + @p_keywords + '%'
							or	mi.insurance_name like '%' + @p_keywords + '%'
						)
			order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mi.code
													when 2 then mi.insurance_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mi.code
													when 2 then mi.insurance_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
			
	end ;
	else
	begin
	select	@rows_count = count(1)
		from
				(
					select 	'ALL' as 'code'
							,'ALL' as 'insurance_name'
					union all
					select  code
							,insurance_name
					from	dbo.master_insurance
					where	is_validate	= '1'
					and		insurance_type = 'NON LIFE'
				) as mi
		where	(
					mi.code like '%' + @p_keywords + '%'
					or	mi.insurance_name like '%' + @p_keywords + '%'
				) ;
			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'insurance_name'
									,@rows_count 'rowcount'
							union all
							select  code
									,insurance_name
									,@rows_count 'rowcount'
							from	dbo.master_insurance
							where	is_validate	= '1'
							and		insurance_type = 'NON LIFE'
						) as mi
			where		(
							mi.code like '%' + @p_keywords + '%'
							or	mi.insurance_name like '%' + @p_keywords + '%'
						)
			order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mi.code
													when 2 then mi.insurance_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mi.code
													when 2 then mi.insurance_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only 
		
	end ;
end ;

