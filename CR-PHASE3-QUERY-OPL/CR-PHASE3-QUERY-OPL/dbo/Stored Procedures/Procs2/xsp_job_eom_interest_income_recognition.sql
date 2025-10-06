/*
exec xsp_job_eom_interest_income_recognition
*/
-- Louis Senin, 06 Maret 2023 13.49.39 -- 
CREATE PROCEDURE dbo.xsp_job_eom_interest_income_recognition
as
begin
	declare @msg			 nvarchar(max)
			,@eod_date		 datetime	  = dbo.xfn_get_system_date()
			,@mod_date		 datetime	  = getdate()
			,@mod_by		 nvarchar(15) = 'EOD'
			,@mod_ip_address nvarchar(15) = '127.0.0.1' ;

	begin try
		if (day(dateadd(day, 1, @eod_date)) = 1)
		begin 
			exec dbo.xsp_agreement_calculate_accrue @p_transaction_date = @eod_date
													--
													,@p_cre_date		= @mod_date		 
													,@p_cre_by			= @mod_by		 
													,@p_cre_ip_address	= @mod_ip_address 
													,@p_mod_date		= @mod_date		 
													,@p_mod_by			= @mod_by		 
													,@p_mod_ip_address	= @mod_ip_address  

			exec dbo.xsp_job_eom_interest_income_recognition_journal
		end ;
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

