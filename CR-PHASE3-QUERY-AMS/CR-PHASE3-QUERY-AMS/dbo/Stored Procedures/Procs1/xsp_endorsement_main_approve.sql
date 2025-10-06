CREATE PROCEDURE dbo.xsp_endorsement_main_approve 
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@currency_code					nvarchar(50)
			,@endorsement_date				datetime
			,@endorsement_received_amount	decimal(18, 2)
			,@endorsement_payment_amount	decimal(18, 2)
			,@endorsement_remarks			nvarchar(4000)
			,@fa_code						nvarchar(50)
			,@policy_code					nvarchar(50)
			,@insured_name					nvarchar(250)
			,@insured_qq_name				nvarchar(250)
			,@object_name					nvarchar(250)
			,@policy_eff_date				datetime
			,@policy_exp_date				datetime
			,@cashier_received_request_code nvarchar(50)
			,@gl_link_code					nvarchar(50)
			,@sp_name						nvarchar(250)
			,@debet_or_credit				nvarchar(10)
			,@orig_amount_db				decimal(18, 2)
			,@return_value					decimal(18, 2)

	begin try
		select @branch_code						= em.branch_code					
			   ,@branch_name					= em.branch_name					
			   ,@currency_code					= em.currency_code					
			   ,@endorsement_date				= endorsement_date				
			   ,@endorsement_received_amount	= endorsement_received_amount
			   ,@endorsement_payment_amount		= em.endorsement_payment_amount
			   ,@endorsement_remarks			= 'Endorsement received no ' + em.code + ', for Client No ' + ipm.fa_code + ' - ' + aa.item_name	
			   ,@policy_code					= em.policy_code  
			   ,@fa_code						= ipm.fa_code
		from   dbo.endorsement_main em
			   inner join dbo.insurance_policy_main ipm on (ipm.code = em.policy_code)
			   inner join dbo.asset aa on (aa.code =ipm.fa_code)
			   inner join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
        where  em.code = @p_code

		select	@insured_name	 = insured_name 
			   ,@insured_qq_name = insured_qq_name
			   ,@object_name     = object_name
			   ,@policy_eff_date = eff_date
			   ,@policy_exp_date = exp_date
		from   dbo.endorsement_detail
        where  endorsement_code = @p_code and old_or_new = 'NEW'
	
		if exists (select 1 from dbo.endorsement_main where code = @p_code and endorsement_status = 'ON PROCESS')
		begin
		    update	dbo.endorsement_main 
			set		endorsement_status	= 'APPROVE'
					--
					,mod_date			= @p_mod_date		
					,mod_by				= @p_mod_by			
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code

			exec dbo.xsp_insurance_policy_main_history_insert @p_id					= 0,          
																@p_policy_code		= @policy_code,          
																@p_history_date		= @p_mod_date,
																@p_history_type		= 'ENDORSEMENT APPROVE',    
																@p_policy_status	= 'ACTIVE',              
																@p_history_remarks	= 'ENDORSEMENT APPROVE',    
																@p_cre_date			= @p_mod_date,
																@p_cre_by			= @p_mod_by,
																@p_cre_ip_address	= @p_mod_ip_address,
																@p_mod_date			= @p_mod_date,
																@p_mod_by			= @p_mod_by,
																@p_mod_ip_address	= @p_mod_ip_address

			if @endorsement_received_amount = 0 and @endorsement_payment_amount = 0
			begin
				update dbo.insurance_policy_main
				set    insured_name			  = @insured_name
					   ,insured_qq_name		  = @insured_qq_name
					   ,object_name			  = @object_name
					   ,policy_eff_date		  = @policy_eff_date
					   ,policy_exp_date		  = @policy_exp_date
					   ,policy_process_status = null
				where code					  = @policy_code
			end
			else
            begin	
				exec dbo.xsp_endorsement_main_payment_request @p_code				= @p_code
															  --
															  ,@p_cre_date			= @p_mod_date
															  ,@p_cre_by			= @p_mod_by
															  ,@p_cre_ip_address	= @p_mod_ip_address
															  ,@p_mod_date			= @p_mod_date
															  ,@p_mod_by			= @p_mod_by
															  ,@p_mod_ip_address	= @p_mod_ip_address
			end
		end
        else
		begin
		    raiserror('Error data already proceed',16,1) ;
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
