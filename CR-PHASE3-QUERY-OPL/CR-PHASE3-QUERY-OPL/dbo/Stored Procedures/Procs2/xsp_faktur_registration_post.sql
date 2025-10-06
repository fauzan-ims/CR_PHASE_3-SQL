CREATE PROCEDURE [dbo].[xsp_faktur_registration_post]
(
	@p_code					   nvarchar(50)
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin

	declare @faktur_no				nvarchar(50)
			,@year					nvarchar(4)
			,@invoice_no			nvarchar(50)
			,@msg					nvarchar(max) ;

	begin try

		if exists
		(
			select	1
			from	dbo.faktur_registration
			where	@p_code not in
					(
						select	registration_code
						from	dbo.faktur_registration_detail
					)
		)
		begin
			set @msg = 'Please Generate Data' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.faktur_registration
			where	code	= @p_code
			and		status	= 'NEW'
		)
		begin

			update	dbo.faktur_registration
			set		status			= 'POST'
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code ;

			/* declare variables */
			
			declare c_faktur_registration_detail cursor fast_forward read_only for 

			select	year
					,faktur_no
			from	dbo.faktur_registration_detail
			where	registration_code = @p_code

			open c_faktur_registration_detail
			
			fetch next from c_faktur_registration_detail 
			into @year
				 ,@faktur_no
			
			while @@fetch_status = 0
			begin
			    

				exec	dbo.xsp_faktur_main_insert 
						0
						,@faktur_no
						,@year
						,'NEW'
						,@p_code
						,''
						--
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
			
			    fetch next from c_faktur_registration_detail 
				into	@year
						,@faktur_no

			end
			
			close c_faktur_registration_detail
			deallocate c_faktur_registration_detail

		end ;
		else
		begin
			set @msg = 'Data already post';
			raiserror(@msg, 16, 1) ;
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
