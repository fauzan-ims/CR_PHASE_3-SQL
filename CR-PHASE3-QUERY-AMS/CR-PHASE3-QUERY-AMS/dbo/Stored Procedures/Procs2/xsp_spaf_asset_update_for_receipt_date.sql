CREATE PROCEDURE [dbo].[xsp_spaf_asset_update_for_receipt_date]
(
	@p_code							nvarchar(50)
	,@p_receipt_date				datetime = null
	--													
	,@p_mod_date					datetime		
	,@p_mod_by						nvarchar(50)	
	,@p_mod_ip_address 				nvarchar(50)	
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	spaf_asset
		set		receipt_date			= @p_receipt_date
				--	
				,mod_date				= @p_mod_date		
				,mod_by					= @p_mod_by			
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code
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
			set @msg = 'v' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%v;%' or error_message() like '%e;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;
