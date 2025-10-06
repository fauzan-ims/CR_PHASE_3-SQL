CREATE PROCEDURE dbo.xsp_application_asset_doc_update
(
	@p_id			   bigint 
	,@p_expired_date   datetime = null
	,@p_promise_date   datetime = null 
	,@p_is_tbo		   nvarchar(1) = '0'
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max) 
			,@asset_no	nvarchar(50) ; 

	begin try
		if (@p_is_tbo = '1')
		begin
			if (@p_promise_date is null)
			begin
				set @msg = 'Please fill Promise Date';
				raiserror(@msg, 16, -1) ;
			end   
			else if exists (select 1 from application_asset_doc where id = @p_id and isnull(filename, '') = '')
			begin
				if (@p_promise_date <= dbo.xfn_get_system_date())
				begin
					set @msg = 'Promise Date must be greater than System Date';
					raiserror(@msg, 16, -1) ;
				end   
			end    
		end
		else
		begin
			if (@p_promise_date <= dbo.xfn_get_system_date())
			begin
				set @msg = 'Promise Date must be greater than System Date';
				raiserror(@msg, 16, -1) ;
			end  
			if (@p_expired_date <= dbo.xfn_get_system_date())
			begin
				set @msg = 'Expired Date must be greater than System Date';
				raiserror(@msg, 16, -1) ;
			end     
		end

		select	@asset_no = asset_no
		from	application_asset_doc 
		where	id = @p_id ;

		update	application_asset_doc
		set		expired_date		= @p_expired_date
				,promise_date		= @p_promise_date 
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id;  
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

