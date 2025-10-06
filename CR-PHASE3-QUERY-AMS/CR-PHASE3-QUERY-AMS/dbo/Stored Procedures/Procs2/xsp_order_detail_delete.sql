CREATE PROCEDURE dbo.xsp_order_detail_delete
(
	@p_id				bigint
	
)
as
begin
	declare @msg				nvarchar(max)
			,@register_code		nvarchar(50)
			,@order_code		nvarchar(50)
			,@sum_amount		decimal(18, 2) = 0
			,@remark			NVARCHAR(4000)

	select	@order_code = order_code
			,@register_code = register_code
	from	dbo.order_detail
	where	id = @p_id

	begin try
		delete order_detail
		where	id = @p_id ;

		if not exists (select 1 from dbo.order_detail where order_code = @order_code)
		begin
			
			update	order_main
			set		order_amount	= 0
			where	code			= @order_code;
		end
		else
		begin
			select	@sum_amount = sum(dp_to_public_service)
			from	dbo.order_detail
			where	order_code = @order_code

			update	order_main
			set		order_amount	= @sum_amount
			where	code			= @order_code;
		end


		
		--select	@remark = stuff((
		--			  select	distinct
		--						', ' + avh.plat_no + '/' + avh.engine_no + '/' + avh.chassis_no
		--			  from		 dbo.order_detail od
		--						inner join dbo.register_main rmn on (rmn.code collate latin1_general_ci_as = od.register_code)
		--						inner join dbo.asset_vehicle			  avh on (rmn.fa_code = avh.asset_code)
		--			  where		od.order_code = @order_code
		--			  for xml path('')
		--		  ), 1, 1, ''
		--		 ) ;

		-- (+) Ari 2023-11-21 ket : get only no pol

		select	@remark = stuff((
					  select	distinct
								', ' + avh.plat_no
					  from		 dbo.order_detail od
								inner join dbo.register_main rmn on (rmn.code collate latin1_general_ci_as = od.register_code)
								inner join dbo.asset_vehicle			  avh on (rmn.fa_code = avh.asset_code)
					  where		od.order_code = @order_code
					  for xml path('')
				  ), 1, 1, ''
				 ) ;

		update	dbo.register_main
		set		order_code			= null
				,order_status		= null
				,register_status	= 'ON PROCESS'
		where	code = @register_code

		update dbo.order_main
		set		asset			 = @remark
		WHERE	code = @order_code
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
