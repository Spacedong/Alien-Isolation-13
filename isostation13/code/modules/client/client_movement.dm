/client/Move(n, direct)


	if(!mob)
		return // Moved here to avoid nullrefs below

	if(world.time < move_delay)	return//everything should be affected by move delays now

	move_delay = world.time//set move delay immediately to prevent this proc being run too many times, saving CPU

	if (isliving(mob) && !mob.control_object && !mob.incorporeal_move && !isobserver(mob))

		switch(mob.m_intent)
			if("run")
				if(mob.drowsyness > 0)
					move_delay += 6
				move_delay += 1+config.run_speed
				if (!isalien(mob) && prob(1)) mob.make_sound(SOUND_MEDIUM)
			if("walk")
				move_delay += 1+config.walk_speed
		move_delay += mob.movement_delay()

		if(config.Tickcomp)
			move_delay -= 1.3
			var/tickcomp = ((1/(world.tick_lag))*1.3)
			move_delay = move_delay + tickcomp

	//putting alien code stuff down here which may make movement code a lot faster

	if (isturf(n))//not if we're going into an object

		if (mob && !isalien(mob) && !istype(mob.loc, /atom/movable))//human being seen by alien

			var/no_aliens = 1

			for (var/mob/m in alien_list)
				if (1 == 1)//no need for a client check right now I guess
					if (abs(mob.x-m.x) <= 10 && abs(mob.y-m.y) <= 10 && mob.z == m.z)
						mob.seen_by_hive = TRUE
						no_aliens = 0

			if (no_aliens)
				mob.seen_by_hive = FALSE

		else if (mob && isalien(mob))

			for (var/mob/player in mob_list)
				if (istype(player.loc, /atom/movable))
					continue
				if (1 == 1)//no need for a client check right now I guess
					if (abs(mob.x-player.x) <= 10 && abs(mob.y-player.y) <= 10 && mob.z == player.z)
						player.seen_by_hive = TRUE
					else
						player.seen_by_hive = FALSE

	if(mob.control_object)
		Move_object(direct)

	if(mob.incorporeal_move && isobserver(mob))
		Process_Incorpmove(direct)
		return

	if(moving)	return FALSE

	if(locate(/obj/effect/stop/, mob.loc))
		for(var/obj/effect/stop/S in mob.loc)
			if(S.victim == mob)
				return

	if(mob.stat==DEAD && isliving(mob))
		mob.ghostize()
		return

	// handle possible Eye movement - this has its own move delay for the new processing movement system
	if(mob.eyeobj)
		move_delay = world.time
		move_delay += 1+config.run_speed
		return mob.EyeMove(n,direct)

	if(mob.transforming)	return//This is sota the goto stop mobs from moving var

	if(isliving(mob))
		var/mob/living/L = mob
		if(L.incorporeal_move)//Move though walls
			move_delay = world.time
			move_delay += 1+config.run_speed
			Process_Incorpmove(direct)
			return
		if(mob.client)
			if(mob.client.view != world.view) // If mob moves while zoomed in with device, unzoom them.
				for(var/obj/item/item in mob.contents)
					if(item.zoom)
						item.zoom()
						break
				/*
				if(locate(/obj/item/weapon/gun/energy/sniperrifle, mob.contents))		// If mob moves while zoomed in with sniper rifle, unzoom them.
					var/obj/item/weapon/gun/energy/sniperrifle/s = locate() in mob
					if(s.zoom)
						s.zoom()
				if(locate(/obj/item/device/binoculars, mob.contents))		// If mob moves while zoomed in with binoculars, unzoom them.
					var/obj/item/device/binoculars/b = locate() in mob
					if(b.zoom)
						b.zoom()
				*/

	if(Process_Grab())	return

	if(!mob.canmove)
		return

	//if(istype(mob.loc, /turf/space) || (mob.flags & NOGRAV))
	//	if(!mob.Process_Spacemove(0))	return FALSE

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)

	if((istype(mob.loc, /turf/space)) || (mob.lastarea.has_gravity == 0))
		if(!mob.Process_Spacemove(0))	return FALSE

	if(isobj(mob.loc) || ismob(mob.loc))//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(isturf(mob.loc))

		if(mob.restrained())//Why being pulled while cuffed prevents you from moving
			for(var/mob/M in range(mob, 1))
				if(M.pulling == mob)
					if(!M.restrained() && M.stat == 0 && M.canmove && mob.Adjacent(M))
						src << "\blue You're restrained! You can't move!"
						return FALSE
					else
						M.stop_pulling()

		if(mob.pinned.len)
			src << "\blue You're pinned to a wall by [mob.pinned[1]]!"
			return FALSE



		var/tickcomp = 0 //moved this out here so we can use it for vehicles
		if(config.Tickcomp)
			// move_delay -= 1.3 //~added to the tickcomp calculation below
			tickcomp = ((1/(world.tick_lag))*1.3) - 1.3
			move_delay = move_delay + tickcomp

		if(istype(mob.buckled, /obj/vehicle))
			//manually set move_delay for vehicles so we don't inherit any mob movement penalties
			//specific vehicle move delays are set in code\modules\vehicles\vehicle.dm
			move_delay = world.time + tickcomp
			//drunk driving
			if(mob.confused)
				direct = pick(cardinal)
			return mob.buckled.relaymove(mob,direct)

		if(istype(mob.machine, /obj/machinery))
			if(mob.machine.relaymove(mob,direct))
				return

		if(mob.pulledby || mob.buckled) // Wheelchair driving!
			if(istype(mob.loc, /turf/space))
				return // No wheelchair driving in space
			if(istype(mob.pulledby, /obj/structure/bed/chair/wheelchair))
				return mob.pulledby.relaymove(mob, direct)
			else if(istype(mob.buckled, /obj/structure/bed/chair/wheelchair))
				if(ishuman(mob))
					var/mob/living/carbon/human/driver = mob
					var/obj/item/organ/external/l_hand = driver.get_organ("l_hand")
					var/obj/item/organ/external/r_hand = driver.get_organ("r_hand")
					if((!l_hand || l_hand.is_stump()) && (!r_hand || r_hand.is_stump()))
						return // No hands to drive your chair? Tough luck!
				//drunk wheelchair driving
				if(mob.confused)
					direct = pick(cardinal)
				move_delay += 2
				return mob.buckled.relaymove(mob,direct)

		//We are now going to move
		moving = 1
		//Something with pulling things
		if(locate(/obj/item/weapon/grab, mob))
			move_delay = max(move_delay, world.time + 7)
			var/list/L = mob.ret_grab()
			if(istype(L, /list))
				if(L.len == 2)
					L -= mob
					var/mob/M = L[1]
					if(M)
						if ((get_dist(mob, M) <= 1 || M.loc == mob.loc))
							var/turf/T = mob.loc
							. = ..()
							if (isturf(M.loc))
								var/diag = get_dir(mob, M)
								if ((diag - 1) & diag)
								else
									diag = null
								if ((get_dist(mob, M) > 1 || diag))
									step(M, get_dir(M.loc, T))
				else
					for(var/mob/M in L)
						M.other_mobs = 1
						if(mob != M)
							M.animate_movement = 3
					for(var/mob/M in L)
						spawn( 0 )
							step(M, direct)
							return
						spawn( 1 )
							M.other_mobs = null
							M.animate_movement = 2
							return

		else if(mob.confused)
			step(mob, pick(cardinal))
		else
			. = mob.SelfMove(n, direct)

		for (var/obj/item/weapon/grab/G in mob)
			if (G.state == GRAB_NECK)
				mob.set_dir(reverse_dir[direct])
			G.adjust_position()
		for (var/obj/item/weapon/grab/G in mob.grabbed_by)
			G.adjust_position()

		moving = 0

		return .

	return


