---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_document_contract_update
(
	@p_code			   nvarchar(50)
	,@p_description	   nvarchar(250)
	,@p_document_type  nvarchar(4)
	,@p_template_name  nvarchar(250) = ''
	,@p_rpt_name	   nvarchar(250) = ''
	,@p_sp_name		   nvarchar(250)
	,@p_table_name	   nvarchar(250)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists
		(
			select	1
			from	master_document_contract
			where	description = @p_description
					and code	<> @p_code
		)
		begin
			set @msg = 'Description already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	master_document_contract
		set		description		= upper(@p_description)
				,document_type	= @p_document_type
				,template_name	= upper(@p_template_name)
				,rpt_name		= lower(@p_rpt_name)
				,sp_name		= lower(@p_sp_name)
				,table_name		= upper(@p_table_name)
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;
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

