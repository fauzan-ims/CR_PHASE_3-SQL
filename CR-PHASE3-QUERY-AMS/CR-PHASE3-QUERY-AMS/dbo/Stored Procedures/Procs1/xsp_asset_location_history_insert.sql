CREATE PROCEDURE [dbo].[xsp_asset_location_history_insert]
(
	@p_id							bigint = 0 output
	,@p_asset_code					nvarchar(50)
	,@p_unit_province_code			nvarchar(50) 
	,@p_unit_province_name			nvarchar(50)
	,@p_unit_city_code				nvarchar(50)
	,@p_unit_city_name				nvarchar(50)
	,@p_parking_location			nvarchar(50)
	,@p_remark_update_location		nvarchar(50)
	,@p_update_location_date		DATETIME
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
			,@update_by NVARCHAR(50);

	begin TRY
		
		insert into dbo.ASSET_LOCATION_HISTORY
		(
		    ASSET_CODE,
		    TRANSACTION_DATE,
		    VALUE_DATE,
		    PARKING_LOCATION,
		    REMARK,
		    UPDATE_BY,
			--
		    CRE_DATE,
		    CRE_BY,
		    CRE_IP_ADDRESS,
		    MOD_DATE,
		    MOD_BY,
		    MOD_IP_ADDRESS
		)
		VALUES
		(   @p_asset_code
			,GETDATE()
			,@p_update_location_date
			,@p_parking_location
			,@p_remark_update_location
			,@p_mod_by
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		    );

		-- update barcode yang sudah digunakan
		UPDATE dbo.ASSET SET remark_update_location = @p_remark_update_location
							,update_location_date	= @p_update_location_date
							,unit_province_code		= @p_unit_province_code
							,unit_province_name		= @p_unit_province_name
							,unit_city_code			= @p_unit_city_code
							,unit_city_name			= @p_unit_city_name
							,parking_location		= @p_parking_location
							,mod_date				= @p_mod_date
							,mod_by					= @p_mod_by
							,mod_ip_address			= @p_mod_ip_address
		WHERE
			code = @p_asset_code;
		

		set @p_id = @@identity ;
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
