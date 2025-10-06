
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_purchase_order_detail_object_info_update]
(
	@p_id			   bigint
	,@p_plat_no						nvarchar(50)	= ''
	,@p_chassis_no					nvarchar(50)	= ''
	,@p_engine_no					nvarchar(50)	= ''
	,@p_serial_no					nvarchar(50)	= ''
	,@p_invoice_no					nvarchar(50)	= ''
	,@p_domain						nvarchar(50)	= ''
	,@p_imei						nvarchar(50)	= ''
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists(select 1 from dbo.purchase_order_detail_object_info obj 
		inner join dbo.purchase_order_detail pod on pod.id = obj.purchase_order_detail_id
		inner join dbo.purchase_order po on po.code = pod.po_code 
		where obj.plat_no = @p_plat_no and obj.plat_no <> '' and obj.id <> @p_id AND po.STATUS <> 'CANCEL')
		begin
			set @msg = 'Plat No. ' + @p_plat_no + ' already exist.' ;
			raiserror(@msg, 16, -1) ;
		end
		if exists(select 1 from dbo.purchase_order_detail_object_info obj 
		inner join dbo.purchase_order_detail pod on pod.id = obj.purchase_order_detail_id
		inner join dbo.purchase_order po on po.code = pod.po_code 
		where obj.engine_no = @p_engine_no and obj.engine_no <> '' and obj.id <> @p_id AND po.STATUS <> 'CANCEL')
		begin
			set @msg = 'Engine No. '+ @p_engine_no + ' already exist.' ;
			raiserror(@msg, 16, -1) ;
		end
		if exists(select 1 from dbo.purchase_order_detail_object_info obj 
		inner join dbo.purchase_order_detail pod on pod.id = obj.purchase_order_detail_id
		inner join dbo.purchase_order po on po.code = pod.po_code 
		where obj.chassis_no = @p_chassis_no and obj.chassis_no <> '' and obj.id <> @p_id AND po.STATUS <> 'CANCEL')
		begin
			set @msg = 'Chasis No. ' + @p_chassis_no + ' already exist.' ;
			raiserror(@msg, 16, -1) ;
		end

		if exists(select 1 from ifinams.dbo.asset_vehicle avh where avh.plat_no = @p_plat_no and avh.plat_no <> '')
		begin
			set @msg = 'Plat No. ' + @p_plat_no + ' already exist.' ;
			raiserror(@msg, 16, -1) ;
		end
		if exists(select 1 from ifinams.dbo.asset_vehicle avh where avh.engine_no = @p_engine_no and avh.engine_no <> '')
		begin
			set @msg = 'Engine No. ' + @p_engine_no + ' already exist.' ;
			raiserror(@msg, 16, -1) ;
		end
		if exists(select 1 from ifinams.dbo.asset_vehicle avh where avh.chassis_no = @p_chassis_no and avh.chassis_no <> '')
		begin
			set @msg = 'Chasis No. ' + @p_chassis_no + ' already exist.' ;
			raiserror(@msg, 16, -1) ;
		end

		if exists(select 1 from dbo.purchase_order_detail_object_info where id = @p_id and good_receipt_note_detail_id = 0)
		begin
			update	dbo.purchase_order_detail_object_info
			set		plat_no			= @p_plat_no
					,chassis_no		= @p_chassis_no
					,engine_no		= @p_engine_no
					,serial_no		= @p_serial_no
					,invoice_no		= @p_invoice_no
					,domain			= @p_domain
					,imei			= @p_imei
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	id = @p_id ;
		end
		else
		begin
			set @msg = 'Data already used in Good Receipt Note transaction' ;
			raiserror(@msg, 16, 1) ;
		end

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
