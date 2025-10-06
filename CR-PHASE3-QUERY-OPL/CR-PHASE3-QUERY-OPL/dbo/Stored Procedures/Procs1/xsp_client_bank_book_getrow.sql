CREATE procedure [dbo].[xsp_client_bank_book_getrow]
(
	@p_id				 bigint		  = 0
	,@p_client_bank_code nvarchar(50) = ''
	,@p_approval_summary nvarchar(1)  = ''
)
as
begin
	if (@p_approval_summary <> '')
	begin
		select top 1
					cbb.id
					,cbb.client_code
					,cbb.periode_year
					,cbb.periode_month
					,case periode_month
						 when 1 then 'January'
						 when 2 then 'February'
						 when 3 then 'March'
						 when 4 then 'April'
						 when 5 then 'May'
						 when 6 then 'June'
						 when 7 then 'July'
						 when 8 then 'August'
						 when 9 then 'September'
						 when 10 then 'October'
						 when 11 then 'November'
						 when 12 then 'December'
					 end as 'periode_months'
					,cbb.client_bank_code
					,cbb.opening_balance_amount
					,cbb.ending_balance_amount
					,cbb.total_cr_mutation_amount
					,cbb.total_db_mutation_amount
					,cbb.freq_credit_mutation
					,cbb.freq_debet_mutation
					,cbb.average_cr_mutation_amount
					,cbb.average_db_mutation_amount
					,cbb.average_balance_amount
					,cbb.highest_balance_amount
					,cbb.lowest_balance_amount
		from		client_bank_book cbb
					inner join dbo.client_bank cb on (cb.code = cbb.client_bank_code)
		where		client_bank_code  = @p_client_bank_code
					and cb.is_default = '1'
		order by	periode_month + periode_year desc ;
	end ;
	else if (@p_id <> 0)
	begin
		select	id
				,client_code
				,periode_year
				,periode_month
				,client_bank_code
				,opening_balance_amount
				,ending_balance_amount
				,total_cr_mutation_amount
				,total_db_mutation_amount
				,freq_credit_mutation
				,freq_debet_mutation
				,average_cr_mutation_amount
				,average_db_mutation_amount
				,average_balance_amount
				,highest_balance_amount
				,lowest_balance_amount
		from	client_bank_book
		where	id = @p_id ;
	end ;
end ;

