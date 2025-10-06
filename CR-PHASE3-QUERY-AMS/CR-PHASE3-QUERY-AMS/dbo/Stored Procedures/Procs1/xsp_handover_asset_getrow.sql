CREATE PROCEDURE [dbo].[xsp_handover_asset_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	declare @reff_code			nvarchar(50)
			,@flag_handover_req nvarchar(1)
			,@handover_req_code nvarchar(50)
			,@handover_code		nvarchar(50)
			,@type_handover		nvarchar(50)
			,@handover_type		nvarchar(50)
			,@type				nvarchar(50) 
			,@maturity_date		datetime
			,@fa_code			nvarchar(50)

	select	@reff_code = reff_code
			,@type	   = left(type, 20)
			,@fa_code  = fa_code
	from	dbo.handover_asset
	where	code = @p_code ;

	if exists
	(
		select	1
		from	dbo.handover_request
		where	reff_code		   = @reff_code
				and left(type, 20) <> @type
				and handover_code is null
	)
	begin
		--tampilkan code handover req + warna merah
		set @flag_handover_req = N'1' ;

		select	@handover_req_code = code
				,@type_handover	   = type
		from	dbo.handover_request
		where	reff_code		   = @reff_code
				and left(type, 20) <> @type
				and handover_code is null ;
	end ;

	--else if exists
	--(
	--	select	1
	--	from	dbo.handover_request
	--	where	reff_code		  = @reff_code
	--			and left(type, 6) = 'RETURN'
	--			and handover_code is null
	--)
	--begin 
	--	--tampilkan code handover req + warna merah
	--	set @flag_handover_req = N'1' ;

	--	select	@handover_req_code = code
	--			,@type_handover = type
	--	from	dbo.handover_request
	--	where	reff_code		  = @reff_code
	--			and left(type, 6) = 'RETURN'
	--			and handover_code is null ;
	--end ;
	else
	begin
		-- jika ada di handover hold
		if exists
		(
			select	1
			from	dbo.handover_asset
			where	reff_code  = @reff_code
					and status = 'HOLD'
					and code   <> @p_code
		)
		begin
			set @flag_handover_req = N'0' ;

			select	@handover_code	= code
					,@handover_type = type
			from	dbo.handover_asset
			where	reff_code  = @reff_code
					and status = 'HOLD'
					and code   <> @p_code ;
		end ;
		else
		begin
			set @flag_handover_req = N'x' ;
		end ;
	end ;

	select	@maturity_date = b.maturity_date
	from	ifinopl.dbo.agreement_asset a
			outer apply
	(
		select	max(b.maturity_date) maturity_date
		from	ifinopl.dbo.agreement_information b
		where	b.agreement_no = a.agreement_no
	) b
	where	isnull(fa_code, replacement_fa_code) = @fa_code 

	select	ha.code
			,ha.branch_code
			,ha.branch_name
			,ha.status
			,ha.transaction_date
			,ha.handover_date
			,case ha.type
				 when 'REPLACE IN' then 'REPLACE IN / ACTIVE'
				 when 'REPLACE OUT' then 'REPLACE OUT / REPLACEMENT'
				 when 'RETURN IN' then 'RETURN IN / REPLACEMENT'
				 when 'RETURN OUT' then 'RETURN OUT / ACTIVE'
				 else ha.type
			 end													'type_status'
			,ha.type
			,ha.remark
			,ha.fa_code
			,ha.handover_from
			,ha.handover_to
			,ha.unit_condition
			,ha.reff_code
			,ha.reff_name
			,ass.item_name											'fa_name'
			,hr.eta_date											'estimate_date'
			,@flag_handover_req										'flag_handover_req'
			,isnull(@handover_req_code, @handover_code)				'handover_request_code'
			,isnull(@handover_type, @type_handover)					'type_handover'
			,ha.process_status
			,isnull(hr.handover_phone_area, ha.handover_phone_area) 'handover_phone_area'
			,isnull(hr.handover_phone_no, ha.handover_phone_no)		'handover_phone_no'
			,hr.handover_address
			,ha.km
			,ha.plan_date
			,av.plat_no
			,av.chassis_no
			,av.engine_no
			,av.colour
			,hr.bbn
			,ass.agreement_no
			,ha.courier
			,ha.pic_handover_name
			,ha.pic_handover_address
			,ha.pic_handover_phone_area
			,ha.pic_handover_phone_no
			,ha.pic_recipient_name
			,ha.pic_recipient_phone_area
			,ha.pic_recipient_phone_no
			,isnull(convert(nvarchar(30), @maturity_date, 103), '-')	'maturity_date'
	from	handover_asset				   ha
			left join dbo.asset			   ass on (ass.code		   = ha.fa_code)
			left join dbo.handover_request hr on (hr.handover_code = ha.code)
			left join dbo.asset_vehicle	   av on (av.asset_code	   = ass.code)
	where	ha.code = @p_code ;
end ;
