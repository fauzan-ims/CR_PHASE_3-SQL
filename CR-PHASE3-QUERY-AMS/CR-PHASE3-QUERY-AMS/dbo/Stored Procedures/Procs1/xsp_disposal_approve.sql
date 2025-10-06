CREATE PROCEDURE dbo.xsp_disposal_approve
(
	@p_code				nvarchar(50)
	,@p_approval_reff	nvarchar(250)
	,@p_approval_remark nvarchar(4000)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg		    nvarchar(max)
			,@id		    bigint
			,@remarks	    nvarchar(4000)
			,@level_status  nvarchar(250)
			,@level_code    nvarchar(20)
			,@asset_code	nvarchar(50)
			,@reason_type	nvarchar(50)
			,@code_detail			nvarchar(50)
			,@is_gps				nvarchar(1)
			,@gps_status			nvarchar(20)
			,@id_monitoring_gps		bigint
			,@remark_h				nvarchar(400)
            ,@remark				nvarchar(400)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)

	begin try
		
		if exists
		(
			select	1
			from	dbo.disposal
			where	code		= @p_code
					and status	= 'ON PROCESS'
		)
		begin
			update	dbo.disposal
			set		status		= 'APPROVE'	
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code ;


			declare cursor_name cursor fast_forward read_only for
			select asset_code
					,ds.reason_type 
					,dd.description + ' - ' + ds.remarks 
			from dbo.disposal ds
			inner join dbo.disposal_detail  dd on (dd.disposal_code = ds.code)
			where ds.code = @p_code
		
			open cursor_name
		
			fetch next from cursor_name 
			into @asset_code
				,@reason_type
				,@remark
		
			while @@fetch_status = 0
			begin
				update	dbo.asset
				set		status			= 'DISPOSED'
						,fisical_status = 'DISPOSED'
						,rental_status	= ''
						,process_status = @reason_type	
						--
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	code					= @asset_code ;

				--
				-- Ambil data IS_GPS, GPS_STATUS, BRANCH dari ASSET
				select 
					@is_gps = is_gps,
					@gps_status = gps_status,
					@branch_code = branch_code,
					@branch_name = branch_name
				from dbo.asset
				where code = @code_detail;

				update	dbo.asset
				set		status			= 'DISPOSED'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @code_detail
			
				-- Insert ke GPS_UNSUBCRIBE_REQUEST jika IS_GPS = 1 dan GPS_STATUS = 'SUBCRIBE'
				if exists 
				(
					select	1
					from	dbo.asset 
					where	code = @asset_code 
							and is_gps = '1' and gps_status = 'SUBSCRIBE'
				)
				begin
				
					select	@id_monitoring_gps = id
					from	dbo.monitoring_gps
					where	fa_code = @asset_code
							and status = 'SUBSCRIBE'
				
					declare @p_request_no nvarchar(50);
					exec dbo.xsp_gps_unsubcribe_request_insert @p_request_no		= @p_request_no output, 
															   @p_id				= @id_monitoring_gps,   
															   @p_source_reff_name	= N'DISPOSAL',      
															   @p_cre_date			= @p_mod_date,			
															   @p_cre_by			= @p_mod_by,            
															   @p_cre_ip_address	= @p_mod_ip_address,    
															   @p_mod_date			= @p_mod_date,			
															   @p_mod_by			= @p_mod_by,            
															   @p_mod_ip_address	= @p_mod_ip_address,
															   @p_source_reff_no	= @p_code,
																@p_remarks			= @remark
				END
		
		
				fetch next from cursor_name 
				into @asset_code
					,@reason_type
					,@remark
			end
		
			close cursor_name
			deallocate cursor_name


		end ;
		else
		begin
			set @msg = 'Data already process';
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




