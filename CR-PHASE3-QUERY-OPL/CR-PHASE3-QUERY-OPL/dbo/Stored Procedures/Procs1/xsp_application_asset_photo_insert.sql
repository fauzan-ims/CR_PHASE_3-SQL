CREATE PROCEDURE dbo.xsp_application_asset_photo_insert
(
	@p_id			   bigint = 0 output
	,@p_asset_no	   nvarchar(50)
	,@p_remarks		   nvarchar(250)
	,@p_file_name	   nvarchar(250) = ''
	,@p_paths		   nvarchar(250) = ''
	,@p_latitude	   nvarchar(250) = ''
	,@p_longitude	   nvarchar(250) = ''
	,@p_geo_address	   nvarchar(250) = ''
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into application_asset_photo
		(
			asset_no
			,remarks
			,file_name
			,paths
			,latitude
			,longitude
			,geo_address
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_asset_no
			,@p_remarks
			,@p_file_name
			,@p_paths
			,@p_latitude
			,@p_longitude
			,@p_geo_address
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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

