CREATE PROCEDURE [dbo].[xsp_application_external_data_insert]
(
	@p_application_no		nvarchar(50)
	,@p_reff_name			nvarchar(250)  = null
	,@p_reff_value_datatype nvarchar(50)   = null
	,@p_reff_value_string	nvarchar(50)   = null
	,@p_reff_value_number	decimal(18, 2) = 0
	,@p_remark				nvarchar(4000) = ''
	---
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists
		(
			select	1
			from	application_external_data
			where	reff_name		   = @p_reff_name
					and remark		   = @p_remark
					and application_no = @p_application_no
		)
		begin
			update	dbo.application_external_data
			set		reff_value_datatype = @p_reff_value_datatype
					,reff_value_string  = @p_reff_value_string
					,reff_value_number  = @p_reff_value_number
			where	reff_name			= @p_reff_name
					and remark			= @p_remark ;
		end ;
		else
		begin
			insert into dbo.application_external_data
			(
				application_no
				,reff_name
				,reff_value_datatype
				,reff_value_string
				,reff_value_number
				,remark
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
				@p_application_no
				,@p_reff_name
				,@p_reff_value_datatype
				,@p_reff_value_string
				,@p_reff_value_number
				,@p_remark
				--	
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;
		end ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
