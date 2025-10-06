CREATE PROCEDURE dbo.xsp_order_main_paid
(
	@p_code					nvarchar(50)
	,@p_voucher				nvarchar(50)
	,@p_date				datetime
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
	
	begin try
		select	@order_status	= order_status
				--,@order_amount	= order_amount
		from	dbo.order_main
		where	code = @p_code
		

		if @order_status <> 'ON PROCESS'
		begin
			set @msg = 'Data already proceed.'
			raiserror(@msg ,16,-1)
		end

		declare c_main cursor read_only for
		select	register_code
				,odt.dp_to_public_service
				,ISNULL(detail.service_fee_amount,0)
		from	dbo.order_detail odt
				inner join dbo.order_main om on (om.code = odt.order_code)
				inner join dbo.master_public_service_branch mps on (mps.public_service_code = om.public_service_code and mps.branch_code = om.branch_code)  
				outer apply (	
								select sum(bs.service_fee_amount) 'service_fee_amount' 
								from dbo.master_public_service_branch_service bs
								inner join dbo.register_detail rd on (rd.service_code = bs.service_code and rd.register_code = odt.register_code)
								where bs.public_service_branch_code = mps.code
							) detail
		where	order_code = @p_code
										
		open c_main
		fetch next from c_main
		into @register_code
			,@order_amount
			,@service_fee_amount
									
		while @@fetch_status = 0
		begin			
				
			update	dbo.register_main
			set		order_status					= 'PAID'
					,register_status				= 'PENDING'
					,payment_status					= 'HOLD'
					,order_code						= @p_code
					,realization_service_fee		= @service_fee_amount
					,dp_to_public_service_amount	= @order_amount
					,dp_to_public_service_date		= @p_date
					,dp_to_public_service_voucher	= @p_voucher
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			where	code = @register_code
	
										
			fetch next from c_main
			into @register_code
				,@order_amount
				,@service_fee_amount
									
		end
									
		close c_main
		deallocate c_main

		update	dbo.order_main
		set		order_status	= 'PAID'
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code = @p_code

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



