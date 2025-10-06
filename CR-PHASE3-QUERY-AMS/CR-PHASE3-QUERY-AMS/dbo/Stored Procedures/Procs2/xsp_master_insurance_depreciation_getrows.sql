CREATE PROCEDURE dbo.xsp_master_insurance_depreciation_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_insurance_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_insurance_depreciation mid
			inner join dbo.master_depreciation md on (md.code = mid.depreciation_code)
			inner join dbo.sys_general_subcode sgs on (sgs.code = mid.collateral_type_code)
	where	insurance_code = @p_insurance_code
			and (
					sgs.description					like '%' + @p_keywords + '%'
					or	md.depreciation_name		like '%' + @p_keywords + '%'
					or	case is_default
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
				) ;

		select		id
					,sgs.description	
					,md.depreciation_name
					,case is_default
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_default'
					,@rows_count 'rowcount'
		from		master_insurance_depreciation mid
					inner join dbo.master_depreciation md on (md.code = mid.depreciation_code)
					inner join dbo.sys_general_subcode sgs on (sgs.code = mid.collateral_type_code)
		where		insurance_code = @p_insurance_code
					and (
							sgs.description				like '%' + @p_keywords + '%'
							or	md.depreciation_name	like '%' + @p_keywords + '%'
							or	case is_default
									when '1' then 'Yes'
									else 'No'
								end						like '%' + @p_keywords + '%'
						)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then sgs.description	
													when 2 then md.depreciation_name
													when 3 then is_default
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then sgs.description	
													when 2 then md.depreciation_name
													when 3 then is_default
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


