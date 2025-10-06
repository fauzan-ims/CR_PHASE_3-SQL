CREATE PROCEDURE dbo.xsp_master_upload_tabel_column_update
(
	@p_code								nvarchar(50)
	,@p_upload_tabel_code				nvarchar(50)
	,@p_column_name						nvarchar(50)
	,@p_data_type						nvarchar(10)
	,@p_order_key						nvarchar(10)
	--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin

	declare @msg			nvarchar(max)	
	

	begin try
		
		if exists
		(
			select	1
			from	master_upload_tabel_column
			where	code <> @p_code
			and		upload_tabel_code	= @p_upload_tabel_code
			and		order_key			= @p_order_key

		)
		begin
			set @msg = 'Order Key already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	dbo.master_upload_tabel_column
		set		data_type		= @p_data_type
				,order_key		= @p_order_key
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code

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
