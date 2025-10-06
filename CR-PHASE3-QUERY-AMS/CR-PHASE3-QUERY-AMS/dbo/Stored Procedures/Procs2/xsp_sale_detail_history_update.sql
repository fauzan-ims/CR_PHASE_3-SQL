CREATE PROCEDURE dbo.xsp_sale_detail_history_update
(
	@p_id					bigint
	,@p_sale_code			nvarchar(50)
	,@p_asset_code			nvarchar(50)
	,@p_description			nvarchar(4000)
	,@p_net_book_value		decimal(18, 2)
	,@p_sale_value			decimal(18, 2)
		--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
	,@p_cost_center_code	nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	sale_detail_history
		set		sale_code			= @p_sale_code
				,asset_code			= @p_asset_code
				,description		= @p_description
				,net_book_value		= @p_net_book_value
				,sale_value			= @p_sale_value
					--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
				,cost_center_code	= @p_cost_center_code
		where	id	= @p_id

	end try
	Begin catch
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
