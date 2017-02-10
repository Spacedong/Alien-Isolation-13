#define WHITELISTFILE "data/whitelist.txt"

var/list/whitelist = list()
var/list/whitelist_synths = file2list("config/whitelistsynth.txt")

/hook/startup/proc/loadWhitelist()
	if(config.usewhitelist)
		load_whitelist()
	return 1

/proc/load_whitelist()
	whitelist = file2list(WHITELISTFILE)
	if(!whitelist.len)	whitelist = null

/proc/check_whitelist(mob/M /*, var/rank*/)
	if(!whitelist)
		return 0
	return ("[M.ckey]" in whitelist)


/proc/is_alien_whitelisted(mob/M, var/species)
	// always return true because we don't have xenos and related whitelist
	return 1

/proc/is_synth_whitelisted(mob/M)
	if (config.debug_mode_on)
		world << "synth WL debugging"
		world << whitelist_synths
		world << whitelist_synths[1]

	return (whitelist_synths.Find(M.ckey) || whitelist_synths.Find(M.key))

#undef WHITELISTFILE
