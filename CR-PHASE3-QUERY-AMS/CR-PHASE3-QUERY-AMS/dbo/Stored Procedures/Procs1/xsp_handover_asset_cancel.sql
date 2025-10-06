--Created, Rian at 26/12/2022

CREATE PROCEDURE dbo.xsp_handover_asset_cancel

(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max)
			,@status	nvarchar(20);

	begin try  

		update	dbo.handover_asset
		set		status			= 'CANCEL'
		where	code			= @p_code

		update	dbo.handover_request
		set		handover_code	= NULL
				,status			= 'HOLD'
		WHERE	handover_code	= @p_code
		
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
