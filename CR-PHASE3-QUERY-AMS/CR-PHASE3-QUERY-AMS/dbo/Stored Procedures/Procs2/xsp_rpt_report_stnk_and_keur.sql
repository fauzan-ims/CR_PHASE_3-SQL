--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_report_stnk_and_keur
(
	@p_user_id			nvarchar(50) = ''
	,@p_from_date		datetime		= null
	,@p_to_date			datetime		= null
)
as
BEGIN

	delete rpt_report_stnk_and_keur
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@asset_no						nvarchar(50)
			,@lessee						NVARCHAR(50)
			,@brand							nvarchar(50)
			,@type							nvarchar(50)
			,@surat_kuasa					nvarchar(50)
			,@object						nvarchar(50)
			,@color							nvarchar(50)
			,@year							int			
			,@chassis_no					nvarchar(50)
			,@engine_no						nvarchar(50)
			,@plat_no						nvarchar(50)
			,@keur_or_stnk					nvarchar(50)
			,@end_date_keur_or_stnk			datetime	
			,@area							nvarchar(50)
			,@keur_or_stnk_region			nvarchar(50)
			,@order_name					nvarchar(50)
			,@birojasa_name					nvarchar(50)
			,@date_received_file			datetime	
			,@end_date_new					datetime	
			,@date_of_delivery_cust			datetime	
			,@name							nvarchar(50)
			,@address						nvarchar(50)
			,@no_telp						nvarchar(50)
			,@notes							nvarchar(50)
			,@report_date					datetime	

	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP' ;

		set	@report_title = 'REPORT PER CUSTOMER';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			insert into rpt_report_stnk_and_keur
			(
				user_id
				,report_company
				,report_title
				,report_image
				,asset_no					
				,lessee					
				,brand						
				,type						
				,surat_kuasa				
				,object					
				,color						
				,year						
				,chassis_no				
				,engine_no					
				,plat_no					
				,keur_or_stnk				
				,end_date_keur_or_stnk		
				,area						
				,keur_or_stnk_region		
				,order_name				
				,birojasa_name				
				,date_received_file		
				,end_date_new				
				,date_of_delivery_cust		
				,name						
				,address					
				,no_telp					
				,notes						
				,report_date				
						
			)
			VALUES
			(
				@p_user_id
				,@report_company				
				,@report_title
				,@report_image
				,@asset_no					
				,@lessee					
				,@brand						
				,@type						
				,@surat_kuasa				
				,@object					
				,@color						
				,@year						
				,@chassis_no				
				,@engine_no					
				,@plat_no					
				,@keur_or_stnk				
				,@end_date_keur_or_stnk		
				,@area						
				,@keur_or_stnk_region		
				,@order_name				
				,@birojasa_name				
				,@date_received_file		
				,@end_date_new				
				,@date_of_delivery_cust		
				,@name						
				,@address					
				,@no_telp					
				,@notes						
				,@report_date							
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