/client/North(auto = 0)
	if (!processScheduler || !processScheduler.isRunning)
		auto = 1
	if (!auto)
		if (mob)
			mob.dir = NORTH
			pressing_move_key++
			spawn (4)
				pressing_move_key--
			return
	..()


/client/South(auto = 0)
	if (!processScheduler || !processScheduler.isRunning)
		auto = 1
	if (!auto)
		if (mob)
			mob.dir = SOUTH
			pressing_move_key++
			spawn (4)
				pressing_move_key--
			return
	..()


/client/West(auto = 0)
	if (!processScheduler || !processScheduler.isRunning)
		auto = 1
	if (!auto)
		if (mob)
			mob.dir = WEST
			pressing_move_key++
			spawn (4)
				pressing_move_key--
			return
	..()


/client/East(auto = 0)
	if (!processScheduler || !processScheduler.isRunning)
		auto = 1
	if (!auto)
		if (mob)
			mob.dir = EAST
			pressing_move_key++
			spawn (4)
				pressing_move_key--
			return
	..()


/client/proc/client_dir(input, direction=-1)
	return turn(input, direction*dir2angle(dir))

/client/Northeast()
	diagonal_action(NORTHEAST)
/client/Northwest()
	diagonal_action(NORTHWEST)
/client/Southeast()
	diagonal_action(SOUTHEAST)
/client/Southwest()
	diagonal_action(SOUTHWEST)

/client/Center()
	/* No 3D movement in 2D spessman game. dir 16 is Z Up
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	*/
	return
