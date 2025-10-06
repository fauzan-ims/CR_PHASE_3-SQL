CREATE PROCEDURE dbo.xsp_agreement_main_lookup_for_billing_scheme_detail
(
	@p_scheme_code			nvarchar(50)
	,@p_client_no			nvarchar(50)	= ''
	--
	,@p_keywords			nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)	
)
as
begin
	declare @tempTable table
	(
		agreement_no		   nvarchar(50)
		,client_name		   nvarchar(250)
		,asset_no			   nvarchar(50)
		,asset_name			   nvarchar(250)
		,agreement_external_no nvarchar(50)
		,due_date			   varchar(30)
	) ;

	insert into @temptable
	(
		agreement_no
		,client_name
		,asset_no
		,asset_name
		,agreement_external_no
		,due_date
	)
	select	am.agreement_no
			,am.client_name
			,ast.asset_no
			,ast.asset_name 
			,am.agreement_external_no
			,convert(varchar(30), aasset.due_date, 103) 'due_date'
	from	dbo.agreement_main am with (nolock)
			inner join dbo.agreement_asset ast with (nolock) on (ast.agreement_no = am.agreement_no)
			outer apply
			(
				select	min(aaa.due_date) due_date
				from	dbo.agreement_asset_amortization aaa with (nolock)
				where	aaa.agreement_no = ast.agreement_no
						and aaa.asset_no = ast.asset_no
						and aaa.due_date >= dbo.xfn_get_system_date()
						and isnull(aaa.invoice_no,'')=''
			) aasset
	where	ast.asset_no not in (
									select	asset_no 
									from	dbo.billing_scheme_detail with (nolock)
									where	scheme_code = @p_scheme_code
								)
	and		ast.asset_no not in(
									select	asset_no 
									from	dbo.billing_scheme_detail bsd with (nolock)
									inner join dbo.billing_scheme bs with (nolock) on (bs.code = bsd.scheme_code)
									where bs.is_active = '1'
								)
	and		am.client_no = case @p_client_no
								when '' then am.client_no
								else @p_client_no
							end
	and		am.agreement_status = 'GO LIVE'
	and		(
				am.agreement_no									like '%' + @p_keywords + '%'
				or	am.client_name								like '%' + @p_keywords + '%'
				or	ast.asset_no								like '%' + @p_keywords + '%'
				or	ast.asset_name								like '%' + @p_keywords + '%'
				or	am.agreement_external_no					like '%' + @p_keywords + '%'
				or  convert(varchar(30), aasset.due_date, 103)	like '%' + @p_keywords + '%'
			)

	declare @rows_count int = 0 ;
	
	select	@rows_count = count(1)
	from	@tempTable ;


	select		agreement_no
				,client_name
				,asset_no
				,asset_name
				,agreement_external_no
				,convert(varchar(30), due_date, 103) 'due_date'
				,@rows_count 'rowcount'
	from		@tempTable
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then agreement_external_no
													 when 2 then asset_no
													 when 3 then due_date
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then agreement_external_no
													   when 2 then asset_no
													   when 3 then due_date
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end ;

