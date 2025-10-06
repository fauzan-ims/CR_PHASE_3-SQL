CREATE procedure [dbo].[rpt_keuntungan_kerugian_penjualan_aset]
as
begin
	declare @category_code		   nvarchar(50)
			,@category_name		   nvarchar(250)
			,@biaya_perolehan	   decimal(18, 2)
			,@akumulasi_penyusutan decimal(18, 2)
			,@nilai_buku_neto	   decimal(18, 2)
			,@harga_jual		   decimal(18, 2)
			,@cre_date			   datetime		= getdate()
			,@cre_by			   nvarchar(15) = N'system'
			,@cre_ip_address	   nvarchar(15) = N'10.0.0.0' ;

	declare @tamp_table table
	(
		category_code		  nvarchar(50)
		,category_name		  nvarchar(250)
		,biaya_perolehan	  decimal(18, 2)
		,akumulasi_penyusutan decimal(18, 2)
		,nilai_buku_neto	  decimal(18, 2)
		,harga_jual			  decimal(18, 2)
		,untung_rugi		  decimal(18, 2)
	) ;

	delete dbo.rpt_keuntungan_kerugian_penjualan_aset_list_summary

	declare cursor_name cursor fast_forward read_only for
	select		a.category_code
				,a.category_name
	from		dbo.sale_detail		 sd
				inner join dbo.sale	 s on s.code = sd.sale_code
				inner join dbo.asset a on a.code = sd.asset_code
	where		s.STATUS = 'POST'
	group by	a.category_code
				,a.category_name ;

	open cursor_name ;

	fetch next from cursor_name
	into @category_code
		 ,@category_name ;

	while @@fetch_status = 0
	begin
		select	@biaya_perolehan	   = sum(isnull(a.purchase_price, 0))
				,@akumulasi_penyusutan = sum(isnull(sc.accum_depre_amount, 0))
				,@nilai_buku_neto	   = sum(sd.net_book_value)
				,@harga_jual		   = sum(sd.sale_value)
		from	dbo.sale_detail		 sd
				inner join dbo.sale	 s on s.code = sd.sale_code
				inner join dbo.asset a on a.code = sd.asset_code
				outer apply
							(
								select	top 1
										accum_depre_amount
								from	dbo.asset_depreciation_schedule_commercial
								where	asset_code = sd.asset_code
							)							 sc
		where	s.status			= 'POST'
				and a.category_code = @category_code ;

		insert	@tamp_table
		(
			category_code
			,category_name
			,biaya_perolehan
			,akumulasi_penyusutan
			,nilai_buku_neto
			,harga_jual
			,untung_rugi
		)
		values
		(
			@category_code
			,@category_name
			,@biaya_perolehan
			,@akumulasi_penyusutan
			,@nilai_buku_neto
			,@harga_jual
			,@harga_jual - @nilai_buku_neto
		) ;

		insert into dbo.rpt_keuntungan_kerugian_penjualan_aset_list_summary
		(
			user_id
			,deskripsi
			,biaya_perolehan
			,akumulasi_penyusutan
			,nilai_buku_neto
			,harga_jual
			,keuntungan_kerugian
			,total
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			'admin'
			,@category_name
			,@biaya_perolehan
			,@akumulasi_penyusutan
			,@nilai_buku_neto
			,@harga_jual
			,@harga_jual - @nilai_buku_neto
			,0
			,@cre_date
			,@cre_by
			,@cre_ip_address
			,@cre_date
			,@cre_by
			,@cre_ip_address
		) ;

		fetch next from cursor_name
		into @category_code
			 ,@category_name ;
	end ;

	close cursor_name ;
	deallocate cursor_name ;

	insert into dbo.rpt_keuntungan_kerugian_penjualan_aset_list_summary
	(
		user_id
		,deskripsi
		,biaya_perolehan
		,akumulasi_penyusutan
		,nilai_buku_neto
		,harga_jual
		,keuntungan_kerugian
		,total
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
	)
	select	'admin'
			,'Total'
			,sum(biaya_perolehan)
			,sum(akumulasi_penyusutan)
			,sum(nilai_buku_neto)
			,sum(harga_jual)
			,sum(untung_rugi)
			,0
			,@cre_date
			,@cre_by
			,@cre_ip_address
			,@cre_date
			,@cre_by
			,@cre_ip_address
	from	@tamp_table ;

	select	user_id
			,deskripsi
			,biaya_perolehan
			,akumulasi_penyusutan
			,nilai_buku_neto
			,harga_jual
			,keuntungan_kerugian
			,total
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
	from	rpt_keuntungan_kerugian_penjualan_aset_list_summary ;
end ;
