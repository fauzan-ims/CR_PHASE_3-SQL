CREATE PROCEDURE [dbo].[xsp_unsubscribe_request_gps_cancel]
(
	@p_request_no			nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
    
	declare @msg			nvarchar(max)
			,@status		nvarchar(20)
			,@code			nvarchar(20)
			,@id			bigint
            ,@asst_code		nvarchar(50)
			,@reff_name		nvarchar(50)
			,@reff_no		nvarchar(50)

	begin try
	
		if exists 
		(
			select	1 
			from	dbo.gps_unsubcribe_request
			where	status <> 'hold'
					and	request_no = @p_request_no
		)
		begin
			set @msg = 'Data Already Proceed'
			raiserror (@msg, 16, -1)
		end

		
		select	@id			= id_monitoring_gps
				,@asst_code	= fa_code
				,@reff_no	= source_reff_no
				,@reff_name	= source_reff_name
		from	dbo.gps_unsubcribe_request
		where	request_no	= @p_request_no
	
		if (@reff_name = 'SELL REQUEST')
		begin
			if exists (	select	1
						from	dbo.sale al
								inner join dbo.sale_detail sd on sd.sale_code = al.code
						where	code = @reff_no and sd.is_sold = '1'
						and		sd.sale_detail_status in ('POST','PAID'))
			begin
				set @msg = 'Cannot Cancel Unsubscribe Because Asset Already Sold'
				raiserror (@msg, 16, -1)	    
			end
		end
		else if (@reff_name = 'DISPOSAL')
		begin
			if exists (	select	1 
						from	dbo.disposal 
						where	code = @reff_no and status = 'APPROVE')
			begin
				set @msg = 'Cannot Cancel Unsubscribe Because Asset Already Dispose'
				raiserror (@msg, 16, -1)	    
			end
		end

		update	dbo.gps_unsubcribe_request
		set		status			= 'CANCEL'
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	request_no	= @p_request_no
		

		update	dbo.monitoring_gps
		set		status				= 'SUBSCRIBE'
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @id

		update	dbo.asset
		set		gps_status			= 'SUBSCRIBE'
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code= @asst_code
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
			set @msg = 'v' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%v;%' or error_message() like '%e;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	

end
