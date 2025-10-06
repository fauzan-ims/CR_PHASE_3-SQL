CREATE PROCEDURE dbo.xsp_mtn_change_billing_date
(
	@p_agreement_no		NVARCHAR(50)		-- Agreement yang akan dilakukan perubahan billing date nya 
	,@p_month_or_date	NVARCHAR(50)		-- Month = jika perubahannya dihitung bulanan, DATE = jika perubahannya dihitungnya harian
	,@p_jumlah			INT					-- Jumlah perubahannya, baik untuk harian/bulanan
	,@p_start_biling_no	INT					-- Perubahan billing date nya dimulai dari billing no ke berapa
	,@p_end_billing_no	INT					-- Perubahan billing date nya sampe billing no ke berapa
	,@p_asset_no		NVARCHAR(50) =''		-- Asset no jika 1 agreement beda spesifik billing date nya 
	 --
   ,@p_mod_ip_address	NVARCHAR(15)		-- Dapat Diisi nomor issue nya
   ,@p_mtn_remark		NVARCHAR(4000)		-- Diisi keterangan Maintenance nya untuk apa, terhadap agreement berapa dan issue apa 
   ,@p_mtn_cre_by		NVARCHAR(250)		-- Siapa yang melakukan Maintenance
)

/* Script ini dibuat untuk melakukan data maintenance jika ada perubahan billing date
dengan syarat :
1. Billing yang ingin dilakukan perubahan belum memiliki invoice yang sudah tergenerate.
2. Jika billing tersebut sudah memiliki invoice, user HARUS melakukan cancel terhadap invoice nya atau billing date untuk billing no tersebut tidak dapat di Maintenance

Jika masih ada yang belum dipahami sebelum melakukan script ini untuk maintenance, bisa menghubungi Raffyanda (IMS)
*/
as
begin
	begin try
		begin transaction ;

			declare @msg						nvarchar(max)
					,@agreement_no				nvarchar(50) = replace(@p_agreement_no,'/','.')
					,@mod_date					datetime = dbo.xfn_get_system_date()
					,@mod_by					nvarchar(15) = 'MAINTENANCE'
					,@remark					NVARCHAR(4000)

			select	'Before', * 
			from	dbo.agreement_asset_amortization 
			where	agreement_no = @agreement_no

			if exists
			(			
				select	1
				from	dbo.agreement_asset_amortization
				where	agreement_no = @agreement_no
				and		billing_no between @p_start_biling_no and @p_end_billing_no
				and		isnull(invoice_no,'') <> ''
				and		asset_no	= case  @p_asset_no 
										when  '' then asset_no
											else @p_asset_no
									end
			)				
			begin
				set @msg = 'Cancel Terlebih Dahulu Invoice yang sudah tergenerate'
				raiserror (@msg, 16, -1)
			end
			else
			begin            
				if (@p_month_or_date = 'MONTH')
					begin
						if (@p_asset_no = '')
							begin
								update	dbo.agreement_asset_amortization
								set		billing_date	= dateadd(month, @p_jumlah, billing_date)
										,mod_date		= getdate()
										,mod_by			= @p_mtn_cre_by
										,mod_ip_address	= @p_mod_ip_address
								where	agreement_no = @agreement_no 
								and		billing_no between @p_start_biling_no and @p_end_billing_no
							end
			                else
			                begin
								update	dbo.agreement_asset_amortization
								set		billing_date	= dateadd(month, @p_jumlah, billing_date)
										,mod_date		= getdate()
										,mod_by			= @p_mtn_cre_by
										,mod_ip_address	= @p_mod_ip_address
								where	agreement_no	= @agreement_no 
								and		asset_no		= @p_asset_no
								and		billing_no between @p_start_biling_no and @p_end_billing_no
			                end
					end
				else if (@p_month_or_date = 'DATE')
					BEGIN
						if (@p_asset_no = '')
							begin
								update	dbo.agreement_asset_amortization
								set		billing_date = dateadd(day, @p_jumlah, billing_date)
										,mod_date		= getdate()
										,mod_by			= @p_mtn_cre_by
										,mod_ip_address	= @p_mod_ip_address
								where	agreement_no = @agreement_no
								and		billing_no between @p_start_biling_no and @p_end_billing_no
							end
			                else
			                BEGIN
                            SELECT 'masuk'
								update	dbo.agreement_asset_amortization
								set		billing_date = dateadd(day, @p_jumlah, billing_date)
										,mod_date		= getdate()
										,mod_by			= LEFT(@p_mtn_cre_by, 15)
										,mod_ip_address	= @p_mod_ip_address
								where	agreement_no	= @agreement_no
								and		asset_no		= @p_asset_no
								and		billing_no between @p_start_biling_no and @p_end_billing_no
							end
					END
				else 
					begin
						set @msg = 'Masukkan Parameter Month or Date'
						raiserror (@msg, 16, -1)
					END
			         
				SET @remark = @p_mtn_remark + ' Untuk Agreement ' + @agreement_no + ' Issue ' + @p_mod_ip_address 
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
					'MTN Change Billing Date'
					,@remark
					,'Agreement_asset_amortization'
					,@p_agreement_no
					,@agreement_no -- REFF_2 - nvarchar(50)
					,@agreement_no -- REFF_3 - nvarchar(50)
					,getdate()
					,@p_mtn_cre_by
				)
	
			end

			if @@error = 0
			begin
				select 'SUCCESS'
				SELECT 'After', * FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE AGREEMENT_NO = @agreement_no
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
GRANT ALTER
    ON OBJECT::[dbo].[xsp_mtn_change_billing_date] TO [DSF\eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_change_billing_date] TO [DSF\eddy.rakhman]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[xsp_mtn_change_billing_date] TO [eddy.r]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_change_billing_date] TO [eddy.r]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_change_billing_date] TO [ims-raffyanda]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[xsp_mtn_change_billing_date] TO [eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_change_billing_date] TO [eddy.rakhman]
    AS [dbo];

