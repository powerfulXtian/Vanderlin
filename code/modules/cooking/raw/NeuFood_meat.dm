/* * * * * * * * * * * **
 *						*
 *		 NeuFood		*
 *		 (Meats)		*
 *						*
 * * * * * * * * * * * **/


/*-------------------\
| Raw meats and cuts |
\-------------------*/

// Template
/obj/item/reagent_containers/food/snacks/meat
	eat_effect = /datum/status_effect/debuff/uncookedfood
	list_reagents = list(/datum/reagent/consumable/nutriment = RAWMEAT_NUTRITION)
	icon_state = "meat"
	slice_batch = TRUE // so it takes more time, changed from FALSE
	filling_color = "#8f433a"
	bitesize = 1
	rotprocess = SHELFLIFE_SHORT
	chopping_sound = TRUE
	foodtype = RAW | MEAT
	drop_sound = 'sound/foley/dropsound/gen_drop.ogg'
	become_rot_type = /obj/item/reagent_containers/food/snacks/rotten/meat

/*	.............   Raw meat   ................ */
/obj/item/reagent_containers/food/snacks/meat/steak
	ingredient_size = 2
	name = "raw meat"
	fried_type = /obj/item/reagent_containers/food/snacks/cooked/frysteak
	cooked_type = /obj/item/reagent_containers/food/snacks/cooked/frysteak
	cooked_smell = /datum/pollutant/food/fried_meat
	slices_num = 2
	slice_path = /obj/item/reagent_containers/food/snacks/meat/mince/beef
	slice_bclass = BCLASS_CHOP

/obj/item/reagent_containers/food/snacks/meat/human
	name = "manflesh"
	foodtype = RAW | MEAT | GROSS

/*	.............   Pigflesh, strange meat, birdmeat   ................ */
/obj/item/reagent_containers/food/snacks/meat/fatty
	name = "raw pigflesh"
	icon_state = "pigflesh"
	fried_type = /obj/item/reagent_containers/food/snacks/cooked/ham
	cooked_type = /obj/item/reagent_containers/food/snacks/cooked/ham
	cooked_smell = /datum/pollutant/food/bacon
	slices_num = 2
	slice_path = /obj/item/reagent_containers/food/snacks/meat/mince/beef
	chopping_sound = TRUE

/obj/item/reagent_containers/food/snacks/meat/strange // Low-nutrient, kind of gross. Survival food.
	name = "strange meat"
	icon_state = "strange_meat"
	fried_type = /obj/item/reagent_containers/food/snacks/cooked/strange
	cooked_type = /obj/item/reagent_containers/food/snacks/cooked/strange
	cooked_smell = /datum/pollutant/food/fried_meat
	slice_path = null
	slices_num = 0

/obj/item/reagent_containers/food/snacks/meat/poultry
	name = "plucked bird"
	icon_state = "poultry"
	slice_path = /obj/item/reagent_containers/food/snacks/meat/poultry/cutlet
	cooked_type = /obj/item/reagent_containers/food/snacks/cooked/roastchicken
	cooked_smell = /datum/pollutant/food/fried_chicken
	fried_type = /obj/item/reagent_containers/food/snacks/cooked/roastchicken
	slices_num = 2
	slice_sound = TRUE
	ingredient_size = 4
	become_rot_type = /obj/item/reagent_containers/food/snacks/rotten/poultry

/obj/item/reagent_containers/food/snacks/meat/poultry/cutlet
	name = "bird meat"
	icon_state = "chickencutlet"
	ingredient_size = 2
	fried_type = /obj/item/reagent_containers/food/snacks/cooked/frybird
	slices_num = 2
	slice_bclass = BCLASS_CHOP
	slice_path = /obj/item/reagent_containers/food/snacks/meat/mince/poultry
	cooked_type = /obj/item/reagent_containers/food/snacks/cooked/frybird
	cooked_smell = /datum/pollutant/food/fried_chicken
	become_rot_type = /obj/item/reagent_containers/food/snacks/rotten/chickenleg

/*	........   Fish sounds   ................ */
/obj/item/reagent_containers/food/snacks/fish
	chopping_sound = TRUE
	slices_num = 2
	/// Number representing how rare the fish is, 0 is the lowest common fish
	var/rarity_rank = 0

/*	........   Cooked food template   ................ */ // No choppping double cooking etc prefixed
/obj/item/reagent_containers/food/snacks/cooked
	name = "cooked meat"
	desc = ""
	icon_state = "frysteak"
	list_reagents = list(/datum/reagent/consumable/nutriment = COOKED_MEAT_NUTRITION)
	rotprocess = SHELFLIFE_DECENT
	filling_color = "#8f433a"
	foodtype = MEAT
	become_rot_type = /obj/item/reagent_containers/food/snacks/rotten/meat

/*-----------------------\
| Mince & Sausage making |
\-----------------------*/

/*	.............   Minced meat & stuffing sausages   ................ */
/obj/item/reagent_containers/food/snacks/meat/mince
	name = "mince template. BUGREPORT"
	icon_state = "meatmince"
	ingredient_size = 2
	bitesize = 1
	slice_path = null
	filling_color = "#8a0000"
	rotprocess = SHELFLIFE_TINY
	cooked_type = null
	become_rot_type = /obj/item/reagent_containers/food/snacks/rotten/mince
