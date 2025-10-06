--created by, Rian at 16/05/2023 

CREATE PROCEDURE dbo.xsp_area_blacklist_transaction_detail_update
(
	@p_id								bigint
	,@p_area_blacklist_transaction_code nvarchar(50)
	,@p_province_code					nvarchar(50)
	,@p_city_code						nvarchar(50) 
	,@p_province_name					nvarchar(4000) 
	,@p_city_name						nvarchar(4000) 
	--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	area_blacklist_transaction_detail
		set		area_blacklist_transaction_code = @p_area_blacklist_transaction_code
				,province_code					= @p_province_code
				,city_code						= @p_city_code
				,province_name					= @p_province_name
				,city_name						= @p_city_name
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	id								= @p_id 
		and		area_blacklist_transaction_code	= @p_area_blacklist_transaction_code
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
