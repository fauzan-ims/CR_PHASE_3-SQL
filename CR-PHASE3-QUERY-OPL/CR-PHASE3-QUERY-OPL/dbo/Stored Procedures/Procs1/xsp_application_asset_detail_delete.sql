--created by, Rian at 17/05/2023 

CREATE PROCEDURE dbo.xsp_application_asset_detail_delete
(
	@p_id				bigint
	,@p_asset_no		nvarchar(50)
	,@p_application_no	nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) 
			,@type					nvarchar(15)
			,@total_amount			decimal(18,2)
			,@unit_amount			decimal(18,2)
			,@karoseri_amount		decimal(18,2)
			,@accessories_amount	decimal(18,2)
			,@total_asset_amount	decimal(18,2)

	begin try

		--select type
		select	@type = type
		from	dbo.application_asset_detail
		where	asset_no = @p_asset_no
				and id	 = @p_id ;
		
		--delete data di application asset detail
		delete dbo.application_asset_detail
		where	asset_no = @p_asset_no
				and id	 = @p_id ;

		--calculate karoseri and accessories amount
		exec dbo.xsp_application_asset_detail_calculate_karoseri_accessories @p_asset_no			= @p_asset_no
																			 ,@p_application_no		= @p_application_no
																			 ,@p_type				= @type
																			 --
																			 ,@p_mod_date			= @p_mod_date
																			 ,@p_mod_by				= @p_mod_by
																			 ,@p_mod_ip_address		= @p_mod_ip_address
		
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
