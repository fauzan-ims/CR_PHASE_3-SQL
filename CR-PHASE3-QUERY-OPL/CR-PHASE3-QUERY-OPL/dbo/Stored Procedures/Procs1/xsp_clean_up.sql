CREATE PROCEDURE dbo.xsp_clean_up
as
begin
	declare @msg nvarchar(max) ;

	begin try


		truncate table AGREEMENT_ASSET_REPLACEMENT_HISTORY
		truncate table AGREEMENT_ASSET_AMORTIZATION
		delete AGREEMENT_ASSET

		truncate table AGREEMENT_DEPOSIT_MAIN
		truncate table AGREEMENT_OBLIGATION
		truncate table AGREEMENT_OBLIGATION_PAYMENT
		delete AGREEMENT_MAIN

		truncate table FAKTUR_MAIN

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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




