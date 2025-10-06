CREATE PROCEDURE [dbo].[xsp_stop_billing_insert]
(
	@p_code			   nvarchar(50) output
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_agreement_no   nvarchar(50)
	,@p_status		   nvarchar(10)
	,@p_date		   datetime
	,@p_remarks		   nvarchar(4000) = ''
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @code	nvarchar(50)
			,@year	nvarchar(4)
			,@month nvarchar(2)
			,@msg	nvarchar(max) ;

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = N'STB'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = N'STOP_BILLING'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		--(-)SEPRIA 20FEB2024: VALIDASI INI DITUTUP KARENA ADA CASE STOP BILLING DILAKUKAN UNTUK UNIT YANG SUDAH HILANG.
		----(+) Raffyanda 18/10/2023 21.21.00 penambahan Validasi agar SKT di proses sebelum stop billing 
		--if not exists(select agreement_no from dbo.repossession_letter where agreement_no = @p_agreement_no and letter_status <> 'CANCEL')
		--begin 
		--	set @msg = 'Please create SKT before stop billing'
		--	raiserror(@msg, 16, -1)
		--end 

		--if exists(select agreement_no from dbo.repossession_letter where agreement_no = @p_agreement_no and letter_status in ('HOLD', 'POST'))
		--begin 
		--	set @msg = 'Cannot process because contract is in progress SKT'
		--	raiserror(@msg, 16, -1)
		--end 
		----(+) Raffyanda 18/10/2023 21.21.00 penambahan Validasi agar SKT di proses sebelum stop billing 
		--(-)SEPRIA 20FEB2024: VALIDASI INI DITUTUP KARENA ADA CASE STOP BILLING DILAKUKAN UNTUK UNIT YANG SUDAH HILANG.

		if (@p_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Date must be less than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.stop_billing
			where	agreement_no = @p_agreement_no
					and status in
		(
			'ON PROCESS', 'HOLD'
		)
		)
		begin
			set @msg = N'Agreement already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into dbo.stop_billing
		(
			code
			,branch_code
			,branch_name
			,agreement_no
			,status
			,date
			,remarks
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@code
			,@p_branch_code
			,@p_branch_name
			,@p_agreement_no
			,@p_status
			,@p_date
			,@p_remarks
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		-- update opl status
		exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no = @p_agreement_no
													  ,@p_status = N'STOP BILLING' ;

		set @p_code = @code ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
