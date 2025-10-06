CREATE PROCEDURE [dbo].[xsp_asset_replacement_detail_update_new_asset]
(
	@p_id						bigint
	,@p_new_fa_code				nvarchar(50) = ''
	,@p_new_fa_name				nvarchar(250) = ''
	-- (+) Ari 2023-09-13 ket : add new asset platno, chasis & engine no
	,@p_new_fa_ref_no_01		nvarchar(50) = ''
	,@p_new_fa_ref_no_02		nvarchar(50) = ''
	,@p_new_fa_ref_no_03		nvarchar(50) = ''
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	asset_replacement_detail
		set		new_fa_code			= @p_new_fa_code
				,new_fa_name		= @p_new_fa_name
				-- (+) Ari 2023-09-13 ket : add new asset platno, chasis & engine no
				,new_fa_ref_no_01	= @p_new_fa_ref_no_01
				,new_fa_ref_no_02	= @p_new_fa_ref_no_02
				,new_fa_ref_no_03	= @p_new_fa_ref_no_03
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;

	end try
	Begin catch
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
