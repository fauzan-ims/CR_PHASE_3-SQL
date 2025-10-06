CREATE PROCEDURE dbo.xsp_inventory_adjustment_detail_insert
(
	 @p_id								bigint	= 0 output
	,@p_inventory_adjustment_code		nvarchar(50)
	,@p_item_code						nvarchar(50)
	,@p_item_name						nvarchar(250)
	,@p_plus_or_minus					nvarchar(5)
	,@p_warehouse_code					nvarchar(50)
	,@p_total_adjustment				int
	,@p_remark							nvarchar(4000)
	--
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;
	
	--if @p_plus_or_minus = 'T'
	--	set @p_plus_or_minus = '1' ;
	--else if @p_plus_or_minus = '1'
	--	set @p_plus_or_minus = '1' ;
	--else if @p_plus_or_minus = '0'
	--	set @p_plus_or_minus = '0' ;
	--else
	--	set @p_plus_or_minus = '0' ;

	begin try
	insert into inventory_adjustment_detail
	(
		 inventory_adjustment_code
		,item_code
		,item_name
		,plus_or_minus
		,warehouse_code
		,total_adjustment
		,remark
		--
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
	)
	values
	(
		 @p_inventory_adjustment_code
		,@p_item_code
		,@p_item_name
		,@p_plus_or_minus
		,@p_warehouse_code
		,@p_total_adjustment
		,@p_remark
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	)

	set @p_id = @@IDENTITY

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
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end
