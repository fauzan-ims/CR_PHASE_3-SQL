CREATE PROCEDURE [dbo].[xsp_ifinproc_interface_document_upload_insert]
(
	@p_id						bigint
	,@p_reff_no					nvarchar(50)
	,@p_reff_name				nvarchar(250)
	,@p_reff_trx_code			nvarchar(50)
	,@p_file_name				nvarchar(250)
	,@p_file_path				nvarchar(250)	= ''
	,@p_doc_file				varbinary(max)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max);

	begin try
		insert into dbo.proc_interface_sys_document_upload
		(
			reff_no
			,reff_name
			,reff_trx_code
			,file_name
			,file_path
			,doc_file
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_reff_no
			,@p_reff_name
			,@p_reff_trx_code
			,@p_file_name
			,@p_file_path
			,@p_doc_file
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_id = @@identity ;
	end try
	Begin catch
		declare @error int ;

		set @error = @@error ;

		--if (@error = 2627)
		--begin
		--	set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		--end ;

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

