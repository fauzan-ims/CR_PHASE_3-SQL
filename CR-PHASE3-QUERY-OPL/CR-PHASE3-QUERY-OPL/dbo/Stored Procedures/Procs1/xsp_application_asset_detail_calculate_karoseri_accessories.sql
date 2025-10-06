--created by, Rian at 19/05/2023 

CREATE procedure xsp_application_asset_detail_calculate_karoseri_accessories
(
	@p_asset_no			nvarchar(50)
	,@p_application_no	nvarchar(50)
	,@p_type			nvarchar(15)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
AS
BEGIN
	declare	@msg					nvarchar(max)
			,@total_amount			decimal(18,2)
			,@karoseri_amount		decimal(18,2)
			,@accessories_amount	decimal(18,2)
			,@unit_amount			decimal(18,2)
			,@total_asset_amount	decimal(18,2)

	begin try
				--select dan jumlahkan semua nilai amount berdasarkan 
		select	@total_amount	= sum(amount)
		from	dbo.application_asset_detail
		where	asset_no = @p_asset_no
				and type = @p_type ;

		--update karoseri amount dan accessories amount berdarakan type nya
		if (@p_type = 'KAROSERI')
		begin
			update	dbo.application_asset
			set		karoseri_amount = isnull(@total_amount, 0)
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where	application_no	= @p_application_no
			and		asset_no		= @p_asset_no
		end
		else
		begin
			update	dbo.application_asset
			set		accessories_amount	= isnull(@total_amount, 0)
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	application_no		= @p_application_no
			and		asset_no			= @p_asset_no
		end

		--select data amount dari application asset
		select	@unit_amount			= market_value
				,@karoseri_amount		= karoseri_amount
				,@accessories_amount	= accessories_amount
		from	dbo.application_asset
		where	application_no			= @p_application_no
				and asset_no			= @p_asset_no ;

		--set total asset amount
		set	@total_asset_amount = @unit_amount + @karoseri_amount + @accessories_amount

		--update applcation asset
		update	dbo.application_asset
		set		asset_amount		= isnull(@total_asset_amount, 0)
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	application_no		= @p_application_no
		and		asset_no			= @p_asset_no
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
END


