CREATE PROCEDURE dbo.xsp_application_insurance_insert
(
	@p_id							  bigint		= 0 output
	,@p_application_no				  nvarchar(50)
	,@p_coverage_code				  nvarchar(50)
	,@p_coverage_name				  nvarchar(250)
	,@p_insurance_code				  nvarchar(50)
	,@p_insurance_name				  nvarchar(250)
	,@p_tenor						  int
	,@p_eff_date					  datetime		= null
	,@p_exp_date					  datetime		= null
	,@p_sum_insured_amount			  decimal(18, 2)
	,@p_initial_buy_rate			  decimal(9, 6)
	,@p_initial_sell_rate			  decimal(9, 6)
	,@p_initial_buy_amount			  decimal(18, 2)
	,@p_initial_sell_amount			  decimal(18, 2)
	,@p_initial_discount_pct		  decimal(9, 6)
	,@p_initial_discount_amount		  decimal(18, 2)
	,@p_initial_admin_fee_amount	  decimal(18, 2)
	,@p_initial_sell_admin_fee_amount decimal(18, 2)
	,@p_initial_stamp_fee_amount	  decimal(18, 2)
	,@p_buy_amount					  decimal(18, 2)
	,@p_sell_amount					  decimal(18, 2)
	,@p_total_buy_amount			  decimal(18, 2)
	,@p_total_sell_amount			  decimal(18, 2)
	,@p_insurance_type				  nvarchar(10)
	--
	,@p_cre_date					  datetime
	,@p_cre_by						  nvarchar(15)
	,@p_cre_ip_address				  nvarchar(15)
	,@p_mod_date					  datetime
	,@p_mod_by						  nvarchar(15)
	,@p_mod_ip_address				  nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@package_code  nvarchar(50)
			,@tenor_tc		int 
			,@package_msg   nvarchar(max)
			,@currency_code	nvarchar(3) ;

	begin try
		select	@package_code = package_code
				,@tenor_tc = at.tenor
				,@currency_code = am.currency_code
		from	dbo.application_main am 
				inner join dbo.application_tc at on (at.application_no = am.application_no)
		where	am.application_no = @p_application_no ;
		
		if (@p_tenor < 1)
		begin
			set @msg = 'Tenor must be greater than 0';
			raiserror(@msg, 16, -1) ;
		end 
		
		if (@p_tenor > (select tenor from dbo.application_tc where application_no = @p_application_no))
		begin
			set @msg = 'Tenor must be less or equal than ' + cast(ceiling(cast(@tenor_tc as decimal(18, 2)) / 12) as nvarchar(50));
			raiserror(@msg, 16, -1) ;
		end 

		if (isnull(@package_code, '') <> '')
		begin
			if exists (select 1 from dbo.master_package_insurance where package_code = @package_code)
			begin
				if not exists (select 1 from dbo.master_package_insurance where package_code = @package_code and insurance_code = @p_insurance_code)
				begin
					select  @package_msg = stuff(list,1,1,'')
					from    (
							select  ', ' + cast(insurance_name as varchar(16)) as [text()]
							from    dbo.master_package_insurance
							where package_code = @package_code
									and insurance_type ='LIFE'
							for     xml path('')
							) as Sub(list)
					set @msg = 'This Insurer is not listed in this package, Please select another Insurer like : ' + @package_msg
					raiserror (@msg, 16,1)
				end
			end
			
			if exists (select 1 from dbo.master_package_coverage where package_code = @package_code)
			begin
				if not exists (select 1 from dbo.master_package_coverage where package_code = @package_code and coverage_code = @p_coverage_code)
				begin
					select  @package_msg = stuff(list,1,1,'')
					from    (
							select  ', ' + cast(coverage_name as varchar(16)) as [text()]
							from    dbo.master_package_coverage
							where package_code = @package_code
									and insurance_type ='LIFE'
							for     xml path('')
							) as Sub(list)
					set @msg = 'This Coverage is not listed in this package, Please select another Coverage like : ' + @package_msg
					raiserror (@msg, 16,1)
				end
			end
		end
		

		insert into application_insurance
		(
			application_no
			,coverage_code
			,coverage_name
			,insurance_code
			,insurance_name
			,tenor
			,eff_date
			,exp_date
			,sum_insured_amount
			,initial_buy_rate
			,initial_sell_rate
			,initial_buy_amount
			,initial_sell_amount
			,initial_discount_pct
			,initial_discount_amount
			,initial_admin_fee_amount
			,initial_sell_admin_fee_amount
			,initial_stamp_fee_amount
			,buy_amount
			,sell_amount
			,adjustment_amount
			,total_buy_amount
			,total_sell_amount
			,currency_code
			,insurance_type
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_application_no
			,@p_coverage_code
			,@p_coverage_name
			,@p_insurance_code
			,@p_insurance_name
			,@p_tenor
			,@p_eff_date
			,@p_exp_date
			,@p_sum_insured_amount
			,@p_initial_buy_rate
			,@p_initial_sell_rate
			,@p_initial_buy_amount
			,@p_initial_sell_amount
			,@p_initial_discount_pct
			,@p_initial_discount_amount
			,@p_initial_admin_fee_amount
			,@p_initial_sell_admin_fee_amount
			,@p_initial_stamp_fee_amount
			,@p_buy_amount
			,@p_sell_amount
			,0
			,@p_total_buy_amount
			,@p_total_sell_amount
			,@currency_code
			,@p_insurance_type
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
		
		exec dbo.xsp_application_insurance_fee_update @p_application_no		= @p_application_no
													  ,@p_insurance_type	= @p_insurance_type
													  ,@p_mod_date			= @p_mod_date
													  ,@p_mod_by			= @p_mod_by
													  ,@p_mod_ip_address	= @p_mod_ip_address
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

