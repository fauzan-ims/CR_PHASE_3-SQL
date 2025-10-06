--created by, Rian at 08/05/2023 

CREATE PROCEDURE [dbo].[xsp_application_doc_update_is_valid]
(
	@p_application_no  nvarchar(50)
	,@p_id			   bigint
	,@p_is_valid	   nvarchar(1)
	,@p_remarks		   nvarchar(4000) = ''
	,@p_is_received	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if @p_is_valid = 'T'
			set @p_is_valid = '1' ;
		else
			set @p_is_valid = '0' ;

		if @p_is_received = 'T'
			set @p_is_received = '1' ;
		else
			set @p_is_received = '0' ;

		update	dbo.application_doc
		set		is_valid			= @p_is_valid
				,remarks			= @p_remarks
				,is_received		= @p_is_received
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	application_no		= @p_application_no
				and id				= @p_id ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
