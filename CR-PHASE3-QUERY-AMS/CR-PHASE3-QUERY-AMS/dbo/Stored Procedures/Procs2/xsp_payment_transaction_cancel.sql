CREATE PROCEDURE dbo.xsp_payment_transaction_cancel
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@status				nvarchar(20)
			,@payment_request_code	nvarchar(50) ;

	begin try  
		select	@status = pts.payment_status
		from	dbo.payment_transaction pts
				inner join dbo.payment_transaction_detail ptd on (ptd.payment_transaction_code = pts.code)
		where	pts.code = @p_code ;

		if (@status = 'HOLD')
		begin
			update	dbo.payment_transaction
			set		payment_status	= 'CANCEL'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code;

			
			declare curr_payment_cancel cursor fast_forward read_only for
			select	ptd.payment_request_code
			from	dbo.payment_transaction pts
					inner join dbo.payment_transaction_detail ptd on (ptd.payment_transaction_code = pts.code)
			where	pts.code = @p_code ; 
			
			open curr_payment_cancel
			
			fetch next from curr_payment_cancel 
			into @payment_request_code
			
			while @@fetch_status = 0
			begin
			    -- Hari - 19.Jun.2023 05:16 PM --	header di cancel maka detail nya kembali hold
				update dbo.payment_request
				set		payment_status				= 'HOLD'
						,payment_transaction_code	= ''
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	code						= @payment_request_code ;

			    fetch next from curr_payment_cancel 
				into @payment_request_code
			end
			
			close curr_payment_cancel
			deallocate curr_payment_cancel

		end
		else
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg ,16,-1);
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
