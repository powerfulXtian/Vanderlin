/obj/structure/closet
	name = "closet"
	desc = ""
	icon = 'icons/obj/closet.dmi'
	icon_state = "generic"
	density = TRUE
	drag_slowdown = 1.5		// Same as a prone mob
	max_integrity = 200
	integrity_failure = 0.25
	armor = list("blunt" = 20, "slash" = 20, "stab" = 20,  "piercing" = 10, "fire" = 70, "acid" = 60)

	var/icon_door = null
	var/icon_door_override = FALSE //override to have open overlay use icon different to its base's
	var/secure = FALSE //secure locker or not, also used if overriding a non-secure locker with a secure door overlay to add fancy lights
	var/opened = FALSE
	var/welded = FALSE
	var/locked = FALSE
	var/large = TRUE
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/breakout_time = 1200
	var/message_cooldown
	var/can_weld_shut = TRUE
	var/horizontal = FALSE
	var/allow_objects = FALSE
	var/allow_dense = FALSE
	var/dense_when_open = FALSE //if it's dense when open or not
	var/max_mob_size = MOB_SIZE_HUMAN //Biggest mob_size accepted by the container
	var/mob_storage_capacity = 2 // how many human sized mob/living can fit together inside a closet.
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.
	var/open_sound = 'sound/misc/cupboard_open.ogg'
	var/close_sound = 'sound/misc/cupboard_close.ogg'
	var/open_sound_volume = 100
	var/close_sound_volume = 100
	var/material_drop
	var/material_drop_amount = 2
	var/delivery_icon = "deliverycloset" //which icon to use when packagewrapped. null to be unwrappable.
	var/anchorable = TRUE
	var/icon_welded = "welded"
	var/keylock = FALSE
	var/lockid = null
	var/masterkey = FALSE
	throw_speed = 1
	throw_range = 1
	anchored = FALSE
	/// true whenever someone with the strong pull component is dragging this, preventing opening
	// var/strong_grab = FALSE

/obj/structure/closet/pre_sell()
	open()
	..()

/obj/structure/closet/Initialize(mapload)
	if(mapload && !opened)		// if closed, any item at the crate's loc is put in the contents
		addtimer(CALLBACK(src, PROC_REF(take_contents)), 0)
	. = ..()
	update_icon()
	PopulateContents()

//USE THIS TO FILL IT, NOT INITIALIZE OR NEW
/obj/structure/closet/proc/PopulateContents()
	return

/obj/structure/closet/Destroy()
	dump_contents()
	return ..()

/obj/structure/closet/update_icon()
	cut_overlays()
	if(!opened)
		layer = OBJ_LAYER
		if(icon_door)
			add_overlay("[icon_door]_door")
		else
			add_overlay("[icon_state]_door")
		if(welded)
			add_overlay(icon_welded)
		if(secure && !broken)
			if(locked)
				add_overlay("locked")
			else
				add_overlay("unlocked")

	else
		layer = BELOW_OBJ_LAYER
		if(icon_door_override)
			add_overlay("[icon_door]_open")
		else
			add_overlay("[icon_state]_open")

/obj/structure/closet/examine(mob/user)
	. = ..()
/*	if(welded)
		. += "<span class='notice'>It's welded shut.</span>"
	if(anchored)
		. += "<span class='notice'>It is <b>bolted</b> to the ground.</span>"
	if(opened)
		. += "<span class='notice'>The parts are <b>welded</b> together.</span>"
	else if(secure && !opened)
		. += "<span class='notice'>Alt-click to [locked ? "unlock" : "lock"].</span>"
	if(isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_SKITTISH))
			. += "<span class='notice'>Ctrl-Shift-click [src] to jump inside.</span>"*/

/obj/structure/closet/CanPass(atom/movable/mover, turf/target)
	if(wall_mounted)
		return TRUE
	return !density

/obj/structure/closet/proc/can_open(mob/living/user)
	if(welded || locked)
		if(user)
			to_chat(user, "<span class='warning'>Locked.</span>" )
		return FALSE
	// if(strong_grab && pulledby != user)
	// 	to_chat(user, span_danger("[pulledby] has an incredibly strong grip on [src], preventing it from opening."))
	// 	return FALSE
//	var/turf/T = get_turf(src)
//	for(var/mob/living/L in T)
//		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
//			if(user)
//				to_chat(user, "<span class='danger'>There's something large on top of [src], preventing it from opening.</span>" )
//			return FALSE
	return TRUE

/obj/structure/closet/proc/can_close(mob/living/user)
//	var/turf/T = get_turf(src)
//	for(var/obj/structure/closet/closet in T)
//		if(closet != src && !closet.wall_mounted)
//			return FALSE
//	for(var/mob/living/L in T)
//		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
//			if(user)
//				to_chat(user, "<span class='danger'>There's something too large in [src], preventing it from closing.</span>")
//			return FALSE
	return TRUE

