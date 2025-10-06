

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	 code		
			,branch_code	
			,branch_name	
			,date		
			,remarks		
			,status		
	from	dbo.faktur_no_replacement
	where	code = @p_code ;
end ;
