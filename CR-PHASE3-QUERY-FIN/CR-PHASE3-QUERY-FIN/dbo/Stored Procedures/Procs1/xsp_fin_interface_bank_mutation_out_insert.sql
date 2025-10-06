CREATE PROCEDURE dbo.xsp_fin_interface_bank_mutation_out_insert
(
	@p_id								int
	,@p_branch_code						nvarchar(50)
	,@p_branch_name						nvarchar(250)
	,@p_branch_bank_code				nchar(10)
	,@p_branch_bank_name				nchar(10)
	,@p_gl_link_code					nvarchar(50)
	,@p_transaction_date				datetime
	,@p_value_date						datetime
	,@p_reff_code						nvarchar(50)
	,@p_reff_name						nvarchar(250)
	,@p_orig_amount						decimal(18,2)
	,@p_orig_currency_code				nvarchar(3)
	,@p_exch_rate						decimal(18,2)
	,@p_base_amount						decimal(18,2)
	,@p_remarks							nvarchar(4000)
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.fin_interface_bank_mutation_out
		(
		    branch_code
		    ,branch_name
		    ,branch_bank_code
		    ,branch_bank_name
		    ,gl_link_code
		    ,transaction_date
		    ,value_date
		    ,reff_code
		    ,reff_name
		    ,orig_amount
		    ,orig_currency_code
		    ,exch_rate
		    ,base_amount
			,remarks
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		values
		(  
			@p_branch_code				
			,@p_branch_name				
			,@p_branch_bank_code		
			,@p_branch_bank_name		
			,@p_gl_link_code			
			,@p_transaction_date		
			,@p_value_date				
			,@p_reff_code				
			,@p_reff_name				
			,@p_orig_amount				
			,@p_orig_currency_code		
			,@p_exch_rate				
			,@p_base_amount	
			,@p_remarks			
			,@p_cre_date				
			,@p_cre_by					
			,@p_cre_ip_address			
			,@p_mod_date				
			,@p_mod_by					
			,@p_mod_ip_address			
		)
		
		set @p_id = @@identity ;
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
