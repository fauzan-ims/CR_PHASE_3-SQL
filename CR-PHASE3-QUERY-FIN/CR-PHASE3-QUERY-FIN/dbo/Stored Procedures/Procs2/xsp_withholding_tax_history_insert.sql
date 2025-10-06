CREATE procedure dbo.xsp_withholding_tax_history_insert
(
	@p_id					bigint = 0 output
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_payment_date		datetime
	,@p_payment_amount		decimal(18, 2)
	,@p_tax_payer_reff_code nvarchar(50)
	,@p_tax_type			nvarchar(5)
	,@p_tax_file_no			nvarchar(50)
	,@p_tax_file_name		nvarchar(250)
	,@p_tax_pct				decimal(9, 6)
	,@p_tax_amount			decimal(18, 2)
	,@p_reff_no				nvarchar(50)
	,@p_reff_name			nvarchar(250)
	,@p_remark				nvarchar(4000)
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
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.withholding_tax_history
		(
			branch_code
			,branch_name
			,payment_date
			,payment_amount
			,tax_payer_reff_code
			,tax_type
			,tax_file_no
			,tax_file_name
			,tax_pct
			,tax_amount
			,reff_no
			,reff_name
			,remark
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_branch_code
			,@p_branch_name
			,@p_payment_date
			,@p_payment_amount
			,@p_tax_payer_reff_code
			,@p_tax_type
			,isnull(@p_tax_file_no, '')
			,@p_tax_file_name
			,@p_tax_pct
			,@p_tax_amount
			,@p_reff_no
			,@p_reff_name
			,@p_remark
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
