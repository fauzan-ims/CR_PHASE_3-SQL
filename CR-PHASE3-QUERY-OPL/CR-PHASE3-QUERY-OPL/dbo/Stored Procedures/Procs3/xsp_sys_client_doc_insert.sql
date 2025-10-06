CREATE PROCEDURE dbo.xsp_sys_client_doc_insert
(
	@p_code			   nvarchar(50)
	,@p_client_code	   nvarchar(50)
	,@p_doc_type	   nvarchar(50)
	,@p_doc_no		   nvarchar(50)
	,@p_doc_status	   nvarchar(50)
	,@p_eff_date	   datetime
	,@p_exp_date	   datetime
	,@p_is_default	   nvarchar(1)
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

	if @p_is_default = 'T'
		set @p_is_default = '1' ;
	else
		set @p_is_default = '0' ;

	begin try
	
		if exists (select 1 from sys_general_subcode_detail where code = @p_code)
		begin
    		SET @msg = 'Code already exist';
    		raiserror(@msg, 16, -1) ;
		end

		insert into sys_client_doc
		(
			code
			,client_code
			,doc_type
			,doc_no
			,doc_status
			,eff_date
			,exp_date
			,is_default
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_client_code
			,@p_doc_type
			,@p_doc_no
			,@p_doc_status
			,@p_eff_date
			,@p_exp_date
			,@p_is_default
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

