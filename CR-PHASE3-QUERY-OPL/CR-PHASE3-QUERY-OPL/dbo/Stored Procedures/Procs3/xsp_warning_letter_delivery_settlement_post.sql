CREATE PROCEDURE dbo.xsp_warning_letter_delivery_settlement_post
(
	@p_code						nvarchar(50)
    --
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
BEGIN
	
	declare @msg				nvarchar(max)
			--
			--,@letter_code		nvarchar(50)
			--,@received_status	nvarchar(20) 
			--,@received_by		nvarchar(20) 
			--,@received_date		datetime 


	begin TRY

		--if exists (select 1 from dbo.warning_letter_delivery where code = @p_code and delivery_status  <> 'ON PROCESS')
		--begin
		--	set @msg = dbo.xfn_get_msg_err_data_already_proceed();
		--	raiserror(@msg ,16,-1)
		--end
        --
		--if exists (select 1 from dbo.warning_letter_delivery_detail where delivery_code = @p_code and isnull(received_status,'') = '')
		--begin
		--	set @msg = 'Please Fill All Received Status in Detail';
		--	raiserror(@msg ,16,-1)
		--end
		--
		--declare c_warning_letter_delivery cursor local fast_forward for
		--
		--select	letter_code
		--		,received_status
		--		,received_by
		--		,received_date 
		--from	warning_letter_delivery_detail
		--where	delivery_code = @p_code
		--
		--open	c_warning_letter_delivery
		--fetch	c_warning_letter_delivery
		--into	@letter_code
		--		,@received_status 
		--		,@received_by
		--		,@received_date
		--
		--while	@@fetch_status = 0
		--begin
		--		
		--		if exists
		--		(
		--			select	1
		--			from	dbo.warning_letter_delivery_detail
		--			where	delivery_code		= @p_code
		--					and received_status = 'DELIVERED'
		--					and file_name		is null
		--		)
		--		begin
		--			set @msg = 'Must be insert file name';
		--			raiserror(@msg ,16,-1)
		--		end 
		--
		--		update	dbo.warning_letter
		--		set		letter_status			= @received_status
		--				,received_by			= @received_by
		--				,received_date			= @received_date
		--				--
		--				,mod_date				= @p_mod_date		
		--				,mod_by					= @p_mod_by			
		--				,mod_ip_address			= @p_mod_ip_address
		--		
		--		where	letter_no				= @letter_code
		--
		--	fetch	c_warning_letter_delivery
		--	into	@letter_code
		--			,@received_status 
		--			,@received_by
		--			,@received_date
		--
		--end
		--close c_warning_letter_delivery
		--deallocate c_warning_letter_delivery

		if exists
		(
			select	1 
			from	dbo.warning_letter_delivery
			where	code = @p_code
					and	isnull(result,'')=''
		)
		begin
			set @msg = 'Please Input Result'
			raiserror(@msg, 16, -1);
		end

		if exists 
		(
			select	1
			from	dbo.warning_letter_delivery
			where	code = @p_code 
					and isnull(file_name, '') = ''
		)
		begin
			set @msg = 'File Name Is Required.';
			raiserror(@msg, 16, -1);
		end
			   
		if exists (select 1 from dbo.warning_letter_delivery where code = @p_code and result = 'FAILED')
		begin
		    update	dbo.warning_letter
			set		letter_status			= 'ON PROCESS'
					,mod_date				= @p_mod_date		
					,mod_by					= @p_mod_by			
					,mod_ip_address			= @p_mod_ip_address
			from	dbo.warning_letter wl
					inner join dbo.warning_letter_delivery_detail wld on wld.letter_code = wl.code
			where	wld.delivery_code = @p_code
		end

		update	dbo.warning_letter_delivery
		set		delivery_status			= 'DONE'
				--
				,mod_date				= @p_mod_date		
				,mod_by					= @p_mod_by			
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code

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
end   
