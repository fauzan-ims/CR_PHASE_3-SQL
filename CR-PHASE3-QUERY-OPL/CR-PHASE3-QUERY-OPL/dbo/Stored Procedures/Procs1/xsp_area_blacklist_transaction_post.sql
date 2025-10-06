--created by, Rian at 16/05/2023 

CREATE PROCEDURE dbo.xsp_area_blacklist_transaction_post
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@zip_postal_code		nvarchar(50)
			,@zip_code_code			nvarchar(50)
			,@zip_code_name			nvarchar(250)
			,@province_code			nvarchar(50)
			,@city_code				nvarchar(50)
			,@province_name			nvarchar(50)
			,@city_name				nvarchar(50)
			,@register_source		nvarchar(250)
			,@is_active				nvarchar(1)
			,@area_blacklist_code	nvarchar(50)
			,@transaction_date		datetime
			,@transaction_remarks	nvarchar(4000)
			,@history_remarks		NVARCHAR(4000)
			,@entry_date			datetime
			,@entry_remarks			nvarchar(4000)
			,@source				nvarchar(10)
			,@code					nvarchar(50)
			,@id					bigint;

	
	begin try			
	
		if not exists (select 1 from area_blacklist_transaction where code = @p_code and transaction_status = 'HOLD')
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg, 16, -1) ;
		end 
		
		update	dbo.area_blacklist_transaction
		set		transaction_status	= 'POST'
				,transaction_date	= dbo.xfn_get_system_date()
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code

		select	@transaction_date		= transaction_date
				,@transaction_remarks	= transaction_remarks
				,@register_source		= register_source
		from	dbo.area_blacklist_transaction
		where	code					= @p_code

		if exists (select 1 from area_blacklist_transaction where code = @p_code and transaction_type = 'REGISTER')
		begin
			set @history_remarks		= 'REGISTER - '+@transaction_remarks
		    declare los_cur	cursor local fast_forward for
			select	province_code
					,city_code
					,province_name
					,city_name
			from	dbo.area_blacklist_transaction_detail 
			where	area_blacklist_transaction_code = @p_code
									
			open los_cur
			fetch next from los_cur  
			into	@province_code
					,@city_code
					,@province_name
					,@city_name
						
			while @@fetch_status = 0
			begin
				if exists (select 1 from area_blacklist where city_code = @city_code)
				begin
					select	@is_active				= is_active 
							,@area_blacklist_code	= code
							,@entry_date			= entry_date
							,@entry_remarks			= entry_remarks
							,@source				= source
					from	area_blacklist
					where	city_code				= @city_code

					if @is_active = '1'
					begin
						set @msg = 'This Province ( '+@province_name +' - '+ @city_name+' ) already exist and active'
					    raiserror(@msg,16,1)
					end
					else
					begin

						exec dbo.xsp_area_blacklist_update @p_code				= @area_blacklist_code
														   ,@p_source			= @register_source
														   ,@p_province_code	= @province_code
														   ,@p_city_code		= @city_code
														   ,@p_province_name	= @province_name
														   ,@p_city_name		= @city_name
														   ,@p_entry_date		= @transaction_date
														   ,@p_entry_remarks	= @transaction_remarks
														   ,@p_exit_date		= null
														   ,@p_exit_remarks		= N''
														   ,@p_is_active		= 'T'
														   --
														   ,@p_mod_date			= @p_mod_date
														   ,@p_mod_by			= @p_mod_by
														   ,@p_mod_ip_address	= @p_mod_ip_address

						exec dbo.xsp_area_blacklist_history_insert @p_id					= @id output
																   ,@p_area_blacklist_code	= @area_blacklist_code
																   ,@p_source				= @register_source
																   ,@p_history_date			= @entry_date
																   ,@p_history_remarks		= @history_remarks
																   --
																   ,@p_cre_date				= @p_cre_date		
																   ,@p_cre_by				= @p_cre_by		
																   ,@p_cre_ip_address		= @p_cre_ip_address
																   ,@p_mod_date				= @p_mod_date		
																   ,@p_mod_by				= @p_mod_by		
																   ,@p_mod_ip_address		= @p_mod_ip_address
						
						
					    
					end
				end	
				else
				begin

					exec dbo.xsp_area_blacklist_insert @p_code				= @code output
													   ,@p_source			= @register_source
													   ,@p_province_code	= @province_code
													   ,@p_city_code		= @city_code
													   ,@p_province_name	= @province_name
													   ,@p_city_name		= @city_name
													   ,@p_entry_date		= @transaction_date
													   ,@p_entry_remarks	= @transaction_remarks
													   ,@p_exit_date		= null
													   ,@p_exit_remarks		= N''
													   ,@p_is_active		= N'T'
													   --
													   ,@p_cre_date			= @p_cre_date
													   ,@p_cre_by			= @p_cre_by
													   ,@p_cre_ip_address	= @p_cre_ip_address
													   ,@p_mod_date			= @p_mod_date
													   ,@p_mod_by			= @p_mod_by
													   ,@p_mod_ip_address	= @p_mod_ip_address
					

					exec dbo.xsp_area_blacklist_history_insert @p_id					= @id output
															   ,@p_area_blacklist_code	= @code
															   ,@p_source				= @register_source
															   ,@p_history_date			= @transaction_date
															   ,@p_history_remarks		= @history_remarks
															   --
															   ,@p_cre_date				= @p_cre_date		
															   ,@p_cre_by				= @p_cre_by		
															   ,@p_cre_ip_address		= @p_cre_ip_address
															   ,@p_mod_date				= @p_mod_date		
															   ,@p_mod_by				= @p_mod_by		
															   ,@p_mod_ip_address		= @p_mod_ip_address
					
				end	

				fetch next from los_cur  
				into	@province_code
						,@city_code
						,@province_name
						,@city_name

			end
				
			close los_cur
			deallocate los_cur
		end
		else if exists (select 1 from area_blacklist_transaction where code = @p_code and transaction_type = 'RELEASE')
		BEGIN
			SET @history_remarks		= 'RELEASE - '+@transaction_remarks
			
		    declare los_cur	cursor local fast_forward for
			select	province_code
					,city_code
					,province_name
					,city_name
			from	dbo.area_blacklist_transaction_detail 
			where	area_blacklist_transaction_code = @p_code
									
			open los_cur
			fetch next from los_cur  
			into	@province_code
					,@city_code
					,@province_name
					,@city_name
						
			while @@fetch_status = 0
			begin
				if exists (select 1 from area_blacklist where city_code = @city_code)
				begin
					select	@is_active				= is_active 
							,@area_blacklist_code	= code
							,@entry_date			= entry_date
							,@entry_remarks			= entry_remarks
							,@source				= source
					from	area_blacklist
					where	city_code				= @city_code
					
					if @is_active = '0'
					begin
						set @msg = 'This Provice ( '+@province_name +' - '+ @city_name+' ) already release'
					    raiserror(@msg,16,1)
					end
					else
					begin

						exec dbo.xsp_area_blacklist_update @p_code = @area_blacklist_code
														   ,@p_source = @source
														   ,@p_province_code = @province_code
														   ,@p_city_code = @city_code
														   ,@p_province_name = @province_name
														   ,@p_city_name = @city_name
														   ,@p_entry_date = @entry_date
														   ,@p_entry_remarks = @entry_remarks
														   ,@p_exit_date = @transaction_date
														   ,@p_exit_remarks = @transaction_remarks
														   ,@p_is_active = N'F'
														   --
														   ,@p_mod_date = @p_mod_date
														   ,@p_mod_by = @p_mod_by
														   ,@p_mod_ip_address = @p_mod_ip_address
					    
						exec dbo.xsp_area_blacklist_history_insert @p_id					= @id output
																   ,@p_area_blacklist_code	= @area_blacklist_code
																   ,@p_source				= @source
																   ,@p_history_date			= @entry_date
																   ,@p_history_remarks		= @history_remarks
																   --
																   ,@p_cre_date				= @p_cre_date		
																   ,@p_cre_by				= @p_cre_by		
																   ,@p_cre_ip_address		= @p_cre_ip_address
																   ,@p_mod_date				= @p_mod_date		
																   ,@p_mod_by				= @p_mod_by		
																   ,@p_mod_ip_address		= @p_mod_ip_address
					end
				end	
				else
				begin
					set @msg = 'This Zip Code ( '+@zip_postal_code +' - '+ @zip_code_name+' ) is not exist for release process'
					raiserror(@msg,16,1)					
				end	

				fetch next from los_cur  
				into	@zip_code_code
						,@zip_code_name
						,@zip_postal_code

			end
				
			close los_cur
			deallocate los_cur
		    
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
