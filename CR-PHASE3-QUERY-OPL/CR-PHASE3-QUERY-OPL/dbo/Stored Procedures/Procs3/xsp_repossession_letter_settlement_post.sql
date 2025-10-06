CREATE PROCEDURE dbo.xsp_repossession_letter_settlement_post
(
	@p_code							NVARCHAR(50)
	--
	,@p_cre_date					DATETIME
	,@p_cre_by						NVARCHAR(15)
	,@p_cre_ip_address				NVARCHAR(15)
	,@p_mod_date					DATETIME
	,@p_mod_by						NVARCHAR(15)
	,@p_mod_ip_address				NVARCHAR(15)
)
AS
BEGIN
	
	DECLARE @msg									nvarchar(max)
			,@gl_link_code_deposit					nvarchar(50)
			,@gl_link_code_penalty					nvarchar(50)
			,@gl_link_code_installment				nvarchar(50)
			,@agreement_no							nvarchar(50)
			,@agreement_external_no					nvarchar(50)
			,@mak_code								nvarchar(50)
			,@bast_main_code						nvarchar(50)
			,@asset_no								nvarchar(50)
			,@result_status							nvarchar(10)
			,@result_action							nvarchar(10)
			,@letter_collector_code					nvarchar(50)
			,@letter_collector_name					nvarchar(250)
			,@reserve_back_to_current				int
			,@installment_no						int
			,@installment_amount					decimal(18,2)
			,@branch_code							nvarchar(50)
			,@branch_name							nvarchar(250)
			,@purpose_loan_code 					nvarchar(50)
			,@purpose_loan_name 					nvarchar(250)
			,@purpose_loan_detail_code 				nvarchar(50)
			,@purpose_loan_detail_name 				nvarchar(250)
			,@facility_code							nvarchar(50)
			,@facility_name							nvarchar(250)
			,@client_name							nvarchar(250)
			,@client_no								nvarchar(50)
			,@request_amount						decimal(18,2)
			,@detail_amount							decimal(18,2)
			,@overdue_installment_amount			decimal(18,2)	
			,@currency_code							nvarchar(3)
			,@date									datetime = dbo.xfn_get_system_date()
			,@letter_no								nvarchar(50)
			,@checklist_code						nvarchar(50)
			,@bast_code								nvarchar(50)
			,@cashier_received_code					nvarchar(50)
			,@agreement_status						nvarchar(10)
			,@agreement_sub_status					nvarchar(20)
			,@reposition_status						nvarchar(10)
			,@remarks								nvarchar(4000)
			,@result_received_remarks				nvarchar(4000)
			,@entry_remarks							nvarchar(4000)
			,@letter_remarks						nvarchar(4000)
			,@result_received_amount				decimal(18,2)	
			,@code									nvarchar(50)
			,@fa_code								nvarchar(50)
			,@fa_name								nvarchar(250)
			,@deliver_to_name						nvarchar(250)
			,@company_address						nvarchar(4000)
			,@company_phone_are						nvarchar(5)
			,@company_phone_no						nvarchar(15)
			,@bbn_location							nvarchar(250)

	begin try
		
		select  @agreement_no							= rl.agreement_no
				,@agreement_external_no 				= am.agreement_external_no 
				,@agreement_status 						= am.agreement_status 
				,@agreement_sub_status 					= am.agreement_sub_status
				,@client_name 							= am.client_name 
				,@client_no 							= am.client_no 
				,@result_status 						= rl.result_status
				,@result_action 						= rl.result_action 
				,@facility_code 						= am.facility_code
				,@facility_name 						= am.facility_name
				,@branch_code 							= rl.branch_code
				,@branch_name 							= rl.branch_name
				,@letter_no								= rl.letter_no
				,@currency_code							= am.currency_code
				,@date									= rl.letter_date
				,@letter_collector_code					= rl.letter_collector_code
				,@letter_collector_name					= mc.collector_name
				,@letter_remarks						= rl.letter_remarks
		from	repossession_letter rl
				left join agreement_main am						on (am.agreement_no = rl.agreement_no)
				left join dbo.repossession_letter_collateral rlc	on (rlc.letter_code = rl.code)
				left join dbo.master_collector mc on (mc.code = rl.letter_collector_code)
		where	rl.code			 = @p_code
		 

		if(@agreement_status = 'GO LIVE')
		begin
			if(@agreement_sub_status = 'WO')
			begin
				set @reposition_status = 'REPO WO'
			end 
			else if(isnull(@agreement_sub_status,'') = '')
			begin
				set @reposition_status = 'REPO I'
			end
		end
		

		SELECT @gl_link_code_installment = value FROM dbo.sys_global_param where CODE = 'INST'
		SELECT @gl_link_code_penalty = value FROM dbo.sys_global_param where CODE = 'OVDP'
		SELECT @gl_link_code_deposit = value FROM dbo.sys_global_param where CODE = 'DPINST'


		if exists(select 1 from dbo.repossession_letter where code = @p_code and (isnull(result_status,'') ='' or result_date is null ))
		begin
			set @msg = 'Please fill Result for this transaction before';
			raiserror(@msg ,16,-1)
        end

		if exists(select 1 from dbo.repossession_letter where code = @p_code and result_status = 'REPO')
		begin
			if not exists(select 1 from dbo.repossession_letter_collateral where letter_code = @p_code and is_success_repo ='1')
			begin
				set @msg = 'Please choose Asset';
				raiserror(@msg ,16,-1)
			end

			if  exists
			(
				select	1
				from	dbo.warning_letter
				where	agreement_no	   = @agreement_no
						--and installment_no = @installment_no
						and letter_status  IN ( 'HOLD', 'ON PROCESS','POST') 
						--and letter_status  = 'DELIVERED'
						and letter_type	   = 'SP1'			
			)
			begin
				select	top 1 
						@letter_no 	 = letter_no
				from	dbo.warning_letter 
				where	agreement_no = @agreement_no 
						--and installment_no = @installment_no 
						and letter_status  IN ( 'HOLD', 'ON PROCESS','POST') 
						--and letter_status <> 'CANCEL' 
						and letter_type = 'SP1'

				set @msg = 'Letter No : ' + @letter_no + ' - SP1 Agreement No : ' + @agreement_external_no + ' - ' + @client_name + ' not DELIVERED yet';
				raiserror(@msg ,16,-1)
			end

			if  exists
			(
				select	1
				from	dbo.warning_letter
				where	agreement_no	   = @agreement_no
						--and installment_no = @installment_no
						and letter_status  IN ( 'HOLD', 'ON PROCESS','POST') 
						--and letter_status  = 'DELIVERED'
						and letter_type	   = 'SP2'	
			)
			begin
				select	top 1 
						@letter_no 	 = letter_no
				from	dbo.warning_letter 
				where	agreement_no = @agreement_no 
						--and installment_no = @installment_no 
						and letter_status  IN ( 'HOLD', 'ON PROCESS','POST') 
						--and letter_status <> 'CANCEL' 
						and letter_type = 'SP2'

				set @msg = 'Letter No : ' + @letter_no + ' - SP2 Agreement No : ' + @agreement_external_no + ' - ' + @client_name + ' not DELIVERED yet';
				raiserror(@msg ,16,-1)
			end

			if  exists
			(
				select	1
				from	dbo.warning_letter
				where	agreement_no	   = @agreement_no
						--and installment_no = @installment_no
						and letter_status  IN ( 'HOLD', 'ON PROCESS','POST') 
						--and letter_status  = 'DELIVERED'
						and letter_type	   = 'SOMASI'			
			)
			begin
				select	top 1 
						@letter_no 	 = letter_no
				from	dbo.warning_letter 
				where	agreement_no = @agreement_no 
						--and installment_no = @installment_no 
						--and letter_status <> 'CANCEL' 
						and letter_status  IN ( 'HOLD', 'ON PROCESS','POST') 
						and letter_type = 'SOMASI'

				set @msg = 'Letter No : ' + @letter_no + ' - SOMASI Agreement No : ' + @agreement_external_no + ' - ' + @client_name + ' not DELIVERED yet';
				raiserror(@msg ,16,-1)
			end

        end

		if exists(select 1 from dbo.repossession_letter where code = @p_code and letter_status <> 'POST')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
        end
		else
		begin
            select	@company_address = value
			from	dbo.SYS_GLOBAL_PARAM
			where	CODE = 'INVADD' ;

			select	@company_phone_are = value
			from	dbo.SYS_GLOBAL_PARAM
			where	CODE = 'TELPAREA' ;

			select	@company_phone_no = value
			from	dbo.SYS_GLOBAL_PARAM
			where	CODE = 'TELP' ;

			if (@result_status = 'REPO')
			begin
				
				declare c_bast cursor local fast_forward for
		
				select	rlc.asset_no
						,aga.fa_code
						,aga.fa_name
						,aga.bbn_location_description
				from	dbo.repossession_letter_collateral rlc
				left join	dbo.agreement_asset aga on (aga.asset_no = rlc.asset_no)
				where	rlc.letter_code		 = @p_code
				and		rlc.is_success_repo	 = '1'

				open	c_bast
				fetch	c_bast
				into	@asset_no
						,@fa_code
						,@fa_name
						,@bbn_location

				while @@fetch_status = 0
				begin
					if (@fa_code is null)
					begin
                    	set @msg = 'Please check, is main asset already delivered';
						raiserror(@msg ,16,-1)
					END
                    
					UPDATE	dbo.agreement_asset
					set		asset_status		= 'REPOSSESSION'
							--
							,mod_date			= @p_mod_date		
							,mod_by				= @p_mod_by			
							,mod_ip_address		= @p_mod_ip_address	
					where	asset_no			= @asset_no

					--ini masuk ke handover
					--exec dbo.xsp_opl_interface_bast_main_insert @p_code					= ''
					--											 ,@p_branch_code			= @branch_code
					--											 ,@p_branch_name			= @branch_name
					--											 ,@p_repo_date				= @date
					--											 ,@p_agreement_no			= @agreement_no
					--											 ,@p_collateral_no			= @asset_no
					--											 ,@p_reposition_letter_code = @letter_no
					--											 ,@p_reposition_status		= @reposition_status
					--											 ,@p_cre_date				= @p_cre_date			
					--											 ,@p_cre_by					= @p_cre_by				
					--											 ,@p_cre_ip_address			= @p_cre_ip_address		
					--											 ,@p_mod_date				= @p_mod_date			
					--											 ,@p_mod_by					= @p_mod_by				
					--											 ,@p_mod_ip_address			= @p_mod_ip_address

					--set data company
				
					set @remarks = 'Penarikan Unit Sewa, SKT Settlemen Untuk Agreement No :  ' + @agreement_external_no + '. dari Asset : ' + @fa_code + ' - ' + @fa_name + '.'

					exec dbo.xsp_opl_interface_handover_asset_insert @p_code					= @code output 
																	 ,@p_branch_code			= @branch_code
																	 ,@p_branch_name			= @branch_name
																	 ,@p_status					= N'HOLD'
																	 ,@p_transaction_date		= @date
																	 ,@p_type					= N'PICK UP'
																	 ,@p_remark					= @remarks
																	 ,@p_fa_code				= @fa_code
																	 ,@p_fa_name				= @fa_name
																	 ,@p_handover_from			= @client_name
																	 ,@p_handover_to			= N'INTERNAL'
																	 ,@p_handover_address		= @company_address
																	 ,@p_handover_phone_area	= @company_phone_are
																	 ,@p_handover_phone_no		= @company_phone_no
																	 ,@p_handover_eta_date		= @date
																	 ,@p_unit_condition			= N''
																	 ,@p_reff_no				= @asset_no
																	 ,@p_reff_name				= N'SKT SETTLEMENT'
																	 ,@p_agreement_external_no	= @agreement_external_no
																	 ,@p_agreement_no			= @agreement_no
																	 ,@p_asset_no				= @asset_no
																	 ,@p_client_no				= @client_no
																	 ,@p_client_name			= @client_name
																	 ,@p_bbn_location			= @bbn_location
																	 --
																	 ,@p_cre_date				= @p_cre_date			
																	 ,@p_cre_by					= @p_cre_by				
																	 ,@p_cre_ip_address			= @p_cre_ip_address		
																	 ,@p_mod_date				= @p_mod_date			
																	 ,@p_mod_by					= @p_mod_by				
																	 ,@p_mod_ip_address			= @p_mod_ip_address
					
												
					fetch	c_bast
					into	@asset_no
							,@fa_code
							,@fa_name
							,@bbn_location

				end
				close c_bast
				deallocate c_bast

				--update agreement information set skt status nya menjadi kosong
				update	dbo.agreement_information
				set		skt_status			= null
						--
						,@p_mod_date		= @p_mod_date		
						,@p_mod_by			= @p_mod_by			
						,@p_mod_ip_address	= @p_mod_ip_address
				where	agreement_no		= @agreement_no

				-- insert to blacklist
				--set @entry_remarks = 'Automatic from SETTELMENT SKT NO : ' + @p_code + ' and AGREEMENT NO : ' + @agreement_external_no + ' - ' + @letter_remarks
				--exec dbo.xsp_opl_interface_client_blacklist_insert @p_source			= N'IFINOPL'              
				--			                                       ,@p_blacklist_type	= N'NEGATIVE'              
				--			                                       ,@p_client_no		= @client_no                 
				--			                                       ,@p_entry_date		= @date
				--			                                       ,@p_entry_remarks	= @entry_remarks
				--			                                       ,@p_exit_date		= null
				--			                                       ,@p_exit_remarks		= null               
				--			                                       ,@p_cre_date			= @p_mod_date		
				--			                                       ,@p_cre_by			= @p_mod_by			
				--			                                       ,@p_cre_ip_address	= @p_mod_ip_address
				--			                                       ,@p_mod_date			= @p_mod_date		
				--			                                       ,@p_mod_by			= @p_mod_by			
				--			                                       ,@p_mod_ip_address	= @p_mod_ip_address	

			end 
			
			if (@result_status = 'FAILED' and @result_action = 'CHANGE')
			begin
				update	dbo.repossession_letter
				set		letter_status						= 'HOLD'
						,letter_eff_date					= null
						,letter_exp_date					= null
						,letter_collector_code				= null
						,letter_collector_name				= null
						,letter_collector_position			= null
						,letter_signer_collector_code		= null
						,letter_signer_collector_name		= null
						,letter_signer_collector_position	= null
						,companion_id_no					= null
						,companion_name						= null
						,companion_job						= null
						--
						,mod_date							= @p_mod_date		
						,mod_by								= @p_mod_by			
						,mod_ip_address						= @p_mod_ip_address	
				where	code								= @p_code

				delete	dbo.repossession_letter_collateral
				where	letter_code = @p_code
			end
			else
			begin
				update	dbo.repossession_letter
				set		letter_status		='SETTLEMENT'
						--
						,mod_date			= @p_mod_date		
						,mod_by				= @p_mod_by			
						,mod_ip_address		= @p_mod_ip_address	
				where	code				= @p_code

				update	dbo.agreement_main
				set		collection_status	= ''
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	agreement_no		= @agreement_no ;

				--update agreement information set skt status nya menjadi kosong
				update	dbo.agreement_information
				set		skt_status			= null
						--
						,@p_mod_date		= @p_mod_date		
						,@p_mod_by			= @p_mod_by			
						,@p_mod_ip_address	= @p_mod_ip_address
				where	agreement_no		= @agreement_no

			end

			--update	dbo.repossession_letter
			--set		letter_status		= 'SETTLEMENT'
			--		--
			--		,mod_date			= @p_mod_date		
			--		,mod_by				= @p_mod_by			
			--		,mod_ip_address		= @p_mod_ip_address	
			--where	code				= @p_code

			--exec dbo.xsp_agreement_log_insert @p_id							= 0 -- bigint
			--								  ,@p_agreement_no				= @agreement_no
			--								  ,@p_log_date					= @p_cre_date
			--								  ,@p_log_transaction_no		= @p_code
			--								  ,@p_log_transaction_source	= 'Repossession Letter Settlement'
			--								  ,@p_log_remarks				= N'Repossession Letter Settlement' -- nvarchar(4000)
			--								  ,@p_cre_date					= @p_cre_date			
			--								  ,@p_cre_by					= @p_cre_by				
			--								  ,@p_cre_ip_address			= @p_cre_ip_address		
			--								  ,@p_mod_date					= @p_mod_date			
			--								  ,@p_mod_by					= @p_mod_by				
			--								  ,@p_mod_ip_address			= @p_mod_ip_address

			 declare @p_id bigint;
			 exec dbo.xsp_agreement_log_insert @p_id						= 0
											  ,@p_agreement_no				= @agreement_no
											  ,@p_log_date					= @p_cre_date
											  ,@p_log_source_no				= @p_code
											  ,@p_asset_no					= @asset_no
											  ,@p_log_remarks				= N'Repossession Letter Settlement' -- nvarchar(4000)
											  ,@p_cre_date					= @p_cre_date		
											  ,@p_cre_by					= @p_cre_by			
											  ,@p_cre_ip_address			= @p_cre_ip_address	
											  ,@p_mod_date					= @p_mod_date		
											  ,@p_mod_by					= @p_mod_by			
											  ,@p_mod_ip_address			= @p_mod_ip_address
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

end
