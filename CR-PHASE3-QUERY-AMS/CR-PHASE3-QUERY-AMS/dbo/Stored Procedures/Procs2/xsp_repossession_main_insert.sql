CREATE PROCEDURE dbo.xsp_repossession_main_insert
(
	@p_code							nvarchar(50) = '' output
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_bast_code					nvarchar(50)
	,@p_repossession_status			nvarchar(10)
	,@p_repossession_status_process nvarchar(20)
	,@p_bast_type					nvarchar(10)
	,@p_asset_code					nvarchar(50)
	,@p_item_name					nvarchar(50)
	,@p_asset_category_code			nvarchar(50)
	,@p_asset_category_name			nvarchar(250)
	,@p_exit_status					nvarchar(20)
	,@p_exit_date					datetime
	,@p_repo_i_date					datetime
	,@p_repo_ii_date				datetime
	,@p_inventory_date				datetime
	,@p_wo_date						datetime
	,@p_back_to_current_date		datetime
	,@p_puchase_date				datetime
	,@p_fa_date						datetime
	,@p_extension_count				int
	,@p_estimate_repoii_date		datetime
	,@p_warehouse_code				nvarchar(50)
	,@p_warehouse_external_name		nvarchar(250)
	,@p_pricing_amount				decimal(18, 2)
	,@p_is_permit_to_sell			nvarchar(1)
	,@p_permit_sell_remarks			nvarchar(4000)
	,@p_sell_request_amount			decimal(18, 2)
	,@p_sold_amount					decimal(18, 2)
	,@p_is_remedial					nvarchar(1)
	,@p_overdue_period				int
	,@p_overdue_days				int
	,@p_overdue_penalty				decimal(18, 2)
	,@p_overdue_installment			decimal(18, 2)
	,@p_outstanding_installment		decimal(18, 2)
	,@p_status						nvarchar(50)
	,@p_fisical_status				nvarchar(25)
	,@p_rental_status				nvarchar(25)
	,@p_outstanding_deposit			decimal(18, 2)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@year				nvarchar(2)
			,@month				nvarchar(2)
			,@code				nvarchar(50);

			set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
			set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
			
			exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
														,@p_branch_code = @p_branch_code
														,@p_sys_document_code = N'RMN'
														,@p_custom_prefix = ''
														,@p_year = @year
														,@p_month = @month
														,@p_table_name = 'REPOSSESSION_MAIN'
														,@p_run_number_length = 6
														,@p_delimiter = '.'
														,@p_run_number_only = N'0' ;

	if @p_is_permit_to_sell = 'T'
		set @p_is_permit_to_sell = '1' ;
	else
		set @p_is_permit_to_sell = '0' ;

	if @p_is_remedial = 'T'
		set @p_is_remedial = '1' ;
	else
		set @p_is_remedial = '0' ;

	begin try
		insert into repossession_main
		(
			code
			,branch_code
			,branch_name
			,bast_code
			,repossession_status
			,repossession_status_process
			,bast_type
			,asset_code
			,item_name
			,asset_category_code
			,asset_category_name
			,exit_status
			,exit_date
			,repo_i_date
			,repo_ii_date
			,inventory_date
			,wo_date
			,back_to_current_date
			,purchase_date
			,fa_date
			,extension_count
			,estimate_repoii_date
			,warehouse_code
			,warehouse_external_name
			,pricing_amount
			,is_permit_to_sell
			,permit_sell_remarks
			,sell_request_amount
			,sold_amount
			,is_remedial
			,overdue_period
			,overdue_days
			,overdue_penalty
			,overdue_installment
			,outstanding_installment
			,status			
			,fisical_status	
			,rental_status	
			,outstanding_deposit
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_branch_code
			,@p_branch_name
			,@p_bast_code
			,@p_repossession_status
			,@p_repossession_status_process
			,@p_bast_type
			,@p_asset_code
			,@p_item_name
			,@p_asset_category_code
			,@p_asset_category_name
			,@p_exit_status
			,@p_exit_date
			,@p_repo_i_date
			,@p_repo_ii_date
			,@p_inventory_date
			,@p_wo_date
			,@p_back_to_current_date
			,@p_puchase_date
			,@p_fa_date
			,@p_extension_count
			,@p_estimate_repoii_date
			,@p_warehouse_code
			,@p_warehouse_external_name
			,@p_pricing_amount
			,@p_is_permit_to_sell
			,@p_permit_sell_remarks
			,@p_sell_request_amount
			,@p_sold_amount
			,@p_is_remedial
			,@p_overdue_period
			,@p_overdue_days
			,@p_overdue_penalty
			,@p_overdue_installment
			,@p_outstanding_installment
			,@p_status			
			,@p_fisical_status	
			,@p_rental_status	
			,@p_outstanding_deposit
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		set @p_code = @code ;
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
