CREATE PROCEDURE dbo.xsp_work_order_detail_update
(
	@p_id							  bigint
	,@p_work_order_code				  nvarchar(50)
	,@p_asset_maintenance_schedule_id bigint
	,@p_service_code				  nvarchar(50)
	,@p_service_name				  nvarchar(250)
	,@p_service_type				  nvarchar(50)
	,@p_service_fee					  decimal(18, 2)
	,@p_quantity					  int
	,@p_pph_amount					  decimal(18, 2)
	,@p_ppn_amount					  decimal(18, 2)
	,@p_total_amount				  decimal(18, 2)
	,@p_payment_amount				  decimal(18, 2)
	,@p_tax_code					  nvarchar(50)
	,@p_tax_name					  nvarchar(250)
	,@p_ppn_pct						  decimal(9, 6)
	,@p_pph_pct						  decimal(9, 6)
	,@p_part_number					  int
	--
	,@p_mod_date					  datetime
	,@p_mod_by						  nvarchar(15)
	,@p_mod_ip_address				  nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		
		update	work_order_detail
		set		work_order_code = @p_work_order_code
				,asset_maintenance_schedule_id = @p_asset_maintenance_schedule_id
				,service_code = @p_service_code
				,service_name = @p_service_name
				,service_type = @p_service_type
				,service_fee = @p_service_fee
				,quantity = @p_quantity
				,pph_amount = @p_pph_amount
				,ppn_amount = @p_ppn_amount
				,total_amount = @p_total_amount
				,payment_amount = @p_payment_amount
				,tax_code = @p_tax_code
				,tax_name = @p_tax_name
				,ppn_pct = @p_ppn_pct
				,pph_pct = @p_pph_pct
				,part_number = @p_part_number
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id = @p_id ;
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
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
