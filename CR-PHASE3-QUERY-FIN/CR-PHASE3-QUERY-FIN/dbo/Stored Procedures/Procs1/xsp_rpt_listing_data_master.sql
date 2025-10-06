CREATE PROCEDURE [dbo].[xsp_rpt_listing_data_master]
(
	@p_table_name nvarchar(100)
)
as
BEGIN

	declare @msg nvarchar(max) 
			,@value	nvarchar(max)

	begin TRY
		
		--
		--
		--MASTER_UPLOAD_TABEL_COLUMN
		--MASTER_UPLOAD_TABEL_VALIDATION
		--MASTER_UPLOAD_TABLE
		--MASTER_UPLOAD_VALIDATION
				
		set @value = 'SELECT * FROM .dbo.' + @p_table_name
		exec sp_executesql @value	

		--if (@p_table_name = 'MASTER_ACCOUNT_PAYABLE')
		--begin
			
		--	select	code
  --                  ,ap_code
  --                  ,remarks
  --                  ,case is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	FROM	master_account_payable 

		--end ;
		--else if (@p_table_name = 'MASTER_ACCOUNT_PAYABLE_DETAIL')
		--begin
			
		--	select	mapd.account_payable_code
		--			,map.ap_code
  --                  ,mapd.payment_source
		--	from	master_account_payable_detail mapd
		--			inner join dbo.master_account_payable map on (map.code = mapd.account_payable_code)
		--end ;
		--else if (@p_table_name = 'MASTER_CASHIER_QUESTION')
		--begin
			
		--	select	code
		--			,description
		--			,case is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_cashier_question

		--end ;
		--else if (@p_table_name = 'MASTER_CASHIER_PRIORITY')
		--begin
			
		--	select	code
		--			,description
		--			,case is_default
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_cashier_priority

		--end ;
		--else if (@p_table_name = 'MASTER_CASHIER_PRIORITY_DETAIL')
		--begin
			
		--	select	mcpd.cashier_priority_code
		--			,mcp.description 'cashier_priority_name'
		--			,mcpd.order_no
		--			,mcpd.transaction_code
		--			,mt.transaction_name
		--			,case mcpd.is_partial
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_partial'
		--	from	master_cashier_priority_detail mcpd
		--			inner join dbo.master_transaction mt		on (mcpd.transaction_code = mt.code)
		--			inner join  master_cashier_priority mcp		on (mcpd.cashier_priority_code = mcp.code)

		--end ;
		--else if (@p_table_name = 'MASTER_BANKNOTE_AND_COIN')
		--begin
			
		--	select code
  --                 ,description
  --                 ,type
  --                 ,value_amount
  --                 ,case is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_partial'
		--	from dbo.master_banknote_and_coin

		--end ;
		--else if (@p_table_name = 'MASTER_OJK_REFERENCE')
		--begin
			
		--	select	mor.code
  --                  ,mor.description
  --                  ,mor.reference_type_code
		--			,sgs.description 'reference_type_name'
		--			,mor.ojk_code
		--			,case mor.is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 	'is_active'
		--	from	master_ojk_reference mor
		--			inner join dbo.sys_general_subcode sgs on (sgs.code = mor.reference_type_code)
		--end ;
		--else if (@p_table_name = 'MASTER_TAX')
		--begin
			
		--	select	code
		--			,tax_file_type
		--			,description
		--			,case is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 	'is_active'
		--	from	dbo.master_tax

		--end ;
		--else if (@p_table_name = 'MASTER_TAX_DETAIL')
		--begin
			
		--	select	mtd.tax_code
		--			,mt.description 'tax_name'
  --                  ,convert(varchar(30), mtd.effective_date, 103) 'effective_date' 
  --                  ,mtd.from_value_amount
  --                  ,mtd.to_value_amount
  --                  ,mtd.with_tax_number_pct
  --                  ,mtd.without_tax_number_pct
		--	from	dbo.master_tax_detail mtd
		--			inner join dbo.master_tax mt on (mt.code = mtd.tax_code)

		--end ;
		--else if (@p_table_name = 'MASTER_DASHBOARD')
		--begin
			
		--	select	code
		--			,dashboard_name
		--			,case dashboard_type
		--				 when 'column' then 'Column'
		--				 when 'pie' then 'Pie'
		--				 when 'bar' then 'Bar'
		--				 when 'line' then 'Line'
		--				 when 'spline' then 'Spline'
		--			 end 'dashboard_type'
		--			,case dashboard_grid
		--				 when 'col-md-12' then 'Full'
		--				 when 'col-md-6' then 'Half'
		--				 when 'col-md-4' then 'Third'
		--				 when 'col-md-3' then 'Quarter'
		--			 end 'dashboard_grid'
		--			,sp_name
		--			,case is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--			,case is_editable
		--				 when '1' then 'YES'
		--				 else 'NO'
		--			 end 'is_editable'
		--	from	master_dashboard

		--end ;
		--else if (@p_table_name = 'MASTER_DASHBOARD_USER')
		--begin
			
		--	select	mdu.dashboard_code
		--			,md.dashboard_name
		--			,mdu.employee_code
  --                  ,mdu.employee_name
		--			,case md.dashboard_grid
		--				 when 'col-md-12' then 'Full'
		--				 when 'col-md-6' then 'Half'
		--				 when 'col-md-4' then 'Third'
		--				 when 'col-md-3' then 'Quarter'
		--			 end 'dashboard_grid'
		--			,mdu.order_key
		--	from	master_dashboard_user mdu
		--			inner join dbo.master_dashboard md on (md.code = mdu.dashboard_code)

		--end ;
		--else if (@p_table_name = 'MASTER_REVERSAL_VALIDATION')
		--begin
			
		--	select	name
  --                  ,module_code
  --                  ,process_name
  --                  ,api_validation
		--	from	master_reversal_validation 

		--end ;
		--else if (@p_table_name = 'MASTER_TRANSACTION')
		--begin
			
		--	SELECT	mt.code
		--			,mt.transaction_name
		--			,mt.module_name
		--			,mt.gl_link_code
		--			,jgl.gl_link_name
		--			,CASE mt.is_active
		--				 WHEN '1' THEN 'Yes'
		--				 ELSE 'No'
		--			 END 	'is_active'
		--			,CASE mt.is_calculated
		--				 WHEN '1' THEN 'Yes'
		--				 ELSE 'No'
		--			 END 	'is_calculated'
		--	from	dbo.master_transaction mt
		--			left join journal_gl_link jgl on (jgl.code = mt.gl_link_code)

		--end ;
		--else if (@p_table_name = 'MASTER_UPLOAD_TABLE')
		--begin
			
		--	select	code
  --                  ,description
  --                  ,tabel_name
  --                  ,template_name
  --                  ,sp_getrows_name
  --                  ,sp_validate_name
  --                  ,sp_upload_name
  --                  ,sp_post_name
  --                  ,sp_cancel_name
  --                  ,case is_active
		--				WHEN '1' then 'Yes'
		--				ELSE 'No'
		--			end 'is_active'
		--	FROM	master_upload_table
			
		--end ;
		--else if (@p_table_name = 'MASTER_UPLOAD_TABEL_COLUMN')
		--begin
			
		--	select	mutc.code
		--			,mutc.upload_tabel_code
		--			,mut.description 'upload_table_name'
		--			,mutc.column_name
		--			,(select stuff((
		--					   select ' '+upper(left(T3.V, 1))+lower(stuff(T3.V, 1, 1, ''))
		--					   from (select cast(replace((select data_type as '*' for xml path('')), ' ', '<X/>') as xml).query('.')) as T1(X)
		--						 cross apply T1.X.nodes('text()') as T2(X)
		--						 cross apply (select T2.X.value('.', 'varchar(250)')) as T3(V)
		--					   for xml path(''), type
		--					   ).value('text()[1]', 'varchar(30)'), 1, 1, '') as [Capitalize first letter only]) 'data_type'
		--			,substring(order_key,8,2) 'order_key'
		--	from	dbo.master_upload_tabel_column mutc
		--			left join dbo.master_upload_table  mut on (mut.code = mutc.upload_tabel_code)
			
		--end ;
		--else if (@p_table_name = 'MASTER_UPLOAD_TABEL_VALIDATION')
		--begin
			
		--	select	mutv.upload_tabel_column_code
		--			,mut.description 'upload_table_name'
		--			,mutc.column_name
		--			,mutv.upload_validation_code
		--			,muvd.description 'upload_validation_name'
		--			,mutv.param_generic_1
		--			,mutv.param_generic_2
		--	from	dbo.master_upload_tabel_validation mutv
		--			left join dbo.master_upload_tabel_column mutc	ON (mutc.code = mutv.upload_tabel_column_code)
		--			left join dbo.master_upload_table  mut			ON (mut.code = mutc.upload_tabel_code)
		--			left join dbo.master_upload_validation muvd		ON (muvd.code = mutv.upload_validation_code)

		--end ;
		--else if (@p_table_name = 'MASTER_UPLOAD_VALIDATION')
		--begin
			
		--	select	code
		--			,description
		--			,sp_name
		--			,case is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_upload_validation

		--end ;
		--else if (@p_table_name = 'MASTER_APPROVAL')
		--begin
		--	select	code
		--			,approval_name
		--			,reff_approval_category_code
		--			,reff_approval_category_name
		--			,case is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_approval ;
		--end ;
		--else if (@p_table_name = 'MASTER_APPROVAL_DIMENSION')
		--begin
		--	select	id
		--			,approval_code
		--			,reff_dimension_code
		--			,reff_dimension_name
		--			,dimension_code
		--	from	dbo.master_approval_dimension ;
		--end ;
		--else if (@p_table_name = 'MASTER_FAQ')
		--begin
		--	select	question
		--			,answer
		--			,filename
		--			,paths
		--			,case is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_faq ;
		--end ;

	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg,16,-1) ;

		return ;
	end catch ;
end ;
