
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_adjustment_insert]
(
	@p_code							nvarchar(50) output
	,@p_company_code				nvarchar(50)
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_date						datetime
	,@p_new_purchase_date			datetime
	,@p_asset_code					nvarchar(50)
	,@p_old_netbook_value_fiscal	decimal(18, 2)
	,@p_old_netbook_value_comm		decimal(18, 2)
	,@p_new_netbook_value_fiscal	decimal(18, 2)
	,@p_new_netbook_value_comm		decimal(18, 2)
	,@p_total_adjustment			decimal(18, 2)
	,@p_payment_by					nvarchar(10)
	,@p_vendor_code					nvarchar(50) = ''
	,@p_vendor_name					nvarchar(250) = ''
	,@p_remark						nvarchar(4000)
	,@p_status						nvarchar(25)
	,@p_adjust_type					nvarchar(15) = 'REVAL'
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
	,@p_is_from_proc				 nvarchar(1) = '0' -- cr priority sepria: 28082025. jika dari proc = 1, else 0
)
as
begin
	declare @msg				nvarchar(max) 
			,@year				nvarchar(4) 
			,@month				nvarchar(2)
			,@code				nvarchar(50)
			,@purchase_price	decimal(18,2)
			,@old_total_depre	decimal(18,2)
			,@depre_date		datetime

	begin try

	select	@depre_date = max(depreciation_date)
	from	dbo.asset_depreciation_schedule_commercial
	where	asset_code			 = @p_asset_code
	and transaction_code <> '' ;

	--validasi jika kita input adjust date kurang dari tanggal terakhir di depretiation
	--if(month(@p_new_purchase_date) < month(@depre_date))
	--begin
	--	set @msg = 'Adjustment date must be greater than last depretiation date ' + convert(varchar(10),@depre_date, 103) + ' .';
	--	raiserror(@msg ,16,-1);	   
	--end

	--validasi jika pada bulan itu belom dilakukan depre maka asset tidak bisa di adjust
	--if exists(select 1 from dbo.asset_depreciation_schedule_commercial
	--where asset_code = @p_asset_code
	--and month(depreciation_date) = month(@p_new_purchase_date) 
	--and year(depreciation_date) = year(@p_new_purchase_date)
	--and isnull(transaction_code,'') = '')
	--begin
	--	set @msg = 'Please depre first.' ;
	--	raiserror(@msg, 16, -1) ;
	--end

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @p_code output
												,@p_branch_code			 = @p_branch_code
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'ADJ'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'ADJUSTMENT'
												,@p_run_number_length	 = 5
												,@p_delimiter			= '.'
												,@p_run_number_only		 = '0' ;


	select	@purchase_price		= purchase_price
			,@old_total_depre	= total_depre_comm
	from	dbo.asset
	where	code = @p_asset_code

	insert into adjustment
	(
		code
		,company_code
		,branch_code
		,branch_name
		,date
		,adjustment_type
		,new_purchase_date
		,asset_code
		,old_netbook_value_fiscal
		,old_netbook_value_comm
		,new_netbook_value_fiscal
		,new_netbook_value_comm
		,total_adjustment
		,payment_by
		,vendor_code
		,vendor_name
		,remark
		,status
		,old_total_depre_comm
		,purchase_price
		,adjust_type
		--
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
		,is_from_proc
	)
	values
	(
		@p_code
		,@p_company_code
		,@p_branch_code
		,@p_branch_name
		,dbo.xfn_get_system_date()
		,'REVAL'
		,@p_new_purchase_date
		,@p_asset_code
		,@p_old_netbook_value_fiscal
		,@p_old_netbook_value_comm
		,@p_new_netbook_value_fiscal
		,@p_new_netbook_value_comm
		,@p_total_adjustment
		,@p_payment_by
		,@p_vendor_code
		,@p_vendor_name
		,@p_remark
		,@p_status
		,@old_total_depre
		,@purchase_price
		,@p_adjust_type
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
		,@p_is_from_proc
	)

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
end
