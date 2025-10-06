--Created, Rian at 27/01/2023
CREATE PROCEDURE dbo.xsp_rpt_asset_allocation_permohonan_pengiriman_barang_validation
(
	@p_asset_no nvarchar(50)
)
as
begin
	declare @msg		nvarchar(max) 
			,@fa_code	nvarchar(50)
			,@fa_name	nvarchar(250);

	begin try

		select	@fa_code	= fa_code
				,@fa_name	= fa_name
		from	dbo.application_asset
		where	asset_no = @p_asset_no

		if exists 
			(
				select	1
				from	dbo.application_asset
				where	asset_no = @p_asset_no 
				and		(fa_code is null or fa_code = '')
			)
		begin
			set @msg = 'Please Select Fixed Asset, Asset No : ' + @p_asset_no ;
			raiserror(@msg, 16, -1)
		end
		else if exists 
			(
				select	1
				from	dbo.application_asset
				where	asset_no = @p_asset_no 
				and		(request_delivery_date is null or request_delivery_date = '')
			)
		begin
			set @msg = 'Please Insert Estimate Delivery Date For Asset ' + @fa_code + ' - ' + @fa_name 
			raiserror(@msg, 16, -1)
		end

		if exists
			(
				select	1
				from	dbo.application_asset
				where	asset_no = @p_asset_no
				and		request_delivery_date < dbo.xfn_get_system_date()
			)
		begin
			set @msg = 'Estimate Delivery Date must be greater than System Date For Asset ' + @fa_code + ' - ' + @fa_name 
			raiserror(@msg, 16, -1)
		end
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
