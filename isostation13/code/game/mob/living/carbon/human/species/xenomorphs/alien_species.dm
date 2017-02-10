//Stand-in until this is made more lore-friendly.
/datum/species/xenos
	name = "Xenomorph Base" //to distinguish from new /datum/species/xenos/new_xeno
	name_plural = "Xenomorphs"

	default_language = "Xenomorph"
	language = "Hivemind"
	unarmed_types = list(/datum/unarmed_attack/claws/strong, /datum/unarmed_attack/bite/strong)


	hud_type = /datum/hud_data/alien
	rarity_value = 3

	has_fine_manipulation = FALSE
	can_pick_up_stuff = FALSE
	siemens_coefficient = 0
	gluttonous = GLUT_ANYTHING

	eyes = "blank_eyes"

	brute_mod = 0.2 // Hardened carapace.
	burn_mod = 0.33 //worse against fire
	stun_mod = 0.05 //worst against stuns
	agony_mod = 0.05//very good against paindmg

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	flags =  NO_BREATHE | NO_SCAN | NO_PAIN | NO_SLIP | NO_POISON | NO_MINOR_CUT
	spawn_flags = IS_RESTRICTED

	reagent_tag = IS_XENOS

	blood_color = "#05EE05"
	flesh_color = "#282846"
	gibbed_anim = "gibbed-a"
	dusted_anim = "dust-a"
	death_message = "lets out a waning guttural screech, green blood bubbling from its maw."
	death_sound = 'sound/voice/hiss6.ogg'

//	speech_sounds = list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
	speech_chance = 100
	speech_sounds = list("x_a_speak")

	breath_type = null
	poison_type = null

	vision_flags = SEE_SELF|SEE_MOBS|SEE_OBJS
	darksight_addendum = 3 //fix it

	has_organ = list(
		"heart" =           /obj/item/organ/heart,
		"brain" =           /obj/item/organ/brain/xeno,
		"plasma vessel" =   /obj/item/organ/xenos/plasmavessel,
		"hive node" =       /obj/item/organ/xenos/hivenode,
		)

	bump_flag = ALIEN
	swap_flags = ~HEAVY
	push_flags = (~HEAVY) ^ ROBOT

	var/alien_number = 0
	var/caste_name = "creature" // Used to update alien name.
	var/weeds_heal_rate = 1     // Health regen on weeds.
	var/weeds_plasma_rate = 5   // Plasma regen on weeds.
	//verb helpers
	var/delays[100]

/datum/species/xenos/proc/alerted(atomic, alerted)
	if (!alerted)
		return
	var/atom/a = atomic
	if (square_dist(atomic, alerted) <= 5)//don't bother with a sound
		return FALSE
	if (istype(a))
		alerted << "<span class = 'alium'><i>You hear a sound coming from [a.find_nearest_vent()]!</i></span>"
		return TRUE

	else if (!a)
		alerted << "<span class = 'alium'><i>You hear a sound coming from nearby!</i></span>"
		return TRUE
	else
		return FALSE

/datum/species/xenos/attack_hand_special(var/atomic)
	if (istype(atomic, /obj/structure/closet))
		var/obj/structure/closet/closet = atomic
		//search for holder
		for (var/mob/living/carbon/human/H in alien_list)
			if (istype(H) && H.client && H.species && H.species == src)
				closet.xeno_toggle(H)
				return TRUE//override attack_hand
				break
	return ..()//return FALSE


/datum/species/xenos/table_climb_time()
	return 10

/datum/species/xenos/get_bodytype()
	return "Xenomorph"

/datum/species/xenos/get_random_name()
	return "alien [caste_name] ([alien_number])"

/datum/species/xenos/can_understand(var/mob/other)

	if(istype(other,/mob/living/carbon/alien/larva))
		return TRUE

	return FALSE


/datum/species/xenos/hug(var/mob/living/carbon/human/H,var/mob/living/target)
	H.visible_message("<span class='notice'>[H] caresses [target] with its scythe-like arm.</span>", \
					"<span class='notice'>You caress [target] with your scythe-like arm.</span>")

/datum/species/xenos/handle_death()
	for (var/mob/living/carbon/human/H in player_list)
		if (istype(H) && H.species && H.species == src)
			alien_message("[H] has been slain at [get_area(H)]!")

