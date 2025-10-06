CREATE PROCEDURE dbo.xsp_xxxxjournal_gl_link_transaction_insert
(
	@p_id					   bigint = 0 output
	,@p_branch_code			   nvarchar(50)
	,@p_branch_name			   nvarchar(250)
	,@p_transaction_status	   nvarchar(10)
	,@p_transaction_date	   datetime
	,@p_transaction_value_date datetime
	,@p_transaction_code	   nvarchar(50)
	,@p_transaction_name	   nvarchar(250)
	,@p_reff_module_code	   nvarchar(10)
	,@p_reff_source_no		   nvarchar(50)
	,@p_reff_source_name	   nvarchar(250)
	,@p_gl_link_code		   nvarchar(50)
	,@p_contra_gl_link_code	   nvarchar(50)
	,@p_agreement_no		   nvarchar(50)
	,@p_orig_currency_code	   nvarchar(3)
	,@p_orig_amount_db		   decimal(18, 2)
	,@p_orig_amount_cr		   decimal(18, 2)
	,@p_exch_rate			   decimal(18, 6)
	,@p_base_amount_db		   decimal(18, 2)
	,@p_base_amount_cr		   decimal(18, 2)
	,@p_division_code		   nvarchar(50)
	,@p_division_name		   nvarchar(250)
	,@p_department_code		   nvarchar(50)
	,@p_department_name		   nvarchar(250)
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into xxxxjournal_gl_link_transaction
		(
			branch_code
			,branch_name
			,transaction_status
			,transaction_date
			,transaction_value_date
			,transaction_code
			,transaction_name
			,reff_module_code
			,reff_source_no
			,reff_source_name
			,gl_link_code
			,contra_gl_link_code
			,agreement_no
			,orig_currency_code
			,orig_amount_db
			,orig_amount_cr
			,exch_rate
			,base_amount_db
			,base_amount_cr
			,division_code
			,division_name
			,department_code
			,department_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_branch_code
			,@p_branch_name
			,@p_transaction_status
			,@p_transaction_date
			,@p_transaction_value_date
			,@p_transaction_code
			,@p_transaction_name
			,@p_reff_module_code
			,@p_reff_source_no
			,@p_reff_source_name
			,@p_gl_link_code
			,@p_contra_gl_link_code
			,@p_agreement_no
			,@p_orig_currency_code
			,@p_orig_amount_db
			,@p_orig_amount_cr
			,@p_exch_rate
			,@p_base_amount_db
			,@p_base_amount_cr
			,@p_division_code
			,@p_division_name
			,@p_department_code
			,@p_department_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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
