-- Stored Procedure

CREATE PROCEDURE dbo.xsp_job_interface_in_ifinams_ifinopl_sell_request
as
declare @msg								nvarchar(max)
		,@row_to_process					int
		,@last_id_from_job					bigint
		,@code_sys_job						nvarchar(50)
		,@is_active							nvarchar(1)
		,@mod_date							datetime		= getdate()
		,@mod_by							nvarchar(15) = 'job'
		,@mod_ip_address					nvarchar(15) = '127.0.0.1'
		,@current_mod_date					datetime
        ,@is_success						nvarchar(1)	  = 0
		,@err_msg							nvarchar(4000)
		,@from_id							bigint		  = 0
		,@id_interface						bigint
		,@number_rows			int			  = 0
		--
		,@asset_code						nvarchar(50)
		,@remark							nvarchar(4000)
		,@branch_code						nvarchar(50)
		,@branch_name						nvarchar(250)
		,@client_name						nvarchar(250)
		,@code_sale							nvarchar(50)
		,@system_date						datetime = dbo.fn_get_system_date()
		,@code								nvarchar(50)

select	@code_sys_job = code
		,@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_in_ifinams_ifinopl_sell_request' ; -- sesuai dengan nama sp ini

/*
	CR Priority sepria 09092025: job ini untuk otomatis generate depre asset jika dari procurement sudah final post + semua invoice dari item sudah terbayar (coa asset sudah ada)
*/
if (@is_active = '1')
begin
	--get approval request
	declare curr_asset cursor for
	select	remark
			,branch_code
			,branch_name
			,client_name
			,code
			,id
	from	dbo.ams_interface_sell_request_from_et
	where	job_status in ('HOLD','FAILED')
	order by code asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_asset ;

	fetch next from curr_asset
	into	@remark
			,@branch_code
			,@branch_name
			,@client_name
			,@code
			,@id_interface

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

				--insert ke sale request
			exec dbo.xsp_sale_insert @p_code					= @code_sale output
									 ,@p_company_code			= 'DSF'
									 ,@p_sale_date				= @system_date
									 ,@p_description			= @REMARK
									 ,@p_branch_code			= @branch_code
									 ,@p_branch_name			= @branch_name
									 ,@p_sale_amount_header		= 0
									 ,@p_remark					= @remark
									 ,@p_status					= 'HOLD'
									 ,@p_sell_type				= 'COP'
									 ,@p_auction_code			= ''
									 ,@p_buyer_name				= @CLIENT_NAME
									 ,@p_claim_amount			= 0
									 ,@p_cre_date				= @mod_date		
									 ,@p_cre_by					= @mod_by			
									 ,@p_cre_ip_address			= @mod_ip_address
									 ,@p_mod_date				= @mod_date		
									 ,@p_mod_by					= @mod_by			
									 ,@p_mod_ip_address			= @mod_ip_address

			declare curr_sale_req cursor fast_forward read_only for
			select	fa_code 
			from	dbo.ams_interface_sell_request_detail_from_et 
			where	code = @code
			
			open curr_sale_req
			fetch next from curr_sale_req 
			into   @asset_code

			while @@fetch_status = 0
			begin
				
					EXEC dbo.xsp_sale_detail_insert @p_id							= 0
													,@p_sale_code					= @code_sale
													,@p_asset_code					= @asset_code
													,@p_description					= @remark
													,@p_total_income				= 0
													,@p_total_expense				= 0
													,@p_buyer_type					= ''
													,@p_buyer_name					= ''
													,@p_buyer_area_phone			= ''
													,@p_buyer_area_phone_no			= ''
													,@p_buyer_address				= ''
													,@p_file_name					= ''
													,@p_file_paths					= ''
													,@p_ktp_no						= ''
													,@p_sale_value					= 0
													,@p_total_fee_amount			= 0
													,@p_total_ppn_amount			= 0
													,@p_total_pph_amount			= 0
													,@p_faktur_no					= ''
													,@p_borrowing_interest_amount	= 0
													,@p_claim_amount				= 0
													,@p_cre_date					= @mod_date		
													,@p_cre_by						= @mod_by			
													,@p_cre_ip_address				= @mod_ip_address
													,@p_mod_date					= @mod_date		
													,@p_mod_by						= @mod_by			
													,@p_mod_ip_address				= @mod_ip_address
			    
			
			    fetch next from curr_sale_req 
				into @asset_code
			end
			
			close curr_sale_req
			deallocate curr_sale_req
			----------------------------
			update dbo.ams_interface_sell_request_from_et
			set		job_status = 'POST'
			where	code = @code

			commit transaction ;

		end try
		begin catch
			rollback transaction ;

			set @is_success = N'0' ;
			set @msg = error_message() ;
			set @current_mod_date = getdate() ;

			update	dbo.ams_interface_sell_request_from_et	--cek poin
			set		job_status = 'FAILED'
					,failed_remarks = @msg
			where	id = @id_interface ;

			--cek poin	

			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
													 ,@p_status = N'Error'
													 ,@p_start_date = @mod_date
													 ,@p_end_date = @current_mod_date	--cek poin
													 ,@p_log_description = @msg
													 ,@p_run_by = 'job'
													 ,@p_from_id = @from_id				--cek poin
													 ,@p_to_id = @id_interface			--cek poin
													 ,@p_number_of_rows = @number_rows	--cek poin
													 ,@p_cre_date = @current_mod_date	--cek poin
													 ,@p_cre_by = N'job'
													 ,@p_cre_ip_address = N'127.0.0.1'
													 ,@p_mod_date = @current_mod_date	--cek poin
													 ,@p_mod_by = N'job'
													 ,@p_mod_ip_address = N'127.0.0.1' ;
		end catch ;

		fetch next from curr_asset
		into	@remark
				,@branch_code
				,@branch_name
				,@client_name
				,@code
				,@id_interface

	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_asset') >= -1
		begin
			if cursor_status('global', 'curr_asset') > -1
			begin
				close curr_asset ;
			end ;

			deallocate curr_asset ;
		end ;
	end ;
end ;
