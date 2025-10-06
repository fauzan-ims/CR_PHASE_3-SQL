CREATE PROCEDURE dbo.xsp_mtn_main_contract
(
	@p_application_no	nvarchar(50)
	,@p_main_contract	nvarchar(50)
	 --
   ,@p_mtn_remark		nvarchar(4000)
   ,@p_mtn_cre_by		nvarchar(250)
)
as
begin
	begin try
		begin transaction ;

			declare @msg						nvarchar(max)
					,@application_no			nvarchar(50) = replace(@p_application_no,'/','.')
					,@mod_date					datetime = dbo.xfn_get_system_date()
					,@mod_by					nvarchar(15) = 'MAINTENANCE'
					,@mod_ip_address			nvarchar(15) = '127.0.0.1'
					,@client_code				nvarchar(50)

			if((isnull(@p_mtn_remark, '') = '' or isnull(@p_mtn_cre_by,'') = ''))
			begin
				set @msg = 'MTN Remark/Cre by harus Terisi Sesuai yang di Maintenance';
				raiserror(@msg, 16, 1) ;
				return
			end ;

			if exists (
						select	1 
						from	dbo.application_extention
						where	main_contract_no = @p_main_contract
						and		application_no = @application_no
					  )
			begin
				set @msg = 'Main Contract Already Exist';
				raiserror(@msg, 16, 1) ;
			end

			declare @p_id bigint ;

			select	@client_code = client_code 
			from	dbo.application_main
			where	application_no = @application_no
			
			exec dbo.xsp_application_extention_insert @p_id = @p_id output								-- bigint
													  ,@p_application_no = @application_no
													  ,@p_main_contract_status = N'EXISTING'					-- nvarchar(50)
													  ,@p_main_contract_no = @p_main_contract
													  ,@p_main_contract_file_name = N''					-- nvarchar(250)
													  ,@p_main_contract_file_path = N''					-- nvarchar(250)
													  ,@p_main_contract_date = '2024-01-09 06:45:49'	-- datetime
													  ,@p_client_no = @client_code
													  ,@p_remarks = N'MIGRASI SUSULAN'					-- nvarchar(4000)
													  ,@p_cre_date = @mod_date
													  ,@p_cre_by = @mod_by
													  ,@p_cre_ip_address = @mod_ip_address
													  ,@p_mod_date = @mod_date
													  ,@p_mod_by = @mod_by
													  ,@p_mod_ip_address = @mod_ip_address
			

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
				'MTN MAIN CONTRACT'
				,@p_mtn_remark
				,'APPLICATION_EXTENTION'
				,@p_application_no
				,@p_main_contract -- REFF_2 - nvarchar(50)
				,@application_no -- REFF_3 - nvarchar(50)
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
