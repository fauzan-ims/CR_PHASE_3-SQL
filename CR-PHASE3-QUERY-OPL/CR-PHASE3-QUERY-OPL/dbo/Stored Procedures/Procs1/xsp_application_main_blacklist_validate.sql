CREATE PROCEDURE dbo.xsp_application_main_blacklist_validate
(
	@p_application_no		nvarchar(50)
)
as
begin
	declare @msg					nvarchar(max)
			,@client_code			nvarchar(50)
			,@client_type			nvarchar(50)
			,@jobcode				nvarchar(50)
			,@is_area_blacklist		nvarchar(1)	
			,@is_job_blacklist		nvarchar(1)	
			,@watchlist_status		nvarchar(10)	 ;

	begin try
		select	@client_code = client_code
		from	dbo.application_main
		where	application_no = @p_application_no ;

		select	@client_type = cm.client_type
				,@watchlist_status = cm.watchlist_status
		from	dbo.client_main cm
				inner join client_address ca on (ca.client_code = cm.code)
		where	cm.code = @client_code ;

		if (@client_type = 'PERSONAL')
		begin
			select top 1
					@jobcode = work_type_code
			from	dbo.client_personal_work
			where	client_code		 = @client_code
					and is_latest	 = '1' ;

			-- cek apakah ada di job blacklist
			if exists
			(
				select	1
				from	dbo.job_blacklist
				where	job_code	  = @jobcode
						and is_active = '1'
			)
			begin
				set @is_job_blacklist = '1' ;
			end ;
			else
			begin
				set @is_job_blacklist = '0' ;
			end ;
		end ;
		else
		begin
			set @is_job_blacklist = '0' ;
		end ;

		begin
			-- cek apakah ada di area blacklist
			if exists
			(
				select	1
				from	dbo.area_blacklist
				where	postal_code in (select	ca.zip_code
										from	dbo.client_main cm
												inner join client_address ca on (ca.client_code = cm.code)
										where	cm.code = @client_code )
						and is_active = '1'
			)
			begin
				set @is_area_blacklist = '1' ;
			end ;
			else
			begin
				set @is_area_blacklist = '0' ;
			end ;
		end ;

		begin
			update	dbo.application_main
			set		is_blacklist_area = @is_area_blacklist
					,watchlist_status = @watchlist_status
					,is_blacklist_job = @is_job_blacklist 
			where	application_no = @p_application_no;
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



