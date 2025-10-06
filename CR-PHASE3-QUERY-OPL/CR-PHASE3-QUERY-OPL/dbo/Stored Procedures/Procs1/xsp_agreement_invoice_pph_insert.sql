CREATE PROCEDURE dbo.xsp_agreement_invoice_pph_insert
(
	@p_code					 nvarchar(50) output
	,@p_invoice_no			 nvarchar(50)
	,@p_agreement_no		 nvarchar(50)
	,@p_asset_no			 nvarchar(50)
	,@p_billing_no			 int
	,@p_due_date			 datetime
	,@p_invoice_date		 datetime
	,@p_pph_amount			 decimal(18,2)
	,@p_description			 nvarchar(4000)
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin

	declare @code			nvarchar(50)
			,@year			nvarchar(4)
			,@month			nvarchar(2)
			,@msg			nvarchar(max) ;

	begin try
	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = N'AIPH'
												,@p_year = @year 
												,@p_month = @month 
												,@p_table_name = N'AGREEMENT_INVOICE_PPH' 
												,@p_run_number_length = 6 
												,@p_delimiter = '.'
												,@p_run_number_only = N'0'

		insert into dbo.agreement_invoice_pph
		(
			code
			,invoice_no
			,agreement_no
			,asset_no
			,billing_no
			,due_date
			,invoice_date
			,pph_amount
			,description
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
			@code
			,@p_invoice_no
			,@p_agreement_no
			,@p_asset_no
			,@p_billing_no
			,@p_due_date
			,@p_invoice_date
			,@p_pph_amount
			,@p_description
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_code = @code ;

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
