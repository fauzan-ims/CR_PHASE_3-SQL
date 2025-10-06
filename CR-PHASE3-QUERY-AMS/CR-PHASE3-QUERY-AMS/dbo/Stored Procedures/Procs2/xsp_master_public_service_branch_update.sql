CREATE PROCEDURE dbo.xsp_master_public_service_branch_update
(
	@p_code					nvarchar(50)
	,@p_public_service_code nvarchar(50)
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin TRY
    
		if exists
		(
			select	1
			from	dbo.master_public_service_branch
			where	branch_name = @p_branch_name
			and		public_service_code = @p_public_service_code
			and		code <> @p_code
		)
		begin
			set @msg = 'Branch already exist 1' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	master_public_service_branch
		set		public_service_code = @p_public_service_code
				,branch_code		= @p_branch_code
				,branch_name		= @p_branch_name
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;
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



