CREATE PROCEDURE dbo.xsp_adjustment_history_update
(
	@p_code							nvarchar(50)
	,@p_company_code				nvarchar(50)
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_date						datetime
	,@p_adjustment_type				nvarchar(50)
	,@p_new_purchase_date			datetime
	,@p_description					nvarchar(1000)
	,@p_asset_code					nvarchar(50)
	,@p_cost_center_code			nvarchar(50)
	,@p_cost_center_name			nvarchar(250)
	,@p_new_netbook_value_fiscal	decimal(18, 2)
	,@p_new_netbook_value_comm		decimal(18, 2)
	,@p_total_adjustment			decimal(18, 2)
	,@p_payment_by					nvarchar(10)
	,@p_vendor_code					nvarchar(50)
	,@p_vendor_name					nvarchar(250)
	,@p_remark						nvarchar(4000)
	,@p_status						nvarchar(25)
	,@p_purchase_price				decimal(18, 2)
	,@p_old_total_depre_comm		decimal(18, 2)
		--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	adjustment_history
		set		company_code				= @p_company_code
				,branch_code				= @p_branch_code
				,branch_name				= @p_branch_name
				,date						= @p_date
				,adjustment_type			= @p_adjustment_type
				,new_purchase_date			= @p_new_purchase_date
				,description				= @p_description
				,asset_code					= @p_asset_code
				,cost_center_code			= @p_cost_center_code
				,cost_center_name			= @p_cost_center_name
				,new_netbook_value_fiscal	= @p_new_netbook_value_fiscal
				,new_netbook_value_comm		= @p_new_netbook_value_comm
				,total_adjustment			= @p_total_adjustment
				,payment_by					= @p_payment_by
				,vendor_code				= @p_vendor_code
				,vendor_name				= @p_vendor_name
				,remark						= @p_remark
				,status						= @p_status
				,purchase_price				= @p_purchase_price		
				,old_total_depre_comm		= @p_old_total_depre_comm
					--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code	= @p_code

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
