CREATE PROCEDURE dbo.xsp_application_external_data_update
(
	@p_id					bigint 
	,@p_reff_name			nvarchar(250)
	,@p_reff_value			nvarchar(250)
	,@p_reff_value_datatype nvarchar(50)
	,@p_reff_value_string	nvarchar(50)
	,@p_reff_value_number	decimal(18, 2)
	,@p_remark				nvarchar(4000)
	---
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	dbo.application_external_data
		set		reff_name = @p_reff_name
				,reff_value = @p_reff_value
				,reff_value_datatype = @p_reff_value_datatype
				,reff_value_string = @p_reff_value_string
				,reff_value_number = @p_reff_value_number
				,remark = @p_remark
				---						 --
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id = @p_id ;
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
