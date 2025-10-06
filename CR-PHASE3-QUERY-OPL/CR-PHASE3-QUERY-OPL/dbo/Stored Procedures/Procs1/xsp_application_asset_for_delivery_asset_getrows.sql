CREATE PROCEDURE dbo.xsp_application_asset_for_delivery_asset_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_delivery_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_asset aa
			inner join dbo.asset_delivery_detail adde on (adde.asset_no = aa.asset_no)
			inner join dbo.application_main am on (am.application_no = aa.application_no)
			inner join dbo.client_main cm on (cm.code = am.client_code)
	where	adde.delivery_code = @p_delivery_code
			and (
					am.agreement_external_no like '%' + @p_keywords + '%'
					or	cm.client_name		 like '%' + @p_keywords + '%'
					or	aa.asset_no			 like '%' + @p_keywords + '%'
					or	aa.asset_name		 like '%' + @p_keywords + '%'
					or	aa.asset_year		 like '%' + @p_keywords + '%'
					or	aa.asset_condition	 like '%' + @p_keywords + '%'
					or	aa.fa_code			 like '%' + @p_keywords + '%'
					or	aa.fa_name			 like '%' + @p_keywords + '%'
				) ;

	select		aa.asset_no
				,aa.asset_name
				,aa.asset_year
				,aa.asset_condition
				,aa.lease_rounded_amount
				,aa.net_margin_amount
				,aa.purchase_status
				,aa.unit_code
				,aa.fa_code
				,aa.fa_name
				,adde.id
				,am.agreement_external_no
				,cm.client_name
				,@rows_count 'rowcount'
	from		application_asset aa
				inner join dbo.asset_delivery_detail adde on (adde.asset_no = aa.asset_no)
				inner join dbo.application_main am on (am.application_no = aa.application_no)
				inner join dbo.client_main cm on (cm.code = am.client_code)
	where		adde.delivery_code = @p_delivery_code
				and (
						am.agreement_external_no like '%' + @p_keywords + '%'
						or	cm.client_name		 like '%' + @p_keywords + '%'
						or	aa.asset_no			 like '%' + @p_keywords + '%'
						or	aa.asset_name		 like '%' + @p_keywords + '%'
						or	aa.asset_year		 like '%' + @p_keywords + '%'
						or	aa.asset_condition	 like '%' + @p_keywords + '%'
						or	aa.fa_code			 like '%' + @p_keywords + '%'
						or	aa.fa_name			 like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.agreement_external_no + cm.client_name
													 when 2 then aa.asset_no + aa.asset_name
													 when 3 then aa.asset_year
													 when 4 then aa.asset_condition
													 when 5 then aa.fa_code + aa.fa_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then am.agreement_external_no + cm.client_name
													   when 2 then aa.asset_no + aa.asset_name
													   when 3 then aa.asset_year
													   when 4 then aa.asset_condition
													   when 5 then aa.fa_code + aa.fa_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

