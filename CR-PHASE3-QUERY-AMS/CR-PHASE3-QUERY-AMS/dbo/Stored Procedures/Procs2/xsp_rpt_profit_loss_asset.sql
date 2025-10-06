--Created, Aliv at 29-05-2023
CREATE PROCEDURE [dbo].[xsp_rpt_profit_loss_asset]
(
	@p_user_id			nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(50)
	,@p_as_of_date		datetime	
	,@p_is_condition	nvarchar(1) --(+) Untuk Kondisi Excel Data Only
)
as
begin
	delete	dbo.rpt_profit_loss_asset
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
			,@rv			 decimal(18, 2)
			,@sell_price	 decimal(18, 2)
			,@gain_loss		 decimal(18, 2)
			,@branch_name	 nvarchar(50) ;

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = N'Report Profit Loss Asset' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		begin
			declare curr_expense_asset cursor fast_forward read_only for

			select	ass.code
					,asv.merk_name
					,asv.model_name
					,asv.type_item_name
					,asv.plat_no
					,asv.chassis_no
					,asv.engine_no
					,ass.purchase_price
					,sld.total_expense
					,sld.total_income
					,ass.residual_value
					,sld.sold_amount
					,sld.gain_loss_profit
					,sl.branch_name
			from	ifinams.dbo.sale sl
					inner join ifinams.dbo.sale_detail sld on (sld.sale_code	= sl.code)
					inner join ifinams.dbo.asset ass on (ass.code				= sld.asset_code)
					inner join ifinams.dbo.asset_vehicle asv on (asv.asset_code = ass.code) 
			where	ass.status = 'SOLD'
			and		sl.branch_code			  = case @p_branch_code
														when 'ALL' then sl.branch_code
														else @p_branch_code
													end
			and		cast(sl.sale_date as date) <= cast(@p_as_of_date as date)

			open curr_expense_asset ;

			fetch next from curr_expense_asset
			into @asset_no
				 ,@merk
				 ,@model
				 ,@type
				 ,@plat_no
				 ,@chassis_no
				 ,@engine_no
				 ,@purchase_price
				 ,@expense
				 ,@revenue
				 ,@rv
				 ,@sell_price
				 ,@gain_loss
				 ,@branch_name 

			while @@fetch_status = 0
			begin
				insert into rpt_profit_loss_asset
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
					,sell_price
					,gain_loss
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
					,@p_as_of_date
					,@asset_no
					,@merk
					,@model
					,@type
					,@plat_no
					,@chassis_no
					,@engine_no
					,@purchase_price
					,@expense
					,@revenue
					,@rv
					,@sell_price
					,@gain_loss
					,@p_is_condition
				) ;

				fetch next from curr_expense_asset
				into @asset_no
					 ,@merk
					 ,@model
					 ,@type
					 ,@plat_no
					 ,@chassis_no
					 ,@engine_no
					 ,@purchase_price
					 ,@expense
					 ,@revenue
					 ,@rv
					 ,@sell_price
					 ,@gain_loss
					 ,@branch_name ;
			end ;

			close curr_expense_asset ;
			deallocate curr_expense_asset ;
		end ;

		if not exists
		(
			select	*
			from	dbo.rpt_profit_loss_asset
			where	user_id = @p_user_id
		)
		begin
			insert into rpt_profit_loss_asset
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
				,sell_price
				,gain_loss
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
				,null
				,null
				,null
				,null
				,null
				,null
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
