/*
exec xsp_job_eod_agreement_main_update_status
*/
-- Louis Handry 27/02/2023 20:44:35 -- 
CREATE PROCEDURE [dbo].[xsp_job_eod_agreement_main_update_status]
as
begin
	declare @msg			 nvarchar(max)
			,@agreement_no	 nvarchar(50)
			,@maturity_date	 datetime
			,@mod_date		 datetime	  = getdate()
			,@mod_by		 nvarchar(15) = 'EOD'
			,@mod_ip_address nvarchar(15) = '127.0.0.1' ;

	begin try
		begin
			declare curr_agreement cursor fast_forward read_only for
			select	am.agreement_no
					,ai.maturity_date
			from	dbo.agreement_main am
					inner join dbo.agreement_information ai on (ai.agreement_no = am.agreement_no)
			where	agreement_status				   = 'GO LIVE'
					and cast(ai.maturity_date as date) < dbo.xfn_get_system_date() ;

			open curr_agreement ;

			fetch next from curr_agreement
			into @agreement_no
				 ,@maturity_date ;

			while @@fetch_status = 0
			begin
					update	dbo.agreement_main
					set		agreement_status	  = 'TERMINATE'
							,agreement_sub_status = 'INCOMPLETE'
							,termination_status	  = 'NORMAL'
							,termination_date	  = @maturity_date
							--
							,mod_date			  = @mod_date		 
							,mod_by				  = @mod_by		 
							,mod_ip_address		  = @mod_ip_address 
					where	agreement_no		  = @agreement_no ;

					exec dbo.xsp_agreement_main_update_terminate_status @p_agreement_no			= @agreement_no
																		,@p_termination_date	= @maturity_date
																		,@p_mod_date			= @mod_date
																		,@p_mod_by				= @mod_by
																		,@p_mod_ip_address		= @mod_ip_address
				
				fetch next from curr_agreement
				into @agreement_no 
					 ,@maturity_date ;
			end ;

			close curr_agreement ;
			deallocate curr_agreement ;
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
