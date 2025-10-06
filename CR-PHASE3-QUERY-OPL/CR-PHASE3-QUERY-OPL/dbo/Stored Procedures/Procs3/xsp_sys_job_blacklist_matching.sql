CREATE PROCEDURE dbo.xsp_sys_job_blacklist_matching
(
	@p_job_code			nvarchar(50)
	,@p_status			nvarchar(1) output
)
as
begin
	declare @msg		nvarchar(max)					
	
	begin try
		if exists (select 1 from dbo.sys_job_tasklist where code = @p_job_code and is_active = '1')
		begin
			set @p_status = 1 ;
		end
		else
		begin
		    set @p_status = 0 ;
		end
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
