CREATE PROCEDURE [dbo].[xsp_job_pull_interface_asset]
(
	@p_company_code	   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg   nvarchar(max)
			,@code nvarchar(50) ;

	begin try
		declare c_asset cursor fast_forward read_only for
		select	code
		from	ifinproc.dbo.eproc_interface_asset with (nolock)
		where	company_code = 'DSF'
				and status = 'NEW'
				and code not in
					(
						select	ast.code
						from	dbo.asset ast
						where ast.status <> 'AVAILABLE'
					) ;

		open c_asset ;

		fetch next from c_asset
		into @code ;

		while @@fetch_status = 0
		begin
			insert into dbo.efam_interface_asset
			(
				code
				,company_code
				,item_code
				,item_name
				,condition
				,barcode
				,status
				,po_no
				,requestor_code
				,requestor_name
				,vendor_code
				,vendor_name
				,type_code
				,category_code
				,purchase_date
				,purchase_price
				,invoice_no
				,invoice_date
				,original_price
				,sale_amount
				,sale_date
				,disposal_date
				,branch_code
				,branch_name
				--,location_code
				,division_code
				,division_name
				,department_code
				,department_name
				--,sub_department_code
				--,sub_department_name
				--,units_code
				--,units_name
				,pic_code
				,residual_value
				,depre_category_comm_code
				,total_depre_comm
				,depre_period_comm
				,net_book_value_comm
				,depre_category_fiscal_code
				,total_depre_fiscal
				,depre_period_fiscal
				,net_book_value_fiscal
				,contractor_name
				,contractor_address
				,contractor_email
				,contractor_pic
				,contractor_pic_phone
				,contractor_start_date
				,contractor_end_date
				,warranty
				,warranty_start_date
				,warranty_end_date
				,remarks_warranty
				,is_maintenance
				,maintenance_time
				,maintenance_type
				,maintenance_cycle_time
				,maintenance_start_date
				,remarks
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
				,is_gps
			)
			select	code
					,company_code
					,isnull(item_code, null)
					,isnull(item_name, null)
					,isnull(condition, null)
					,isnull(barcode, null)
					,isnull(status, null)
					,isnull(po_no, null)
					,isnull(requestor_code, null)
					,isnull(requestor_name, null)
					,isnull(vendor_code, null)
					,isnull(vendor_name, null)
					,isnull(type_code, null)
					,isnull(category_code, null)
					,isnull(purchase_date, null)
					,isnull(purchase_price, 0)
					,isnull(invoice_no, null)
					,isnull(invoice_date, null)
					,isnull(original_price, 0)
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(branch_code, null)
					,isnull(branch_name, null)
					--,isnull(location_code, null)
					,isnull(division_code, null)
					,isnull(division_name, null)
					,isnull(department_code, null)
					,isnull(department_name, null)
					--,isnull(sub_department_code, null)
					--,isnull(sub_department_name, null)
					--,isnull(units_code, null)
					--,isnull(units_name, null)
					,isnull(null, null)
					,isnull(null, 0)
					,isnull(null, '')
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, 0)
					,isnull(null, '')
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, null)
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, 0)
					,isnull(null, null)
					,isnull(null, null)
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
					,isnull(is_gps,'0')
			from	ifinproc.dbo.eproc_interface_asset
			where	code = @code ;

			update ifinproc.dbo.eproc_interface_asset
			set status = 'POST'
			where code = @code

			fetch next from c_asset
			into @code ;
		end ;

		close c_asset ;
		deallocate c_asset ;
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

