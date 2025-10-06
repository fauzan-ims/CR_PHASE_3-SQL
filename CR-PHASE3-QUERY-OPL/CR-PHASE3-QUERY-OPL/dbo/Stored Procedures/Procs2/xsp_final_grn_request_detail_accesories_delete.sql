
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_detail_accesories_delete]
(
	@p_id int
)
as
begin
	declare @msg	nvarchar(max)
			,@count int ;

	begin try
		--select	@count = count(1)
		--from	dbo.final_grn_request_detail_accesories_lookup
		--where	final_grn_request_detail_accesories_id = @p_id ;

		--if (@count > 1)
		--begin
		--	update	dbo.final_grn_request_detail_accesories_lookup
		--	set		final_grn_request_detail_accesories_id = 0
		--	where	id = @p_final_grn_request_detail_accesories_id ;
		--end ;
		--else
		--begin
		--	set @msg = N'Cannot delete this data.' ;

		--	raiserror(@msg, 16, 1) ;
		--end ;
		delete	dbo.final_grn_request_detail_accesories
		where	id = @p_id ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%v;%'
				   or	error_message() like '%e;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'e;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
