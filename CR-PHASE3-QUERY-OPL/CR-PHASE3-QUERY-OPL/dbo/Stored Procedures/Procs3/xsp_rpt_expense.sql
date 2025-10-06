--created by, Bilal at 04/07/2023 

CREATE PROCEDURE [dbo].[xsp_rpt_expense]
(
	@p_user_id				NVARCHAR(MAX)
	,@p_asset_no			NVARCHAR(50)
	--
	,@p_cre_date			DATETIME
	,@p_cre_by				NVARCHAR(15)
	,@p_cre_ip_address		NVARCHAR(15)
	,@p_mod_date			DATETIME
	,@p_mod_by				NVARCHAR(15)
	,@p_mod_ip_address		NVARCHAR(15)
)
as
begin

	delete dbo.rpt_expense
	where user_id = @p_user_id 

	declare	@msg						nvarchar(max)
			,@report_company			nvarchar(250)
			,@report_image				nvarchar(250)
			,@report_title				nvarchar(250)
			,@as_of_date				datetime
			,@asset_no					nvarchar(50)
		    ,@merk						nvarchar(50)
		    ,@model						nvarchar(50)
		    ,@type						nvarchar(50)
		    ,@plat_no					nvarchar(50)
		    ,@chassis_no				nvarchar(50)
		    ,@engine_no					nvarchar(50)
		    ,@purchase_price			decimal(18, 2)
		    ,@expense					decimal(18, 2)
		    ,@revenue					decimal(18, 2)
		    ,@rv_amount					decimal(18, 2)
		    ,@net_income				decimal(18, 2)

	begin try

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set	@report_title = 'Report Expense Asset'

		insert into dbo.rpt_expense
		(
		    user_id
		    ,filter_as_of_date
		    ,report_company
		    ,report_title
		    ,report_image
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
		    ,rv_amount
		    ,net_income
			--
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		select	@p_user_id
				,dbo.xfn_get_system_date()
				,@report_company
				,@report_title 
				,@report_image 
				,@p_asset_no
				,av.merk_name
				,av.model_name
				,av.type_item_name
				,isnull(av.plat_no, '')
				,isnull(av.chassis_no, '')
				,isnull(av.engine_no, '')
				,isnull(a.purchase_price, 0)
				,isnull(ael.expense_amount, 0)
				,isnull(ail.income_amount, 0)
				,isnull(aa.asset_rv_amount, 0)
				--,(isnull(a.purchase_price, 0) + isnull(aa.asset_rv_amount, 0)) - (isnull(ael.expense_amount, 0) + isnull(ail.income_amount, 0))
				,(isnull(a.purchase_price, 0) - isnull(ael.expense_amount, 0)) + isnull(ail.income_amount, 0)
				--
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
				,@p_mod_date		
				,@p_mod_by			
				,@p_mod_ip_address
		from	ifinams.dbo.asset a
				inner join ifinams.dbo.asset_vehicle av on (av.asset_code = a.code)
				outer apply
					(
						select	asset_rv_amount
						from	dbo.agreement_asset
						where	agreement_no = a.agreement_no
					)						  aa
				outer apply
					(
						select	expense_amount
						from	ifinams.dbo.asset_expense_ledger
						where	asset_code = a.code
					) ael
				outer apply
					(
						select	income_amount
						from	ifinams.dbo.asset_income_ledger
						where	asset_code = a.code
					) ail
					--
			--	outer apply
				--(
				--	select	plat_no
				--			,chassis_no
				--			,engine_no
				--	from	ifinams.dbo.asset_vehicle
				--	where	asset_code = a.code
				--) av
		where	a.asset_no = @p_asset_no
					
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
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
END
