CREATE PROCEDURE [dbo].[xsp_master_budget_cost_lookup_multiple]
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_asset_no			 nvarchar(50) = ''
	,@p_budget_approval_code nvarchar(50) = ''
)
as
begin
	declare @rows_count int = 0 
			,@class_type_code nvarchar(50)

	if (@p_asset_no <> '')
	begin
		select	@class_type_code = mvu.class_type_code
		from	dbo.application_asset_vehicle aav
				inner join dbo.master_vehicle_unit mvu on (mvu.code = aav.vehicle_unit_code)
		where	asset_no = @p_asset_no ;

		select	@rows_count = count(1)
		from	master_budget_cost mbc
		where	mbc.code not in
				(
					select	aab.cost_code
					from	dbo.application_asset_budget aab
					where	aab.cost_code	 = mbc.code
							and aab.asset_no = @p_asset_no
				)
				and mbc.code not in
					(
					N'MBDC.2208.000001',
					N'MBDC.2211.000001',
					N'MBDC.2211.000003',
					N'MBDC.2301.000001'
					)
				and mbc.class_code = @class_type_code
				and mbc.is_active = '1'
				and (
						mbc.description					like '%' + @p_keywords + '%'
						or	case mbc.is_subject_to_purchase
								when '1' then 'Yes'
								else 'No'
							end							like '%' + @p_keywords + '%'
					) ;

		select		mbc.code
					,mbc.description
					,mbc.cost_type
					,mbc.bill_periode
					,case mbc.is_subject_to_purchase
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_subject_to_purchase'
					,@rows_count as 'rowcount'
		from		master_budget_cost mbc
		where		mbc.code not in
					(
						select	aab.cost_code
						from	dbo.application_asset_budget aab
						where	aab.cost_code	 = mbc.code
								and aab.asset_no = @p_asset_no
					)
					and mbc.class_code = @class_type_code
					and mbc.code not in
						(
						N'MBDC.2208.000001',
						N'MBDC.2211.000001',
						N'MBDC.2211.000003',
						N'MBDC.2301.000001'
						)
					and mbc.is_active = '1'
					and (
							mbc.description					like '%' + @p_keywords + '%'
							or	case mbc.is_subject_to_purchase
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
	else
	begin
		select	@rows_count = count(1)
		from	master_budget_cost mbc
		where	mbc.code not in
				(
					select	aab.cost_code
					from	dbo.application_asset_budget aab
					where	aab.cost_code	 = mbc.code
							and aab.asset_no = @p_asset_no
				)
				and (
						mbc.code						like '%' + @p_keywords + '%'
						or	mbc.description				like '%' + @p_keywords + '%'
						or	mbc.cost_type				like '%' + @p_keywords + '%'
						or	mbc.bill_periode			like '%' + @p_keywords + '%'
						or	case mbc.is_active
								when '1' then 'Yes'
								else 'No'
							end							like '%' + @p_keywords + '%'
					) ;

		select		mbc.code
					,mbc.description
					,mbc.cost_type
					,mbc.bill_periode
					,case mbc.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count as 'rowcount'
		from		master_budget_cost mbc
		where		mbc.code not in
					(
						select	bad.cost_code
						from	dbo.budget_approval_detail bad
						where	bad.cost_code	 = mbc.code
								and bad.budget_approval_code = @p_budget_approval_code
					)
					and (
							mbc.code						like '%' + @p_keywords + '%'
							or	mbc.description				like '%' + @p_keywords + '%'
							or	mbc.cost_type				like '%' + @p_keywords + '%'
							or	mbc.bill_periode			like '%' + @p_keywords + '%'
							or	case mbc.is_active
									when '1' then 'Yes'
									else 'No'
								end							like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then mbc.description
														 when 2 then mbc.code
														 when 3 then mbc.cost_type
														 when 4 then mbc.bill_periode
														 when 5 then mbc.is_active
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then mbc.description
														   when 2 then mbc.code
														   when 3 then mbc.cost_type
														   when 4 then mbc.bill_periode
														   when 5 then mbc.is_active
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end
end ;
