CREATE PROCEDURE dbo.xsp_master_category_fiscal_active
(
	@p_code				nvarchar(50)
	,@p_company_code	nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg		  nvarchar(max)
			,@is_editable nvarchar(1) ;

	begin try
		select	@is_editable = is_active
		from	dbo.master_depre_category_fiscal
		where	code = @p_code 
		and		company_code = @p_company_code;

		if (@is_editable = '1')
			set @is_editable = '0' ;
		else
			set @is_editable = '1' ;

		update	dbo.master_depre_category_fiscal
		set		is_active		= @is_editable
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code
		and		company_code	= @p_company_code ;
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
