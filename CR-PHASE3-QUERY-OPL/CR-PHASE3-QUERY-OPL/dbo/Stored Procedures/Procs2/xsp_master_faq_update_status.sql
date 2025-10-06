--created by, Rian at 10/02/2023 

CREATE procedure dbo.xsp_master_faq_update_status
(
	@p_id					bigint
		--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin

	declare @msg nvarchar(max) ;

	begin try
		
		if exists (	select 1 from dbo.MASTER_FAQ 
						where id = @p_id
						and  is_active = '1')
		begin
				
			update	dbo.MASTER_FAQ
			set		is_active		= '0'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where id = @p_id

		end
		else
		begin
				
			update	dbo.MASTER_FAQ
			set		is_active		= '1'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where id = @p_id

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
