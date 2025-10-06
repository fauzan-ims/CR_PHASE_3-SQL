--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_report_delivery_unit
(
	@p_user_id			nvarchar(50) = ''
	,@p_branch_code		nvarchar(50) = ''
	,@p_from_date		datetime	= null
    ,@p_to_date			datetime	= null
)
as
BEGIN

	delete dbo.rpt_report_delivery_unit
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@branch_code					nvarchar(50)	
			,@branch_name					nvarchar(50)	
			,@delivery_or_collect			nvarchar(50)	
			,@unit_condition				nvarchar(50)	
			,@status_pengiriman				nvarchar(50)	
			,@agreement_no					nvarchar(50)	
			,@lessee						nvarchar(50)	
			,@lessee_address				nvarchar(50)	
			,@pic_lesse						nvarchar(150)	
			,@lessee_contact_number			nvarchar(50)	
			,@description_unit_utama		nvarchar(50)	
			,@year							int
			,@plat_no						nvarchar(50)	
			,@chassis_no					nvarchar(50)	
			,@engine_no						nvarchar(50)	
			,@color							nvarchar(50)	
			,@delivery_date					datetime		
			,@bast_date						datetime		
			,@upload_bast_date				datetime		

	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP' ;

		set	@report_title = 'REPORT PER CUSTOMER';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			insert into rpt_report_delivery_unit
			(
				user_id
				,report_company
				,report_title
				,report_image
				,branch_code
				,branch_name
				,delivery_or_collect
				,unit_condition
				,status_pengiriman
				,agreement_no
				,lessee
				,lessee_address
				,pic_lesse
				,lessee_contact_number
				,description_unit_utama
				,year
				,plat_no
				,chassis_no
				,engine_no
				,color
				,delivery_date
				,bast_date
				,upload_bast_date
			)
			VALUES
			(
				@p_user_id
				,@report_company				
				,@report_title
				,@report_image
				,@branch_code			
				,@branch_name			
				,@delivery_or_collect	
				,@unit_condition		
				,@status_pengiriman		
				,@agreement_no			
				,@lessee				
				,@lessee_address		
				,@pic_lesse				
				,@lessee_contact_number	
				,@description_unit_utama
				,@year					
				,@plat_no				
				,@chassis_no			
				,@engine_no				
				,@color					
				,@delivery_date			
				,@bast_date				
				,@upload_bast_date			
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

