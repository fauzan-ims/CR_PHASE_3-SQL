CREATE PROCEDURE dbo.xsp_sys_client_sipp_update
(
	@p_code						   nvarchar(50)
	,@p_client_code				   nvarchar(50)
	,@p_sipp_kelompok_debtor	   nvarchar(50)
	,@p_sipp_kategori_debtor	   nvarchar(50)
	,@p_sipp_golongan_debtor	   nvarchar(50)
	,@p_sipp_hub_debtor_dg_pp	   nvarchar(50)
	,@p_sipp_sektor_ekonomi_debtor nvarchar(50)
	--
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	sys_client_sipp
		set		client_code					= @p_client_code
				,sipp_kelompok_debtor		= @p_sipp_kelompok_debtor
				,sipp_kategori_debtor		= @p_sipp_kategori_debtor
				,sipp_golongan_debtor		= @p_sipp_golongan_debtor
				,sipp_hub_debtor_dg_pp		= @p_sipp_hub_debtor_dg_pp
				,sipp_sektor_ekonomi_debtor = @p_sipp_sektor_ekonomi_debtor
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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

