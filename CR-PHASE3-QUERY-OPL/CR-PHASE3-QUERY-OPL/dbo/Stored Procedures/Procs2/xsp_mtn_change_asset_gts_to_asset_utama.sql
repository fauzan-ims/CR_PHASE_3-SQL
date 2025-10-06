CREATE PROCEDURE dbo.xsp_mtn_change_asset_gts_to_asset_utama
(
	@p_agreement_no		nvarchar(50)
	,@p_asset_code_new	nvarchar(50)
	,@p_asset_code_gts	nvarchar(50)
	 --
   ,@p_mtn_remark		nvarchar(4000)
   ,@p_mtn_cre_by		nvarchar(250)
)
as
begin
	begin try
		begin transaction ;

			declare @agreement_ext		nvarchar(50)
					,@asset_name		nvarchar(250)
					,@asset_year		nvarchar(4)
					,@fa_name			nvarchar(250)
					,@plat_no			nvarchar(50)
					,@chassis_no		nvarchar(50)
					,@engine_no			nvarchar(50)
					,@msg				nvarchar(4000)
					,@asset_no			nvarchar(50)
					,@client_no			nvarchar(50)
					,@client_name		nvarchar(250)
					,@mod_by			nvarchar(15) = 'MAINTENANCE'
					,@mod_date			datetime = dbo.xfn_get_system_date()
					,@mod_ip_address	nvarchar(15) = '127.0.0.1'


			set @p_agreement_no = replace(@p_agreement_no,'/','.')
			set @agreement_ext = replace(@p_agreement_no,'.','/')

			if((isnull(@p_mtn_remark, '') = '' or isnull(@p_mtn_cre_by,'') = ''))
			begin
				set @msg = 'MTN Remark/Cre by harus Terisi Sesuai yang di Maintenance';
				raiserror(@msg, 16, 1) ;
				return
			end ;

			if exists (select 1 from ifinams.dbo.asset where code = @p_asset_code_new  and (isnull(agreement_external_no,'') <> '' or isnull(agreement_no,'') <> ''))
			begin
				set @msg = 'Asset telah menempel pada kontrak lain'
				raiserror(@msg, 16, -1)
				return
			end
			else if exists (select 1 from ifinopl.dbo.agreement_asset where fa_code = @p_asset_code_new and asset_status = 'RENTED')
			begin
				set @msg = 'Asset telah dipakai oleh kontrak lain'
				raiserror(@msg, 16, -1)
				return
				end
				else if exists (select 1 from ifinopl.dbo.agreement_asset where agreement_no = @p_agreement_no and fa_code = @p_asset_code_gts and asset_status = 'RETURN')
			begin
				set @msg = 'Agreement Asset sudah RETURN'
				raiserror(@msg, 16, -1)
				return
			end 

			select	'BEFORE'
					,code
					,agreement_external_no
					,agreement_no
					,asset_no
					,client_no
					,client_name
					,status
					,fisical_status 
			from	ifinams.dbo.asset
			where	code in (@p_asset_code_new,@p_asset_code_gts)

			
			select	@asset_name = merk_name + '-' + type_item_name 
					,@asset_year = built_year
					,@fa_name = type_item_name
					,@plat_no = plat_no
					,@chassis_no = chassis_no
					,@engine_no = engine_no
			from	ifinams.dbo.asset_vehicle
			where	asset_code = @p_asset_code_new

			select	@asset_no = asset_no 
					,@client_no = am.client_no
					,@client_name = am.client_name
			from	ifinopl.dbo.agreement_asset aa
			inner	join ifinopl.dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
			where	aa.agreement_no = @p_agreement_no
			and		fa_code = @p_asset_code_gts

			update	ifinopl.dbo.agreement_asset
			set		fa_code = @p_asset_code_new
					,asset_name = @asset_name
					,asset_year = @asset_year
					,fa_name = @fa_name
					,fa_reff_no_01 = @plat_no
					,fa_reff_no_02 = @chassis_no
					,fa_reff_no_03 = @engine_no
					,mod_date = @mod_date
					,mod_by = @mod_by
					,mod_ip_address = @mod_ip_address
			where	agreement_no = @p_agreement_no
			and		fa_code = @p_asset_code_gts

			update	ifinams.dbo.asset
			set		agreement_external_no = null
					,agreement_no = null
					,asset_no = null
					,client_no = null
					,client_name = null
					,fisical_status = 'ON HAND'
					,mod_date = @mod_date
					,mod_by = @mod_by
					,mod_ip_address = @mod_ip_address
			where	code = @p_asset_code_gts


			update	ifinams.dbo.asset
			set		agreement_external_no = @agreement_ext
					,agreement_no = @p_agreement_no
					,asset_no = @asset_no
					,client_no = @client_no
					,client_name = @client_name
					,fisical_status = 'ON CUSTOMER'
					,mod_date = @mod_date
					,mod_by = @mod_by
					,mod_ip_address = @mod_ip_address
			where	code = @p_asset_code_new


			select	'AFTER'
					,code
					,agreement_external_no
					,agreement_no
					,asset_no
					,client_no
					,client_name
					,status
					,fisical_status 
			from	ifinams.dbo.asset
			where	code in (@p_asset_code_new,@p_asset_code_gts)

			select	fa_code
					,asset_no
					,asset_status
			from	ifinopl.dbo.agreement_asset
			where	agreement_no in 
									(
										@p_agreement_no
									)
			and		fa_code = @p_asset_code_new

			


			insert into dbo.mtn_data_dsf_log
			(
				maintenance_name
				,remark
				,tabel_utama
				,reff_1
				,reff_2
				,reff_3
				,cre_date
				,cre_by
			)
			values
			(
				'MTN CHANGE ASSET GTS TO ASSET UTAMA'
				,@p_mtn_remark
				,'ASSET'
				,@p_asset_code_gts
				,@p_asset_code_new -- REFF_2 - nvarchar(50)
				,@p_agreement_no -- REFF_3 - nvarchar(50)
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
