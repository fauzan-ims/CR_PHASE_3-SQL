CREATE PROCEDURE dbo.xsp_reprint_receipt_post
(
	@p_code					nvarchar(50)
	,@p_cashier_code		nvarchar(50)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg				nvarchar(max)
			,@new_receipt_code	nvarchar(50)
			,@reprint_date		datetime

	begin try
	
		if exists (select 1 from dbo.reprint_receipt where code = @p_code and reprint_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin

			select	@new_receipt_code	= new_receipt_code
					,@reprint_date		= reprint_date
			from	dbo.reprint_receipt 
			where	code = @p_code

			if exists (select 1 from dbo.receipt_main where code = @new_receipt_code and receipt_status <> 'NEW')
			begin
				set @msg = 'Receipt is not NEW, Please check Receipt status';
				raiserror(@msg ,16,-1)
			end
			
			update	dbo.receipt_main
			set		receipt_status		= 'USED'
					,print_count		= print_count + 1
					,receipt_use_date	= @reprint_date
					,cashier_code		= @p_cashier_code
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @new_receipt_code

			update	dbo.cashier_receipt_allocated
			set		receipt_status			= 'USED'
					,receipt_use_date		= @reprint_date
					,receipt_use_trx_code	= @p_code
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	cashier_code			= @p_cashier_code
					and receipt_code		= @new_receipt_code

			update	dbo.reprint_receipt
			set		reprint_status		= 'POST'
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


