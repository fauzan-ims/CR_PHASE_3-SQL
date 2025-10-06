CREATE PROCEDURE [dbo].[xsp_claim_main_paid]
(		
	@p_code					nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@agreement_no				nvarchar(50)
			,@deposit_type				nvarchar(15)
			,@deposit_currency_code		nvarchar(3)
			,@deposit_amount			decimal(18, 2)
			,@deposit_date				datetime
			,@deposit_reff_no			nvarchar(250)
			,@deposit_remarks			nvarchar(4000)
			,@policy_code				nvarchar(50)
			,@claim_progress_code		nvarchar(20)
			,@is_policy_terminate		nvarchar(1)
			,@claim_remark				nvarchar(400)
			,@received_request_code		nvarchar(50)
			,@deposit_main_code			nvarchar(50)
			,@plafond_no				nvarchar(50)
			,@policy_no					nvarchar(50)
			,@remark					nvarchar(4000)
			,@date						datetime = dbo.xfn_get_system_date()


	select	@branch_code				= cm.branch_code
			,@branch_name				= cm.branch_name 
			,@deposit_type				= cm.claim_loss_type
			,@deposit_currency_code		= ipm.currency_code
			,@deposit_amount			= cm.claim_amount
			,@deposit_remarks			= cm.claim_remarks	
			,@policy_code				= ipm.code
			,@policy_no					= ipm.policy_no
			,@claim_progress_code		= claim_loss_type
			,@is_policy_terminate		= cm.is_policy_terminate 
	from	dbo.claim_main cm
			inner join dbo.insurance_policy_main ipm on cm.policy_code = ipm.code 
	where	cm.code						= @p_code

	--select @received_request_code = code
	--from dbo.efam_interface_received_request
	--where received_source_no = @p_code

	begin try
		if exists (select 1 from dbo.claim_main where code = @p_code and claim_status = 'APPROVE')
		begin

			update	dbo.claim_main
			set		claim_status = 'PAID'
			        --,received_request_code = @received_request_code
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code

			update	dbo.insurance_policy_main
			set		policy_process_status = NULL
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @policy_code

			set @remark = 'Claim for ' + @plafond_no + @agreement_no + ' Policy Insurance from Policy No : ' + @policy_no
			                                     
			exec dbo.xsp_claim_progress_insert @p_id						= 0        
				                               ,@p_claim_code				= @p_code                 
				                               ,@p_claim_progress_code		= 'CLAIM PAID'                 
				                               ,@p_claim_progress_date		= @date
				                               ,@p_claim_progress_remarks	= @deposit_remarks                 
				                               ,@p_cre_date					= @p_cre_date		
				                               ,@p_cre_by					= @p_cre_by			
				                               ,@p_cre_ip_address			= @p_cre_ip_address
				                               ,@p_mod_date					= @p_mod_date		
				                               ,@p_mod_by					= @p_mod_by			
				                               ,@p_mod_ip_address			= @p_mod_ip_address

			
			-- update status asset menjadi claim
			update	dbo.insurance_policy_asset
			set		status_asset = 'CLAIM'
			where	code in
					(
						select	policy_asset_code
						from	dbo.claim_detail_asset
						where	claim_code = @p_code
					) ;
			exec dbo.xsp_insurance_policy_main_history_insert @p_id					= 0         
			                                                  ,@p_policy_code		= @policy_code                  
			                                                  ,@p_history_date		= @p_cre_date
			                                                  ,@p_history_type		= 'CLAIM PAID'                  
			                                                  ,@p_policy_status		= 'CLAIM'                  
			                                                  ,@p_history_remarks	= ''                 
			                                                  ,@p_cre_date			= @p_cre_date	
															  ,@p_cre_by			= @p_cre_by			
															  ,@p_cre_ip_address	= @p_cre_ip_address
															  ,@p_mod_date			= @p_mod_date		
															  ,@p_mod_by			= @p_mod_by			
															  ,@p_mod_ip_address	= @p_mod_ip_address
		end
		else
		begin
			set @msg = 'Data Already Proceed'
		    raiserror(@msg, 16, -1)
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

