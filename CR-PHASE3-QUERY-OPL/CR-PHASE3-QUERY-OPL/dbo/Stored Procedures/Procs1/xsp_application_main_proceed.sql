CREATE PROCEDURE [dbo].[xsp_application_main_proceed]
(
	@p_application_no		nvarchar(50) 
	,@p_last_return			nvarchar(3)		= 'NO'
	,@p_approval_comment	nvarchar(4000)	= 'ENTRY to Approval'
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@id							bigint 
			,@workflow_code					nvarchar(50)
			,@scoring_code					nvarchar(50)
			,@workflow_name					nvarchar(250)
			,@to_workflow_name				nvarchar(250)
			,@application_status			nvarchar(10)
			,@level_status					nvarchar(20)
			,@remarks						nvarchar(4000) 
			,@is_approval					nvarchar(1)
			,@is_blacklist_area				nvarchar(1)
			,@is_blacklist_job				nvarchar(1)
			,@is_client_valid				nvarchar(1)
			,@loan_amount					decimal(18, 2)
			,@result_status					nvarchar(max)
			,@function_name					nvarchar(250)
			,@rules_desc					nvarchar(250)
			,@asset_no						nvarchar(50)
			,@watchlist_status				nvarchar(10)
			,@is_red_flag					nvarchar(1) 
			,@group_limit_amount			decimal(18, 2) = 0
			,@os_expousure_amount			decimal(18, 2) = 0
			,@scoring_remarks				nvarchar(4000)
			,@client_code					nvarchar(50) 
			,@asset_name					nvarchar(250)
			,@application_external_no		nvarchar(50)
			,@is_simulation					nvarchar(1)
			,@approval_code					nvarchar(50)
			,@fa_code						nvarchar(50)
			,@client_no						nvarchar(50)
			,@is_valid						nvarchar(1)

	begin try 
		-- validation
		begin 
			select	@is_valid = isnull(is_valid,0)
			from	dbo.application_exposure
			where	application_no = @p_application_no ;

			--if(@is_valid = 0)
			--begin
			--	set @msg = 'Please view exposure first.' ;

			--	raiserror(@msg, 18, 1) ;
			--end

			select	@is_blacklist_area				= am.is_blacklist_area
					,@is_blacklist_job				= am.is_blacklist_job
					,@application_status			= am.application_status
					,@level_status					= am.level_status
					,@function_name					= mw.sp_check_name
					,@is_client_valid				= cm.is_validate
					,@is_red_flag					= cm.is_red_flag
					,@watchlist_status				= cm.watchlist_status
					,@group_limit_amount			= isnull(ai.group_limit_amount, 0)
					,@os_expousure_amount			= isnull(ai.os_exposure_amount, 0)
					,@client_code					= am.client_code
					,@is_simulation					= am.is_simulation
					,@client_no						= cm.client_no
			from	dbo.application_main am
					left join dbo.client_main cm on (cm.code = am.client_code)
					left join dbo.application_information ai on (ai.application_no = am.application_no)
					left join dbo.master_workflow mw on (mw.code = am.level_status)
			where	am.application_no = @p_application_no ;

			--if ini digunakan untuk data maintenance
			if (@is_simulation = '1')
			begin
				set @approval_code = 'APPLICATION SIMULATION' ;
			end ;
			else
			begin

				set @approval_code = 'APPLICATION' ;
	
				if not exists (select 1 from dbo.mtn_application_rental where application_no = replace(@p_application_no,'/','.'))
				begin
					--validate deviation and rules
					exec dbo.xsp_application_rules_and_deviation_validate @p_application_no		= @p_application_no
																		  ,@p_cre_date			= @p_mod_date		
																		  ,@p_cre_by			= @p_mod_by			
																		  ,@p_cre_ip_address	= @p_mod_ip_address	
																		  ,@p_mod_date			= @p_mod_date		
																		  ,@p_mod_by			= @p_mod_by			
																		  ,@p_mod_ip_address	= @p_mod_ip_address	
				
					-- (+) Ari 2023-09-07 ket : validasi survey
					--exec dbo.xsp_application_survey_validate @p_application_no	= @p_application_no
					--										 ,@p_cre_date		= @p_mod_date
					--										 ,@p_cre_by			= @p_mod_by
					--										 ,@p_cre_ip_address = @p_mod_ip_address
					--										 ,@p_mod_date		= @p_mod_date
					--										 ,@p_mod_by			= @p_mod_by
					--										 ,@p_mod_ip_address = @p_mod_ip_address
				end ;
			end ;
		
			if (@is_blacklist_area = '1')
			begin
			    set @msg = 'Client Address is in Watchlist Area';
				raiserror(@msg, 16,1)
			end
			if (@is_blacklist_job = '1')
			begin
			    set @msg = 'Client Job is in Watchlist Job';
				raiserror(@msg, 16,1)
			end
            if (@watchlist_status = 'NEGATIVE') -- jika warning masih bisa lanjut
			begin
			    set @msg = 'Client is in NEGATIVE list';
				raiserror(@msg, 16,1)
			end
			--else if (@watchlist_status = 'BAD') -- jika warning masih bisa lanjut
			--begin
			--    set @msg = 'Client is in BAD list';
			--	raiserror(@msg, 16,1)
			--end

            if (@is_red_flag = '1')
			begin
			    set @msg = 'Client is in Red Flag list';
				raiserror(@msg, 16,1)
			end 

			if (@is_simulation <> '1')
			begin
				if exists
				(
					select	1
					from	dbo.application_asset
					where	application_no = @p_application_no
							and billing_to_name = ''
				)
				begin
					set @msg = 'Application Asset is not complete'
					raiserror(@msg, 16, -1)
				end

				--validasi continue Rental jika client no <> @p_client_no
				if exists
				(
					select	1
					from	ifinams.dbo.asset a
							inner join dbo.application_asset aa on (aa.fa_code = a.code)
					where	aa.application_no			= @p_application_no
							and isnull(a.re_rent_status, '') = 'CONTINUE'
							and isnull(a.client_no, '') <> ''
				)
				begin
					if exists
					(
						select	1
						from	ifinams.dbo.asset a
								inner join dbo.application_asset aa on (aa.fa_code = a.code)
						where	aa.application_no			= @p_application_no
								and isnull(a.re_rent_status, '') = 'CONTINUE'
								and isnull(a.client_no, '') <> @client_no
					)
					begin
						select @msg = N'Fixed Asset : ' + a.code + N' is already booked for Client : ' + a.client_name
							from	ifinams.dbo.asset a
								inner join dbo.application_asset aa on (aa.fa_code = a.code)
						where	aa.application_no			= @p_application_no
								and isnull(a.re_rent_status, '') = 'CONTINUE'
								and isnull(a.client_no, '') <> @client_no

						raiserror(@msg, 16, -1) ;
					end ;
				end ;
			end

			if exists
			(
				select	1
				from	dbo.application_asset aa
				inner join dbo.application_asset_budget aab on (aab.asset_no = aa.asset_no)
				where	aa.application_no = @p_application_no 
						and aab.budget_amount = 0
			)
			begin 
				select	top 1 @asset_no = aa.asset_no
				from	dbo.application_asset aa
				inner join dbo.application_asset_budget aab on (aab.asset_no = aa.asset_no)
				where	aa.application_no = @p_application_no 
						and aab.budget_amount = 0

				set @msg = 'Budget Amount must be greater than 0 for Asset : ' + @asset_no;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_asset aa
						left join dbo.application_amortization am on (
																		 am.asset_no			 = aa.asset_no
																		 and   am.installment_no = 1
																	 )
				where	aa.application_no			= @p_application_no
						and isnull(am.billing_amount, 0) = 0
			)
			begin
			
				select	@asset_no = aa.asset_no
				from	dbo.application_asset aa
						left join dbo.application_amortization am on (
																		 am.asset_no			 = aa.asset_no
																		 and   am.installment_no = 1
																	 )
				where	aa.application_no			= @p_application_no
						and isnull(am.billing_amount, 0) = 0

				set @msg = 'Please Check Application Asset Amortization For Asset : ' + @asset_no;

				raiserror(@msg, 16, 1) ;
			end ;
					
			if exists
			(
				select	1
				from	dbo.application_asset aa
						left join dbo.application_amortization am on (
																		 am.asset_no			 = aa.asset_no
																		 and   am.installment_no = 1
																	 )
						outer apply (
							select top 1 am.billing_amount from dbo.application_amortization am
							where am.asset_no = aa.asset_no
							order by am.installment_no desc
						) aml
				where	aa.application_no			= @p_application_no
						and aa.lease_rounded_amount <> (isnull(am.billing_amount, 0) + isnull(aml.billing_amount,0))
						and aa.prorate = 'yes'
			)
			begin
				select	@asset_no = aa.asset_no
				from	dbo.application_asset aa
						left join dbo.application_amortization am on (
																		 am.asset_no			 = aa.asset_no
																		 and   am.installment_no = 1
																	 )
						outer apply (
							select top 1 am.billing_amount from dbo.application_amortization am
							where am.asset_no = aa.asset_no
							order by am.installment_no desc
						) aml
				where	aa.application_no			= @p_application_no
				and		aa.lease_rounded_amount <> (isnull(am.billing_amount, 0) + isnull(aml.billing_amount,0))
				and		aa.prorate = 'yes'

				set @msg = 'Please Check Application Asset Amortization For Asset : ' + @asset_no;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_asset aa
						left join dbo.application_amortization am on (
																		 am.asset_no			 = aa.asset_no
																		 --and   am.installment_no = 1
																	 )
				where	aa.application_no			= @p_application_no
						and aa.lease_rounded_amount <> isnull(am.billing_amount, 0)
						and isnull(aa.prorate,'no') = 'no'
			)
			begin
			
				select	@asset_no = aa.asset_no
				from	dbo.application_asset aa
						left join dbo.application_amortization am on (
																		 am.asset_no			 = aa.asset_no
																		 --and   am.installment_no = 1
																	 )
				where	aa.application_no			= @p_application_no
				and		aa.lease_rounded_amount <> isnull(am.billing_amount, 0)
				and		isnull(aa.prorate,'no') = 'no'

				set @msg = 'Please check Application Asset Amortization for Asset : ' + @asset_no;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_asset
				where	application_no			  = @p_application_no
						and is_calculate_amortize = '0'
			)
			begin
				select	top 1 @asset_no = asset_no
						,@asset_name	= asset_name
				from	dbo.application_asset
				where	application_no	= @p_application_no
				and		is_calculate_amortize = '0'
				set @msg = 'Please Calculate Amortization for Asset: ' + @asset_no + ' - ' + @asset_name ;
				raiserror(@msg, 16, -1) ;
			end ;

			if (@group_limit_amount > 0)
			begin
				if (@os_expousure_amount + @loan_amount > @group_limit_amount)
				begin
					set @msg = 'Existing Loan Amount + New Loan Amount must be less than Client Group Limit. Existing Loan Amount : ' + convert(varchar, cast(@os_expousure_amount as money), 1) + ', New Loan Amount : ' + convert(varchar, cast(@loan_amount as money), 1) + ', Client Group Limit Amount : ' + convert(varchar, cast(@group_limit_amount as money), 1) ;

					raiserror(@msg, 16, 1) ;
				end ;
			end ;
				 

			if exists
			(
				select	1
				from	application_rules_result
				where	application_no = @p_application_no
			)
			begin
				select top 1
						@rules_desc = mr.description
				from	dbo.application_rules_result prr
						inner join dbo.master_rules mr on (mr.code = prr.rules_code)
				where	prr.application_no = @p_application_no ;
				set @msg = 'This Application against rules : ' + @rules_desc;
				raiserror(@msg, 16, 1) ;
			end ;  
			
			if (@level_status <> 'ENTRY')
			begin
				if (isnull(@function_name, '') <> '')
				begin
					exec @result_status = @function_name @p_application_no ;
					
					if (isnull(@result_status, '') <> '')
					begin
						set @msg = @result_status;
						raiserror(@msg, 16,1)
					end
				end
				if (@is_simulation <> '1')
				begin
					--validasi application doc yang ada docuken nya harus valid semua
					if exists
					(
						select 1 from dbo.application_doc
						where	application_no = @p_application_no
						and		isnull(filename, '') <> ''
						and		is_valid	= '0'
					)
					begin
						set @msg = 'Please Validate Document.'
						raiserror(@msg, 16, -1)
					end
				end
			end  
			
			--if exists
			--(
			--	select	1
			--	from	dbo.application_survey_request
			--	where	application_no	  = @p_application_no
			--			and survey_status = 'HOLD'
			--)
			--begin
			--	set @msg = 'Application Survey Request is not completed' ;

			--	raiserror(@msg, 16, 1) ;
			--end ; 

			--if exists
			--(
			--	select	1
			--	from	dbo.application_doc
			--	where	application_no			= @p_application_no
			--			and is_required			= '1'
			--			and isnull(paths, '')	= ''
			--			and promise_date is null
			--			and	@is_simulation		= '1'
			--)
			--begin
			--	set @msg = 'Application Document is not complete, please upload mandatory Document' ;

			--	raiserror(@msg, 16, 1) ;
			--end ;

			if not exists
				 (
					 select 1
					 from	dbo.application_asset
					 where	application_no = @p_application_no
				 )
			begin
				set @msg = 'Please input Application Asset';
				raiserror(@msg, 16, 1) ;
			end ; 
			
			--Validasi lease rounded amount tidak boleh lebih kecil dari 0
			if exists
			(
				select	1
				from	dbo.application_asset
				where	application_no = @p_application_no
				and		lease_rounded_amount <= 0
			)
			begin
				set @msg = 'Invalid rental amount. Please check unit price and budget amount.'
				raiserror (@msg, 16, -1)
			end
			
			--cek jika menggunakan asset use apakah asset tersebut digunakan di data lain
			select	@fa_code	= fa_code
					,@asset_no	= asset_no
			from	dbo.application_asset
			where	application_no = @p_application_no;	
			
			-- Louis Kamis, 25 April 2024 18.45.49 --  Penambahan validasi jika service untuk model tersebut kosong
			begin

				if exists
				(
					select	1
					from	ifinbam.dbo.master_model mm
							left join dbo.application_asset_vehicle aav on (aav.vehicle_model_code = mm.code)
							left join dbo.application_asset aa on (aa.asset_no					   = aav.asset_no)
					where	aa.application_no = @p_application_no
				)
				begin
					if ((
							select	isnull(count(mmd.service_code), 0)
							from	ifinbam.dbo.master_model_detail mmd
									inner join ifinbam.dbo.master_model mm on (mm.code					   = mmd.model_code)
									left join dbo.application_asset_vehicle aav on (aav.vehicle_model_code = mm.code)
									left join dbo.application_asset aa on (aa.asset_no					   = aav.asset_no)
							where	aa.application_no = @p_application_no
						) = 0
					   )
					begin
						select	@msg = N'Please setting service for model : ' + mm.description
						from	ifinbam.dbo.master_model mm
								left join dbo.application_asset_vehicle aav on (aav.vehicle_model_code = mm.code)
								left join dbo.application_asset aa on (aa.asset_no					   = aav.asset_no)
						where	aa.application_no = @p_application_no ;

						raiserror(@msg, 16, -1) ;
					end ;
				end ;
				 
				if exists
				(
					select	1
					from	ifinbam.dbo.master_model mm
							left join dbo.application_asset_he aah on (aah.he_model_code = mm.code)
							left join dbo.application_asset aa on (aa.asset_no			 = aah.asset_no)
					where	aa.application_no = @p_application_no
				)
				begin
					if ((
							select	isnull(count(mmd.service_code), 0)
							from	ifinbam.dbo.master_model_detail mmd
									inner join ifinbam.dbo.master_model mm on (mm.code			 = mmd.model_code)
									left join dbo.application_asset_he aah on (aah.he_model_code = mm.code)
									left join dbo.application_asset aa on (aa.asset_no			 = aah.asset_no)
							where	aa.application_no = @p_application_no
						) = 0
					   )
					begin
						select	@msg = N'Please setting service for model : ' + mm.description
						from	ifinbam.dbo.master_model mm
								left join dbo.application_asset_he aah on (aah.he_model_code = mm.code)
								left join dbo.application_asset aa on (aa.asset_no			 = aah.asset_no)
						where	aa.application_no = @p_application_no ;

						raiserror(@msg, 16, -1) ;
					end ;
				end ;
				 
				if exists
				(
					select	1
					from	ifinbam.dbo.master_model mm
							left join dbo.application_asset_machine aam on (aam.machinery_model_code = mm.code)
							left join dbo.application_asset aa on (aa.asset_no						 = aam.asset_no)
					where	aa.application_no = @p_application_no
				)
				begin
					if ((
							select	isnull(count(mmd.service_code), 0)
							from	ifinbam.dbo.master_model_detail mmd
									inner join ifinbam.dbo.master_model mm on (mm.code						 = mmd.model_code)
									left join dbo.application_asset_machine aam on (aam.machinery_model_code = mm.code)
									left join dbo.application_asset aa on (aa.asset_no						 = aam.asset_no)
							where	aa.application_no = @p_application_no
						) = 0
					   )
					begin  
						select	@msg = N'Please setting service for model : ' + mm.description
						from	ifinbam.dbo.master_model mm
								left join dbo.application_asset_machine aam on (aam.machinery_model_code = mm.code)
								left join dbo.application_asset aa on (aa.asset_no						 = aam.asset_no)
						where	aa.application_no = @p_application_no ;

						raiserror(@msg, 16, -1) ;
					end ;
				end ;
				 
				if exists
				(
					select	1
					from	ifinbam.dbo.master_model mm
							left join dbo.application_asset_electronic aae on (aae.electronic_model_code = mm.code)
							left join dbo.application_asset aa on (aa.asset_no							 = aae.asset_no)
					where	aa.application_no = @p_application_no
				)
				begin
					if ((
							select	isnull(count(mmd.service_code), 0)
							from	ifinbam.dbo.master_model_detail mmd
									inner join ifinbam.dbo.master_model mm on (mm.code							 = mmd.model_code)
									left join dbo.application_asset_electronic aae on (aae.electronic_model_code = mm.code)
									left join dbo.application_asset aa on (aa.asset_no							 = aae.asset_no)
							where	aa.application_no = @p_application_no
						) = 0
					   )
					begin
						select	@msg = N'Please setting service for model : ' + mm.description
						from	ifinbam.dbo.master_model mm
								left join dbo.application_asset_electronic aae on (aae.electronic_model_code = mm.code)
								left join dbo.application_asset aa on (aa.asset_no							 = aae.asset_no)
						where	aa.application_no = @p_application_no ;

						raiserror(@msg, 16, -1) ;
					end ;
				end ;
			end ;  
		end ;
	 
		--kebutuhan data maintenance
		if not exists (select 1 from dbo.mtn_application_rental where application_no = @p_application_no)
		begin 
			
			--for update fixe asset status to Reserved when asset condition is USED
			--begin
			--	declare currapplicationasset cursor fast_forward read_only for
			--	select	asset_no
			--			,fa_code
			--	from	dbo.application_asset
			--	where	application_no		= @p_application_no
			--			and asset_condition = 'USED' ;

			--	open currapplicationasset ;

			--	fetch next from currapplicationasset
			--	into @asset_no 
			--		 ,@fa_code ;

			--	while @@fetch_status = 0
			--	begin

			--		exec ifinams.dbo.xsp_asset_update_rental_status @p_code				= @fa_code
			--														,@p_rental_reff_no	= @asset_no
			--														,@p_rental_status	= 'RESERVED'
			--														,@p_reserved_by		= null
			--														,@p_mod_date		= @p_mod_date
			--														,@p_mod_by			= @p_mod_by
			--														,@p_mod_ip_address	= @p_mod_ip_address
				
			--		fetch next from currapplicationasset
			--		into @asset_no 
			--			 ,@fa_code ;
			--	end ;

			--	close currapplicationasset ;
			--	deallocate currapplicationasset ;
			--end

			if exists
			(
				select	1
				from	dbo.application_main
				where	application_no		   = @p_application_no
						and application_status = 'HOLD'
						and level_status	   = 'ENTRY'
						and	is_simulation	   = '0'
			)
			begin
				if exists (select 1 from dbo.sys_global_param where code = 'APPSCOR' and value = '1')
				begin
					select	@application_external_no = application_external_no
					from	dbo.application_main
					where	application_no = @p_application_no ;

					set @scoring_remarks = N'Application Scoring for ' + @application_external_no;

					exec dbo.xsp_application_scoring_request_insert @p_code				= ''
																	,@p_application_no	= @p_application_no
																	,@p_scoring_status	= N'HOLD'
																	,@p_scoring_date	= @p_mod_date
																	,@p_scoring_remarks	= @scoring_remarks
																	,@p_cre_date		= @p_mod_date		
																	,@p_cre_by			= @p_mod_by			
																	,@p_cre_ip_address	= @p_mod_ip_address
																	,@p_mod_date		= @p_mod_date		
																	,@p_mod_by			= @p_mod_by			
																	,@p_mod_ip_address	= @p_mod_ip_address

					select	@scoring_code = code
					from	dbo.application_scoring_request
					where	application_no = @p_application_no ;
				
					exec dbo.xsp_application_scoring_request_proceed @p_code			= @scoring_code
																	 ,@p_mod_date		= @p_mod_date		
																	 ,@p_mod_by			= @p_mod_by			
																	 ,@p_mod_ip_address	= @p_mod_ip_address
				end
			end ; 
		
			-- untuk getnext level and push to approval
			begin 
				exec dbo.xsp_application_main_get_next_level @p_application_no	= @p_application_no
															 ,@p_workflow_code	= @workflow_code output
															 ,@p_is_approval	= @is_approval output
															 ,@p_mod_date		= @p_mod_date
															 ,@p_mod_by			= @p_mod_by
															 ,@p_mod_ip_address = @p_mod_ip_address ; 
					
				if (@p_last_return = 'YES')
				begin
					exec dbo.xsp_application_main_proceed_to_approval @p_application_no		= @p_application_no
																	  ,@p_approval_code		= @approval_code
																	  ,@p_is_simulation		= @is_simulation
																	  ,@p_last_return		= @p_last_return
																	  ,@p_approval_comment	= @p_approval_comment
																	  ,@p_mod_date			= @p_mod_date
																	  ,@p_mod_by			= @p_mod_by
																	  ,@p_mod_ip_address	= @p_mod_ip_address ; 
				end								
				else if (@is_approval = '1')
				begin		
					exec dbo.xsp_application_main_proceed_to_approval @p_application_no		= @p_application_no
																	  ,@p_approval_code		= @approval_code
																	  ,@p_is_simulation		= @is_simulation
																	  ,@p_last_return		= @p_last_return
																	  ,@p_approval_comment	= @p_approval_comment
																	  ,@p_mod_date			= @p_mod_date
																	  ,@p_mod_by			= @p_mod_by
																	  ,@p_mod_ip_address	= @p_mod_ip_address ; 
					
				end
			end 
		
			-- update process
			begin
				if(@application_status = 'HOLD')
				begin  
					select	@to_workflow_name = description
					from	dbo.master_workflow
					where	code = @workflow_code ;

					set @application_status = 'ON PROCESS' ;

					if (@is_simulation = '1')
					begin
						set @remarks = 'SIMULATION PROCEED from ENTRY to ' + @to_workflow_name ; 
					end
					else
					begin
						set @remarks = 'PROCEED from ENTRY to ' + @to_workflow_name ; 
					end
				end
				else
				begin
					select	@to_workflow_name = description
					from	dbo.master_workflow
					where	code = @workflow_code

					select	@workflow_name = description
					from	dbo.master_workflow
					where	code = @level_status

					set @remarks = 'APPROVE from ' + isnull(@workflow_name, '') + ' to ' + isnull(@to_workflow_name,'GO LIVE');
				end
			
				begin 
					exec dbo.xsp_application_log_insert @p_id				= @id output
														,@p_application_no	= @p_application_no
														,@p_log_date		= @p_mod_date
														,@p_log_description	= @remarks
														,@p_cre_date		= @p_mod_date
														,@p_cre_by			= @p_mod_by
														,@p_cre_ip_address	= @p_mod_ip_address
														,@p_mod_date		= @p_mod_date
														,@p_mod_by			= @p_mod_by
														,@p_mod_ip_address	= @p_mod_ip_address ;
				end ;
				
				if (@p_last_return = 'YES')
				begin
					update	application_main
					set		application_status	= @application_status
							,level_status		= 'A_COMITE'
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	application_no		= @p_application_no ;
				end
				else
				begin
					update	application_main
					set		application_status	= @application_status
							,level_status		= @workflow_code
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	application_no		= @p_application_no ;
				end

				-- Louis Senin, 07 Juli 2025 18.02.05 -- update application asset status
				begin
					exec dbo.xsp_application_asset_update_asset_status @p_application_no = @p_application_no
																	   ,@p_status = @application_status
					
				end
		
				-- untuk calculate
				exec dbo.xsp_application_financial_analysis_calculate @p_application_no		= @p_application_no
																	  ,@p_mod_date			= @p_mod_date
																	  ,@p_mod_by			= @p_mod_by
																	  ,@p_mod_ip_address	= @p_mod_ip_address
			end
		end
		else
		begin
			if exists
			(
				select	1
				from	dbo.application_main
				where	application_no		   = @p_application_no
						and	is_simulation	   = '1'
			)
			begin
				--kebutuhan data maintenance
				update	application_main
				set		application_status	= 'APPROVE'
						,level_status		= 'A_FINALCK'
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	application_no		= @p_application_no ;
			end
			else
			begin
				--kebutuhan data maintenance
				update	application_main
				set		application_status	= 'APPROVE'
						,level_status		= 'GO LIVE'
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	application_no		= @p_application_no ;
			end
		end
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end ;


