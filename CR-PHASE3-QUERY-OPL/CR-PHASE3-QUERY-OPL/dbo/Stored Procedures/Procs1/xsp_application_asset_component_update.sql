CREATE PROCEDURE dbo.xsp_application_asset_component_update
(
	@p_id				  bigint
	,@p_asset_no		  nvarchar(50)
	,@p_component_name	  nvarchar(250)
	,@p_component_no	  nvarchar(50)
	,@p_component_date	  datetime = null
	,@p_component_remarks nvarchar(4000)
	--
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	application_asset_component
		set		asset_no			= @p_asset_no
				,component_name		= upper(@p_component_name)
				,component_no		= upper(@p_component_no)
				,component_date		= @p_component_date
				,component_remarks	= @p_component_remarks
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ; 
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

