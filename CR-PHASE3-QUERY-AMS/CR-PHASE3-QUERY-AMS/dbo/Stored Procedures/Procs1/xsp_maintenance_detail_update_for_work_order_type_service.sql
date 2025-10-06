CREATE PROCEDURE [dbo].[xsp_maintenance_detail_update_for_work_order_type_service]
(
	@p_id					bigint
	,@p_service_code		nvarchar(50)
	,@p_service_name		nvarchar(250)
	,@p_service_fee			decimal(18,2) = 0
	,@p_service_type		nvarchar(50)  = ''
	,@p_ppn_amount			decimal(18,2) = 0
	,@p_pph_amount			decimal(18,2) = 0
	,@p_quantity			int			  = 0
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(50)
)
as
begin
	declare @msg				nvarchar(max)
			--,@ppn_amount		decimal(18,2)
			--,@pph_amount		decimal(18,2)
			,@ppn_amount		int
			,@pph_amount		int
			,@maintenance_code	nvarchar(50)
			,@service_amount	decimal(18,2)
			,@total_amount		decimal(18,2)
			,@payment_amount	decimal(18,2)

	begin try
		select @maintenance_code = maintenance_code
		from dbo.maintenance_detail
		where id = @p_id

		update	maintenance_detail
		set		service_code			= @p_service_code
				,service_name			= @p_service_name
				,service_fee			= @p_service_fee
				,service_type			= @p_service_type
				,ppn_amount				= @p_ppn_amount
				,pph_amount				= @p_pph_amount
				,quantity				= @p_quantity
				,total_amount			= @p_service_fee * @p_quantity
				,payment_amount			= (@p_service_fee * @p_quantity) + @p_ppn_amount - @p_pph_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id = @p_id ;

		select	@ppn_amount			= sum(ppn_amount)
				,@pph_amount		= sum(pph_amount)
				,@service_amount	= sum(service_fee)
				,@total_amount		= sum(total_amount)
				,@payment_amount	= sum(payment_amount)
		from dbo.maintenance_detail
		where maintenance_code = @maintenance_code

		update dbo.work_order
		set		total_ppn_amount	 = @ppn_amount
				,total_pph_amount	 = @pph_amount
				,total_amount		 = @total_amount
				,payment_amount		 = @payment_amount
				--
				,mod_date			 = @p_mod_date
				,mod_by				 = @p_mod_by
				,mod_ip_address		 = @p_mod_ip_address
		where	maintenance_code	 = @maintenance_code ;
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