/obj/item/reagent_containers/food/snacks/meat/mince/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	new /obj/effect/decal/cleanable/food/mess(get_turf(src))
	playsound(get_turf(src), 'sound/foley/meatslap.ogg', 100, TRUE, -1)
	..()
	qdel(src)
/obj/item/reagent_containers/food/snacks/meat/mince/attackby(obj/item/I, mob/living/user, params)
	if(user.mind)
		short_cooktime = (50 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*8))
		long_cooktime = (90 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*15))
	var/found_table = locate(/obj/structure/table) in (loc)
	if(istype(I, /obj/item/reagent_containers/food/snacks/meat/mince) && (!modified))
		if(isturf(loc)&& (found_table))
			to_chat(user, "<span class='notice'>Stuffing a wiener...</span>")
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user, long_cooktime, src))
				new /obj/item/reagent_containers/food/snacks/meat/sausage(loc)
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, (user.STAINT*0.5))
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/fat) && (!modified))
		if(isturf(loc)&& (found_table))
			to_chat(user, "<span class='notice'>Stuffing a wiener...</span>")
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user, long_cooktime, src))
				new /obj/item/reagent_containers/food/snacks/meat/sausage(loc)
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, (user.STAINT*0.5))
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	else
		return ..()


/obj/item/reagent_containers/food/snacks/meat/mince/beef
	name = "minced meat"
	icon_state = "meatmince"
	fried_type = /obj/item/reagent_containers/food/snacks/meat/mince/beef/cooked
/obj/item/reagent_containers/food/snacks/meat/mince/beef/cooked
	eat_effect = null
	foodtype = MEAT
	rotprocess = SHELFLIFE_DECENT
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	color = "#a0655f"

/obj/item/reagent_containers/food/snacks/meat/mince/fish
	name = "minced fish"
	icon_state = "fishmince"
	fried_type = /obj/item/reagent_containers/food/snacks/meat/mince/fish/cooked
/obj/item/reagent_containers/food/snacks/meat/mince/fish/cooked
	eat_effect = null
	foodtype = MEAT
	rotprocess = SHELFLIFE_DECENT
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	color = "#a0655f"

/obj/item/reagent_containers/food/snacks/meat/mince/poultry
	name = "mince poultry"
	icon_state = "birdmince"
	fried_type = /obj/item/reagent_containers/food/snacks/meat/mince/poultry/cooked
/obj/item/reagent_containers/food/snacks/meat/mince/poultry/cooked
	eat_effect = null
	foodtype = MEAT
	rotprocess = SHELFLIFE_DECENT
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	color = "#a0655f"

/*	..................   METT   ................... */
/obj/item/reagent_containers/food/snacks/meat/mince/beef/mett
	name = "grenzel mett"
	desc = "A popular toping for bread in Grenzelhoft, while simply bizarr to people from vanderlin"
	icon_state = "mett_minced"
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_NUTRITIOUS)
	bitesize = 3
	slice_path = /obj/item/reagent_containers/food/snacks/meat/mince/beef/mett/slice
	slices_num = 3
	slice_batch = TRUE
	slice_sound = TRUE
	eat_effect = null
	rotprocess = SHELFLIFE_TINY
	faretype = FARE_POOR

/obj/item/reagent_containers/food/snacks/meat/mince/beef/mett/slice
	name = "grenzel mett"
	icon_state = "mett_slice"
	bitesize = 1
	slices_num = FALSE
	slice_path = FALSE
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_POOR)

/obj/item/reagent_containers/food/snacks/meat/mince/beef/attackby(obj/item/I, mob/living/user, params)
	..()
	if(user.mind)
		short_cooktime = (50 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*7))
		long_cooktime = (90 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*14))
	var/found_table = locate(/obj/structure/table) in (loc)
	if(istype(I, /obj/item/reagent_containers/food/snacks/veg/onion_sliced))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/kneading_alt.ogg', 90, TRUE, -1)
			to_chat(user, span_notice("Kneading onions into the mince..."))
			if(do_after(user,long_cooktime, src))
				new /obj/item/reagent_containers/food/snacks/meat/mince/beef/mett(loc)
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, (user.STAINT*0.5))
				qdel(I)
				qdel(src)

/*	..................   Sausage & Wiener   ................... */
/obj/item/reagent_containers/food/snacks/meat/sausage
	name = "raw sausage"
	icon_state = "raw_wiener"
	ingredient_size = 1
	fried_type = /obj/item/reagent_containers/food/snacks/cooked/sausage
	cooked_type = /obj/item/reagent_containers/food/snacks/cooked/sausage
	cooked_smell = /datum/pollutant/food/sausage
	become_rot_type = /obj/item/reagent_containers/food/snacks/rotten/sausage

/obj/item/reagent_containers/food/snacks/meat/wiener
	name = "raw wiener"
	icon_state = "raw_wiener"
	ingredient_size = 1
	fried_type = /obj/item/reagent_containers/food/snacks/cooked/sausage/wiener
	cooked_type = /obj/item/reagent_containers/food/snacks/cooked/sausage/wiener
	cooked_smell = /datum/pollutant/food/sausage
	become_rot_type = /obj/item/reagent_containers/food/snacks/rotten/sausage


