CREATE PROCEDURE [dbo].[xsp_rpt_print_pajak_insurance_group]
(
	@p_user_id		   nvarchar(50)
	--,@p_sale_id			int
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
	declare @policy_no NVARCHAR(50) ;

	delete	dbo.rpt_list_faktur_pajak_insurance_detail_detail 
	where	user_id = @p_user_id

	delete	dbo.rpt_list_faktur_pajak_insurance_detail
	where	user_id = @p_user_id

	declare cur_print_pajak_group cursor local fast_forward read_only for
	select	policy_no
	from	dbo.RPT_PRINT_PAJAK_INSURANCE_GROUP with (nolock)
	where	user_id = @p_user_id ;

	open cur_print_pajak_group ;

	fetch next from cur_print_pajak_group
	into @policy_no ;

	while @@fetch_status = 0
	begin
		
		EXEC dbo.xsp_rpt_list_faktur_pajak_insurance_detail @p_user_id = @p_user_id, -- nvarchar(50)
		                                                    @p_policy_no = @policy_no  -- int
		
		
		

		fetch next from cur_print_pajak_group
		into @policy_no ;
	end ;

	close cur_print_pajak_group ;
	deallocate cur_print_pajak_group ;

end ;