/obj/structure/closet/dump_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in src)
		AM.forceMove(L)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM, dir)
	if(throwing)
		throwing.finalize(FALSE)

/obj/structure/closet/proc/take_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in L)
		if(AM != src && insert(AM) == -1) // limit reached
			break

/obj/structure/closet/proc/open(mob/living/user)
	if(opened)
		return
	if(user)
		if(!can_open(user))
			return
	playsound(loc, open_sound, open_sound_volume, FALSE, -3)
	opened = TRUE
	if(!dense_when_open)
		density = FALSE
//	climb_time *= 0.5 //it's faster to climb onto an open thing
	dump_contents()
	update_icon()
	return 1

/obj/structure/closet/proc/insert(atom/movable/AM)
	if(contents.len >= storage_capacity)
		return -1
	if(insertion_allowed(AM))
		AM.forceMove(src)
		return TRUE
	else
		return FALSE

/obj/structure/closet/proc/insertion_allowed(atom/movable/AM)
	if(ismob(AM))
		testing("begin")
		if(!isliving(AM)) //let's not put ghosts or camera mobs inside closets...
			return FALSE
		var/mob/living/L = AM
		if(L.anchored || (L.buckled && L.buckled != src) || L.incorporeal_move || L.has_buckled_mobs())
			return FALSE
		if(L.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if(horizontal && L.density)
				return FALSE
			if(L.mob_size > max_mob_size)
				return FALSE
			var/mobs_stored = 0
			for(var/mob/living/M in contents)
				if(++mobs_stored >= mob_storage_capacity)
					return FALSE
			for(var/obj/structure/closet/crate/C in contents)
				if(C != src)
					return FALSE
		testing("enmd")
		L.stop_pulling()

	else if(isobj(AM))
		if((!allow_dense && AM.density) || AM.anchored || AM.has_buckled_mobs())
			return FALSE
		else if(isitem(AM) && !HAS_TRAIT(AM, TRAIT_NODROP))
			return TRUE
		else if(!allow_objects)
			return FALSE
//		for(var/mob/living/M in contents)
//			return FALSE
	else
		return FALSE

	return TRUE

/obj/structure/closet/proc/close(mob/living/user)
	if(!opened)
		return FALSE
	if(user)
		if(!can_close(user))
			return FALSE
	take_contents()
	playsound(loc, close_sound, close_sound_volume, FALSE, -3)
//	climb_time = initial(climb_time)
	opened = FALSE
	density = TRUE
	update_icon()
	return TRUE

/obj/structure/closet/proc/toggle(mob/living/user)
	if(opened)
		return close(user)
	else
		return open(user)

/obj/structure/closet/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(flags_1 & NODECONSTRUCT_1))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/closet/obj_break(damage_flag)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		bust_open()
	..()


/obj/structure/closet/attackby(obj/item/W, mob/user, params)
	if(user in src)
		return
	if(istype(W, /obj/item/key) || istype(W, /obj/item/storage/keyring))
		trykeylock(W, user)
		return
	if(istype(W, /obj/item/lockpick))
		trypicklock(W, user)
		return
	if(src.tool_interact(W,user))
		return 1 // No afterattack
	return ..()

/obj/structure/closet/proc/trykeylock(obj/item/I, mob/user)
	if(opened)
		return
	if(!keylock)
		to_chat(user, "<span class='warning'>There's no lock on this.</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The lock is broken.</span>")
		return
	if(istype(I,/obj/item/storage/keyring))
		var/obj/item/storage/keyring/R = I
		if(!R.contents.len)
			return
		for(var/obj/item/key/K as anything in shuffle(R.contents.Copy()))
			var/combat = user.cmode
			if(combat && !do_after(user, 1 SECONDS, src))
				rattle()
				break
			if(K.lockid == lockid)
				togglelock(user)
				break
			if(combat)
				rattle()
		return
	var/obj/item/key/K = I
	if(K.lockid != lockid)
		rattle()
		return
	togglelock(user)

/obj/structure/closet/proc/rattle()
	playsound(src, 'sound/foley/doors/lockrattle.ogg', 100)
	var/oldx = pixel_x
	animate(src, pixel_x = oldx+1, time = 0.5)
	animate(pixel_x = oldx-1, time = 0.5)
	animate(pixel_x = oldx, time = 0.5)

