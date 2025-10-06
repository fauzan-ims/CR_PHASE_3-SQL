CREATE PROCEDURE dbo.xsp_job_eod_payment_request_for_fintech_disbursement
as
begin
	declare @msg				   nvarchar(max)
			,@mod_date			   datetime		= getdate()
			,@mod_by			   nvarchar(15) = 'EOD'
			,@mod_ip_address	   nvarchar(15) = 'SYSTEM'
			,@payment_request_code nvarchar(50) ; 

	begin try

		declare paymentrequest cursor fast_forward read_only for
		select	code 
		from	dbo.payment_request
		where	payment_source	   = 'FINTECH DISBURSEMENT'
				and payment_status = 'HOLD' ;

		open paymentRequest ;

		fetch next from paymentRequest
		into @payment_request_code  ;

		while @@fetch_status = 0
		begin    
																		 
			exec dbo.xsp_payment_request_proceed @p_code			= @payment_request_code
												 ,@p_rate			= 1
												 ,@p_cre_date		= @mod_date		
												 ,@p_cre_by			= @mod_by		
												 ,@p_cre_ip_address = @mod_ip_address
												 ,@p_mod_date		= @mod_date		
												 ,@p_mod_by			= @mod_by		
												 ,@p_mod_ip_address = @mod_ip_address

			fetch next from paymentRequest
			into @payment_request_code ;
		end ;

		close paymentRequest ;
		deallocate paymentRequest ;

	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;There is an error.' + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
