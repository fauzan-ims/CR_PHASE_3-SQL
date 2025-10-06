CREATE PROCEDURE dbo.xsp_task_main_insert
(
	@p_id							   bigint = 0 output
	,@p_task_date					   datetime
	,@p_desk_collector_code			   nvarchar(50)
	,@p_desk_collector_name				nvarchar(250)	
	,@p_client_no					   nvarchar(50)
	,@p_client_name					   nvarchar(250)
	--
	,@p_cre_date					   datetime
	,@p_cre_by						   nvarchar(15)
	,@p_cre_ip_address				   nvarchar(15)
	,@p_mod_date					   datetime
	,@p_mod_by						   nvarchar(15)
	,@p_mod_ip_address				   nvarchar(15)
	,@p_promise_date					datetime = null	
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into task_main
		(
			task_date
			,desk_collector_code
			,deskcoll_staff_name
			,client_no
			,client_name
			,desk_status
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			,promise_date
		)
		values
		(
			@p_task_date
			,@p_desk_collector_code
			,@p_desk_collector_name
			,@p_client_no
			,@p_client_name
			,'NEW'
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
			,@p_promise_date
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
