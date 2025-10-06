CREATE PROCEDURE dbo.xsp_warning_letter_eod_paid
as
begin

	declare @msg							nvarchar(max)
			--
			,@agreement_no					nvarchar(50)
			,@installment_no				int
			--
			,@mod_date						datetime		= dbo.xfn_get_system_date()
			,@mod_by						nvarchar(15)	= 'EOD'
			,@mod_ip_address				nvarchar(15)	= 'SYSTEM'

	begin TRY

		declare c_main cursor local fast_forward for

		select	ai.agreement_no
				,ai.last_paid_period + 1
		from	dbo.agreement_information ai
		where	ai.ovd_days > 0

		open	c_main
		fetch	c_main
		into	@agreement_no	
				 ,@installment_no	
		while @@fetch_status = 0
		BEGIN
			 
			update dbo.warning_letter
			set		letter_status	   = 'ALREADY PAID'
					--				   
					,mod_date		   = @mod_date
					,mod_by			   = @mod_by
					,mod_ip_address	   = @mod_ip_address
			where	agreement_no	   = @agreement_no
					and installment_no < @installment_no
					and letter_status not in ('CANCEL','REQUEST')

			fetch	c_main
			into	@agreement_no	
					,@installment_no	

		end
		close c_main
		deallocate c_main


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
