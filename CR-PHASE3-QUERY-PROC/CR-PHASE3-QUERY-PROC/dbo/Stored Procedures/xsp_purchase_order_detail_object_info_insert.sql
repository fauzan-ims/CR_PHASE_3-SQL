CREATE PROCEDURE dbo.xsp_purchase_order_detail_object_info_insert
(
	@p_id							bigint = 0 output
	,@p_purchase_order_detail_id	int
	,@p_good_receipt_note_detail_id	int
	,@p_plat_no						nvarchar(50)	= ''
	,@p_chassis_no					nvarchar(50)	= ''
	,@p_engine_no					nvarchar(50)	= ''
	,@p_serial_no					nvarchar(50)	= ''
	,@p_invoice_no					nvarchar(50)	= ''
	,@p_domain						nvarchar(50)	= ''
	,@p_imei						nvarchar(50)	= ''
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists(select 1 from dbo.purchase_order_detail_object_info where plat_no = @p_plat_no and plat_no <> '')
		begin
			set @msg = 'Plat No already exist.' ;
			raiserror(@msg, 16, -1) ;
		end
		if exists(select 1 from dbo.purchase_order_detail_object_info where engine_no = @p_engine_no and engine_no <> '')
		begin
			set @msg = 'Engine No already exist.' ;
			raiserror(@msg, 16, -1) ;
		end
		if exists(select 1 from dbo.purchase_order_detail_object_info where chassis_no = @p_chassis_no and chassis_no <> '')
		begin
			set @msg = 'Chasis No already exist.' ;
			raiserror(@msg, 16, -1) ;
		end
		insert into dbo.purchase_order_detail_object_info
		(
			purchase_order_detail_id
			,good_receipt_note_detail_id
			,plat_no
			,chassis_no
			,engine_no
			,serial_no
			,invoice_no
			,domain
			,imei
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
			@p_purchase_order_detail_id
			,@p_good_receipt_note_detail_id
			,@p_plat_no
			,@p_chassis_no
			,@p_engine_no
			,@p_serial_no
			,@p_invoice_no
			,@p_domain
			,@p_imei
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_id = @@identity ;
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
