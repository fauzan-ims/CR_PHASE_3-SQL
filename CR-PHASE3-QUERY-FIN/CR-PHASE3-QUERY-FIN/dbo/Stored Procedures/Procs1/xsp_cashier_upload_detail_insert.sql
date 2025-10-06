CREATE PROCEDURE dbo.xsp_cashier_upload_detail_insert
(
	@p_id						 bigint = 0 output
	,@p_cashier_upload_code		 nvarchar(50)
	,@p_reff_loan_no			 nvarchar(50)
	,@p_agreement_no			 nvarchar(50)
	,@p_client_name				 nvarchar(250)
	,@p_total_installment_amount decimal(18, 2)
	,@p_total_obligation_amount	 decimal(18, 2)
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(50)
	,@p_cre_ip_address			 nvarchar(50)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(50)
	,@p_mod_ip_address			 nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into cashier_upload_detail
		(
			cashier_upload_code
			,reff_loan_no
			,agreement_no
			,client_name
			,total_installment_amount
			,total_obligation_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_cashier_upload_code
			,@p_reff_loan_no
			,@p_agreement_no
			,@p_client_name
			,@p_total_installment_amount
			,@p_total_obligation_amount
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
