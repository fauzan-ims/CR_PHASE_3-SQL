
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_adjustment_proceed]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				 nvarchar(max)
			,@status			 nvarchar(20)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid			 int
			,@max_day			 int
			,@date				 datetime
			,@purchase_date		 datetime
			,@asset_code		 nvarchar(50)
			,@asset_purcase_date datetime
			,@company_code		 nvarchar(50) 
			,@adjustment_type	 nvarchar(50)
			,@adj_purc_price	decimal(18,2)
			,@old_purc_price	decimal(18,2)
			,@is_from_proc		nvarchar(1)

	begin try -- 
		select	@status				= dor.status
				,@date				= dor.date
				,@company_code		= dor.company_code
				,@purchase_date		= new_purchase_date
				,@asset_code		= asset_code
				,@adjustment_type	= adjustment_type
				,@adj_purc_price	= dor.purchase_price
				,@is_from_proc		= dor.is_from_proc
		from	dbo.adjustment dor
		where	dor.code = @p_code ;

		-- ( + ) Dicki Kurniawan - 10/25/2022 03:00 pm  - Tambah Validasi untuk purcase date 
		select	@asset_purcase_date = purchase_date
				,@old_purc_price	= purchase_price
		from	dbo.asset
		where	code = @asset_code ;

		if(@adjustment_type = 'REVAL')
		begin
			if @purchase_date < @asset_purcase_date
			begin
				set @msg = 'Purchase Date Adjustment Is Not The Same As Purcase Date Asset' ;
				raiserror(@msg, 16, -1) ;
			end
		end		

		---- Arga 06-Nov-2022 ket : additional control for diff purchase price related to journal function (+)
		--if @adj_purc_price <> @old_purc_price  and isnull(@is_from_proc,0) = 0
		--begin
		--	set @msg = 'Purchase Price must be the same as the current asset data' ;
		--	raiserror(@msg, 16, -1) ;
		--end


		-- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
		set @is_valid = dbo.xfn_date_validation(@date) ;

		select	@max_day = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MDT' ;

		if @is_valid = 0 and isnull(@is_from_proc,0) = 0
		begin
			set @msg = 'The maximum back date input transaction is ' + cast(@max_day as char(2)) + ' in each month';
			raiserror(@msg, 16, -1) ;
		end ;

		-- Arga 06-Nov-2022 ket : request wom back date only for register aset (+)
		if datediff(month,@date,dbo.xfn_get_system_date()) > 0  and isnull(@is_from_proc,0) = 0
		begin
			set @msg = 'Back date transactions are not allowed for this transaction';
			raiserror(@msg ,16,-1);	 
		end



		if (@status = 'HOLD')
		begin
			update	dbo.adjustment
			set		status = 'ON PROCESS'
					--
					,mod_date = @p_mod_date
					,mod_by = @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code ;

			-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code = 'APRQTR'
			--												 ,@p_doc_code = @p_code
			--												 ,@p_attachment_flag = 0
			--												 ,@p_attachment_file = ''
			--												 ,@p_attachment_path = ''
			--												 ,@p_company_code = @company_code
			--												 ,@p_trx_no = @p_code
			--												 ,@p_trx_type = 'ADJUSTMENT' ;
		-- End of send mail attachment based on setting ================================================
		end ;
		else
		begin
			set @msg = 'Data already proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;
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
