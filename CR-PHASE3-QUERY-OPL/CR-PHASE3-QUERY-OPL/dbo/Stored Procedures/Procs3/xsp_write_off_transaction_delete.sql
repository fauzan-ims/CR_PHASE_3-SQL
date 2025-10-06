CREATE PROCEDURE dbo.xsp_write_off_transaction_delete
(
	@p_wo_code		 nvarchar(50)
	,@p_agreement_no nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete dbo.agreement_amortization_history
		where	agreement_no		 = @p_agreement_no
				and transaction_code = @p_wo_code ;

		delete dbo.agreement_amortization_payment_history
		where	agreement_no		 = @p_agreement_no
				and transaction_code = @p_wo_code ;

		delete write_off_transaction
		where	wo_code = @p_wo_code ;
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

