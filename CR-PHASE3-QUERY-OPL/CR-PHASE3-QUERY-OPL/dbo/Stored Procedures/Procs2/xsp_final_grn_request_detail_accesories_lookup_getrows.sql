
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_detail_accesories_lookup_getrows]
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
	,@p_type		   nvarchar(1)
)
as
begin
	declare @rows_count int = 0 ;

	if (@p_type = '0')
	begin
		select	@rows_count = count(1)
		from	dbo.final_grn_request_detail_accesories_lookup
		where	application_no = @p_application_no
				and id not in
					(
						select	isnull(final_grn_request_detail_accesories_id, 0)
						from	dbo.final_grn_request_detail_accesories
					)
				and
				(
					po_no like '%' + @p_keywords + '%'
					or	grn_code like '%' + @p_keywords + '%'
					or	item_name like '%' + @p_keywords + '%'
				) ;

		select		id
					,application_no
					,po_no
					,grn_code
					,item_name
					,@rows_count 'rowcount'
		from		dbo.final_grn_request_detail_accesories_lookup
		where		application_no = @p_application_no
					and id not in
						(
							select	isnull(final_grn_request_detail_accesories_id, 0)
							from	dbo.final_grn_request_detail_accesories
						)
					and
					(
						po_no like '%' + @p_keywords + '%'
						or	grn_code like '%' + @p_keywords + '%'
						or	item_name like '%' + @p_keywords + '%'
					)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then po_no
														 when 2 then grn_code
														 when 3 then item_name
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then po_no
														   when 2 then grn_code
														   when 3 then item_name
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select	@rows_count = count(1)
		from	dbo.final_grn_request_detail_accesories_lookup
		where	id not in
				(
					select	isnull(final_grn_request_detail_accesories_id, 0)
					from	dbo.final_grn_request_detail_accesories a
					--		left join dbo.final_grn_request_detail	b on a.final_grn_request_detail_id = b.id
					--where	 isnull(b.grn_code_asset,'') <> ''
				)
				and isnull(application_no, '') = ''
				and
				(
					po_no like '%' + @p_keywords + '%'
					or	grn_code like '%' + @p_keywords + '%'
					or	item_name like '%' + @p_keywords + '%'
				) ;

		select		id
					,application_no
					,po_no
					,grn_code
					,item_name
					,@rows_count 'rowcount'
		from		dbo.final_grn_request_detail_accesories_lookup
		where		id not in
					(
						select	isnull(final_grn_request_detail_accesories_id, 0)
						from	dbo.final_grn_request_detail_accesories a
						--		left join dbo.final_grn_request_detail	b on a.final_grn_request_detail_id = b.id
						--where	isnull(b.grn_code_asset,'') <> ''
					)
					and isnull(application_no, '') = ''
					and
					(
						po_no like '%' + @p_keywords + '%'
						or	grn_code like '%' + @p_keywords + '%'
						or	item_name like '%' + @p_keywords + '%'
					)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then po_no
														 when 2 then grn_code
														 when 3 then item_name
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then po_no
														   when 2 then grn_code
														   when 3 then item_name
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;
