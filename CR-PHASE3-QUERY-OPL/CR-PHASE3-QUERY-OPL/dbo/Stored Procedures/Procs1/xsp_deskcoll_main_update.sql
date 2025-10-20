CREATE PROCEDURE dbo.xsp_deskcoll_main_update
(
	@p_id							    bigint
	,@p_result_code					    nvarchar(50)
	,@p_result_detail_code			    nvarchar(50)	= ''
	,@p_result_remarks				    nvarchar(400)
	,@p_result_promise_date			    datetime = null
	,@p_result_promise_amount			decimal(18,2) = 0
	,@p_is_need_next_fu					nvarchar(1)
	,@p_next_fu_date					datetime	= null
	--
	,@p_mod_date					    datetime
	,@p_mod_by						    nvarchar(15)
	,@p_mod_ip_address				    nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_need_next_fu = 'T'
		set @p_is_need_next_fu = '1' ;
	else
		set @p_is_need_next_fu = '0' ;

	if (@p_result_code = 'MD004')   -- jika janji bayar
	begin
		if(cast(@p_result_promise_date as date) <= cast(@p_next_fu_date as date))
		begin
			set @msg = 'Promise Date Must be Geater than FU Date';
			raiserror(@msg, 16, 1) ;
		end

		if(cast(@p_result_promise_date as date) < cast(dbo.xfn_get_system_date() as date))
		begin
			set @msg =  'Promise Date Must Be Geater Than System Date';
			raiserror(@msg, 16, 1) ;
		end
	end
	else
    begin
        set @p_result_promise_date		= null
		set @p_result_promise_amount	= 0.00
    end
    

	IF(@p_next_fu_date < dbo.xfn_get_system_date())
	BEGIN
		SET @msg = 'Fu Date Must Be Geater Than System Date';
		raiserror(@msg, 16, 1) ;
	end
	--if not exists(select 1 from dbo.sys_global_param where code = 'CDPTP' and value = @p_result_code)
	--begin
	--	set @p_result_promise_date = null
	--end

	begin try
		--if (@p_result_promise_date is not null and cast(@p_result_promise_date as date) <= cast(dbo.xfn_get_system_date()as date)) 
		--	begin
		--		set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Promise Date','System Date');
		--		raiserror(@msg ,16,-1)
		--	end

		if (@p_next_fu_date > @p_result_promise_date)
		begin
			set @msg = 'Next FU Date must be less than promise date.';
			raiserror(@msg, 16, 1) ;
		end

		update	deskcoll_main
		set		result_code				= @p_result_code
				,result_detail_code		= @p_result_detail_code
				,result_remarks			= @p_result_remarks
				,result_promise_date	= @p_result_promise_date
				,result_promise_amount	= @p_result_promise_amount
				,is_need_next_fu		= @p_is_need_next_fu
				,next_fu_date			= @p_next_fu_date
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;

		update  dbo.task_main
		set		desk_status			= 'HOLD'
				--
				,mod_date			= @p_mod_date		
				,mod_by				= @p_mod_by			
				,mod_ip_address		= @p_mod_ip_address
		where	deskcoll_main_id	= @p_id

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