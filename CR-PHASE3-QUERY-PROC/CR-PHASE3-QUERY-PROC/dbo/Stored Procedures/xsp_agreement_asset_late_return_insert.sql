CREATE PROCEDURE [dbo].[xsp_agreement_asset_late_return_insert]
(
	@p_code					 nvarchar(50) output
	,@p_agreement_no		 nvarchar(50)
	,@p_asset_no			 nvarchar(50)
	,@p_branch_code			 nvarchar(50)
	,@p_branch_name			 nvarchar(250)
	,@p_currency_code		 nvarchar(3)
	,@p_os_obligation_amount decimal(18,2)
	,@p_maturity_date		 datetime
	,@p_bast_date			 datetime
	,@p_payment_status		 nvarchar(50)
	,@p_late_return_days	 int	
	,@p_invoice_no			 nvarchar(50)
	,@p_credit_note_no		 nvarchar(50)
	,@p_waive_no			 nvarchar(50)
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
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'ASTLR'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'AGREEMENT_ASSET_LATE_RETURN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		insert into dbo.agreement_asset_late_return
		(
		    code,
		    agreement_no,
		    asset_no,
		    branch_code,
		    branch_name,
		    currency_code,
		    os_obligation_amount,
		    maturity_date,
		    bast_date,
		    payment_status,
		    late_return_days,
		    invoice_no,
		    credit_note_no,
		    waive_no,
		    cre_date,
		    cre_by,
		    cre_ip_address,
		    mod_date,
		    mod_by,
		    mod_ip_address
		)
		values
		(   @code
		    ,@p_agreement_no
		    ,@p_asset_no
		    ,@p_branch_code
		    ,@p_branch_name
		    ,@p_currency_code
		    ,@p_os_obligation_amount
		    ,@p_maturity_date
		    ,@p_bast_date
		    ,@p_payment_status
		    ,@p_late_return_days
		    ,@p_invoice_no
		    ,@p_credit_note_no
		    ,@p_waive_no
		    ,@p_cre_date
		    ,@p_cre_by
		    ,@p_cre_ip_address
		    ,@p_mod_date
		    ,@p_mod_by
		    ,@p_mod_ip_address
		    );

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
