CREATE PROCEDURE dbo.xsp_claim_doc_insert
(
	@p_id					  bigint = 0 output
	,@p_claim_code			  nvarchar(50)
	,@p_document_code			nvarchar(50)
	,@p_document_name			nvarchar(250)
	--,@p_document_date		  datetime = null
	,@p_document_remarks	  nvarchar(4000) = ''
	--,@p_file_name			  nvarchar(250) = null
	--,@p_paths				  nvarchar(250) = null
	--,@p_is_required			  nvarchar(1) = '0'
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into claim_doc
		(
			claim_code
			,document_code
			,document_name
			--,document_date
			,document_remarks
			--,file_name
			--,paths
			--,is_required
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_claim_code
			,@p_document_code
			,@p_document_name
			--,@p_document_date
			,@p_document_remarks
			--,@p_file_name
			--,@p_paths
			--,@p_is_required
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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

