CREATE PROCEDURE dbo.xsp_supplier_selection_detail_update
(
	 @p_id						bigint
	,@p_unit_available_status	nvarchar(25)
	,@p_indent_days				int					= 0
	,@p_offering				nvarchar(4000)		= ''
		--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if @p_unit_available_status='READY'
		begin
			set @p_indent_days = null ;
		end ;

		update	supplier_selection_detail
		set		unit_available_status			= @p_unit_available_status
				,offering						= @p_offering
				,indent_days					= @p_indent_days
					--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	id	= @p_id ;

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
