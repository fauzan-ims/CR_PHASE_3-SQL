CREATE PROCEDURE dbo.xsp_claim_doc_update
(
	@p_id					  bigint
	,@p_document_date		  datetime = NULL
    ,@p_document_remarks	  nvarchar(4000) = ''
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;
	begin try
    if (cast(@p_document_date as date) < dbo.xfn_get_system_date())
		begin
			set @msg ='Document Date must be greater than System Date';
			raiserror(@msg,16,1) ;
		end
		update	claim_doc
		set		document_date		= @p_document_date
				,document_remarks	= @p_document_remarks
				---
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;
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

