/*
exec xsp_job_eod_asset_aging
*/
create PROCEDURE dbo.xsp_job_eod_asset_aging
as
begin

	declare @msg								nvarchar(max)  
            ,@mod_date							datetime = getdate()
			,@mod_by							nvarchar(15) ='EOD'
			,@mod_ip_address					nvarchar(15) ='SYSTEM'


	begin try
		begin			

			insert into dbo.asset_aging
			(
				aging_date
				,code
				,item_code
				,status
				,fisical_status
				,insurance_status
				,claim_status
				,rental_status
				,rental_reff_no
				,reserved_by
				,reserved_date
				,purchase_price
				,original_price
				,sale_amount
				,sale_date
				,disposal_date
				,pic_code
				,pic_name
				,residual_value
				,depre_category_comm_code
				,total_depre_comm
				,depre_period_comm
				,net_book_value_comm
				,depre_category_fiscal_code
				,total_depre_fiscal
				,depre_period_fiscal
				,net_book_value_fiscal
				,is_rental
				,is_maintenance
				,use_life
				,asset_purpose
				,asset_from
				,parking_location
				,process_status
				,agreement_no
				,client_name
				,start_period_date
				,end_period_date
				,wo_no
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select dbo.xfn_get_system_date()
					,code
					,item_code
					,status
					,fisical_status
					,insurance_status
					,claim_status
					,rental_status
					,rental_reff_no
					,reserved_by
					,reserved_date
					,purchase_price
					,original_price
					,sale_amount
					,sale_date
					,disposal_date
					,pic_code
					,pic_name
					,residual_value
					,depre_category_comm_code
					,total_depre_comm
					,depre_period_comm
					,net_book_value_comm
					,depre_category_fiscal_code
					,total_depre_fiscal
					,depre_period_fiscal
					,net_book_value_fiscal
					,is_rental
					,is_maintenance
					,use_life
					,asset_purpose
					,asset_from
					,parking_location
					,process_status
					,agreement_no
					,client_name
					,start_period_date
					,end_period_date
					,wo_no
					--
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from dbo.asset
			
		end
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;There is an error.' + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
	
end
	

