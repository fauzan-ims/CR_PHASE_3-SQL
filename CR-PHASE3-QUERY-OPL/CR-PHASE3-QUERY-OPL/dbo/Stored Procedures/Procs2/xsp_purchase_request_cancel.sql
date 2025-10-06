CREATE PROCEDURE dbo.xsp_purchase_request_cancel
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@is_request_gts	nvarchar(1)
			,@asset_no			nvarchar(50);

	begin try 

		select	@is_request_gts = is_request_gts
				,@asset_no		= asset_no
		from	dbo.application_asset
		where	purchase_code		  = @p_code
				or	purchase_gts_code = @p_code ;

		if exists
		(
			select	1
			from	dbo.purchase_request
			where	code			   = @p_code
					and request_status = 'HOLD'
		)
		begin
			update	dbo.purchase_request
			set		request_status	= 'CANCEL'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address
			where	asset_no		= @asset_no ;

			if (@is_request_gts = '1')
			begin
				update dbo.application_asset
				set		purchase_gts_status = 'NONE'
						,purchase_gts_code	= null
						--
						,mod_date			= @p_mod_date		
						,mod_by				= @p_mod_by			
						,mod_ip_address		= @p_mod_ip_address
				where	purchase_gts_code 	= @p_code ;
			end
			else
			begin
				update dbo.application_asset
				set		purchase_status = 'NONE'
						,purchase_code	= null
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	purchase_code 	= @p_code ;
			end

			--alter Rian at 15/06/2023 +penambahan jika ada data karoseri dan accessories nya
			if exists
			(
				select	1
				from	dbo.application_asset_detail
				where	asset_no = @asset_no
			)
			begin
				update dbo.application_asset_detail
				set		purchase_status = 'NONE'
						,purchase_code	= null
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	asset_no	 	= @asset_no ;
			end

		end ;
		else
		begin
			set @msg = 'Data already proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

