--Created, Rian 13/12/2022

CREATE PROCEDURE dbo.xsp_application_asset_reservation_cancel
(
	@p_id					bigint
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg				nvarchar(max)

	begin try
	
		if exists (select 1 from dbo.application_asset_reservation where id = @p_id and status <> 'HOLD')
		begin
			set @msg = 'Data Already Proceed or Post';
			raiserror(@msg ,16,-1)
		end
		else
		begin
			update	dbo.application_asset_reservation
			set		status				= 'CANCEL'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	id					= @p_id

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


