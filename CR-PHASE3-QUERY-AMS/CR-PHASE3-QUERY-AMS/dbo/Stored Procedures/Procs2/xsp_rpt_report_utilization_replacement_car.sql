--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_report_utilization_replacement_car
(
	@p_user_id			nvarchar(50) = ''
	,@p_from_date		datetime		= null
	,@p_to_date			datetime		= null
)
as
BEGIN

	delete rpt_report_utilization_replacement_car
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@dateout						datetime		
			,@incoming_status				nvarchar(50)	
			,@agreement_no					nvarchar(50)	
			,@status_unit					nvarchar(50)	
			,@status_pemakaian				nvarchar(50)	
			,@ex_customer					nvarchar(50)	
			,@leased_object					nvarchar(50)	
			,@year							int
			,@chassis_no					nvarchar(50)	
			,@engine_no						nvarchar(50)	
			,@plat_no						nvarchar(50)	
			,@customer_name					nvarchar(50)	
	
	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP' ;

		set	@report_title = 'REPORT PER CUSTOMER';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			insert into rpt_report_utilization_replacement_car
			(
				user_id
				,report_company
				,report_title
				,report_image
				,dateout
				,incoming_status
				,agreement_no
				,status_unit
				,status_pemakaian
				,ex_customer
				,leased_object
				,year
				,chassis_no
				,engine_no
				,plat_no
				,customer_name
			)
			select	@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,hast.handover_date
					,hast.process_status
					,ast.agreement_no
					,aag.rental_status
					,ast.status
					,client.client_name
					,ast.item_name
					,avi.built_year
					,avi.chassis_no
					,avi.engine_no
					,avi.plat_no
					,ast.client_name
			from	ifinams.dbo.handover_asset hast
					inner join ifinams.dbo.asset ast on hast.fa_code = ast.code
					inner join ifinams.dbo.asset_vehicle avi on avi.asset_code = ast.code
					left join ifinams.dbo.asset_aging aag on aag.code = ast.code
					outer apply
								(
									select		top 1
												asg.client_name
									from		ifinams.dbo.asset_aging asg
									where		asg.code	 = ast.code
												and asg.agreement_no != ast.agreement_no
									order by	asg.aging_date desc
								) client
			where	hast.TYPE = 'REPLACE OUT' ;

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

