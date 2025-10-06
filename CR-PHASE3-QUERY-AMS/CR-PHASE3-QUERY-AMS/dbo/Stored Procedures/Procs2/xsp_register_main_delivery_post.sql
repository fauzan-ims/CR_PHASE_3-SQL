CREATE PROCEDURE [dbo].[xsp_register_main_delivery_post]
(
	@p_code					nvarchar(50)
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
	
declare @msg					  nvarchar(max)
		,@regis_status			  nvarchar(20)
		,@stnk_no				  nvarchar(50)
		,@stnk_tax_date			  datetime
		,@stnk_expired_date		  datetime
		,@keur_no				  nvarchar(50)
		,@keur_date				  datetime
		,@keur_expired_date		  datetime
		,@asset_no				  nvarchar(50)
		,@asset_stnk_no			  nvarchar(50)
		,@asset_stnk_tax_date	  datetime
		,@asset_stnk_expired_date datetime
		,@asset_keur_no			  nvarchar(50)
		,@asset_keur_date		  datetime
		,@asset_keur_expired_date datetime
		,@reff_remark			  nvarchar(4000)
		,@fa_code				  nvarchar(50)
		,@item_name				  nvarchar(250)
		,@date					  datetime
		,@agreement_no			  nvarchar(50)
		,@client_name			  nvarchar(250)
		,@expense				  decimal(18, 2)
		,@prepaid_no			  nvarchar(50)
		,@total_net_premi_amount  decimal(18, 2)
		,@usefull				  int
		,@monthly_amount		  decimal(18, 2)
		,@counter				  int
		,@date_prepaid			  datetime
		,@year_periode			  int
		,@amount				  decimal(18, 2)
		,@service_code			  nvarchar(50)
		,@code_register			  nvarchar(50)
		,@payment_status		  nvarchar(50)
		,@receive_date			  DATETIME;


	begin try
		select	@regis_status			= register_status
				,@stnk_no				= stnk_no
				,@stnk_tax_date			= stnk_tax_date
				,@stnk_expired_date		= stnk_expired_date
				,@keur_no				= keur_no
				,@keur_date				= keur_date
				,@keur_expired_date		= keur_expired_date
				,@asset_no				= fa_code
				,@payment_status		= payment_status
				,@receive_date			= receive_date
		from	dbo.register_main
		where	code = @p_code

		select @asset_stnk_no				= stnk_no
				,@asset_stnk_tax_date		= stnk_tax_date
				,@asset_stnk_expired_date	= stnk_expired_date
				,@asset_keur_no				= keur_no
				,@asset_keur_expired_date	= keur_expired_date
				,@asset_keur_date			= keur_date
		from dbo.asset_vehicle
		where asset_code = @asset_no

		if @regis_status <> 'PENDING'
		begin
			set @msg = 'Data already proceed.'
			raiserror(@msg ,16,-1)
		END

		IF(@receive_date IS NULL)
		begin
			set @msg = 'Please Complete Receive Date'
			raiserror(@msg ,16,-1)
		END
        
		if (isnull(@stnk_no,'') = '')
			set @stnk_no = @asset_stnk_no;
		if (isnull(@stnk_tax_date,'') = '')
			set @stnk_tax_date = @asset_stnk_tax_date;
		if (isnull(@stnk_expired_date,'') = '')
			set @stnk_expired_date = @asset_stnk_expired_date;
		if (isnull(@keur_no,'') = '')
			set @keur_no = @asset_keur_no;
		if (isnull(@keur_date,'') = '')
			set @keur_date = @asset_keur_date;
		if (isnull(@keur_expired_date,'') = '')
			set @keur_expired_date = @asset_keur_expired_date;
		
		if not exists (
			select	1 
			from	dbo.asset_prepaid_main 
			where	reff_no = @p_code
		)
		begin
			if(@payment_status in ('ON PROCESS', 'PAID'))
			begin
				exec dbo.xsp_prepaid_realization @p_code			= @p_code
												 ,@p_mod_date		= @p_mod_date
												 ,@p_mod_by			= @p_mod_by
												 ,@p_mod_ip_address = @p_mod_ip_address
				
				
			end
		end

		update	dbo.register_main
		set		register_status						= 'DELIVERY'
				,mod_date							= @p_mod_date
				,mod_by								= @p_mod_by
				,mod_ip_address						= @p_mod_ip_address
		where	code = @p_code

		update	dbo.asset_vehicle
		set		stnk_no				= @stnk_no
				,stnk_tax_date		= @stnk_tax_date
				,stnk_expired_date	= @stnk_expired_date
				,keur_no			= @keur_no
				,keur_date			= @keur_date
				,keur_expired_date	= @keur_expired_date
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	asset_code			= @asset_no


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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;

end


