/*
	alterd : Nia, 20 Mei 2020
*/
CREATE PROCEDURE [dbo].[xsp_insurance_register_post]
(		
	@p_code					NVARCHAR(50)
	--
	,@p_cre_date			DATETIME
	,@p_cre_by				NVARCHAR(15)
	,@p_cre_ip_address		NVARCHAR(15)
	,@p_mod_date			DATETIME
	,@p_mod_by				NVARCHAR(15)
	,@p_mod_ip_address		NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg						    NVARCHAR(MAX)
			,@branch_code			        NVARCHAR(50)
			,@branch_name			        NVARCHAR(250)
			,@agreement_no			        NVARCHAR(50)
			,@currency_code			        NVARCHAR(3)
            ,@source						NVARCHAR(50)
			,@insurance_paid_by				NVARCHAR(10)
			,@total_sell_amount             DECIMAL(18, 2)
			,@request_remarks               NVARCHAR(4000)
			,@received_request_code			NVARCHAR(50)
			,@gl_link_code					NVARCHAR(50)
			,@sp_name						NVARCHAR(250)
			,@debet_or_credit				NVARCHAR(10)
			,@orig_amount_db				decimal(18, 2)
			,@orig_amount_cr				decimal(18, 2)
			,@return_value					decimal(18, 2)
			,@facility_code		            nvarchar(50)
			,@facility_name		            nvarchar(250)
			,@purpose_loan_code             nvarchar(50)
			,@purpose_loan_name             nvarchar(250)
			,@purpose_loan_detail_code      nvarchar(50)
			,@purpose_loan_detail_name      nvarchar(250)
			,@request_amount				decimal(18, 2)
			,@register_no					nvarchar(50)
			,@insurance_payment_type		nvarchar(10)
			,@period_year					int
			,@count_main_coverage			int
			,@fa_code						nvarchar(50)
			,@coverage_budget_insurance		nvarchar(50)
			,@remark						nvarchar(4000)

	begin TRY
    
		IF EXISTS (
			select 1
			from dbo.insurance_register ir
			inner join dbo.insurance_register_asset ira on ira.register_code = ir.code
			inner join ifinams.dbo.sale_detail sd on sd.asset_code = ira.fa_code
			inner join ifinams.dbo.sale s on s.code = sd.sale_code
			where ir.code = @p_code
			  and s.status not in ('CANCEL','REJECT')
		)
		BEGIN
			DECLARE @platno_list NVARCHAR(MAX);
    
			SELECT @platno_list = STRING_AGG(av.PLAT_NO, ', ')
			FROM dbo.INSURANCE_REGISTER ir
			INNER JOIN dbo.INSURANCE_REGISTER_ASSET ira ON ira.REGISTER_CODE = ir.CODE
			INNER JOIN IFINAMS.dbo.SALE_DETAIL sd ON sd.ASSET_CODE = ira.FA_CODE
			INNER JOIN IFINAMS.dbo.SALE s ON s.CODE = sd.SALE_CODE
			INNER JOIN IFINAMS.dbo.ASSET_VEHICLE av ON av.ASSET_CODE = sd.ASSET_CODE
			WHERE ir.CODE = @p_code
			  AND s.STATUS not in ('CANCEL','REJECT');

			SET @msg = N'Asset Are In Sales Request Process, For Plat No: ' + ISNULL(@platno_list, '');
			RAISERROR(@msg, 16, -1);
			RETURN;
		END


    
		select @branch_code					= ir.branch_code
			   ,@branch_name				= ir.branch_name
			   ,@currency_code           	= ir.currency_code   
			   ,@insurance_paid_by          = insurance_paid_by 
			   ,@request_remarks			= 'Receive insurance register'
			   ,@insurance_payment_type		= insurance_payment_type
			   ,@period_year				= ir.year_period
			   ,@remark						= isnull(ir.register_remarks,'')		
		from   dbo.insurance_register ir
		where  ir.code = @p_code

		if exists
		(
			select	1
			from	dbo.insurance_register_asset
			where	register_code		  = @p_code
					and depreciation_code = ''
		)
		begin
			set @msg = N'Please input depreciation in asset.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if(@remark = '')
		begin
			set @msg = N'Please input remark.' ;

			raiserror(@msg, 16, -1) ;
		end
		
		if exists (select 1 from dbo.insurance_register where code = @p_code and register_status = 'HOLD')
		begin

			if not exists (select 1 from dbo.insurance_register_period where register_code = @p_code)
			begin
				set @msg = N'Please add insurance period' ;

				raiserror(@msg, 16, -1) ;
			end

			select	@count_main_coverage = count(1)
			from	dbo.insurance_register_period irp
			inner join dbo.master_coverage mc on (irp.coverage_code = mc.code)
			where	irp.register_code = @p_code
			and mc.is_main_coverage = '1'
			
			if @count_main_coverage <> ceiling((@period_year * 1.0)/12)
			begin
				set @msg = 'Main Coverage must be equal with period (month).' ;
				raiserror(@msg, 16, -1) ;
			end

			if not exists (select 1 from dbo.insurance_register_asset where register_code = @p_code)
			begin
				set @msg = 'Please add insurance asset.' ;
				raiserror(@msg, 16, -1) ;
			end

			--validasi coverage dengan budget insurance
			declare cursor_name cursor fast_forward read_only for
			select	ira.fa_code
			from	dbo.insurance_register_asset	  ira
					inner join dbo.insurance_register ir on ir.code = ira.register_code
			where	ir.code = @p_code ;
			
			open cursor_name
			
			fetch next from cursor_name 
			into @fa_code
			
			while @@fetch_status = 0
			begin
				select	@coverage_budget_insurance = main_coverage_code
				from	dbo.asset_insurance
				where	asset_code = @fa_code ;
			
			    fetch next from cursor_name 
				into @fa_code
			end
			
			close cursor_name
			deallocate cursor_name
			
			if not exists (select 1 from dbo.insurance_register_period irp
							inner join dbo.master_coverage mc on (mc.code = irp.coverage_code)
							inner join dbo.insurance_register ir on (ir.code = irp.register_code)
							where register_code = @p_code and mc.is_main_coverage = '1')
			begin
				set @msg = 'Please setting default main coverage' ;

				raiserror(@msg, 16, -1) ;
			end
			else
			begin
				update	dbo.insurance_register
				set		register_status = 'ON PROCESS'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code

				-- jika dari manual ( source <> application) dan di bayar oleh client maka masuk ke received request dulu
				if (
					   @source = ''
					   and	@insurance_paid_by = 'CLIENT'
				   )
				begin
					select	@request_amount = sum(request_amount)
					from	dbo.efam_interface_cashier_received_request 
					where	code = @received_request_code

					select	@orig_amount_cr = abs(sum(orig_amount))
					from	dbo.efam_interface_cashier_received_request_detail
					where	cashier_received_request_code = @received_request_code
				
					--+ validasi : total detail =  payment_amount yang di header
					if (@request_amount <> @orig_amount_cr)
					begin
						set @msg = 'Amount does not balance' ;

						raiserror(@msg, 16, -1) ;
					end
				end
				else
				begin
					exec dbo.xsp_insurance_register_paid	@p_code           = @p_code,                      
															@p_cre_date       = @p_cre_date,		
															@p_cre_by	      = @p_cre_by,		
															@p_cre_ip_address = @p_cre_ip_address,	
															@p_mod_date       = @p_mod_date,		
															@p_mod_by         = @p_mod_by,			
															@p_mod_ip_address = @p_mod_ip_address	


				end

			end
		end
		else
		begin
			set @msg = N'Data already proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		select @msg
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




