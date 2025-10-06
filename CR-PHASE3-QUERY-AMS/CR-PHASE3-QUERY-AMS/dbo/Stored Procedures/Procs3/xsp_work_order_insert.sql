CREATE PROCEDURE [dbo].[xsp_work_order_insert]
(
	@p_code					nvarchar(50) output
	,@p_company_code		nvarchar(50)
	,@p_asset_code			nvarchar(50)
	,@p_maintenance_code	nvarchar(50)
	,@p_maintenance_by		nvarchar(50)
	,@p_status				nvarchar(50)
	,@p_remark				nvarchar(4000)
	,@p_file_name			nvarchar(250)	= ''
	,@p_file_paths			nvarchar(250)	= ''
	,@p_actual_km			int				= 0
	,@p_work_date			datetime		= null
	,@p_last_km_service		int				= 0
	,@p_last_meter			int				= 0
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max)
			,@year		nvarchar(4)
			,@month		nvarchar(2)
			,@code		nvarchar(50)

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
													,@p_branch_code			 = @p_company_code
													,@p_sys_document_code	 = ''
													,@p_custom_prefix		 = 'WO'
													,@p_year				 = @year
													,@p_month				 = @month
													,@p_table_name			 = 'WORK_ORDER'
													,@p_run_number_length	 = 5
													,@p_delimiter			 = '.'
													,@p_run_number_only		 = '0' ;
		insert into work_order
		(
			code
			,company_code
			,asset_code
			,maintenance_code
			,maintenance_by
			,status
			,remark
			,file_name
			,file_path
			,actual_km
			,work_date
			,last_km_service
			,last_meter
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			--
			,total_amount	
			,total_ppn_amount	
			,total_pph_amount	
			,payment_amount
		)
		values
		(	
			@code
			,@p_company_code
			,@p_asset_code
			,@p_maintenance_code
			,@p_maintenance_by
			,@p_status
			,@p_remark
			,@p_file_name
			,@p_file_paths
			,@p_actual_km
			,@p_work_date
			,@p_last_km_service
			,@p_last_meter
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
			,0.00
			,0.00
			,0.00
			,0.00


		) set @p_code = @code ;

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;
