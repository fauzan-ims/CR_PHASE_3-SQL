--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_report_asset
(
	@p_user_id			nvarchar(50) = ''
	,@p_branch_code		NVARCHAR(50) = ''
	,@p_from_date		datetime		= null
	,@p_to_date			datetime		= null
)
as
BEGIN

	delete	dbo.rpt_report_asset
	where	user_id = @p_user_id ;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)	
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(50)
			,@plat_no						nvarchar(50)
			,@brand							nvarchar(50)
			,@product_category				nvarchar(50)
			,@vehicle_ype					nvarchar(50)
			,@chassis_no					nvarchar(50)
			,@engine_no						nvarchar(50)
			,@yeardate							nvarchar(50)
			,@color							nvarchar(50)
			,@mileage						int
			,@lessee						nvarchar(50)
			,@agreement_no					nvarchar(50)
			,@beginning_period				datetime
			,@ending_period					nvarchar(50)
			,@period						int
			,@status						nvarchar(50)
			,@aging							int
			,@province						nvarchar(50)
			,@city							nvarchar(50)
			,@parking_location				nvarchar(50)
			,@contract_status				nvarchar(50)
			,@stnk_date						nvarchar(50)
			,@keur							nvarchar(50)
			,@color_plat					nvarchar(50)
			,@insurance_polis				nvarchar(50)
			,@insurance_company				nvarchar(50)
			,@start_date					datetime
			,@end_date						nvarchar(50)
			,@supplier						nvarchar(50)
			,@maintenance_scheme			nvarchar(50)
			,@cop_non_cop					nvarchar(50)
			,@ni							nvarchar(50)
			,@registration_budget			decimal(18, 2)
			,@maintenance_budget			decimal(18, 2)
			,@replacement_budget			decimal(18, 2)
			,@insurance_cost				decimal(18, 2)
			,@mobilization_cost				decimal(18, 2)
			,@marketing_officer				nvarchar(50)
			,@remark						NVARCHAR(50)
	
	begin try
	
		SELECT	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP' ;

		set	@report_title = 'PHYSICAL UNIT CHECKING FORM';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			INSERT INTO rpt_report_asset
			(
				user_id
				,report_company
				,report_title
				,report_image
				,branch_code
				,branch_name
				,plat_no
				,brand
				,product_category
				,vehicle_ype
				,chassis_no
				,engine_no
				,year_item
				,color
				,mileage
				,lessee
				,agreement_no
				,beginning_period
				,ending_period
				,period
				,status
				,aging
				,province
				,city
				,parking_location
				,contract_status
				,stnk_date
				,keur
				,color_plat
				,insurance_polis
				,insurance_company
				,start_date
				,end_date
				,supplier
				,maintenance_scheme
				,cop_non_cop
				,ni
				,registration_budget
				,maintenance_budget
				,replacement_budget
				,insurance_cost
				,mobilization_cost
				,marketing_officer
				,REMARK
			)
			SELECT	@p_user_id
					,@report_company
					,@report_title	
					,@report_image	
					,ass.BRANCH_CODE
					,ass.BRANCH_NAME
					,av.PLAT_NO
					,'' --brand
					,'' --product
					,av.TYPE_ITEM_NAME
					,av.CHASSIS_NO
					,av.ENGINE_NO
					,YEAR(ass.PURCHASE_DATE)
					,av.COLOUR
					,'' --milliage
					,'' -- lesse
					,ass.AGREEMENT_NO
					,'' --beginning
					,'' -- ending
					,'' --period
					,'' --status
					,'' --aging
					,'' --province
					,'' --city
					,'' --parkingloc
					,'' --contrac
					,'' --stnk_date
					,'' --keur
					,'' --colorplat
					,'' --insurancepolis
					,'' --insurancecomp
					,'' --startdate
					,'' --enddate
					,'' --supplier
					,null --maintenance
					,'' --
					,'' --ni
					,null --
					,null --
					,null --
					,null --
					,null --
					,'' -- marketing
					,'' --remark
			FROM asset ass
			LEFT JOIN dbo.ASSET_VEHICLE av ON (av.ASSET_CODE = ass.CODE)
			WHERE ass.BRANCH_CODE = @p_branch_code
			AND  cast(ass.PURCHASE_DATE as date)between cast(@p_from_date as date) and cast(@p_to_date as date) ;
		
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

