
CREATE procedure dbo.xsp_efam_interface_journal_getrow_for_api_thirdparty
(
	@p_code				nvarchar(50)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @jramount	decimal(18, 2) ;
	
	declare @journal as table
	(
		gl_link_transaction_code nvarchar(50)
		,jr_amount				 decimal(18, 2)
	)

	if (len(@p_code) < 10) -- depreciation
	begin
	
		if exists (select	1
					from	dbo.efam_interface_journal_gl_link_transaction_detail jrd 
							inner join dbo.efam_interface_journal_gl_link_transaction jtr on jtr.code = jrd.gl_link_transaction_code
					where	jtr.code in (select journal_code collate latin1_general_ci_as from dbo.asset_depreciation where status = 'POST'
											and convert(char(6),depreciation_date,112) = @p_code)
					and		jtr.code not in (select distinct transaction_no collate latin1_general_ci_as from dbo.api_log where response_code = '1') -- Arga 05-Nov-2022 ket : exclude data integration success (+)
					and		jrd.company_code	= @p_company_code
					and		jtr.transaction_code = @p_code)
		begin
			
			insert into @journal
			(
				gl_link_transaction_code
			  , jr_amount
			)
			select	jtr.code
					,sum(isnull(jrd.base_amount_db, 0))
			from	dbo.efam_interface_journal_gl_link_transaction_detail jrd 
					left join dbo.efam_interface_journal_gl_link_transaction jtr on jtr.code = jrd.gl_link_transaction_code	
			-- Arga 05-Nov-2022 ket : open discuss for better speed loading (+)		
			where	jtr.code in (select journal_code collate latin1_general_ci_as from dbo.asset_depreciation where status = 'POST'
									and convert(char(6),depreciation_date,112) = @p_code)
			and		jtr.code not in (select distinct transaction_no collate latin1_general_ci_as from dbo.api_log where response_code = '1') -- Arga 05-Nov-2022 ket : exclude data integration success (+)
			and		jrd.company_code	= @p_company_code
			and		jtr.transaction_code = @p_code
			group by jtr.code		
			
			select	top 25 jrt.id
					,jrt.code
					,jrt.company_code
					,jrt.branch_code
					,jrt.branch_name
					,jrt.transaction_status
					,jrt.transaction_date
					,jrt.transaction_value_date
					,jrt.transaction_code
					,jrt.transaction_name
					,jrt.reff_module_code
					,jrt.reff_source_no
					,jrt.reff_source_name
					,jrt.is_journal_reversal
					,isnull(jrt.reversal_reff_no, '') 'reversal_reff_no'
					,year(jrt.transaction_value_date) 'period_year'
					,month(jrt.transaction_value_date) 'month_year'
					,isnull(jr.jr_amount, 0) 'base_amount_db'
			from	efam_interface_journal_gl_link_transaction jrt
					left join @journal jr on jr.gl_link_transaction_code collate latin1_general_ci_as = jrt.code
			where	jrt.code in (select journal_code collate latin1_general_ci_as from dbo.asset_depreciation where status = 'POST'
									and convert(char(6),depreciation_date,112) = @p_code)
			and		jrt.code not in (select distinct transaction_no collate latin1_general_ci_as from dbo.api_log where response_code = '1') -- Arga 05-Nov-2022 ket : exclude data integration success (+)
			and		jrt.transaction_code = @p_code
			and		jrt.company_code	= @p_company_code

		end
		else
		begin
			raiserror('This low value data cannot be processed' ,16,1)
			return
		end
	    
	end
	else -- non depreciation
	begin
		-- Arga 05-Nov-2022 ket : new condition for empty amount journal detail (+)
		--select	@jramount = sum(isnull(jrd.base_amount_db, 0))
		--from	dbo.efam_interface_journal_gl_link_transaction_detail jrd 
		--		inner join dbo.efam_interface_journal_gl_link_transaction jtr on jtr.code = jrd.gl_link_transaction_code
		--where	jtr.transaction_code = @p_code 
		--and		jtr.code not in (select distinct transaction_no collate latin1_general_ci_as from dbo.api_log where response_code = '1') -- Arga 05-Nov-2022 ket : exclude data integration success (+)
		--and		jrd.company_code	= @p_company_code
		--group by jtr.code
		
		insert into @journal
		(
			gl_link_transaction_code
			, jr_amount
		)
		select	jtr.code,sum(isnull(jrd.base_amount_db, 0))
		from	dbo.efam_interface_journal_gl_link_transaction_detail jrd 
				inner join dbo.efam_interface_journal_gl_link_transaction jtr on jtr.code = jrd.gl_link_transaction_code
		where	jtr.transaction_code = @p_code 
		and		jtr.code not in (select distinct transaction_no collate latin1_general_ci_as from dbo.api_log where response_code = '1') -- Arga 05-Nov-2022 ket : exclude data integration success (+)
		and		jrd.company_code	= @p_company_code
		group by jtr.code;

	    if exists (select	1
					from	dbo.efam_interface_journal_gl_link_transaction_detail jrd 
							inner join dbo.efam_interface_journal_gl_link_transaction jtr on jtr.code = jrd.gl_link_transaction_code
					where	jtr.transaction_code = @p_code 
					and		jrd.company_code	= @p_company_code
					and		jtr.code not in (select distinct transaction_no collate latin1_general_ci_as from dbo.api_log where response_code = '1')) -- Arga 05-Nov-2022 ket : exclude data integration success (+))
				--and @jramount > 0 -- Arga 05-Nov-2022 ket : new condition for empty amount journal detail (+)
					and		exists (select 1 from @journal where jr_amount > 0) -- Arga 08-Nov-2022 ket : for multiple journal sell transaction (-/+)
		begin
			--select	@jramount = sum(isnull(jrd.base_amount_db, 0))
			--from	dbo.efam_interface_journal_gl_link_transaction_detail jrd 
			--		inner join dbo.efam_interface_journal_gl_link_transaction jtr on jtr.code = jrd.gl_link_transaction_code
			--where	jtr.transaction_code = @p_code 
			--and		jtr.code not in (select distinct transaction_no collate latin1_general_ci_as from dbo.api_log where response_code = '1') -- Arga 05-Nov-2022 ket : exclude data integration success (+)
			--and		jrd.company_code	= @p_company_code
			--group by jtr.code;
			

			select	jrt.id
					,jrt.code
					,jrt.company_code
					,jrt.branch_code
					,jrt.branch_name
					,jrt.transaction_status
					,jrt.transaction_date
					,jrt.transaction_value_date
					,jrt.transaction_code
					,jrt.transaction_name
					,jrt.reff_module_code
					,jrt.reff_source_no
					,jrt.reff_source_name
					,jrt.is_journal_reversal
					,isnull(jrt.reversal_reff_no, '') 'reversal_reff_no'
					,year(jrt.transaction_value_date) 'period_year'
					,month(jrt.transaction_value_date) 'month_year'
					--,cast(@jramount as nvarchar(25)) 'base_amount_db'
					,cast(jr.jr_amount as nvarchar(25)) 'base_amount_db'
			from	efam_interface_journal_gl_link_transaction jrt
					left join @journal jr on jr.gl_link_transaction_code collate latin1_general_ci_as = jrt.code
			where	jrt.transaction_code = @p_code
			and		jrt.code not in (select distinct transaction_no collate latin1_general_ci_as from dbo.api_log where response_code = '1') -- Arga 05-Nov-2022 ket : exclude data integration success (+)
			and		jrt.company_code = @p_company_code ;
		end
		else
		begin
			raiserror('This low value data cannot be processed' ,16,1)
			return
		end
	end

	/*
	if (len(@p_code) < 10) -- depreciation
	begin
		
		if exists (select	1
					from	dbo.efam_interface_journal_gl_link_transaction_detail jrd 
							inner join dbo.efam_interface_journal_gl_link_transaction jtr on jtr.code = jrd.gl_link_transaction_code
					where	jtr.code in (select journal_code collate latin1_general_ci_as from dbo.asset_depreciation where status = 'POST'
											and convert(char(6),depreciation_date,112) = @p_code)
					and		jtr.code not in (select type_code collate latin1_general_ci_as from dbo.success_data_migration where len(type_code) > 10) 
					--and		jtr.code not in (select distinct transaction_no from dbo.api_log where response_code = '1') -- Arga 05-Nov-2022 ket : exclude data integration success (+)
					and		jrd.company_code	= @p_company_code
					and		jtr.transaction_code = @p_code)
		begin
			
			insert into @journal
			(
				gl_link_transaction_code
			  , jr_amount
			)
			select	jtr.code
					,sum(isnull(jrd.base_amount_db, 0))
			from	dbo.efam_interface_journal_gl_link_transaction_detail jrd 
					left join dbo.efam_interface_journal_gl_link_transaction jtr on jtr.code = jrd.gl_link_transaction_code	
			-- Arga 05-Nov-2022 ket : open discuss for better speed loading (+)		
			--where	jtr.code in (select journal_code collate latin1_general_ci_as from dbo.asset_depreciation where status = 'POST'
			--						and convert(char(6),depreciation_date,112) = @p_code)
			--and		jtr.code not in (select type_code collate latin1_general_ci_as from dbo.success_data_migration where len(type_code) > 10) 
			----and		jtr.code not in (select distinct transaction_no from dbo.api_log where response_code = '1') -- Arga 05-Nov-2022 ket : exclude data integration success (+)
			--and		jrd.company_code	= @p_company_code)
			group by jtr.code		

			select	jrt.id
					,jrt.code
					,jrt.company_code
					,jrt.branch_code
					,jrt.branch_name
					,jrt.transaction_status
					,jrt.transaction_date
					,jrt.transaction_value_date
					,jrt.transaction_code
					,jrt.transaction_name
					,jrt.reff_module_code
					,jrt.reff_source_no
					,jrt.reff_source_name
					,jrt.is_journal_reversal
					,isnull(jrt.reversal_reff_no, '') 'reversal_reff_no'
					,year(jrt.transaction_value_date) 'period_year'
					,month(jrt.transaction_value_date) 'month_year'
					,isnull(jr.jr_amount, 0) 'base_amount_db'
			from	efam_interface_journal_gl_link_transaction jrt
					left join @journal jr on jr.gl_link_transaction_code collate latin1_general_ci_as = jrt.code
			where	jrt.code in (select journal_code collate latin1_general_ci_as from dbo.asset_depreciation where status = 'POST'
									and convert(char(6),depreciation_date,112) = @p_code)
			and		jrt.code not in (select type_code collate latin1_general_ci_as from dbo.success_data_migration where len(type_code) > 10) 
			--and		jrt.code not in (select distinct transaction_no from dbo.api_log where response_code = '1') -- Arga 05-Nov-2022 ket : exclude data integration success (+)
			and		jrt.company_code	= @p_company_code

			--where	jrt.company_code = @p_company_code 
			--and		jrt.transaction_code = @p_code 
			--and jrt.CODE = '0011FAMDPR2211000022'
			--and		jrt.code in (select journal_code collate latin1_general_ci_as from dbo.asset_depreciation where status = 'POST' and convert(char(6),depreciation_date,112) = @p_code)
			--and		jrt.code not in (select type_code collate latin1_general_ci_as from dbo.success_data_migration where len(type_code) > 10) 
			--and		jrt.code in ( '1171FAMDPR2211000006'
			--						,'1201FAMDPR2211000006'
			--						,'1221FAMDPR2211000006'
			--						,'1241FAMDPR2211000006'
			--						,'1251FAMDPR2211000006'
			--						,'1331FAMDPR2211000006'
			--						,'1541FAMDPR2211000006'
			--						,'5011FAMDPR2211000006'
			--						,'5111FAMDPR2211000006')
			--and		jrt.transaction_value_date = '2022-11-30';

			insert into dbo.success_data_migration
			(
				id
				,type_code
			)
			select	@p_code --202302
					,jrt.code
			from	efam_interface_journal_gl_link_transaction jrt
					left join @journal jr on jr.gl_link_transaction_code collate latin1_general_ci_as = jrt.code
			where	jrt.code in (select journal_code collate latin1_general_ci_as from dbo.asset_depreciation where status = 'POST'
									and convert(char(6),depreciation_date,112) = @p_code)
			and		jrt.code not in (select type_code collate latin1_general_ci_as from dbo.success_data_migration where len(type_code) > 10) 
			and		jrt.company_code	= @p_company_code

			--and		jrt.code in (select journal_code collate latin1_general_ci_as from dbo.asset_depreciation where status = 'POST')
			--and	jrt.code not in (select type_code collate latin1_general_ci_as from dbo.success_data_migration where len(type_code) > 10) 
			--and		jrt.code in ( '1561FAMDPR2211000006'
			--						,'1571FAMDPR2211000006'
			--						,'1581FAMDPR2211000006'
			--						,'1591FAMDPR2211000006'
			--						,'1601FAMDPR2211000006'
			--						,'1611FAMDPR2211000006'
			--						,'1621FAMDPR2211000006'
			--						,'1731FAMDPR2211000006'
			--						,'1741FAMDPR2211000006'
			--						,'1761FAMDPR2211000006'
			--						,'1991FAMDPR2211000006'
			--						,'2091FAMDPR2211000006'
			--						,'2171FAMDPR2211000006'
			--						,'2181FAMDPR2211000006'
			--						,'2301FAMDPR2211000006'
			--						,'3271FAMDPR2211000006'
			--						,'3771FAMDPR2211000006'
			--						,'3781FAMDPR2211000006'
			--						,'3791FAMDPR2211000006'
			--						,'4111FAMDPR2211000006'
			--						,'4211FAMDPR2211000006'
			--						,'4311FAMDPR2211000006'
			--						,'4411FAMDPR2211000006'
			--						,'4511FAMDPR2211000006'
			--						,'4611FAMDPR2211000006'
			--						,'4711FAMDPR2211000006'
			--						,'4811FAMDPR2211000006'
			--						,'4911FAMDPR2211000006'
			--						,'5011FAMDPR2211000006'
			--						,'5111FAMDPR2211000006'
			--						,'5211FAMDPR2211000006'
			--						,'5311FAMDPR2211000006'
			--						,'5411FAMDPR2211000006'
			--						,'5541FAMDPR2211000006'
			--						,'5711FAMDPR2211000006'
			--						,'5921FAMDPR2211000006'
			--						,'6001FAMDPR2211000006'
			--						,'6041FAMDPR2211000006'
			--						,'6051FAMDPR2211000006'
			--						,'6121FAMDPR2211000006'
			--						,'6371FAMDPR2211000006'
			--						,'6411FAMDPR2211000006'
			--						,'6511FAMDPR2211000006'
			--						,'6521FAMDPR2211000006'
			--						,'6531FAMDPR2211000006'
			--						,'6541FAMDPR2211000006'
			--						,'6681FAMDPR2211000006'
			--						,'6751FAMDPR2211000006'
			--						,'9011FAMDPR2211000006'
			--						,'9021FAMDPR2211000006')
			--and		jrt.transaction_value_date = '2022-11-30';
			
		end
		else
		begin
			raiserror('This low value data cannot be processed' ,16,1)
			return
		end
	    
	end
	else -- non depreciation
	begin
		-- Arga 05-Nov-2022 ket : new condition for empty amount journal detail (+)
		select	@jramount = sum(isnull(jrd.base_amount_db, 0))
		from	dbo.efam_interface_journal_gl_link_transaction_detail jrd 
				inner join dbo.efam_interface_journal_gl_link_transaction jtr on jtr.code = jrd.gl_link_transaction_code
		where	jtr.transaction_code = @p_code 
		and		jrd.company_code	= @p_company_code;

	    if exists (select	1
					from	dbo.efam_interface_journal_gl_link_transaction_detail jrd 
							inner join dbo.efam_interface_journal_gl_link_transaction jtr on jtr.code = jrd.gl_link_transaction_code
					where	jtr.transaction_code = @p_code 
					and		jrd.company_code	= @p_company_code)
				and @jramount > 0 -- Arga 05-Nov-2022 ket : new condition for empty amount journal detail (+)
		begin
			select	@jramount = sum(isnull(jrd.base_amount_db, 0))
			from	dbo.efam_interface_journal_gl_link_transaction_detail jrd 
					inner join dbo.efam_interface_journal_gl_link_transaction jtr on jtr.code = jrd.gl_link_transaction_code
			where	jtr.transaction_code = @p_code 
			and		jrd.company_code	= @p_company_code;

			select	jrt.id
					,jrt.code
					,jrt.company_code
					,jrt.branch_code
					,jrt.branch_name
					,jrt.transaction_status
					,jrt.transaction_date
					,jrt.transaction_value_date
					,jrt.transaction_code
					,jrt.transaction_name
					,jrt.reff_module_code
					,jrt.reff_source_no
					,jrt.reff_source_name
					,jrt.is_journal_reversal
					,isnull(jrt.reversal_reff_no, '') 'reversal_reff_no'
					,year(jrt.transaction_value_date) 'period_year'
					,month(jrt.transaction_value_date) 'month_year'
					--,replace(cast(@jramount as nvarchar(25)), '.00', '') 'base_amount_db'
					,cast(@jramount as nvarchar(25)) 'base_amount_db'
			from	efam_interface_journal_gl_link_transaction jrt
					--inner join dbo.efam_interface_journal_gl_link_transaction_detail jrd on (jrd.gl_link_transaction_code = jrt.code)
			where	jrt.transaction_code = @p_code
			and		jrt.company_code = @p_company_code ;
		end
		else
		begin
			raiserror('This low value data cannot be processed' ,16,1)
			return
		end
	end
	*/

end ;
