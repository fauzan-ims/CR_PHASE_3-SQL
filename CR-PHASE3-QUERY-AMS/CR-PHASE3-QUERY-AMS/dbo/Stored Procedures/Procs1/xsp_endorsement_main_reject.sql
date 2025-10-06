/*
	alterd : Yunus Muslim, 28 April 2020
*/
CREATE PROCEDURE dbo.xsp_endorsement_main_reject 
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@policy_code	 nvarchar(50);

	begin try		
		select @policy_code = policy_code
		from dbo.endorsement_main 
		where code = @p_code

		if exists (select 1 from dbo.endorsement_main where code = @p_code and endorsement_status = 'ON PROCESS')
		begin
			update	dbo.endorsement_main 
			set		endorsement_status	= 'REJECT'
					--
					,mod_date			= @p_mod_date		
					,mod_by				= @p_mod_by			
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code
			
			update dbo.insurance_policy_main
			set	   policy_process_status = null
			where  code = @policy_code	
		end
        else
		begin
			set @msg = 'Data already proceed' ;
			raiserror(@msg, 16, -1) ;
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

