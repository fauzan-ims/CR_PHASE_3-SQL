CREATE PROCEDURE [dbo].[xsp_reversal_main_insert_from_cashier_transaction]
(
	@p_code			   nvarchar(50)
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
	declare @reversal_remark nvarchar(4000)
			,@source_code	 nvarchar(50)
			,@branch_name	 nvarchar(250)
			,@branch_code	 nvarchar(50)
			,@date			 datetime	   = dbo.xfn_get_system_date()
			,@agreement_no	 nvarchar(50)
			,@client_name	 nvarchar(250)
			,@cashier_no	 nvarchar(50)
			,@cashier_name	 nvarchar(250)
			,@msg			 nvarchar(max) ;

	if exists
	(
		select	1
		from	dbo.cashier_transaction_detail
		where	transaction_code			 NOT IN ('INST','SPND', 'DPINST', 'DPOTH', 'OVDP', 'LRAP')
				and is_paid					 = '1'
				and base_amount				 > 0
				and cashier_transaction_code = @p_code
	)
	begin
		set @msg = N'This Cashier Cannot Do Reversal' ;

		raiserror(@msg, 16, -1) ;
	end ;

	select	@branch_code	= ct.branch_code
			,@branch_name	= ct.branch_name
			,@agreement_no	= ct.agreement_no
			,@source_code	= ct.code
			,@cashier_no	= ct.cashier_main_code
			,@client_name	= am.client_name
			,@cashier_name	= cm.employee_name
	from	dbo.cashier_transaction ct
			left join dbo.agreement_main am on (am.agreement_no = ct.agreement_no)
			inner join dbo.cashier_main cm on (cm.code			 = ct.cashier_main_code)
	where	ct.code = @p_code ;

	set @reversal_remark = 'Reversal Cashier Transaction ' + isnull((@agreement_no + ' - ' + @client_name),'SUSPEND (UNKNOW)') + ' - Cashier: ' + @cashier_no + ' ' + @cashier_name ;

	exec dbo.xsp_reversal_main_insert @p_code				= @p_code output
									  ,@p_branch_code		= @branch_code
									  ,@p_branch_name		= @branch_name
									  ,@p_reversal_status	= N'HOLD'
									  ,@p_reversal_date		= @date
									  ,@p_reversal_remarks	= @reversal_remark
									  ,@p_source_reff_code	= @source_code
									  ,@p_source_reff_name	= N'Cashier Transaction'
									  --
									  ,@p_cre_date			= @p_cre_date
									  ,@p_cre_by			= @p_cre_by
									  ,@p_cre_ip_address	= @p_cre_ip_address
									  ,@p_mod_date			= @p_mod_date
									  ,@p_mod_by			= @p_mod_by
									  ,@p_mod_ip_address	= @p_mod_ip_address ;

	update	dbo.cashier_transaction
	set		cashier_status	= 'ON REVERSE'
			--
			,mod_date		= @p_mod_date
			,mod_by			= @p_mod_by
			,mod_ip_address	= @p_mod_ip_address
	where	code			= @source_code ;
end ;
