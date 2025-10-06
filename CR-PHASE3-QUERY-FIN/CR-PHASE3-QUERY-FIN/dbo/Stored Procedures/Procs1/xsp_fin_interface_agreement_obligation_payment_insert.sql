CREATE PROCEDURE dbo.xsp_fin_interface_agreement_obligation_payment_insert
(
	@p_id					bigint = 0 output
	,@p_code				nvarchar(50) output
	,@p_agreement_no		nvarchar(50)
	,@p_installment_no		int
	,@p_obligation_type		nvarchar(50)
	,@p_payment_date		datetime
	,@p_value_date			datetime
	,@p_payment_source_type nvarchar(50)
	,@p_payment_source_no	nvarchar(50)
	,@p_payment_amount		decimal(18, 2)
	,@p_payment_remarks		nvarchar(4000)
	,@p_is_waive			nvarchar(1)
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
	declare @msg			nvarchar(max)
			,@year			nvarchar(2)
			,@month			nvarchar(2)
			,@code			nvarchar(50);

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'AOP'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'FIN_INTERFACE_AGREEMENT_OBLIGATION_PAYMENT'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	if @p_is_waive = 'T'
		set @p_is_waive = '1' ;
	else
		set @p_is_waive = '0' ;

	begin try
		insert into fin_interface_agreement_obligation_payment
		(
			code
			,agreement_no
			,installment_no
			,obligation_type
			,payment_date
			,value_date
			,payment_source_type
			,payment_source_no
			,payment_amount
			,payment_remarks
			,is_waive
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
			,@p_agreement_no
			,@p_installment_no
			,@p_obligation_type
			,@p_payment_date
			,@p_value_date
			,@p_payment_source_type
			,@p_payment_source_no
			,@p_payment_amount
			,@p_payment_remarks
			,@p_is_waive
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
		set @p_code = @code;
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
