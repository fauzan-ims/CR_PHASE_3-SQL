/*
	Created Arif 23-02-2023
*/
CREATE PROCEDURE [dbo].[xsp_monitoring_insurance_getrows]
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_branch_code	  nvarchar(50)
	,@p_status		  nvarchar(25)
	,@p_budget_status nvarchar(10)
)
as
begin
	declare @rows_count			  int = 0
			,@code				  nvarchar(50)
			,@item_name			  nvarchar(250)
			,@branch_name		  nvarchar(250)
			,@net_book_value_comm decimal(18, 2)
			,@plat_no			  nvarchar(50)
			,@engine_no			  nvarchar(50)
			,@chassis_no		  nvarchar(50)
			,@rental_status		  nvarchar(50)
			,@policy_exp_date	  datetime
			,@budget_status		  nvarchar(10)
			,@status			  nvarchar(50)
			,@fisical_status	  nvarchar(50) ;

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

	declare @tabletemp table
	(
		code				 nvarchar(50)
		,item_name			 nvarchar(250)
		,branch_name		 nvarchar(250)
		,net_book_value_comm decimal(18, 2)
		,plat_no			 nvarchar(50)
		,engine_no			 nvarchar(50)
		,chassis_no			 nvarchar(50)
		,rental_status		 nvarchar(50)
		,policy_exp_date	 nvarchar(30)
		,budget_status		 nvarchar(10)
		,status				 nvarchar(50)
		,fisical_status		 nvarchar(50)
		,policy_no			 nvarchar(250)
		,insurance_company	 nvarchar(250)
	) ;

	if (@p_status = 'ALL')
	begin
		insert into @tabletemp
		(
			code
			,item_name
			,branch_name
			,net_book_value_comm
			,plat_no
			,engine_no
			,chassis_no
			,rental_status
			,policy_exp_date
			,budget_status
			,status
			,fisical_status
			,policy_no
			,insurance_company
		)
		select	distinct
				ass.code
				,ass.item_name
				,ass.branch_name
				,ass.net_book_value_comm
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ass.rental_status
				,convert(varchar(30), policy.policy_exp_date, 103)
				,case
					 when isnull(ain.total_premium_amount, 0) > 0 then 'Yes'
					 else 'No'
				 end
				,ass.status
				,ass.fisical_status
				,policy_no.polis
				,insco.insured_name
		from	dbo.asset					  ass
				inner join dbo.asset_vehicle  av on (ass.code = av.asset_code)
				left join dbo.asset_insurance ain on (ain.asset_code = av.asset_code and ain.agreement_external_no = ass.agreement_external_no)
				outer apply
		(
			select	max(ipm.policy_exp_date) 'policy_exp_date'
			from	dbo.insurance_policy_asset			 ipa
					inner join dbo.insurance_policy_main ipm on ipm.code = ipa.policy_code
			where	ipa.fa_code = av.asset_code
		)									  policy
		outer apply
		(
			select	stuff((
								 select distinct
										', ' + a.policy_no
								 from	dbo.insurance_policy_main		a
								 inner join dbo.insurance_policy_asset b on a.code = b.policy_code
								 where	b.fa_code = ass.code
								 for xml path('')
							 ), 1, 1, ''
							) 'polis'
		) policy_no
		outer apply(
			select top 1 ipm.insured_name 
			from dbo.insurance_policy_main ipm
			inner join dbo.insurance_policy_asset ipa on ipa.policy_code = ipm.code
			where ipa.fa_code = ass.code
		)insco
		where	exists
		(
			select	1
			from	dbo.ASSET
			where	ass.status	   = 'STOCK'
					or	ass.STATUS = 'REPLACEMENT'
		)
				and ass.branch_code = case @p_branch_code
										  when 'ALL' then ass.branch_code
										  else @p_branch_code
									  end
		and
				(
					code												like '%' + @p_keywords + '%'
					or	item_name										like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	net_book_value_comm								like '%' + @p_keywords + '%'
					or	convert(varchar(30), policy_exp_date, 103)		like '%' + @p_keywords + '%'
					or	plat_no											like '%' + @p_keywords + '%'
					or	engine_no										like '%' + @p_keywords + '%'
					or	chassis_no										like '%' + @p_keywords + '%'
					or	rental_status									like '%' + @p_keywords + '%'
					or	case
						when isnull(ain.total_premium_amount, 0) > 0 then 'Yes'
						else 'No'
					end													like '%' + @p_keywords + '%'
					or	status											like '%' + @p_keywords + '%'
					or	fisical_status									like '%' + @p_keywords + '%'
					or	policy_no.polis									like '%' + @p_keywords + '%'
					or	insco.insured_name								like '%' + @p_keywords + '%'
				) ;

		select	@rows_count = count(1)
		from	@tabletemp
		where	budget_status = case @p_budget_status
									when 'ALL' then budget_status
									else @p_budget_status
								end
				and
				(
					code												like '%' + @p_keywords + '%'
					or	item_name										like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	net_book_value_comm								like '%' + @p_keywords + '%'
					or	convert(varchar(30), policy_exp_date, 103)		like '%' + @p_keywords + '%'
					or	plat_no											like '%' + @p_keywords + '%'
					or	engine_no										like '%' + @p_keywords + '%'
					or	chassis_no										like '%' + @p_keywords + '%'
					or	rental_status									like '%' + @p_keywords + '%'
					or	budget_status									like '%' + @p_keywords + '%'
					or	status											like '%' + @p_keywords + '%'
					or	fisical_status									like '%' + @p_keywords + '%'
					or	policy_no										like '%' + @p_keywords + '%'
					or	insurance_company								like '%' + @p_keywords + '%'
				) ;

		select		code
					,item_name
					,branch_name
					,net_book_value_comm
					,convert(varchar(30), policy_exp_date, 103) 'policy_exp_date'
					,plat_no
					,engine_no
					,chassis_no
					,rental_status
					,budget_status
					,status
					,fisical_status
					,insurance_company
					,policy_no
					,@rows_count								'rowcount'
		from		@tabletemp
		where		budget_status = case @p_budget_status
										when 'ALL' then budget_status
										else @p_budget_status
									end
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then code
														 when 2 then plat_no
														 when 3 then branch_name
														 when 4 then cast(policy_exp_date as sql_variant)
														 when 5 then cast(net_book_value_comm as sql_variant)
														 when 6 then status
														 when 7 then budget_status
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then code
														   when 2 then plat_no
														   when 3 then branch_name
														   when 4 then cast(policy_exp_date as sql_variant)
														   when 5 then cast(net_book_value_comm as sql_variant)
														   when 6 then status
														   when 7 then budget_status
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else if (@p_status = 'EXIST')
	begin
		insert into @tabletemp
		(
			code
			,item_name
			,branch_name
			,net_book_value_comm
			,plat_no
			,engine_no
			,chassis_no
			,rental_status
			,policy_exp_date
			,budget_status
			,status
			,fisical_status
			,policy_no
			,insurance_company
		)
		select	distinct
				ass.code
				,ass.item_name
				,ass.branch_name
				,ass.net_book_value_comm
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ass.rental_status
				,convert(varchar(30), policy.policy_exp_date, 103)
				,case
					 when isnull(ain.total_premium_amount, 0) > 0 then 'Yes'
					 else 'No'
				 end
				,ass.status
				,ass.fisical_status
				,policy_no.polis
				,insco.insured_name
		from	dbo.asset					  ass
				inner join dbo.asset_vehicle  av on (ass.code = av.asset_code)
				left join dbo.asset_insurance ain on (ain.asset_code = av.asset_code and ain.agreement_external_no = ass.agreement_external_no)
				outer apply
		(
			select	max(ipm.policy_exp_date) 'policy_exp_date'
			from	dbo.insurance_policy_asset			 ipa
					inner join dbo.insurance_policy_main ipm on ipm.code = ipa.policy_code
			where	ipa.fa_code = av.asset_code
		)									  policy
		outer apply
		(
			select	stuff((
								 select distinct
										', ' + a.policy_no
								 from	dbo.insurance_policy_main		a
								 inner join dbo.insurance_policy_asset b on a.code = b.policy_code
								 where	b.fa_code = ass.code
								 for xml path('')
							 ), 1, 1, ''
							) 'polis'
		) policy_no
		outer apply(
			select top 1 ipm.insured_name 
			from dbo.insurance_policy_main ipm
			inner join dbo.insurance_policy_asset ipa on ipa.policy_code = ipm.code
			where ipa.fa_code = ass.code
		)insco
		where	exists
		(
			select	1
			from	dbo.asset
			where	ass.status	   = 'STOCK'
					or	ass.status = 'REPLACEMENT'
		)
				and ass.code in
					(
						select	ipa.fa_code
						from	dbo.insurance_policy_asset			 ipa
								inner join dbo.insurance_policy_main ipm on ipm.code = ipa.policy_code
						where	ipm.policy_payment_status <> 'CANCEL'
					)
					and ass.code not in
					(
						select	ira.fa_code
						from	dbo.insurance_register					ir
								inner join dbo.insurance_register_asset ira on ira.register_code = ir.code
						where	ir.register_status = 'HOLD'
						union
						select	ira.fa_code
						from	dbo.insurance_register					ir
								inner join dbo.insurance_register_asset ira on ira.register_code = ir.code
								inner join dbo.sppa_request				sr on sr.register_code	 = ir.code
						where	sr.register_status  = 'HOLD'
						union
						select	sd.fa_code
						from	dbo.sppa_main			   sm
								inner join dbo.sppa_detail sd on sm.code = sd.sppa_code
						where	sm.sppa_status = 'HOLD'
					)
				--and ass.code not in
				--	(
				--		select ira.fa_code 
				--		from dbo.insurance_register ir
				--		inner join dbo.insurance_register_asset ira on ira.register_code = ir.code
				--		where ir.register_status <> 'CANCEL'
				--	)
				--and	ass.code not in
				--	(
				--		select ira.fa_code 
				--		from dbo.insurance_register ir
				--		inner join dbo.insurance_register_asset ira on ira.register_code = ir.code
				--		inner join dbo.sppa_request sr on sr.register_code = ir.code
				--	)
				--and ass.code not in
				--	(
				--		select sd.fa_code 
				--		from dbo.sppa_main sm
				--		inner join dbo.sppa_detail sd on sm.code = sd.sppa_code
				--		where sm.sppa_status <> 'CANCEL'
				--	)
				and ass.branch_code = case @p_branch_code
										  when 'ALL' then ass.branch_code
										  else @p_branch_code
									  end 
		and
				(
					code												like '%' + @p_keywords + '%'
					or	item_name										like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	net_book_value_comm								like '%' + @p_keywords + '%'
					or	convert(varchar(30), policy_exp_date, 103)		like '%' + @p_keywords + '%'
					or	plat_no											like '%' + @p_keywords + '%'
					or	engine_no										like '%' + @p_keywords + '%'
					or	chassis_no										like '%' + @p_keywords + '%'
					or	rental_status									like '%' + @p_keywords + '%'
					or	case
						when isnull(ain.total_premium_amount, 0) > 0 then 'Yes'
						else 'No'
					end													like '%' + @p_keywords + '%'
					or	status											like '%' + @p_keywords + '%'
					or	fisical_status									like '%' + @p_keywords + '%'
					or	policy_no.polis									like '%' + @p_keywords + '%'
					or	insco.insured_name								like '%' + @p_keywords + '%'
				) ;

		select	@rows_count = count(1)
		from	@tabletemp
		where	budget_status = case @p_budget_status
									when 'ALL' then budget_status
									else @p_budget_status
								end
				and
				(
					code												like '%' + @p_keywords + '%'
					or	item_name										like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	net_book_value_comm								like '%' + @p_keywords + '%'
					or	convert(varchar(30), policy_exp_date, 103)		like '%' + @p_keywords + '%'
					or	plat_no											like '%' + @p_keywords + '%'
					or	engine_no										like '%' + @p_keywords + '%'
					or	chassis_no										like '%' + @p_keywords + '%'
					or	rental_status									like '%' + @p_keywords + '%'
					or	budget_status									like '%' + @p_keywords + '%'
					or	status											like '%' + @p_keywords + '%'
					or	fisical_status									like '%' + @p_keywords + '%'
					or	policy_no										like '%' + @p_keywords + '%'
					or	insurance_company								like '%' + @p_keywords + '%'
				) ;

		select		code
					,item_name
					,branch_name
					,net_book_value_comm
					,convert(varchar(30), policy_exp_date, 103) 'policy_exp_date'
					,plat_no
					,engine_no
					,chassis_no
					,rental_status
					,budget_status
					,status
					,fisical_status
					,policy_no
					,insurance_company
					,@rows_count								'rowcount'
		from		@tabletemp
		where		budget_status = case @p_budget_status
										when 'ALL' then budget_status
										else @p_budget_status
									end
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then code
														 when 2 then plat_no
														 when 3 then branch_name
														 when 4 then cast(policy_exp_date as sql_variant)
														 when 5 then cast(net_book_value_comm as sql_variant)
														 when 6 then status
														 when 7 then budget_status
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then code
														   when 2 then plat_no
														   when 3 then branch_name
														   when 4 then cast(policy_exp_date as sql_variant)
														   when 5 then cast(net_book_value_comm as sql_variant)
														   when 6 then status
														   when 7 then budget_status
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else if (@p_status = 'NOT EXIST')
	begin
		insert into @tabletemp
		(
			code
			,item_name
			,branch_name
			,net_book_value_comm
			,plat_no
			,engine_no
			,chassis_no
			,rental_status
			,policy_exp_date
			,budget_status
			,status
			,fisical_status
		)
		select	distinct
				ass.code
				,ass.item_name
				,ass.branch_name
				,ass.net_book_value_comm
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ass.rental_status
				,convert(varchar(30), policy.policy_exp_date, 103)
				,case
					 when isnull(ain.total_premium_amount, 0) > 0 then 'Yes'
					 else 'No'
				 end
				,ass.status
				,ass.fisical_status
		from	dbo.asset					  ass
				inner join dbo.asset_vehicle  av on (ass.code = av.asset_code)
				left join dbo.asset_insurance ain on (ain.asset_code = av.asset_code and ain.agreement_external_no = ass.agreement_external_no)
				outer apply
		(
			select	max(ipm.policy_exp_date) 'policy_exp_date'
			from	dbo.insurance_policy_asset			 ipa
					inner join dbo.insurance_policy_main ipm on ipm.code = ipa.policy_code
			where	ipa.fa_code = av.asset_code
		)									  policy
		where	exists
		(
			select	1
			from	dbo.asset
			where	ass.status	   = 'STOCK'
					or	ass.status = 'REPLACEMENT'
		)
				and ass.code not in
					(
						select	ipa.fa_code
						from	dbo.insurance_policy_asset			 ipa
								inner join dbo.insurance_policy_main ipm on ipm.code = ipa.policy_code
						where	ipm.policy_payment_status <> 'CANCEL'
					)
				and ass.code not in
				(
					select ira.fa_code from dbo.insurance_register ir
					inner join dbo.insurance_register_asset ira on ira.register_code = ir.code
					where ir.register_status <> 'CANCEL'
				)
				and ass.branch_code = case @p_branch_code
										  when 'ALL' then ass.branch_code
										  else @p_branch_code
									  end
		and (
					code												like '%' + @p_keywords + '%'
					or	item_name										like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	net_book_value_comm								like '%' + @p_keywords + '%'
					or	convert(varchar(30), policy_exp_date, 103)		like '%' + @p_keywords + '%'
					or	plat_no											like '%' + @p_keywords + '%'
					or	engine_no										like '%' + @p_keywords + '%'
					or	chassis_no										like '%' + @p_keywords + '%'
					or	rental_status									like '%' + @p_keywords + '%'
					or	status											like '%' + @p_keywords + '%'
					or	fisical_status									like '%' + @p_keywords + '%'
				) ;

		select	@rows_count = count(1)
		from	@tabletemp
		where	budget_status = case @p_budget_status
									when 'ALL' then budget_status
									else @p_budget_status
								end
				and
				(
					code												like '%' + @p_keywords + '%'
					or	item_name										like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	net_book_value_comm								like '%' + @p_keywords + '%'
					or	convert(varchar(30), policy_exp_date, 103)		like '%' + @p_keywords + '%'
					or	plat_no											like '%' + @p_keywords + '%'
					or	engine_no										like '%' + @p_keywords + '%'
					or	chassis_no										like '%' + @p_keywords + '%'
					or	rental_status									like '%' + @p_keywords + '%'
					or	budget_status									like '%' + @p_keywords + '%'
					or	status											like '%' + @p_keywords + '%'
					or	fisical_status									like '%' + @p_keywords + '%'
				) ;

		select		code
					,item_name
					,branch_name
					,net_book_value_comm
					,convert(varchar(30), policy_exp_date, 103) 'policy_exp_date'
					,plat_no
					,engine_no
					,chassis_no
					,rental_status
					,budget_status
					,status
					,fisical_status
					,@rows_count								'rowcount'
		from		@tabletemp
		where		budget_status = case @p_budget_status
										when 'ALL' then budget_status
										else @p_budget_status
									end
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then code
														 when 2 then plat_no
														 when 3 then branch_name
														 when 4 then cast(policy_exp_date as sql_variant)
														 when 5 then cast(net_book_value_comm as sql_variant)
														 when 6 then status
														 when 7 then budget_status
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then code
														   when 2 then plat_no
														   when 3 then branch_name
														   when 4 then cast(policy_exp_date as sql_variant)
														   when 5 then cast(net_book_value_comm as sql_variant)
														   when 6 then status
														   when 7 then budget_status
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else if (@p_status = 'ON PROCESS')
	begin
		insert into @tabletemp
		(
			code
			,item_name
			,branch_name
			,net_book_value_comm
			,plat_no
			,engine_no
			,chassis_no
			,rental_status
			,policy_exp_date
			,budget_status
			,status
			,fisical_status
		)
		select	distinct
				ass.code
				,ass.item_name
				,ass.branch_name
				,ass.net_book_value_comm
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ass.rental_status
				,convert(varchar(30), policy.policy_exp_date, 103)
				,case
					 when isnull(ain.total_premium_amount, 0) > 0 then 'Yes'
					 else 'No'
				 end
				,ass.status
				,ass.fisical_status
		from	dbo.asset					  ass
				inner join dbo.asset_vehicle  av on (ass.code = av.asset_code)
				left join dbo.asset_insurance ain on (ain.asset_code = av.asset_code and ain.agreement_external_no = ass.agreement_external_no)
				outer apply
		(
			select	max(ipm.policy_exp_date) 'policy_exp_date'
			from	dbo.insurance_policy_asset			 ipa
					inner join dbo.insurance_policy_main ipm on ipm.code = ipa.policy_code
			where	ipa.fa_code = av.asset_code
		)									  policy
		where	exists
		(
			select	1
			from	dbo.asset
			where	ass.status	   = 'STOCK'
					or	ass.status = 'REPLACEMENT'
		)
				--and ass.code not in
				--	(
				--		select	ipa.fa_code
				--		from	dbo.insurance_policy_asset			 ipa
				--				inner join dbo.insurance_policy_main ipm on ipm.code = ipa.policy_code
				--		where	ipm.policy_payment_status <> 'CANCEL'
				--	)
				and ass.code in
			(
				select	ira.fa_code
				from	dbo.insurance_register					ir
						inner join dbo.insurance_register_asset ira on ira.register_code = ir.code
				where	ir.register_status = 'HOLD' --<> 'CANCEL'
				union
				select	ira.fa_code
				from	dbo.insurance_register					ir
						inner join dbo.insurance_register_asset ira on ira.register_code = ir.code
						inner join dbo.sppa_request				sr on sr.register_code	 = ir.code
				where	sr.register_status = 'HOLD '--<> 'CANCEL'
				union
				select	sd.fa_code
				from	dbo.sppa_main			   sm
						inner join dbo.sppa_detail sd on sm.code = sd.sppa_code
				where	sm.sppa_status = 'HOLD' --<> 'CANCEL'
			)
			--and ass.code not in
			--(
			--	select	ipa.fa_code
			--	from	dbo.insurance_policy_asset			 ipa
			--			inner join dbo.insurance_policy_main ipm on ipm.code = ipa.policy_code
			--)
			--and ass.code not in
			--(
			--	select	sd.fa_code
			--	from	dbo.sppa_main			   sm
			--			inner join dbo.sppa_detail sd on sm.code = sd.sppa_code
			--	where	sm.sppa_status  = 'POST'
			--)
				and ass.branch_code = case @p_branch_code
										  when 'ALL' then ass.branch_code
										  else @p_branch_code
									  end
		and (
					code												like '%' + @p_keywords + '%'
					or	item_name										like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	net_book_value_comm								like '%' + @p_keywords + '%'
					or	convert(varchar(30), policy_exp_date, 103)		like '%' + @p_keywords + '%'
					or	plat_no											like '%' + @p_keywords + '%'
					or	engine_no										like '%' + @p_keywords + '%'
					or	chassis_no										like '%' + @p_keywords + '%'
					or	rental_status									like '%' + @p_keywords + '%'
					or	status											like '%' + @p_keywords + '%'
					or	fisical_status									like '%' + @p_keywords + '%'
				) ;

		select	@rows_count = count(1)
		from	@tabletemp
		where	budget_status = case @p_budget_status
									when 'ALL' then budget_status
									else @p_budget_status
								end
				and
				(
					code												like '%' + @p_keywords + '%'
					or	item_name										like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	net_book_value_comm								like '%' + @p_keywords + '%'
					or	convert(varchar(30), policy_exp_date, 103)		like '%' + @p_keywords + '%'
					or	plat_no											like '%' + @p_keywords + '%'
					or	engine_no										like '%' + @p_keywords + '%'
					or	chassis_no										like '%' + @p_keywords + '%'
					or	rental_status									like '%' + @p_keywords + '%'
					or	budget_status									like '%' + @p_keywords + '%'
					or	status											like '%' + @p_keywords + '%'
					or	fisical_status									like '%' + @p_keywords + '%'
					or	policy_no										like '%' + @p_keywords + '%'
					or	insurance_company								like '%' + @p_keywords + '%'
				) ;

		select		code
					,item_name
					,branch_name
					,net_book_value_comm
					,convert(varchar(30), policy_exp_date, 103) 'policy_exp_date'
					,plat_no
					,engine_no
					,chassis_no
					,rental_status
					,budget_status
					,status
					,fisical_status
					,policy_no
					,insurance_company
					,@rows_count								'rowcount'
		from		@tabletemp
		where		budget_status = case @p_budget_status
										when 'ALL' then budget_status
										else @p_budget_status
									end
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then code
														 when 2 then plat_no
														 when 3 then branch_name
														 when 4 then cast(policy_exp_date as sql_variant)
														 when 5 then cast(net_book_value_comm as sql_variant)
														 when 6 then status
														 when 7 then budget_status
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
														   when 1 then code
														   when 2 then plat_no
														   when 3 then branch_name
														   when 4 then cast(policy_exp_date as sql_variant)
														   when 5 then cast(net_book_value_comm as sql_variant)
														   when 6 then status
														   when 7 then budget_status
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end
end ;
