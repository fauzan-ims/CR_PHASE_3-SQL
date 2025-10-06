CREATE procedure [dbo].[xsp_insurance_policy_main_lookup]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_is_existing nvarchar(1) = ''
)
as
begin
	declare @rows_count int = 0 ;

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
	from	insurance_policy_main		   ipm
			left join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
			outer apply
				(
					select	stuff((
									  select	distinct
												',' + avh.plat_no + ' ' + avh.engine_no + ' ' + avh.chassis_no
									  from		dbo.insurance_policy_asset	 ipa
												inner join dbo.asset_vehicle avh on ipa.fa_code = avh.asset_code
									  where		ipa.policy_code = ipm.code
									  for xml path('')
								  ), 1, 1, ''
								 ) 'asset'
				)									   asset
	where	ipm.branch_code							  = case @p_branch_code
															when 'ALL' then ipm.branch_code
															else @p_branch_code
														end
			and ipm.policy_status					  = 'ACTIVE'
			and isnull(ipm.policy_process_status, '') = ''
			and ipm.is_policy_existing				  = case @p_is_existing
															when '' then ipm.is_policy_existing
															else @p_is_existing
														end
			and
			(
				ipm.policy_no			like '%' + @p_keywords + '%'
				or	mi.insurance_name	like '%' + @p_keywords + '%'
				or	asset.asset			like '%' + @p_keywords + '%'
			) ;

	select		ipm.code
				,ipm.policy_no
				,insurance_name
				,ipm.insurance_type
				,convert(varchar(30), ipm.policy_exp_date, 103) 'policy_exp_date'
				,convert(varchar(30), ipm.policy_eff_date, 103) 'policy_eff_date'
				,asset.asset
				,@rows_count									'rowcount'
	from		insurance_policy_main		   ipm
				left join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
				outer apply
				(
					select	stuff((
									  select	distinct
												',' + avh.plat_no + ' ' + avh.engine_no + ' ' + avh.chassis_no
									  from		dbo.insurance_policy_asset	 ipa
												inner join dbo.asset_vehicle avh on ipa.fa_code = avh.asset_code
									  where		ipa.policy_code = ipm.code
									  for xml path('')
								  ), 1, 1, ''
								 ) 'asset'
				)									   asset
	where		ipm.branch_code							  = case @p_branch_code
																when 'ALL' then ipm.branch_code
																else @p_branch_code
															end
				and ipm.policy_status					  = 'ACTIVE'
				and isnull(ipm.policy_process_status, '') = ''
				and ipm.is_policy_existing				  = case @p_is_existing
																when '' then ipm.is_policy_existing
																else @p_is_existing
															end
				and
				(
					ipm.policy_no			like '%' + @p_keywords + '%'
					or	ipm.insured_name	like '%' + @p_keywords + '%'
					or	asset.asset			like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ipm.policy_no
													 when 2 then mi.insurance_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ipm.policy_no
													   when 2 then mi.insurance_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
