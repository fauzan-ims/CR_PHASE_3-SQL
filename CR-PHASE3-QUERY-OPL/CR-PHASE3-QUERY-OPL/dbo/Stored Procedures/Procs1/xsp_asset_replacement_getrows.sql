CREATE PROCEDURE dbo.xsp_asset_replacement_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	--
	,@p_branch_code nvarchar(50)
	,@p_status		nvarchar(10)
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
	from	asset_replacement arm
			inner join dbo.agreement_main am on (am.agreement_no = arm.agreement_no)
			left JOIN dbo.ASSET_REPLACEMENT_DETAIL  ard ON ard.REPLACEMENT_CODE = arm.CODE
			--INNER JOIN dbo.AGREEMENT_ASSET asta ON (am.AGREEMENT_NO = asta.AGREEMENT_NO)
			-- (+) Ari 2023-10-10 ket : change joinan berdasarkan asset 
			outer apply (
							select	distinct
									asta.fa_reff_no_01 'old_asset_plat_no'
									,asta.asset_name
							from	agreement_asset asta
							where	asta.agreement_no = am.agreement_no
							and		asta.asset_no = ard.old_asset_no
						) asta
	where	arm.branch_code = case @p_branch_code
								  when 'ALL' then arm.branch_code
								  else @p_branch_code
							  end
			and arm.status	= case @p_status
								  when 'ALL' then arm.status
								  else @p_status
							  end
			and (
					arm.code									like 	'%'+@p_keywords+'%'
					or	arm.agreement_no						like 	'%'+@p_keywords+'%'
					or	am.agreement_external_no				like 	'%'+@p_keywords+'%'
					or	am.client_name							like 	'%'+@p_keywords+'%'
					or	arm.date								like 	'%'+@p_keywords+'%'
					or	arm.branch_code							like 	'%'+@p_keywords+'%'
					or	arm.branch_name							like 	'%'+@p_keywords+'%'
					or	arm.remark								like 	'%'+@p_keywords+'%'
					or	arm.status								like 	'%'+@p_keywords+'%'
					or	convert(varchar(30), arm.date,103)		like 	'%'+@p_keywords+'%'
					--or asta.fa_reff_no_01 						LIKE 	'%'+@p_keywords+'%'
					or asta.old_asset_plat_no					like 	'%'+@p_keywords+'%'
					or ard.new_fa_ref_no_01						like 	'%'+@p_keywords+'%'
					or ard.old_asset_no							like 	'%'+@p_keywords+'%'
					or asta.asset_name							like 	'%'+@p_keywords+'%'
					or ard.new_fa_code							like 	'%'+@p_keywords+'%'
					or ard.new_fa_name							like 	'%'+@p_keywords+'%'
				) ;

	select		arm.code
				,arm.agreement_no
				,am.agreement_external_no
				,am.client_name
				,arm.branch_code
				,arm.branch_name
				,arm.remark
				,arm.status
				,convert(varchar(30), arm.date,103) 'date'
				--,asta.fa_reff_no_01 'old_asset_plat_no'
				-- (+) Ari 2023-10-10 ket : change
				,asta.old_asset_plat_no 
				,ard.new_fa_ref_no_01 'new_asset_plat_no'
				,ard.old_asset_no
				,asta.asset_name
				,ard.new_fa_code
				,ard.new_fa_name
				,@rows_count 'rowcount'
	from		asset_replacement arm
				inner join dbo.agreement_main am on (am.agreement_no = arm.agreement_no)
				left JOIN dbo.ASSET_REPLACEMENT_DETAIL  ard ON ard.REPLACEMENT_CODE = arm.CODE
				--inner join dbo.agreement_asset asta on (am.agreement_no = asta.agreement_no)
				-- (+) Ari 2023-10-10 ket : change joinan berdasarkan asset 
				outer apply (
								select	distinct
										asta.fa_reff_no_01 'old_asset_plat_no'
										,asta.asset_name
								from	agreement_asset asta
								where	asta.agreement_no = am.agreement_no
								and		asta.asset_no = ard.old_asset_no
							) asta
	where		arm.branch_code = case @p_branch_code
									  when 'ALL' then arm.branch_code
									  else @p_branch_code
								  end
				and arm.status	= case @p_status
									  when 'ALL' then arm.status
									  else @p_status
								  end
				and (
						arm.code									like 	'%'+@p_keywords+'%'
						or	arm.agreement_no						like 	'%'+@p_keywords+'%'
						or	am.agreement_external_no				like 	'%'+@p_keywords+'%'
						or	am.client_name							like 	'%'+@p_keywords+'%'
						or	arm.date								like 	'%'+@p_keywords+'%'
						or	arm.branch_code							like 	'%'+@p_keywords+'%'
						or	arm.branch_name							like 	'%'+@p_keywords+'%'
						or	arm.remark								like 	'%'+@p_keywords+'%'
						or	arm.status								like 	'%'+@p_keywords+'%'
						or	convert(varchar(30), arm.date,103)		like 	'%'+@p_keywords+'%'
						--or asta.fa_reff_no_01 						LIKE 	'%'+@p_keywords+'%'
						or asta.old_asset_plat_no					like 	'%'+@p_keywords+'%'
						or ard.new_fa_ref_no_01						like 	'%'+@p_keywords+'%'
						or ard.old_asset_no							like 	'%'+@p_keywords+'%'
						or asta.asset_name							like 	'%'+@p_keywords+'%'
						or ard.new_fa_code							like 	'%'+@p_keywords+'%'
						or ard.new_fa_name							like 	'%'+@p_keywords+'%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then arm.code
													 when 2 then arm.branch_name
													 when 3 then cast(date as sql_variant)
													 when 4 then am.agreement_external_no + am.client_name
													 when 5 then asta.old_asset_plat_no + asta.asset_name + ard.old_asset_no
													 when 6 then ard.new_fa_ref_no_01 + ard.new_fa_name + ard.new_fa_code
													 when 7 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then arm.code
														when 2 then arm.branch_name
														when 3 then cast(date as sql_variant)
														when 4 then am.agreement_external_no + am.client_name
														when 5 then asta.old_asset_plat_no + asta.asset_name + ard.old_asset_no
														when 6 then ard.new_fa_ref_no_01 + ard.new_fa_name + ard.new_fa_code
														when 7 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
