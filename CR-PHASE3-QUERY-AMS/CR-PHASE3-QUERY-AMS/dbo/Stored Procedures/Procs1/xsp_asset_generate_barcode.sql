CREATE PROCEDURE dbo.xsp_asset_generate_barcode
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg	  nvarchar(max)
			,@status  nvarchar(20)
			,@barcode nvarchar(50) ;

	begin try -- 
		select	@status			= dor.status
				,@barcode		= dor.barcode
		from	dbo.asset dor
		where	dor.code		= @p_code ;

		if (@status = 'NEW')
		begin
			if exists
			(
				select	1
				from	dbo.asset_barcode_image
				where	asset_code = @p_code --and barcode = @barcode
			)
			begin
				update	dbo.asset_barcode_image
				set		barcode			= @barcode
				where	asset_code		= @p_code ;
			end ;
			else
			begin
				exec dbo.xsp_asset_barcode_image_insert @p_asset_code	= @p_code
														,@p_barcode		= @barcode ;
			end ;
		end ;
		else
		begin
			set @msg = 'Data already proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;
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
