--created by, Rian at 01/03/2023 

CREATE procedure dbo.xsp_maturity_update_result
(
	@p_code						nvarchar(50)
	,@p_result					nvarchar(20)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max)
	
	begin try

		update	dbo.maturity
		set		result				= @p_result
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;

		update	dbo.maturity_detail
		set		result				= @p_result
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	maturity_code		= @p_code ;

		if	(@p_result = 'STOP')
		begin
			update	dbo.maturity
			set		additional_periode = 0
			where	code = @p_code

			update	dbo.maturity_detail
			set		additional_periode = 0
			where	maturity_code = @p_code
		end
		else if (@p_result = 'CONTINUE')
		begin
			update	dbo.maturity
			set		pickup_date = null
			where	code = @p_code

			update	dbo.maturity_detail
			set		pickup_date = null
			where	maturity_code = @p_code
		end

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
