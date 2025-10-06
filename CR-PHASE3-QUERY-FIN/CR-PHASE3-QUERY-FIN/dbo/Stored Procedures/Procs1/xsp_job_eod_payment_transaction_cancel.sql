-- Louis Jumat, 03 November 2023 17.19.19 --
CREATE PROCEDURE dbo.xsp_job_eod_payment_transaction_cancel
as
begin
	declare @msg					   nvarchar(max)
			,@mod_date				   datetime		= getdate()
			,@mod_by				   nvarchar(15) = N'EOD'
			,@mod_ip_address		   nvarchar(15) = N'SYSTEM'
			,@receipt_code			   nvarchar(50)
			,@payment_transaction_code nvarchar(50) ;

	begin try
		begin
			declare cur_payment_transaction cursor fast_forward read_only for
			select	code
			from	dbo.payment_transaction
			where	payment_status in ('HOLD', 'ON PROCESS') ;

			open cur_payment_transaction ;

			fetch next from cur_payment_transaction
			into @payment_transaction_code ;

			while @@fetch_status = 0
			begin
				exec dbo.xsp_payment_transaction_cancel @p_code				= @payment_transaction_code
														,@p_cre_date		= @mod_date		
														,@p_cre_by			= @mod_by		
														,@p_cre_ip_address	= @mod_ip_address
														,@p_mod_date		= @mod_date		
														,@p_mod_by			= @mod_by		
														,@p_mod_ip_address	= @mod_ip_address

				fetch next from cur_payment_transaction
				into @payment_transaction_code ;
			end ;

			close cur_payment_transaction ;
			deallocate cur_payment_transaction ;
		end ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;There is an error.' + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
