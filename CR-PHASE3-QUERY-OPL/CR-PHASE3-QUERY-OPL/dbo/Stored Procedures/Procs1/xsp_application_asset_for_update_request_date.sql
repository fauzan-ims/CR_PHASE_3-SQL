--Created by, Rian at 26/01/2023
CREATE PROCEDURE dbo.xsp_application_asset_for_update_request_date
(
	@p_asset_no				  nvarchar(50) 
	,@p_request_delivery_date datetime = null
)
as
begin
	declare @msg					nvarchar(max) 
			,@fa_code				nvarchar(50)
			,@fa_name				nvarchar(250)
			,@request_deivery_date	datetime

	begin try

		select	@fa_code				= fa_code
				,@fa_name				= fa_name
				,@request_deivery_date	= request_delivery_date
		from	dbo.application_asset
		where	asset_no = @p_asset_no

		--validasi tanggal tidak boleh lebih kecil dari sistem date
		if (@p_request_delivery_date < dbo.xfn_get_system_date())
		begin
			--set @msg = 'Estimate Delivery Date must be greater than System Date For Asset ' + @fa_code + ' - ' + @fa_name 
			set @msg = 'Estimate Delivery Date must be greater than System Date For Asset ' + @p_asset_no
			raiserror(@msg, 16, -1)
		end

		update	dbo.application_asset
		set		request_delivery_date				= @p_request_delivery_date
				,is_asset_delivery_request_printed	= '0'
		where	asset_no							= @p_asset_no ;
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
