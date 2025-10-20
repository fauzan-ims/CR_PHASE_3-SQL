CREATE PROCEDURE dbo.deskcoll_main_apply_to_all
(
	@p_id			   bigint
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@result_code	 nvarchar(50)
			,@result_remarks nvarchar(4000) 
			,@promise_date_header	datetime
			,@promise_amount_header	decimal(18,2)

	begin try
		select	@result_code			= result_code
				,@result_remarks		= result_remarks
				,@promise_date_header	= result_promise_date
				,@promise_amount_header	= result_promise_amount
		from	dbo.deskcoll_main
		where	id = @p_id ;

		if isnull(@result_code,'') = ''
		begin
		    set @msg = 'Please Save Result Firts'
			raiserror (@msg,16,1)
		end

		update	dbo.deskcoll_invoice
		set		result_code			= @result_code
				,remark				= @result_remarks
				,promise_date		= @promise_date_header
				,promise_amount		= @promise_amount_header
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	deskcoll_main_id	= @p_id ;

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