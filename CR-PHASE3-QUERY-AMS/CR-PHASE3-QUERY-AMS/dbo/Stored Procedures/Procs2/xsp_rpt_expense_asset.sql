--Created, Aliv at 29-05-2023
CREATE PROCEDURE [dbo].[xsp_rpt_expense_asset]
(
	@p_user_id			nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(50)
	,@p_as_of_date		datetime	
	,@p_is_condition	nvarchar(1)
)
as
begin
	delete	dbo.rpt_expense_asset
	where	user_id = @p_user_id ;

	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_title	 nvarchar(250)
			,@report_image	 nvarchar(250)
			,@asset_no		 nvarchar(50)
			,@merk			 nvarchar(50)
			,@model			 nvarchar(50)
			,@type			 nvarchar(50)
			,@plat_no		 nvarchar(50)
			,@chassis_no	 nvarchar(50)
			,@engine_no		 nvarchar(50)
			,@purchase_price decimal(18, 2)
			,@expense		 decimal(18, 2)
			,@revenue		 decimal(18, 2)
			,@rv			 decimal(18,2)
			,@net_income	 decimal(18, 2)
			,@branch_name	 nvarchar(50) ;

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = N'Report Expense Asset' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		begin
			insert into dbo.RPT_EXPENSE_ASSET
			(
				USER_ID
				,REPORT_COMPANY
				,REPORT_TITLE
				,REPORT_IMAGE
				,BRANCH_CODE
				,BRANCH_NAME
				,AS_OF_DATE
				,ASSET_NO
				,MERK
				,MODEL
				,TYPE
				,PLAT_NO
				,CHASSIS_NO
				,ENGINE_NO
				,PURCHASE_PRICE
				,EXPENSE
				,REVENUE
				,RV
				,NET_INCOME
				,IS_CONDITION
			)
			select	distinct @p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_branch_code
					,@p_branch_name
					,@p_as_of_date
					,a.code
					,a.merk_name
					,a.model_name
					,a.type_name_asset
					,isnull(av.plat_no, '')
					,isnull(av.chassis_no, '')
					,isnull(av.engine_no, '')
					,isnull(a.purchase_price, 0)
					,isnull(ael.expense_amount, 0) + a.total_depre_comm
					,isnull(ail.income_amount, 0)
					,isnull(a.residual_value, 0)
					,(isnull(a.purchase_price, 0) + isnull(a.residual_value, 0)+ isnull(ail.income_amount, 0)) - (isnull(ael.expense_amount, 0) + isnull(a.total_depre_comm,0)) 
					,@p_is_condition
			from	ifinams.dbo.asset a
					outer apply
			(
				select	sum(asset_rv_amount) 'asset_rv_amount'
				from	ifinopl.dbo.agreement_asset
				where	agreement_no = a.agreement_no
			)						  aa
					outer apply
			(
				select	sum(expense_amount) 'expense_amount'
				from	ifinams.dbo.asset_expense_ledger
				where	asset_code = a.code
			) ael
					outer apply
			(
				select	sum(income_amount)'income_amount'
				from	ifinams.dbo.asset_income_ledger
				where	asset_code = a.code
			) ail
					outer apply
			(
				select	plat_no
						,chassis_no
						,engine_no
				from	ifinams.dbo.asset_vehicle
				where	asset_code = a.code
			) av
			where	cast(a.purchase_date as date) <= cast(@p_as_of_date as date)
					and a.branch_code			  = case @p_branch_code
														when 'ALL' then a.branch_code
														else @p_branch_code
													end
					and	a.status in ('STOCK', 'REPLACEMENT')
					and	a.asset_from = 'BUY';
			--declare curr_expense_asset cursor fast_forward read_only for
			

			--open curr_expense_asset ;

			--fetch next from curr_expense_asset
			--into @asset_no
			--	 ,@merk
			--	 ,@model
			--	 ,@type
			--	 ,@plat_no
			--	 ,@chassis_no
			--	 ,@engine_no
			--	 ,@purchase_price
			--	 ,@expense
			--	 ,@revenue
			--	 ,@rv
			--	 ,@net_income
			--	 ,@branch_name ;

			--while @@fetch_status = 0
			--begin
			--	insert into rpt_expense_asset
			--	(
			--		user_id
			--		,report_company
			--		,report_title
			--		,report_image
			--		,branch_code
			--		,branch_name
			--		,as_of_date
			--		,asset_no
			--		,merk
			--		,model
			--		,type
			--		,plat_no
			--		,chassis_no
			--		,engine_no
			--		,purchase_price
			--		,expense
			--		,revenue
			--		,rv
			--		,net_income
			--		,is_condition
			--	)
			--	values
			--	(
			--		@p_user_id
			--		,@report_company
			--		,@report_title
			--		,@report_image
			--		,@p_branch_code
			--		,@p_branch_name
			--		,@p_as_of_date
			--		,@asset_no
			--		,@merk
			--		,@model
			--		,@type
			--		,@plat_no
			--		,@chassis_no
			--		,@engine_no
			--		,@purchase_price
			--		,@expense
			--		,@revenue
			--		,@rv
			--		,@net_income
			--		,@p_is_condition
			--	) ;

			--	fetch next from curr_expense_asset
			--	into @asset_no
			--		 ,@merk
			--		 ,@model
			--		 ,@type
			--		 ,@plat_no
			--		 ,@chassis_no
			--		 ,@engine_no
			--		 ,@purchase_price
			--		 ,@expense
			--		 ,@revenue
			--		 ,@rv
			--		 ,@net_income
			--		 ,@branch_name ;
			--end ;

			--close curr_expense_asset ;
			--deallocate curr_expense_asset ;
		end ;

		if not exists
		(
			select	*
			from	rpt_expense_asset
			where	user_id = @p_user_id
		)
		begin
			insert into rpt_expense_asset
			(
				user_id
				,report_company
				,report_title
				,report_image
				,branch_code
				,branch_name
				,as_of_date
				,asset_no
				,merk
				,model
				,type
				,plat_no
				,chassis_no
				,engine_no
				,purchase_price
				,expense
				,revenue
				,rv
				,net_income
				,is_condition
			)
			values
			(
				@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@p_branch_code
				,@p_branch_name
				,''
				,''
				,''
				,''
				,''
				,''
				,''
				,''
				,0
				,0
				,0
				,0
				,0
				,@p_is_condition
			) ;
		end ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
