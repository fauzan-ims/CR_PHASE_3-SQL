-- Created By, Raffyanda 30/10/2023
CREATE PROCEDURE dbo.xsp_rpt_asset_depreciation
(
	@p_user_id			NVARCHAR(50)
	,@p_asset_code		NVARCHAR(50)
	,@p_branch_code		NVARCHAR(50) 
	,@p_branch_name		NVARCHAR(50) 
	,@p_item_name		NVARCHAR(50)
	,@p_is_condition	NVARCHAR(2)
	,@p_options			NVARCHAR(50)
)
AS
BEGIN

	delete dbo.rpt_asset_depreciation
	where user_id = @p_user_id;

	declare @msg				nvarchar(max)
			,@report_company	nvarchar(200)
			,@report_image		nvarchar(200)
			,@report_title		nvarchar(200);

	begin try 
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		if(@p_options = 'Commercial')
			begin
            set	@report_title = 'REPORT ASSET DEPRECIATION COMMERCIAL';
				insert into dbo.rpt_asset_depreciation
				(
				    user_id,
				    report_company,
				    report_title,
				    report_image,
					branch_code,
					branch_name,
				    asset_code,
				    asset_status,
					fisical_status,
				    purchase_price,
				    net_book,
					total_depreciation,
				    asset_name,
				    purchase_date,
				    rv,
				    date,
				    depreciation_amount,
				    net_book_value,
				    depreciation_date,
					is_depreciation,
					last_depreciation,
					reff_no,
					is_condition,
					plat_no
				)
				select @p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@p_branch_code
				,@p_branch_name
				,@p_asset_code 
				,a.status
				,a.fisical_status
				,a.purchase_price
				,a.net_book_value_comm
				,a.total_depre_comm
				,@p_item_name
				,a.purchase_date
				,a.residual_value
				,ac.depreciation_date
				,ac.depreciation_amount
				,ac.net_book_value
				,0
				,case 
					when a.is_permit_to_sell = '1' then 'Yes'
					else 'No' 
				end
				,a.depre_period_comm
				,ac.transaction_code
				,@p_is_condition
				,av.plat_no
				from dbo.asset a
				left join dbo.asset_depreciation_schedule_commercial ac on (ac.asset_code = a.code)
				left join dbo.asset_vehicle av on (av.asset_code = a.code)
				where a.code = @p_asset_code;
			END
          else
			begin
            set	@report_title = 'REPORT ASSET DEPRECIATION FISCAL';
				insert into dbo.rpt_asset_depreciation
				(
					user_id,
					report_company,
					report_title,
					report_image,
					branch_code,
					branch_name,
					asset_code,
					asset_status,
					fisical_status,
					purchase_price,
					net_book,
					total_depreciation,
					asset_name,
					purchase_date,
					rv,
					date,
					depreciation_amount,
					net_book_value,
					depreciation_date,
					is_depreciation,
					last_depreciation,
					reff_no,
					is_condition,
					plat_no
				)
				select @p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@p_branch_code
				,@p_branch_name
				,@p_asset_code 
				,a.status
				,a.fisical_status
				,a.purchase_price
				,a.net_book_value_fiscal
				,a.total_depre_fiscal
				,@p_item_name
				,a.purchase_date
				,a.residual_value
				,af.depreciation_date
				,af.depreciation_amount
				,af.net_book_value
				,0
				,case 
					when a.is_permit_to_sell = '1' then 'Yes'
					else 'No' 
				end
				,a.depre_period_fiscal
				,af.transaction_code
				,@p_is_condition
				,av.plat_no
				from dbo.asset a
				left join dbo.asset_depreciation_schedule_fiscal af on (af.asset_code = a.code)
				left join dbo.asset_vehicle av on (av.asset_code = a.code)
				where a.code = @p_asset_code;
			end

		if not exists (select * from dbo.rpt_asset_depreciation where user_id = @p_user_id)
		begin 
		insert into dbo.rpt_asset_depreciation
		(
		    user_id,
		    report_company,
		    report_title,
		    report_image,
		    branch_code,
		    branch_name,
		    asset_code,
		    asset_name,
		    fisical_status,
		    asset_status,
		    purchase_price,
		    net_book,
		    purchase_date,
		    rv,
		    date,
		    depreciation_amount,
		    net_book_value,
		    depreciation_date,
		    is_depreciation,
		    last_depreciation,
		    total_depreciation,
		    reff_no,
		    is_condition
		)
		values
		(   @p_user_id,
		    @report_company,
		    @report_title,
		    @report_image,
		    @p_branch_code,
		    @p_branch_name,
		    @p_asset_code,
		    @p_item_name,
		    NULL,
		    NULL,
		    NULL,
		    NULL,
		    NULL,
		    NULL,
		    NULL,
		    NULL,
		    NULL,
		    NULL,
		    NULL,
		    NULL,
		    NULL,
		    NULL, 
		    @p_is_condition
		    )
		end

		END TRY
	BEGIN CATCH
		DECLARE @error INT ;

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

