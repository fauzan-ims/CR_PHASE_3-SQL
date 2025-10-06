CREATE PROCEDURE dbo.xsp_agreement_obligation_insert 
(
	@p_code				   nvarchar(50) output
	,@p_agreement_no	   nvarchar(50)
	,@p_asset_no		   nvarchar(50)
	,@p_invoice_no		   nvarchar(50)
	,@p_installment_no	   int
	,@p_obligation_day	   int
	,@p_obligation_date	   datetime
	,@p_obligation_type	   nvarchar(10)
	,@p_obligation_name	   nvarchar(250)
	,@p_obligation_reff_no nvarchar(50)
	,@p_obligation_amount  decimal(18, 2)
	,@p_remarks			   nvarchar(4000)
	--
	,@p_cre_date		   datetime
	,@p_cre_by			   nvarchar(15)
	,@p_cre_ip_address	   nvarchar(15)
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg		  nvarchar(max) 
			,@year		  nvarchar(2)
			,@month		  nvarchar(2);

	begin try

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'OPLAOB'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'AGREEMENT_OBLIGATION'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	insert into agreement_obligation
	(
		code
		,agreement_no
		,asset_no
		,invoice_no
		,installment_no
		,obligation_day
		,obligation_date
		,obligation_type
		,obligation_name
		,obligation_reff_no
		,obligation_amount
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
	(
		@p_code
		,@p_agreement_no
		,@p_asset_no
		,@p_invoice_no
		,@p_installment_no
		,@p_obligation_day
		,@p_obligation_date
		,@p_obligation_type
		,@p_obligation_name
		,@p_obligation_reff_no
		,@p_obligation_amount
		,@p_remarks
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	)

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
end




