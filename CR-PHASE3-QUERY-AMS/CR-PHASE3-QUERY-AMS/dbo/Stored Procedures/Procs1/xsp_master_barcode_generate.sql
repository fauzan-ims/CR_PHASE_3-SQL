create PROCEDURE dbo.xsp_master_barcode_generate
(
	@p_no_of_data				int
	,@p_prefix_code				nvarchar(50)
	,@p_running_code			nvarchar(50)
	,@p_postfix_code			nvarchar(50)	= ''
	,@p_barcode_register_code	nvarchar(50)
	--
	,@p_mod_by					nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_ip_address			nvarchar(15)
)as
begin
	declare	@counter		int = 1
			,@barcode_no	nvarchar(50)
			,@len			int = len(@p_running_code);
	

	delete	dbo.master_barcode_register_detail
	where	barcode_register_code = @p_barcode_register_code;

	while (@counter <= @p_no_of_data)
	begin
		set @barcode_no = isnull(@p_prefix_code, '') + @p_running_code + cast(@counter as nvarchar(10)) + isnull(@p_postfix_code, '');
		--set @barcode_no = isnull(@p_prefix_code, '') + right(@p_running_code + @counter, @len) + isnull(@p_postfix_code, '');
		--set @barcode_no = isnull(@p_prefix_code, '') + right(convert(int, @p_running_code) + @counter, @len) + isnull(@p_postfix_code, '');

		exec dbo.xsp_master_barcode_register_detail_insert @p_barcode_no				 = @barcode_no
														   ,@p_barcode_register_code	 = @p_barcode_register_code
														   ,@p_asset_code				 = '-'
														   ,@p_status					 = 'UNUSED'
														   ,@p_cre_date					 = @p_mod_date		
														   ,@p_cre_by					 = @p_mod_by		
														   ,@p_cre_ip_address			 = @p_mod_ip_address	
														   ,@p_mod_date					 = @p_mod_date		
														   ,@p_mod_by					 = @p_mod_by	
														   ,@p_mod_ip_address			 = @p_mod_ip_address;
				
		set @counter += 1;
	end
	
end

