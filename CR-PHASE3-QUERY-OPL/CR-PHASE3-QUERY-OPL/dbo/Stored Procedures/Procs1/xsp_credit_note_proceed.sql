CREATE PROCEDURE dbo.xsp_credit_note_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists
		(
			select	inv.invoice_no
			from	dbo.credit_note cn
					left join dbo.invoice inv on inv.invoice_no = cn.invoice_no
			where	invoice_status = 'CANCEL' and cn.code = @p_code
		)	
		begin
			set @msg = 'Invoice already cancel' ;

			raiserror(@msg, 16, 1) ;
		end 

		if exists
		(
			select	1
			from	dbo.credit_note
			where	code	  = @p_code
					and credit_amount <= 0
		)
		begin
			set @msg = N'Credit Amount must be greater than 0' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.credit_note
			where	code	   = @p_code
					and status = 'HOLD'
		)
		begin
			update	dbo.credit_note
			set		status			= 'ON PROCESS'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;
		end ;
		else 
		begin
			set @msg = 'Data already proceed' ;

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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
