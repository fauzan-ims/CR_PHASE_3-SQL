CREATE PROCEDURE dbo.xsp_change_item_type_history_update
(
	@p_code							nvarchar(50)
	,@p_company_code				nvarchar(50)
	,@p_date						datetime
	,@p_description					nvarchar(1000)
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_location_code				nvarchar(50)
	,@p_location_name				nvarchar(250)
	,@p_from_item_code				nvarchar(50)
	,@p_from_item_name				nvarchar(250)
	,@p_to_item_code				nvarchar(50)
	,@p_to_item_name				nvarchar(250)
	,@p_from_category_code			nvarchar(50)
	,@p_from_category_name			nvarchar(250)
	,@p_to_category_code			nvarchar(50)
	,@p_to_category_name			nvarchar(250)
	,@p_original_price_amount		decimal(18, 2)
	,@p_net_book_value_amount		decimal(18, 2)
	,@p_remark						nvarchar(4000)
	,@p_status						nvarchar(50)
	,@p_asset_code					nvarchar(50)
	,@p_barcode						nvarchar(50)
		--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	change_item_type_history
		set		company_code	= @p_company_code
				,date	= @p_date
				,description			= @p_description
				,branch_code			= @p_branch_code
				,branch_name			= @p_branch_name
				,location_code			= @p_location_code
				,location_name			= @p_location_name
				,from_item_code			= @p_from_item_code
				,from_item_name			= @p_from_item_name
				,to_item_code			= @p_to_item_code
				,to_item_name			= @p_to_item_name
				,from_category_code		= @p_from_category_code
				,from_category_name		= @p_from_category_name
				,to_category_code		= @p_to_category_code
				,to_category_name		= @p_to_category_name
				,original_price_amount	= @p_original_price_amount
				,net_book_value_amount	= @p_net_book_value_amount
				,remark					= @p_remark
				,status					= @p_status
				,asset_code				= @p_asset_code
				,barcode				= @p_barcode
					--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
	where		code	= @p_code

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
end
