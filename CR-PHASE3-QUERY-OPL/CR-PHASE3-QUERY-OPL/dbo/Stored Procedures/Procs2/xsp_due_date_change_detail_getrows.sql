--created by, Rian at 04/05/2023 

CREATE PROCEDURE [dbo].[xsp_due_date_change_detail_getrows]
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	--
	,@p_due_date_change_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 
			,@due_date_change_main_status	nvarchar(15)

	select	@due_date_change_main_status = change_status
	from	dbo.due_date_change_main
	where	code = @p_due_date_change_code ;

	select	@rows_count = count(1)
	from	dbo.due_date_change_detail dcd
			inner join dbo.agreement_asset aa on (aa.asset_no = dcd.asset_no)
	where	dcd.due_date_change_code = @p_due_date_change_code
			and (
					dcd.id													like '%' + @p_keywords + '%'
					or	aa.asset_name + ' - ' + isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)			like '%' + @p_keywords + '%'
					or	dcd.asset_no										like '%' + @p_keywords + '%'
					or	dcd.os_rental_amount								like '%' + @p_keywords + '%'
					or	dcd.due_date_change_code							like '%' + @p_keywords + '%'
					or	convert(varchar(30), dcd.old_due_date_day, 103)		like '%' + @p_keywords + '%'
					or	convert(varchar(30), dcd.new_due_date_day, 103)		like '%' + @p_keywords + '%'
					or	convert(varchar(30), dcd.old_billing_date, 103)		like '%' + @p_keywords + '%'
					or	convert(varchar(30), dcd.new_billing_date, 103)		like '%' + @p_keywords + '%'
					or	dcd.at_installment_no								like '%' + @p_keywords + '%'
					or	dcd.is_change										like '%' + @p_keywords + '%'
				) ;

	select		dcd.id
				,dcd.due_date_change_code
				,dcd.asset_no
				,dcd.os_rental_amount 
				,convert(varchar(30), dcd.old_due_date_day, 103) 'old_due_date_day'	
				,convert(varchar(30), dcd.new_due_date_day, 103) 'new_due_date_day'
				,convert(varchar(30), dcd.OLD_BILLING_DATE, 103) 'old_billing_date_day'	
				,convert(varchar(30), dcd.NEW_BILLING_DATE, 103) 'new_billing_date_day'
				,dcd.at_installment_no
				,dcd.is_change
				,dcd.is_change_billing_date
				,dcd.is_every_eom
				,aa.asset_name + ' - ' + isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01) 'asset_name'
				,@due_date_change_main_status 'change_status'
				,@rows_count 'rowcount'
	from		dbo.due_date_change_detail dcd
				inner join dbo.agreement_asset aa on (aa.asset_no = dcd.asset_no)
	where		dcd.due_date_change_code = @p_due_date_change_code
				and (
						dcd.id													like '%' + @p_keywords + '%'
						or	aa.asset_name + ' - ' + isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)			like '%' + @p_keywords + '%'
						or	dcd.asset_no										like '%' + @p_keywords + '%'
						or	dcd.os_rental_amount								like '%' + @p_keywords + '%'
						or	dcd.due_date_change_code							like '%' + @p_keywords + '%'
						or	convert(varchar(30), dcd.old_due_date_day, 103)		like '%' + @p_keywords + '%'
						or	convert(varchar(30), dcd.new_due_date_day, 103)		like '%' + @p_keywords + '%'
						or	convert(varchar(30), dcd.old_billing_date, 103)		like '%' + @p_keywords + '%'
						or	convert(varchar(30), dcd.new_billing_date, 103)		like '%' + @p_keywords + '%'
						or	dcd.at_installment_no								like '%' + @p_keywords + '%'
						or	dcd.is_change										like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then aa.asset_name
													 when 2 then cast(dcd.at_installment_no as sql_variant)
													 when 3 then cast(dcd.old_due_date_day as sql_variant)
													 when 4 then cast(dcd.new_due_date_day as sql_variant)
													 when 5 then cast(dcd.os_rental_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then aa.asset_name
														when 2 then cast(dcd.at_installment_no as sql_variant)
														when 3 then cast(dcd.old_due_date_day as sql_variant)
														when 4 then cast(dcd.new_due_date_day as sql_variant)
														when 5 then cast(dcd.os_rental_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
