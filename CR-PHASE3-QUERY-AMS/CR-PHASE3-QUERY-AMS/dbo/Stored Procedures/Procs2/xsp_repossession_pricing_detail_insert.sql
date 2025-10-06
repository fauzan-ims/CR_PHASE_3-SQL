CREATE PROCEDURE dbo.xsp_repossession_pricing_detail_insert
(
	@p_id					bigint = 0 output
	,@p_pricing_code		nvarchar(50)
	,@p_asset_code			nvarchar(50)
	,@p_request_amount		decimal(18, 2)
	,@p_approve_amount		decimal(18, 2)
	
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
			,@estimate_gain_loss_pct		   decimal(9, 6) = 0
			,@estimate_gain_loss_amount		   decimal(18, 2) = 0
			,@code_pricelist				   nvarchar(50)
			,@item_name						   nvarchar(50)
			,@vehicle_category_code			   nvarchar(50)
			,@vehicle_subcategory_code		   nvarchar(50)
			,@vehicle_merk_code				   nvarchar(50)
			,@vehicle_model_code			   nvarchar(50)
			,@vehicle_type_code				   nvarchar(50)
			,@vehicle_unit_code				   nvarchar(50)
			,@currency_code					   nvarchar(3)
			,@eff_date						   datetime
			,@pricelist_amount				   decimal(18, 2)
			,@pricing_amount				   decimal(18, 2);

	select	 @pricing_amount					= pricing_amount
			 ,@item_name						= item_name
	from	dbo.repossession_main
	where	code								= @p_asset_code

	begin try
		set @pricelist_amount = isnull(@pricelist_amount,0)

		insert into repossession_pricing_detail
		(
			pricing_code
			,asset_code
			,pricelist_amount
			,pricing_amount
			,request_amount
			,approve_amount
			,estimate_gain_loss_pct
			,estimate_gain_loss_amount
			,net_book_value_fiscal
			,net_book_value_comm
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_pricing_code
			,@p_asset_code
			,0
			,@pricing_amount
			,@p_request_amount
			,@p_approve_amount
			,@estimate_gain_loss_pct
			,@estimate_gain_loss_amount
			,0
			,0
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		update	dbo.repossession_main
		set		repossession_status_process		= 'PRICING'
				--
				,mod_date						= @p_mod_date		
				,mod_by							= @p_mod_by			
				,mod_ip_address					= @p_mod_ip_address
		where	code							= @p_asset_code
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
