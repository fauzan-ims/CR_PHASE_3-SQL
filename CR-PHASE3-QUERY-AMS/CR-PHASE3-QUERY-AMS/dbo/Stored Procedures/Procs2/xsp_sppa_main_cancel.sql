/*
	alterd : Yunus Muslim, 23 April 2020
*/
CREATE PROCEDURE dbo.xsp_sppa_main_cancel 
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
	declare @msg				nvarchar(max)
			,@sppa_request_code	nvarchar(50);

	begin try
		if exists (select 1 from dbo.sppa_main where code = @p_code and sppa_status <> 'HOLD')
		begin
			set @msg = 'Data Already Proceed'
		    raiserror(@msg, 16, -1) ;
		end
        else
		begin
		    update	dbo.sppa_main 
			set		sppa_status		= 'CANCEL'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code

			declare efam_cur	cursor local fast_forward for

			select	sppa_request_code
			from	dbo.sppa_detail
			where	sppa_code	= @p_code
						
			open efam_cur
			fetch next from efam_cur  
			into	@sppa_request_code
						
			while @@fetch_status = 0
			begin
				update dbo.sppa_request
				set		register_status = 'HOLD'
						,sppa_code		= null
				where	code			= @sppa_request_code

				fetch next from efam_cur  
				into	@sppa_request_code
			
			end
				
			close efam_cur
			deallocate efam_cur
		
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

