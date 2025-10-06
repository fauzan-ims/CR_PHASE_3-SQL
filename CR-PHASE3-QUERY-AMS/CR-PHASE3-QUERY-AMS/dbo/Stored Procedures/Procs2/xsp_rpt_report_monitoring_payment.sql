--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_report_monitoring_payment
(
	@p_user_id			nvarchar(50) = ''
	,@p_from_date		datetime		= null
	,@p_to_date			datetime		= null
)
as
BEGIN

	delete rpt_report_monitoring_payment
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

	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP' ;

		set	@report_title = 'REPORT PER CUSTOMER';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			insert into rpt_report_monitoring_payment
			(
				user_id
				,report_company
				,report_title
				,report_image
				,vendor_name	
				,payment_date	
				,no_kwitansi	
				,plat_no		
				,customer		
				,agreement_no	
				,object_lease	
				,category_asset
				,jasa			
				,pph
				,spare_part			
				,sub_material	
				,ppn			
				,material		
				,other			
				,total			
			)
			VALUES
			(
				@p_user_id
				,@report_company				
				,@report_title
				,@report_image
				,@vendor_name	
				,@payment_date	
				,@no_kwitansi	
				,@plat_no		
				,@customer		
				,@agreement_no	
				,@object_lease	
				,@category_asset
				,@jasa			
				,@pph		
				,@spare_part	
				,@sub_material	
				,@ppn			
				,@material		
				,@other			
				,@total					
			)
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

