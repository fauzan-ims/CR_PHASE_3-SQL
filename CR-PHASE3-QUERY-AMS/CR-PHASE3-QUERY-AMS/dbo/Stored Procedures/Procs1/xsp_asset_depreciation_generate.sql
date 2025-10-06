CREATE PROCEDURE dbo.xsp_asset_depreciation_generate
(
	@p_year				nvarchar(4) =''
	,@p_month			nvarchar(2) = ''
	,@p_company_code	nvarchar(50)
	
	--@p_to_date		datetime
	--
	,@p_cre_by		   nvarchar(15)
	,@p_cre_date	   datetime
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_by		   nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_ip_address nvarchar(15)
)
as
begin

	DECLARE @msg						NVARCHAR(MAX)
			,@asset_code				NVARCHAR(50)
			,@depre_date				DATETIME
			,@original_price			DECIMAL(18,2)
			,@depre_amount_comm			DECIMAL(18,2)
			,@nett_book_value_comm		DECIMAL(18,2)
			,@asset_code_fiscal			NVARCHAR(50)
			,@depre_date_fiscal			DATETIME
			,@original_price_fiscal		DECIMAL(18,2)
			,@depre_amount_fiscal		DECIMAL(18,2)
			,@nett_book_value_fiscal	DECIMAL(18,2)
			,@barcode					NVARCHAR(50)
			,@barcode_fiscal			NVARCHAR(50)
			,@purchase_amount			DECIMAL
			,@date_depre				DATETIME
            ,@period					INT
			,@sys_date					DATETIME = dbo.xfn_get_system_date()
			,@ctr						INT = 0
			,@period_depre				NVARCHAR(10) = @p_year + '-' + @p_month + '-01'
			,@date						DATETIME
			,@is_valid					INT
			,@max_day					INT ;

	begin try
		
		if(@p_month = '')
		begin
			set @msg = 'Please insert Month.';
			raiserror(@msg, 16, -1) ;
		END

		if(@p_year = '')
		begin
			set @msg = 'Please insert Year.';
			raiserror(@msg, 16, -1) ;
		end	

		---- Arga 12-Nov-2022 ket : based on request zaka wom (+)
		--declare @exclude_trx table
		--(
		--	asset_code	nvarchar(50)
		--)

		--insert into @exclude_trx (asset_code)
		--select	asset_code
		--from	dbo.asset_mutation_history
		--where	convert(char(6),date,112) > (@p_year + @p_month)
		--union
		--select	asset_code
		--from	dbo.adjustment
		--where	STATUS = 'POST'
		--and		convert(char(6),date,112) > (@p_year + @p_month)

		--delete dbo.asset_depreciation
		--where month(depreciation_date) <= cast(@p_month as int)
		--and	year(depreciation_date) <= cast(@p_year as int)
		--and status = 'NEW'

		delete dbo.asset_depreciation
		where status = 'HOLD'
		
		declare curr_asset_depre_gennerate cursor fast_forward read_only for 
		select	adsc.asset_code
				,isnull(ass.barcode,'')
				,adsc.depreciation_date
				,adsc.original_price
				,isnull(adsc.depreciation_amount, 0)
				,isnull(adsf.depreciation_amount, 0)
				,isnull(adsc.net_book_value, 0)
				,isnull(adsf.net_book_value, 0)
				,isnull(ass.purchase_price, 0)
		from	dbo.asset_depreciation_schedule_commercial adsc
				left join dbo.asset ass on (ass.code									   = adsc.asset_code)
				left  join dbo.asset_depreciation_schedule_fiscal adsf on (adsf.asset_code = adsc.asset_code and month(adsf.depreciation_date) = cast(@p_month as int) and year(adsf.depreciation_date) =  cast(@p_year as int))
		where	ass.status								IN( 'STOCK','REPLACEMENT')
				--and ass.company_code					= @p_company_code
				and adsc.transaction_code				= ''
				--AND month(adsc.depreciation_date)		<= cast(@p_month as int) -- Arga 21-Oct-2022 ket : cover case depre blm jalan pada bulan sebelmunya (+)
				--and year(adsc.depreciation_date)		<= cast(@p_year as int) -- Arga 21-Oct-2022 ket : cover case depre blm jalan pada bulan sebelmunya (+)
				and convert(nvarchar(6), adsc.depreciation_date, 112) <= convert(nvarchar(6),dbo.xfn_get_system_date(),112) -- 20231202 hari-- rubah logic where date depre kurang dari sekarang- 
				--and adsc.asset_code collate Latin1_General_CI_AS not in (select asset_code from @exclude_trx) -- Arga 12-Nov-2022 ket : based on request zaka wom (+)
				and isnull(ass.is_permit_to_sell,'0') = '0' -- Bagas : asset yang belom pernah pengajuan penjualan yang terdepresiasi
				--(+) Saparudin : 19-09-2022 and cast(adsc.depreciation_date as date) = eomonth(cast(@p_to_date as date)) ;

		open curr_asset_depre_gennerate
		
		fetch next from curr_asset_depre_gennerate 
		into @asset_code
			,@barcode
			,@depre_date
			,@original_price
			,@depre_amount_comm
			,@depre_amount_fiscal
			,@nett_book_value_comm
			,@nett_book_value_fiscal
			,@purchase_amount
		
		while @@fetch_status = 0
		begin
			set @ctr += 1;

		    exec dbo.xsp_asset_depreciation_insert  @p_id								 = 0
		    									   ,@p_asset_code						 = @asset_code
		    									   ,@p_barcode							 = @barcode
		    									   ,@p_depreciation_date				 = @depre_date
		    									   ,@p_depreciation_commercial_amount	 = @depre_amount_comm
		    									   ,@p_net_book_value_commercial		 = @nett_book_value_comm
		    									   ,@p_depreciation_fiscal_amount		 = @depre_amount_fiscal
		    									   ,@p_net_book_value_fiscal			 = @nett_book_value_fiscal
		    									   ,@p_purchase_amount					 = @purchase_amount
		    									   ,@p_status							 = 'HOLD'
		    									   ,@p_cre_date							 = @p_cre_date		  
		    									   ,@p_cre_by							 = @p_cre_by	  
		    									   ,@p_cre_ip_address					 = @p_cre_ip_address
		    									   ,@p_mod_date							 = @p_mod_date		  
		    									   ,@p_mod_by							 = @p_mod_by	  
		    									   ,@p_mod_ip_address					 = @p_mod_ip_address
		    
		
		    fetch next from curr_asset_depre_gennerate 
			into @asset_code
				,@barcode
				,@depre_date
				,@original_price
				,@depre_amount_comm
				,@depre_amount_fiscal
				,@nett_book_value_comm
				,@nett_book_value_fiscal
				,@purchase_amount
		END
		
		close curr_asset_depre_gennerate
		deallocate curr_asset_depre_gennerate

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
