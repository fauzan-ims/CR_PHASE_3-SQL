CREATE PROCEDURE dbo.xsp_mutation_document_history_update
(
	@p_id					bigint
	,@p_mutation_code		nvarchar(50)
	,@p_file_name			nvarchar(250)
	,@p_path				nvarchar(250)
	,@p_description			nvarchar(400)
	,@p_mod_by				nvarchar(15)
		--
	,@p_mod_date			datetime
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	mutation_document_history
		set		mutation_code	= @p_mutation_code
				,file_name		= @p_file_name
				,path			= @p_path
				,description	= @p_description
				,mod_by			= @p_mod_by
					--
				,mod_date		= @p_mod_date
				,mod_ip_address	= @p_mod_ip_address
		where	id	= @p_id

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
