/*
exec xsp_job_eod_stop_billing
*/
-- Louis Handry 27/02/2023 20:44:35 -- 
CREATE PROCEDURE dbo.xsp_job_eod_stop_billing
as
begin
	declare @msg			   nvarchar(max)
			,@agreement_no	   nvarchar(50)
			,@max_billing_date nvarchar(250)
			,@mod_date		   datetime		= getdate()
			,@mod_by		   nvarchar(15) = 'EOD'
			,@mod_ip_address   nvarchar(15) = '127.0.0.1' 
			,@asset_no				nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@client_name			nvarchar(250)
			,@remark				nvarchar(4000)
			,@fa_name				nvarchar(250)
			,@fa_code				nvarchar(50)
			,@handover_asset_code	nvarchar(50)
			,@handover_address		nvarchar(4000)
			,@handover_phone_area	nvarchar(5)
			,@handover_phone_no		nvarchar(15)
			,@handover_eta_date		datetime 
			,@agreement_external_no	nvarchar(50)
			,@client_no				nvarchar(50)
			,@bbn_location			nvarchar(250)
			,@unit_condition		nvarchar(50)

	begin try
		begin
			select	@max_billing_date = value
			FROM	dbo.sys_global_param
			WHERE	code = 'MAXBILDATE' ;

			declare curagreement cursor fast_forward read_only for
			select	am.agreement_no
			from	dbo.agreement_main am
					inner join dbo.agreement_information ai on ai.agreement_no = am.agreement_no
			where	agreement_status = 'GO LIVE'
			and		ai.ovd_days >= cast(@max_billing_date as int)

			open curagreement ;

			fetch next from curagreement
			into @agreement_no ;

			while @@fetch_status = 0
			begin
			
				--(- SEPRIA 27/07/2023) FILTER KONTRAK OVERDUE DI PASANG DI CURSOR,
				--if (dbo.xfn_agreement_get_ovd_days(@agreement_no) >  cast(@max_billing_date as int)) -- ini untuk pengecekan apa bila ovd days sudah melebihi maximum stop billing days
				begin
					update	dbo.agreement_main
					set		is_stop_billing			= '1'
							,agreement_status		= 'TERMINATE'
							,termination_date		= @mod_date
							,termination_status		= 'STOP BILLING'
							,agreement_sub_status	= 'STOP BILLING'
							--
							,mod_date				= @mod_date
							,mod_by					= @mod_by
							,mod_ip_address			= @mod_ip_address
					where	agreement_no = @agreement_no ;
			 
					declare agreementasset cursor fast_forward read_only for
					select	asset_no
							,am.branch_code
							,am.branch_name
							,isnull(aa.fa_code, aa.replacement_fa_code)
							,isnull(aa.fa_name, aa.replacement_fa_name)
							,am.client_name
							,aa.pickup_address
							,aa.pickup_phone_area_no
							,aa.pickup_phone_no
							,am.agreement_external_no
							,am.client_no
							,aa.bbn_location_description
							,aa.asset_condition
					from	agreement_asset aa
							inner join dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
					where	aa.agreement_no	 = @agreement_no
							and asset_status = 'RENTED' 

					open agreementAsset ;

					fetch next from agreementAsset
					into @asset_no
						 ,@branch_code
						 ,@branch_name
						 ,@fa_code
						 ,@fa_name
						 ,@client_name
						 ,@handover_address	
						 ,@handover_phone_area
						 ,@handover_phone_no
						 ,@agreement_external_no
						 ,@client_no
						 ,@bbn_location
						 ,@unit_condition

					while @@fetch_status = 0
					begin
			
						set @remark = 'Penarikan Unit Sewa, Stop Billing Untuk Agreement No :  ' + @agreement_external_no + '. dari Asset : ' + @fa_code + ' - ' + @fa_name + '.'

						exec dbo.xsp_opl_interface_handover_asset_insert @p_code				 = @handover_asset_code output
																		 ,@p_branch_code		 = @branch_code
																		 ,@p_branch_name		 = @branch_name
																		 ,@p_status				 = N'HOLD'  
																		 ,@p_transaction_date	 = @mod_date
																		 ,@p_type				 = N'PICK UP'
																		 ,@p_remark				 = @remark
																		 ,@p_fa_code			 = @fa_code
																		 ,@p_fa_name			 = @fa_name
																		 ,@p_handover_from		 = @client_name
																		 ,@p_handover_to		 = N'INTERNAL'
																		 ,@p_handover_address    = @handover_address  
																		 ,@p_handover_phone_area = @handover_phone_area
																		 ,@p_handover_phone_no   = @handover_phone_no 
																		 ,@p_handover_eta_date   = @handover_eta_date 
																		 ,@p_unit_condition		 = @unit_condition
																		 ,@p_reff_no			 = @asset_no
																		 ,@p_reff_name			 = N'STOP BILLING'
																		 ,@p_agreement_external_no	= @agreement_external_no
																		 ,@p_agreement_no			= @agreement_no
																		 ,@p_asset_no				= @asset_no
																		 ,@p_client_no				= @client_no
																		 ,@p_client_name			= @client_name
																		 ,@p_bbn_location			= @bbn_location
																		 --						 
																		 ,@p_cre_date			 = @mod_date	   
																		 ,@p_cre_by				 = @mod_by		   
																		 ,@p_cre_ip_address		 = @mod_ip_address 
																		 ,@p_mod_date			 = @mod_date	   
																		 ,@p_mod_by				 = @mod_by		   
																		 ,@p_mod_ip_address		 = @mod_ip_address 
			
							update	dbo.agreement_asset
							set		asset_status		= 'TERMINATE'
									--
									,mod_date			= @mod_date
									,mod_by				= @mod_by
									,mod_ip_address		= @mod_ip_address
							where	asset_no			= @asset_no ;
				

						fetch next from agreementAsset
						into @asset_no
							 ,@branch_code
							 ,@branch_name
							 ,@fa_code
							 ,@fa_name
							 ,@client_name
							 ,@handover_address	
							 ,@handover_phone_area
							 ,@handover_phone_no
							 ,@agreement_external_no
							 ,@client_no
							 ,@bbn_location
							 ,@unit_condition
					end ;

					close agreementAsset ;
					deallocate agreementAsset ;


					exec dbo.xsp_agreement_log_insert @p_id					= 0 
													  ,@p_agreement_no		= @agreement_no
													  ,@p_log_date			= @mod_date
													  ,@p_asset_no			= null
													  ,@p_log_source_no		= N'EOD'
													  ,@p_log_remarks		= N'STOP BILLING'
													  ,@p_cre_date			= @mod_date		
													  ,@p_cre_by			= @mod_by		
													  ,@p_cre_ip_address	= @mod_ip_address
													  ,@p_mod_date			= @mod_date		
													  ,@p_mod_by			= @mod_by		
													  ,@p_mod_ip_address	= @mod_ip_address
					
				end
				
				fetch next from curagreement
				into @agreement_no ;
			end ;

			close curagreement ;
			deallocate curagreement ;
		end ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
