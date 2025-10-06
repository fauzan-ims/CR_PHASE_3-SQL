--created by Raffyanda 31/10/2023
CREATE PROCEDURE dbo.xsp_rpt_depreciation_fixed_asset
(
	@p_user_id			NVARCHAR(50)
	,@p_branch_code		NVARCHAR(50) 
	,@p_branch_name		NVARCHAR(50)
	,@p_month			NVARCHAR(20)
	,@p_year			nvarchar(4) 
	,@p_is_condition	nvarchar(2)
)
AS
BEGIN

	delete dbo.rpt_depreciation_fixed_asset
	where user_id = @p_user_id;

	DECLARE @msg				NVARCHAR(max)
			,@report_company	NVARCHAR(200)
			,@report_image		NVARCHAR(200)
			,@report_title		NVARCHAR(200);

	BEGIN TRY 
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set	@report_title = 'REPORT DEPRECIATION FIXED ASSET';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;


		insert into dbo.rpt_depreciation_fixed_asset
		(
		    user_id,
		    report_title,
		    report_image,
		    report_company,
		    branch_code,
		    branch_name,
		    asset_code,
		    asset_name,
		    merek,
		    model,
		    type,
		    agreement_no,
		    client_name,
		    purchase_date,
		    purchase_price,
		    net_book_value,
		    residual_value,
		    total_depre,
		    depre_this_month,
		    total_accum,
			is_condition,
			month,
			year,
			PLAT_NO
		)
		select 
		@p_user_id
		,@report_title
		,@report_image
		,@report_company
		,a.branch_code
		,a.branch_name
		,a.code
		,a.item_name
		,a.merk_name
		,a.model_name
		,a.type_name_asset
		,a.agreement_external_no
		,a.client_name
		,a.purchase_date
		,a.purchase_price
		,a.net_book_value_comm
		,a.residual_value
		,a.total_depre_comm
		,ac.depreciation_amount
		,ac.accum_depre_amount
		,@p_is_condition
		,case	when @p_month = '1' then 'JANUARI'
				when @p_month = '2' then 'FEBRUARI'
				when @p_month = '3' then 'MARET'
				when @p_month = '4' then 'APRIL'
				when @p_month = '5' then 'MEI'
				when @p_month = '6' then 'JUNI'
				when @p_month = '7' then 'JULI'
				when @p_month = '8' then 'AGUSTUS'
				when @p_month = '9' then 'SEPTEMBER'
				when @p_month = '10' then 'OKTOBER'
				when @p_month = '11' then 'NOVEMBER'
				when @p_month = '12' then 'DESEMBER'
				else @p_month
		end
		,@p_year
		,av.plat_no
		from	dbo.asset a
		left join dbo.asset_depreciation_schedule_commercial ac on (ac.asset_code = a.code)
		left join dbo.asset_vehicle av on (av.asset_code = a.code)
		where	@p_month = month(ac.depreciation_date) and year(ac.depreciation_date) = @p_year 
		and		a.branch_code = case @p_branch_code
									when 'ALL' then a.branch_code
									else @p_branch_code
								end
        
        
		if not exists (select * from dbo.rpt_depreciation_fixed_asset where user_id = @p_user_id)
		begin
        insert into dbo.rpt_depreciation_fixed_asset
        (
            user_id,
            report_title,
            report_image,
            report_company,
            branch_code,
            branch_name,
            asset_code,
            asset_name,
            merek,
            model,
            type,
            agreement_no,
            client_name,
            purchase_date,
            purchase_price,
            net_book_value,
            residual_value,
            total_depre,
            depre_this_month,
            total_accum,
            is_condition,
            month,
            year
        )
        values
        (   @p_user_id, -- USER_ID - nvarchar(50)
            @report_title, -- REPORT_TITLE - nvarchar(50)
            @report_image, -- REPORT_IMAGE - nvarchar(50)
            @report_company, -- REPORT_COMPANY - nvarchar(50)
            NULL, -- BRANCH_CODE - nvarchar(50)
            NULL, -- BRANCH_NAME - nvarchar(50)
            NULL, -- ASSET_CODE - nvarchar(50)
            NULL, -- ASSET_NAME - nvarchar(200)
            NULL, -- MEREK - nvarchar(50)
            NULL, -- MODEL - nvarchar(50)
            NULL, -- TYPE - nvarchar(50)
            NULL, -- AGREEMENT_NO - nvarchar(50)
            NULL, -- CLIENT_NAME - nvarchar(200)
            NULL, -- PURCHASE_DATE - datetime
            NULL, -- PURCHASE_PRICE - decimal(18, 2)
            NULL, -- NET_BOOK_VALUE - decimal(18, 2)
            NULL, -- RESIDUAL_VALUE - decimal(18, 2)
            NULL, -- TOTAL_DEPRE - decimal(18, 2)
            NULL, -- DEPRE_THIS_MONTH - decimal(18, 2)
            NULL, -- TOTAL_ACCUM - decimal(18, 2)
            @p_is_condition, -- IS_CONDITION - nvarchar(3)
            @p_month, -- MONTH - nvarchar(20)
            @p_year  -- YEAR - nvarchar(4)
            )
		end
		end TRY
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

