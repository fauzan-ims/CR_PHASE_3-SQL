CREATE PROCEDURE dbo.xsp_mtn_document_main
(
	--@p_plat_no			nvarchar(50)
	@p_chassis_no		nvarchar(50)
	,@p_engine_no		nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(250)
	,@p_document_type	nvarchar(50)
	,@p_document_name	nvarchar(250)
	,@p_document_desc	nvarchar(4000)
	,@p_doc_no			nvarchar(50)
	,@p_received_date	datetime
	,@p_document_date	datetime
	 --
   ,@p_mtn_remark		nvarchar(4000)
   ,@p_mtn_cre_by		nvarchar(250)
)
as
begin
	begin try
		begin transaction ;

			declare	@msg						nvarchar(max)
					--,@agreement_no				nvarchar(50) = replace(@p_agreement_no,'/','.')
					,@branch_code				nvarchar(50)
					,@branch_name				nvarchar(250)
					,@asset_no					nvarchar(50)
					,@asset_name				nvarchar(250)
					,@mod_date					datetime = dbo.xfn_get_system_date()
					,@mod_by					nvarchar(15) = 'MAINTENANCE'
					,@mod_ip_address			nvarchar(15) = '127.0.0.1'

			if((isnull(@p_mtn_remark, '') = '' or isnull(@p_mtn_cre_by,'') = ''))
			begin
				set @msg = 'MTN Remark/Cre by harus Terisi Sesuai yang di Maintenance';
				raiserror(@msg, 16, 1) ;
				return
			end ;

			declare @p_code		nvarchar(50) 
					,@p_id		bigint 
					,@p_id2		bigint


			select	@asset_no = asset_code
					,@asset_name = type_item_name 
			from	ifinams.dbo.asset_vehicle
			where	--plat_no = @p_plat_no
					chassis_no = @p_chassis_no
			and		engine_no = @p_engine_no

			if exists(select 1 from dbo.document_main where asset_no = @asset_no and document_type = @p_document_type)
			begin
				set @msg = 'Document Asset sudah terdaftar pada document main';
				raiserror(@msg, 16, 1) ;
				return
			end
			else if exists(select 1 from dbo.replacement_request_detail where asset_no = @asset_no)
			begin
				set @msg = 'Document Asset sudah terdaftar pada replacement request detail';
				raiserror(@msg, 16, 1) ;
				return
			end


			if(@p_document_type = 'BPKB')
			begin
			
				exec dbo.xsp_document_main_insert @p_code = @p_code output							-- nvarchar(50)
												  ,@p_branch_code = @p_branch_code
												  ,@p_branch_name = @p_branch_name
												  ,@p_custody_branch_code = @p_branch_code
												  ,@p_custody_branch_name = @p_branch_name
												  ,@p_document_type = @p_document_type
												  ,@p_asset_no = @asset_no
												  ,@p_asset_name = @asset_name
												  ,@p_locker_position = 'OUT LOCKER'
												  ,@p_locker_code = null
												  ,@p_drawer_code = null
												  ,@p_row_code = null
												  ,@p_document_status = N'ON HAND'
												  ,@p_mutation_type = 'ENTRY'
												  ,@p_mutation_location = null
												  ,@p_mutation_from = null
												  ,@p_mutation_to = null
												  ,@p_mutation_by = null
												  ,@p_mutation_date = null
												  ,@p_mutation_return_date = null
												  ,@p_last_mutation_type = null
												  ,@p_last_mutation_date = null
												  ,@p_last_locker_position = null
												  ,@p_last_locker_code = null
												  ,@p_last_drawer_code = null
												  ,@p_last_row_code = null
												  ,@p_borrow_thirdparty_type = null
												  ,@p_first_receive_date = @p_received_date
												  ,@p_release_customer_date = null
												  ,@p_cre_date = @mod_date
												  ,@p_cre_by = @mod_by
												  ,@p_cre_ip_address = @mod_ip_address
												  ,@p_mod_date = @mod_date
												  ,@p_mod_by = @mod_by
												  ,@p_mod_ip_address = @mod_ip_address

			
				exec dbo.xsp_document_detail_insert @p_id = @p_id output						-- bigint
													,@p_document_code = @p_code
													,@p_document_name = @p_document_name
													,@p_document_type = @p_document_type
													,@p_document_date = @p_document_date
													,@p_document_description = @p_document_desc
													,@p_file_name = null
													,@p_paths = null
													,@p_doc_no = @p_doc_no
													,@p_doc_name = @p_document_name
													,@p_expired_date = null
													,@p_is_manual = '0'
													,@p_cre_date = @mod_date
													,@p_cre_by = @mod_by
													,@p_cre_ip_address = @mod_ip_address
													,@p_mod_date = @mod_date
													,@p_mod_by = @mod_by
													,@p_mod_ip_address = @mod_ip_address

				
				exec dbo.xsp_document_history_insert @p_id = @p_id2 output								-- bigint
													 ,@p_document_code = @p_code
													 ,@p_document_status = N'ON HAND'					
													 ,@p_movement_type = 'ENTRY'
													 ,@p_movement_location = null
													 ,@p_movement_from = null
													 ,@p_movement_to = null
													 ,@p_movement_by = null
													 ,@p_movement_date = null
													 ,@p_movement_return_date = null
													 ,@p_locker_position = ''
													 ,@p_locker_code = null
													 ,@p_drawer_code = null
													 ,@p_row_code = null
													 ,@p_remarks = @p_document_desc
													 ,@p_cre_date = @mod_date
													 ,@p_cre_by = @mod_by
													 ,@p_cre_ip_address = @mod_ip_address
													 ,@p_mod_date = @mod_date
													 ,@p_mod_by = @mod_by
													 ,@p_mod_ip_address = @mod_ip_address
				
			end
			else
			begin
				exec dbo.xsp_document_main_insert @p_code = @p_code output							-- nvarchar(50)
												  ,@p_branch_code = @p_branch_code
												  ,@p_branch_name = @p_branch_name
												  ,@p_custody_branch_code = @p_branch_code
												  ,@p_custody_branch_name = @p_branch_name
												  ,@p_document_type = @p_document_type
												  ,@p_asset_no = @asset_no
												  ,@p_asset_name = @asset_name
												  ,@p_locker_position = 'OUT LOCKER'
												  ,@p_locker_code = null
												  ,@p_drawer_code = null
												  ,@p_row_code = null
												  ,@p_document_status = N'ON HAND'
												  ,@p_mutation_type = 'ENTRY'
												  ,@p_mutation_location = null
												  ,@p_mutation_from = null
												  ,@p_mutation_to = null
												  ,@p_mutation_by = null
												  ,@p_mutation_date = null
												  ,@p_mutation_return_date = null
												  ,@p_last_mutation_type = null
												  ,@p_last_mutation_date = null
												  ,@p_last_locker_position = null
												  ,@p_last_locker_code = null
												  ,@p_last_drawer_code = null
												  ,@p_last_row_code = null
												  ,@p_borrow_thirdparty_type = null
												  ,@p_first_receive_date = @p_received_date
												  ,@p_release_customer_date = null
												  ,@p_cre_date = @mod_date
												  ,@p_cre_by = @mod_by
												  ,@p_cre_ip_address = @mod_ip_address
												  ,@p_mod_date = @mod_date
												  ,@p_mod_by = @mod_by
												  ,@p_mod_ip_address = @mod_ip_address

			
				exec dbo.xsp_document_detail_insert @p_id = @p_id output						-- bigint
													,@p_document_code = @p_code
													,@p_document_name = @p_document_name
													,@p_document_type = @p_document_type
													,@p_document_date = @p_document_date
													,@p_document_description = @p_document_desc
													,@p_file_name = null
													,@p_paths = null
													,@p_doc_no = @p_doc_no
													,@p_doc_name = @p_document_name
													,@p_expired_date = null
													,@p_is_manual = '0'
													,@p_cre_date = @mod_date
													,@p_cre_by = @mod_by
													,@p_cre_ip_address = @mod_ip_address
													,@p_mod_date = @mod_date
													,@p_mod_by = @mod_by
													,@p_mod_ip_address = @mod_ip_address


				exec dbo.xsp_document_history_insert @p_id = @p_id2 output								-- bigint
													 ,@p_document_code = @p_code
													 ,@p_document_status = N'ON HAND'					
													 ,@p_movement_type = 'ENTRY'
													 ,@p_movement_location = null
													 ,@p_movement_from = null
													 ,@p_movement_to = null
													 ,@p_movement_by = null
													 ,@p_movement_date = null
													 ,@p_movement_return_date = null
													 ,@p_locker_position = ''
													 ,@p_locker_code = null
													 ,@p_drawer_code = null
													 ,@p_row_code = null
													 ,@p_remarks = @p_document_desc
													 ,@p_cre_date = @mod_date
													 ,@p_cre_by = @mod_by
													 ,@p_cre_ip_address = @mod_ip_address
													 ,@p_mod_date = @mod_date
													 ,@p_mod_by = @mod_by
													 ,@p_mod_ip_address = @mod_ip_address
			end
			
			insert into ifinopl.dbo.mtn_data_dsf_log
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
				'MTN DOCUMENT MAIN'
				,@p_mtn_remark
				,'DOCUMENT'
				,@p_id
				,@p_chassis_no -- REFF_2 - nvarchar(50)
				,@p_code -- REFF_3 - nvarchar(50)
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
