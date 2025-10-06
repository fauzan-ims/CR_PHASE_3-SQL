CREATE PROCEDURE dbo.xsp_master_collateral_category_getrows
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
	from	master_collateral_category mcc
			INNER JOIN dbo.SYS_GENERAL_SUBCODE sgs ON (sgs.CODE = mcc.COLLATERAL_TYPE_CODE)
	where	(
				mcc.code						like '%' + @p_keywords + '%'
				or	category_name				like '%' + @p_keywords + '%'
				or	sgs.description				like '%' + @p_keywords + '%'
				or	case mcc.is_active
						when '1' then 'Yes'
						else 'No'
					end							like '%' + @p_keywords + '%'
			) ;

		select		mcc.code
					,category_name
					,sgs.description
					,case mcc.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from	master_collateral_category mcc
				INNER JOIN dbo.SYS_GENERAL_SUBCODE sgs ON (sgs.CODE = mcc.COLLATERAL_TYPE_CODE)
		where	(
					mcc.code						like '%' + @p_keywords + '%'
					or	category_name				like '%' + @p_keywords + '%'
					or	sgs.description				like '%' + @p_keywords + '%'
					or	case mcc.is_active
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
				)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then category_name
													when 2 then sgs.description
													when 3 then mcc.is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then category_name
													when 2 then sgs.description
													when 3 then mcc.is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;


