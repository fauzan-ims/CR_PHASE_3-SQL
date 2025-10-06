--Created, Jeff at 08-08-2023
CREATE PROCEDURE [dbo].[xsp_rpt_pemakaian_jasa_vendor_stnk]
(
	@p_user_id			nvarchar(50) = ''
	,@p_year			nvarchar(4)
	,@p_type			nvarchar(50)
)
as
BEGIN

	delete dbo.RPT_PEMAKAIAN_JASA_VENDOR_STNK
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@vendor_name					nvarchar(50)	
			,@payment_date					datetime		
			,@no_kwitansi					nvarchar(50)	
			,@plat_no						nvarchar(50)	
			,@customer						nvarchar(50)	
			,@agreement_no					nvarchar(50)	
			,@object_lease					nvarchar(50)	
			,@category_asset				nvarchar(50)	
			,@jasa							decimal(18, 2)	
			,@pph							decimal(18, 2)	
			,@spare_part					decimal(18, 2)
			,@sub_material					nvarchar(50)	
			,@ppn							decimal(18, 2)	
			,@material						int	
			,@other							int	
			,@total							decimal(18, 2)
			,@type_code						nvarchar(50)

	begin try
	
		SELECT	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'Report Pemakaian Jasa Vendor';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		if @p_type = 'STNK'
		set @type_code = 'PBSPSTN'
		else
		set @type_code = 'PBSPKEUR';

	BEGIN

			insert into dbo.RPT_PEMAKAIAN_JASA_VENDOR_STNK
			(
				USER_ID
				,REPORT_TITLE
				,REPORT_IMAGE
				,REPORT_COMPANY
				,type
				,BIRO_JASA_CODE
				,NAMA_BIRO_JASA
				,JANUARI
				,FEBRUARI
				,MARET
				,APRIL
				,MEI
				,JUNI
				,JULI
				,AGUSTUS
				,SEPTEMBER
				,OKTOBER
				,NOVEMBER
				,DESEMBER
				,YEAR
			)
			select	distinct
					@p_user_id
					,@report_title
					,@report_image
					,@report_company
					,@p_type
					,mps.code
					,mps.public_service_name
					,januari.jumlah
					,februari.jumlah
					,maret.jumlah
					,april.jumlah
					,mei.jumlah
					,juni.jumlah
					,juli.jumlah
					,agustus.jumlah
					,september.jumlah
					,oktober.jumlah
					,november.jumlah
					,desember.jumlah
					,@p_year
			from	dbo.register_main rmain
					left join register_detail rde on rde.register_code = rmain.code
					left join order_detail ode on ode.register_code = rmain.code
					left join order_main oma on oma.code = ode.order_code
					inner join dbo.master_public_service mps on mps.code = oma.public_service_code
					outer apply
			(
				select	count(rde.id) 'jumlah'
				from	dbo.register_main rmain
						left join register_detail rde on rde.register_code	   = rmain.code
						left join order_detail ode on ode.register_code		   = rmain.code
						left join order_main oma on oma.code				   = ode.order_code
						inner join dbo.master_public_service mps2 on mps2.code = oma.public_service_code
				where	rde.service_code		  = @type_code
						and month(oma.order_date) = '1'
						and year(oma.order_date)  = @p_year
						and mps2.code			  = mps.code
						and rmain.payment_status = 'PAID'
			) januari
					outer apply
			(
				select	count(rde.id) 'jumlah'
				from	dbo.register_main rmain
						left join register_detail rde on rde.register_code	   = rmain.code
						left join order_detail ode on ode.register_code		   = rmain.code
						left join order_main oma on oma.code				   = ode.order_code
						inner join dbo.master_public_service mps2 on mps2.code = oma.public_service_code
				where	rde.service_code		  = @type_code
						and month(oma.order_date) = '2'
						and year(oma.order_date)  = @p_year
						and mps2.code			  = mps.code
						and rmain.payment_status = 'PAID'
			) februari
					outer apply
			(
				select	count(rde.id) 'jumlah'
				from	dbo.register_main rmain
						left join register_detail rde on rde.register_code	   = rmain.code
						left join order_detail ode on ode.register_code		   = rmain.code
						left join order_main oma on oma.code				   = ode.order_code
						inner join dbo.master_public_service mps2 on mps2.code = oma.public_service_code
				where	rde.service_code		  = @type_code
						and month(oma.order_date) = '3'
						and year(oma.order_date)  = @p_year
						and mps2.code			  = mps.code
						and rmain.payment_status = 'PAID'
			) maret 
					outer apply
			(
				select	count(rde.id) 'jumlah'
				from	dbo.register_main rmain
						left join register_detail rde on rde.register_code	   = rmain.code
						left join order_detail ode on ode.register_code		   = rmain.code
						left join order_main oma on oma.code				   = ode.order_code
						inner join dbo.master_public_service mps2 on mps2.code = oma.public_service_code
				where	rde.service_code		  = @type_code
						and month(oma.order_date) = '4'
						and year(oma.order_date)  = @p_year
						and mps2.code			  = mps.code
						and rmain.payment_status = 'PAID'
			) april 
					outer apply
			(
				select	count(rde.id) 'jumlah'
				from	dbo.register_main rmain
						left join register_detail rde on rde.register_code	   = rmain.code
						left join order_detail ode on ode.register_code		   = rmain.code
						left join order_main oma on oma.code				   = ode.order_code
						inner join dbo.master_public_service mps2 on mps2.code = oma.public_service_code
				where	rde.service_code		  = @type_code
						and month(oma.order_date) = '5'
						and year(oma.order_date)  = @p_year
						and mps2.code			  = mps.code
						and rmain.payment_status = 'PAID'
			) mei
					outer apply
			(
				select	count(rde.id) 'jumlah'
				from	dbo.register_main rmain
						left join register_detail rde on rde.register_code	   = rmain.code
						left join order_detail ode on ode.register_code		   = rmain.code
						left join order_main oma on oma.code				   = ode.order_code
						inner join dbo.master_public_service mps2 on mps2.code = oma.public_service_code
				where	rde.service_code		  = @type_code
						and month(oma.order_date) = '6'
						and year(oma.order_date)  = @p_year
						and mps2.code			  = mps.code
						and rmain.payment_status = 'PAID'
			) juni
			outer apply
			(
				select	count(rde.id) 'jumlah'
				from	dbo.register_main rmain
						left join register_detail rde on rde.register_code	   = rmain.code
						left join order_detail ode on ode.register_code		   = rmain.code
						left join order_main oma on oma.code				   = ode.order_code
						inner join dbo.master_public_service mps2 on mps2.code = oma.public_service_code
				where	rde.service_code		  = @type_code
						and month(oma.order_date) = '7'
						and year(oma.order_date)  = @p_year
						and mps2.code			  = mps.code
						and rmain.payment_status = 'PAID'
			) juli
					outer apply
			(
				select	count(rde.id) 'jumlah'
				from	dbo.register_main rmain
						left join register_detail rde on rde.register_code	   = rmain.code
						left join order_detail ode on ode.register_code		   = rmain.code
						left join order_main oma on oma.code				   = ode.order_code
						inner join dbo.master_public_service mps2 on mps2.code = oma.public_service_code
				where	rde.service_code		  = @type_code
						and month(oma.order_date) = '8'
						and year(oma.order_date)  = @p_year
						and mps2.code			  = mps.code
						and rmain.payment_status  = 'PAID'
			) agustus
					outer apply
			(
				select	count(rde.id) 'jumlah'
				from	dbo.register_main rmain
						left join register_detail rde on rde.register_code	   = rmain.code
						left join order_detail ode on ode.register_code		   = rmain.code
						left join order_main oma on oma.code				   = ode.order_code
						inner join dbo.master_public_service mps2 on mps2.code = oma.public_service_code
				where	rde.service_code		  = @type_code
						and month(oma.order_date) = '9'
						and year(oma.order_date)  = @p_year
						and mps2.code			  = mps.code
						and rmain.payment_status  = 'PAID'
			) september 
					outer apply
			(
				select	count(rde.id) 'jumlah'
				from	dbo.register_main rmain
						left join register_detail rde on rde.register_code	   = rmain.code
						left join order_detail ode on ode.register_code		   = rmain.code
						left join order_main oma on oma.code				   = ode.order_code
						inner join dbo.master_public_service mps2 on mps2.code = oma.public_service_code
				where	rde.service_code		  = @type_code
						and month(oma.order_date) = '10'
						and year(oma.order_date)  = @p_year
						and mps2.code			  = mps.code
						and rmain.payment_status  = 'PAID'
			) oktober 
					outer apply
			(
				select	count(rde.id) 'jumlah'
				from	dbo.register_main rmain
						left join register_detail rde on rde.register_code	   = rmain.code
						left join order_detail ode on ode.register_code		   = rmain.code
						left join order_main oma on oma.code				   = ode.order_code
						inner join dbo.master_public_service mps2 on mps2.code = oma.public_service_code
				where	rde.service_code		  = @type_code
						and month(oma.order_date) = '11'
						and year(oma.order_date)  = @p_year
						and mps2.code			  = mps.code
						and rmain.payment_status  = 'PAID'
			) november
					outer apply
			(
				select	count(rde.id) 'jumlah'
				from	dbo.register_main rmain
						left join register_detail rde on rde.register_code	   = rmain.code
						left join order_detail ode on ode.register_code		   = rmain.code
						left join order_main oma on oma.code				   = ode.order_code
						inner join dbo.master_public_service mps2 on mps2.code = oma.public_service_code
				where	rde.service_code		  = @type_code
						and month(oma.order_date) = '12'
						and year(oma.order_date)  = @p_year
						and mps2.code			  = mps.code
						and rmain.payment_status  = 'PAID'
			) desember
			;
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
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

