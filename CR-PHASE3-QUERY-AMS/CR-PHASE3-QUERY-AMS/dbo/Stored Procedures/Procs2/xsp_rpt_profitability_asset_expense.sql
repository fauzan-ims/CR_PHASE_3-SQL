--Created, Aliv at 29-05-2023
CREATE PROCEDURE  dbo.xsp_rpt_profitability_asset_expense
(
	@p_code				nvarchar(50)
	,@p_user_id			nvarchar(50)
)
as
BEGIN

	--delete dbo.rpt_profitability_asset
	--where	user_id = @p_user_id ;

	declare @msg							nvarchar(max)
			,@kontrak_expense				int
			,@description_expense			nvarchar(100)
			,@budget_expense				decimal(18,2)
			,@actual_expense				decimal(18,2)
			,@conter						INT = 1
			,@contract						NVARCHAR(50)


	begin TRY
		
		declare expensecursor cursor for
		
		select  @conter
				,ael.reff_remark
				,ael.expense_amount
		from asset_expense_ledger ael
		WHERE ael.ASSET_CODE = @p_code
		set @conter  = @conter  + 1
		
		--buka cursor
		open expensecursor
		fetch next from expensecursor
		INTO @contract
			,@description_expense
			,@budget_expense

		while @@fetch_status=0
		BEGIN
        SET @contract =  'Contract ' + convert(varchar,@conter)
		insert into rpt_profitability_asset_expense
		(
			KONTRAK_EXPENSE
			,DESCRIPTION_EXPENSE
			,BUDGET_EXPENSE
		)
		values
		(
			@contract
			,@description_expense
			,@budget_expense
		)
        
		fetch next from expensecursor
		into @contract
			,@description_expense
			,@budget_expense
		end

		--ttup kursor
		close expensecursor
		deallocate expensecursor

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

