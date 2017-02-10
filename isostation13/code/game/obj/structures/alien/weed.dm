/obj/structure/alien/weed
	name = "weeds"
	desc = "Some kind of strange, black weeds."
	icon = 'icons/mob/alien_new.dmi'
	icon_state = ""
	health = 100
	anchored = 1
	layer = 3.1

/obj/structure/alien/weed/New(nloc, state)
	..()
	loc = nloc
	icon_state = state
	set_light(3,3, rgb(100,50,100))

/obj/structure/alien/weed/Destroy()
	..()

/obj/structure/alien/weed/ex_act(severity)
	switch(severity)
		if(1.0 to 2.0)
			qdel(src)
			return
		if (3.0)
			health-=pick(25,50)
	healthcheck()
	return
