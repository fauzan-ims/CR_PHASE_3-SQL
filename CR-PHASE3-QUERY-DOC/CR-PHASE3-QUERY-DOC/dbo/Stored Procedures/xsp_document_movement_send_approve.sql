CREATE PROCEDURE dbo.xsp_document_movement_send_approve
(
	@p_code			    nvarchar(50)
	,@p_approval_reff	nvarchar(250)
	,@p_approval_remark	nvarchar(4000)
	--
	,@p_mod_date	    datetime
	,@p_mod_by		    nvarchar(15)
	,@p_mod_ip_address  nvarchar(15)
)
as
begin
	declare @msg		   nvarchar(max) ;

	begin try
		if exists
		(
			select	1
			from	dbo.document_movement
			where	code	   = @p_code
					and movement_status = 'ON PROCESS'
		)
		begin 
			exec dbo.xsp_document_movement_send_post @p_code			= @p_code 
												     --
												     ,@p_mod_date		= @p_mod_date		
												     ,@p_mod_by			= @p_mod_by			
												     ,@p_mod_ip_address = @p_mod_ip_address
		end ;
		else
		begin
			set @msg = 'Data already proceed' ;

			raiserror(@msg, 16, -1) ;
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
