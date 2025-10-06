CREATE PROCEDURE dbo.xsp_agreement_for_terminate
	@p_agreement_no		   nvarchar(50)
	,@p_termination_date   datetime
	,@p_termination_status nvarchar(20)
	--
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
as
begin
	declare	@msg	nvarchar(max)

	begin try 

		if exists
		(
			select	1
			from	dbo.agreement_main
			where	agreement_no		 = @p_agreement_no
					and agreement_status = 'GO LIVE'
		)
		begin

			-- cek fundin used
			if not exists
			(
				select	1
				from	dbo.agreement_fund_in_used_main
				where	agreement_no	   = @p_agreement_no
						and charges_amount > 0
			)
			begin
				update	dbo.agreement_main
				set		termination_date		= @p_termination_date
						,termination_status		= @p_termination_status
						,agreement_status		= 'TERMINATE' -- (GO LIVE / TERMINATE )
						,agreement_sub_status	= ''  
						--
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	agreement_no			= @p_agreement_no ;
			end ;
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
