CREATE PROCEDURE dbo.xsp_master_insurance_lookup_report
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_for_all				nvarchar(1)	= ''
	,@p_insurance_type		nvarchar(10) = ''
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
							,'ALL' as 'insurance_type'
					union all
					select  code
							,insurance_name
							,insurance_type
					from	dbo.master_insurance
					where	is_validate	= '1'
					and insurance_type = case @p_insurance_type
											 when 'ALL' then insurance_type
											 else @p_insurance_type
										 end
				) as mi
		where	(
					mi.code like '%' + @p_keywords + '%'
					or	mi.insurance_name like '%' + @p_keywords + '%'
					or	mi.insurance_type like '%' + @p_keywords + '%'
				) ;

			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'insurance_name'
									,'ALL' as 'insurance_type'
									,@rows_count 'rowcount'
							union all
							select  code
									,insurance_name
									,insurance_type
									,@rows_count 'rowcount'
							from	dbo.master_insurance
							where	is_validate	= '1'
							and insurance_type = case @p_insurance_type
													 when 'ALL' then insurance_type
													 else @p_insurance_type
												 end
						) as mi
			where		(
							mi.code like '%' + @p_keywords + '%'
							or	mi.insurance_name like '%' + @p_keywords + '%'
							or	mi.insurance_type like '%' + @p_keywords + '%'
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
			from	dbo.master_insurance
			where	(
						code							like '%' + @p_keywords + '%'
						or	insurance_name				like '%' + @p_keywords + '%'
						or	insurance_type				like '%' + @p_keywords + '%'
					) ;

				select		code
							,insurance_name
							,insurance_type
							,@rows_count 'rowcount'
				from		dbo.master_insurance
				where		is_validate = '1'
				and			insurance_type = case @p_insurance_type
												  when 'ALL' then insurance_type
												  else @p_insurance_type
											 end
				and			(
								code					like '%' + @p_keywords + '%'
								or	insurance_name		like '%' + @p_keywords + '%'
								or	insurance_type		like '%' + @p_keywords + '%'
							)
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then insurance_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then code
													when 2 then insurance_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
		
end ;
end

