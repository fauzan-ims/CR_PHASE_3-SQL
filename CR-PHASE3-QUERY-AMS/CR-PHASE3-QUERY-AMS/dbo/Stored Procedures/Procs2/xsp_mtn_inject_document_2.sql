CREATE PROCEDURE dbo.xsp_mtn_inject_document_2
(
	@p_grn_code		NVARCHAR(50)			-- 
	,@p_asset_code	NVARCHAR(50)			-- 
	 --
   ,@p_mod_ip_address	NVARCHAR(15)		-- Dapat Diisi nomor issue nya
   ,@p_mtn_remark		NVARCHAR(4000)		-- Diisi keterangan Maintenance nya untuk apa, terhadap agreement berapa dan issue apa 
   ,@p_mtn_cre_by		NVARCHAR(250)		-- Siapa yang melakukan Maintenance
)

/* Script ini dibuat untuk melakukan data maintenance jika ada perubahan plat no asset dan upload ulang document 
dan digunakan ketika sp ini xsp_mtn_inject_document_1 dijalankan

Jika masih ada yang belum dipahami sebelum melakukan script ini untuk maintenance, bisa menghubungi Raffyanda (IMS)
*/
as
begin
	begin try
		begin transaction ;

			declare @msg						nvarchar(max)
					,@mod_date					datetime = dbo.xfn_get_system_date()
					,@remark					NVARCHAR(4000)
					,@id_po						bigint
			begin
		

				select	@id_po	= id
				from	ifinproc.dbo.purchase_order_detail_object_info
				where	asset_code = @p_asset_code

				begin
					insert into ifinams.dbo.efam_interface_asset_document
						(
						    asset_code,
						    description,
						    file_name,
						    path,
							doc_file,
						    cre_date,
						    cre_by,
						    cre_ip_address,
						    mod_date,
						    mod_by,
						    mod_ip_address
						)				
					select	pt.ASSET_CODE
							,case 
								when doc.file_name = pt.stnk_file_no
								then 'STNK ' + doc.REFF_NO
								when doc.file_name = pt.stck_file_no
								then 'STCK ' + doc.REFF_NO
								when doc.file_name = pt.keur_file_no
								then 'KEUR ' + doc.REFF_NO
								else '-'
							end
							,doc.file_name
							,case 
								when doc.file_name = pt.stnk_file_no
								then pt.stnk_file_path
								when doc.file_name = pt.stck_file_no
								then pt.stck_file_path
								when doc.file_name = pt.keur_file_no
								then pt.keur_file_path
								else '-'
							end
							,doc.doc_file
							,GETDATE()
							,left(@p_mtn_cre_by,15)
							,@p_mod_ip_address
							,GETDATE()
							,left(@p_mtn_cre_by,15)
							,@p_mod_ip_address
					from	ifinproc.dbo.proc_interface_sys_document_upload doc
					inner	join ifinproc.dbo.good_receipt_note_detail grnd on (grnd.good_receipt_note_code = doc.reff_no)
					outer	apply 
							(
								select	pob.stnk_file_no
										,pob.stnk_file_path
										,pob.stck_file_no
										,pob.stck_file_path
										,pob.keur_file_no
										,pob.keur_file_path
										,pob.asset_code
								from	ifinproc.dbo.purchase_order_detail_object_info pob
								where	pob.good_receipt_note_detail_id = grnd.id
							) pt
					where	pt.asset_code = @p_asset_code
					and case
							when doc.file_name = pt.stnk_file_no then pt.stnk_file_path
							when doc.file_name = pt.stck_file_no then pt.stck_file_path
							when doc.file_name = pt.keur_file_no then pt.keur_file_path
							else '-'
						end <> '-'
					and file_name not in (select file_name from ifinams.dbo.efam_interface_asset_document where asset_code = @p_asset_code) 
				end
				
				begin
					INSERT into IFINAMS.dbo.asset_document
					(
						asset_code
						,description
						,file_name
						,file_path
						--(+) Ari 2024-04-04 ket : add doc sys
						,document_code
						,doc_file
						,doc_no
						,doc_date
						,doc_exp_date
						--
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select	asset_code
							,description
							,file_name
							,path
							,case	when description like '%STNK%'
									then (select code from ifinams.dbo.sys_general_document where document_name = 'STNK')
									when description like '%STCK%'
									then (select code from ifinams.dbo.sys_general_document where document_name = 'STCK')
									when description like '%KEUR%'
									then (select code from ifinams.dbo.sys_general_document where document_name = 'KEUR')
									else '-'
							end
							,doc_file
							,doc_no
							,doc_date
							,doc_exp_date
							--
							,GETDATE()
							,left(@p_mtn_cre_by,15)
							,@p_mod_ip_address
							,GETDATE()
							,left(@p_mtn_cre_by,15)
							,@p_mod_ip_address
					from	ifinams.dbo.efam_interface_asset_document
					where	asset_code = @p_asset_code
					and		file_name not in (select file_name from ifinams.dbo.asset_document where asset_code = @p_asset_code)
				end

					
					         
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
					'MTN INJECT DOCUMENT ASSET'
					,@remark
					,@p_mtn_remark
					,@p_grn_code
					,@p_asset_code -- REFF_2 - nvarchar(50)
					,@p_mod_ip_address -- REFF_3 - nvarchar(50)
					,getdate()
					,@p_mtn_cre_by
				)
			end

			if @@error = 0
			begin
				select 'SUCCESS'
				SELECT 'After', * from dbo.asset_document where asset_code = @p_asset_code
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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_inject_document_2] TO [dsf_lina]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_inject_document_2] TO [windy.nurbani]
    AS [dbo];

