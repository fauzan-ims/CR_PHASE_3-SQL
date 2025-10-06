
CREATE PROCEDURE [dbo].[xsp_agreement_asset_lookup_for_generate_invoice]
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	--
	,@p_agreement_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select		@rows_count = count(1)
	from		agreement_asset aa with (nolock)
				inner join dbo.agreement_asset_amortization aaa with (nolock) on (aaa.asset_no = aa.asset_no)
				inner join dbo.agreement_main am with (nolock) on (am.agreement_no			   = aa.agreement_no)
	where		aa.agreement_no							= @p_agreement_no
				and aaa.invoice_no is null
				--and asset_status = 'RENTED'
				-- Louis Selasa, 15 Oktober 2024 15.02.49 -- 
				and isnull(am.is_stop_billing, '0')		<> '1'
				and isnull(aaa.hold_billing_status, '') <> 'PENDING'
				and aaa.asset_no not in
					(
						select	bsd.asset_no
						from	dbo.billing_scheme_detail bsd
								inner join dbo.billing_scheme bs on (bs.code = bsd.scheme_code)
						where	bs.is_active = '1'
					)
				and aaa.asset_no not in
					(
						select	et.asset_no
						from	dbo.et_detail et with (nolock)
								inner join dbo.et_main em with (nolock) on (
																			   em.code			= et.et_code
																			   and em.et_status in ('APPROVE', 'ON PROCESS')
																		   )
						where	et.is_terminate = '1'
					)
				and asset_status <> 'IN PROCESS' -- Louis Kamis, 03 Juli 2025 15.38.56 -- 
				and
				(
					aa.asset_no like '%' + @p_keywords + '%'
					or	asset_name like '%' + @p_keywords + '%'
				)
	group by	aa.asset_no
				,aa.asset_name ;

	select		aa.asset_no
				,asset_name
				,@rows_count 'rowcount'
	from		agreement_asset aa with (nolock)
				inner join dbo.agreement_asset_amortization aaa with (nolock) on (aaa.asset_no = aa.asset_no)
				inner join dbo.agreement_main am with (nolock) on (am.agreement_no			   = aa.agreement_no)
	where		aa.agreement_no							= @p_agreement_no
				and aaa.invoice_no is null
				--and asset_status = 'RENTED'
				-- Louis Selasa, 15 Oktober 2024 15.02.49 -- 
				and isnull(am.is_stop_billing, '0')		<> '1'
				and isnull(aaa.hold_billing_status, '') <> 'PENDING'
				and aaa.asset_no not in
					(
						select	bsd.asset_no
						from	dbo.billing_scheme_detail bsd
								inner join dbo.billing_scheme bs on (bs.code = bsd.scheme_code)
						where	bs.is_active = '1'
					)
				and aaa.asset_no not in
					(
						select	et.asset_no
						from	dbo.et_detail et with (nolock)
								inner join dbo.et_main em with (nolock) on (
																			   em.code			= et.et_code
																			   and em.et_status in ('APPROVE', 'ON PROCESS')
																		   )
						where	et.is_terminate = '1'
					)
				and asset_status <> 'IN PROCESS' -- Louis Kamis, 03 Juli 2025 15.38.56 -- 
				and
				(
					aa.asset_no like '%' + @p_keywords + '%'
					or	asset_name like '%' + @p_keywords + '%'
				)
	group by	aa.asset_no
				,aa.asset_name
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then aa.asset_no
													 when 2 then asset_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then aa.asset_no
													   when 2 then asset_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
