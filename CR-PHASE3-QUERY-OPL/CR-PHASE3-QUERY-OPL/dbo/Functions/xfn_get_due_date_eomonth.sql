CREATE function	[dbo].[xfn_get_due_date_eomonth]
(
	@asset_no			nvarchar(50) 
)
returns nvarchar(1)
as
begin 

declare @max_billing_no		int
		,@return			nvarchar(1)
		,@due_date			datetime


select	@max_billing_no =  max(billing_no) 
from	dbo.agreement_asset_amortization 
where	asset_no = @asset_no


declare curr_due_date cursor for
	select	top 3 due_date
	from	dbo.agreement_asset_amortization 
	where	asset_no = @asset_no 
	and		billing_no < @max_billing_no
	order by billing_no desc


	open curr_due_date		
	fetch next from curr_due_date
	into @due_date

	while @@fetch_status = 0

	begin 
			if (eomonth(@due_date) <> cast(@due_date as date))
			begin
				set @return = '0'
			end

	fetch next from curr_due_date
	into @due_date
	end

	close curr_due_date
	deallocate curr_due_date 

	return  isnull(@return,'1');
end;
