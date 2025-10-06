/*
	alterd : Windy, 24 April 2020
*/
CREATE PROCEDURE dbo.xsp_claim_main_reversal
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
			,@claim_progress_code		nvarchar(20)
			,@claim_remark				nvarchar(400)


	select	@branch_code				= cm.branch_code
			,@branch_name				= cm.branch_name
			,@deposit_type				= cm.claim_loss_type
			,@deposit_currency_code		= ipm.currency_code
			,@deposit_amount			= cm.claim_amount * -1
			--,@deposit_date				= loss_date
			,@deposit_reff_no			= cm.claim_reff_external_no
			,@deposit_remarks			= cm.claim_remarks	
			,@claim_progress_code		= claim_loss_type
	from	dbo.claim_main cm
			inner join dbo.claim_request ir on  cm.claim_request_code = ir.code
			inner join dbo.insurance_policy_main ipm on ir.policy_code = ipm.code 
	where	cm.code						= @p_code

	begin try
		if exists (select 1 from dbo.claim_main where code = @p_code and claim_status = 'HOLD' or CLAIM_STATUS = 'APPROVED')
		begin

			update	dbo.claim_main
			set		claim_status	= 'REVERSED'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code
			
			exec dbo.xsp_claim_progress_insert @p_id						= 0        
				                               ,@p_claim_code				= @p_code                 
				                               ,@p_claim_progress_code		= @claim_progress_code                 
				                               ,@p_claim_progress_date		= @p_cre_date
				                               ,@p_claim_progress_remarks	= @deposit_remarks                 
				                               ,@p_cre_date					= @p_cre_date		
				                               ,@p_cre_by					= @p_cre_by			
				                               ,@p_cre_ip_address			= @p_cre_ip_address
				                               ,@p_mod_date					= @p_mod_date		
				                               ,@p_mod_by					= @p_mod_by			
				                               ,@p_mod_ip_address			= @p_mod_ip_address

		end
		else
		begin
		    raiserror('Data already proceed',16,1)
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

