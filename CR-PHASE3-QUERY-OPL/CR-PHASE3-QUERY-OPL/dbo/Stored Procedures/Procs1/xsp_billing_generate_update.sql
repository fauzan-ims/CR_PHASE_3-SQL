CREATE PROCEDURE dbo.xsp_billing_generate_update
(
	@p_code					nvarchar(50)
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_date				datetime
	,@p_remark				nvarchar(4000)
	,@p_client_no			nvarchar(50)	= ''
	,@p_client_name			nvarchar(250)	= ''
	,@p_agreement_no		nvarchar(50)	= ''
	,@p_asset_no			nvarchar(50)	= ''
	,@p_as_off_date			datetime
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		if exists
		(
			select	1
			from	dbo.billing_generate
			where	code			= @p_code
					and as_off_date <> @p_as_off_date
		)
		begin 
			-- generate billing detail
			exec dbo.xsp_billing_generate_detail_generate @p_code			 = @p_code
														  ,@p_as_off_date	 = @p_as_off_date
														  ,@p_client_no		 = @p_client_no
														  ,@p_agreement_no	 = @p_agreement_no	
														  ,@p_asset_no		 = @p_asset_no
														  --
														  ,@p_mod_date		 = @p_mod_date
														  ,@p_mod_by		 = @p_mod_by
														  ,@p_mod_ip_address = @p_mod_ip_address
		end

		update	billing_generate
		set		branch_code			= @p_branch_code
				,branch_name		= @p_branch_name
				,date				= @p_date
				,remark				= @p_remark
				,client_no			= @p_client_no
				,client_name		= @p_client_name
				,agreement_no		= @p_agreement_no
				,asset_no			= @p_asset_no
				,as_off_date		= @p_as_off_date
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;

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
