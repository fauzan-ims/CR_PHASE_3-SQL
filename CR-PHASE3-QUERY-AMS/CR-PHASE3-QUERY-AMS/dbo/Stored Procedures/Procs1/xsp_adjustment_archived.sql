CREATE PROCEDURE dbo.xsp_adjustment_archived 
as
begin
	declare @msg						nvarchar(max)
			,@max_value					int	
			,@code						nvarchar(50)
			,@company_code				nvarchar(50)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@date						datetime
			,@adjustment_type			nvarchar(50)
			,@new_purchase_date			datetime
			,@asset_code				nvarchar(50)
			,@cost_center_code			nvarchar(50)
			,@cost_center_name			nvarchar(250)
			,@old_netbook_value_fiscal	decimal(18, 2)
			,@old_netbook_value_comm	decimal(18, 2)
			,@new_netbook_value_fiscal	decimal(18, 2)
			,@new_netbook_value_comm	decimal(18, 2)
			,@total_adjustment			decimal(18, 2)
			,@payment_by				nvarchar(50)
			,@vendor_code				nvarchar(50)
			,@vendor_name				nvarchar(250)
			,@status					nvarchar(20)
			,@description				nvarchar(4000)
			,@remark					nvarchar(4000)
			,@purchase_price			decimal(18, 2)
			,@old_total_depre_comm		decimal(18, 2)
			--
			,@description_detail		nvarchar(4000)
			--
			,@file_name_doc				nvarchar(250)
			,@path_doc					nvarchar(250)
			,@description_doc			nvarchar(400)
			,@cre_date					datetime
			,@cre_by					nvarchar(50)
			,@cre_ip_address			nvarchar(15)
			,@mod_date					datetime
			,@mod_by					nvarchar(50)
			,@mod_ip_address			nvarchar(15) ;

	begin try 
		declare @code_adjustment as table
		(
			code nvarchar(50)
		)

		select	@max_value = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MAD'

		declare c_adjustment_trx cursor fast_forward read_only for 
		select	code
				,company_code
				,branch_code
				,branch_name
				,date
				,adjustment_type
				,new_purchase_date
				,description
				,asset_code
				,old_netbook_value_fiscal
				,old_netbook_value_comm
				,new_netbook_value_fiscal
				,new_netbook_value_comm
				,total_adjustment
				,payment_by
				,vendor_code
				,vendor_name
				,remark
				,status
				,purchase_price
				,old_total_depre_comm
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
		from	dbo.adjustment 
		where	status in ('REJECT', 'CANCEL')
		and		datediff(month,date, dbo.xfn_get_system_date()) > @max_value ;

		open c_adjustment_trx
		
		fetch next from c_adjustment_trx 
		into	@code
				,@company_code
				,@branch_code
				,@branch_name
				,@date
				,@adjustment_type
				,@new_purchase_date
				,@description
				,@asset_code
				,@cost_center_code
				,@cost_center_name
				,@old_netbook_value_fiscal
				,@old_netbook_value_comm
				,@new_netbook_value_fiscal
				,@new_netbook_value_comm
				,@total_adjustment
				,@payment_by
				,@vendor_code
				,@vendor_name
				,@remark
				,@status
				,@purchase_price
				,@old_total_depre_comm
				,@cre_date
				,@cre_by
				,@cre_ip_address
				,@mod_date
				,@mod_by
				,@mod_ip_address
		
		while @@fetch_status = 0
		begin
		    
			exec dbo.xsp_adjustment_history_insert @p_code							= @code
													,@p_company_code				= @company_code
													,@p_branch_code					= @branch_code
													,@p_branch_name					= @branch_name
													,@p_date						= @date
													,@p_adjustment_type				= @adjustment_type
													,@p_new_purchase_date			= @new_purchase_date
													,@p_description					= @description
													,@p_asset_code					= @asset_code
													,@p_cost_center_code			= @cost_center_code
													,@p_cost_center_name			= @cost_center_name
													,@p_old_netbook_value_fiscal	= @old_netbook_value_fiscal
													,@p_old_netbook_value_comm		= @old_netbook_value_comm
													,@p_new_netbook_value_fiscal	= @new_netbook_value_fiscal
													,@p_new_netbook_value_comm		= @new_netbook_value_comm
													,@p_total_adjustment			= @total_adjustment
													,@p_payment_by					= @payment_by
													,@p_vendor_code					= @vendor_code
													,@p_vendor_name					= @vendor_name
													,@p_purchase_price				= @purchase_price
													,@p_old_total_depre_comm		= @old_total_depre_comm
													,@p_remark						= @remark
													,@p_status						= @status
													--
													,@p_cre_date					= @cre_date
													,@p_cre_by						= @cre_by
													,@p_cre_ip_address				= @cre_ip_address
													,@p_mod_date					= @mod_date
													,@p_mod_by						= @mod_by
													,@p_mod_ip_address				= @mod_ip_address ;
			
			-- adjustment Detail
			insert into dbo.adjustment_detail_history
			(
			    adjustment_code
				,adjusment_transaction_code
				,amount
				,currency_code
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select   adjustment_code
					,adjusment_transaction_code
					,amount
					,currency_code	
					--		
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
			from	dbo.adjustment_detail 
			where	adjustment_code = @code ;
			
			insert into dbo.adjustment_document_history
			(
			    adjustment_code
				,file_name
				,path
				,description
				,cre_by
				,cre_date
				,cre_ip_address
				,mod_by
				,mod_date
				,mod_ip_address
			)
			select	adjustment_code
					,file_name
					,path
					,description
					,cre_by
					,cre_date
					,cre_ip_address
					,mod_by
					,mod_date
					,mod_ip_address 
			from	dbo.adjustment_document
			where	adjustment_code = @code ;


			insert into @code_adjustment
			(
			    code
			)
			values 
			(
				@code
			)

		    fetch next from c_adjustment_trx 
			into	@code
					,@company_code
					,@branch_code
					,@branch_name
					,@date
					,@adjustment_type
					,@new_purchase_date
					,@description
					,@asset_code
					,@cost_center_code
					,@cost_center_name
					,@old_netbook_value_fiscal
					,@old_netbook_value_comm
					,@new_netbook_value_fiscal
					,@new_netbook_value_comm
					,@total_adjustment
					,@payment_by
					,@vendor_code
					,@vendor_name
					,@remark
					,@status
					,@purchase_price
					,@old_total_depre_comm
					,@cre_date
					,@cre_by
					,@cre_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
		end
		
		close c_adjustment_trx
		deallocate c_adjustment_trx
		
		-- delete data
		delete	dbo.adjustment 
		where	code in (select code collate latin1_general_ci_as from @code_adjustment) ;

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

