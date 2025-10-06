CREATE PROCEDURE dbo.xsp_good_receipt_note_detail_object_info_update
(
	@p_id			   bigint
	,@p_plat_no		   nvarchar(50) = ''
	,@p_chassis_no	   nvarchar(50) = ''
	,@p_engine_no	   nvarchar(50) = ''
	,@p_serial_no	   nvarchar(50) = ''
	,@p_invoice_no	   nvarchar(50) = ''
	,@p_domain		   nvarchar(50) = ''
	,@p_imei		   nvarchar(50) = ''
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@asset_code nvarchar(50);

			select	@asset_code = gdr.type_asset_code
			from	dbo.good_receipt_note_detail_object_info gdrno
					inner join good_receipt_note_detail gdr on (gdr.id = gdrno.good_receipt_note_detail_id)
			where	gdrno.id = @p_id

	begin try

		--Validasi jika ada plat no, engine no, dan chassis no yang sama
		if exists
		(
			select	1
			from	dbo.good_receipt_note_detail_object_info
			where	plat_no		= @p_plat_no
					and id		<> @p_id
					and plat_no <> ''
		)
		begin
			set @msg = N'Plat no already exist.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.good_receipt_note_detail_object_info
			where	engine_no	  = @p_engine_no
					and id		  <> @p_id
					and engine_no <> ''
		)
		begin
			set @msg = N'Engine no already exist.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.good_receipt_note_detail_object_info
			where	chassis_no	   = @p_chassis_no
					and id		   <> @p_id
					and chassis_no <> ''
		)
		begin
			set @msg = N'Chassis no already exist.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.good_receipt_note_detail_object_info
			where	serial_no	  = @p_serial_no
					and id		  <> @p_id
					and serial_no <> ''
		)
		begin
			set @msg = N'Serial no already exist.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.good_receipt_note_detail_object_info
			where	invoice_no	   = @p_invoice_no
					and id		   <> @p_id
					and invoice_no <> ''
		)
		begin
			set @msg = N'Invoice no already exist.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.good_receipt_note_detail_object_info
			where	domain		 = @p_domain
					and id		 <> @p_id
					and domain	 <> ''
		)
		begin
			set @msg = N'Domain already exist.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.good_receipt_note_detail_object_info
			where	imei		 = @p_imei
					and id		 <> @p_id
					and imei	 <> ''
		)
		begin
			set @msg = N'IMEI already exist.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		--Validasi jika ada plat no, engine no, dan chassis no yang sama di module asset

		--Validasi jika ada plat no yg sama di module asset
		if exists
		(
			select	1
			from	ifinams.dbo.asset_vehicle assv
					inner join ifinams.dbo.asset ass on (ass.code = assv.asset_code)
			where	plat_no		= @p_plat_no
					and plat_no <> ''
		)
		begin
			set @msg = N'Plat no already exist.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		--Akhir Validasi jika ada plat no yg sama di module asset

		--Validasi jika ada engine no yg sama di module asset
		if exists
		(
			select	1
			from	ifinams.dbo.asset ass
					inner join ifinams.dbo.asset_vehicle assv on (assv.asset_code = ass.code)
			where	assv.engine_no	  = @p_engine_no
					and assv.engine_no <> ''


		)
		begin
			set @msg = N'Engine no already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	ifinams.dbo.asset ass
					inner join ifinams.dbo.asset_he assh on (assh.asset_code = ass.code)
			where	assh.engine_no	  = @p_engine_no
					and assh.engine_no <> ''


		)
		begin
			set @msg = N'Engine no already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	ifinams.dbo.asset ass
					inner join ifinams.dbo.asset_machine assm on (assm.asset_code = ass.code)
			where	assm.engine_no	  = @p_engine_no
					and assm.engine_no <> ''


		)
		begin
			set @msg = N'Engine no already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;
		--Akhir Validasi jika ada engino no yg sama di module asset

		--Validasi jika ada Chassis no yg sama di module asset
		if exists
		(
			select	1
			from	ifinams.dbo.asset ass
					inner join ifinams.dbo.asset_vehicle assv on (assv.asset_code = ass.code)
			where	assv.chassis_no	  = @p_chassis_no
					and assv.chassis_no <> ''


		)
		begin
			set @msg = N'Chassis no already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	ifinams.dbo.asset ass
					inner join ifinams.dbo.asset_he assh on (assh.asset_code = ass.code)
			where	assh.chassis_no	  = @p_chassis_no
					and assh.chassis_no <> ''


		)
		begin
			set @msg = N'Chassis no already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	ifinams.dbo.asset ass
					inner join ifinams.dbo.asset_machine assm on (assm.asset_code = ass.code)
			where	assm.chassis_no	  = @p_chassis_no
					and assm.chassis_no <> ''


		)
		begin
			set @msg = N'Chassis no already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;
		--Akhir Validasi jika ada Chassis no yg sama di module asset

		--Validasi jika ada Serial no yg sama di module asset
		if exists
		(
			select	1
			from	ifinams.dbo.asset ass
					inner join ifinams.dbo.asset_electronic asse on (asse.asset_code = ass.code)
			where	asse.serial_no	  = @p_serial_no
					and serial_no	  <> ''
		)
		begin
			set @msg = N'Serial no already exist.' ;

			raiserror(@msg, 16, -1) ;
		end ;
		--Akhir Validasi jika ada Serial no yg sama di module asset

		--Validasi jika ada Invoice no yg sama di module asset
		if exists
		(
			select	1
			from	ifinams.dbo.asset ass
					inner join ifinams.dbo.asset_he assh on (assh.asset_code = ass.code)
			where	assh.invoice_no		= @p_invoice_no
					and assh.invoice_no <> ''
		)
		begin
			set @msg = N'Invoice no already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	ifinams.dbo.asset ass
					inner join ifinams.dbo.asset_machine assm on (assm.asset_code = ass.code)
			where	assm.invoice_no		= @p_invoice_no
					and assm.invoice_no <> ''


		)
		begin
			set @msg = N'Invoice no already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;
		--Akhir Validasi jika ada Invoice no yg sama di module asset

		--Validasi jika ada domain yg sama di module asset
		if exists
		(
			select	1
			from	ifinams.dbo.asset ass
					inner join ifinams.dbo.asset_electronic asse on (asse.asset_code = ass.code)
			where	asse.domain	  = @p_domain
					and domain	  <> ''
		)
		begin
			set @msg = N'Domain already exist.' ;

			raiserror(@msg, 16, -1) ;
		end ;
		--Akhir Validasi jika ada domain yg sama di module asset

		--Validasi jika ada domain yg sama di module asset
		if exists
		(
			select	1
			from	ifinams.dbo.asset ass
					inner join ifinams.dbo.asset_electronic asse on (asse.asset_code = ass.code)
			where	asse.imei	  = @p_imei
					and imei	  <> ''
		)
		begin
			set @msg = N'IMEI already exist.' ;

			raiserror(@msg, 16, -1) ;
		end ;
		--Akhir Validasi jika ada domain yg sama di module asset

		update	good_receipt_note_detail_object_info
		set		plat_no = @p_plat_no
				,chassis_no = @p_chassis_no
				,engine_no = @p_engine_no
				,serial_no = @p_serial_no
				,invoice_no = @p_invoice_no
				,domain		= @p_domain
				,imei		= @p_imei
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
