CREATE PROCEDURE dbo.xsp_register_main_proceed
(
	@p_code					nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
    
	declare	@msg					    nvarchar(max)
			,@dp_from_cust_amount	    decimal(18,2)
			,@register_status		    nvarchar(20)
			,@process_by			    nvarchar(50)
			,@branch_code			    nvarchar(50)
			,@branch_name			    nvarchar(250)
			,@register_date			    datetime
			,@remarks				    nvarchar(4000)
			,@doc_reff_name				nvarchar(250)
			,@fa_code				    nvarchar(50)
			,@currency_code			    nvarchar(5)
			,@interface_code		    nvarchar(50)
			,@system_date				datetime = dbo.xfn_get_system_date()
			,@item_name					nvarchar(250)

	begin try
	
		select	@register_status		= register_status
				,@process_by			= register_process_by
				,@branch_code			= rm.branch_code
				,@branch_name			= rm.branch_name
				,@register_date			= register_date
				,@fa_code				= fa_code
				,@item_name				= ass.item_name
		from	dbo.register_main rm
		inner join dbo.asset ass on ass.code = rm.fa_code
		where	rm.code = @p_code

		if(@process_by = 'CUSTOMER')
		begin
			set @remarks = 'RECEIVED ADMINISTRATION FEE PUBLIC SERVICE FOR ' + @fa_code + ' ' + @item_name
			set @doc_reff_name = 'ADMINISTRATION FEE'
		end
		else
		begin
			set @remarks = 'RECEIVED DP BY CLIENT AMOUNT FOR ' + @fa_code + ' ' + @item_name
			set @doc_reff_name = 'DP BY CLIENT AMOUNT'
		end
		
		if @register_status <> 'HOLD'
		begin
			set @msg = 'Data already proceed.'
			raiserror(@msg ,16,-1)
		end
		
		--if exists (select 1 from dbo.register_document where register_code = @p_code and isnull(file_name,'') = '')
		--begin
		--	set @msg = 'Please upload at least 1 document'
		--	raiserror(@msg ,16,-1)
		--end

		if not exists (select 1 from dbo.register_detail where register_code = @p_code)
		begin
			set @msg = 'Please add at least 1 service'
			raiserror(@msg ,16,-1)
		end

		--exec dbo.xsp_ams_interface_cashier_received_request_insert @p_code						= @interface_code output                
		--                                                          ,@p_branch_code				= @branch_code
		--                                                          ,@p_branch_name				= @branch_name
		--                                                          ,@p_request_status			= 'HOLD'
		--                                                          ,@p_request_currency_code		= 'IDR'
		--                                                          ,@p_request_date				= @system_date              
		--                                                          ,@p_request_remarks			= @remarks
		--                                                          ,@p_fa_code					= @fa_code
		--                                                          ,@p_pdc_code					= ''    
		--                                                          ,@p_pdc_no					= ''      
		--                                                          ,@p_doc_ref_code				= @p_code
		--                                                          ,@p_doc_ref_name				= @doc_reff_name
		--                                                          ,@p_process_date				= null
		--                                                          ,@p_process_reff_no			= ''
		--                                                          ,@p_process_reff_name			= ''
		--                                                          ,@p_cre_date					= @p_cre_date
		--                                                          ,@p_cre_by					= @p_cre_by
		--                                                          ,@p_cre_ip_address			= @p_cre_ip_address
		--                                                          ,@p_mod_date					= @p_mod_date
		--                                                          ,@p_mod_by					= @p_mod_by
		--                                                          ,@p_mod_ip_address			= @p_mod_ip_address


		update	dbo.register_main
		set		register_status				= 'ON PROCESS'
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code = @p_code

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


