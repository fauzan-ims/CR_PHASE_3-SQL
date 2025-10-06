
CREATE procedure xsp_reversal_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,reversal_status
			,reversal_date
			,reversal_remarks
			,source_reff_code
			,source_reff_name
	from	reversal_main
	where	code = @p_code ;
end ;
