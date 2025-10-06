--created by, raffyanda 30/10/2023
CREATE PROCEDURE dbo.xsp_rpt_asset_prepaid
(
	@p_user_id			NVARCHAR(50)
	,@p_asset_code		NVARCHAR(50)
	,@p_branch_code		nvarchar(50) 
	,@p_branch_name		nvarchar(50) 
	,@p_item_name		nvarchar(50)
	,@p_is_condition	NVARCHAR(2)
)
AS
BEGIN

	DELETE dbo.rpt_asset_prepaid
	WHERE user_id = @p_user_id;

	declare @msg					nvarchar(max)
			,@report_company		nvarchar(200)
			,@report_image			nvarchar(200)
			,@report_title			nvarchar(200)
			,@os_prepaid			decimal(18,2)
			,@prepaid_amount		decimal(18,2)
			,@total_prepaid_amount	decimal(18,2)
			,@total					DECIMAL(18,2)
			,@count					int
			,@prepaid_no			nvarchar(50)
			,@index					int;

	begin try 
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set	@report_title = 'REPORT ASSET PREPAID';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;


		insert into dbo.rpt_asset_prepaid
		(
		    user_id,
		    report_company,
		    report_title,
		    report_image,
		    asset_code,
		    asset_name,
			branch_name,
			branch_code,
		    asset_status,
		    fisical_status,
		    purchase_price,
		    purchase_date,
			prepaid_no,
		    prepaid_type,
		    prepaid_date,
			prepaid_date_sch,
		    prepaid_remark,
			total_prepaid_amount,
		    prepaid_amount,
		    total_acrue,
		    outstanding,
		    os_prepaid,
		    acrue_date,
		    reff_no,
			plat_no
		)
		SELECT @p_user_id
		,@report_company
		,@report_title
		,@report_image
		,@p_asset_code
		,a.item_name
		,@p_branch_name
		,@p_branch_code
		,a.status
		,a.fisical_status
		,a.purchase_price
		,a.purchase_date
		,am.prepaid_no
		,am.prepaid_type
		,am.prepaid_date
		,aps.prepaid_date
		,'-'--am.prepaid_remark
		,am.total_prepaid_amount
		,aps.prepaid_amount
		,am.total_accrue_amount
		,am.total_prepaid_amount - am.total_accrue_amount
		,0
		,aps.accrue_date
		,aps.accrue_reff_code
		,av.plat_no
		from asset a
		left join dbo.asset_vehicle av on (av.asset_code = a.code)
		left join dbo.asset_prepaid_main am on am.fa_code = a.code
		left join dbo.asset_prepaid_schedule aps on aps.prepaid_no = am.prepaid_no
		where a.code = @p_asset_code

		 if not exists (select * from dbo.rpt_asset_prepaid where user_id = @p_user_id)
		 begin 
		 insert into dbo.rpt_asset_prepaid
		 (
		     user_id,
		     report_company,
		     report_title,
		     report_image,
		     asset_code,
		     asset_name,
		     asset_status,
		     fisical_status,
		     purchase_price,
		     purchase_date,
		     prepaid_no,
		     prepaid_type,
		     prepaid_date_sch,
		     prepaid_date,
		     prepaid_remark,
		     total_prepaid_amount,
		     prepaid_amount,
		     total_acrue,
		     outstanding,
		     os_prepaid,
		     acrue_date,
		     reff_no,
		     branch_name,
		     branch_code,
		     is_condition
		 )
		 values
		 (
			@p_user_id
		    ,@report_company 
		    ,@report_title 
		    ,@report_image 
		    ,@p_asset_code 
		    ,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
			,NULL 
		    ,@p_branch_name 
		    ,@p_branch_code 
			,NULL 
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

