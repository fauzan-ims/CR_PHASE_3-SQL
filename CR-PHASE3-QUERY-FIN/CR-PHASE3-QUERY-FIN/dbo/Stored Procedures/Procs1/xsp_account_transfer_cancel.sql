CREATE PROCEDURE dbo.xsp_account_transfer_cancel
(
	@p_code				nvarchar(50)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
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
	declare	@msg			nvarchar(max)
			,@cashier_code	nvarchar(50)
			,@is_from		nvarchar(1)

	begin try
		
		select	@is_from	= is_from	
		from	dbo.account_transfer
		where	code = @p_code 

		if exists (select 1 from dbo.account_transfer where code = @p_code and transfer_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			if exists	(	
							select	1	
							from	dbo.account_transfer at
									inner join dbo.cashier_main cm on (cm.code = at.cashier_code) 
							where	at.code = @p_code 
									and cm.cashier_status = 'ON PROCESS'
						)
			begin
				select	@cashier_code	= cm.code
				from	dbo.account_transfer at
						inner join dbo.cashier_main cm on (cm.code = at.cashier_code) 
				where	at.code = @p_code 
						and cm.cashier_status = 'ON PROCESS'

				update	dbo.cashier_main
				set		cashier_status		= 'HOLD'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code = @cashier_code
			end

			-- ketika data dari request OPEX
			if(isnull(@is_from,'') <> '')
			begin
				update	dbo.fin_interface_account_transfer
				set		transfer_status			= 'CANCEL'
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	code					= @p_code
			END
            
			update	dbo.account_transfer
			set		transfer_status		= 'CANCEL'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code
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

end
