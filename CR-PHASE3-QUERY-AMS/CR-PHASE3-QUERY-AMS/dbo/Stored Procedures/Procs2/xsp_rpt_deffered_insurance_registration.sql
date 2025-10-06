--Created, Jeff at 09-08-2023
CREATE PROCEDURE [dbo].[xsp_rpt_deffered_insurance_registration]
(
	@p_user_id			nvarchar(50) = ''
	,@p_type			nvarchar(50)
	,@p_as_of_date		datetime
    ,@p_is_condition    nvarchar(1)
)
as
BEGIN

	delete dbo.RPT_DEFFERED_INSURANCE_REGISTRATION
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@type_code						nvarchar(50)

	begin try
	
		SELECT	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		if @p_type = 'INSURANCE'
		set	@report_title = 'Report Deffered Insurance';
		else
		set	@report_title = 'Report Deffered Registration';

	BEGIN
		insert into dbo.rpt_deffered_insurance_registration
		(
			user_id
			,report_title
			,report_company
			,report_image
			,month
			,year
			,asset_code
			,asset_name
			,prepaid_date
			,prepaid_type
			,prepaid_amount
			,period
			,accrue_amount
			,accrue_date
		)
		select	distinct
				@p_user_id
				,@report_title
				,@report_company
				,@report_image
				,case month(@p_as_of_date)
					 when '1' then 'Januari'
					 when '2' then 'Februari'
					 when '3' then 'Maret'
					 when '4' then 'April'
					 when '5' then 'Mei'
					 when '6' then 'Juni'
					 when '7' then 'Juli'
					 when '8' then 'Agustus'
					 when '9' then 'September'
					 when '10' then 'Oktober'
					 when '11' then 'November'
					 when '12' then 'Desember'
				 end
				,year(@p_as_of_date)
				,apm.fa_code
				,ast.item_name
				,case 
				when len(cast(month(aps.PREPAID_DATE) as nvarchar(50)))='1' then '0'+cast(month(aps.PREPAID_DATE) as nvarchar(50))
				else cast(month(aps.PREPAID_DATE) as nvarchar(50))
				end+'/'+cast(year(aps.PREPAID_DATE) as nvarchar(50))
				,apm.prepaid_type
				,apm.total_prepaid_amount
				,null
				,apm.total_accrue_amount
				,aps.accrue_date
		from	ifinams.dbo.asset_prepaid_main apm
				inner join dbo.asset_prepaid_schedule aps on aps.prepaid_no = apm.prepaid_no
				left join ifinams.dbo.asset ast on ast.code					= apm.fa_code
		where	apm.prepaid_date	 <= @p_as_of_date
				and apm.prepaid_type  = @p_type ;
	
		if not exists (select 1 from dbo.RPT_DEFFERED_INSURANCE_REGISTRATION)
		begin
			insert into dbo.RPT_DEFFERED_INSURANCE_REGISTRATION
			(
				USER_ID
				,REPORT_TITLE
				,REPORT_COMPANY
				,REPORT_IMAGE
				,MONTH
				,YEAR
				,ASSET_CODE
				,ASSET_NAME
				,PREPAID_DATE
				,PREPAID_TYPE
				,PREPAID_AMOUNT
				,PERIOD
				,ACCRUE_AMOUNT
				,ACCRUE_DATE
			)
			values
			(
				@p_user_id
				,@report_title
				,@report_company
				,@report_image
				,case month(@p_as_of_date)
					 when '1' then 'Januari'
					 when '2' then 'Februari'
					 when '3' then 'Maret'
					 when '4' then 'April'
					 when '5' then 'Mei'
					 when '6' then 'Juni'
					 when '7' then 'Juli'
					 when '8' then 'Agustus'
					 when '9' then 'September'
					 when '10' then 'Oktober'
					 when '11' then 'November'
					 when '12' then 'Desember'
				 end
				,year(@p_as_of_date)
				,'-' -- ASSET_CODE - nvarchar(50)
				,'-' -- ASSET_NAME - nvarchar(250)
				,null -- PREPAID_DATE - nvarchar(50)
				,'-' -- PREPAID_TYPE - nvarchar(50)
				,0 -- PREPAID_AMOUNT - decimal(18, 2)
				,'-' -- PERIOD - nvarchar(250)
				,0 -- ACCRUE_AMOUNT - decimal(18, 2)
				,null -- ACCRUE_DATE - datetime
			) ;
		end
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

