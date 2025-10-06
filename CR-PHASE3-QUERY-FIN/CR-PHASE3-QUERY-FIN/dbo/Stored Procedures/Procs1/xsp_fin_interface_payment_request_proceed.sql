/*
	created: Fadlan, 27 Mei 2021
*/
CREATE PROCEDURE dbo.xsp_fin_interface_payment_request_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.payment_request
		(
			code
			,branch_code
			,branch_name
			,payment_branch_code
			,payment_branch_name
			,payment_source
			,payment_request_date
			,payment_source_no
			,payment_status
			,payment_currency_code
			,payment_amount
			,payment_remarks
			,to_bank_name
			,to_bank_account_name
			,to_bank_account_no
			,payment_transaction_code
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	code
				,branch_code
				,branch_name
				,payment_branch_code
				,payment_branch_name
				,payment_source
				,payment_request_date
				,payment_source_no
				,payment_status
				,payment_currency_code
				,payment_amount
				,payment_remarks
				,to_bank_name
				,to_bank_account_name
				,to_bank_account_no
				,''
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.fin_interface_payment_request
		where	code = @p_code ;

		insert into dbo.payment_request_detail
		(
			payment_request_code
			,branch_code
			,branch_name
			,gl_link_code
			,agreement_no
			,facility_code
			,facility_name
			,purpose_loan_code
			,purpose_loan_name
			,purpose_loan_detail_code
			,purpose_loan_detail_name
			,orig_currency_code
			,orig_amount
			,division_code
			,division_name
			,department_code
			,department_name
			,remarks
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	fiprd.payment_request_code
				,fiprd.branch_code
				,fiprd.branch_name
				,fiprd.gl_link_code
				,fiprd.agreement_no
				,fiprd.facility_code
				,fiprd.facility_name
				,fiprd.purpose_loan_code
				,fiprd.purpose_loan_name
				,fiprd.purpose_loan_detail_code
				,fiprd.purpose_loan_detail_name
				,fiprd.orig_currency_code
				,fiprd.orig_amount
				,fiprd.division_code
				,fiprd.division_name
				,fiprd.department_code
				,fiprd.department_name
				,remarks
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.fin_interface_payment_request_detail fiprd
		where	fiprd.payment_request_code = @p_code ;

		update	dbo.fin_interface_payment_request
		set		job_status = 'POST'
				,failed_remarks = null
		where	code = @p_code ;
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
