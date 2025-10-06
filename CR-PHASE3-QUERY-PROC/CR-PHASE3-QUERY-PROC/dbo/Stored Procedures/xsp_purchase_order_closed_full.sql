CREATE PROCEDURE dbo.xsp_purchase_order_closed_full
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max)
			,@grn_code	nvarchar(50);

	begin try
		select @grn_code = code 
		from dbo.good_receipt_note
		where purchase_order_code = @p_code

		if exists(select 1 from dbo.good_receipt_note where purchase_order_code = @p_code and status = 'HOLD')
		begin
			set @msg = 'Please cancel data : ' + @grn_code + ' in GRN first.' ;
			raiserror(@msg, 16, 1) ;
		end

		if exists
		(
			select	1
			from	dbo.purchase_order
			where	code		= @p_code
					and status	= 'APPROVE'
		)
		begin
			update	dbo.purchase_order
			set		status				= 'CLOSEDFULL'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;
		end ;
		else
		begin
			set @msg = 'Data already closed.' ;
			raiserror(@msg, 16, 1) ;
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
