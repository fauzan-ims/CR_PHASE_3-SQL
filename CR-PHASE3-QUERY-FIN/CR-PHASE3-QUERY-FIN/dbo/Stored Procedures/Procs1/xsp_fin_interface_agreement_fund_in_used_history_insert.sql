CREATE PROCEDURE dbo.xsp_fin_interface_agreement_fund_in_used_history_insert
(
	@p_agreement_no			nvarchar(50)
	,@p_charges_date		datetime
	,@p_charges_type		nvarchar(50)
	,@p_transaction_no		nvarchar(50)
	,@p_transaction_name	nvarchar(250)
	,@p_charges_amount		decimal(18, 2)
	,@p_source_reff_module  nvarchar(50)
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
	declare @msg					nvarchar(max);

	begin try

		insert into dbo.fin_interface_agreement_fund_in_used_history
		(
		    agreement_no,
		    charges_date,
		    charges_type,
		    transaction_no,
		    transaction_name,
		    charges_amount,
		    source_reff_module,
		    source_reff_remarks,
		    cre_date,
		    cre_by,
		    cre_ip_address,
		    mod_date,
		    mod_by,
		    mod_ip_address
		)
		values
		(	@p_agreement_no			
			,@p_charges_date		
			,@p_charges_type		
			,@p_transaction_no		
			,@p_transaction_name	
			,@p_charges_amount		
			,@p_source_reff_module  
			,@p_source_reff_remarks 
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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
