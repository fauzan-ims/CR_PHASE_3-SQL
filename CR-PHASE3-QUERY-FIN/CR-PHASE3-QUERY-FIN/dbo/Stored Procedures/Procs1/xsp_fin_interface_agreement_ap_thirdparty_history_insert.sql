CREATE PROCEDURE dbo.xsp_fin_interface_agreement_ap_thirdparty_history_insert
(
	@p_id					bigint
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_refF_code			nvarchar(50)
	,@p_reff_name			nvarchar(250)
	,@p_ap_type				nvarchar(50)
	,@p_ap_thirdparty_code  nvarchar(50)
	,@p_agreement_no		nvarchar(50)
	,@p_transaction_date	datetime
	,@p_orig_amount			decimal(18, 2)
	,@p_orig_currency_code  nvarchar(3)
	,@p_exch_rate			decimal(18, 6)
	,@p_base_amount			decimal(18, 2)
	,@p_source_reff_module	nvarchar(50)
	,@p_source_reff_no		nvarchar(50)
	,@p_source_reff_remarks nvarchar(4000)
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
	declare @msg			  nvarchar(max);

	begin try
		insert into dbo.fin_interface_agreement_ap_thirdparty_history
		(
		    branch_code,
		    branch_name,
		    reff_code,
			reff_name,
		    ap_type,
		    ap_thirdparty_code,
		    agreement_no,
		    transaction_date,
		    orig_amount,
		    orig_currency_code,
		    exch_rate,
		    base_amount,
		    source_reff_module,
		    source_reff_no,
		    source_reff_remarks,
		    cre_date,
		    cre_by,
		    cre_ip_address,
		    mod_date,
		    mod_by,
		    mod_ip_address
		)
		values
		(	@p_branch_code			
			,@p_branch_name			
			,@p_reff_code	
			,@p_reff_name		
			,@p_ap_type				
			,@p_ap_thirdparty_code 
			,@p_agreement_no
			,@p_transaction_date	
			,@p_orig_amount			
			,@p_orig_currency_code 
			,@p_exch_rate			
			,@p_base_amount			
			,@p_source_reff_module	
			,@p_source_reff_no		
			,@p_source_reff_remarks
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






