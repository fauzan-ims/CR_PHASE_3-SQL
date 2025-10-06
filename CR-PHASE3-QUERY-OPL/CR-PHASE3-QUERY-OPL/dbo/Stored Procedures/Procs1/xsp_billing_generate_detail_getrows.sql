CREATE PROCEDURE dbo.xsp_billing_generate_detail_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_generate_code	nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	billing_generate_detail bgd
			inner join dbo.agreement_asset ast on (bgd.asset_no = ast.asset_no)
			left join	dbo.agreement_main am on (am.agreement_no = ast.agreement_no)
	where	bgd.generate_code = @p_generate_code
	and		(
				bgd.agreement_no							like 	'%'+@p_keywords+'%'
				or	ast.billing_to_name						like 	'%'+@p_keywords+'%'
				or	bgd.asset_no							like 	'%'+@p_keywords+'%'
				or	ast.fa_reff_no_01						like 	'%'+@p_keywords+'%'
				or	ast.asset_name							like 	'%'+@p_keywords+'%'
				or	bgd.billing_no							like 	'%'+@p_keywords+'%'
				or	convert(varchar(30), bgd.due_date, 103)	like 	'%'+@p_keywords+'%'
				or	bgd.rental_amount						like 	'%'+@p_keywords+'%'
				or	am.agreement_external_no				like 	'%'+@p_keywords+'%'
			);

	select	bgd.id
			,bgd.generate_code
			,bgd.agreement_no
			,ast.billing_to_name
			,bgd.asset_no
			,ast.asset_name + ' - ' + ast.fa_reff_no_01 'asset_name'
			,bgd.billing_no
			,convert(varchar(30), bgd.due_date, 103) 'due_date'
			,bgd.rental_amount
			,bgd.description
			,am.agreement_external_no
			,am.client_name
			,@rows_count	 'rowcount'
	from	billing_generate_detail bgd
			inner join dbo.agreement_asset ast on (bgd.asset_no = ast.asset_no)
			left join	dbo.agreement_main am on (am.agreement_no = ast.agreement_no)
	where	bgd.generate_code = @p_generate_code
	and		(
				bgd.agreement_no							like 	'%'+@p_keywords+'%'
				or	ast.billing_to_name						like 	'%'+@p_keywords+'%'
				or	bgd.asset_no							like 	'%'+@p_keywords+'%'
				or	ast.fa_reff_no_01						like 	'%'+@p_keywords+'%'
				or	ast.asset_name							like 	'%'+@p_keywords+'%'
				or	bgd.billing_no							like 	'%'+@p_keywords+'%'
				or	convert(varchar(30), bgd.due_date, 103)	like 	'%'+@p_keywords+'%'
				or	bgd.rental_amount						like 	'%'+@p_keywords+'%'
				or	am.agreement_external_no				like 	'%'+@p_keywords+'%'
			)
		order by	 case
							when @p_sort_by = 'asc' then case @p_order_by
										when 1	then am.agreement_external_no
										when 2	then bgd.asset_no
										when 3	then bgd.billing_no
										when 4	then cast(bgd.due_date as sql_variant)
										when 5	then cast(bgd.rental_amount as sql_variant)

								end
					end asc
					,case
								when @p_sort_by = 'desc' then case @p_order_by
										when 1	then am.agreement_external_no
										when 2	then bgd.asset_no
										when 3	then bgd.billing_no
										when 4	then cast(bgd.due_date as sql_variant)
										when 5	then cast(bgd.rental_amount as sql_variant)
					end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end
