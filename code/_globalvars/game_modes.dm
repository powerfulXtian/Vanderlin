GLOBAL_VAR_INIT(master_mode, "roguemode") //"extended"
GLOBAL_VAR_INIT(secret_force_mode, "roguemode") // if this is anything but "secret", the secret rotation will forceably choose this mode
GLOBAL_VAR(common_report) //Contains common part of roundend report
GLOBAL_VAR(survivor_report) //Contains shared survivor report for roundend report (part of personal report)


GLOBAL_VAR_INIT(wavesecret, 0) // meteor mode, delays wave progression, terrible name

//TODO clear this one up too
GLOBAL_DATUM(cult_narsie, /obj/singularity/narsie/large/cult)
