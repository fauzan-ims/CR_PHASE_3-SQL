create procedure xsp_ifinams_interface_additional_request_insert
(
	@p_id					 bigint = 0 output
	,@p_agreement_no		 nvarchar(50)
	,@p_asset_no			 nvarchar(50)
	,@p_branch_code			 nvarchar(50)
	,@p_branch_name			 nvarchar(250)
	,@p_invoice_type		 nvarchar(10)
	,@p_invoice_date		 datetime
	,@p_invoice_name		 nvarchar(250)
	,@p_client_no			 nvarchar(50)
	,@p_client_name			 nvarchar(250)
	,@p_client_address		 nvarchar(4000)
	,@p_client_area_phone_no nvarchar(4)
	,@p_client_phone_no		 nvarchar(15)
	,@p_client_npwp			 nvarchar(50)
	,@p_currency_code		 nvarchar(3)
	,@p_tax_scheme_code		 nvarchar(50)
	,@p_tax_scheme_name		 nvarchar(250)
	,@p_billing_no			 int
	,@p_description			 nvarchar(4000)
	,@p_quantity			 int
	,@p_billing_amount		 decimal(18, 2)
	,@p_discount_amount		 decimal(18, 2)
	,@p_ppn_pct				 decimal(9, 6)
	,@p_ppn_amount			 decimal(18, 2)
	,@p_pph_pct				 decimal(9, 6)
	,@p_pph_amount			 decimal(18, 2)
	,@p_total_amount		 decimal(18, 2)
	,@p_request_status		 nvarchar(10)
	,@p_reff_code			 nvarchar(50)
	,@p_reff_name			 nvarchar(250)
	,@p_settle_date			 datetime
	,@p_job_status			 nvarchar(10)
	,@p_failed_remarks		 nvarchar(4000)
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into ifinams_interface_additional_request
		(
			agreement_no
			,asset_no
			,branch_code
			,branch_name
			,invoice_type
			,invoice_date
			,invoice_name
			,client_no
			,client_name
			,client_address
			,client_area_phone_no
			,client_phone_no
			,client_npwp
			,currency_code
			,tax_scheme_code
			,tax_scheme_name
			,billing_no
			,description
			,quantity
			,billing_amount
			,discount_amount
			,ppn_pct
			,ppn_amount
			,pph_pct
			,pph_amount
			,total_amount
			,request_status
			,reff_code
			,reff_name
			,settle_date
			,job_status
			,failed_remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_agreement_no
			,@p_asset_no
			,@p_branch_code
			,@p_branch_name
			,@p_invoice_type
			,@p_invoice_date
			,@p_invoice_name
			,@p_client_no
			,@p_client_name
			,@p_client_address
			,@p_client_area_phone_no
			,@p_client_phone_no
			,@p_client_npwp
			,@p_currency_code
			,@p_tax_scheme_code
			,@p_tax_scheme_name
			,@p_billing_no
			,@p_description
			,@p_quantity
			,@p_billing_amount
			,@p_discount_amount
			,@p_ppn_pct
			,@p_ppn_amount
			,@p_pph_pct
			,@p_pph_amount
			,@p_total_amount
			,@p_request_status
			,@p_reff_code
			,@p_reff_name
			,@p_settle_date
			,@p_job_status
			,@p_failed_remarks
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
