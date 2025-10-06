/*
	alterd : Nia, 11 Juni 2021
*/
CREATE PROCEDURE dbo.xsp_endorsement_period_getrate
(
    @p_endorsement_code  nvarchar(50),
    @p_coverage_code	 nvarchar(50),
    @p_year_period		 int,
	@p_sum_insured		 decimal(18, 2),
    @p_buy_rate			 decimal(9, 6) output,
    @p_sell_rate		 decimal(9, 6) output,
    @p_buy_amount		 decimal(18, 2) output,
    @p_sell_amount		 decimal(18, 2) output,
    @p_discount_pct		 decimal(9, 6) output
)
as
begin

    declare @msg						nvarchar(max),
            @insurance_type				nvarchar(50),
            @insurance_code				nvarchar(50),
            @gender						nvarchar(1),
            @eff_rate					decimal(9, 6),
            @day_in_year_code			nvarchar(10),
            @day_in_year				int,
            @age						int,
            @periode_start_date			datetime,
            @periode_end_date			datetime,
            @collateral_type			nvarchar(10),
            @collateral_category_code	nvarchar(50),
            @region_code				nvarchar(50),
            @occupation_code			nvarchar(50),
            @is_comercial				nvarchar(1),
            @is_authorized_workshop		nvarchar(1),
            @rate_life_code				nvarchar(50),
            @rate_life_eff_code			nvarchar(50),
            @rate_non_life_code			nvarchar(50),
            @day_period					int = 0,
            @month_period				int = 0, -- jumlah hari nya. untuk perhitungan proportional 
            @day_proporsional			int = 0, -- jumlah hari nya. untuk perhitungan proportional 
			@category_name              nvarchar(100), 
			@coverage_name              nvarchar(100), 
			@occupation_name            nvarchar(100), 
			@region_name	            nvarchar(100),
			@depreciation_code			nvarchar(50),
			@policy_code				nvarchar(50),
			@sum_insured				decimal(18, 2)

    begin try
	
		select @policy_code		= policy_code
		from dbo.endorsement_main em
		where code = @p_endorsement_code

        select @insurance_type				= ipm.insurance_type,
               @insurance_code				= ipm.insurance_code,
               @eff_rate					= isnull(ipm.eff_rate,0),
               @collateral_type				= ipm.collateral_type,
               @collateral_category_code	= ipm.collateral_category_code,
               @region_code					= isnull(ipm.region_code, ''),
               @occupation_code				= isnull(ipm.occupation_code, ''),
			   @depreciation_code           = ipm.depreciation_code,
			   @month_period				= datediff(month, ipm.policy_eff_date, ipm.policy_exp_date)-- in month
        from  dbo.insurance_policy_main ipm 
			  left join dbo.insurance_register ir on (ir.code = ipm.register_code)
        where ipm.code = @policy_code;		
		
        if @insurance_type = 'NON LIFE'
        begin
			
			if not exists
			(
				select	1
				from	dbo.master_depreciation_detail
				where	depreciation_code = @depreciation_code
						and tenor		  = @p_year_period * 12
			)
			begin
				set @msg = 'Please setting insurance depreciation' ;

				raiserror(@msg, 16, -1) ;
			end ;
			else
			begin
				select	@sum_insured = @p_sum_insured * rate / 100.00
				from	dbo.master_depreciation_detail
				where	depreciation_code = @depreciation_code
						and tenor		  = @p_year_period * 12 ;
			end ;
	
            if exists
            (
                select 1
                from dbo.master_insurance_rate_non_life
                where insurance_code					= @insurance_code
                      and collateral_type_code			= @collateral_type
                      and collateral_category_code		= @collateral_category_code
                      and coverage_code					= @p_coverage_code
                      and isnull(region_code, '')		= @region_code
                      and isnull(occupation_code, '')	= @occupation_code
            )
            begin
				select @category_name		= category_name
					   ,@coverage_name		= coverage_name
					   ,@occupation_name	= occupation_name
					   ,@region_name		= region_name
                from  dbo.master_insurance_rate_non_life mirnl
					  left join master_collateral_category mcc ON (mcc.code = mirnl.collateral_type_code)
					  left join master_coverage mc ON (mc.code = mirnl.coverage_code)
					  left join master_occupation mo ON (mo.code = mirnl.occupation_code)
					  left JOIN dbo.master_region mr ON (mr.code = mirnl.region_code)
				where insurance_code						= @insurance_code
                      and mirnl.collateral_type_code		= @collateral_type
                      and collateral_category_code			= @collateral_category_code
                      and coverage_code						= @p_coverage_code
                      and isnull(region_code, '')			= @region_code
                      and isnull(mo.occupation_code, '')	= @occupation_code

                select @rate_non_life_code = code,
                       @day_in_year_code   = day_in_year
                from dbo.master_insurance_rate_non_life
                where insurance_code						= @insurance_code
                      and collateral_type_code				= @collateral_type
                      and collateral_category_code			= @collateral_category_code
                      and coverage_code						= @p_coverage_code
                      and isnull(region_code, '')			= @region_code
                      and isnull(occupation_code, '')		= @occupation_code;

                if ((@p_year_period * 12) < @month_period) -- jika full maka tambah 1 tahun
                begin
                    set @periode_end_date = DATEADD(YEAR, 1, @periode_start_date);
                end;
            
                set @day_period = DATEDIFF(DAY, @periode_start_date, @periode_end_date);
			
                if (@day_in_year_code = 'ACTUAL')
                begin
                    set @day_in_year = DATEPART(dy, DATEFROMPARTS(@p_year_period, 12, 31));
                end;
				else
                begin
                    set @day_in_year = CAST(@day_in_year_code AS int);
                end;

                if exists
                (
                    select 1
                    from dbo.master_insurance_rate_non_life_detail
                    where rate_non_life_code = @rate_non_life_code
                          and @sum_insured
                          between sum_insured_from and sum_insured_to
                )
                begin
					
                    IF (@day_period < @day_in_year) -- jika di bawah 1 tahun maka ambil nilai proporsional nya
                    begin
                        set @day_proporsional = @day_period;
                    end;
                    else -- jika full maka jumlah hari = jumlah hari setahun
                    begin
                        set @day_proporsional = @day_in_year;
                    end;
                    --selecT @day_proporsional,@day_in_year

                    select @p_buy_rate		= (buy_rate * (@day_proporsional * 1.00 / @day_in_year)),
                           @p_sell_rate		= (sell_rate * (@day_proporsional * 1.00 / @day_in_year)),
                           @p_buy_amount	= (buy_amount * (@day_proporsional * 1.00 / @day_in_year)),
                           @p_sell_amount	= (sell_amount * (@day_proporsional * 1.00 / @day_in_year)),
                           @p_discount_pct	= discount_pct
                    from dbo.master_insurance_rate_non_life_detail
                    where rate_non_life_code = @rate_non_life_code
                          and @sum_insured
                          between sum_insured_from and sum_insured_to;

					--property
					if @collateral_type = 'PROP'
					begin
						set @p_buy_amount  = (@p_buy_amount/12) * @month_period
						set @p_sell_amount = (@p_sell_amount/12) * @month_period
						set @p_buy_rate	   = (@p_buy_rate/12) * @month_period
 						set @p_sell_rate   = (@p_sell_rate/12) * @month_period
					end
                end;
                else
                begin
                    set @msg = 'please setting detail insurance rate with sum insured = ' + convert(varchar,cast(@sum_insured as money), 1) ;

                    raiserror(@msg, 16, -1);
                end;

            end;
            else
            begin
                set @msg = 'please setting detail insurance rate combination ' + isnull(@category_name, '') + ' ' + isnull(@coverage_name, '') + ' ' + isnull(@region_name, '') + ' ' +isnull(@occupation_name, '');

                raiserror(@msg, 16, -1);
            end;
        end; 
        
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
end;















