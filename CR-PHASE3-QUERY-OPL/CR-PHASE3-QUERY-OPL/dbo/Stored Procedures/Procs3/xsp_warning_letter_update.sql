CREATE PROCEDURE dbo.xsp_warning_letter_update
(
	@p_code							    nvarchar(50)
	,@p_letter_date					    datetime 
	--,@p_agreement_no					nvarchar(50)
	,@p_branch_code						nvarchar(50)
	,@p_branch_name						nvarchar(250)
	--
	,@p_mod_date					   datetime
	,@p_mod_by						   nvarchar(15)
	,@p_mod_ip_address				   nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@installment_amount				decimal(18, 2)
			,@overdue_days						int
			,@overdue_penalty_amount			decimal(18, 2)
			,@overdue_installment_amount		decimal(18, 2)
			,@agreement_no						NVARCHAR(50)

	begin try
		SELECT @agreement_no = MAX(AGREEMENT_MAIN.AGREEMENT_NO)
		FROM dbo.WARNING_LETTER
			JOIN dbo.AGREEMENT_MAIN
				ON AGREEMENT_MAIN.CLIENT_NO = WARNING_LETTER.CLIENT_NO
		WHERE CODE = @p_code;
		if (@p_letter_date > dbo.xfn_get_system_date())
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date') ;

			raiserror(@msg, 16, -1) ;
		END

		 --overdue_days
		set	@overdue_days = dbo.xfn_agreement_get_ovd_days(@agreement_no)

		--installment_amount
		select	@installment_amount = billing_amount
		from	dbo.agreement_asset_amortization aam 
		where	aam.agreement_no = @agreement_no
		and		aam.billing_no = '1'
		
		set	@overdue_penalty_amount = dbo.xfn_agreement_get_ovd_penalty(@agreement_no, dbo.xfn_get_system_date()) --overdue_penalty_amount
		set @overdue_installment_amount = dbo.xfn_agreement_get_ol_ar(@agreement_no, dbo.xfn_get_system_date()) ; -- overdue_installment_amount

		update	warning_letter
		set		letter_date						= @p_letter_date 
				,agreement_no					= @agreement_no
				,branch_code					= @p_branch_code
				,branch_name					= @p_branch_name
				,max_print_count				= 1
				,print_count					= 0
				,installment_amount				= @installment_amount 
				,overdue_days					= @overdue_days
				,overdue_penalty_amount			= @overdue_penalty_amount
				,overdue_installment_amount		= @overdue_installment_amount 
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	code							= @p_code ;
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
