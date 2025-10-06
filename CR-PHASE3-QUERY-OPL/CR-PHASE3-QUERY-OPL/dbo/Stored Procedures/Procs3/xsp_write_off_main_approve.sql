CREATE PROCEDURE [dbo].[xsp_write_off_main_approve]
(
	@p_code						nvarchar(50)
	,@p_approval_reff			nvarchar(250)
	,@p_approval_remark			nvarchar(4000)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)	
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg			nvarchar(max)
			,@remark		nvarchar(4000)
			,@entry_remarks nvarchar(4000)
			,@agreement_no	nvarchar(50)
			,@wo_date		datetime
			,@client_code	nvarchar(50)
			,@invoice_no	nvarchar(50) ;
	
	begin try
		
		if exists(select 1 from dbo.write_off_main where code = @p_code and wo_status <> 'ON PROCESS')
		begin
			set @msg ='Error data already proceed';
		    raiserror(@msg,16,1) ;
		end
        else
		begin
			
			select	@remark			= wom.wo_remarks
					,@agreement_no	= wom.agreement_no
					,@wo_date		= wom.wo_date  
					,@client_code	= am.client_no
			from	dbo.write_off_main wom
					inner join dbo.agreement_main am on (am.agreement_no = wom.agreement_no)
			where	code			= @p_code

			-- insert to blacklist
			set @entry_remarks = 'Automatic from WRITE OFF NO : ' + @p_code + ' and AGREEMENT NO : ' + @agreement_no + ' - ' + @remark
			
			exec dbo.xsp_opl_interface_client_blacklist_insert @p_source			= N'IFINOPL'              
							                                    ,@p_blacklist_type	= N'NEGATIVE'              
							                                    ,@p_client_no		= @client_code                 
							                                    ,@p_entry_date		= @wo_date
							                                    ,@p_entry_remarks	= @entry_remarks
							                                    ,@p_exit_date		= null
							                                    ,@p_exit_remarks	= null               
							                                    ,@p_cre_date		= @p_mod_date		
							                                    ,@p_cre_by			= @p_mod_by			
							                                    ,@p_cre_ip_address	= @p_mod_ip_address
							                                    ,@p_mod_date		= @p_mod_date		
							                                    ,@p_mod_by			= @p_mod_by			
							                                    ,@p_mod_ip_address	= @p_mod_ip_address	
			
			exec dbo.xsp_write_off_main_journal		@p_reff_name				= 'WRITE OFF'
													,@p_reff_code				= @p_code
													,@p_value_date				= @wo_date
													,@p_trx_date				= @p_mod_date
													,@p_mod_date				= @p_mod_date
													,@p_mod_by					= @p_mod_by
													,@p_mod_ip_address			= @p_mod_ip_address
			 
			declare curragreementinvoice cursor fast_forward read_only for
			select	ai.invoice_no
			from	dbo.agreement_invoice ai
					inner join dbo.invoice inv on ai.invoice_no = inv.invoice_no
			where	ai.agreement_no		   = @agreement_no
					and inv.invoice_status = 'POST' ;

			open curragreementinvoice ;

			fetch next from curragreementinvoice
			into @invoice_no ;

			while @@fetch_status = 0
			begin
				exec dbo.xsp_agreement_write_off_update_invoice @p_invoice_no		= @invoice_no -- nvarchar(50)
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address
				
				fetch next from curragreementinvoice
				into @invoice_no ;
			end ;

			close curragreementinvoice ;
			deallocate curragreementinvoice ;
 
			--update agreement & asset
			begin 
				update	dbo.agreement_main
				set		agreement_status		= 'TERMINATE'
						,agreement_sub_status	= 'COMPLETE' --'WO'
						,termination_status     = 'WO'
						,termination_date		= @wo_date
						--
						,mod_by					= @p_mod_by
						,mod_date				= @p_mod_date
						,mod_ip_address			= @p_mod_ip_address
				where	agreement_no			= @agreement_no

				update	dbo.agreement_information
				set		blacklist_status		= 'NEW'
						,blacklist_date			= @wo_date
						,blacklist_remark		= 'WRITE OFF'
						--
						,mod_by					= @p_mod_by
						,mod_date				= @p_mod_date
						,mod_ip_address			= @p_mod_ip_address
				where	agreement_no			= @agreement_no
				
				exec dbo.xsp_opl_interface_agreement_update_out_insert @p_agreement_no		= @agreement_no
																	   ,@p_mod_date			= @p_mod_date
																	   ,@p_mod_by			= @p_mod_by
																	   ,@p_mod_ip_address	= @p_mod_ip_address 
				
				-- Hari - 05.Jul.2023 01:51 PM -- samakan dengan ET, alur asset status ( RENTED - TERMINATE - RETURN )
				update	dbo.agreement_asset
				set		asset_status	= 'TERMINATE'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	agreement_no			= @agreement_no
						and asset_status = 'RENTED'
						and asset_no in
						(
							select	asset_no
							from	dbo.write_off_detail
							where	write_off_code	   = @p_code
									--and is_take_assets = '1'
						) ;
										
				exec dbo.xsp_write_off_main_to_handover_asset_insert @p_code			= @p_code
																	 ,@p_agreement_no	= @agreement_no
																	 ,@p_wo_date		= @wo_date
																	 --
																	 ,@p_cre_date		= @p_mod_date
																	 ,@p_cre_by			= @p_mod_by
																	 ,@p_cre_ip_address = @p_mod_ip_address
																	 ,@p_mod_date		= @p_mod_date
																	 ,@p_mod_by			= @p_mod_by
																	 ,@p_mod_ip_address = @p_mod_ip_address

				--update	dbo.agreement_asset
				--set		asset_status	= 'TERMINATE'
				--		--
				--		,mod_date		= @p_mod_date
				--		,mod_by			= @p_mod_by
				--		,mod_ip_address	= @p_mod_ip_address
				--where	asset_no in
				--		(
				--			select	asset_no
				--			from	dbo.write_off_detail
				--			where	write_off_code	   = @p_code
				--					and is_take_assets = '0'
				--		) ;
			end
			
																		  
			update dbo.write_off_main
			set		wo_status				= 'APPROVE'
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where   code					= @p_code

			-- update lms status
			exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no	= @agreement_no
															,@p_status		= N'' 
		end

	end try
	Begin catch
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

