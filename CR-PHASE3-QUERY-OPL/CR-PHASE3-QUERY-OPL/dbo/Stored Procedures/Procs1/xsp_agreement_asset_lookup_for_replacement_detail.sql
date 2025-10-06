
CREATE PROCEDURE [dbo].[xsp_agreement_asset_lookup_for_replacement_detail]
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	--
	,@p_agreement_no	 nvarchar(50)
	,@p_replacement_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	agreement_asset
	where	agreement_no = @p_agreement_no
			and asset_no not in
				(
					select	old_asset_no
					from	dbo.asset_replacement_detail
					where	replacement_code = @p_replacement_code
				)
			and asset_no not in
				(
					select	old_asset_no
					from	dbo.asset_replacement_detail ard inner join dbo.asset_replacement ar on (ar.code = ard.replacement_code)
					where	agreement_no = @p_agreement_no and ar.status not in ('DONE', 'CANCEL')
				)
			and asset_status <> 'IN PROCESS' -- Louis Kamis, 03 Juli 2025 15.38.56 -- 
			and (
					asset_no like '%' + @p_keywords + '%'
					or	asset_name like '%' + @p_keywords + '%'
					or	fa_reff_no_01 like '%' + @p_keywords + '%'
				) ;

	select		asset_no
				,asset_name
				,fa_reff_no_01 'plat_no'
				,@rows_count 'rowcount'
	from		agreement_asset
	where		agreement_no = @p_agreement_no
				and asset_no not in
					(
						select	old_asset_no
						from	dbo.asset_replacement_detail
						where	replacement_code = @p_replacement_code
					)
				and asset_no not in
					(
						select	old_asset_no
						from	dbo.asset_replacement_detail ard inner join dbo.asset_replacement ar on (ar.code = ard.replacement_code)
						where	agreement_no = @p_agreement_no and ar.status not in ('DONE', 'CANCEL')
					)
				and asset_status <> 'IN PROCESS' -- Louis Kamis, 03 Juli 2025 15.38.56 -- 
				and (
						asset_no like '%' + @p_keywords + '%'
						or	asset_name like '%' + @p_keywords + '%'
						or	fa_reff_no_01 like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_no + asset_name
													 when 2 then fa_reff_no_01
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then asset_no + asset_name
													   when 2 then fa_reff_no_01
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
