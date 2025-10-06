CREATE PROCEDURE dbo.xsp_application_rules_result_validate
(
	@p_application_no  nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			   nvarchar(max)
			,@code			   nvarchar(50)
			,@function_name	   nvarchar(250)
			,@fn_override_name nvarchar(250)
			,@is_fn_override   nvarchar(1)
			,@id			   bigint
			,@result_status	   nvarchar(250) ;

	begin try
		delete application_rules_result
		where	application_no = @p_application_no ;

		declare cursor_application_rules cursor fast_forward read_only for
			select	code
					,function_name
					,is_fn_override
					,fn_override_name
			from	dbo.master_rules
			where	type		  = 'APPLICATION'
					and is_active = '1' ;
			
		open cursor_application_rules ;

		fetch next from cursor_application_rules
		into @code
			 ,@function_name
			 ,@fn_override_name
			 ,@is_fn_override ;

		while @@fetch_status = 0
		begin
			if @is_fn_override = '1'
				exec @result_status = @fn_override_name @p_application_no ;
			else
				exec @result_status = @function_name @p_application_no ;

			if (@result_status <> '')
			begin
				
				exec dbo.xsp_application_rules_result_insert @p_id				= @id output
															,@p_application_no	= @p_application_no
															,@p_rules_code		= @code
															,@p_rules_result	= @result_status
															,@p_cre_date		= @p_cre_date
															,@p_cre_by			= @p_cre_by
															,@p_cre_ip_address	= @p_cre_ip_address
															,@p_mod_date		= @p_mod_date
															,@p_mod_by			= @p_mod_by
															,@p_mod_ip_address	= @p_mod_ip_address ;
			end ;

			fetch next from cursor_application_rules
			into @code
				 ,@function_name
				 ,@fn_override_name
				 ,@is_fn_override ;
		end ;

		close cursor_application_rules ;
		deallocate cursor_application_rules ;

		
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






