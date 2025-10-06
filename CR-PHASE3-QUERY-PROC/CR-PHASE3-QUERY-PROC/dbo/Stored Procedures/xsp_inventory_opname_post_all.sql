CREATE PROCEDURE dbo.xsp_inventory_opname_post_all
(
	@p_company_code			 nvarchar(50)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@id							bigint
			,@id1							bigint
			,@code							nvarchar(50)
			,@year							nvarchar(2)
			,@month							nvarchar(2)
			,@item_group_code				nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@item_code						nvarchar(50)
			,@item_name						nvarchar(250)
			,@supplier_code					nvarchar(50)
			,@requestor_code				nvarchar(50)
			,@status						nvarchar(50)
			,@warehouse_code				nvarchar(50)
			,@plus_or_minus					nvarchar(1)
			,@count							int
			,@date							datetime
			,@code_detail					nvarchar(50)
			,@date_detail					datetime = getdate()
			,@quantity_deviation			int;
			
	begin try
				--select	@status				= iop.status
				--from	dbo.inventory_opname iop
				--where	iop.company_code = @p_company_code ;

				--if (@status = 'ON PROCESS')
				--begin
				--		update	dbo.inventory_opname
				--		set		status = 'POST'
				--			--
				--			,mod_date		= @p_mod_date
				--			,mod_by			= @p_mod_by
				--			,mod_ip_address = @p_mod_ip_address
				--		where	company_code = @p_company_code ;
				--end
				--else
				--begin
				--	set @msg = 'Please Proceed Before Posting';
				--	raiserror(@msg ,16,-1);
				--end	
														 													 
				declare curr_inven_adjust_detail cursor fast_forward read_only for

				select item_code
						,item_name
						,warehouse_code
						,quantity_deviation
						,branch_code
						,branch_name
						,status
				from dbo.inventory_opname 
				where status = 'ON PROCESS'

				if exists(select * from dbo.inventory_opname where status = 'ON PROCESS' and company_code = @p_company_code)
				begin
				
					open curr_inven_adjust_detail
					
					fetch next from curr_inven_adjust_detail 
					into @item_code
						,@item_name
						,@warehouse_code
						,@quantity_deviation
						,@branch_code
						,@branch_name
						,@status
					
					while @@fetch_status = 0
					begin

					if(@quantity_deviation < 0)
					begin
						set @plus_or_minus = '0'
					end
					else
					begin
						set @plus_or_minus = '1'
					end

					if exists(select * from dbo.inventory_adjustment where status = 'NEW' and branch_code = @branch_code and company_code = @p_company_code)
					begin
						select @code_detail = code 
						from dbo.inventory_adjustment 
						where status = 'NEW' 
						and branch_code = @branch_code
					end
					else
					begin
						exec dbo.xsp_inventory_adjustment_insert @p_code				 = @code_detail output
																,@p_company_code		 = @p_company_code
																,@p_adjustment_date		 = @date_detail
																,@p_branch_code			 = @branch_code
																,@p_branch_name			 = @branch_name
																,@p_division_code		 = 'IT'
																,@p_division_name		 = 'INFORMATION TECHNOLOGY'
																,@p_department_code		 = 'PRG'
																,@p_department_name		 = 'PROGRAMMER'
																,@p_sub_department_code  = 'JPRG'
																,@p_sub_department_name  = 'JUNIOR PROGRAMMER'
																,@p_units_code			 = 'PTRC'
																,@p_units_name			 = 'PERMANENT CONTRACT'
																,@p_reason				 = 'ADJUSTMENT'
																,@p_remark				 = 'ADJUST INVENTORY OPNAME'
																,@p_status				 = 'NEW'
																,@p_cre_date			 = @p_mod_date		
																,@p_cre_by				 = @p_mod_by			
																,@p_cre_ip_address		 = @p_mod_ip_address
																,@p_mod_date			 = @p_mod_date		
																,@p_mod_by				 = @p_mod_by			
																,@p_mod_ip_address		 = @p_mod_ip_address
					end
						exec dbo.xsp_inventory_adjustment_detail_insert @p_id							 = 0
																		,@p_inventory_adjustment_code	 = @code_detail
																		,@p_item_code					 = @item_code
																		,@p_item_name					 = @item_name
																		,@p_plus_or_minus				 = @plus_or_minus
																		,@p_warehouse_code				 = @warehouse_code
																		,@p_total_adjustment			 = @quantity_deviation
																		,@p_remark						 = 'ADJUSTMENT INVENTORY OPNAME'
																		,@p_cre_date					 = @p_mod_date		
																		,@p_cre_by						 = @p_mod_by		
																		,@p_cre_ip_address				 = @p_mod_ip_address
																		,@p_mod_date					 = @p_mod_date		
																		,@p_mod_by						 = @p_mod_by		
																		,@p_mod_ip_address				 = @p_mod_ip_address
						
					    
					    fetch next from curr_inven_adjust_detail 
						into @item_code
							,@item_name
							,@warehouse_code
							,@quantity_deviation
							,@branch_code
							,@branch_name
							,@status
					end
					
					close curr_inven_adjust_detail
					deallocate curr_inven_adjust_detail

					update	dbo.inventory_opname
					set		status = 'POST'
							--
							,mod_date		= @p_mod_date
							,mod_by			= @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	company_code	= @p_company_code
					and		status = 'ON PROCESS' ;
				end
				else
				begin
					set @msg = 'Please Proceed Before Posting';
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

