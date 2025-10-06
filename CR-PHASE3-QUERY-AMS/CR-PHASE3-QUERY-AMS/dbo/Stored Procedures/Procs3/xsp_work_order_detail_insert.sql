CREATE PROCEDURE dbo.xsp_work_order_detail_insert
(
	@p_id							  bigint = 0 output
	,@p_work_order_code				  nvarchar(50)
	,@p_asset_maintenance_schedule_id bigint				= 0
	,@p_service_code				  nvarchar(50)			= ''
	,@p_service_name				  nvarchar(250)			= ''
	,@p_service_type				  nvarchar(50)			= ''
	,@p_service_fee					  decimal(18, 2)		= 0
	,@p_quantity					  int					= 0
	,@p_pph_amount					  decimal(18, 2)		= 0
	,@p_ppn_amount					  decimal(18, 2)		= 0
	,@p_total_amount				  decimal(18, 2)		= 0
	,@p_payment_amount				  decimal(18, 2)		= 0
	,@p_tax_code					  nvarchar(50)			= ''
	,@p_tax_name					  nvarchar(250)			= ''
	,@p_ppn_pct						  decimal(9, 6)			= 0
	,@p_pph_pct						  decimal(9, 6)			= 0
	,@p_part_number					  nvarchar(50)			= null
	--
	,@p_cre_date					  datetime
	,@p_cre_by						  nvarchar(15)
	,@p_cre_ip_address				  nvarchar(50)
	,@p_mod_date					  datetime
	,@p_mod_by						  nvarchar(15)
	,@p_mod_ip_address				  nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into work_order_detail
		(
			work_order_code
			,asset_maintenance_schedule_id
			,service_code
			,service_name
			,service_type
			,service_fee
			,quantity
			,pph_amount
			,ppn_amount
			,total_amount
			,payment_amount
			,tax_code
			,tax_name
			,ppn_pct
			,pph_pct
			,part_number
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_work_order_code
			,@p_asset_maintenance_schedule_id
			,@p_service_code
			,@p_service_name
			,@p_service_type
			,@p_service_fee
			,@p_quantity
			,@p_pph_amount
			,@p_ppn_amount
			,@p_total_amount
			,@p_payment_amount
			,@p_tax_code
			,@p_tax_name
			,@p_ppn_pct
			,@p_pph_pct
			,@p_part_number
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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
