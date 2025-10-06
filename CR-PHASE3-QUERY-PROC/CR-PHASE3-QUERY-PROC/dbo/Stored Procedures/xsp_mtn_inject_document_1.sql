CREATE PROCEDURE dbo.xsp_mtn_inject_document_1
(
	@p_grn_code		NVARCHAR(50)			-- 
	,@p_asset_code	NVARCHAR(50)			-- 
	 --
   ,@p_mod_ip_address	NVARCHAR(15)		-- Dapat Diisi nomor issue nya
   ,@p_mtn_remark		NVARCHAR(4000)		-- Diisi keterangan Maintenance nya untuk apa, terhadap agreement berapa dan issue apa 
   ,@p_mtn_cre_by		NVARCHAR(250)		-- Siapa yang melakukan Maintenance
)

/* Script ini dibuat untuk melakukan data maintenance jika ada perubahan plat no asset dan upload ulang document 

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
			from	dbo.purchase_order_detail_object_info
			where	asset_code = @p_asset_code

			INSERT INTO dbo.PROC_INTERFACE_SYS_DOCUMENT_UPLOAD
			(
			    REFF_NO,
			    REFF_NAME,
			    REFF_TRX_CODE,
			    FILE_NAME,
			    DOC_FILE,
			    CRE_DATE,
			    CRE_BY,
			    CRE_IP_ADDRESS,
			    MOD_DATE,
			    MOD_BY,
			    MOD_IP_ADDRESS
			)
			SELECT	REFF_NO,
					REFF_NAME,
					REFF_TRX_CODE,
					FILE_NAME,
					DOC_FILE,
					@mod_date,
					left(@p_mtn_cre_by,15),
					@p_mod_ip_address,
					@mod_date,
					left(@p_mtn_cre_by,15),
					@p_mod_ip_address 
			FROM	sys_document_upload where reff_no = @p_grn_code and reff_trx_code = @id_po
					and file_name not in (select file_name from dbo.proc_interface_sys_document_upload where reff_no = @p_grn_code) 
			
			         
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
				SELECT 'After', * FROM dbo.PROC_INTERFACE_SYS_DOCUMENT_UPLOAD WHERE REFF_NO = @p_grn_code
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
    ON OBJECT::[dbo].[xsp_mtn_inject_document_1] TO [dsf_lina]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_inject_document_1] TO [windy.nurbani]
    AS [dbo];

