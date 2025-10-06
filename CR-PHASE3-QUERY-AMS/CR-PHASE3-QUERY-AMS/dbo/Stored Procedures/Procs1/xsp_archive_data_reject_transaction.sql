CREATE PROCEDURE dbo.xsp_archive_data_reject_transaction
as
begin
	declare @msg		nvarchar(max) ;

	begin try
		
		/*
			Untuk mengarsipkan data yang berstatus reject setelah transaksi date lebih besar dari parameter
		*/

		-- Asset Upload
		exec dbo.xsp_asset_upload_archived 
		
		-- Asset
		exec dbo.xsp_asset_archived  
		
		-- Mutation
		exec dbo.xsp_mutation_archived  
		
		-- Disposal
		exec dbo.xsp_disposal_archived  
		
		-- Reverse Disposal
		exec dbo.xsp_reverse_disposal_archived  
		
		-- Sale
		exec dbo.xsp_sale_archived  
		
		-- Reverse Sale
		exec dbo.xsp_reverse_sale_archived  
		
		-- Maintenance
		exec dbo.xsp_maintenance_archived  
		
		-- Opname
		exec dbo.xsp_opname_archived  
		
		-- Adjustment
		exec dbo.xsp_adjustment_archived  
		
		-- Change Category
		exec dbo.xsp_change_category_archived  
		
		-- Change Item Type
		exec dbo.xsp_change_item_type_archived  
		

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


