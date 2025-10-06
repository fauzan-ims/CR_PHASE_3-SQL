
CREATE function [dbo].[xfn_get_msg_err_code_already_exist]
()
returns nvarchar(max)
--WITH ENCRYPTION|SCHEMABINDING, ...
as
begin
	
	declare @static_err nvarchar(max)

	--set @static_err = 'Code already exist'; -- Arga 20-Oct-2022 ket : for wom (-)
	set @static_err = 'Code Already Exist' -- Arga 20-Oct-2022 ket : for wom (+)

    return @static_err

end

