CREATE PROCEDURE dbo.xsp_payment_transaction_reject_from_approval
(
	@p_code						nvarchar(50)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)	
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg nvarchar(max) 
			,@payment_request_code	nvarchar(50) ;
	
	--select	@payment_request_code = ptd.payment_request_code
	--from	dbo.payment_transaction pts
	--		inner join dbo.payment_transaction_detail ptd on (ptd.payment_transaction_code = pts.code)
	--where	pts.code = @p_code ;

	begin try
		
		if exists
		(
			select	1
			from	dbo.payment_transaction
			where	code			  = @p_code
					and payment_status <> 'ON PROCESS'
		)
		begin
			set @msg = 'Data already proceed' ;
			raiserror(@msg, 16, 1) ;
		end ;
        else
		BEGIN
			UPDATE dbo.payment_transaction
			set		payment_status			= 'REJECT'
					--
					,mod_by					= @p_mod_by
					,mod_date				= @p_mod_date
					,mod_ip_address			= @p_mod_ip_address
			where   code					= @p_code ;

			DECLARE cursor_name CURSOR FAST_FORWARD READ_ONLY FOR
			select	ptd.payment_request_code
			from	dbo.payment_transaction pts
					inner join dbo.payment_transaction_detail ptd on (ptd.payment_transaction_code = pts.code)
			where	pts.code = @p_code ;
			
			OPEN cursor_name
			
			FETCH NEXT FROM cursor_name 
			INTO @payment_request_code
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
			    update dbo.payment_request
				set		payment_status				= 'HOLD'
						,payment_transaction_code	= ''
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	code						= @payment_request_code ;
			
			    FETCH NEXT FROM cursor_name 
				INTO @payment_request_code
			END
			
			CLOSE cursor_name
			DEALLOCATE cursor_name

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