/obj/structure/closet/proc/trypicklock(obj/item/I, mob/user)
	if(opened)
		to_chat(user, "<span class='warning'>This cannot be picked while it is open.</span>")
		return
	if(!keylock)
		to_chat(user, "<span class='warning'>There's no lock on this.</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The lock is broken.</span>")
		return
	else
		var/lockprogress = 0
		var/locktreshold = 100

		var/obj/item/lockpick/P = I
		var/mob/living/L = user

		var/pickskill = user.mind.get_skill_level(/datum/skill/misc/lockpicking)
		var/perbonus = L.STAPER/5
		var/picktime = 70
		var/pickchance = 35
		var/moveup = 10

		picktime -= (pickskill * 10)
		picktime = clamp(picktime, 10, 70)

		moveup += (pickskill * 3)
		moveup = clamp(moveup, 10, 30)

		pickchance += pickskill * 10
		pickchance += perbonus
		pickchance *= P.picklvl
		pickchance = clamp(pickchance, 1, 95)



		while(!QDELETED(I) &&(lockprogress < locktreshold))
			if(!do_after(user, picktime, src))
				break
			if(prob(pickchance))
				lockprogress += moveup
				playsound(src.loc, pick('sound/items/pickgood1.ogg','sound/items/pickgood2.ogg'), 5, TRUE)
				to_chat(user, "<span class='warning'>Click...</span>")
				if(L.mind)
					var/amt2raise = L.STAINT
					var/boon = L.mind.get_learning_boon(/datum/skill/misc/lockpicking)
					L.mind.adjust_experience(/datum/skill/misc/lockpicking, amt2raise * boon)
				if(lockprogress >= locktreshold)
					to_chat(user, "<span class='deadsay'>The locking mechanism gives way.</span>")
					togglelock(user)
					return
				else
					continue
			else
				playsound(loc, 'sound/items/pickbad.ogg', 40, TRUE)
				I.take_damage(1, BRUTE, "blunt")
				to_chat(user, "<span class='warning'>Clack.</span>")
				continue

/obj/structure/closet/proc/tool_interact(obj/item/W, mob/user)//returns TRUE if attackBy call shouldnt be continued (because tool was used/closet was of wrong type), FALSE if otherwise
	. = FALSE
	if(opened)
		if(user.transferItemToLoc(W, drop_location())) // so we put in unlit welder too
			return TRUE



/obj/structure/closet/proc/after_weld(weld_state)
	return

/obj/structure/closet/MouseDrop_T(atom/movable/O, mob/living/user)
	if(!istype(O) || O.anchored || istype(O, /atom/movable/screen))
		return
	if(!istype(user) || user.incapacitated() || user.body_position == LYING_DOWN)
		return
	if(!Adjacent(user) || !user.Adjacent(O))
		return
	if(user == O) //try to climb onto it
		return ..()
	if(!opened)
		return
	if(!isturf(O.loc))
		return

	var/actuallyismob = FALSE
	if(isliving(O))
		actuallyismob = TRUE
	else if(!isitem(O))
		return
	var/turf/T = get_turf(src)
	add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] [actuallyismob ? "tries to ":""]stuff [O] into [src].</span>", \
						"<span class='warning'>I [actuallyismob ? "try to ":""]stuff [O] into [src].</span>", \
						"<span class='hear'>I hear clanging.</span>")
	if(actuallyismob)
		if(do_after(user, 4 SECONDS, O))
			user.visible_message(span_notice("[user] stuffs [O] into [src]."), \
								span_notice("I stuff [O] into [src]."), \
								span_hear("I hear a loud bang."))
			O.forceMove(T)
			close()
	else
		O.forceMove(T)
	return 1

/obj/structure/closet/relaymove(mob/user)
	if(user.stat || !isturf(loc) || !isliving(user))
		return
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, "<span class='warning'>I'm trapped!</span>")
		return
	container_resist(user)

/obj/structure/closet/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.body_position == LYING_DOWN && get_dist(src, user) > 0)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	toggle(user)

/obj/structure/closet/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/closet/verb/verb_toggleopen()
	set src in view(1)
	set hidden = 1
	set name = "Toggle Open"

	if(!usr.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return

	if(iscarbon(usr))
		return toggle(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/AM)
	open()
	if(AM.loc == src)
		return 0
	return 1

/obj/structure/closet/container_resist(mob/living/user)
	if(opened)
		return
	if(ismovableatom(loc))
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		var/atom/movable/AM = loc
		AM.relay_container_resist(user, src)
		return
	if(!welded && !locked)
		open()
		return

	//okay, so the closet is either welded or locked... resist!!!
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message("<span class='warning'>[src] shakes violently!</span>")

/obj/structure/closet/proc/bust_open()
	welded = FALSE //applies to all lockers
	locked = FALSE //applies to critter crates and secure lockers only
	broken = TRUE //applies to secure lockers only
	open()

/obj/structure/closet/proc/togglelock(mob/living/user)
	if(opened)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(locked)
		user.visible_message("<span class='warning'>[user] unlocks [src].</span>", \
			"<span class='notice'>I unlock [src].</span>")
		playsound(src, 'sound/foley/doors/lock.ogg', 100)
		locked = FALSE
	else
		user.visible_message("<span class='warning'>[user] locks [src].</span>", \
			"<span class='notice'>I lock [src].</span>")
		playsound(src, 'sound/foley/doors/lock.ogg', 100)
		locked = TRUE

/obj/structure/closet/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 1)

/obj/structure/closet/contents_explosion(severity, target)
	for(var/atom/A in contents)
		A.ex_act(severity, target)
		CHECK_TICK

/obj/structure/closet/AllowDrop()
	return TRUE
