CREATE FUNCTION dbo.xfn_get_status
(
	--@p_agreement_no	nvarchar(50)
	--,@p_type		nvarchar(20)
	@p_code			    nvarchar(50)
)
returns nvarchar(50)
as
begin

	declare @status			nvarchar(20)

	if exists (
				select release_status
				from dbo.deposit_release dl
					 left join deposit_release_detail drd on (drd.deposit_release_code = dl.code)
					 left join ifinopl.dbo.agreement_deposit_main adm on (adm.agreement_no = dl.agreement_no)
				where drd.deposit_code = @p_code 
				and release_status not in ('cancel','reject', 'paid')
				and adm.deposit_amount <> 0
				)
				--where agreement_no = @p_agreement_no and   deposit_type = @p_type and release_status in ('HOLD', 'ON PROCESS'))
	begin
		set @status = 'Deposit Release'
	end
	else if exists (
					select revenue_status
					from dbo.deposit_revenue dr
						 left join deposit_revenue_detail drd on (drd.deposit_revenue_code = dr.code)
						 left join ifinopl.dbo.agreement_deposit_main adm on (adm.agreement_no = dr.agreement_no)
					where drd.deposit_code = @p_code 
					and revenue_status not in ('cancel','reject','post')
					and adm.deposit_amount <> 0
					)
					--where agreement_no = @p_agreement_no and   deposit_type = @p_type and revenue_status in ('HOLD'))
	begin
		set @status = 'Deposit Revenue'
	end
	else if exists (
					select move_status
					from dbo.deposit_move dm
					left join ifinopl.dbo.agreement_deposit_main adm on (adm.agreement_no = dm.from_agreement_no)
					where (from_deposit_code = @p_code 
					and move_status not in ('cancel','reject','post'))
					or (to_deposit_type_code = @p_code  
					and move_status not in ('cancel','reject','post'))
					and adm.deposit_amount <> 0
					)
					--where (from_agreement_no = @p_agreement_no and from_deposit_type_code = @p_type and move_status in ('HOLD')) or
					--	  (to_agreement_no = @p_agreement_no and to_deposit_type_code = @p_type  and move_status in ('HOLD')))
	begin
		set @status = 'Deposit Move'
	end
	else if exists (
				select allocation_status
				from dbo.deposit_allocation da
				left join ifinopl.dbo.agreement_deposit_main adm on (adm.agreement_no = da.agreement_no)
				where deposit_code = @p_code 
				and allocation_status not in ('cancel','reject','approve','reversal')
				and adm.deposit_amount <> 0
				)
				--where agreement_no = @p_agreement_no and   deposit_type = @p_type and allocation_status = 'HOLD')

	begin
		set @status = 'Deposit Allocation'
	end

	return @status

end

