CREATE procedure dbo.xsp_eoy_asset_process
as
begin
    
	declare	@sys_date	datetime = dbo.xfn_get_system_date()
			,@date		datetime
			,@job_code	nvarchar(50) = 'EOYAS'

	if right(convert(char(8),@sys_date,112),4) = '0101'
	begin
		set @date = dateadd(day,-1,@sys_date)
		exec dbo.xsp_rpt_fixed_asset_list @p_user_id						= @job_code
										 ,@p_date_type						= 'ALL'
										 ,@p_report_type					= 'DETAIL'
										 ,@p_from_date						= @date
										 ,@p_to_date						= @date
										 ,@p_area_code						= ''
										 ,@p_branch_code					= ''
										 ,@p_category_code					= ''
										 ,@p_item_group_code				= ''
										 ,@p_asset_code						= ''
										 ,@p_net_book_value_commercial		= ''
										 ,@p_net_book_value_fiscal			= ''
		
		declare @rpt_fixed_asset_list_summary table
		(
			user_id								nvarchar(50)
			,asset_code							nvarchar(50)
			,barcode							nvarchar(50)
			,deskripsi							nvarchar(250)
			,saldo_awal							decimal(18, 2)
			,penambahan							decimal(18, 2)
			,pengurangan_penjualan				decimal(18, 2)
			,pengurangan_pemutihan				decimal(18, 2)
			,penjabaran_kurs					decimal(18, 2)
			,revaluasi							decimal(18, 2)
			,saldo_akhir						decimal(18, 2)
			,net_book_value_awal				decimal(18, 2)
			,saldo_awal_akumulasi				decimal(18, 2)
			,penambahan_akumulasi				decimal(18, 2)
			,pengurangan_penjualan_akumulasi	decimal(18, 2)
			,pengurangan_pemutihan_akumulasi	decimal(18, 2)
			,penjabaran_kurs_akumulasi			decimal(18, 2)
			,revaluasi_akumulasi				decimal(18, 2)
			,saldo_akhir_akumulasi				decimal(18, 2)
			,net_book_value_akhir				decimal(18, 2)			
			,region_code						nvarchar(50)
			,region_name						nvarchar(250)
			,office_code						nvarchar(50)
			,office_name						nvarchar(250)
			,category_code						nvarchar(50)
			,category_name						nvarchar(250)
			,asset_type							nvarchar(50)
			,mutation							decimal(18,2)
			,mutation_akumulasi					decimal(18,2)
		)
		

		insert into @rpt_fixed_asset_list_summary
		    (user_id
		    ,asset_code
		    ,barcode
		    ,deskripsi
		    ,saldo_awal
		    ,penambahan
		    ,pengurangan_penjualan
		    ,pengurangan_pemutihan
		    ,penjabaran_kurs
		    ,revaluasi
		    ,saldo_akhir
		    ,net_book_value_awal
		    ,saldo_awal_akumulasi
		    ,penambahan_akumulasi
		    ,pengurangan_penjualan_akumulasi
		    ,pengurangan_pemutihan_akumulasi
		    ,penjabaran_kurs_akumulasi
		    ,revaluasi_akumulasi
		    ,saldo_akhir_akumulasi
		    ,net_book_value_akhir
			,region_code		
			,region_name	
			,office_code	
			,office_name	
			,category_code	
			,category_name	
			,asset_type		
			,mutation
			,mutation_akumulasi
		    )
		select	user_id
				,asset_code
				,'' --barcode
				,'' --deskripsi
				,sum(saldo_awal)
				,sum(penambahan)
				,sum(pengurangan_penjualan)
				,sum(pengurangan_pemutihan)
				,sum(penjabaran_kurs)
				,sum(revaluasi)
				,sum(saldo_akhir)
				,sum(net_book_value_awal)
				,sum(saldo_awal_akumulasi)
				,sum(penambahan_akumulasi)
				,sum(pengurangan_penjualan_akumulasi)
				,sum(pengurangan_pemutihan_akumulasi)
				,sum(penjabaran_kurs_akumulasi)
				,sum(revaluasi_akumulasi)
				,sum(saldo_akhir_akumulasi)
				,sum(net_book_value_akhir)
				,'' --region_code		
				,'' --region_name	
				,'' --office_code	
				,'' --office_name	
				,'' --category_code	
				,'' --category_name	
				,'' --asset_type		
				,sum(mutation)
				,sum(mutation_akumulasi)
		from	dbo.rpt_fixed_asset_list_summary
		where	user_id = @job_code
		group by user_id
				,asset_code
				
		-- update saldo
		update	@rpt_fixed_asset_list_summary
		set		saldo_akhir = saldo_awal + penambahan + pengurangan_penjualan + pengurangan_pemutihan + penjabaran_kurs + revaluasi + mutation
				,saldo_akhir_akumulasi = saldo_awal_akumulasi + penambahan_akumulasi + pengurangan_penjualan_akumulasi + pengurangan_pemutihan_akumulasi + penjabaran_kurs_akumulasi + revaluasi_akumulasi + mutation_akumulasi
		where	user_id = @job_code
		
		-- update nbv	
		update	@rpt_fixed_asset_list_summary
		set		net_book_value_awal		= saldo_awal - saldo_awal_akumulasi
				,net_book_value_akhir	= saldo_akhir - saldo_akhir_akumulasi
		where	user_id = @job_code
			
		insert into dbo.asset_ending_balance
		    (asset_code
		    ,period
		    ,balance_amount
		    ,balance_amount_accum
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		    )
		select asset_code
		    ,@sys_date
		    ,saldo_akhir
		    ,saldo_akhir_akumulasi
		    ,getdate()
		    ,@job_code
		    ,'10.0.9.205'
		    ,getdate()
		    ,@job_code
		    ,'10.0.9.205'
		from	@rpt_fixed_asset_list_summary
		where	user_id = @job_code
	end

end
