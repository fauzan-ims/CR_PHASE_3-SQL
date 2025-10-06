CREATE PROCEDURE [dbo].[xsp_register_main_update]
(
	@p_code						 nvarchar(50)
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	,@p_register_date			 datetime
	,@p_register_status			 nvarchar(20)
	,@p_register_process_by		 nvarchar(50)
	,@p_register_remarks		 nvarchar(4000)
	,@p_stnk_no					 nvarchar(50) = null
	,@p_stnk_tax_date			 datetime	  = null
	,@p_stnk_expired_date		 datetime	  = null
	,@p_keur_no					 nvarchar(50) = null
	,@p_keur_date				 datetime	  = null
	,@p_keur_expired_date		 datetime	  = null
	,@p_is_reimburse			 nvarchar(1)
	,@p_fa_code					 nvarchar(50)
	,@p_is_reimburse_to_customer nvarchar(1)
	--,@p_realization_invoic_date	 datetime
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg		  nvarchar(max)
			,@client_name nvarchar(250) ;

	begin try
		if @p_is_reimburse = 'T'
			set @p_is_reimburse = '1' ;
		else
			set @p_is_reimburse = '0' ;

		if @p_is_reimburse_to_customer = 'T'
			set @p_is_reimburse_to_customer = '1' ;
		else
			set @p_is_reimburse_to_customer = '0' ;

		--if (month(@p_realization_invoic_date) < month(dbo.xfn_get_system_date()))
		--begin
		--	set @msg = N'Invoice month must be equal than system date.' ;

		--	raiserror(@msg, 16, 1) ;
		--end ;

		if (cast(@p_register_date as date) > dbo.xfn_get_system_date())
		begin
			set @msg = N'Register Date must be less or equal than System Date' ;

			raiserror(@msg, 16, 1) ;
		end ;

		select	@client_name = isnull(client_name, '')
		from	dbo.asset
		where	code = @p_fa_code ;

		if (
			   @client_name = ''
			   and	@p_is_reimburse = '1'
		   )
		begin
			set @msg = N'Cannot disburse this asset to customer.' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if (
			   @client_name = ''
			   and	@p_is_reimburse_to_customer = '1'
		   )
		begin
			set @msg = N'Cannot reimburse this asset to customer.' ;

			raiserror(@msg, 16, 1) ;
		end ;

		update	register_main
		set		branch_code					= @p_branch_code
				,branch_name				= @p_branch_name
				,register_date				= @p_register_date
				,register_status			= @p_register_status
				,register_process_by		= @p_register_process_by
				,register_remarks			= @p_register_remarks
				,stnk_no					= @p_stnk_no
				,stnk_tax_date				= @p_stnk_tax_date
				,stnk_expired_date			= @p_stnk_expired_date
				,keur_no					= @p_keur_no
				,keur_date					= @p_keur_date
				,keur_expired_date			= @p_keur_expired_date
				,is_reimburse				= @p_is_reimburse
				,fa_code					= @p_fa_code
				,is_reimburse_to_customer	= @p_is_reimburse_to_customer
				--,realization_invoic_date	= @p_realization_invoic_date
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code = @p_code ;
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
