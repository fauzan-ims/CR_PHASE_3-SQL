-- Louis Jumat, 04 Juli 2025 11.23.56 -- 
CREATE PROCEDURE [dbo].[xsp_agreement_asset_getrows_for_invoice_hold]
(
	@p_keywords	   NVARCHAR(50)
	,@p_pagenumber INT
	,@p_rowspage   INT
	,@p_order_by   INT
	,@p_sort_by	   NVARCHAR(5)
	,@p_branch_code	NVARCHAR(50)
	,@p_client_no	NVARCHAR(50) = ''
	,@p_opl_status	NVARCHAR(20)
)
AS
BEGIN
	DECLARE @rows_count INT = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	dbo.agreement_asset aa
			outer apply
	(
		select		top 1
					aaa.due_date
					,aaa.billing_date
		from		dbo.agreement_asset_amortization aaa
		where		aa.asset_no						  = aaa.asset_no
					and isnull(aaa.generate_code, '') = ''
		order by	aaa.due_date asc
	) aaa
			inner join dbo.agreement_main am on (am.agreement_no			 = aa.agreement_no)
			left join dbo.et_main em on (
											em.agreement_no					 = aa.agreement_no
											and em.et_status not in
	(
		N'APPROVE', N'CANCEL', N'EXPIRED', N'REJECT'
	)
										)
			left join dbo.WRITE_OFF_MAIN wom on (
													wom.AGREEMENT_NO		 = aa.AGREEMENT_NO
													and wom.WO_STATUS not in
	(
		N'APPROVE', N'CANCEL', N'EXPIRED', N'REJECT'
	)
												)
			left join dbo.WAIVED_OBLIGATION wob on (
													   wob.AGREEMENT_NO		 = aa.AGREEMENT_NO
													   and wob.WAIVED_STATUS not in
	(
		N'APPROVE', N'CANCEL', N'EXPIRED', N'REJECT'
	)
												   )
			left join dbo.DUE_DATE_CHANGE_MAIN ddcm on (
														   ddcm.AGREEMENT_NO = aa.AGREEMENT_NO
														   and ddcm.CHANGE_STATUS not in
	(
		N'APPROVE', N'CANCEL', N'EXPIRED', N'REJECT'
	)
													   )
			left join dbo.STOP_BILLING sb on (
												 sb.AGREEMENT_NO			 = aa.AGREEMENT_NO
												 and   sb.STATUS not in
	(
		N'APPROVE', N'CANCEL', N'EXPIRED', N'REJECT'
	)
											 )
	where	isnull(am.opl_status, '') <> ''
			and am.agreement_status	  = 'GO LIVE'
			and aa.asset_status		  = 'RENTED'
			and am.client_no		  = case @p_client_no
											when '' then am.client_no
											else @p_client_no
										end
			and am.branch_code		  = case @p_branch_code
											when 'ALL' then am.branch_code
											else @p_branch_code
										end
			and am.opl_status		  = case @p_opl_status
											when 'ALL' then am.opl_status
											else @p_opl_status
										end
			and
			(
				am.agreement_external_no																											like '%' + @p_keywords + '%'
				or	am.client_name																													like '%' + @p_keywords + '%'
				or	aa.asset_no																														like '%' + @p_keywords + '%'
				or	am.branch_name																													like '%' + @p_keywords + '%'
				or	isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)																			like '%' + @p_keywords + '%'
				or	isnull(aa.fa_reff_no_02, aa.replacement_fa_reff_no_02)																			like '%' + @p_keywords + '%'
				or	isnull(aa.fa_reff_no_03, aa.replacement_fa_reff_no_03)																			like '%' + @p_keywords + '%'
				or	am.opl_status																													like '%' + @p_keywords + '%'
				or	convert(varchar(20), isnull(em.et_date, isnull(wom.wo_date, isnull(ddcm.change_date, isnull(wob.waived_date, sb.date)))), 103)  like '%' + @p_keywords + '%'
				or	convert(varchar(20), aaa.due_date, 103)																							like '%' + @p_keywords + '%'
				or	convert(varchar(20), aaa.billing_date, 103)																						like '%' + @p_keywords + '%'
				or	convert(varchar(20), aaa.billing_date, 103)																						like '%' + @p_keywords + '%'
				or	CASE WHEN am.OPL_STATUS = 'WO' THEN wom.CODE
									WHEN am.OPL_STATUS = 'CHANGE DUE DATE' THEN ddcm.CODE
									WHEN am.OPL_STATUS = 'ET' THEN em.CODE
									WHEN am.OPL_STATUS = 'WAIVE' THEN wob.CODE
									ELSE '-'
								END																													LIKE '%' + @p_keywords + '%'
				or	CASE WHEN am.OPL_STATUS = 'WO' THEN wom.WO_STATUS
									WHEN am.OPL_STATUS = 'CHANGE DUE DATE' THEN ddcm.CHANGE_STATUS
									WHEN am.OPL_STATUS = 'ET' THEN em.ET_STATUS
									WHEN am.OPL_STATUS = 'WAIVE' THEN wob.WAIVED_STATUS
									ELSE '-'
								END																													LIKE '%' + @p_keywords + '%'

			) ;

	select		am.agreement_external_no
				,am.client_name
				,am.branch_name
				,aa.asset_no
				,isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01) 'plat_no'
				,isnull(aa.fa_reff_no_02, aa.replacement_fa_reff_no_02) 'chasiss_no'
				,isnull(aa.fa_reff_no_03, aa.replacement_fa_reff_no_03) 'engine_no'
				,am.opl_status
				,CASE WHEN am.OPL_STATUS = 'WO' THEN wom.CODE
					WHEN am.OPL_STATUS = 'CHANGE DUE DATE' THEN ddcm.CODE
					WHEN am.OPL_STATUS = 'ET' THEN em.CODE
					WHEN am.OPL_STATUS = 'WAIVE' THEN wob.CODE
					ELSE '-'
				END 'transaction_no'
				,convert(varchar(20), isnull(em.et_date, isnull(wom.wo_date, isnull(ddcm.change_date, isnull(wob.waived_date, sb.date)))), 103) 'transaction_date'
				,CASE WHEN am.OPL_STATUS = 'WO' THEN wom.WO_STATUS
					WHEN am.OPL_STATUS = 'CHANGE DUE DATE' THEN ddcm.CHANGE_STATUS
					WHEN am.OPL_STATUS = 'ET' THEN em.ET_STATUS
					WHEN am.OPL_STATUS = 'WAIVE' THEN wob.WAIVED_STATUS
					ELSE '-'
				END 'transaction_status'
				,convert(varchar(20), aaa.due_date, 103) 'due_date'
				,convert(varchar(20), aaa.billing_date, 103) 'billing_date'
				,@rows_count 'rowcount'
	from		dbo.agreement_asset aa
				outer apply
	(
		select		top 1
					aaa.due_date
					,aaa.billing_date
		from		dbo.agreement_asset_amortization aaa
		where		aa.asset_no						  = aaa.asset_no
					and isnull(aaa.generate_code, '') = ''
		order by	aaa.due_date asc
	) aaa
				inner join dbo.agreement_main am on (am.agreement_no			 = aa.agreement_no)
				left join dbo.et_main em on (
												em.agreement_no					 = aa.agreement_no
												and em.et_status not in
	(
		N'APPROVE', N'CANCEL', N'EXPIRED', N'REJECT'
	)
											)
				left join dbo.WRITE_OFF_MAIN wom on (
														wom.AGREEMENT_NO		 = aa.AGREEMENT_NO
														and wom.WO_STATUS not in
	(
		N'APPROVE', N'CANCEL', N'EXPIRED', N'REJECT'
	)
													)
				left join dbo.WAIVED_OBLIGATION wob on (
														   wob.AGREEMENT_NO		 = aa.AGREEMENT_NO
														   and wob.WAIVED_STATUS not in
	(
		N'APPROVE', N'CANCEL', N'EXPIRED', N'REJECT'
	)
													   )
				left join dbo.DUE_DATE_CHANGE_MAIN ddcm on (
															   ddcm.AGREEMENT_NO = aa.AGREEMENT_NO
															   and ddcm.CHANGE_STATUS not in
	(
		N'APPROVE', N'CANCEL', N'EXPIRED', N'REJECT'
	)
														   )
				left join dbo.STOP_BILLING sb on (
													 sb.AGREEMENT_NO			 = aa.AGREEMENT_NO
													 and   sb.STATUS not in
	(
		N'APPROVE', N'CANCEL', N'EXPIRED', N'REJECT'
	)
												 )
	where		isnull(am.opl_status, '') <> ''
				and am.agreement_status	  = 'GO LIVE'
				and aa.asset_status		  = 'RENTED'
				and am.client_no		  = case @p_client_no
												when '' then am.client_no
												else @p_client_no
											end
				and am.branch_code		  = case @p_branch_code
												when 'ALL' then am.branch_code
												else @p_branch_code
											end
				and am.opl_status		  = case @p_opl_status
												when 'ALL' then am.opl_status
												else @p_opl_status
											end
				and
				(
					am.agreement_external_no																											like '%' + @p_keywords + '%'
					or	am.client_name																													like '%' + @p_keywords + '%'
					or	aa.asset_no																														like '%' + @p_keywords + '%'
					or	am.branch_name																													like '%' + @p_keywords + '%'
					or	isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)																			like '%' + @p_keywords + '%'
					or	isnull(aa.fa_reff_no_02, aa.replacement_fa_reff_no_02)																			like '%' + @p_keywords + '%'
					or	isnull(aa.fa_reff_no_03, aa.replacement_fa_reff_no_03)																			like '%' + @p_keywords + '%'
					or	am.opl_status																													like '%' + @p_keywords + '%'
					or	convert(varchar(20), isnull(em.et_date, isnull(wom.wo_date, isnull(ddcm.change_date, isnull(wob.waived_date, sb.date)))), 103)  like '%' + @p_keywords + '%'
					or	convert(varchar(20), aaa.due_date, 103)																							like '%' + @p_keywords + '%'
					or	convert(varchar(20), aaa.billing_date, 103)																						like '%' + @p_keywords + '%'
					or	CASE WHEN am.OPL_STATUS = 'WO' THEN wom.CODE
										WHEN am.OPL_STATUS = 'CHANGE DUE DATE' THEN ddcm.CODE
										WHEN am.OPL_STATUS = 'ET' THEN em.CODE
										WHEN am.OPL_STATUS = 'WAIVE' THEN wob.CODE
										ELSE '-'
									END																													LIKE '%' + @p_keywords + '%'
					or	CASE WHEN am.OPL_STATUS = 'WO' THEN wom.WO_STATUS
										WHEN am.OPL_STATUS = 'CHANGE DUE DATE' THEN ddcm.CHANGE_STATUS
										WHEN am.OPL_STATUS = 'ET' THEN em.ET_STATUS
										WHEN am.OPL_STATUS = 'WAIVE' THEN wob.WAIVED_STATUS
										ELSE '-'
									END																													LIKE '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.agreement_external_no
													 when 2 then aa.asset_no	
													 when 3 then isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)
													 when 4 then am.opl_status
													 when 5 then cast(isnull(em.et_date, isnull(wom.wo_date, isnull(ddcm.change_date, isnull(wob.waived_date, sb.date)))) as sql_variant)
													 when 6 then cast(aaa.due_date as sql_variant)
													 when 7 then cast(aaa.billing_date as sql_variant)

												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														 when 1 then am.agreement_external_no
														 when 2 then aa.asset_no
														 when 3 then isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)
														 when 4 then am.opl_status
														 when 5 then cast(isnull(em.et_date, isnull(wom.wo_date, isnull(ddcm.change_date, isnull(wob.waived_date, sb.date)))) as sql_variant)
														 when 6 then cast(aaa.due_date as sql_variant)
														 when 7 then cast(aaa.billing_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
