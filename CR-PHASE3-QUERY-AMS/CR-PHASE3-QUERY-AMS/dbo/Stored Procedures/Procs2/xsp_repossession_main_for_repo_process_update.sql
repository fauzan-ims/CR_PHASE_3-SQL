CREATE PROCEDURE dbo.xsp_repossession_main_for_repo_process_update
(
	@p_code							nvarchar(50) = null
	,@p_branch_code					nvarchar(50)  = null
	,@p_branch_name					nvarchar(250)  = null
	,@p_bast_code					nvarchar(50) = null
	,@p_repossession_status			nvarchar(10) = null
	,@p_repossession_status_process nvarchar(20) = null
	,@p_asset_code					nvarchar(50) = null
	,@p_item_name					nvarchar(50) = null
	,@p_repo_i_date					datetime = null	  
	,@p_repo_ii_date				datetime = null	   
	,@p_inventory_date				datetime = null	  
	,@p_wo_date						datetime = null	  
	,@p_warehouse_code				nvarchar(50) = null
	,@p_warehouse_external_name		nvarchar(250) = null
	,@p_is_permit_to_sell			nvarchar(10)
	,@p_permit_sell_remarks			nvarchar(4000)
	,@p_sell_request_amount			decimal(18, 2) = null
	,@p_overdue_period				int = null
	,@p_overdue_days				int = null
	,@p_overdue_penalty				decimal(18, 2) = null
	,@p_overdue_installment			decimal(18, 2) = null
	,@p_outstanding_installment		decimal(18, 2) = null
	,@p_outstanding_deposit			decimal(18, 2) = null
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	repossession_main
		set		branch_code						= @p_branch_code
				,branch_name					= @p_branch_name
				,bast_code						= @p_bast_code
				,repossession_status			= @p_repossession_status
				,repossession_status_process	= @p_repossession_status_process
				,asset_code						= @p_asset_code
				,item_name						= @p_item_name
				,repo_i_date					= @p_repo_i_date
				,repo_ii_date					= @p_repo_ii_date
				,inventory_date					= @p_inventory_date
				,wo_date						= @p_wo_date
				,warehouse_code					= @p_warehouse_code
				,warehouse_external_name		= @p_warehouse_external_name
				,is_permit_to_sell				= @p_is_permit_to_sell
				,permit_sell_remarks			= @p_permit_sell_remarks
				,sell_request_amount			= @p_sell_request_amount
				,overdue_period					= @p_overdue_period
				,overdue_days					= @p_overdue_days
				,overdue_penalty				= @p_overdue_penalty
				,overdue_installment			= @p_overdue_installment
				,outstanding_installment		= @p_outstanding_installment
				,outstanding_deposit			= @p_outstanding_deposit
				--
				,mod_date						= @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	code							= @p_code ;
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
