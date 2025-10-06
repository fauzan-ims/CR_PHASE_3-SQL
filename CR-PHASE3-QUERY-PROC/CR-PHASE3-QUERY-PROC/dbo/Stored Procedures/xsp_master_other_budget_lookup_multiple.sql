create PROCEDURE [dbo].[xsp_master_other_budget_lookup_multiple]
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_asset_no			 nvarchar(50) = '' 
)
as
begin
	declare @rows_count int = 0 ;
	 
	select	@rows_count = count(1)
	from	dbo.master_other_budget mbc
	where	mbc.code not in
			(
				select	aab.cost_code
				from	dbo.application_asset_budget aab
				where	aab.cost_code	 = mbc.code
						and aab.asset_no = @p_asset_no
			) and mbc.is_active = '1'
			and (
					mbc.code						like '%' + @p_keywords + '%'
					or	mbc.description				like '%' + @p_keywords + '%' 
					or	case mbc.is_subject_to_purchase
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
					or	case mbc.is_active
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
				) ;

	select		mbc.code
				,mbc.description
				,case mbc.is_subject_to_purchase
								when '1' then 'Yes'
								else 'No'
							end 'is_subject_to_purchase'
				,case mbc.is_active
						when '1' then 'Yes'
						else 'No'
					end 'is_active'
				,@rows_count as 'rowcount'
	from		master_other_budget mbc
	where		mbc.code not in
				(
					select	aab.cost_code
					from	dbo.application_asset_budget aab
					where	aab.cost_code	 = mbc.code
							and aab.asset_no = @p_asset_no
				) and mbc.is_active = '1'
				and (
						mbc.code						like '%' + @p_keywords + '%'
						or	mbc.description				like '%' + @p_keywords + '%'
						or	case mbc.is_subject_to_purchase
								when '1' then 'Yes'
								else 'No'
							end							like '%' + @p_keywords + '%'
						or	case mbc.is_active
								when '1' then 'Yes'
								else 'No'
							end							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then mbc.description 
														when 2 then mbc.is_subject_to_purchase 
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mbc.description
														when 2 then mbc.is_subject_to_purchase 
													end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
