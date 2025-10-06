CREATE procedure dbo.xsp_invoice_delivery_deail_upload_file_update
(
	@p_id			   bigint
	,@p_file_name	   nvarchar(250)
	,@p_file_paths	   nvarchar(250)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	update	dbo.invoice_delivery_detail
	set		file_name		= upper(@p_file_name)
			,file_path		= upper(@p_file_paths)
			--
			,mod_date		= @p_mod_date
			,mod_by			= @p_mod_by
			,mod_ip_address	= @p_mod_ip_address
	where	id = @p_id ;
end ;
