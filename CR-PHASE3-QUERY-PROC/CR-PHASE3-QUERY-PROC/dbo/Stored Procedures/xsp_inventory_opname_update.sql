CREATE PROCEDURE dbo.xsp_inventory_opname_update
(
 	 @p_code				nvarchar(50)
	,@p_company_code		nvarchar(50)
	--,@p_opname_date			datetime
	--,@p_branch_code			nvarchar(50)
	--,@p_branch_name			nvarchar(250)
	--,@p_warehouse_code		nvarchar(50)
	--,@p_item_code			nvarchar(50)
	--,@p_item_name			nvarchar(250)
	--,@p_uom_code			nvarchar(50)
	--,@p_uom_name			nvarchar(250)
	--,@p_quantity_stock		int
	,@p_quantity_opname		int
	--,@p_quantity_deviation	int
	--,@p_status				nvarchar(25)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@quantitiy_stock	int
			,@result			int;

	

	begin try		
		
		update inventory_opname
		set
				-- opname_date		= @p_opname_date
				--,branch_code		= @p_branch_code
				--,branch_name		= @p_branch_name
				--,warehouse_code		= @p_warehouse_code
				--,item_code			= @p_item_code
				--,item_name			= @p_item_name
				--,uom_code			= @p_uom_code
				--,uom_name			= @p_uom_name
				--,quantity_stock		= @p_quantity_stock
				quantity_opname	= @p_quantity_opname
				,quantity_deviation	=  @p_quantity_opname - quantity_stock
				--,status				= @p_status
					--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where		code			= @p_code
				and company_code	= @p_company_code

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
end
