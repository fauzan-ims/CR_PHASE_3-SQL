CREATE PROCEDURE dbo.xsp_application_deviation_validate
(
	@p_application_no  nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			  nvarchar(max)
			,@code			  nvarchar(50)
			,@description	  nvarchar(250)
			,@function_name	  nvarchar(250)
			,@position_code   nvarchar(50)
			,@position_name   nvarchar(250)
			,@result_status	  int
			,@id			  bigint ;

	begin try
		delete dbo.application_deviation
		where	application_no = @p_application_no
				and is_manual  = '0' ;

		declare cursor_master_deviation cursor fast_forward read_only for
		select	code
				,description
				,function_name
				,md.position_code
				,md.position_name
		from	dbo.master_deviation md
				inner join dbo.application_main am on (
														  am.facility_code		 = md.facility_code
														  and  am.application_no = @p_application_no
													  )
		where	type		  = 'APPLICATION'
				and is_active = '1'
				--and is_manual = '0' ;
				
		open cursor_master_deviation ;

		fetch next from cursor_master_deviation
		into @code
			 ,@description
			 ,@function_name
			 ,@position_code 
			 ,@position_name  ;

		while @@fetch_status = 0
		begin
			exec @result_status = @function_name @p_application_no ;

			if (@result_status <> 0)
			begin
				exec dbo.xsp_application_deviation_insert @p_id					= @id output
														  ,@p_application_no	= @p_application_no
														  ,@p_deviation_code	= @code
														  ,@p_remarks			= @description
														  ,@p_is_manual			= '0'
														  ,@p_position_code		= @position_code
														  ,@p_position_name		= @position_name
														  ,@p_cre_date			= @p_mod_date
														  ,@p_cre_by			= @p_mod_by
														  ,@p_cre_ip_address	= @p_mod_ip_address
														  ,@p_mod_date			= @p_mod_date
														  ,@p_mod_by			= @p_mod_by
														  ,@p_mod_ip_address	= @p_mod_ip_address ;
			end ;

			fetch next from cursor_master_deviation
			into @code
				 ,@description
				 ,@function_name
				 ,@position_code 
				 ,@position_name  ;
		end ;

		close cursor_master_deviation ;
		deallocate cursor_master_deviation ;
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






