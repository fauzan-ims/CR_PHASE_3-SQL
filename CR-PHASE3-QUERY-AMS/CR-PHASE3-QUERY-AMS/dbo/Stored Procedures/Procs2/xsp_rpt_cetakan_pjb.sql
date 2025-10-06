--Created, Aliv at 26-05-2023
CREATE PROCEDURE dbo.xsp_rpt_cetakan_pjb
(
	@p_user_id			nvarchar(50)	
	,@p_sell_code		nvarchar(50)
	,@p_sell_type		nvarchar(50)
	--,@p_sell_date		datetime
	,@p_buyer_name		nvarchar(50)
	,@p_buyer_type		nvarchar(50)
	,@p_buyer_ktp_no	nvarchar(50)
	,@p_buyer_npwp		nvarchar(50)
	,@p_cre_date		datetime
)
as
BEGIN

	delete dbo.rpt_cetakan_pjb
	where	user_id = @p_user_id ;

	delete dbo.rpt_laporan_pjb
	where	user_id = @p_user_id ;

	delete dbo.rpt_cetakan_pjb_berita_acara_serah_terima_kendaraan
	where	user_id = @p_user_id ;

	delete	dbo.rpt_pjb_bastk
	where	user_id = @p_user_id ;



	declare @msg						nvarchar(max)
			,@report_company			nvarchar(250)
			,@report_title				nvarchar(250)
			,@report_title_detail		nvarchar(250)
			,@report_image				nvarchar(250)
			,@report_address			nvarchar(250)
			,@report_direktur			nvarchar(250)
			,@buyer_type				nvarchar(250)
			,@year						nvarchar(4)
			,@month						nvarchar(4)
			,@code						nvarchar(50)
			,@tipe_kendaraan			nvarchar(250)
			,@built_year				nvarchar(10)
			,@engine_no					nvarchar(250)
			,@chassis_no				nvarchar(250)
			,@plat_no					nvarchar(250)
			,@bpkb_no					nvarchar(250)
			,@print_tipe_kendaraan		nvarchar(50)
			,@print_built_year			nvarchar(50)
			,@print_engine_no			nvarchar(50)
			,@print_chasis_no			nvarchar(50)
			,@print_plat_no				nvarchar(50)
			,@print_bpkb_no				nvarchar(50)
			,@print_no					nvarchar(50)
			,@no						int = 0
			,@temp_print_tipe_kendaraan	nvarchar(4000)
			,@temp_print_built_year		nvarchar(4000)
			,@temp_print_engine_no		nvarchar(4000)
			,@temp_print_chasis_no		nvarchar(4000)
			,@temp_print_plat_no		nvarchar(4000)	
			,@temp_print_bpkb_no		nvarchar(4000)	
			,@temp_no					nvarchar(4000)
			,@jml_unit					int
			,@direktur_name				nvarchar(50)
			,@pjb_no					nvarchar(50)
			,@code_2					nvarchar(50)
			,@month_rom					nvarchar(4)	
			,@nama						nvarchar(50)
			,@position_name				nvarchar(250)
			,@branch_code				nvarchar(50)
			,@count_jumlah				int
			,@sum_kendaraan				decimal(18,2)
			,@report_title_laporan		nvarchar(50)
			,@nama_leesee				nvarchar(50)
			,@sell_code					nvarchar(50)
			,@sell_id					nvarchar(50)
			,@sale_date					datetime
			,@nama_bank					nvarchar(50)
			,@nama_rek					nvarchar(50)
			,@no_rek					nvarchar(50)
			,@perjanjian_no				nvarchar(50)

	begin TRY
		set @year = year(@p_cre_date) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
		
		select	top 1
				@sale_date = sale_date
		from	dbo.sale_detail
		where	sale_code = @p_sell_code
				and sale_date is not null ;

		select @month_rom = dbo.xfn_convert_int_to_roman(@month)
		declare cur_cetakan_pjb cursor fast_forward read_only for
			
			select	sd.id
			from	dbo.sale_detail sd
					left join sale sa on sa.code = sd.sale_code
			where	isnull(sd.buyer_name,'')					= isnull(@p_buyer_name,'')
					and isnull(sa.sell_type,'')					= isnull(@p_sell_type,'')
					and isnull(sd.buyer_type,'')				= isnull(@p_buyer_type,'')
					and isnull(sd.ktp_no,'')				    = isnull(@p_buyer_ktp_no,'')
					and isnull(sd.buyer_npwp,'')			    = isnull(@p_buyer_npwp,'')
					and cast(sd.sale_date as date)				= cast(@sale_date as date)
					and sd.sale_detail_status					<> 'HOLD' ;

			open cur_cetakan_pjb
		
			fetch next from cur_cetakan_pjb 
			into	@sell_id

			while @@fetch_status = 0
			begin

				declare @unique_code nvarchar(50) ;
				exec dbo.xsp_generate_auto_surat_no @p_unique_code = @unique_code output -- nvarchar(50)
													,@p_branch_code = N'' -- nvarchar(10)
													,@p_year = @year -- nvarchar(4)
													,@p_month = @month_rom -- nvarchar(4)
													,@p_opl_code = N'DISP' -- nvarchar(250)
													,@p_jkn = N'PJB' -- nvarchar(250)
													,@p_run_number_length = 5 -- int
													,@p_delimiter = N'/' -- nvarchar(1)
													,@p_table_name = N'SALE_DETAIL' -- nvarchar(250)
													,@p_column_name = N'PJB_NO' -- nvarchar(250)
		
				select @pjb_no = pjb_no
				from dbo.SALE_DETAIL
				where	sale_code = @p_sell_code ;

				select	@branch_code = branch_code
				from	sale
				where	code = @p_sell_code ;

				if @pjb_no is null
				begin
				update	dbo.sale_detail
				set		pjb_no = @unique_code
				where	sale_code = @p_sell_code;
				set		@pjb_no = @unique_code ;
				end ;

				select	@report_company = value
				from	dbo.sys_global_param
				where	code = 'COMP2' ;

				set	@report_title			= 'Perjanjian Jual Beli';
				set	@report_title_detail	= 'BERITA ACARA SERAH TERIMA KENDARAAN';
				set @report_title_laporan	= 'Laporan Perjanjian Jual Beli';

				select	@report_image = value
				from	dbo.sys_global_param
				where	code = 'IMGDSF' ;

				select @report_address = value 
				from	dbo.sys_global_param
				where	code = 'COMADD2'

				select @buyer_type = buyer_type 
				from dbo.sale_detail
				where sale_code = @p_sell_code

				select @jml_unit = count(1) 
				from dbo.sale_detail
				where sale_code = @p_sell_code

				select	@nama = sbs.signer_name 
						,@position_name = spo.description
				from	ifinsys.dbo.sys_branch_signer sbs
				inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
				inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
				where	sbs.signer_type_code = 'DIREKOPL'
						and sbs.branch_code = @branch_code ;

				select	@nama_bank = value
				from	dbo.sys_global_param
				where	code = 'BANKNAMEINV' ;

				select	@nama_rek = value
				from	dbo.sys_global_param
				where	code = 'BANKREKINV' ;

				select	@no_rek = value
				from	dbo.sys_global_param
				where	code = 'BANKREKNOINV' ;

				insert into dbo.rpt_cetakan_pjb
				(
					user_id
					,report_company
					,report_title
					,report_image
					,report_address
					,client_type
					,pjb_no
					,hari_pjb
					,tanggal_pjb
					,direktur_name
					,buyer_name
					,buyer_address
					,ktp_no
					,nama_kendaraan
					,tahun_pembuatan
					,jumlah_unit
					,engine_no
					,chassis_no
					,plat_no
					,no_bpkb
					,price
					,nominal
					,nama_bank
					,nama_akun_bank
					,no_rek
					,client_name
					,client_address
					,client_direktur
					,DIREKTUR_JABATAN
					,TOTAL_HARGA
				)
				select	@p_user_id
						,@report_company
						,@report_title
						,@report_image
						,@report_address
						,sd.BUYER_TYPE
						--,case
						--	when sa.SELL_TYPE='COP' then cma.client_type
						--	else'CORPORATE'
						--end
						,@pjb_no --@code	output
						,case datename(dw, sd.sale_date)
							 when 'monday' then 'Senin'
							 when 'tuesday' then 'Selasa'
							 when 'wednesday' then 'Rabu'
							 when 'thursday' then 'Kamis'
							 when 'friday' then 'Jumat'
							 when 'saturday' then 'Sabtu'
							 when 'sunday' then 'Minggu'
						 end
						,sd.sale_date
						,upper(@nama)
						,case
						when sd.buyer_type='PERSONAL' then sd.buyer_name
						else upper(case
									--when sell_type = 'COP' then ass.client_name
									when sell_type = 'AUCTION' then ma.auction_name
									else upper(sd.buyer_name)
								end)
						end
						,case
							 --when sell_type = 'COP' then isnull(cad.address,'-')
							 when sell_type = 'AUCTION' then isnull(maa.address,'-')
							 else sd.buyer_address
						 end
						,sd.ktp_no
						,ass.item_name
						,case
							 when av.built_year = '' then '-'
							 when av.built_year is null then '-'
							 else av.built_year
						 end
						,'1 (satu) Unit'
						,case
							 when av.engine_no = '' then '-'
							 when av.engine_no is null then '-'
							 else av.engine_no
						 end
						,case
							 when av.chassis_no = '' then '-'
							 when av.chassis_no is null then '-'
							 else av.chassis_no
						 end
						,case
							 when av.plat_no = '' then '-'
							 when av.plat_no is null then '-'
							 else av.plat_no
						 end
						,case
							 when av.stnk_name = '' then '-'
							 when av.stnk_name is null then '-'
							 else av.stnk_name
						 end
						,dbo.xfn_separator_tiga(ass.purchase_price)
						--,dbo.Terbilang(sale_detail.sell_request_amount) + 'Rupiah'
						,dbo.Terbilang(sd.sold_amount) + 'Rupiah'
						,@nama_bank--upper(mab.bank_name)
						,@nama_rek--upper(mab.bank_account_name)
						,@no_rek--mab.bank_account_no
						,case
						when sd.buyer_type='PERSONAL' then sd.BUYER_NAME
						else upper(case
									--when sell_type = 'COP' then ass.client_name
									when sell_type = 'AUCTION' then ma.auction_name
									else upper(sd.buyer_name)
								end)
						end
						,case
							 --when sell_type = 'COP' then isnull(cad.address,'-')
							 when sell_type = 'AUCTION' then isnull(maa.address,'-')
							 else sd.buyer_address
						 end
						,case
						when sd.buyer_type='PERSONAL' then sd.BUYER_NAME
						else upper(case
									--when sell_type = 'COP' then ass.client_name
									when sell_type = 'AUCTION' then ma.auction_name
									else upper(sd.buyer_signer_name)
								end)
						end
						,@position_name
						--,sale_detail.sell_request_amount
						,sd.sold_amount
				from	dbo.sale_detail sd
						left join dbo.sale sa on (sa.code = sd.sale_code)
						left join dbo.asset ass on (ass.code = sd.asset_code)
						left join ifinopl.dbo.client_main cma on (cma.client_no = ass.CLIENT_NO)
						left join dbo.asset_vehicle av on (av.asset_code = ass.code)
						left join dbo.master_auction ma on (ma.code = sa.auction_code)
						left join dbo.master_auction_bank mab on (mab.auction_code = ma.code)
						left join dbo.master_auction_address maa on (maa.auction_code = ma.code)
						left join ifinopl.dbo.client_address cad on cad.client_code = ass.client_no
						left join ifinopl.dbo.CLIENT_RELATION		 cr on cr.client_code = cma.code and cr.relation_type = 'SHAREHOLDER'
						outer apply
							(
								select	sum(sd.sell_request_amount) 'sell_request_amount'
								from	dbo.sale_detail sd
								where	sd.sale_code = @p_sell_code
							) sale_detail
						outer apply(
							SELECT top 1 full_name 'direktur_name' FROM ifinopl.dbo.CLIENT_RELATION cri
							where cri.CLIENT_CODE = cr.CLIENT_CODE and cri.FULL_NAME is not null and cri.relation_type = 'SHAREHOLDER'
							order by cri.FULL_NAME desc
						) nama
				where	sd.id = @sell_id ;

				insert into dbo.rpt_laporan_pjb
				(
					user_id
					,report_title
					,no_pjb
					,type_kendaraan
					,tahun_pembuatan
					,engine_no
					,chassis_no
					,plat_no
					,nama_bpkb
					,nilai_jual
				)
				select	distinct @p_user_id
						,@report_title_laporan
						,@pjb_no --@code	output
						,ass.item_name
						,case
							 when av.built_year = '' then '-'
							 when av.built_year is null then '-'
							 else av.built_year
						 end
						,case
							 when av.engine_no = '' then '-'
							 when av.engine_no is null then '-'
							 else av.engine_no
						 end
						,case
							 when av.chassis_no = '' then '-'
							 when av.chassis_no is null then '-'
							 else av.chassis_no
						 end
						,case
							 when av.plat_no = '' then '-'
							 when av.plat_no is null then '-'
							 else av.plat_no
						 end
						,case
							 when av.stnk_name = '' then '-'
							 when av.stnk_name is null then '-'
							 else av.stnk_name
						 end
						--,ass.purchase_price
						,sd.sell_request_amount
				from	dbo.sale_detail sd
						left join dbo.sale sa on (sa.code								= sd.sale_code)
						left join dbo.asset ass on (ass.code						= sd.asset_code)
						left join dbo.asset_vehicle av on (av.asset_code			= ass.code)
						left join dbo.master_auction ma on (ma.code					= sa.auction_code)
						left join dbo.master_auction_bank mab on (mab.auction_code	= ma.code)
						left join dbo.master_auction_address maa on (maa.auction_code = ma.code)
						left join ifinopl.dbo.client_address cad on cad.client_code = ass.client_no
						outer apply(select sum(sd.sell_request_amount) 'sell_request_amount' from dbo.sale_detail sd where sd.sale_code = @p_sell_code) sale_detail
				where	sd.id	  = @sell_id;

				insert into dbo.RPT_CETAKAN_PJB_BERITA_ACARA_SERAH_TERIMA_KENDARAAN
				(
					user_id
					,report_company
					,report_title
					,report_image
					,report_address
					,client_type
					,pjb_no
					,hari_pjb
					,tanggal_pjb
					,direktur_name
					,buyer_name
					,buyer_address
					,client_name
					,client_address
					,client_direktur
					,jabatan_direktur
				)
				select	@p_user_id
						,@report_company
						,@report_title_detail
						,@report_image
						,@report_address
						,sd.buyer_type
						--,case
						--	when sd.buyer_type='COP' then cma.client_type
						--	else'CORPORATE'
						--end
						,sd.pjb_no --@code	output
						,case datename(dw, sd.sale_date)
							 when 'monday' then 'Senin'
							 when 'tuesday' then 'Selasa'
							 when 'wednesday' then 'Rabu'
							 when 'thursday' then 'Kamis'
							 when 'friday' then 'Jumat'
							 when 'saturday' then 'Sabtu'
							 when 'sunday' then 'Minggu'
						 end
						,sd.sale_date
						,upper(@nama)
						,upper(	  case
									  --when sell_type = 'COP' then ass.client_name
									  when sell_type = 'AUCTION' then ma.auction_name
									  else upper(sd.buyer_name)
								  end
							  )
						,case
							 --when sell_type = 'COP' then isnull(cad.address,'-')
							 when sell_type = 'AUCTION' then isnull(maa.address, '-')
							 else sd.buyer_address
						 end
						,case
							 when sd.buyer_type = 'PERSONAL' then sd.buyer_name
							 else upper(   case
											   --when sell_type = 'COP' then ass.client_name
											   when sell_type = 'AUCTION' then ma.auction_name
											   else upper(sd.buyer_signer_name)
										   end
									   )
						 end
						,case
							 --when sell_type = 'COP' then isnull(cad.address,'-')
							 when sell_type = 'AUCTION' then isnull(maa.address, '-')
							 else sd.buyer_address
						 end
						,case
							 when sd.buyer_type = 'PERSONAL' then sd.buyer_name
							 else upper(   case
											   --when sell_type = 'COP' then ass.client_name
											   when sell_type = 'AUCTION' then ma.auction_name
											   else upper(sd.buyer_signer_name)
										   end
									   )
						 end
						,@position_name
				from	dbo.sale_detail sd
						left join sale sa on (sa.code = sd.sale_code)
						left join dbo.asset ass on (ass.code = sd.asset_code)
						left join ifinopl.dbo.client_main cma on (cma.client_no = ass.CLIENT_NO)
						left join dbo.asset_vehicle av on (av.asset_code = ass.code)
						left join dbo.master_auction ma on (ma.code = sa.auction_code)
						left join dbo.master_auction_bank mab on (mab.auction_code = ma.code)
						left join dbo.master_auction_address maa on (maa.auction_code = ma.code)
						left join ifinopl.dbo.client_address cad on cad.client_code = ass.client_no
						left join ifinopl.dbo.CLIENT_RELATION cr on cr.client_code = cma.code
																	and cr.relation_type = 'SHAREHOLDER'
						outer apply
				(
					select		top 1
								full_name 'direktur_name'
					from		ifinopl.dbo.client_relation cri
					where		cri.client_code		  = cr.client_code
								and cri.full_name is not null
								and cri.relation_type = 'SHAREHOLDER'
					order by	cri.full_name desc
				) nama
				where	sd.id = @sell_id ;

				insert into dbo.rpt_pjb_bastk
				(
					user_id
					,hari
					,tanggal
					,sale_code
					,report_company
					,leased_object
					,year
					,chassis_no
					,plat_no
					,leesee_name
					,leesor_name
				)
				select	distinct
						@p_user_id
						,case datename(dw, sd.sale_date)
							 when 'monday' then 'Senin'
							 when 'tuesday' then 'Selasa'
							 when 'wednesday' then 'Rabu'
							 when 'thursday' then 'Kamis'
							 when 'friday' then 'Jumat'
							 when 'saturday' then 'Sabtu'
							 when 'sunday' then 'Minggu'
						 end
						,dbo.xfn_bulan_indonesia(sd.sale_date)
						,sa.code
						,@report_company
						,ass.item_name
						,av.built_year
						,av.chassis_no
						,av.plat_no
						,ass.client_name
						--,case
						--	 when sd.buyer_type = 'PERSONAL' then sd.buyer_name
						--	 else upper(   case
						--					   --when sell_type = 'COP' then ass.client_name
						--					   when sell_type = 'AUCTION' then ma.auction_name
						--					   else upper(sd.buyer_signer_name)
						--				   end
						--			   )
						-- end
						,upper(@nama)
				from	dbo.sale_detail sd
						left join sale sa on (sa.code = sd.sale_code)
						left join dbo.asset ass on (ass.code = sd.asset_code)
						left join ifinopl.dbo.client_main cma on (cma.client_no = ass.CLIENT_NO)
						left join dbo.asset_vehicle av on (av.asset_code = ass.code)
						left join dbo.master_auction ma on (ma.code = sa.auction_code)
						left join dbo.master_auction_bank mab on (mab.auction_code = ma.code)
						left join dbo.master_auction_address maa on (maa.auction_code = ma.code)
						left join ifinopl.dbo.client_address cad on cad.client_code = ass.client_no
						left join ifinopl.dbo.CLIENT_RELATION cr on cr.client_code = cma.code
																	and cr.relation_type = 'SHAREHOLDER'
						outer apply
				(
					select		top 1
								full_name 'direktur_name'
					from		ifinopl.dbo.client_relation cri
					where		cri.client_code		  = cr.client_code
								and cri.full_name is not null
								and cri.relation_type = 'SHAREHOLDER'
					order by	cri.full_name desc
				) nama
				where	sd.id = @sell_id ;

				select	@count_jumlah = count(user_id)
				from	dbo.RPT_CETAKAN_PJB 
				where	user_id = @p_user_id;

				if @count_jumlah>1
				begin
					update dbo.RPT_CETAKAN_PJB
					set NAMA_KENDARAAN = '(Terlampir)'
						,TAHUN_PEMBUATAN = '(Terlampir)'
						,JUMLAH_UNIT = '(Terlampir)'
						,ENGINE_NO = '(Terlampir)'
						,CHASSIS_NO = '(Terlampir)'
						,PLAT_NO = '(Terlampir)'
						,NO_BPKB = '(Terlampir)'
						,PRICE = '(Terlampir)'
					where user_id = @p_user_id ;
				end;

				--select	top 1
				--		@nama_leesee = leesee_name
				--from	dbo.rpt_pjb_bastk
				--where	user_id = @p_user_id ;

				select	@nama_leesee = ass.client_name
				from	sale_detail sd
						left join dbo.asset ass on (ass.code = sd.asset_code)
						left join dbo.sale s on (s.code		 = sd.sale_code)
				where	sd.id = @sell_id ;

				update	dbo.rpt_pjb_bastk
				set		leesee_name = @nama_leesee
				where	user_id = @p_user_id ;

			fetch next from cur_cetakan_pjb 
			into	@sell_id
			
		end
		close cur_cetakan_pjb
		deallocate cur_cetakan_pjb
		
		--if (@buyer_type = 'CORPORATE')
		--BEGIN
		--	declare c_asset cursor FOR
		--	select	ass.item_name			
		--				,av.built_year		
		--				,av.engine_no		
		--				,av.chassis_no		
		--				,av.plat_no			
		--				,av.bpkb_no			
		--	from		dbo.sale_detail sd
		--				left join dbo.asset ass on (ass.code = sd.asset_code)
		--				left join dbo.asset_vehicle av on (av.asset_code = ass.code)
		--	where		sd.sale_code = @p_sell_code
		--	--open cursor
		--	open	c_asset

		--	--fetch cursor
		--	fetch	c_asset
		--	into	@tipe_kendaraan
		--			,@built_year
		--			,@engine_no
		--			,@chassis_no
		--			,@plat_no
		--			,@bpkb_no

		--	while	@@fetch_status = 0
		--	BEGIN
			
		--	--set awal
		--		set @print_tipe_kendaraan	= ''
		--		set @print_built_year		= ''
		--		set @print_engine_no		= '' 
		--		set @print_chasis_no		= ''
		--		set @print_plat_no			= '' 
		--		set @print_bpkb_no			= ''
		--		set @print_no				= '' 
		--		set @no	+= 1

		--		--set dari fetch	
		--		set @print_tipe_kendaraan	= @tipe_kendaraan
		--		set @print_built_year		= @built_year
		--		set @print_engine_no		= @engine_no
		--		set @print_chasis_no		= @chassis_no
		--		set @print_plat_no			= @plat_no
		--		set @print_bpkb_no			= @bpkb_no
				

		--		--set data loopingan 
		--		set @print_no					= cast(@no as nvarchar(3)) 
		--		set @temp_no					= @temp_no + @print_no + char(10) + char(13) 

		--		set @temp_print_tipe_kendaraan	= @temp_print_tipe_kendaraan	+ @print_tipe_kendaraan	+ char(10) + char(13)
		--		set @temp_print_built_year		= @temp_print_built_year		+ @print_built_year		+ char(10) + char(13)
		--		set @temp_print_engine_no		= @temp_print_engine_no			+ @print_engine_no		+ char(10) + char(13)
		--		set @temp_print_chasis_no		= @temp_print_chasis_no			+ @print_chasis_no		+ char(10) + char(13)
		--		set @temp_print_plat_no			= @temp_print_plat_no			+ @print_plat_no		+ char(10) + char(13)	
		--		set @temp_print_bpkb_no			= @temp_print_bpkb_no			+ @print_bpkb_no		+ char(10) + char(13)	

		--	--fetch cursor
		--	fetch	c_asset
		--	into	@tipe_kendaraan
		--			,@built_year
		--			,@engine_no
		--			,@chassis_no
		--			,@plat_no
		--			,@bpkb_no
		--	END
		--	--close and deallocate cursor
		--	close		c_asset
		--	deallocate	c_asset
		--		select	@report_company										AS 'REPORT_COMPANY'
		--				,@report_address									AS 'REPORT_ADDRESS'
		--				,@temp_print_tipe_kendaraan							AS 'TIPE_KENDARAAN'
		--				,@temp_print_built_year								AS 'BUILT_YEAR'
		--				,@temp_print_engine_no								AS 'ENGINE_NO'
		--				,@temp_print_chasis_no								AS 'CHASSIS_NO'
		--				,@temp_print_plat_no								AS 'PLAT_NO'
		--				,@temp_print_bpkb_no								AS 'BPKB_NO'
		--				,@report_direktur									AS 'REPORT_DIREKTUR'
		--				,sd.buyer_name										AS 'BUYER_NAME'
		--				,sd.buyer_address									AS 'BUYER_ADDRESS'
		--				,sd.pjb_no											AS 'PJB_NO'
		--				,convert(nvarchar(30), sa.sale_date, 103)			AS 'TANGGAL_PJB'
		--				,SD.SOLD_AMOUNT										AS 'NILAI_JUAL'
		--				,@temp_no											as 'NO'
		--				--,SUM(SD.SOLD_AMOUNT)			AS 'TOTAL'
		--				,@jml_unit											as 'JUMLAH_KENDARAAN'
		--				,mab.bank_name										as 'BANK_NAME'
		--				,mab.bank_account_no								as 'BANK_ACC_NO'
		--				,mab.bank_account_name								as 'BANK_ACC_NAME'
		--	from		dbo.sale_detail sd
		--				left join sale sa on (sa.code = sd.sale_code)
		--				left join dbo.asset ass on (ass.code = sa.code)
		--				left join dbo.asset_vehicle av on (av.asset_code = ass.code)
		--				left join dbo.master_auction ma on (ma.code = sa.auction_code)
		--				left join dbo.master_auction_bank mab on (mab.auction_code = ma.code)
		--	where		sd.sale_code = @p_sell_code
		--end ;
		--else
		--begin
		--	select	
		--			@report_company								AS 'REPORT_COMPANY'
		--			,@report_address							AS 'REPORT_ADDRESS'
		--			,ass.item_name								AS 'TIPE_KENDARAAN'
		--			,av.built_year								AS 'BUILT_YEAR'
		--			,av.engine_no								AS 'ENGINE_NO'
		--			,av.chassis_no								AS 'CHASSIS_NO'
		--			,av.plat_no									AS 'PLAT_NO'
		--			,av.bpkb_no									AS 'BPKB_NO'
		--			,@report_direktur							AS 'REPORT_DIREKTUR'
		--			,sd.buyer_name								AS 'BUYER_NAME'
		--			,sd.buyer_address							AS 'BUYER_ADDRESS'
		--			,sd.pjb_no									AS 'PJB_NO'
		--			,convert(nvarchar(30), sa.sale_date, 103)	AS 'TANGGAL_PJB'
		--			,SD.SOLD_AMOUNT								as 'NILAI_JUAL'
		--			,ass.purchase_price							as  'HARGA_KENDARAAN'
		--			,@jml_unit									as 'JUMLAH_KENDARAAN'
		--			,mab.bank_name								as 'BANK_NAME'
		--			,mab.bank_account_no						as 'BANK_ACC_NO'
		--			,mab.bank_account_name						as 'BANK_ACC_NAME'
		--	from	dbo.sale_detail sd
		--			left join sale sa on (sa.code = sd.sale_code)
		--			left join dbo.asset ass on (ass.code = sd.asset_code)
		--			left join dbo.asset_vehicle av on (av.asset_code = ass.code)
		--			left join dbo.master_auction ma on (ma.code = sa.auction_code)
		--			left join dbo.master_auction_bank mab on (mab.auction_code = ma.code)
		--	where	sd.sale_code = @p_sell_code ;
		--END;
		
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

