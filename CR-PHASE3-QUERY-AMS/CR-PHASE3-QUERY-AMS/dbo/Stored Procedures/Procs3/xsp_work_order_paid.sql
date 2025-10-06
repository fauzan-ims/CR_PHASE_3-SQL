CREATE PROCEDURE [dbo].[xsp_work_order_paid]
(
	@p_code					nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)

as
begin
	declare @msg					nvarchar(max)
			,@order_status			nvarchar(20)
			,@order_amount			decimal(18,2)
			,@service_fee_amount	decimal(18,2)
			,@register_code			nvarchar(50)
			,@code					nvarchar(50)
			,@is_reimburse			nvarchar(1)
			,@reff_remark			nvarchar(4000)
			,@asset_code			nvarchar(50)
			,@item_name				nvarchar(250)
			,@maintenance_code		nvarchar(50)
			,@date					datetime = dbo.xfn_get_system_date()
			,@payment_amount		decimal(18,2)
			,@agreement_no			nvarchar(50)
			,@client_name			nvarchar(250)
			,@last_meter			int
			,@last_km				int
			,@service_date			datetime
	
	begin try
		set @date = dbo.xfn_get_system_date()

		select	@order_status		= wo.status
				,@code				= wo.code
				,@is_reimburse		= mnt.is_reimburse
				,@asset_code		= wo.asset_code
				,@item_name			= ass.item_name
				,@maintenance_code	= mnt.code
				,@payment_amount	= wo.payment_amount
				,@agreement_no		= ass.agreement_no
				,@client_name		= ass.client_name
				,@last_meter		= wo.actual_km
				,@last_km			= wo.last_km_service
				,@service_date		= wo.work_date
		from	dbo.work_order wo
		inner join dbo.maintenance mnt on (mnt.code = wo.maintenance_code)
		inner join dbo.asset ass on (ass.code = wo.asset_code)
		where	wo.CODE = @p_code ;
		
		if @order_status <> 'APPROVE'
		begin
			set @msg = 'Data already process.'
			raiserror(@msg ,16,-1)
		end

		update	dbo.WORK_ORDER
		set		STATUS			= 'PAID'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code = @code

		update dbo.asset
		set		last_meter			= @last_meter
				,last_service_date	= @service_date
				,last_km_service	= @last_meter --@last_km
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @asset_code

		if @is_reimburse = '0'
		begin
			--insert ke expense ledger
			set @reff_remark = 'Maintenance for ' + @asset_code + ' - ' + @item_name
			exec dbo.xsp_asset_expense_ledger_insert @p_id					= 0
													 ,@p_asset_code			= @asset_code
													 ,@p_date				= @date
													 ,@p_reff_code			= @maintenance_code
													 ,@p_reff_name			= 'WORK ORDER'
													 ,@p_reff_remark		= @reff_remark
													 ,@p_expense_amount		= @payment_amount
													 ,@p_agreement_no		= @agreement_no
													 ,@p_client_name		= @client_name
													 ,@p_cre_date			= @p_mod_date	  
													 ,@p_cre_by				= @p_mod_by		
													 ,@p_cre_ip_address		= @p_mod_ip_address
													 ,@p_mod_date			= @p_mod_date	  
													 ,@p_mod_by				= @p_mod_by		
													 ,@p_mod_ip_address		= @p_mod_ip_address
		end

	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;There is an error.' + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
	
end



