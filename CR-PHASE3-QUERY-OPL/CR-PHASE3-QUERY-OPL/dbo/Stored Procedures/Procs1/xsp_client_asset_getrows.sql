CREATE PROCEDURE dbo.xsp_client_asset_getrows
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_client_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_asset ca
			inner join dbo.sys_general_subcode sgs on (sgs.code = ca.asset_type_code)
	where	client_code = @p_client_code
			and (
					sgs.description		like '%' + @p_keywords + '%'
					or	ca.asset_name	like '%' + @p_keywords + '%'
					or	ca.asset_value	like '%' + @p_keywords + '%'
				) ;

		select		ca.id
					,sgs.description 'asset_type_desc'
					,ca.asset_name
					,ca.asset_value
					,@rows_count 'rowcount'
		from		client_asset ca
					inner join dbo.sys_general_subcode sgs on (sgs.code = ca.asset_type_code)
		where		client_code = @p_client_code
					and (
							sgs.description		like '%' + @p_keywords + '%'
							or	ca.asset_name	like '%' + @p_keywords + '%'
							or	ca.asset_value	like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then sgs.description 
													when 2 then ca.asset_name
													when 3 then try_cast(ca.asset_value as nvarchar(20))
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then sgs.description 
														when 2 then ca.asset_name
														when 3 then try_cast(ca.asset_value as nvarchar(20))
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

