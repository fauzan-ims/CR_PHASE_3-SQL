CREATE PROCEDURE dbo.xsp_asset_upload_delete
(
	--@p_id bigint
	@p_cre_by			nvarchar(15)
	,@p_asset_type		nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		if (@p_asset_type = 'ELCT')
		begin
			
				delete	dbo.asset_electronic_upload
				where	cre_by = @p_cre_by
				and		upload_no in	(
											select	upload_no 
											from	dbo.upload_error_log 
										)

		end
		else if (@p_asset_type = 'FNTR')
		begin
			
				delete	dbo.asset_furniture_upload
				where	cre_by = @p_cre_by
				and		upload_no in	(
											select	upload_no 
											from	dbo.upload_error_log 
										)

		end
		else if (@p_asset_type = 'MCHN')
		begin
			
				delete	dbo.asset_machine_upload
				where	cre_by = @p_cre_by
				and		upload_no in	(
											select	upload_no 
											from	dbo.upload_error_log 
										)

		end
		else if (@p_asset_type = 'PRTY')
		begin
			
				delete	dbo.asset_property_upload
				where	cre_by = @p_cre_by
				and		upload_no in	(
											select	upload_no 
											from	dbo.upload_error_log 
										)

		end
		else if (@p_asset_type = 'VHCL')
		begin
			
				delete	dbo.asset_vehicle_upload
				where	cre_by = @p_cre_by
				and		upload_no in	(
											select	upload_no 
											from	dbo.upload_error_log 
										)

		end
		else if (@p_asset_type = 'OTHR')
		begin
			
				delete	dbo.asset_other_upload
				where	cre_by = @p_cre_by
				and		upload_no in	(
											select	upload_no 
											from	dbo.upload_error_log 
										)

		end
		
		delete	dbo.upload_error_log
		where	cre_by = @p_cre_by
		and		upload_no in	(
									select	upload_no 
									from	dbo.asset_upload 
									where	type_code	= @p_asset_type
								)

		delete	dbo.asset_upload 
		where	cre_by = @p_cre_by
		and		type_code = @p_asset_type
		and		status = 'NEW'

		--delete asset_upload
		--where	id = @p_id ;

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
