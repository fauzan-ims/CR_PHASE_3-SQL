CREATE PROCEDURE dbo.xsp_sys_branch_update
(
	@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_is_custody_branch	nvarchar(1)
	,@p_custody_branch_code nvarchar(50)  = ''
	,@p_custody_branch_name nvarchar(250) = ''
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_custody_branch = 'T'
		set @p_is_custody_branch = '1' ;
	else
		set @p_is_custody_branch = '0' ;

	begin try
		update	sys_branch
		set		branch_name				= @p_branch_name
				,is_custody_branch		= @p_is_custody_branch
				,custody_branch_code	= @p_custody_branch_code
				,custody_branch_name	= @p_custody_branch_name
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	branch_code				= @p_branch_code ;

		/* perubahan 5.0.1 untuk apabila ada perubahan settingan, update ke transaksi document juga */
		if(@p_custody_branch_code = '')
		begin
			set @p_custody_branch_code = null
			set @p_custody_branch_name = null
		end

		update	document_main
		set		custody_branch_code		= isnull(@p_custody_branch_code, @p_branch_code)
				,custody_branch_name	= isnull(@p_custody_branch_name, @p_branch_name)
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	branch_code				= @p_branch_code ;
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
