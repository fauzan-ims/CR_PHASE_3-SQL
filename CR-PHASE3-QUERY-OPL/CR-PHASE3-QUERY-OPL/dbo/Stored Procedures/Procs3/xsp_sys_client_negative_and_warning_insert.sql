CREATE PROCEDURE dbo.xsp_sys_client_negative_and_warning_insert
(
	@p_code				   nvarchar(50)
	,@p_status			   nvarchar(10)
	,@p_source			   nvarchar(250)
	,@p_client_type		   nvarchar(20)
	,@p_client_id		   nvarchar(50)
	,@p_fullname		   nvarchar(100)
	,@p_mother_maiden_name nvarchar(50)
	,@p_dob				   datetime
	,@p_id_no			   nvarchar(50)
	,@p_tax_file_no		   nvarchar(50)
	,@p_est_date		   datetime
	,@p_entry_date		   datetime
	,@p_entry_reason	   nvarchar(4000)
	,@p_exit_date		   datetime
	,@p_exit_reason		   nvarchar(4000)
	--
	,@p_cre_date		   datetime
	,@p_cre_by			   nvarchar(15)
	,@p_cre_ip_address	   nvarchar(15)
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
	
		if exists (select 1 from sys_general_subcode_detail where code = @p_code)
		begin
    		SET @msg = 'Code already exist';
    		raiserror(@msg, 16, -1) ;
		end

		insert into sys_client_negative_and_warning
		(
			code
			,status
			,source
			,client_type
			,client_id
			,fullname
			,mother_maiden_name
			,dob
			,id_no
			,tax_file_no
			,est_date
			,entry_date
			,entry_reason
			,exit_date
			,exit_reason
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
			,@p_status
			,@p_source
			,@p_client_type
			,@p_client_id
			,@p_fullname
			,@p_mother_maiden_name
			,@p_dob
			,@p_id_no
			,@p_tax_file_no
			,@p_est_date
			,@p_entry_date
			,@p_entry_reason
			,@p_exit_date
			,@p_exit_reason
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
	end try
	Begin catch
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

