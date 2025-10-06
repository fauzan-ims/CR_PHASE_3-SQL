--Created, Aliv at 29-05-2023
CREATE PROCEDURE [dbo].[xsp_rpt_pa_with_amortization]
(
	@p_user_id			nvarchar(50) = ''
	,@p_branch_code		nvarchar(50) = ''
	,@p_as_of_date		datetime	 = null
	,@p_type			int = NULL
    ,@p_is_condition	nvarchar(1)
)
as
BEGIN

	delete dbo.rpt_pa_with_amortization
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@branch_code					nvarchar(50)	
			,@branch_name					nvarchar(50)	
			,@prepaid_no					nvarchar(50)	
			,@prepaid_acc					nvarchar(50)	
			,@expense_acc					nvarchar(50)
			,@description					nvarchar(100)	
			,@amortiz_balance				decimal(18, 2)	
			,@amortiz_value					decimal(18, 2)	
			,@prepaid_amount				decimal(18, 2)	
			,@p_type_name					nvarchar(50)	= 'Prepaid Active With Amortization Balance'

	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'Report Asset Activity';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			insert into rpt_pa_with_amortization
			(
				user_id
				,report_company
				,report_title
				,report_image
				,as_of_date
				,type
				,branch_code		
				,branch_name		
				,prepaid_no	
				,prepaid_type
				,description		
				,amortiz_balance	
				,amortiz_value		
				,prepaid_amount	
				,is_condition
			)
			select	@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_as_of_date
					,@p_type_name
					,ast.branch_code
					,ast.branch_name
					,apm.prepaid_no
					,case
						when apm.prepaid_type = 'INSURANCE' then 'Insurance'
						when apm.prepaid_type = 'REGISTER' then 'Register'
						else ''
					end
					,ast.item_name
					,apm.total_prepaid_amount - apm.total_accrue_amount
					,apm.total_accrue_amount
					,apm.total_prepaid_amount
					,@p_is_condition
			from	ifinams.dbo.asset_prepaid_main apm
					inner join ifinams.dbo.asset ast on ast.code = apm.fa_code
			where	ast.purchase_date <= @p_as_of_date ;

			if not exists (select * from dbo.rpt_pa_with_amortization where user_id = @p_user_id)
			begin
					insert into dbo.rpt_pa_with_amortization
					(
					    user_id
					    ,report_company
					    ,report_title
					    ,report_image
					    ,as_of_date
					    ,type
					    ,branch_code
					    ,branch_name
					    ,prepaid_no
					    ,prepaid_acc
					    ,expense_acc
					    ,description
					    ,amortiz_balance
					    ,amortiz_value
					    ,prepaid_amount
					    ,is_condition
					)
					values
					(   
						@p_user_id
					    ,@report_company
					    ,@report_title
					    ,@report_image
					    ,@p_as_of_date
					    ,@p_type
					    ,@p_branch_code
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,null
					    ,@p_is_condition
					)
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

