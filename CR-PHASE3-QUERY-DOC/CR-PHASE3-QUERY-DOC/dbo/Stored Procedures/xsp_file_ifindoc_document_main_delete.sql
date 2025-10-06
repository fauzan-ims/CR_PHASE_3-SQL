
CREATE procedure dbo.xsp_file_ifindoc_document_main_delete
(
	@p_doc_no	  nvarchar(50)
	,@p_module	  nvarchar(15)
	,@p_file_name nvarchar(250)
)
as
begin
	declare @msg	nvarchar(max)
			,@query nvarchar(max) ;

	begin try
		set @query = N'delete ' + 'file_' + @p_module + '_document_main' + ' where	doc_no = ''' + @p_doc_no + ''' and doc_name = ''' + @p_file_name + '''' ;

		execute sp_executesql @query ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
