CREATE PROCEDURE dbo.xsp_application_refund_insert
(
	@p_code				 nvarchar(50)  output
	,@p_application_no	 nvarchar(50)
	,@p_refund_code		 nvarchar(50)
	,@p_fee_code		 nvarchar(50)
	,@p_refund_rate		 decimal(9, 6)
	,@p_refund_amount	 decimal(18, 2)
	,@p_is_auto_generate nvarchar(1)   = '0'
	,@p_currency_code	 nvarchar(3)
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
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
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'ARF'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'APPLICATION_REFUND'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	if @p_is_auto_generate = 'T'
		set @p_is_auto_generate = '1' ;
	else
		set @p_is_auto_generate = '0' ;

	begin try
		insert into application_refund
		(
			code
			,application_no
			,refund_code
			,fee_code
			,refund_rate
			,refund_amount
			,is_auto_generate
			,is_valid
			,currency_code
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
			,@p_application_no
			,@p_refund_code
			,@p_fee_code
			,@p_refund_rate
			,@p_refund_amount
			,@p_is_auto_generate
			,0
			,@p_currency_code
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




