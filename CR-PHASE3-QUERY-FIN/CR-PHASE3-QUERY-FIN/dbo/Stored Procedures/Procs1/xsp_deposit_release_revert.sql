CREATE PROCEDURE dbo.xsp_deposit_release_revert
(
	@p_code					nvarchar(50)
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
			,@payment_code	nvarchar(50)

	begin try
	
		if exists (select 1 from dbo.deposit_release where code = @p_code and release_status <> 'ON PROCESS')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else if exists (select 1 from dbo.payment_request where payment_source_no = @p_code and isnull(payment_transaction_code,'') <> '')
		begin
			select	@payment_code = payment_transaction_code 
			from	dbo.payment_request 
			where	payment_source_no = @p_code 
			set @msg = 'This Relase transaction is already in Payment transaction '+ @payment_code +'. Please delete it first';
			raiserror(@msg ,16,-1)
		end
		else
		begin
			
			update	dbo.payment_request
			set		payment_status		= 'CANCEL'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	payment_source_no	= @p_code

			update	dbo.deposit_release
			set		release_status		= 'HOLD'
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

