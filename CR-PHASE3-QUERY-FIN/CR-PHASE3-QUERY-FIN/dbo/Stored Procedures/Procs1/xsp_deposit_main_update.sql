CREATE PROCEDURE dbo.xsp_deposit_main_update
(
	@p_code					  nvarchar(50)
	,@p_branch_code			  nvarchar(50)
	,@p_branch_name			  nvarchar(250)
	,@p_agreement_no		  nvarchar(50)
	,@p_deposit_type		  nvarchar(15)
	,@p_deposit_currency_code nvarchar(3)
	,@p_deposit_amount		  decimal(18, 2)
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	deposit_main
		set		branch_code				= @p_branch_code
				,branch_name			= @p_branch_name
				,agreement_no			= @p_agreement_no
				,deposit_type			= @p_deposit_type
				,deposit_currency_code	= @p_deposit_currency_code
				,deposit_amount			= @p_deposit_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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
