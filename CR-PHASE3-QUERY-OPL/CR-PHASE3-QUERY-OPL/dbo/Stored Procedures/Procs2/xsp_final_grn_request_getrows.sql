
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_getrows]
(
	@p_keywords	   NVARCHAR(50)
	,@p_pagenumber INT
	,@p_rowspage   INT
	,@p_order_by   INT
	,@p_sort_by	   NVARCHAR(5)
	,@p_status	   NVARCHAR(50)
)
AS
BEGIN
	DECLARE @rows_count INT = 0 ;

	SELECT	@rows_count = COUNT(1)
	FROM	dbo.final_grn_request pr
	outer apply (	select	 string_agg(pod.po_code,', ') 'purchase_order_code'
							from (	select po_code_asset 'po_code'
									from	dbo.final_grn_request_detail
									where	final_grn_request_no = pr.final_grn_request_no
											and	isnull(po_code_asset,'')<>''
									union
									select	a.po_no 'po_code'
									from	dbo.final_grn_request_detail_accesories_lookup a
									inner join dbo.final_grn_request_detail_accesories b on a.id = b.final_grn_request_detail_accesories_id
									inner join dbo.final_grn_request_detail c on c.id = b.final_grn_request_detail_id
									inner join dbo.final_grn_request d on d.final_grn_request_no = c.final_grn_request_no 
									where c.final_grn_request_no = pr.final_grn_request_no
											and	isnull(a.po_no,'')<>''
									union									
									select	a.po_no 'po_code'
									from	dbo.final_grn_request_detail_karoseri_lookup a
									inner join dbo.final_grn_request_detail_karoseri b on a.id = b.final_grn_request_detail_karoseri_id
									inner join dbo.final_grn_request_detail c on c.id = b.final_grn_request_detail_id
									inner join dbo.final_grn_request d on d.final_grn_request_no = c.final_grn_request_no 
									where	c.final_grn_request_no = pr.final_grn_request_no
											and	isnull(a.po_no,'')<>''
								)pod
						)po
	WHERE	pr.status = CASE @p_status
							WHEN 'ALL' THEN pr.status
							ELSE @p_status
						END
			AND
			(
				pr.application_no												LIKE '%' + @p_keywords + '%'
				OR	CONVERT(VARCHAR(30), pr.application_date, 103)				LIKE '%' + @p_keywords + '%'
				OR	pr.branch_name												LIKE '%' + @p_keywords + '%'
				OR	pr.requestor_name											LIKE '%' + @p_keywords + '%'
				OR	pr.status													LIKE '%' + @p_keywords + '%'
				OR	pr.procurement_request_code									LIKE '%' + @p_keywords + '%'
				OR	CONVERT(VARCHAR(30), pr.procurement_request_date, 103)		LIKE '%' + @p_keywords + '%'
				OR	pr.client_name												LIKE '%' + @p_keywords + '%'
				or	po.purchase_order_code										like '%' + @p_keywords + '%'

			) ;

	SELECT		pr.final_grn_request_no
				,pr.procurement_request_code
				,pr.application_no
				,pr.branch_code
				,pr.branch_name
				,pr.requestor_name
				,CONVERT(VARCHAR(30), pr.application_date, 103) 'application_date'
				,CONVERT(VARCHAR(30), pr.procurement_request_date, 103) 'date'
				,pr.status
				,pr.client_name
				,po.purchase_order_code  'remark'
				,@rows_count									'rowcount'
	FROM		dbo.final_grn_request pr
	outer apply (	select	 string_agg(pod.po_code,', ') 'purchase_order_code'
							from (	select po_code_asset 'po_code'
									from	dbo.final_grn_request_detail
									where	final_grn_request_no = pr.final_grn_request_no
											and	isnull(po_code_asset,'')<>''
									union
									select	a.po_no 'po_code'
									from	dbo.final_grn_request_detail_accesories_lookup a
									inner join dbo.final_grn_request_detail_accesories b on a.id = b.final_grn_request_detail_accesories_id
									inner join dbo.final_grn_request_detail c on c.id = b.final_grn_request_detail_id
									inner join dbo.final_grn_request d on d.final_grn_request_no = c.final_grn_request_no 
									where c.final_grn_request_no = pr.final_grn_request_no
											and	isnull(a.po_no,'')<>''
									union									
									select	a.po_no 'po_code'
									from	dbo.final_grn_request_detail_karoseri_lookup a
									inner join dbo.final_grn_request_detail_karoseri b on a.id = b.final_grn_request_detail_karoseri_id
									inner join dbo.final_grn_request_detail c on c.id = b.final_grn_request_detail_id
									inner join dbo.final_grn_request d on d.final_grn_request_no = c.final_grn_request_no 
									where	c.final_grn_request_no = pr.final_grn_request_no
											and	isnull(a.po_no,'')<>''
								)pod
						)po
	where		pr.status = case @p_status
								when 'ALL' then pr.status
								else @p_status
							end
				and
				(
					pr.application_no												like '%' + @p_keywords + '%'
					or	convert(varchar(30), pr.application_date, 103)				like '%' + @p_keywords + '%'
					or	pr.branch_name												like '%' + @p_keywords + '%'
					or	pr.requestor_name											like '%' + @p_keywords + '%'
					or	pr.status													like '%' + @p_keywords + '%'
					or	pr.procurement_request_code									like '%' + @p_keywords + '%'
					or	convert(varchar(30), pr.procurement_request_date, 103)		like '%' + @p_keywords + '%'
					or	pr.client_name												like '%' + @p_keywords + '%'
					or	po.purchase_order_code										like '%' + @p_keywords + '%'

				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then pr.application_no
													 when 2 then pr.client_name
													 when 3 then pr.branch_name
													 when 4 then pr.requestor_name
													 when 5 then cast(pr.application_date as sql_variant)
													 when 6 then po.purchase_order_code
													 when 7 then pr.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then pr.application_no
													 when 2 then pr.client_name
													 when 3 then pr.branch_name
													 when 4 then pr.requestor_name
													 when 5 then cast(pr.application_date as sql_variant)
													 when 6 then po.purchase_order_code
													 when 7 then pr.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
