CREATE PROCEDURE dbo.xsp_mtn_change_asset_unit_name
(
	@p_asset_code		nvarchar(50)
	,@p_application_no	nvarchar(50)
	,@p_agreement_no	nvarchar(50)
	,@p_unit_name		nvarchar(max)
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

			select	'BEFORE Asset'
					,code
					,item_name
			from	ifinams.dbo.asset
			where	code = @p_asset_code

			select	'BEFORE Asset Vehicle'
					,asset_code
					,type_item_name
			from	ifinams.dbo.asset_vehicle
			where	asset_code = @p_asset_code

			select	'BEFORE Application Asset'
					,fa_code
					,asset_name 
			from	dbo.application_asset
			where	fa_code = @p_asset_code

			select	'BEFORE Agreement Asset'
					,fa_code
					,asset_name 
			from	dbo.agreement_asset
			where	fa_code = @p_asset_code

			select	'BEFORE Fixed Asset'
					,asset_no
					,asset_name 
			from	ifindoc.dbo.fixed_asset_main
			where	asset_no = @p_asset_code

			update	ifinams.dbo.asset
			set		item_name = @p_unit_name
					,mod_date = @mod_date
					,mod_by = @mod_by
					,mod_ip_address = @mod_ip_address
			where	code = @p_asset_code

			update	ifinams.dbo.asset_vehicle
			set		type_item_name = @p_unit_name
					,mod_date = @mod_date
					,mod_by = @mod_by
					,mod_ip_address = @mod_ip_address
			where	asset_code = @p_asset_code

			update	ifinopl.dbo.application_asset
			set		asset_name = @p_unit_name
					,mod_date = @mod_date
					,mod_by = @mod_by
					,mod_ip_address = @mod_ip_address
			where	fa_code = @p_asset_code

			update	ifinopl.dbo.agreement_asset
			set		asset_name = @p_unit_name
					,mod_date = @mod_date
					,mod_by = @mod_by
					,mod_ip_address = @mod_ip_address
			where	fa_code = @p_asset_code

			update	ifindoc.dbo.fixed_asset_main
			set		asset_name = @p_unit_name
					,mod_date = @mod_date
					,mod_by = @mod_by
					,mod_ip_address = @mod_ip_address
			where	asset_no = @p_asset_code


			select	'AFTER Asset'
					,code
					,item_name
			from	ifinams.dbo.asset
			where	code = @p_asset_code

			select	'AFTER Asset Vehicle'
					,asset_code
					,type_item_name
			from	ifinams.dbo.asset_vehicle
			where	asset_code = @p_asset_code

			select	'AFTER Application Asset'
					,fa_code
					,asset_name 
			from	dbo.application_asset
			where	fa_code = @p_asset_code

			select	'AFTER Agreement Asset'
					,fa_code
					,asset_name 
			from	dbo.agreement_asset
			where	fa_code = @p_asset_code

			select	'AFTER Fixed Asset'
					,asset_no
					,asset_name 
			from	ifindoc.dbo.fixed_asset_main
			where	asset_no = @p_asset_code


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
				'MTN CHANGE NAME ASSET UNIT'
				,@p_mtn_remark
				,'ASSET'
				,@p_asset_code
				,@p_agreement_no -- REFF_2 - nvarchar(50)
				,@p_application_no -- REFF_3 - nvarchar(50)
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
