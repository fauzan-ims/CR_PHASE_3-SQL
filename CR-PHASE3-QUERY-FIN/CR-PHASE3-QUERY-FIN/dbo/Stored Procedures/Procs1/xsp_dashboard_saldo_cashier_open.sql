CREATE PROCEDURE dbo.xsp_dashboard_saldo_cashier_open
--(
--	@p_year nvarchar(4)
--)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		select		top 5 sum(CASHIER_CLOSE_AMOUNT) 'total_data'
					,BRANCH_NAME 'reff_name'
		from		dbo.CASHIER_MAIN
		where		CASHIER_STATUS = 'OPEN'
		group by	BRANCH_NAME ;
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
