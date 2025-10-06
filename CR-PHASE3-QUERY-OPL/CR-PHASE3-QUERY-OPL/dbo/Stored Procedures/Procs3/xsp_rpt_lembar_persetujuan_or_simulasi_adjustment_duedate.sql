CREATE PROCEDURE [dbo].[xsp_rpt_lembar_persetujuan_or_simulasi_adjustment_duedate]
(
	@p_user_id						nvarchar(50)
	,@p_adjustment_duedate_no		nvarchar(50)
)
as
begin 

		declare @msg								nvarchar(max)
				,@report_company					nvarchar(250)
				,@report_title						nvarchar(250)
				,@report_image						nvarchar(250)
		        ,@agreement_no						nvarchar(50)
		        ,@kota								nvarchar(50)
		        ,@tanggal							datetime
		        ,@nama_client						nvarchar(250)
		        ,@tgl_adjustment_duedate			datetime
		        ,@os_principal						decimal(18,2)
		        ,@tgl_angsuran						datetime
		        ,@angsuran							decimal(18,2)
		        ,@tenor								int
		        ,@bunga								decimal(18,2)
		        ,@biaya_administrasi				decimal(18,2)
		        ,@bunga_berjalan					decimal(18,2) = 0
		        ,@outstanding_angsuran				decimal(18,2)
		        ,@denda_keterlambatan				decimal(18,2)
		        ,@kekurangan_asuransi				decimal(18,2)
		        ,@biaya_lain_lain					decimal(18,2)
		        ,@total_pembayaran					decimal(18,2)
		        ,@nama_bank_perusahaan				nvarchar(50)
		        ,@atas_nama_rekening_perusahaan		nvarchar(50)
		        ,@nomor_rekening_perusahaan			nvarchar(50)
		        ,@nama_branch_manager				nvarchar(50) = ''
				,@rental_amount						decimal(18, 2)
				,@penambahan_bulan					int
				,@akhir_periode						DATETIME
				,@protate_awal						DECIMAL(18,2)
				,@protate_akhir						DECIMAL(18,2)	
				,@asset_no							NVARCHAR(50)
				,@asset_name						NVARCHAR(50)
				,@reff_no							NVARCHAR(10)	
				,@end_periode						datetime
				,@date_day							datetime
				--
				,@datetimeNow						datetime = getdate();

	begin try

		delete	dbo.rpt_lembar_persetujuan_or_simulasi_adjustment_duedate	
		where	user_id = @p_user_id

		delete dbo.rpt_lembar_persetujuan_or_simulasi_adjustment_duedate_detail
		where	user_id = @p_user_id

		set	@report_title = 'PERSETUJUAN PERUBAHAN TANGGAL PENAGIHAN'	

		select	@report_company = value 
		from	dbo.sys_global_param
		where	code = 'COMP2'	
		
		select	@report_image = value 
		from	dbo.sys_global_param
		where	code = 'IMGDSF'		

		select	@kota = value 
		from	dbo.sys_global_param
		where	code = 'COMCITY'	

		set		@tanggal = @datetimeNow
		

		select	@nama_bank_perusahaan				= isnull(sbk.description,'-')
				,@atas_nama_rekening_perusahaan		= isnull(sbb.bank_account_name,'-')
				,@nomor_rekening_perusahaan			= isnull(sbb.bank_account_no,'-')				
		from	ifinsys.dbo.sys_branch sb with(nolock)
				inner join ifinsys.dbo.sys_city sc with(nolock) on (sc.code = sb.city_code)
				inner join ifinsys.dbo.sys_branch_bank sbb with(nolock) on (sbb.branch_code = sb.code)
				inner join ifinsys.dbo.sys_bank sbk with(nolock) on (sbk.code = sbb.master_bank_code)
		where	sb.code = '0000'
		
		select	@agreement_no				= isnull(am.agreement_external_no,'-')
				,@nama_client				= isnull(am.client_name,'-')
				,@tgl_adjustment_duedate	= ddc.change_date
				,@angsuran					= isnull(ddc.change_amount,0)	
				,@rental_amount				= ai.os_rental_amount
				,@akhir_periode				= max(aaa.due_date)
				,@penambahan_bulan			= datediff(month, ddcd.new_due_date_day, aaa.due_date)
		from	dbo.due_date_change_main ddc with(nolock)
				inner join due_date_change_detail ddcd on ddc.code = ddcd.due_date_change_code
				inner join dbo.agreement_main am with(nolock) on (am.agreement_no = ddc.agreement_no)
				inner join dbo.agreement_information ai on ai.agreement_no = am.agreement_no
				inner join dbo.agreement_asset_amortization aaa on aaa.agreement_no = am.agreement_no
		where	ddc.code = @p_adjustment_duedate_no
		group by isnull(am.agreement_external_no,'-')
				 ,isnull(am.client_name,'-')
				 ,ddc.change_date
				 ,isnull(ddc.change_amount,0)	
				 ,ai.os_rental_amount
				 ,aaa.due_date
				 ,ddcd.new_due_date_day

		set @total_pembayaran = @biaya_administrasi + @bunga_berjalan + @outstanding_angsuran + @denda_keterlambatan + @kekurangan_asuransi + @biaya_lain_lain

		/* insert into table report */
		insert into dbo.rpt_lembar_persetujuan_or_simulasi_adjustment_duedate
		(
			user_id
			,report_company
			,report_title
			,report_image
			,adjustment_duedate_no
			,agreement_no
			,kota
			,tanggal
			,nama_client
			,tgl_adjustment_duedate
			,rental_amount
			,penambahan
			,akhir_periode
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_user_id					-- USER_ID - nvarchar(50)
			,@report_company			-- REPORT_COMPANY - nvarchar(250)
			,@report_title				-- REPORT_TITLE - nvarchar(250)
			,@report_image				-- REPORT_IMAGE - nvarchar(250)
			,@p_adjustment_duedate_no	-- ADJUSTMENT_DUEDATE_NO - nvarchar(50)
			,@agreement_no				-- AGREEMENT_NO - nvarchar(50)
			,@kota						-- KOTA - nvarchar(50)
			,@tanggal					-- TANGGAL - datetime
			,@nama_client				-- NAMA_CLIENT - nvarchar(250)
			,@tgl_adjustment_duedate	-- TGL_ADJUSTMENT_DUEDATE - datetime
			,@rental_amount				-- RENTAL_AMOUNT - decimal(18, 2)
			,@penambahan_bulan			-- PENAMBAHAN - int
			,@akhir_periode				-- AKHIR_PERIODE - datetime
		    ,@datetimenow
			,@p_user_id
			,'127.0.0.1'
			,@datetimenow
			,@p_user_id 	
			,'127.0.0.1'
		)

		--(+) Raffyanda 11/10/2023 14.13.00.00 penambahan variabel penampung untuk mendapatkan installment no yang sesuai dengan new due date dan paling akhir
		DECLARE curr_lembar_persetujuan cursor fast_forward read_only FOR
		select DISTINCT 
				ags.ASSET_NO
				,ags.asset_name
				,ags.fa_reff_no_01
				,h.BILLING_AMOUNT
				,null
				,d.new_due_date_day
				,billing.BILLING_AMOUNT
				
		from	dbo.due_date_change_amortization_history h
				INNER join	dbo.due_date_change_detail d on d.due_date_change_code = h.due_date_change_code
				left join dbo.agreement_asset ags on (ags.asset_no					  = d.asset_no)
				OUTER APPLY
				(
					select top 1
					billing_amount
					from dbo.due_date_change_amortization_history dd
					where dd.due_date_change_code = @p_adjustment_duedate_no
					and dd.old_or_new = 'new'
					and	dd.asset_no = ags.asset_no
					order by installment_no desc
				) billing
		where	d.due_date_change_code = @p_adjustment_duedate_no
		and		d.is_change = '1'
		and		old_or_new = 'NEW'
		and		h.installment_no = d.at_installment_no
		and		h.asset_no = d.asset_no
		--group by ags.ASSET_NO
		--		 ,ags.asset_name
		--		 ,ags.fa_reff_no_01
		--		 ,billing.BILLING_AMOUNT
		--		 ,dcd.new_due_date_day
		--		 ,biling.prorate
        open curr_lembar_persetujuan ;

		FETCH next from curr_lembar_persetujuan

		INTO @asset_no
			,@asset_name
			,@reff_no
			,@protate_awal
			,@end_periode
			,@date_day
			,@protate_akhir
		while @@fetch_status = 0
		BEGIN

			insert into dbo.rpt_lembar_persetujuan_or_simulasi_adjustment_duedate_detail
			(
				user_id
				,asset_no
				,asset_name
				,plat_no
				,rental_amount
				,end_periode
				,date_adjustment_due_date
				,protate_rental_akhir
			) 
			VALUES
			(
				@p_user_id
				,@asset_no
				,@asset_name
				,@reff_no
				,@protate_awal
				,@end_periode
				,@date_day
				,@protate_akhir
			);

			
			
			FETCH NEXT FROM curr_lembar_persetujuan
			INTO @asset_no
				,@asset_name
				,@reff_no
				,@protate_awal
				,@end_periode
				,@date_day
				,@protate_akhir
		
		
		END;
		close curr_lembar_persetujuan ;
		DEALLOCATE curr_lembar_persetujuan ;
		--(+) Raffyanda 11/10/2023 14.13.00.00 penambahan variabel penampung untuk mendapatkan installment no yang sesuai dengan new due date dan paling akhir

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
