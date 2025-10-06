
-- Louis Kamis, 04 April 2024 16.52.20 --
CREATE PROCEDURE [dbo].[xsp_master_other_budget_delete]
(
	@p_code nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete dbo.master_other_budget
		where	code = @p_code ;
	end try
	begin catch 
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
