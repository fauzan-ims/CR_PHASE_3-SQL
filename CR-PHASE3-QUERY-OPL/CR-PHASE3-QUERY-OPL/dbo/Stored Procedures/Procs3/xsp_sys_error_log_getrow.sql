
CREATE PROCEDURE dbo.xsp_sys_error_log_getrow
(
@p_id			bigint
) as
begin

	select		id
		,log_date
		,log_message
		,sp_name
		,parameter
	from	sys_error_log
	where
	id	= @p_id
	end
