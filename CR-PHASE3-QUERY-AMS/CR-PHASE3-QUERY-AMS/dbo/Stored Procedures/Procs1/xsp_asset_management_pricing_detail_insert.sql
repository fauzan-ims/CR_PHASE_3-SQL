CREATE PROCEDURE dbo.xsp_asset_management_pricing_detail_insert
(
	@p_id						  bigint = 0 output
	,@p_pricing_code			  nvarchar(50)
	,@p_asset_code				  nvarchar(50)
	,@p_pricelist_amount		  decimal(18, 2)	= 0
	,@p_pricing_amount			  decimal(18, 2)
	,@p_request_amount			  decimal(18, 2)
	,@p_approve_amount			  decimal(18, 2)
	,@p_estimate_gain_loss_pct	  decimal(9, 6)		= 0
	,@p_estimate_gain_loss_amount decimal(18, 2)	= 0
	,@p_net_book_value_fiscal	  decimal(18, 2)
	,@p_net_book_value_comm		  decimal(18, 2)
	,@p_collateral_location		  nvarchar(4000)	= ''
	,@p_collateral_description	  nvarchar(250)		= ''
	--
	,@p_cre_date				  datetime
	,@p_cre_by					  nvarchar(15)
	,@p_cre_ip_address			  nvarchar(15)
	,@p_mod_date				  datetime
	,@p_mod_by					  nvarchar(15)
	,@p_mod_ip_address			  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into asset_management_pricing_detail
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
			,collateral_location
			,collateral_description
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_pricing_code
			,@p_asset_code
			,@p_pricelist_amount
			,@p_pricing_amount
			,@p_request_amount
			,@p_approve_amount
			,@p_estimate_gain_loss_pct
			,@p_estimate_gain_loss_amount
			,@p_net_book_value_fiscal
			,@p_net_book_value_comm
			,@p_collateral_location
			,@p_collateral_description
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
