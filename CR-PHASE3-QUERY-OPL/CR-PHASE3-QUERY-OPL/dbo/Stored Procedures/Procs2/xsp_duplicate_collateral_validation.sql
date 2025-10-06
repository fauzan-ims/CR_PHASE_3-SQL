CREATE PROCEDURE dbo.xsp_duplicate_collateral_validation
(
	@p_application_collateral_no nvarchar(50) = null
	,@p_application_asset_no	 nvarchar(50) = null
	,@p_plafond_collateral_no	 nvarchar(50) = null
	,@p_collateral_type			 nvarchar(10)
	,@p_serial_no				 nvarchar(50) = null
	,@p_invoice_no				 nvarchar(50) = null
	,@p_certificate_no			 nvarchar(50) = null
	,@p_chassis_no				 nvarchar(50) = null
	,@p_engine_no				 nvarchar(50) = null
	,@p_faktur_no				 nvarchar(50) = null
	,@p_bpkb_no					 nvarchar(50) = null
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_collateral_type = 'ELEC')
		begin
			if exists
			(
				select	1
				from	dbo.plafond_collateral_electronic aaf
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aaf.collateral_no)
						inner join dbo.plafond_main am on (am.code				  = aa.plafond_code)
				where	aaf.serial_no		 = @p_serial_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and am.plafond_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Serial No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_collateral_electronic aaf
						inner join dbo.application_collateral aa on (aa.collateral_no = aaf.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aaf.serial_no		 = @p_serial_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Serial No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_asset_electronic aaf
						inner join dbo.application_asset aa on (aa.asset_no		 = aaf.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	  aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Serial No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;
		else if (@p_collateral_type = 'FUR')
		begin
			if exists
			(
				select	1
				from	dbo.plafond_collateral_furniture aaf
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aaf.collateral_no)
						inner join dbo.plafond_main am on (am.code				  = aa.plafond_code)
				where	aaf.serial_no		 = @p_serial_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and am.plafond_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Serial No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_collateral_furniture acv
						inner join dbo.application_collateral aa on (aa.collateral_no = acv.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	acv.serial_no		 = @p_serial_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Serial No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_asset_furniture acv
						inner join dbo.application_asset aa on (aa.asset_no		 = acv.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	acv.serial_no	= @p_serial_no
						and aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Serial No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;
		else if (@p_collateral_type = 'MHCN')
		begin
			if exists
			(
				select	1
				from	dbo.plafond_collateral_machine aam
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	aam.invoice_no		 = @p_invoice_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Invoice No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_machine aam
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	aam.certificate_no	 = @p_certificate_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Certificate No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_machine aam
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	aam.chassis_no		 = @p_chassis_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Chassis No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_machine aam
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	aam.engine_no		 = @p_engine_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Engine No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_machine aam
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	aam.serial_no		 = @p_serial_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Serial No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_machine aam
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	aam.faktur_no		 = @p_faktur_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Faktur No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_collateral_machine aam
						inner join dbo.application_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aam.invoice_no		 = @p_invoice_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Invoice No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_machine aam
						inner join dbo.application_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aam.certificate_no	 = @p_certificate_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Certificate No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_machine aam
						inner join dbo.application_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aam.chassis_no		 = @p_chassis_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Chassis No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_machine aam
						inner join dbo.application_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aam.engine_no		 = @p_engine_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Engine No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_machine aam
						inner join dbo.application_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aam.serial_no		 = @p_serial_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Serial No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_machine aam
						inner join dbo.application_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aam.faktur_no		 = @p_faktur_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Faktur No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_asset_machine aam
						inner join dbo.application_asset aa on (aa.asset_no		 = aam.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	  aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Invoice No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_machine aam
						inner join dbo.application_asset aa on (aa.asset_no		 = aam.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	  aa.asset_no	   <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Certificate No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_machine aam
						inner join dbo.application_asset aa on (aa.asset_no		 = aam.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	  aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Chassis No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_machine aam
						inner join dbo.application_asset aa on (aa.asset_no		 = aam.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	 aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Engine No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_machine aam
						inner join dbo.application_asset aa on (aa.asset_no		 = aam.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	 aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Serial No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_machine aam
						inner join dbo.application_asset aa on (aa.asset_no		 = aam.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	 aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Faktur No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;
		else if (@p_collateral_type = 'HE')
		begin
			if exists
			(
				select	1
				from	dbo.plafond_collateral_he aam
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	aam.invoice_no		 = @p_invoice_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Invoice No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_he aam
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	aam.certificate_no	 = @p_certificate_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Certificate No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_he aam
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	aam.chassis_no		 = @p_chassis_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Chassis No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_he aam
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	aam.engine_no		 = @p_engine_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Engine No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_he aam
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	aam.serial_no		 = @p_serial_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Serial No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_he aam
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	aam.faktur_no		 = @p_faktur_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Faktur No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_collateral_he aam
						inner join dbo.application_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aam.invoice_no		 = @p_invoice_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Invoice No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_he aam
						inner join dbo.application_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aam.certificate_no	 = @p_certificate_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Certificate No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_he aam
						inner join dbo.application_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aam.chassis_no		 = @p_chassis_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Chassis No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_he aam
						inner join dbo.application_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aam.engine_no		 = @p_engine_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Engine No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_he aam
						inner join dbo.application_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aam.serial_no		 = @p_serial_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Serial No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_he aam
						inner join dbo.application_collateral aa on (aa.collateral_no = aam.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	aam.faktur_no		 = @p_faktur_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Faktur No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_asset_he aam
						inner join dbo.application_asset aa on (aa.asset_no		 = aam.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	  aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Invoice No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_he aam
						inner join dbo.application_asset aa on (aa.asset_no		 = aam.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	 aa.asset_no	   <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Certificate No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_he aam
						inner join dbo.application_asset aa on (aa.asset_no		 = aam.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	 aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Chassis No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_he aam
						inner join dbo.application_asset aa on (aa.asset_no		 = aam.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	  aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Engine No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_he aam
						inner join dbo.application_asset aa on (aa.asset_no		 = aam.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	  aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Serial No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_he aam
						inner join dbo.application_asset aa on (aa.asset_no		 = aam.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	 aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Faktur No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;
		else if (@p_collateral_type = 'PROP')
		begin
			if exists
			(
				select	1
				from	dbo.plafond_collateral_property pcp
						inner join dbo.plafond_collateral aa on (aa.collateral_no = pcp.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	pcp.certificate_no	 = @p_certificate_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Certificate No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_collateral_property asp
						inner join dbo.application_collateral aa on (aa.collateral_no = asp.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	asp.certificate_no	 = @p_certificate_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Certificate No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_asset_property asp
						inner join dbo.application_asset aa on (aa.asset_no		 = asp.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	asp.certificate_no = @p_certificate_no
						and aa.asset_no	   <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Certificate No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;
		else if (@p_collateral_type = 'VHCL')
		begin
			if exists
			(
				select	1
				from	dbo.plafond_collateral_vehicle acv
						inner join dbo.plafond_collateral aa on (aa.collateral_no = acv.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	acv.faktur_no		 = @p_faktur_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Faktur No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_vehicle acv
						inner join dbo.plafond_collateral aa on (aa.collateral_no = acv.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	acv.chassis_no		 = @p_chassis_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Chassis No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_vehicle acv
						inner join dbo.plafond_collateral aa on (aa.collateral_no = acv.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	acv.engine_no		 = @p_engine_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Engine No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.plafond_collateral_vehicle acv
						inner join dbo.plafond_collateral aa on (aa.collateral_no = acv.collateral_no)
						inner join dbo.plafond_main pm on (pm.code				  = aa.plafond_code)
				where	acv.bpkb_no			 = @p_bpkb_no
						and aa.collateral_no <> isnull(@p_plafond_collateral_no, aa.collateral_no)
						and pm.plafond_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Bpkb No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_collateral_vehicle acv
						inner join dbo.application_collateral aa on (aa.collateral_no = acv.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	acv.faktur_no		 = @p_faktur_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Faktur No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_vehicle acv
						inner join dbo.application_collateral aa on (aa.collateral_no = acv.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	acv.chassis_no		 = @p_chassis_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Chassis No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_vehicle acv
						inner join dbo.application_collateral aa on (aa.collateral_no = acv.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	acv.engine_no		 = @p_engine_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Engine No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_collateral_vehicle acv
						inner join dbo.application_collateral aa on (aa.collateral_no = acv.collateral_no)
						inner join dbo.application_main am on (am.application_no	  = aa.application_no)
				where	acv.bpkb_no			 = @p_bpkb_no
						and aa.collateral_no <> isnull(@p_application_collateral_no, aa.collateral_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Bpkb No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_asset_vehicle acv
						inner join dbo.application_asset aa on (aa.asset_no		 = acv.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	 aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
			(
				'CANCEL', 'GO LIVE'
			)
			)
			begin
				set @msg = 'Faktur No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_vehicle acv
						inner join dbo.application_asset aa on (aa.asset_no		 = acv.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	  aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Chassis No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_vehicle acv
						inner join dbo.application_asset aa on (aa.asset_no		 = acv.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	  aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Engine No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset_vehicle acv
						inner join dbo.application_asset aa on (aa.asset_no		 = acv.asset_no)
						inner join dbo.application_main am on (am.application_no = aa.application_no)
				where	  aa.asset_no <> isnull(@p_application_asset_no, aa.asset_no)
						and am.application_status not in
				 (
					 'CANCEL', 'GO LIVE'
				 )
			)
			begin
				set @msg = 'Bpkb No already exists' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;
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
