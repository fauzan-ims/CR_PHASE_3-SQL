CREATE PROCEDURE [dbo].[xsp_rpt_listing_data_master]
(
	@p_table_name nvarchar(100)
)
as
begin
	declare @msg nvarchar(max) 
			,@value	nvarchar(max)

	begin TRY
    
			set @value = 'SELECT * FROM .dbo.' + @p_table_name
			exec sp_executesql @value

		--if (@p_table_name = 'MASTER_DEPRECIATION')
		--begin
		--	select code
		--		  ,depreciation_name
		--		  ,case is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from dbo.master_depreciation
		--end ;
		--else if (@p_table_name = 'MASTER_APPROVAL_DIMENSION')
		--begin
		--	select id
		--		  ,approval_code
		--		  ,reff_dimension_code
		--		  ,reff_dimension_name
		--		  ,dimension_code
		--	from dbo.master_approval_dimension
		--end ;
		--else if (@p_table_name = 'MASTER_CUSTOM_REPORT_COLUMN')
		--begin
		--	select id
		--		  ,custom_report_code
		--		  ,column_name
		--		  ,header_name
		--		  ,order_key
		--	from dbo.master_custom_report_column
		--end ;
		--else if (@p_table_name = 'MASTER_COVERAGE_LOADING')
		--begin
		--	select code
		--		  ,loading_name
		--		  ,loading_type
		--		  ,age_from
		--		  ,age_to
		--		  ,rate_type
		--		  ,buy_amount
		--		  ,sell_amount
		--		  ,buy_rate_pct
		--		  ,sale_rate_pct
		--		  ,case is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from dbo.master_coverage_loading
		--end ;
		--else if (@p_table_name = 'MASTER_ITEM')
		--begin   

		--	select code
		--		   ,company_code
		--		   ,transaction_type
		--		   ,item_group_code
		--		   ,merk_code
		--		   ,model_code
		--		   ,type_code
		--		   ,uom_code
		--		   ,type_asset_code
		--		   ,fa_category_code
		--		   ,fa_category_name
		--		   ,po_latest_price
		--		   ,po_average_price
		--		   ,description
		--		   ,is_rent
		--		   ,case is_active
		--		   	 when '1' then 'Yes'
		--		   	 else 'No'
		--		    end 'is_active'
		--	from dbo.master_item
		--end ;
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
