CREATE PROCEDURE dbo.xsp_dashboard_suspend_by_branch
--(
--	@p_year nvarchar(4)
--)
as
begin
	declare @msg			  nvarchar(max)
			

	begin try
		select		top 5 sum(remaining_amount) 'total_data'
					,branch_name 'reff_name'
		from		dbo.SUSPEND_MAIN
		where		SUSPEND_CURRENCY_CODE = 'IDR'
		group by	branch_name
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
