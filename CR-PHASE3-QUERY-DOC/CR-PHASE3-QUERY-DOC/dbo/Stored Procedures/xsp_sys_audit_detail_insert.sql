CREATE PROCEDURE dbo.xsp_sys_audit_detail_insert
(
	@p_id			   bigint		 = 0 output
	,@p_audit_code	   nvarchar(50)
	,@p_date		   datetime
	,@p_progress	   nvarchar(250)
	,@p_remark		   nvarchar(4000)
	,@p_file_name	   nvarchar(250) = null
	,@p_file_paths	   nvarchar(250) = null
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
		if (cast(@p_date as date) > cast(dbo.xfn_get_system_date() as date))
		begin
			set @msg = 'Date must be less then or equal then System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into sys_audit_detail
		(
			audit_code
			,date
			,progress
			,remark
			,file_name
			,paths
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_audit_code
			,@p_date
			,@p_progress
			,@p_remark
			,@p_file_name
			,@p_file_paths
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
