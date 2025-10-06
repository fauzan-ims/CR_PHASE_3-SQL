CREATE PROCEDURE dbo.xsp_billing_scheme_detail_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	--
	,@p_scheme_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	billing_scheme_detail bsd
			inner join dbo.agreement_main am on (am.agreement_no					= bsd.agreement_no)
			inner join dbo.agreement_asset ast on (ast.asset_no						= bsd.asset_no)
			outer apply -- optimize ini tidak diperlukan untuk rowscount
			(
				select	min(aaa.due_date) due_date
				from	dbo.agreement_asset_amortization aaa
				where	aaa.agreement_no = ast.agreement_no
						and aaa.asset_no = ast.asset_no
						and aaa.due_date >= dbo.xfn_get_system_date()
						and isnull(aaa.invoice_no,'')=''
			) aasset
	where	bsd.scheme_code = @p_scheme_code
			and (
					bsd.agreement_no								like 	'%'+@p_keywords+'%'
					or	am.client_name								like 	'%'+@p_keywords+'%'
					or	bsd.asset_no								like 	'%'+@p_keywords+'%'
					or	ast.asset_name								like 	'%'+@p_keywords+'%'
					or	ast.lease_rounded_amount					like 	'%'+@p_keywords+'%'
					or	convert(varchar(30), aasset.due_date, 103)		like 	'%'+@p_keywords+'%'
					or	ast.billing_mode							like 	'%'+@p_keywords+'%'
					or	ast.billing_mode_date						like 	'%'+@p_keywords+'%'
					or	am.agreement_external_no					like 	'%'+@p_keywords+'%'
				) ;

	select		bsd.id
				,bsd.scheme_code
				,bsd.agreement_no
				,am.client_name
				,bsd.asset_no
				,ast.asset_name
				,ast.lease_rounded_amount 'lease_round_amount'
				,convert(varchar(30), aasset.due_date, 103) 'due_date'
				,ast.billing_mode
				,ast.billing_mode_date
				,am.agreement_external_no
				,@rows_count 'rowcount'
	from		billing_scheme_detail bsd
				inner join dbo.agreement_main am on (am.agreement_no					= bsd.agreement_no)
				inner join dbo.agreement_asset ast on (ast.asset_no						= bsd.asset_no)
				outer apply
				(
					select	min(aaa.due_date) due_date
					from	dbo.agreement_asset_amortization aaa
					where	aaa.agreement_no = ast.agreement_no
							and aaa.asset_no = ast.asset_no
							and aaa.due_date >= dbo.xfn_get_system_date()
							and isnull(aaa.invoice_no,'')=''
				) aasset
	where		bsd.scheme_code = @p_scheme_code
				and (
						bsd.agreement_no								like 	'%'+@p_keywords+'%'
						or	am.client_name								like 	'%'+@p_keywords+'%'
						or	bsd.asset_no								like 	'%'+@p_keywords+'%'
						or	ast.asset_name								like 	'%'+@p_keywords+'%'
						or	ast.lease_rounded_amount					like 	'%'+@p_keywords+'%'
						or	convert(varchar(30), aasset.due_date, 103)		like 	'%'+@p_keywords+'%'
						or	ast.billing_mode							like 	'%'+@p_keywords+'%'
						or	ast.billing_mode_date						like 	'%'+@p_keywords+'%'
						or	am.agreement_external_no					like 	'%'+@p_keywords+'%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.agreement_external_no + am.client_name
													 when 2 then bsd.asset_no + ast.asset_name
													 when 3 then cast(ast.lease_rounded_amount as sql_variant)
													 when 4 then cast(aasset.due_date as sql_variant)
													 when 5 then ast.billing_mode
													 when 6 then cast(ast.billing_mode_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then am.agreement_external_no + am.client_name
													   when 2 then bsd.asset_no + ast.asset_name
													   when 3 then cast(ast.lease_rounded_amount as sql_variant)
													   when 4 then cast(aasset.due_date as sql_variant)
													   when 5 then ast.billing_mode
													   when 6 then cast(ast.billing_mode_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
