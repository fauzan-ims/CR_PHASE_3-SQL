CREATE PROCEDURE dbo.xsp_bank_mutation_history_insert
(
	@p_id					bigint = 0 output
	,@p_bank_mutation_code	nvarchar(50)
	,@p_transaction_date	datetime
	,@p_value_date			datetime
	,@p_source_reff_code	nvarchar(50)
	,@p_source_reff_name	nvarchar(250)
	,@p_orig_amount			decimal(18, 2)
	,@p_orig_currency_code	nvarchar(3)
	,@p_exch_rate			decimal(18, 6)
	,@p_base_amount			decimal(18, 2)
	,@p_remarks				nvarchar(4000)
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
	declare @msg					nvarchar(max) 
			,@gl_link_code			nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@branch_bank_code		nvarchar(50)
			,@branch_bank_name		nvarchar(250)

	begin try
		insert into bank_mutation_history
		(
			bank_mutation_code
			,transaction_date
			,value_date
			,source_reff_code
			,source_reff_name
			,orig_amount
			,orig_currency_code
			,exch_rate
			,base_amount
			,is_reconcile
			,remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_bank_mutation_code
			,@p_transaction_date
			,@p_value_date
			,@p_source_reff_code
			,@p_source_reff_name
			,@p_orig_amount
			,@p_orig_currency_code
			,@p_exch_rate
			,@p_base_amount
			,'0'
			,@p_remarks
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
		--

		select	@branch_code			= branch_code
				,@branch_name			= branch_name
				,@branch_bank_code		= branch_bank_code
				,@branch_bank_name		= branch_bank_name
				,@gl_link_code			= gl_link_code
		from	dbo.bank_mutation
		where	code = @p_bank_mutation_code

		exec dbo.xsp_fin_interface_bank_mutation_out_insert @p_id					= 0				
		                                                    ,@p_branch_code			= @branch_code		
		                                                    ,@p_branch_name			= @branch_name		
		                                                    ,@p_branch_bank_code	= @branch_bank_code			
		                                                    ,@p_branch_bank_name	= @branch_bank_name			
		                                                    ,@p_gl_link_code		= @gl_link_code		
		                                                    ,@p_transaction_date	= @p_transaction_date			
		                                                    ,@p_value_date			= @p_value_date			
		                                                    ,@p_reff_code			= @p_source_reff_code			
		                                                    ,@p_reff_name			= @p_source_reff_name			
		                                                    ,@p_orig_amount			= @p_orig_amount			
		                                                    ,@p_orig_currency_code	= @p_orig_currency_code			
		                                                    ,@p_exch_rate			= @p_exch_rate			
		                                                    ,@p_base_amount			= @p_base_amount
															,@p_remarks				= @p_remarks			
		                                                    ,@p_cre_date			= @p_cre_date			
		                                                    ,@p_cre_by				= @p_cre_by			
		                                                    ,@p_cre_ip_address		= @p_cre_ip_address			
		                                                    ,@p_mod_date			= @p_mod_date			
		                                                    ,@p_mod_by				= @p_mod_by			
		                                                    ,@p_mod_ip_address		= @p_mod_ip_address			

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

