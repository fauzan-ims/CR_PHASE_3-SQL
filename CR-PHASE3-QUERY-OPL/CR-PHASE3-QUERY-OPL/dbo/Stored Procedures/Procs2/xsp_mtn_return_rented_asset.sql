CREATE PROCEDURE dbo.xsp_mtn_return_rented_asset
(
	@p_agreement_no		nvarchar(50)
	,@p_plat_no			nvarchar(50)
	,@p_chassis_no		nvarchar(50)
	 --
   ,@p_mtn_remark		nvarchar(4000)
   ,@p_mtn_cre_by		nvarchar(250)
)
as
begin
	begin try
		begin transaction ;

			declare @msg						nvarchar(max)
					,@agreement_no				nvarchar(50) = replace(@p_agreement_no,'/','.')
					,@agreement_ext				nvarchar(50)
					,@client_no					nvarchar(50)
					,@client_name				nvarchar(50)
					,@fisical_status			nvarchar(50)
					,@rental_status				nvarchar(50)
					,@asset_no					nvarchar(50)
					,@fa_code					nvarchar(50)
					,@plat_no					nvarchar(50)
					,@chassis_no				nvarchar(50)
					,@engine_no					nvarchar(50)
					,@mod_date					datetime = dbo.xfn_get_system_date()
					,@mod_by					nvarchar(15) = 'MAINTENANCE'
					,@mod_ip_address			nvarchar(15) = '127.0.0.1'

			if((isnull(@p_mtn_remark, '') = '' or isnull(@p_mtn_cre_by,'') = ''))
			begin
				set @msg = 'MTN Remark/Cre by harus Terisi Sesuai yang di Maintenance';
				raiserror(@msg, 16, 1) ;
				return
			end ;

			select	@agreement_no = aa.agreement_no
					,@agreement_ext = replace(aa.agreement_no,'.','/')
					,@asset_no = asset_no 
					,@client_no = am.client_no
					,@client_name = am.client_name
					,@fa_code = aa.fa_code
			from	dbo.agreement_asset aa
			inner	join dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
			where	aa.agreement_no = @agreement_no
			and		fa_reff_no_01 = @p_plat_no
			and		fa_reff_no_02 = @p_chassis_no


			if exists
			(
				select	1
				from	ifinams.dbo.asset aa
				inner	join ifinams.dbo.asset_vehicle av on (av.asset_code = aa.code)
				where	agreement_no	<> @agreement_no
						and (
								av.plat_no		<>		@p_plat_no
							or	av.chassis_no	<>		@p_chassis_no	
							)
						and	aa.code = @fa_code	
			)
			begin
				set @msg = 'Asset sudah terdaftar dengan kontrak lain atau nomor plat/chassis berbeda';
				raiserror(@msg, 16, 1) ;
				return
			end 

			update	ifinams.dbo.asset
			set		agreement_no = @agreement_no
					,agreement_external_no = @agreement_ext
					,asset_no = @asset_no
					,client_no = @client_no
					,client_name = @client_name
					,status = 'STOCK'
					,FISICAL_STATUS = 'ON CUSTOMER'
			where	code = @fa_code

			update	dbo.agreement_asset
			set		ASSET_STATUS = 'RENTED'
			where	agreement_no = @agreement_no
			and		fa_reff_no_01 = @p_plat_no
			and		fa_code = @fa_code

			INSERT INTO dbo.MTN_DATA_DSF_LOG
			(
				MAINTENANCE_NAME
				,REMARK
				,TABEL_UTAMA
				,REFF_1
				,REFF_2
				,REFF_3
				,CRE_DATE
				,CRE_BY
			)
			values
			(
				'MTN RETURN - RENTED'
				,@p_mtn_remark
				,'ASSET'
				,@fa_code
				,@agreement_no -- REFF_2 - nvarchar(50)
				,@p_chassis_no -- REFF_3 - nvarchar(50)
				,getdate()
				,@p_mtn_cre_by
			)
	
			if @@error = 0
			begin
				select 'SUCCESS'
				commit transaction ;
			end ;
			else
			begin
				select 'GAGAL PROCESS : ' + @msg
				rollback transaction ;
			end

		end try
		begin catch
			select 'GAGAL PROCESS : ' + @msg
			rollback transaction ;
		end catch ;    
end
