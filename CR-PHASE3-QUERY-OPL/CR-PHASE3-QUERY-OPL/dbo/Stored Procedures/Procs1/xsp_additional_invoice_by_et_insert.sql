CREATE PROCEDURE dbo.xsp_additional_invoice_by_et_insert
(
	@p_code			   nvarchar(50) output
	,@p_et_code		   nvarchar(50) 
	,@p_invoice_type   nvarchar(10)
	,@p_invoice_date   datetime
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
	declare @code					nvarchar(50)
			,@year					nvarchar(4)
			,@month					nvarchar(2)
			,@msg					nvarchar(max)
			,@invoice_name			nvarchar(250)
			,@invoice_status		nvarchar(10)   = 'HOLD'
			,@client_no				nvarchar(50)
			,@client_name			nvarchar(250)
			,@client_address		nvarchar(4000)
			,@client_area_phone_no	nvarchar(4)
			,@client_phone_no		nvarchar(15)
			,@client_npwp			nvarchar(50)   = ''
			,@currency_code			nvarchar(3)	   = ''
			,@total_billing_amount	decimal(18, 2) = 0
			,@total_discount_amount decimal(18, 2) = 0
			,@total_ppn_amount		int
			,@total_pph_amount		int
			,@total_amount			decimal(18, 2) = 0
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250) ;

	begin try

		select	@invoice_name = 'Invoice ET for Agreement : ' + am.agreement_no
				,@branch_code = em.branch_code
				,@branch_name = em.branch_name
				,@currency_code = am.currency_code
				,@client_no = am.client_no
				,@client_name = am.client_name
				,@client_area_phone_no = isnull(cci.area_mobile_no, cpi.area_mobile_no)
				,@client_phone_no = isnull(cci.mobile_no, cpi.mobile_no)
				,@client_address = ca.address
		from	dbo.agreement_main am
				inner join dbo.et_main em on (em.agreement_no				= am.agreement_no)
				inner join dbo.client_main cm on (cm.client_no				= am.client_no)
				left join dbo.client_personal_info cpi on (cpi.client_code	= cm.code)
				left join dbo.client_corporate_info cci on (cci.client_code = cm.code)
				left join dbo.client_address ca on (ca.client_code			= cm.code)
		where	em.code = @p_et_code ;

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = @branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = N'ADN'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = N'ADDITIONAL_INVOICE'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		insert into additional_invoice
		(
			code
			,invoice_type
			,invoice_date
			,invoice_due_date
			,invoice_name
			,invoice_status
			,client_no
			,client_name
			,client_address
			,client_area_phone_no
			,client_phone_no
			,client_npwp
			,currency_code
			,total_billing_amount
			,total_discount_amount
			,total_ppn_amount
			,total_pph_amount
			,total_amount
			,branch_code
			,branch_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_invoice_type
			,@p_invoice_date
			,null
			,@invoice_name
			,@invoice_status
			,@client_no
			,@client_name
			,@client_address
			,@client_area_phone_no
			,@client_phone_no
			,@client_npwp
			,@currency_code
			,@total_billing_amount
			,@total_discount_amount
			,@total_ppn_amount
			,@total_pph_amount
			,@total_amount
			,@branch_code
			,@branch_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;		

		set @p_code = @code ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

