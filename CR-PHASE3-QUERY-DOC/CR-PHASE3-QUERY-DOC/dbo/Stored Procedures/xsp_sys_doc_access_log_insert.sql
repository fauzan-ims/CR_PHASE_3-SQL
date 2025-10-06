CREATE PROCEDURE dbo.xsp_sys_doc_access_log_insert
(
	@p_id			   bigint		 = 0 output
	,@p_module		   nvarchar(50)
	,@p_header		   nvarchar(250)
	,@p_child		   nvarchar(50)
	,@p_acess_type	   nvarchar(250)
	,@p_file_name	   nvarchar(250)
	,@p_print_by_code  nvarchar(50)	  = ''
	,@p_print_by_name  nvarchar(250)  = ''
	,@p_print_by_ip	   nvarchar(50)	  = ''
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.sys_doc_access_log
		(
			module_name
			,transaction_name
			,transaction_no
			,access_date
			,acess_type
			,file_name
			,print_by_code
			,print_by_name
			,print_by_ip
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_module
			,@p_header
			,@p_child
			,@p_cre_date
			,@p_acess_type
			,@p_file_name
			,@p_cre_by
			,@p_print_by_name
			,@p_cre_ip_address
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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
