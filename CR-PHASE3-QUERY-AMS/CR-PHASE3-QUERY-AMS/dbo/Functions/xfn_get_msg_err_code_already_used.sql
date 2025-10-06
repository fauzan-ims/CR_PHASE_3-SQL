
CREATE function [dbo].[xfn_get_msg_err_code_already_used]
()
returns nvarchar(max)
--WITH ENCRYPTION|SCHEMABINDING, ...
as
begin
	
	declare @static_err nvarchar(max)

	set @static_err = 'The code has already been used in the transaction;'; -- Arga 20-Oct-2022 ket : for wom (-/+)
	--set @static_err = 'Kode transaksi ini sudah digunakan pada data lain' -- Arga 20-Oct-2022 ket : for wom (+)

    return @static_err

end

