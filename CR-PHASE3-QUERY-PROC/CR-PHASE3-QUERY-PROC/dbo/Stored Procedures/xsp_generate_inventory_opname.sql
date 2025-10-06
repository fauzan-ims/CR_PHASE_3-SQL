CREATE PROCEDURE dbo.xsp_generate_inventory_opname
(
	@p_company_code		nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by		    nvarchar(15)
	,@p_mod_ip_address  nvarchar(15)
)
as
begin
	declare @msg				 nvarchar(max)
			,@code				 nvarchar(50) 
			,@branch_code		 nvarchar(50)
			,@branch_name		 nvarchar(250)
			,@warehouse_code	 nvarchar(50)
			,@date				 datetime = dbo.xfn_get_system_date()
			,@item_code			 nvarchar(50)
			,@item_name			 nvarchar(250)
			,@uom_code			 nvarchar(50)
			,@uom_name			 nvarchar(250)
			,@stock_quantity	 int
			,@status			 nvarchar(50)

	begin try

		if exists(select 1 from dbo.inventory_opname where status = 'NEW' and company_code = @p_company_code)
		begin		
			set @msg = 'Please Proceed or Post The Data';
			raiserror(@msg ,16,-1)
		end
		else
		begin
			declare curr_inventory_opname cursor fast_forward read_only for 
			select branch_code
					,branch_name
					,warehouse_code
					,item_code
					,item_name
					,mi.uom_code
					,mu.description
					,ic.on_hand_quantity
			from dbo.inventory_card ic
			inner join ifinbam.dbo.master_item mi on mi.code = ic.item_code collate sql_latin1_general_cp1_ci_as and mi.company_code = ic.company_code collate sql_latin1_general_cp1_ci_as
			inner join ifinbam.dbo.master_uom mu on mu.code = mi.uom_code collate sql_latin1_general_cp1_ci_as and mu.company_code = mi.company_code collate sql_latin1_general_cp1_ci_as
			where warehouse_code <> ''

			open curr_inventory_opname
			
			fetch next from curr_inventory_opname 
			into @branch_code
				,@branch_name
				,@warehouse_code
				,@item_code
				,@item_name
				,@uom_code
				,@uom_name
				,@stock_quantity
			
			while @@fetch_status = 0
			begin
			    
			    exec dbo.xsp_inventory_opname_insert @p_code				 = @code output
			    									 ,@p_company_code		 = @p_company_code
			    									 ,@p_opname_date		 = @date
			    									 ,@p_branch_code		 = @branch_code
			    									 ,@p_branch_name		 = @branch_name
			    									 ,@p_warehouse_code		 = @warehouse_code
			    									 ,@p_item_code			 = @item_code
			    									 ,@p_item_name			 = @item_name
			    									 ,@p_uom_code			 = @uom_code
			    									 ,@p_uom_name			 = @uom_name
			    									 ,@p_quantity_stock		 = @stock_quantity
			    									 ,@p_quantity_opname	 = 0
			    									 ,@p_quantity_deviation	 = 0
			    									 ,@p_status				 = 'NEW'
			    									 ,@p_cre_date			 = @p_mod_date		
			    									 ,@p_cre_by				 = @p_mod_by		  
			    									 ,@p_cre_ip_address		 = @p_mod_ip_address
			    									 ,@p_mod_date			 = @p_mod_date		
			    									 ,@p_mod_by				 = @p_mod_by		  
			    									 ,@p_mod_ip_address		 = @p_mod_ip_address
			    		    
			
			    fetch next from curr_inventory_opname 
				into @branch_code
					,@branch_name
					,@warehouse_code
					,@item_code
					,@item_name
					,@uom_code
					,@uom_name
					,@stock_quantity
			end
			
			close curr_inventory_opname
			deallocate curr_inventory_opname
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

