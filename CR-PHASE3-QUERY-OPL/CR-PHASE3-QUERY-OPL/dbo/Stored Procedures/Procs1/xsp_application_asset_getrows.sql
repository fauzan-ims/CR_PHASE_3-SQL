CREATE PROCEDURE [dbo].[xsp_application_asset_getrows]
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_asset aa
			inner join dbo.sys_general_subcode sgs on (sgs.code = aa.asset_type_code)
			left join dbo.realization rz with (nolock) on (rz.agreement_no				  = aa.agreement_no)
	where	aa.application_no = @p_application_no
			and (
					aa.asset_no					like '%' + @p_keywords + '%'
					or	aa.asset_name			like '%' + @p_keywords + '%'
					or	sgs.description			like '%' + @p_keywords + '%'
					or	aa.asset_year			like '%' + @p_keywords + '%'
					or	aa.asset_condition		like '%' + @p_keywords + '%' 
					or	aa.lease_rounded_amount	like '%' + @p_keywords + '%'
					or	aa.net_margin_amount	like '%' + @p_keywords + '%'
					OR	aa.asset_status	        LIKE '%' + @p_keywords + '%'
				) ;

	SELECT		aa.asset_no
				,aa.asset_name
				,sgs.description 'asset_type'
				,aa.asset_year
				,aa.asset_condition
				,aa.lease_rounded_amount
				,aa.net_margin_amount
				,aa.asset_status
				,isnull(('AGREEMENT ' + rz.agreement_external_no),'')'agreement_external_no'
				,cast(aa.is_cancel as int) 'is_cancel'
				,@rows_count 'rowcount'
	FROM		application_asset aa
				INNER JOIN dbo.sys_general_subcode sgs ON (sgs.code = aa.asset_type_code)
				LEFT JOIN dbo.realization rz WITH (NOLOCK) ON (rz.agreement_no				  = aa.agreement_no)
	WHERE		aa.application_no = @p_application_no
				AND (
						aa.asset_no					LIKE '%' + @p_keywords + '%'
						OR	aa.asset_name			LIKE '%' + @p_keywords + '%'
						OR	sgs.description			LIKE '%' + @p_keywords + '%'
						OR	aa.asset_year			LIKE '%' + @p_keywords + '%'
						OR	aa.asset_condition		LIKE '%' + @p_keywords + '%' 
						OR	aa.lease_rounded_amount	LIKE '%' + @p_keywords + '%'
						OR	aa.net_margin_amount	LIKE '%' + @p_keywords + '%'
						OR	aa.asset_status	        LIKE '%' + @p_keywords + '%'
					)
	ORDER BY	CASE
					WHEN @p_sort_by = 'asc' THEN CASE @p_order_by
													 when 1 then asset_no
													 when 2 then asset_name
													 when 3 then sgs.description
													 when 4 then asset_year
													 when 5 then asset_condition
													 when 6 then cast(lease_rounded_amount as sql_variant)
													 when 7 then aa.asset_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then asset_no
													   when 2 then asset_name
													   when 3 then sgs.description
													   when 4 then asset_year
													   when 5 then asset_condition
													   when 6 then cast(lease_rounded_amount as sql_variant)
													   when 7 then aa.asset_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
