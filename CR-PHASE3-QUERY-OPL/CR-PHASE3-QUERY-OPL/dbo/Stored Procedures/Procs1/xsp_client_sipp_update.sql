CREATE PROCEDURE dbo.xsp_client_sipp_update
(
	@p_client_code							nvarchar(50)
	,@p_sipp_kelompok_debtor_code			nvarchar(50) = null
	,@p_sipp_kategori_debtor_code			nvarchar(50) = null
	,@p_sipp_golongan_debtor_code			nvarchar(50) = null
	,@p_sipp_hub_debtor_dg_pp_code			nvarchar(50) = null
	,@p_sipp_sektor_ekonomi_debtor_code		nvarchar(50) = null
	,@p_sipp_kelompok_debtor_ojk_code		nvarchar(50) = null
	,@p_sipp_kategori_debtor_ojk_code		nvarchar(50) = null
	,@p_sipp_golongan_debtor_ojk_code		nvarchar(50) = null
	,@p_sipp_hub_debtor_dg_pp_ojk_code		nvarchar(50) = null
	,@p_sipp_sektor_ekonomi_debtor_ojk_code nvarchar(50) = null
	,@p_sipp_kelompok_debtor_name			nvarchar(250) = null
	,@p_sipp_kategori_debtor_name			nvarchar(250) = null
	,@p_sipp_golongan_debtor_name			nvarchar(250) = null
	,@p_sipp_hub_debtor_dg_pp_name			nvarchar(250) = null
	,@p_sipp_sektor_ekonomi_debtor_name		nvarchar(250) = null
	--
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address

		update	client_sipp
		set		sipp_kelompok_debtor_code				= @p_sipp_kelompok_debtor_code
				,sipp_kategori_debtor_code				= @p_sipp_kategori_debtor_code
				,sipp_golongan_debtor_code				= @p_sipp_golongan_debtor_code
				,sipp_hub_debtor_dg_pp_code				= @p_sipp_hub_debtor_dg_pp_code
				,sipp_sektor_ekonomi_debtor_code		= @p_sipp_sektor_ekonomi_debtor_code
				,sipp_kelompok_debtor_ojk_code			= @p_sipp_kelompok_debtor_ojk_code
				,sipp_kategori_debtor_ojk_code			= @p_sipp_kategori_debtor_ojk_code
				,sipp_golongan_debtor_ojk_code			= @p_sipp_golongan_debtor_ojk_code
				,sipp_hub_debtor_dg_pp_ojk_code			= @p_sipp_hub_debtor_dg_pp_ojk_code
				,sipp_sektor_ekonomi_debtor_ojk_code	= @p_sipp_sektor_ekonomi_debtor_ojk_code
				,sipp_kelompok_debtor_name				= @p_sipp_kelompok_debtor_name
				,sipp_kategori_debtor_name				= @p_sipp_kategori_debtor_name
				,sipp_golongan_debtor_name				= @p_sipp_golongan_debtor_name
				,sipp_hub_debtor_dg_pp_name				= @p_sipp_hub_debtor_dg_pp_name
				,sipp_sektor_ekonomi_debtor_name		= @p_sipp_sektor_ekonomi_debtor_name
				--
				,mod_date								= @p_mod_date
				,mod_by									= @p_mod_by
				,mod_ip_address							= @p_mod_ip_address
		where	client_code								= @p_client_code ;
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

