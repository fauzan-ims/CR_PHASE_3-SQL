/*
exec xsp_payment_request_get_payment_source
*/
-- Louis Rabu, 01 Maret 2023 14.56.30 --
CREATE PROCEDURE dbo.xsp_payment_request_get_payment_source
as
begin
	select	'ALL'  'payment_source'
	from	dbo.payment_request
	where	payment_status = 'HOLD' 
	union
	select distinct
			(payment_source) 'payment_source'
	from	dbo.payment_request
	where	payment_status = 'HOLD' 
	union	
	select	'ALL' -- (+) Ari 2023-10-09 ket : jika tidak ada transaksi munculin ALL (tidak akan double karna ada distinct)
end ;
