CREATE PROCEDURE dbo.xsp_efam_journal_reverse_disposal_register
(
	@p_reverse_disposal_code nvarchar(50)
	,@p_process_code		 nvarchar(50) --- code general subcode
	,@p_company_code		 nvarchar(50)
	,@p_reff_source_no		 nvarchar(50)
	,@p_reff_source_name	 nvarchar(250) 
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@asset_code			nvarchar(50)
			,@gllink_trx_code		nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@sp_name				nvarchar(250)
			,@debit_or_credit		nvarchar(50)
			,@gl_link_code			nvarchar(50)
			,@transaction_name		nvarchar(250)
			,@currency_code			nvarchar(3)	  = 'IDR'
			,@exch_rate				decimal(18, 2) = 1
			,@amount				decimal(18, 2)
			,@orig_amount_db		decimal(18, 2)
			,@orig_amount_cr		decimal(18, 2)
			,@base_amount			decimal(18, 2)
			,@base_amount_db		decimal(18, 2)
			,@base_amount_cr		decimal(18, 2)
			,@description			nvarchar(250)
			,@asset_name			nvarchar(250)
			,@disposal_remark		nvarchar(250)
			,@detail_remark			nvarchar(250)
			,@x_code				nvarchar(50) 
			,@cost_center_code		nvarchar(50)
			,@cost_center_name		nvarchar(250)
			,@company_code			nvarchar(50)
			,@category_code			nvarchar(50)
			,@purchase_price		decimal(18,2)
			,@is_valid				int
			,@disp_code				nvarchar(50)
			,@trx_date				datetime
			,@last_jurnal_code		nvarchar(50) ;

	begin try

		--- select branch
		select	@branch_code	= branch_code
				,@branch_name	= branch_name
				,@company_code	= company_code
				,@description	= 'REVERSAL FIXED ASSET DISPOSAL '+ remarks
				,@disp_code		= disposal_code
				,@trx_date		= reverse_disposal_date
		from	dbo.reverse_disposal
		where	code = @p_reverse_disposal_code ;
		 

		exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gllink_trx_code output
																	   ,@p_company_code				= @p_company_code
																	   ,@p_branch_code				= @branch_code
																	   ,@p_branch_name				= @branch_name
																	   ,@p_transaction_status		= 'HOLD'
																	   ,@p_transaction_date			= @trx_date
																	   ,@p_transaction_value_date	= @trx_date
																	   ,@p_transaction_code			= @p_reverse_disposal_code
																	   ,@p_transaction_name			= @description
																	   ,@p_reff_module_code			= 'EFAM'
																	   ,@p_reff_source_no			= @p_reverse_disposal_code
																	   ,@p_reff_source_name			= 'REVERSE - ASSET DISPOSAL'
																	   ,@p_transaction_type			= 'FAMRDS'
																	   ---
																	   ,@p_cre_date					= @p_mod_date	  
																	   ,@p_cre_by					= @p_mod_by		  
																	   ,@p_cre_ip_address			= @p_mod_ip_address
																	   ,@p_mod_date					= @p_mod_date	  
																	   ,@p_mod_by					= @p_mod_by		  
																	   ,@p_mod_ip_address			= @p_mod_ip_address
 
			-- cursor assets
			declare c_reverse_disposal_asset cursor fast_forward for
			select	asset_code
					,ast.item_name
					,dd.description
					,dd.cost_center_code
					,dd.cost_center_name
					,ast.category_code
					,ast.purchase_price
			from	dbo.reverse_disposal_detail dd
					inner join dbo.asset ast on ast.code = dd.asset_code
			where	reverse_disposal_code = @p_reverse_disposal_code ;

			open c_reverse_disposal_asset ;

			fetch c_reverse_disposal_asset
			into @asset_code
				 ,@asset_name
				 ,@disposal_remark 
				 ,@cost_center_code
				 ,@cost_center_name
				 ,@category_code
				 ,@purchase_price;

			while @@fetch_status = 0
			begin
				
				select	top 1 @last_jurnal_code = hd.code
				from	dbo.efam_interface_journal_gl_link_transaction_detail dt
						inner join dbo.efam_interface_journal_gl_link_transaction hd on hd.code = dt.gl_link_transaction_code
				where	agreement_no = @asset_code
				and		hd.transaction_code = @disp_code
				order by hd.id desc

				insert into dbo.efam_interface_journal_gl_link_transaction_detail
				    (gl_link_transaction_code
				    ,company_code
				    ,branch_code
				    ,branch_name
				    ,cost_center_code
				    ,cost_center_name
				    ,gl_link_code
				    ,contra_gl_link_code
				    ,agreement_no
				    ,facility_code
				    ,facility_name
				    ,purpose_loan_code
				    ,purpose_loan_name
				    ,purpose_loan_detail_code
				    ,purpose_loan_detail_name
				    ,orig_currency_code
				    ,orig_amount_db
				    ,orig_amount_cr
				    ,exch_rate
				    ,base_amount_db
				    ,base_amount_cr
				    ,division_code
				    ,division_name
				    ,department_code
				    ,department_name
				    ,remarks
				    ,cre_date
				    ,cre_by
				    ,cre_ip_address
				    ,mod_date
				    ,mod_by
				    ,mod_ip_address
				    )
				select @gllink_trx_code
						,dt.company_code
						,dt.branch_code
						,dt.branch_name
						,cost_center_code
						,cost_center_name
						,gl_link_code
						,contra_gl_link_code
						,agreement_no
						,facility_code
						,facility_name
						,purpose_loan_code
						,purpose_loan_name
						,purpose_loan_detail_code
						,purpose_loan_detail_name
						,orig_currency_code
						,orig_amount_cr
						,orig_amount_db
						,exch_rate
						,base_amount_cr
						,base_amount_db
						,division_code
						,division_name
						,department_code
						,department_name
						,remarks
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.efam_interface_journal_gl_link_transaction_detail dt
						inner join dbo.efam_interface_journal_gl_link_transaction hd on hd.code = dt.gl_link_transaction_code
				where	hd.code = @last_jurnal_code -- Arga 05-Nov-2022 ket : for case multiple reverse with the same asset (+)
				and		agreement_no = @asset_code -- Arga 12-Nov-2022 ket : for case partial reverse by asset (+)
				 
				fetch c_reverse_disposal_asset
				into @asset_code
					 ,@asset_name
					 ,@disposal_remark 
					 ,@cost_center_code
					 ,@cost_center_name
					 ,@category_code
					 ,@purchase_price;
			end ;

			close c_reverse_disposal_asset ;
			deallocate c_reverse_disposal_asset ;

		 
		
		-- data validation
		if not exists (select 1 from dbo.efam_interface_journal_gl_link_transaction_detail where gl_link_transaction_code = @gllink_trx_code)
		begin
			delete dbo.efam_interface_journal_gl_link_transaction where code = @gllink_trx_code
		end
		else
		begin
			select @msg = dbo.xfn_journal_validation(@gllink_trx_code)
			if (@msg <> '')
			begin
				set @msg += '. Your Transaction Journal Number is ' + @gllink_trx_code
				raiserror(@msg, 16, -1) ;
			end
		end

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
