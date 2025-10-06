CREATE PROCEDURE [dbo].[xsp_clean_data_delete]
as
begin
	declare @msg nvarchar(max) ;

	begin try
		-- company, company user, group role, subscription history
		truncate table dbo.ASSET_BARCODE_HISTORY
		truncate table dbo.ASSET_BARCODE_IMAGE
		truncate table dbo.ASSET_DEPRECIATION
		truncate table dbo.ASSET_DEPRECIATION_SCHEDULE_COMMERCIAL
		truncate table dbo.ASSET_DEPRECIATION_SCHEDULE_FISCAL
		truncate table dbo.ASSET_DOCUMENT
		truncate table dbo.ASSET_ELECTRONIC
		truncate table dbo.ASSET_FURNITURE
		truncate table dbo.ASSET_MACHINE
		truncate table dbo.ASSET_MAINTENANCE_SCHEDULE
		truncate table dbo.ASSET_MUTATION_HISTORY
		truncate table dbo.ASSET_OTHER
		truncate table dbo.ASSET_PROPERTY
		truncate table dbo.ASSET_VEHICLE
		delete dbo.ASSET

		truncate table dbo.MUTATION_DETAIL
		truncate table dbo.MUTATION_DOCUMENT
		delete dbo.MUTATION
		
		truncate table dbo.DISPOSAL_DETAIL
		truncate table dbo.DISPOSAL_DOCUMENT
		delete dbo.DISPOSAL
		
		--truncate table dbo.SALE_BIDDING_DETAIL
		--delete dbo.SALE_BIDDING
		truncate table dbo.SALE_DETAIL
		truncate table dbo.SALE_DOCUMENT
		delete dbo.SALE

		truncate table dbo.MAINTENANCE_DETAIL
		delete dbo.MAINTENANCE
		
		truncate table dbo.OPNAME_DETAIL
		delete dbo.OPNAME

		truncate table dbo.MASTER_DEPRE_CATEGORY_FISCAL
		truncate table MASTER_DEPRE_CATEGORY_COMMERCIAL
		truncate table dbo.MASTER_CATEGORY
		truncate table dbo.MASTER_LOCATION
		truncate table dbo.MASTER_BARCODE_REGISTER_DETAIL
		delete dbo.MASTER_BARCODE_REGISTER

		truncate table ASSET_EXPENSE_LEDGER
		truncate table ASSET_INCOME_LEDGER
		truncate table INSURANCE_POLICY_ASSET_COVERAGE
		delete INSURANCE_POLICY_ASSET

		truncate table INSURANCE_POLICY_MAIN_LOADING
		truncate table INSURANCE_POLICY_MAIN_PERIOD
		delete INSURANCE_POLICY_MAIN

		truncate table MASTER_AUCTION_ADDRESS
		truncate table MASTER_AUCTION_BANK
		truncate table MASTER_AUCTION_BRANCH
		truncate table MASTER_AUCTION_DOCUMENT
		delete MASTER_AUCTION

		truncate table MASTER_INSURANCE_ADDRESS
		truncate table MASTER_INSURANCE_BANK
		truncate table MASTER_INSURANCE_BRANCH
		truncate table MASTER_INSURANCE_DEPRECIATION
		truncate table MASTER_INSURANCE_DOCUMENT
		truncate table MASTER_INSURANCE_FEE
		delete MASTER_INSURANCE

		truncate table MASTER_PUBLIC_SERVICE_ADDRESS
		truncate table MASTER_PUBLIC_SERVICE_BANK
		truncate table MASTER_PUBLIC_SERVICE_BRANCH
		truncate table MASTER_PUBLIC_SERVICE_DOCUMENT
		delete MASTER_PUBLIC_SERVICE

		truncate table REGISTER_DOCUMENT
		truncate table REGISTER_DETAIL
		delete REGISTER_MAIN

		truncate table WORK_ORDER_DETAIL
		delete WORK_ORDER

		--truncate table dbo.SYS_COMPANY_USER_RESET_PASSWORD
		--truncate table dbo.SYS_COMPANY_USER_MAIN_GROUP_SEC
		--truncate table dbo.SYS_COMPANY_USER_MAIN
		--truncate table dbo.SYS_COMPANY_USER_LOGIN_LOG
		--truncate table dbo.SYS_COMPANY_USER_HISTORY_PASSWORD
		--truncate table dbo.SYS_COMPANY
		--truncate table dbo.SYS_EMPLOYEE_NOTIFICATION_SUBSCRIPTION
		--truncate table dbo.SYS_EMPLOYEE_WIDGET_SUBSCRIPTION
		--truncate table dbo.SYS_EOD_TASK_LIST_LOG
		--delete dbo.SYS_EOD_TASK_LIST
		--truncate table dbo.SYS_GENERAL_CODE
		--truncate table dbo.SYS_GENERAL_SUBCODE
		--truncate table dbo.SYS_GLOBAL_PARAM
		----truncate table dbo.SYS_IT_PARAM
		--truncate table dbo.SYS_MENU_ROLE
		--delete dbo.SYS_MENU
		--delete dbo.SYS_MODULE
		--delete dbo.SYS_NOTIFICATION
		--truncate table dbo.SYS_REPORT
		--truncate table dbo.SYS_ROLE_GROUP
		--truncate table dbo.SYS_ROLE_GROUP_DETAIL
		--truncate table dbo.SYS_TODO

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




