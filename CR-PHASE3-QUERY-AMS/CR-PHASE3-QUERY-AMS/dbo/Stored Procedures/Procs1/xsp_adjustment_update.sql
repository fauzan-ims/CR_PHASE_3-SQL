CREATE PROCEDURE dbo.xsp_adjustment_update
(
	@p_code							nvarchar(50)
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_date						datetime
	,@p_adjustment_type				nvarchar(50)
	,@p_new_purchase_date			datetime
	,@p_asset_code					nvarchar(50)
	,@p_old_netbook_value_fiscal	decimal(18, 2)
	,@p_old_netbook_value_comm		decimal(18, 2)
	,@p_new_netbook_value_fiscal	decimal(18, 2)
	,@p_new_netbook_value_comm		decimal(18, 2)
	,@p_total_adjustment			decimal(18, 2)
	,@p_payment_by					nvarchar(10)
	,@p_vendor_code					nvarchar(50) = ''
	,@p_vendor_name					nvarchar(250) = ''
	,@p_remark						nvarchar(4000)
	,@p_status						nvarchar(25)
		--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@depre_date		datetime

	begin try

		--select	@depre_date = max(depreciation_date)
		--from	dbo.asset_depreciation_schedule_commercial
		--where	asset_code			 = @p_asset_code
		--and transaction_code <> '' ;

		--if(month(@p_new_purchase_date) < month(@depre_date))
		--begin
		--	set @msg = 'Adjustment date must be greater than last depretiation date ' + convert(varchar(10),@depre_date, 103) + ' .';
		--	raiserror(@msg ,16,-1);	   
		--end

		if @p_new_purchase_date < dbo.xfn_get_system_date()
		begin
	
			set @msg = 'Effective Date must be greater or equal than System Date';
	
			raiserror(@msg, 16, -1) ;
	
		end   

		update	adjustment
		set		branch_code					= @p_branch_code
				,branch_name				= @p_branch_name
				,date						= dbo.xfn_get_system_date()
				,adjustment_type			= @p_adjustment_type
				,new_purchase_date			= @p_new_purchase_date
				,asset_code					= @p_asset_code
				,old_netbook_value_fiscal	= @p_old_netbook_value_fiscal
				,old_netbook_value_comm		= @p_old_netbook_value_comm
				,new_netbook_value_fiscal	= @p_new_netbook_value_fiscal
				,new_netbook_value_comm		= @p_new_netbook_value_comm
				,total_adjustment			= @p_total_adjustment
				,payment_by					= @p_payment_by
				,vendor_code				= @p_vendor_code
				,vendor_name				= @p_vendor_name
				,remark						= @p_remark
				,status						= @p_status
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
