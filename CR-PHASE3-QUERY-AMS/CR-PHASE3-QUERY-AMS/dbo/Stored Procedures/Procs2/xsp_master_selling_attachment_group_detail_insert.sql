CREATE PROCEDURE [dbo].[xsp_master_selling_attachment_group_detail_insert]
(
	@p_id						bigint = 0	output
	,@p_document_group_code		nvarchar(50)
	,@p_general_doc_code		nvarchar(50)
	,@p_is_required				nvarchar(1) = '0'
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
	declare @msg nvarchar(max) ;

	--if @p_is_required = 'T'
	--	set @p_is_required = '1'
	--else
	--	set @p_is_required = '0'

	begin try
	insert into dbo.master_selling_attachment_group_detail
	(
		document_group_code
		,general_doc_code
		,is_required
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
		@p_document_group_code
		,@p_general_doc_code
		,@p_is_required
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	)

	set @p_id = @@IDENTITY

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
