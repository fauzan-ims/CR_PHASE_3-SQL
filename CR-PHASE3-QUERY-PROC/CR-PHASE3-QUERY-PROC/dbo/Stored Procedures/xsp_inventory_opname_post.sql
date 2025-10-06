CREATE PROCEDURE dbo.xsp_inventory_opname_post
(
	 @p_code					 nvarchar(50)
	,@p_company_code			 nvarchar(50)
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
			
	begin try
		set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;
		
		select	@status				= iop.status
		from	dbo.inventory_opname iop
		where	iop.code = @p_code ;

		if (@status = 'ON PROCESS')
			begin
					update	dbo.inventory_opname
					set		status = 'POST'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
					where	code = @p_code ;
			end
		else
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg ,16,-1);
		end	

		select	 
				 @branch_code				= branch_code				
				,@branch_name       		= branch_name				
				,@warehouse_code			= warehouse_code
				,@item_code					= item_code
				,@item_name					= item_name
		from	dbo.inventory_opname
		where	code = @p_code

		begin

			declare @p_id bigint;
			exec dbo.xsp_inventory_card_insert	 @p_id = @p_id output               
												,@p_company_code				= @p_company_code
												,@p_branch_code                	= @branch_code
												,@p_branch_name                	= @branch_name
												,@p_transaction_code           	= @p_code
												,@p_transaction_type           	= 'OPN'
												,@p_transaction_period         	= ''
												,@p_item_code                  	= @item_code
												,@p_item_name                  	= @item_name
												,@p_warehouse_code             	= @warehouse_code
												,@p_plus_or_minus              	= '1'
												,@p_quantity                    = 0
												,@p_on_hand_quantity            = 0
												,@p_cre_date					= @p_mod_date				
												,@p_cre_by						= @p_mod_by				
												,@p_cre_ip_address				= @p_mod_ip_address		
												,@p_mod_date					= @p_mod_date				
												,@p_mod_by						= @p_mod_by				
												,@p_mod_ip_address				= @p_mod_ip_address ;	
			
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

