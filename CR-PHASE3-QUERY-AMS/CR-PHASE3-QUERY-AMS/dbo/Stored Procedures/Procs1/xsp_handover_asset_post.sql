--created, rian at 29/12/2022

CREATE PROCEDURE [dbo].[xsp_handover_asset_post]
(
	@p_code			   NVARCHAR(50)
	,@p_fa_code		   NVARCHAR(50)
	--
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
BEGIN
	declare @msg					nvarchar(max)
			,@type					nvarchar(20)
			,@status				nvarchar(10)
			,@reff_code				nvarchar(50)
			,@handover_date			datetime 
			,@handover_remark		nvarchar(4000)
			,@handover_status		nvarchar(10) 
			,@asset_status			nvarchar(15)
			,@asset_from			nvarchar(50)
			,@asset_type			nvarchar(50)
			,@agreement_no			nvarchar(50)
			,@agreement_external_no	nvarchar(50)
			,@client_name			nvarchar(250)
			,@client_no				nvarchar(50)
			,@asset_no				nvarchar(50)
			,@last_meter			int 
			,@condition				nvarchar(50)
			,@re_rent				nvarchar(10)

	BEGIN TRY
		SELECT	@type					= ha.type
				,@status				= ha.status
				,@handover_date			= ha.handover_date
				,@reff_code				= ha.reff_code
				,@handover_remark		= ha.remark
				,@asset_from			= ass.asset_from
				,@asset_type			= ass.asset_from
				,@agreement_no			= hr.agreement_no
				,@agreement_external_no	= hr.agreement_external_no
				,@client_name			= hr.client_name
				,@client_no				= hr.client_no
				,@asset_no				= hr.asset_no
				,@last_meter			= ha.km
				,@re_rent				= ass.re_rent_status
		from	dbo.handover_asset ha
		left join dbo.asset ass on (ha.fa_code = ass.code)
		left join dbo.handover_request hr on (hr.handover_code = ha.code)
		where	ha.code = @p_code ;

		--validasi handover date
		if (@handover_date is null)
		begin
			set @msg = 'Please Input Handover Date.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		--validasi checklist status dan checklist remark tidak boleh kosong
		--if exists
		--(
		--	select	1
		--	from	dbo.handover_asset_checklist
		--	where	handover_code		 = @p_code
		--			and checklist_status = ''
		--)
		--begin
		--	set @msg = 'Please input Asset Checklist Status.' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		--validasi tidak bisa post sebelum di print
		if (@type = 'DELIVERY' or @type = 'PICK UP')
		begin
			if not exists
			(
				select	1
				from	dbo.rpt_berita_acara_serah_terima
				where	bast_no		 = @p_code
						
			)
			begin
				set @msg = 'Please Print BAST first.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end
		
		--Validasi Kilometer jika condition used
		select @condition = condition
		from dbo.asset 
			inner join dbo.handover_asset on asset.code = handover_asset.fa_code
		where dbo.handover_asset.code = @p_code

		if (@condition = 'used') and (@last_meter = 0)
		begin
			set	@msg = 'km must be more than 0'
			raiserror(@msg, 16, -1) ;
		end

		--update status in table handover asset
		if (@status = 'HOLD')
		begin
			update	dbo.handover_asset
			set		status			= 'POST'
					,mod_date		= @p_mod_date	  
					,mod_by			= @p_mod_by		  
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @p_code ;
		end ;
		else
		begin
			set @msg = 'Data Already Post.' ;
			raiserror(@msg, 16, -1) ;
		end ;

		--saat unit masuk pembelian dari procurment
		if (@type = 'RECEIVE')
		begin
			update	dbo.asset
			set		fisical_status	= 'ON HAND'
					,last_meter		= @last_meter
					,rental_status	= ''
					,monitoring_status = ''
					,mod_date		= @p_mod_date	  
					,mod_by			= @p_mod_by		  
					,mod_ip_address	= @p_mod_ip_address
			where	code = @p_fa_code ;

			set @asset_status = 'STOCK'
		end ;

		--saat unit dikirim ke custumer untuk disewakan
		if (@type = 'DELIVERY')
		begin
			
			if (@handover_date <
				(
					select	ai.maturity_date
					from		ifinopl.dbo.agreement_information ai
							inner join ifinopl.dbo.agreement_asset aa on (aa.agreement_no = ai.agreement_no)
					where	isnull(fa_code, replacement_fa_code) = @p_fa_code
							and asset_status					 = 'RENTED'
				)
				)
			begin
				select	@msg = N'Handover Date Must be More than or Equal to Maturity Date : ' + convert(nvarchar(15), ai.maturity_date, 103)
				from		ifinopl.dbo.agreement_information ai
						inner join ifinopl.dbo.agreement_asset aa on (aa.agreement_no = ai.agreement_no)
				where	isnull(fa_code, replacement_fa_code) = @p_fa_code
						and asset_status					 = 'RENTED' 

				raiserror(@msg, 16, -1) ;
			end ;

			
			if exists
			(
				select	1
				from	ifinopl.dbo.agreement_asset
				where	isnull(fa_code, replacement_fa_code) = @p_fa_code
						and asset_status					 = 'RENTED'
			)
			begin
				select	@msg = N'Asset still Rented at Agreement : ' + replace(am.agreement_no, '.', '/') + N' Client : ' + am.client_name
				from	ifinopl.dbo.agreement_asset aa
						inner join ifinopl.dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
				where	isnull(fa_code, replacement_fa_code) = @p_fa_code
						and asset_status					 = 'RENTED' ;

				raiserror(@msg, 16, -1) ;
			end

			if(@asset_type = 'BUY')
			begin
				update	dbo.asset
				set		fisical_status			= 'ON CUSTOMER'
						,rental_status			= 'IN USE'
						,agreement_no			= @agreement_no
						,agreement_external_no	= @agreement_external_no
						,client_name			= @client_name
						,client_no				= @client_no
						,is_rental				= '1'
						,asset_no				= @asset_no
						,last_meter				= @last_meter
						,re_rent_status			= null
						--
						,mod_date				= @p_mod_date	  
						,mod_by					= @p_mod_by		  
						,mod_ip_address			= @p_mod_ip_address
				where	code					= @p_fa_code ;

				-- hari - 06.jul.2023 08:06 pm --	jika belum di update in use spaf nya , maka di update sebagai use
				if exists
				(
					select	1
					from	dbo.asset
					where	code			= @p_fa_code
							and is_spaf_use = '0'
				)
				begin
					update	dbo.asset
					set		is_spaf_use = '1'
					where	code			= @p_fa_code
							and is_spaf_use = '0' ;
				end ;

				SET @asset_status = 'STOCK'
			end
			else
			begin
				update	dbo.asset
				set		fisical_status			= 'ON CUSTOMER'
						,rental_status			= 'GTS'
						,is_rental				= '1'
						,agreement_no			= @agreement_no
						,agreement_external_no	= @agreement_external_no
						,client_no				= @client_no
						,client_name			= @client_name
						,asset_no				= @asset_no
						,last_meter				= @last_meter
						--
						,mod_date				= @p_mod_date	  
						,mod_by					= @p_mod_by		  
						,mod_ip_address			= @p_mod_ip_address
				where	code					= @p_fa_code ;
				set @asset_status = 'REPLACEMENT'
			end

			update	dbo.asset_insurance
			set		agreement_external_no	= @agreement_external_no
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	asset_code				= @p_fa_code
					and asset_no			= @asset_no ;
		end ;

		--jika type nya replace in
		if (@type = 'REPLACE IN') -- penarikan unit utama
		begin
			update	dbo.asset
			set		fisical_status = 'ON HAND'
					,monitoring_status = ''
					,last_meter		= @last_meter
					,mod_date		= @p_mod_date	  
					,mod_by			= @p_mod_by		  
					,mod_ip_address	= @p_mod_ip_address
			where	code = @p_fa_code ;
			set @asset_status = 'STOCK'
		end ;

		--jika type nya replace out
		if (@type = 'REPLACE OUT') --pengeluaran unit pengganti
		begin
			update	dbo.asset
			set		fisical_status			= 'ON CUSTOMER'
					,rental_status			= 'REPLACEMENT'
					,agreement_no			= @agreement_no
					,agreement_external_no	= @agreement_external_no
					,client_no				= @client_no
					,client_name			= @client_name
					,asset_no				= @asset_no
					,last_meter				= @last_meter
					,mod_date				= @p_mod_date	  
					,mod_by					= @p_mod_by		  
					,mod_ip_address			= @p_mod_ip_address
			where	code = @p_fa_code ;

			set @asset_status = 'REPLACEMENT'
		end ;

		--jika type nya replace gts in
		if (@type = 'REPLACE GTS IN') -- penarikan unit gts
		begin
			update	dbo.asset
			set		fisical_status			= 'ON HAND'
					,rental_status			= ''
					,monitoring_status = ''
					,agreement_no			= null
					,agreement_external_no	= null
					,client_no				= null
					,client_name			= null
					,asset_no				= null
					,last_meter				= @last_meter
					,mod_date				= @p_mod_date	  
					,mod_by					= @p_mod_by		  
					,mod_ip_address			= @p_mod_ip_address
			where	code = @p_fa_code ;
			set @asset_status = 'REPLACEMENT'
		end ;

		--jika type nya replace gts out
		if (@type = 'REPLACE GTS OUT') --pengeluaran unit utama
		begin
			update	dbo.asset
			set		fisical_status			= 'ON CUSTOMER'
					,rental_status			= 'IN USE'
					,agreement_no			= @agreement_no
					,agreement_external_no	= @agreement_external_no
					,client_no				= @client_no
					,client_name			= @client_name
					,asset_no				= @asset_no
					,last_meter				= @last_meter
					,mod_date				= @p_mod_date	  
					,mod_by					= @p_mod_by		  
					,mod_ip_address			= @p_mod_ip_address
			where	code = @p_fa_code ;

			--(+) Raffy 2024/10/11 jika make asset gts, maka asset code nya diupdate buat asset utamanya, Budget insurance hanya untuk aasset utama, tidak untuk gts
			update	dbo.asset_insurance
			set		asset_code				= @p_fa_code
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	asset_code				= @p_fa_code
					and asset_no			= @asset_no ;

			set @asset_status = 'STOCK'
		end ;

		--jika type nya return in
		if (@type = 'RETURN IN') --penarikan unit pengganti
		begin
			update	dbo.asset
			set		fisical_status			= 'ON HAND'
					,rental_status			= ''
					,monitoring_status = ''
					,agreement_no			= null
					,agreement_external_no	= null
					,client_no				= null
					,client_name			= null
					,asset_no				= null
					,last_meter				= @last_meter
					,mod_date				= @p_mod_date	  
					,mod_by					= @p_mod_by		  
					,mod_ip_address			= @p_mod_ip_address
			where	code = @p_fa_code ;
			set @asset_status = 'REPLACEMENT'
		end ;

		--jika type nya return out
		if (@type = 'RETURN OUT') --pengembalian unit utama
		begin
			update	dbo.asset
			set		fisical_status			= 'ON CUSTOMER'
					,rental_status			= 'IN USE'
					,agreement_no			= @agreement_no
					,agreement_external_no	= @agreement_external_no
					,client_no				= @client_no
					,client_name			= @client_name
					,asset_no				= @asset_no
					,last_meter				= @last_meter
					,mod_date				= @p_mod_date	  
					,mod_by					= @p_mod_by		  
					,mod_ip_address			= @p_mod_ip_address
			where	code = @p_fa_code ;

			set @asset_status = 'STOCK'
		end
		
		--jika type nya pickup, penarikan unit saat kontrak sudah lunas
		if (@type = 'PICK UP')
		begin
			if(isnull(@re_rent,'') = '' or @re_rent = 'NOT')
			begin
				update	dbo.asset
				set		fisical_status			= 'ON HAND'
						,rental_status			= ''
						,monitoring_status = ''
						,agreement_no			= null
						,agreement_external_no	= null
						,client_no				= null
						,client_name			= null
						,asset_no				= null
						,last_meter				= @last_meter
						,re_rent_status			= NULL
                        ,condition				= 'USED' --raffy 2025/08/20 Jika asset sudah digunakan pada agreement, maka statusnya jadi USED 
						--
						,mod_date				= @p_mod_date	  
						,mod_by					= @p_mod_by		  
						,mod_ip_address			= @p_mod_ip_address
				where	code = @p_fa_code ;


				set @asset_status = 'STOCK'
			end
		end ;

		if (@type = 'RENT RETURN')
		begin
			update	dbo.asset
			set		status					= 'RETURNED'
					,fisical_status			= 'RETURNED'
					,rental_status			= ''
					,agreement_no			= null
					,agreement_external_no	= null
					,client_no				= null
					,client_name			= null
					,asset_no				= null
					,last_meter				= @last_meter
					,mod_date				= @p_mod_date	  
					,mod_by					= @p_mod_by		  
					,mod_ip_address			= @p_mod_ip_address
			where	code = @p_fa_code ;
		end

		update	dbo.ams_interface_handover_asset
		set		status				= 'POST'
				,handover_code		= @p_code
				,handover_bast_date = @handover_date
				,handover_remark	= @handover_remark
				,handover_status	= 'POST'
				,asset_status		= @asset_status
				--
				,mod_date			= @p_mod_date	  
				,mod_by				= @p_mod_by		  
				,mod_ip_address		= @p_mod_ip_address
		where	reff_no				= @reff_code 
		and		fa_code				= @p_fa_code;
	end try
	begin catch
        DECLARE @error INT = @@ERROR;

        IF (@error = 2627)
        BEGIN
            SET @msg = dbo.xfn_get_msg_err_code_already_exist();
        END;

        IF (LEN(@msg) <> 0)
        BEGIN
            SET @msg = N'V;' + @msg;
        END
        ELSE IF (LEFT(ERROR_MESSAGE(), 2) = 'V;')
        BEGIN
            SET @msg = ERROR_MESSAGE();
        END
        ELSE
        BEGIN
            SET @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + ERROR_MESSAGE();
        END

        RAISERROR(@msg, 16, -1);
        RETURN;
	end catch ;	
end ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_handover_asset_post] TO [ims-raffyanda]
    AS [dbo];

