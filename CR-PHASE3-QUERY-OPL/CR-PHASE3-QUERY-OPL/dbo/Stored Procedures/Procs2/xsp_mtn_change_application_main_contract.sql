CREATE PROCEDURE dbo.xsp_mtn_change_application_main_contract
(
	@p_application_no		nvarchar(50)
	,@p_main_contract_no	nvarchar(50)
	 --
   ,@p_mtn_remark			nvarchar(4000)
   ,@p_mtn_cre_by			nvarchar(250)
)
as
begin
	begin try
		begin transaction ;

			declare @application_ext		nvarchar(50)
					,@mod_by				nvarchar(15) = 'MAINTENANCE'
					,@mod_date				datetime = dbo.xfn_get_system_date()
					,@mod_ip_address		nvarchar(15) = '127.0.0.1'
					,@msg					nvarchar(max)
					,@main_contract_before	nvarchar(50)


			set @p_application_no = replace(@p_application_no,'/','.')
			set @application_ext = replace(@p_application_no,'.','/')

			if((isnull(@p_mtn_remark, '') = '' or isnull(@p_mtn_cre_by,'') = ''))
			begin
				set @msg = 'MTN Remark/Cre by harus Terisi Sesuai yang di Maintenance';
				raiserror(@msg, 16, 1) ;
				return
			end ;

			select	'BEFORE'
					,main_contract_no
					,* 
			from	dbo.application_extention 
			where	application_no = @p_application_no	

			select	@main_contract_before =  main_contract_no
			from	dbo.application_extention 
			where	application_no = @p_application_no	

			update	application_extention
			set		main_contract_no = @p_main_contract_no
			where	application_no = @p_application_no


			select	'AFTER'
					,main_contract_no
					,* 
			from	dbo.application_extention 
			where	application_no = @p_application_no	

			


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
				'MTN CHANGE APPLICATION MAIN CONTRACT'
				,@p_mtn_remark
				,'ASSET'
				,@p_application_no
				,@p_main_contract_no -- REFF_2 - nvarchar(50)
				,@main_contract_before
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
