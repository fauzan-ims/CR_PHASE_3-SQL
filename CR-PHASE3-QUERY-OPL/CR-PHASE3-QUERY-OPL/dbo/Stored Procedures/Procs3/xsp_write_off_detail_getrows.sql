CREATE procedure dbo.xsp_write_off_detail_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_write_off_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0
			,@wo_status nvarchar(15) ;

	select	@wo_status = wo_status
	from	dbo.write_off_main
	where	code = @p_write_off_code ;

	declare @tempTable table
	(
		id				  bigint
		,asset_name		  nvarchar(250)
		,fa_reff_no_01	  nvarchar(250)
		,fa_reff_no_02	  nvarchar(250)
		,fa_reff_no_03	  nvarchar(250)
		,is_take_assets   nvarchar(1)
		,os_rental_amount decimal(18, 2)
	) ;

	insert into @temptable
	(
		id
		,asset_name
		,fa_reff_no_01
		,fa_reff_no_02
		,fa_reff_no_03
		,is_take_assets
		,os_rental_amount
	)
	select	wod.id
			,aa.asset_name
			,aa.fa_reff_no_01
			,aa.fa_reff_no_02
			,aa.fa_reff_no_03
			,is_take_assets
			,dbo.xfn_agreement_get_ol_ar_asset(aa.agreement_no, aa.asset_no) 'os_rental_amount'
	from	write_off_detail wod
			inner join dbo.agreement_asset aa on (aa.asset_no = wod.asset_no)
	where	wod.write_off_code = @p_write_off_code
			and
			(
				aa.asset_name														like '%' + @p_keywords + '%'
				or	aa.fa_reff_no_01												like '%' + @p_keywords + '%'
				or	aa.fa_reff_no_02												like '%' + @p_keywords + '%'
				or	aa.fa_reff_no_03												like '%' + @p_keywords + '%'
				or	dbo.xfn_agreement_get_ol_ar_asset(aa.agreement_no, aa.asset_no) like '%' + @p_keywords + '%'
			) ;

	select	@rows_count = count(1)
	from	@tempTable ;

	select		id
				,asset_name
				,fa_reff_no_01
				,fa_reff_no_02
				,fa_reff_no_03
				,is_take_assets
				,os_rental_amount
				,@wo_status 'wo_status'
				,@rows_count 'rowcount'
	from		@tempTable
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_name
													 when 2 then fa_reff_no_01
													 when 3 then fa_reff_no_02
													 when 4 then fa_reff_no_03
													 when 5 then cast(os_rental_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then asset_name
													   when 2 then fa_reff_no_01
													   when 3 then fa_reff_no_02
													   when 4 then fa_reff_no_03
													   when 5 then cast(os_rental_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
