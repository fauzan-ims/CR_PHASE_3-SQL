CREATE PROCEDURE dbo.xsp_asset_get_difference_depre_amount
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	declare	@previous_depre			decimal(18, 2)
			,@max_depreciation_date	datetime
			,@new_depre				decimal(18, 2)
			,@msg					nvarchar(max)
	begin try
			
	/*
		var 1 = purchase price - netbook value
		var 2 = dari asset depre schedule, ambil max depre date yang trx code <> '', sum(depre amount) where depre date <= tanggal yang diselect 
		var 3 = var 1- var 2
	*/


	select	@max_depreciation_date = max(depreciation_date) 
			,@previous_depre = sum(depreciation_amount)
	from	dbo.asset_depreciation_schedule_commercial 
	where	asset_code = @p_asset_no 
	and		transaction_code <> '';

	select	@new_depre = sum(isnull(depreciation_amount, 0))
	from	dbo.asset_depreciation_schedule_commercial 
	where	asset_code = @p_asset_no 
	and		transaction_code = ''
	and		cast(depreciation_date as date) <= cast(@max_depreciation_date as date) ;

	select @previous_depre - @new_depre ;

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


end ;
