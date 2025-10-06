create procedure [dbo].[xsp_master_contract_reject]
(
	@p_main_contract_no nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg		   nvarchar(max)
			,@agreement_no nvarchar(50) ;

	begin try
		if exists
		(
			select	1
			from	dbo.master_contract
			where	main_contract_no = @p_main_contract_no
					and status		 <> 'ON PROCESS'
		)
		begin
			set @msg = N'Error data already proceed' ;

			raiserror(@msg, 16, 1) ;
		end ;
		else
		begin
			update	dbo.master_contract
			set		status				= 'REJECT'
					--
					,mod_by				= @p_mod_by
					,mod_date			= @p_mod_date
					,mod_ip_address		= @p_mod_ip_address
			where	main_contract_no	= @p_main_contract_no ;
		end ;
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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
