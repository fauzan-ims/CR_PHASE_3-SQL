--created by, Raffyanda 31/10/2023
CREATE PROCEDURE dbo.xsp_rpt_ammortize_prepaid_fixed_asset
(
	@p_user_id			NVARCHAR(50)
	,@p_branch_code		NVARCHAR(50) 
	,@p_branch_name		NVARCHAR(50)
	,@p_month			NVARCHAR(20)
	,@p_year			NVARCHAR(4) 
	,@p_is_condition	NVARCHAR(2)
)
AS
BEGIN

	DELETE dbo.rpt_ammortize_prepaid_fixed_asset
	WHERE user_id = @p_user_id;

	DECLARE @msg				NVARCHAR(MAX)
			,@report_company	NVARCHAR(200)
			,@report_image		NVARCHAR(200)
			,@report_title		NVARCHAR(200);

	BEGIN TRY 
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set	@report_title = 'REPORT AMORTIZE PREPAID FIXED ASSET';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		insert into dbo.rpt_ammortize_prepaid_fixed_asset
		(
		    user_id,
		    report_title,
		    report_image,
		    report_company,
		    branch_code,
		    branch_name,
		    asset_code,
		    asset_name,
		    purchase_date,
		    purchase_price,
		    status,
		    fisical_status,
		    agreement_no,
		    client_name,
		    prepaid_no,
		    prepaid_date,
		    total_prepaid_amount,
		    accrue_date,
		    prepaid_amount,
		    total_accrue_amount,
		    outstanding_amount,
		    is_condition,
			month,
			year,
			plat_no
		)
		select 
		@p_user_id
		,@report_title
		,@report_image
		,@report_company
		,a.branch_code
		,a.branch_name
		,code
		,item_name
		,purchase_date
		,purchase_price
		,status
		,fisical_status
		,agreement_external_no
		,client_name
		,am.prepaid_no
		,am.prepaid_date
		,total_prepaid_amount
		,aps.accrue_date
		,aps.prepaid_amount 'ACCRUE AMOUNT'
		,total_accrue_amount
		,0
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
		,substring(av.plat_no,0,10)
		from		asset_prepaid_schedule aps
		left join	dbo.asset_prepaid_main am on aps.prepaid_no = am.prepaid_no
		left join	dbo.asset a on  am.fa_code = a.code
		left join	dbo.asset_vehicle av ON (av.asset_code = a.code)
		where		@p_month = month(aps.accrue_date) and year(aps.accrue_date) = @p_year 
		AND 		a.branch_code = case @p_branch_code
									when 'ALL' then a.branch_code
									else @p_branch_code
								end
        
		if not exists (select * from dbo.rpt_ammortize_prepaid_fixed_asset where user_id = @p_user_id)
		begin 
		insert into dbo.rpt_ammortize_prepaid_fixed_asset
		(
		    user_id,
		    report_title,
		    report_company,
		    report_image,
		    branch_code,
		    branch_name,
		    asset_code,
		    asset_name,
		    purchase_price,
		    purchase_date,
		    status,
		    fisical_status,
		    agreement_no,
		    client_name,
		    prepaid_no,
		    prepaid_date,
		    total_prepaid_amount,
		    accrue_date,
		    prepaid_amount,
		    total_accrue_amount,
		    outstanding_amount,
		    is_condition,
		    month,
		    year
		)
		values
		(   @p_user_id,			
		    @report_title,		
		    @report_company,	
		    @report_image,		
		    @p_branch_code, 
		    @p_branch_name, 
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
		    NULL, 
		    @p_is_condition,	
		    case	when @p_month = '1' then 'JANUARI'
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
			end,			
		    @p_year				
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

