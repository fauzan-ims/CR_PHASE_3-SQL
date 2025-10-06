CREATE PROCEDURE [dbo].[xsp_maintenance_return]
(
	@p_code			   nvarchar(50)
	,@p_remark_return	nvarchar(4000) = null
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@status		nvarchar(20)
			,@asset_code	nvarchar(50)
			-- Asqal 20-Oct-2022 ket : for WOM (+)
			,@company_code	nvarchar(50)
			,@code_replacement	nvarchar(50)
			,@year				nvarchar(4) 
			,@month				nvarchar(2)
			,@code				nvarchar(50)
			,@branch_code		nvarchar(50) = '1000'
	set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;


	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
												,@p_branch_code			 = @branch_code
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'MNHIST'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'MAINTENANCE_HISTORY'
												,@p_run_number_length	 = 5
												,@p_delimiter			= '.'
												,@p_run_number_only		 = '0' ;
	begin try  
		select	@status			= status
				,@asset_code	= asset_code
				,@company_code	= company_code
		from	dbo.maintenance
		where	code = @p_code ;

		if(isnull(@p_remark_return,'') = '')
		begin
			set @msg = 'Please input remark return.';
			raiserror(@msg ,16,-1);
		end

		if (@status = 'APPROVE')
		begin
			if exists
			(
				select	1
				from	ifinopl.dbo.asset_replacement					a
						inner join ifinopl.dbo.asset_replacement_detail b on b.replacement_code = a.code
				where	b.reff_no = @p_code
						and a.status not in
			(
				'HOLD', 'CANCEL'
			)
			)
			begin
				set @msg = N'Cannot Return, Because Transaction Replacement Has Been Posted' ;

				raiserror(@msg, 16, -1) ;
			end
			else
			begin
				select	@code_replacement = a.code
				from	ifinopl.dbo.asset_replacement					a
						inner join ifinopl.dbo.asset_replacement_detail b on a.code = b.replacement_code
				where	b.reff_no = @p_code ;

				update ifinopl.dbo.asset_replacement
				set status			= 'CANCEL'
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
				where code = @code_replacement
			end

			update	dbo.maintenance
			set		status			= 'HOLD'
					,count_return	= isnull(count_return,0) + 1
					,remark_return	= @p_remark_return
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code;

			insert into dbo.maintenance_history
			(
				code
				,company_code
				,asset_code
				,transaction_date
				,transaction_amount
				,branch_code
				,branch_name
				,requestor_code
				,requestor_name
				,division_code
				,division_name
				,department_code
				,department_name
				,maintenance_by
				,vendor_code
				,vendor_name
				,status
				,remark
				,actual_km
				,work_date
				,service_type
				,hour_meter
				,vendor_city_name
				,vendor_province_name
				,vendor_address
				,vendor_phone
				,vendor_bank_name
				,vendor_bank_account_no
				,vendor_bank_account_name
				,is_reimburse
				,bank_code
				,bank_name
				,bank_account_no
				,bank_account_name
				,spk_no
				,sa_vendor_name
				,sa_vendor_area_phone
				,sa_vendor_phone_no
				,vendor_npwp
				,vendor_type
				,free_service
				,last_km_service
				,nitku
				,npwp_pusat
				,file_name
				,file_path
				,estimated_start_date
				,estimated_finish_date
				,call_center_ticket_no
				,is_request_replacement
				,delivery_address
				,contact_name
				,contact_phone_no
				,reason_code
				,start_date
				,finish_date
				,remark_return
				,count_return
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
				,maintenance_code
			)
			select @code
				  ,company_code
				  ,asset_code
				  ,transaction_date
				  ,transaction_amount
				  ,branch_code
				  ,branch_name
				  ,requestor_code
				  ,requestor_name
				  ,division_code
				  ,division_name
				  ,department_code
				  ,department_name
				  ,maintenance_by
				  ,vendor_code
				  ,vendor_name
				  ,status
				  ,remark
				  ,actual_km
				  ,work_date
				  ,service_type
				  ,hour_meter
				  ,vendor_city_name
				  ,vendor_province_name
				  ,vendor_address
				  ,vendor_phone
				  ,vendor_bank_name
				  ,vendor_bank_account_no
				  ,vendor_bank_account_name
				  ,is_reimburse
				  ,bank_code
				  ,bank_name
				  ,bank_account_no
				  ,bank_account_name
				  ,spk_no
				  ,sa_vendor_name
				  ,sa_vendor_area_phone
				  ,sa_vendor_phone_no
				  ,vendor_npwp
				  ,vendor_type
				  ,free_service
				  ,last_km_service
				  ,nitku
				  ,npwp_pusat
				  ,file_name
				  ,file_path
				  ,estimated_start_date
				  ,estimated_finish_date
				  ,call_center_ticket_no
				  ,is_request_replacement
				  ,delivery_address
				  ,contact_name
				  ,contact_phone_no
				  ,reason_code
				  ,start_date
				  ,finish_date
				  ,remark_return
				  ,count_return
				  --
				  ,@p_mod_date
				  ,@p_mod_by
				  ,@p_mod_ip_address
				  ,@p_mod_date
				  ,@p_mod_by
				  ,@p_mod_ip_address 
				  ,CODE
			from dbo.maintenance
			where code = @p_code

			insert into dbo.maintenance_detail_history
			(
				maintenance_code
				,asset_maintenance_schedule_id
				,service_code
				,service_name
				,file_name
				,path
				,service_type
				,service_fee
				,quantity
				,pph_amount
				,ppn_amount
				,total_amount
				,payment_amount
				,tax_code
				,tax_name
				,ppn_pct
				,pph_pct
				,part_number
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select maintenance_code
				  ,asset_maintenance_schedule_id
				  ,service_code
				  ,service_name
				  ,file_name
				  ,path
				  ,service_type
				  ,service_fee
				  ,quantity
				  ,pph_amount
				  ,ppn_amount
				  ,total_amount
				  ,payment_amount
				  ,tax_code
				  ,tax_name
				  ,ppn_pct
				  ,pph_pct
				  ,part_number
				  --
				  ,@p_mod_date
				  ,@p_mod_by
				  ,@p_mod_ip_address
				  ,@p_mod_date
				  ,@p_mod_by
				  ,@p_mod_ip_address  
			from dbo.maintenance_detail
			where maintenance_code = @p_code


			update dbo.asset
			set    status	= 'STOCK'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @asset_code;

			-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'RTRQTR'
			--												,@p_doc_code		= @p_code
			--												,@p_attachment_flag = 0
			--												,@p_attachment_file = ''
			--												,@p_attachment_path = ''
			--												,@p_company_code	= @company_code
			--												,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'MAINTENANCE'
			-- End of send mail attachment based on setting ================================================

		end
		else
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg ,16,-1);
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