/datum/species/xenos/handle_post_spawn(var/mob/living/carbon/human/H)

	if(H.mind)
		H.mind.assigned_role = "Alien"
		H.mind.special_role = "Alien"

	alien_number++ //Keep track of how many aliens we've had so far.
	H.real_name = "alien [caste_name] ([alien_number])"
	H.name = H.real_name

	alien_list += src

	delays["tear girder"] = -1

	..()



//start "new xenos"
/datum/species/xenos/new_xeno
	name = "Xenomorph"
	caste_name = "N/A"
	weeds_plasma_rate = 15
	slowdown = -1
	tail = null
	rarity_value = 5


	icobase = 'icons/mob/human_races/xenos/r_xenos_drone.dmi'
	deform =  'icons/mob/human_races/xenos/r_xenos_drone.dmi'
	icon_template = 'icons/mob/alien_new.dmi'
	forced_stand_icon_state = "base_s"
	forced_rest_icon_state = "base_l"
	forced_dead_icon_state = "base_d"
	uses_no_overlays = 1

	has_organ = list(
		"heart" =           /obj/item/organ/heart,
		"brain" =           /obj/item/organ/brain/xeno,
		"plasma vessel" =   /obj/item/organ/xenos/plasmavessel/queen,
		"acid gland" =      /obj/item/organ/xenos/acidgland,
		"hive node" =       /obj/item/organ/xenos/hivenode,
		"resin spinner" =   /obj/item/organ/xenos/resinspinner,
		"egg sac" =         /obj/item/organ/xenos/eggsac,
		"resin spinner" =   /obj/item/organ/xenos/resinspinner,
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/plant,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/tear_girder,
	//	/mob/living/carbon/human/proc/evolve,
	//	/mob/living/carbon/human/proc/resin,
		/mob/living/carbon/human/proc/make_nest,
		/mob/living/carbon/human/proc/corrosive_acid,
	//	/mob/living/carbon/human/proc/tackle,
		/mob/living/carbon/human/proc/headbite,
		/mob/living/carbon/human/proc/leap,
		/mob/living/carbon/human/proc/psychic_whisper,
		/mob/living/carbon/human/proc/neurotoxin,
		///mob/living/carbon/human/proc/lay_egg,
		/mob/living/carbon/human/proc/transfer_plasma,
	//	/mob/living/carbon/human/proc/xeno_infest,
		/mob/living/carbon/human/proc/prydoor
		)


/datum/species/xenos/new_xeno/handle_post_spawn(var/mob/living/carbon/human/H)
	..()
	H.real_name = "Xenomorph ([alien_number])"
	H.name = H.real_name
	alien_list += H

//end "new xenos"

/datum/species/xenos/drone
	name = "Xenomorph Drone"
	caste_name = "drone"
	weeds_plasma_rate = 15
	slowdown = 1
	tail = "xenos_drone_tail"
	rarity_value = 5

	icobase = 'icons/mob/human_races/xenos/r_xenos_drone.dmi'
	deform =  'icons/mob/human_races/xenos/r_xenos_drone.dmi'

	has_organ = list(
		"heart" =           /obj/item/organ/heart,
		"brain" =           /obj/item/organ/brain/xeno,
		"plasma vessel" =   /obj/item/organ/xenos/plasmavessel/queen,
		"acid gland" =      /obj/item/organ/xenos/acidgland,
		"hive node" =       /obj/item/organ/xenos/hivenode,
		"resin spinner" =   /obj/item/organ/xenos/resinspinner,
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/plant,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/evolve,
		///mob/living/carbon/human/proc/resin,
		/mob/living/carbon/human/proc/corrosive_acid
		)

/datum/species/xenos/drone/handle_post_spawn(var/mob/living/carbon/human/H)

	var/mob/living/carbon/human/A = H
	if(!istype(A))
		return ..()
//	var/x = new/datum/light_source(H,H)
	..()

