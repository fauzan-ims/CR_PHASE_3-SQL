CREATE PROCEDURE [dbo].[xsp_ext_client_main_update_status]
(
	@p_reff_no			  nvarchar(50)
	,@p_CustNo			  nvarchar(50) = null
	,@p_MrNegCustTypeCode nvarchar(10) = ''
	,@p_IsActive		  nvarchar(1)  = ''
	--
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg		  nvarchar(max)
			,@client_no nvarchar(50) ;

	if (@p_IsActive = 'T')
		set @p_IsActive = '1'
	else 
		set @p_IsActive = '0'

	begin try
		select	@client_no = cm.client_no
		from	dbo.application_main am
				inner join dbo.client_main cm on (cm.code = am.client_code)
		where	application_no = @p_reff_no ;
		
		if (@p_MrNegCustTypeCode = 'BAD' and @p_IsActive = '1')
		begin
			set @msg = 'Client is in BAD list';
			raiserror(@msg, 16,1)
		end

		--if (@p_IsActive = '1')
		--begin
		--	update	dbo.client_main
		--	set		watchlist_status = @p_MrNegCustTypeCode
		--			--
		--			,mod_date		 = @p_mod_date		  
		--			,mod_by			 = @p_mod_by			  
		--			,mod_ip_address	 = @p_mod_ip_address	  
		--	where	client_no		 = isnull(@p_CustNo, @client_no) ;
		--end
		--else
		begin
			update	dbo.client_main
			set		watchlist_status = case @p_MrNegCustTypeCode when  'NORMAL' then 'CLEAR' else @p_MrNegCustTypeCode end
					--
					,mod_date		 = @p_mod_date		  
					,mod_by			 = @p_mod_by			  
					,mod_ip_address	 = @p_mod_ip_address	   
			where	client_no		 = isnull(@p_CustNo, @client_no) ;
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
