

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_update
(
	 @p_code							nvarchar (50)
	,@p_branch_code						nvarchar (50)  
	,@p_branch_name						nvarchar (50)  
	,@p_date							datetime       
	,@p_remarks							nvarchar (4000)
	,@p_status							nvarchar (20)  
	--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@system_date		datetime

	begin try
	
	set @system_date = dbo.xfn_get_system_date()

	if (cast(@p_date as date) > cast(@system_date as date))
	begin
	    set @msg = 'Date Cannot Bigger Than System Date'
		raiserror(@msg, 16, -1)
	end

		update	dbo.faktur_no_replacement
		set		 branch_code	= @p_branch_code	
				,branch_name	= @p_branch_name	
				,date			= @p_date		
				,remarks		= @p_remarks		
				,status			= @p_status		
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	 code			= @p_code ;
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