/datum/species/xenos/hunter

	name = "Xenomorph Hunter"
	weeds_plasma_rate = 5
	caste_name = "hunter"
	slowdown = -2
	total_health = 150
	tail = "xenos_hunter_tail"

	icobase = 'icons/mob/human_races/xenos/r_xenos_hunter.dmi'
	deform =  'icons/mob/human_races/xenos/r_xenos_hunter.dmi'

	has_organ = list(
		"heart" =           /obj/item/organ/heart,
		"brain" =           /obj/item/organ/brain/xeno,
		"plasma vessel" =   /obj/item/organ/xenos/plasmavessel/hunter,
		"hive node" =       /obj/item/organ/xenos/hivenode,
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/tackle,
		/mob/living/carbon/human/proc/gut,
		/mob/living/carbon/human/proc/leap,
		/mob/living/carbon/human/proc/psychic_whisper,
		/mob/living/carbon/human/proc/regurgitate
		)

/datum/species/xenos/sentinel
	name = "Xenomorph Sentinel"
	weeds_plasma_rate = 10
	caste_name = "sentinel"
	slowdown = 0
	total_health = 125
	tail = "xenos_sentinel_tail"

	icobase = 'icons/mob/human_races/xenos/r_xenos_sentinel.dmi'
	deform =  'icons/mob/human_races/xenos/r_xenos_sentinel.dmi'

	has_organ = list(
		"heart" =           /obj/item/organ/heart,
		"brain" =           /obj/item/organ/brain/xeno,
		"plasma vessel" =   /obj/item/organ/xenos/plasmavessel/sentinel,
		"acid gland" =      /obj/item/organ/xenos/acidgland,
		"hive node" =       /obj/item/organ/xenos/hivenode,
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/tackle,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/corrosive_acid,
		/mob/living/carbon/human/proc/neurotoxin
		)

/datum/species/xenos/queen

	name = "Xenomorph Queen"
	total_health = 250
	weeds_heal_rate = 5
	weeds_plasma_rate = 20
	caste_name = "queen"
	slowdown = 4
	tail = "xenos_queen_tail"
	rarity_value = 10

	icobase = 'icons/mob/human_races/xenos/r_xenos_queen.dmi'
	deform =  'icons/mob/human_races/xenos/r_xenos_queen.dmi'

	has_organ = list(
		"heart" =           /obj/item/organ/heart,
		"brain" =           /obj/item/organ/brain/xeno,
		"egg sac" =         /obj/item/organ/xenos/eggsac,
		"plasma vessel" =   /obj/item/organ/xenos/plasmavessel/queen,
		"acid gland" =      /obj/item/organ/xenos/acidgland,
		"hive node" =       /obj/item/organ/xenos/hivenode,
		"resin spinner" =   /obj/item/organ/xenos/resinspinner,
		)

	inherent_verbs = list(
		/mob/living/proc/ventcrawl,
		/mob/living/carbon/human/proc/psychic_whisper,
		/mob/living/carbon/human/proc/regurgitate,
		/mob/living/carbon/human/proc/lay_egg,
		/mob/living/carbon/human/proc/plant,
		/mob/living/carbon/human/proc/transfer_plasma,
		/mob/living/carbon/human/proc/corrosive_acid,
		/mob/living/carbon/human/proc/neurotoxin,
//		/mob/living/carbon/human/proc/resin,
		/mob/living/carbon/human/proc/xeno_infest
		)

/datum/species/xenos/queen/handle_login_special(var/mob/living/carbon/human/H)
	..()
	// Make sure only one official queen exists at any point.
	if(!alien_queen_exists(1,H))
		H.real_name = "alien queen ([alien_number])"
		H.name = H.real_name
	else
		H.real_name = "alien princess ([alien_number])"
		H.name = H.real_name

/datum/hud_data/alien

	icon = 'icons/mob/screen1_alien.dmi'
/*	has_a_intent =  1
	has_m_intent =  1
	has_warnings =  1
	has_hands =     1
	has_drop =      1
	has_throw =     1
	has_resist =    1
	has_pressure =  0
	has_nutrition = 0
	has_bodytemp =  0*/
	has_internals = 0

	gear = list(
	"belt" =         slot_belt,
	"l_hand" =       slot_l_hand,
	"r_hand" =       slot_r_hand,
	"mask" =         slot_wear_mask,
	"head" =         slot_head,
	"storage1" =     slot_l_store,
	"storage2" =     slot_r_store
	)