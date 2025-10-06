CREATE PROCEDURE [dbo].[xsp_sys_job_tasklist_update]
(
	 @p_code					 nvarchar(50)
	 ,@p_description			 nvarchar(250)
	 ,@p_sp_name				 nvarchar(250)
	 ,@p_order_no				 int
	 ,@p_row_to_process			 int
		--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max) 
			,@count int
			,@old_order_no int
			,@type	       nvarchar(20);
			
	begin try

	select @type = type 
	from dbo.sys_job_tasklist
	where code = @p_code

	if @type = 'EOD'
	begin
		if (@p_order_no <= 0)
		begin
			set @msg = 'Step Order must be greater than 0' ;
			raiserror(@msg, 16, -1) ;
		end ;

		select	@count = count(code)
		from	dbo.sys_job_tasklist
		where	type = 'EOD'
	
		if (@count > @p_order_no)
		begin
			set @msg = 'Next Order No is ' + cast(@count as nvarchar(3)) 
			raiserror(@msg, 16, -1) ;
		end ;

		if (@count < @p_order_no)
		begin
			set @msg = 'Maximum step Order is ' + cast(@count as nvarchar(3)) 
			raiserror(@msg, 16, -1) ;
		end ;
		
		select	@old_order_no = order_no
		from	dbo.sys_job_tasklist
		where	code = @p_code
		and     type = 'EOD'

		begin
			if @old_order_no > @p_order_no
			begin
				update	dbo.sys_job_tasklist
				set		order_no = order_no + 1
				where	code  = @p_code
				and		type  = 'EOD'
				
			end ;
			else if @old_order_no < @p_order_no
			begin
				update	dbo.sys_job_tasklist
				set		order_no = order_no - 1
				where	code     = @p_code
				and		type  = 'EOD'
			end ;
		end ;
	 end

	 update dbo.sys_job_tasklist
	 set
		code            = @p_code
		,type			= @type		
		,description	= @p_description
		,sp_name		= @p_sp_name	
		,order_no		= @p_order_no	
		,row_to_process = @p_row_to_process
		--
		,mod_date		= @p_mod_date
		,mod_by			= @p_mod_by
		,mod_ip_address	= @p_mod_ip_address
	where  code			= @p_code

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
end