
#define FILTERSCRIPT

#include <a_samp>
#include <YSI\y_iterate>
#include <YSI\y_commands>
#include <YSI\y_master>
#include <YSI\y_timers>
#include <sscanf2>

#include <streamer>

#pragma dynamic 500000

#define c_warn    0xDE6767FF
#define c_result  0x33CCFFFF

#define A_PATH "actors/"

#define ACTOR_LIMIT 5000
#define MAX_ANIMS 250
#define D_ANIM_LIST 555
#define D_ANIM_EDIT 556

#define A_LENGHT 32
#define A_NAME 16
#define DEFAULT_ANIMS 44

#define ADMIN_REQ true //Set to false for debugging

#define m_admin "(!) You don't have permission to use this command!"

#define SCM SendClientMessage

#define function%0(%1)         forward %0(%1); public %0(%1)

//DB Vars
new DB:db_Actors;
new DB:db_Anims;

//Actor vars
enum a_Info{
	animation,
	askin,
	Float:posx,
	Float:posy,
	Float:posz,
	Float:rot,
	invulnerable,
	bool:valid
};
new aInfo[ACTOR_LIMIT][a_Info];

new aHandle[ACTOR_LIMIT];
new Text3D:aLabel[ACTOR_LIMIT];
new actors;
new actoredit[MAX_PLAYERS];
new bool:alabels;

new bool:EditMode;
new aObject;

//Animations Vars
enum a_data{
	name[A_NAME],
	alib[A_LENGHT],
	aname[A_LENGHT],
	Float:fdelta,
	loop,
	lockx,
	locky,
	freeze,
	time,
	bool:valid
};
new anim_info[MAX_ANIMS][a_data];

new anims;

new aindex[MAX_PLAYERS];
new animpage[MAX_PLAYERS];
new nxtbtn[MAX_PLAYERS], prvbtn[MAX_PLAYERS];
new animedit[MAX_PLAYERS];


enum a_default
{
	daname[A_NAME],
	dlib[A_LENGHT],
	dname[A_LENGHT],
	Float:delta,
	ddata[5]
};

static const defaultAnim [][a_default] = {
	{ "CHAIRSIT",    "PED", 		  "SEAT_idle", 4.0999,   {1, 0, 0, 0, 0 }},
	{ "WAVE",    "ON_LOOKERS",   "wave_loop", 4.0,   {1, 0, 0, 0, 0 }},
	{ "SIT",    "MISC", 		  "Seat_talk_01",4.0,   {1,0,0,0,0 }},
	{ "PEE",    "PAULNMAC", 	  "Piss_in", 3.0,   {1, 0, 0, 0, 0 }},
	{ "CHAT",    "PED", 		  "IDLE_CHAT",4.1,   {1,1,1,1,1 }},
	{ "THREATEN",    "SHOP", 		  "ROB_Loop_Threat", 4.0,   { 1, 0, 0, 0, 0 }},
	{ "TAICHI",    "PARK",		  "Tai_Chi_Loop",4.0,   {1,0,0,0,0 }},
	{ "VOMIT",    "FOOD", 		  "EAT_Vomit_P", 3.0,   { 1, 0, 0, 0, 0 }},
	{ "BEACH SIT",    "BEACH",		  "SitnWait_loop_W",4.1,   {0,1,1,1,1 }},
	{ "LAUGH",    "RAPPING",  	  "Laugh_01", 4.0,   { 1, 0, 0, 0, 0 }},
	{ "MEDIC CPR",    "MEDIC",		  "CPR",4.1,   {1,1,1,1,1 }},
	{ "DEAD",    "PED",		  "KO_skid_front",4.1,   {0,1,1,1,0 }},
	{ "LAY",    "BEACH", 		  "bather", 4.0,   { 1, 0, 0, 0, 0 }},
	{ "RELAX",    "BEACH", 		  "ParkSit_M_loop", 4.0,   { 1, 0, 0, 0, 0 }},
	{ "RAP1",    "RAPPING",      "RAP_A_Loop",4.0,   {1,0,0,0,0 }},
	{ "RAP2",    "RAPPING",      "RAP_C_Loop",4.0,   {1,0,0,0,0 }},
	{ "RAP3",    "GANGS",        "prtial_gngtlkD",4.0,   {1,0,0,0,0 }},
	{ "RAP4",    "GANGS",        "prtial_gngtlkH",4.0,   {1,0,0,1,1 }},
	{ "LEAN1",    "GANGS",        "leanIDLE",4.0,   {1,1,1,1,0 }},
	{ "LEAN2",    "MISC",         "Plyrlean_loop",4.0,   {1,1,1,1,0 }},
	{ "CROSSARMS",    "COP_AMBIENT",  "Coplook_loop", 4.0,   { 1, 1, 1, 1, -1 }},
	{ "FUCKU",    "PED",		  	  "fucku",4.0,   {1,0,0,0,0 }},
	{ "FUCKU2",    "RIOT", 		  "RIOT_FUKU", 4.0,   { 1,0, 0, 0, 0 }},
	{ "SPRAY",    "SPRAYCAN",	  "spraycan_full",4.0,   {1,0,0,0,0 }},
	{ "PANIC",    "ped", 		  "cower", 3.0,   { 1, 0, 0, 0, 0 }},
	{ "DEALER",    "DEALER",		  "DEALER_IDLE",4.0,   {1,0,0,0,0 }},
	{ "LOUNGE",    "INT_HOUSE", 	  "LOU_Loop", 4.0,   { 1, 0, 0, 0, 0 }},
	{ "ANGRY",    "RIOT", 		  "RIOT_ANGRY", 4.0,   { 1,0, 0, 0, 0 }},
	{ "PROTEST",    "RIOT", 		  "RIOT_CHANT", 4.0,   { 1,0, 0, 0, 0 }},
	{ "SMOKE",    "SHOP",		  "Smoke_RYD",4.0,   {1,0,0,0,0 }},
	{ "PUNCH",    "RIOT", 		  "RIOT_PUNCHES", 4.0,   { 1,0, 0, 0, 0 }},
	{ "SCRATCH",    "MISC", 		  "Scratchballs_01", 4.0,   { 1, 0, 0, 0, 0 }},
	{ "WASH",    "INT_HOUSE", 	  "wash_up", 4.0,   { 1, 0, 0, 0, 0 }},
	{ "KICK",    "FIGHT_D",	  "FightD_G",4.0,   {1,0,0,0,0 }},
	{ "EXHAUST",    "PED",		  "IDLE_tired",3.0,   {1,0,0,0,0 }},
	{ "THROW",    "GRENADE", 	  "WEAPON_throw",4.0,   {1,0,0,0,0 }},
	{ "PUSH",    "GANGS",		  "shake_cara",4.0,   {1,0,0,0,0 }},
	{ "GREET",    "GANGS",		  "hndshkfa_swt",4.0,   {1,0,0,0,0 }},
	{ "SLAPASS",    "SWEET", 		  "sweet_ass_slap", 4.0,   {1, 0, 0, 0, 0 }},
	{ "DOORLOCKED",    "PED",		  "CAR_doorlocked_LHS", 4.0,   {1, 0, 0, 0, 0 }},
	{ "BOMB",    "BOMBER", 	  "BOM_Plant",          4.0,   {1, 0, 0, 0, 0 }},
	{ "NIGHTMARE",    "CRACK", 		  "crckdeth2",4.1,   {1,1,1,1,0 }},
    { "INJURED",    "SWEET", 		  "Sweet_injuredloop", 4.0,   {1, 0, 0, 0, 0 }}
};

public OnFilterScriptInit()
{
    LoadAnimLib();
	LoadActorDB();
	print("\n--------------------------------------");
	print(" Actor Galore editor by UnuAlex");
	print("--------------------------------------\n");
	return 1;
}


public OnFilterScriptExit()
{
	//Safely unloading the filterscript
	for(new i = 1; i < ACTOR_LIMIT; i++)
	{
	    if(aInfo[i][valid])
	    {
	        DestroyDynamicActor(aHandle[i]);
	        if(alabels)DestroyDynamic3DTextLabel(aLabel[i]);
	    }
	}
    db_close(db_Actors);
    db_close(db_Anims);
	return 1;
}

//Actor Commands

CMD:actorhelp(playerid, params[])
{
	#pragma unused params
	#if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif
	SCM(playerid, 0x207B18FF, "_______ACTOR GALORE HELP_______");
	SCM(playerid, 0xE99738FF, "/nactor - Create new actor.");
	SCM(playerid, 0x2EB023FF, "/dactor - Destroy actor.");
	SCM(playerid, 0xE99738FF, "/aactor - Change actor animation.");
	SCM(playerid, 0x2EB023FF, "/aexport - Export actors into script format.");
	SCM(playerid, 0xE99738FF, "/alabels - Show/Hide the actor labels.");
	SCM(playerid, 0x2EB023FF, "/apos - Relocate an actor at your current posiotion.");
	SCM(playerid, 0xE99738FF, "/atp - Relocate an actor at custom coordinates.");
	SCM(playerid, 0x2EB023FF, "/askin - Change actors skin.");
	SCM(playerid, 0xE99738FF, "/aedit - Move the actors with precision.");
	SCM(playerid, 0x2EB023FF, "/ainv - Toggle actors invulnerability.");
	SCM(playerid, 0xE99738FF, "/animadd - Add new animation to the library.");
	SCM(playerid, 0x2EB023FF, "/animedit - Edit the existing animations.");

	return 1;
}

CMD:nactor(playerid,params[])
{
    #if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif
	
	if(actors == ACTOR_LIMIT-1)return SCM(playerid,c_warn,"(!) You can't create any more actors!");

	new skin;
	if(sscanf(params,"d",skin))return SCM(playerid,-1,"Type: /nactor [Skin Id]");
	if(skin < 0 || skin > 311)return SCM(playerid,c_warn,"Invalid skin id (0 - 311)");
	
	new Float:pPos[4];
	GetPlayerPos(playerid,pPos[0],pPos[1],pPos[2]);
	GetPlayerFacingAngle(playerid,pPos[3]);
	
	NewActor(skin,pPos[0],pPos[1],pPos[2],pPos[3]);
	SetPlayerPos(playerid,pPos[0],pPos[1]+2,pPos[2]);
	
	new txt[64];
    format(txt, sizeof(txt),"[A] - New actor created! Skin: %d.",skin);
    SCM(playerid,c_result,txt);
	return 1;
}

CMD:dactor(playerid, params[])
{
    #if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif

	new actorid;
	if(sscanf(params,"d",actorid))return SCM(playerid,-1,"Type: /dactor [Actor Id]");
	if(!aInfo[actorid][valid])return SCM(playerid,c_warn,"Invalid actor id!");
	DeleteActor(actorid);
	new txt[64];
    format(txt, sizeof(txt),"[A] - Actor %d deleted!",actorid);
    SCM(playerid,c_result,txt);
    return 1;
}

CMD:aanim(playerid,params[])
{
    #if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif

	new actorid;
	if(sscanf(params,"d",actorid))return SCM(playerid,-1,"Type: /aanim [Actor Id]");
	if(!aInfo[actorid][valid])return SCM(playerid,c_warn,"Invalid actor id!");
	if(EditMode)return SCM(playerid,c_warn,"You can't change animations while editing actors!");
	animpage[playerid] = 1;
	aindex[playerid] = 1;
	AnimList(playerid, actorid);
	return 1;
}

CMD:aexport(playerid, params[])
{
    #if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif

	new path[32];
	if(sscanf(params,"s[32]",path))return SCM(playerid,-1,"Type:/aexport [File Name]");
	
	new check[64];
	format(check,sizeof(check),"%s%s.txt",A_PATH,path);
	new File:handle = fopen(check, io_read);

	// Check, if the file is opened
	if(handle)
	{
		fclose(handle);
		SCM(playerid,c_warn,"(!) This file name is already being used!");
		return 1;
	}
	else
	{
		ExportActors(path);
		new txt[64];
	    format(txt, sizeof(txt),"[A] - Your actors have been exported at scriptfiles/%s.txt!",path);
	    SCM(playerid,c_result,txt);
	}
	
	return 1;
}

CMD:alabels(playerid, params[])
{
	#pragma unused params
	#if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif
	if(alabels)
	{
	    for(new i=1; i < ACTOR_LIMIT; i++)
		{
		    if(aInfo[i][valid]) { DestroyDynamic3DTextLabel(aLabel[i]); }
		}
		SCM(playerid,c_result,"[A] - Actor labels are now hidden!");
		alabels = false;
	}
	else
	{
	    for(new i=1; i < ACTOR_LIMIT; i++)
		{
		    if(aInfo[i][valid]) {
		    	new lbl[20];
				format(lbl, sizeof(lbl), "Actor: %d",i);
                aLabel[i] = CreateDynamic3DTextLabel(lbl, -1,aInfo[i][posx], aInfo[i][posy], aInfo[i][posz]+1, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100);
			}
		}
		SCM(playerid,c_result,"[A] - Actor labels are now shown!");
		alabels = true;
	}
	return 1;
}

CMD:apos(playerid, params[])
{
    #if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif

    new actorid;
	if(sscanf(params,"d",actorid))return SCM(playerid,-1,"Type: /apos [Actor Id]");
	if(!aInfo[actorid][valid])return SCM(playerid,c_warn,"Invalid actor id!");
	new Float:pPos[4];
	GetPlayerPos(playerid,pPos[0],pPos[1],pPos[2]);
	GetPlayerFacingAngle(playerid,pPos[3]);
	aInfo[actorid][posx] = pPos[0], aInfo[actorid][posy] = pPos[1], aInfo[actorid][posz] = pPos[2], aInfo[actorid][rot] = pPos[3];
	SetPlayerPos(playerid,pPos[0],pPos[1]+2,pPos[2]);
	SaveActor(actorid);
	RefreshActor(actorid);
	new txt[64];
    format(txt, sizeof(txt),"[A] - Position changed for actor %d.",actorid);
    SCM(playerid,c_result,txt);
	return 1;
}

CMD:atp(playerid, params[])
{
    #if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif

    new actorid,Float:posX,Float:posY,Float:posZ,Float:Rot;
	if(sscanf(params,"dffff",actorid,posX,posY,posZ,Rot))return SCM(playerid,-1,"Type: /atp [Actor Id][PosX][PosY][PosZ][Rot]");
	if(!aInfo[actorid][valid])return SCM(playerid,c_warn,"Invalid actor id!");
	aInfo[actorid][posx] = posX, aInfo[actorid][posy] = posY, aInfo[actorid][posz] = posZ, aInfo[actorid][rot] = Rot;
	SaveActor(actorid);
	RefreshActor(actorid);
	new txt[64];
    format(txt, sizeof(txt),"[A] - Actor %d got teleported.",actorid);
    SCM(playerid,c_result,txt);
	return 1;
}


CMD:askin(playerid, params[])
{
    #if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif

    new actorid, skin;
	if(sscanf(params,"dd",actorid,skin))return SCM(playerid,-1,"Type: /askin [Actor Id][Skin Id]");
	if(!aInfo[actorid][valid])return SCM(playerid,c_warn,"Invalid actor id!");
	if(skin < 0 || skin > 311)return SCM(playerid,c_warn,"Invalid skin id (0 - 311)");
	aInfo[actorid][askin] = skin;
    SaveActor(actorid);
	RefreshActor(actorid);
	new txt[64];
    format(txt, sizeof(txt),"[A] - Skin changed for actor %d.",actorid);
    SCM(playerid,c_result,txt);
	return 1;
}

CMD:aedit(playerid, params[])
{
    #if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif

    new actorid;
	if(sscanf(params,"d",actorid))return SCM(playerid,-1,"Type: /aedit [Actor Id]");
	if(!aInfo[actorid][valid])return SCM(playerid,c_warn,"Invalid actor id!");
	if(EditMode == false)
	{
	    EditMode = true;
	    if(IsValidObject(aObject)) { CancelEdit(playerid); DestroyObject(aObject); }
		aObject = CreateObject(19574,aInfo[actorid][posx], aInfo[actorid][posy], aInfo[actorid][posz], 0, 0, aInfo[actorid][rot],100);
		EditObject(playerid,aObject);
		actoredit[playerid] = actorid;
		new txt[64];
	    format(txt, sizeof(txt),"[A] - Now editing actor %d.",actorid);
	    SCM(playerid,c_result,txt);
	}
	else
	{
	    EditMode = false;
		CancelEdit(playerid);
	    DestroyObject(aObject);
	    SCM(playerid,c_result,"[A] - Actor edit canceled.");
	}
	return 1;
}

CMD:ainv(playerid, params[])
{
    #if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif

    new actorid;
	if(sscanf(params,"d",actorid))return SCM(playerid,-1,"Type: /ainv [Actor Id]");
	if(!aInfo[actorid][valid])return SCM(playerid,c_warn,"Invalid actor id!");
	if(aInfo[actorid][invulnerable] == 0)
	{
	    aInfo[actorid][invulnerable] = 1;
		SetDynamicActorInvulnerable(actorid, 1);
		new txt[64];
	    format(txt, sizeof(txt),"[A] - Actor %d is now invulnerable.",actorid);
	    SCM(playerid,c_result,txt);
	}
	else
	{
	    aInfo[actorid][invulnerable] = 0;
		SetDynamicActorInvulnerable(actorid, 0);
		new txt[64];
	    format(txt, sizeof(txt),"[A] - Actor %d is now vulnerable.",actorid);
	    SCM(playerid,c_result,txt);
	}
	return 1;
}

//Animation Commands

CMD:animadd(playerid, params[])
{
    #if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif

	new animlib[A_LENGHT], animname[A_LENGHT];
	if(sscanf(params,"s[32]s[32]",animlib,animname))return SCM(playerid, -1, "Type: /animadd [anim-lib][anim-name]");
	if(strlen(animlib) > A_LENGHT)return SCM(playerid,c_warn,"(!) The 'anim-lib' string exceeds the character limit!");
	if(strlen(animname) > A_LENGHT)return SCM(playerid,c_warn,"(!) The 'anim-name' string exceeds the character limit!");

	AddAnimation(animlib, animname);

	PreloadAnimLib(playerid,animlib);

	SCM(playerid,c_result,"[A] -  You added a new animation. Use /animedit to change its parameters!");
	return 1;
}

CMD:animedit(playerid, params[])
{
	#pragma unused params
    #if ADMIN_REQ == true
	if(!IsPlayerAdmin(playerid))return SCM(playerid,c_warn, m_admin);
	#endif
	
	animpage[playerid] = 1;
	aindex[playerid] = 1;
	
	AnimEdit(playerid);
	return 1;
}


//Actor Functions

function LoadActorDB()
{
	alabels = true;
	actors = 0;
	//Creating database if it doesn't exist
	new path[32];
	format(path,sizeof(path),"%sactors.db",A_PATH);
	db_Actors = db_open(path);
	db_free_result(db_query(db_Actors,"CREATE TABLE IF NOT EXISTS `actors` (`actorid`,`animation`,`skin`,`posx`,`posy`,`posz`,`rot`,`invulnerable`)"));
	//Loading the data
	for(new i=1; i < ACTOR_LIMIT; i++)
	{
	    new query[48], DBResult:res;
 		format(query,sizeof(query),"SELECT * FROM `actors` WHERE `actorid` = '%d'",i);
        res = db_query(db_Actors,query);

        if(db_num_rows(res))
        {
            
            actors ++;
            new field[50];

            db_get_field_assoc(res, "animation", field, 50 );
            aInfo[i][animation] = strval(field);
            db_get_field_assoc(res, "skin", field, 50 );
            aInfo[i][askin] = strval(field);
            db_get_field_assoc(res, "posx", field, 50 );
            aInfo[i][posx] = floatstr(field);
            db_get_field_assoc(res, "posy", field, 50 );
            aInfo[i][posy] = floatstr(field);
            db_get_field_assoc(res, "posz", field, 50 );
            aInfo[i][posz] = floatstr(field);
            db_get_field_assoc(res, "rot", field, 50 );
            aInfo[i][rot] = floatstr(field);
            db_get_field_assoc(res, "invulnerable", field, 50 );
            aInfo[i][invulnerable] = strval(field);
            new lbl[20];
            format(lbl, sizeof(lbl), "Actor: %d",i);
            aHandle[i] = CreateDynamicActor(aInfo[i][askin], aInfo[i][posx], aInfo[i][posy], aInfo[i][posz], aInfo[i][rot], aInfo[i][invulnerable], 100.0, -1, -1, -1, 100.0);
            aLabel[i] = CreateDynamic3DTextLabel(lbl, -1, aInfo[i][posx], aInfo[i][posy], aInfo[i][posz]+1, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100);
            ActorAnimation(i, aInfo[i][animation]);
            
            aInfo[i][valid] = true;
            //printf("[A] - Actor %d loaded, animation %d.",i,aInfo[i][animation]);
		}
		db_free_result(res);
	}
	printf("[A] - %d actors successfully loaded!",actors);
	return 1;
}

function NewActor(skinid, Float:aposx, Float:aposy, Float:aposz, Float:arot)
{
	new aquery[48], DBResult:res;
    for(new i=1; i < ACTOR_LIMIT; i++)
	{
 		format(aquery,sizeof(aquery),"SELECT * FROM `actors` WHERE `actorid` = '%d'",i);
        res = db_query(db_Actors,aquery);
        if(!db_num_rows(res))
        {
		    aInfo[i][askin] = skinid, aInfo[i][posx] = aposx, aInfo[i][posy] = aposy, aInfo[i][posz] = aposz, aInfo[i][rot] = arot;
		    aInfo[i][animation] = 0; aInfo[i][invulnerable] = 0;
		    
			new lbl[20];
			format(lbl, sizeof(lbl), "Actor: %d",i);
		    aHandle[i] = CreateDynamicActor(skinid, aposx, aposy, aposz, arot, aInfo[i][invulnerable], 100.0, -1, -1, -1, 100.0);
		 	if(alabels) aLabel[i] = CreateDynamic3DTextLabel(lbl, -1,aposx, aposy, aposz+1, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100);
		 	
		 	ActorAnimation(i, aInfo[i][animation]);
		 	new query[512];
			format(query,sizeof(query),"INSERT INTO `actors` (`actorid`,`animation`,`skin`,`posx`,`posy`,`posz`,`rot`,`invulnerable`) VALUES('%d','%d','%d','%f','%f','%f','%f','%d')",
			i, 0, skinid, aposx, aposy, aposz, arot, 0);
			db_free_result(db_query(db_Actors,query));
			
			aInfo[i][valid] = true;
			
			actors ++;
		 	break;
	 	}
	 	db_free_result(res);
	}
	return 1;
}

function ActorAnimation(actorid, anim)
{
	if(anim == 0)
	{
	    ClearDynamicActorAnimations(aHandle[actorid]);
	}
	else
	{
	    if(!anim_info[anim][valid])
	    {
	        aInfo[actorid][animation] = 0;
	        ClearDynamicActorAnimations(aHandle[actorid]);
	        SaveActor(actorid);
	    }
	    ApplyDynamicActorAnimation(aHandle[actorid],anim_info[anim][alib],anim_info[anim][aname],anim_info[anim][fdelta],anim_info[anim][loop],anim_info[anim][lockx],anim_info[anim][locky],anim_info[anim][freeze],anim_info[anim][time]);
	}
	return 1;
}

function SaveActor(actorid)
{
    new query[300];
	format(query,sizeof(query),"UPDATE `actors` SET `animation` = '%d', `skin` = '%d', `posx` = '%f', `posy` = '%f', `posz` = '%f', `rot` = '%f', `invulnerable` = '%d' WHERE `actorid` = '%d'",
	aInfo[actorid][animation], aInfo[actorid][askin], aInfo[actorid][posx], aInfo[actorid][posy], aInfo[actorid][posz], aInfo[actorid][rot], aInfo[actorid][invulnerable],actorid);
	db_free_result(db_query(db_Actors,query));
	printf("Actor %d got saved",actorid);
	return 1;
}

function DeleteActor(actorid)
{
	DestroyDynamicActor(aHandle[actorid]);
	if(alabels)DestroyDynamic3DTextLabel(aLabel[actorid]);
	aInfo[actorid][valid] = false;
	new Query[64];
	format(Query,sizeof(Query),"DELETE FROM `actors` WHERE `actorid` = '%d'",actorid);
	db_free_result(db_query(db_Actors,Query));
	
	actors --;
	return 1;
}

function RefreshActor(actorid)
{
    DestroyDynamicActor(aHandle[actorid]);
	if(alabels)DestroyDynamic3DTextLabel(aLabel[actorid]);
	new lbl[20];
	format(lbl, sizeof(lbl), "Actor: %d",actorid);
	aHandle[actorid] = CreateDynamicActor(aInfo[actorid][askin], aInfo[actorid][posx], aInfo[actorid][posy], aInfo[actorid][posz], aInfo[actorid][rot], aInfo[actorid][invulnerable], 100.0, -1, -1, -1, 100.0);
	if(alabels)aLabel[actorid] = CreateDynamic3DTextLabel(lbl, -1,aInfo[actorid][posx], aInfo[actorid][posy], aInfo[actorid][posz]+1, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 100);
	ActorAnimation(actorid, aInfo[actorid][animation]);
	return 1;
}


function ExportActors(filename[])
{
 	new path[32], File:hFile, entry[256];
	format(path, sizeof(path),"%s%s.txt",A_PATH, filename);
	
    hFile = fopen(path, io_write);
	fwrite(hFile, "new actorvar;\n");
	for(new i = 1; i < ACTOR_LIMIT; i++)
	{
	    if(aInfo[i][valid])
	    {
    		format(entry, sizeof(entry), "actorvar = CreateDynamicActor(%d, %f, %f, %f, %f, %d, 100.0, -1, -1, -1, 100.0);\n",aInfo[i][askin], aInfo[i][posx], aInfo[i][posy], aInfo[i][posz], aInfo[i][rot], aInfo[i][invulnerable]);
    		fwrite(hFile, entry);
    		if(aInfo[i][animation] > 0 && anim_info[aInfo[i][animation]][valid])
    		{
    		    new anim = aInfo[i][animation];
    		    format(entry,sizeof(entry),"ApplyDynamicActorAnimation(actorvar,\"%s\",\"%s\",%f,%d,%d,%d,%d,%d);\n",anim_info[anim][alib],anim_info[anim][aname],anim_info[anim][fdelta],anim_info[anim][loop],anim_info[anim][lockx],anim_info[anim][locky],anim_info[anim][freeze],anim_info[anim][time]);
    		    fwrite(hFile, entry);
    		}
		}
    }
    fclose(hFile);
	return 1;
}

//Animation Library Functions

function LoadAnimLib()
{
	anims = 0;
	//Creating database if it doesn't exist
	new path[32];
	format(path,sizeof(path),"%sanimlib.db",A_PATH);
	db_Anims = db_open(path);
	db_free_result(db_query(db_Anims,"CREATE TABLE IF NOT EXISTS `anims` (`animid`,`name`,`alib`,`aname`,`fdelta`,`loop`,`lockx`,`locky`,`freeze`,`time`)"));
	//Loading the data
	for(new i=1; i < MAX_ANIMS; i++)
	{
	    new query[48], DBResult:res;
 		format(query,sizeof(query),"SELECT * FROM `anims` WHERE `animid` = '%d'",i);
        res = db_query(db_Anims,query);

        if(db_num_rows(res))
        {
            anims ++;
            new field[50];
            db_get_field_assoc(res, "name", field, 50 );
            format(anim_info[i][name], A_NAME, field);
            db_get_field_assoc(res, "alib", field, 50 );
            format(anim_info[i][alib], A_LENGHT, field);
            db_get_field_assoc(res, "aname", field, 50 );
            format(anim_info[i][aname], A_LENGHT, field);
            db_get_field_assoc(res, "fdelta", field, 50 );
            anim_info[i][fdelta] = floatstr(field);
            db_get_field_assoc(res, "loop", field, 50 );
            anim_info[i][loop] = strval(field);
            db_get_field_assoc(res, "lockx", field, 50 );
            anim_info[i][lockx] = strval(field);
            db_get_field_assoc(res, "locky", field, 50 );
            anim_info[i][locky] = strval(field);
            db_get_field_assoc(res, "freeze", field, 50 );
            anim_info[i][freeze] = strval(field);
            db_get_field_assoc(res, "time", field, 50 );
            anim_info[i][time] = strval(field);

            anim_info[i][valid] = true;
		}
		db_free_result(res);
	}
	if(anims == 0)//If there are no anims in the library add the default \/
	{
	    print("[A] - No animation found in the library. Importing default ones now...");

	    new query[512];
	    for(new i = 1; i < DEFAULT_ANIMS; i ++)
	    {
	        new idx = i - 1;
	        format(anim_info[i][name], A_NAME, defaultAnim[idx][daname]);
			format(anim_info[i][alib], A_LENGHT, defaultAnim[idx][dlib]);
			format(anim_info[i][aname], A_LENGHT, defaultAnim[idx][dname]);

			anim_info[i][fdelta] = defaultAnim[idx][delta];
			anim_info[i][loop] = defaultAnim[idx][ddata][0];
			anim_info[i][lockx] = defaultAnim[idx][ddata][1];
			anim_info[i][locky] = defaultAnim[idx][ddata][2];
			anim_info[i][freeze] = defaultAnim[idx][ddata][3];
			anim_info[i][time] = defaultAnim[idx][ddata][4];

			format(query,sizeof(query),"INSERT INTO `anims` (`animid`,`name`,`alib`,`aname`,`fdelta`,`loop`,`lockx`,`locky`,`freeze`,`time`) VALUES('%d','%s','%s','%s','%f','%d','%d','%d','%d','%d')",
			i, anim_info[i][name],anim_info[i][alib],anim_info[i][aname],anim_info[i][fdelta],anim_info[i][loop],anim_info[i][lockx],anim_info[i][locky],anim_info[i][freeze],anim_info[i][time]);
			db_free_result(db_query(db_Anims,query));

			anim_info[i][valid] = true;
			anims ++;
	    }
	    printf("[A] - Operation complete! %d default animations added to the library.", anims);
	}
	printf("[A] - %d animations successfully loaded!",anims);
	return 1;
}

function AddAnimation(animlib[], animname[])
{
	new query[48], DBResult:res;
    for(new i=1; i < MAX_ANIMS; i++)
	{
 		format(query,sizeof(query),"SELECT * FROM `anims` WHERE `animid` = '%d'",i);
        res = db_query(db_Anims,query);

        if(!db_num_rows(res))
        {

            //Set variables
            format(anim_info[i][name], A_NAME, "NEW ANIMATION");
			format(anim_info[i][alib], A_LENGHT, animlib);
			format(anim_info[i][aname], A_LENGHT, animname);

			anim_info[i][fdelta] = 4.0;
			anim_info[i][loop] = 1;
			anim_info[i][lockx] = 0;
			anim_info[i][locky] = 0;
			anim_info[i][freeze] = 0;
			anim_info[i][time] = 0;

			//Save in database
            new aquery[512];
			format(aquery,sizeof(aquery),"INSERT INTO `anims` (`animid`,`name`,`alib`,`aname`,`fdelta`,`loop`,`lockx`,`locky`,`freeze`,`time`) VALUES('%d','%s','%s','%s','%f','%d','%d','%d','%d','%d')",
			i, anim_info[i][name], anim_info[i][alib], anim_info[i][aname], anim_info[i][fdelta], anim_info[i][loop], anim_info[i][lockx], anim_info[i][locky], anim_info[i][freeze], anim_info[i][time]);
			db_free_result(db_query(db_Anims,aquery));

			anim_info[i][valid] = true;

			anims ++;
            break;
        }
        db_free_result(res);
	}
	return 1;
}

function SaveAnimation(animid)
{
    if(!anim_info[animid][valid])return printf("Error: Tried to update invalid animation %d!",animid);
    new query[300];
	format(query,sizeof(query),"UPDATE `anims` SET `name` = '%s', `alib` = '%s', `aname` = '%s', `fdelta` = '%f', `loop` = '%d', `lockx` = '%d', `locky` = '%d', `freeze` = '%d', `time` = '%d' WHERE `animid` = '%d'",
 	anim_info[animid][name], anim_info[animid][alib], anim_info[animid][aname], anim_info[animid][fdelta], anim_info[animid][loop], anim_info[animid][lockx], anim_info[animid][locky], anim_info[animid][freeze], anim_info[animid][time], animid);
	db_free_result(db_query(db_Anims,query));
	
	for(new i=1; i < ACTOR_LIMIT; i++)//Update Actors Animation
	{
	    if(aInfo[i][animation] == animid && aInfo[i][valid])
	    {
	        ActorAnimation(i, animid);
	    }
	}
	
	return 1;
}

function DeleteAnimation(animid)
{
	if(!anim_info[animid][valid])return printf("Error: Tried to delete invalid animation %d!",animid);
	anim_info[animid][valid] = false;
	new Query[64];
	format(Query,sizeof(Query),"DELETE FROM `anims` WHERE `animid` = '%d'",animid);
	db_free_result(db_query(db_Anims,Query));
	
	for(new i=1; i < ACTOR_LIMIT; i++)//Update Actors Animation
	{
	    if(aInfo[i][animation] == animid && aInfo[i][valid])
	    {
	        aInfo[i][animation] = 0;
	        ActorAnimation(i, 0);
	        SaveActor(i);
	    }
	}
	
	anims --;
	return 1;
}

function AnimList(playerid,actorid)
{
	new animlist[512];
	new itm, e = 1;
    if(animpage[playerid] == 1)
	{
	    aindex[playerid]=1;
	    e = 0;
		format(animlist,sizeof(animlist),"{E3391D}NO ANIMATION");
	}
	for(new i = aindex[playerid]; i <= 20*animpage[playerid]; i++)
	{
	    if(anim_info[i][valid])
	    {
	        itm++;
			format(animlist,sizeof(animlist),"%s\n%d.{1DE323}%s",animlist,i,anim_info[i][name]);
		}
		else
		{
		    itm++;
			format(animlist,sizeof(animlist),"%s\n%d.{DE771F}EMPTY",animlist,i);
		}
	}
	if(itm < 20) e = 2;
	if(itm == 20) { format(animlist,sizeof(animlist),"%s\nNext Page >>",animlist); nxtbtn[playerid] = itm+1-e; }
	if(animpage[playerid] > 1){ format(animlist,sizeof(animlist),"%s\nPrevious Page <<",animlist); prvbtn[playerid] = itm+2-e; }

	ShowPlayerDialog(playerid,D_ANIM_LIST,DIALOG_STYLE_LIST, "ACTOR ANIMATIONS", animlist, "Select","Cancel");
	actoredit[playerid] = actorid;
	return 1;
}

function AnimEdit(playerid)
{
	new animlist[512];
	new itm, e = 1;
	for(new i = aindex[playerid] ; i <= 20*animpage[playerid]; i++)
	{
	    if(anim_info[i][valid])
	    {
	        itm++;
			format(animlist,sizeof(animlist),"%s\n%d.{1DE323}%s",animlist,i,anim_info[i][name]);
		}
		else
		{
		    itm++;
			format(animlist,sizeof(animlist),"%s\n%d.{DE771F}EMPTY",animlist,i);
		}
	}
	if(itm < 20) e = 2;
	if(itm == 20) { format(animlist,sizeof(animlist),"%s\nNext Page >>",animlist); nxtbtn[playerid]  = itm+1-e; }
	if(animpage[playerid] > 1){ format(animlist,sizeof(animlist),"%s\nPrevious Page <<",animlist); prvbtn[playerid] = itm+2-e; }

	ShowPlayerDialog(playerid,D_ANIM_EDIT,DIALOG_STYLE_LIST, "EDIT ANIMATIONS", animlist, "Select","Cancel");
	return 1;
}

function AnimationEdit(playerid, animid)
{
	new lo[5], lx[5], ly[5], fr[5];
	if(anim_info[animid][loop] == 1)lo = "Yes";
	else lo = "No";
	if(anim_info[animid][lockx] == 0)lx = "Yes";
	else lx = "No";
	if(anim_info[animid][locky] == 0)ly = "Yes";
	else ly = "No";
	if(anim_info[animid][freeze] == 1)fr = "Yes";
	else fr = "No";

	new dialog[512];
 	format(dialog,sizeof(dialog),
	"Setting\tValue\n\
	Listing Name\t%s\n\
	Animation Lib\t%s\n\
	Animation Name\t%s\n\
	fDelta\t%.02f\n\
	Looping\t%s\n\
	Lock X\t%s\n\
	Lock Y\t%s\n\
	Freeze\t%s\n\
	Time\t%d\n\
	{B62626}DELETE ANIMATION"
	,anim_info[animid][name],anim_info[animid][alib],anim_info[animid][aname],anim_info[animid][fdelta],lo,lx,ly,fr,anim_info[animid][time]);
 	ShowPlayerDialog(playerid, D_ANIM_EDIT+1, DIALOG_STYLE_TABLIST_HEADERS, "EDIT ANIMATION", dialog, "Select", "Cancel");
  	return 1;
}

function PreloadAnims(playerid)
{
	for(new i=1; i < MAX_ANIMS; i++)
	{
	    if(anim_info[i][valid])
	    {
	        PreloadAnimLib(playerid,anim_info[i][alib]);
	    }
	}
	return 1;
}
PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);
}

IsNumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}

//SAMP Publics

public OnPlayerRequestClass(playerid, classid)
{
    PreloadAnims(playerid);
	return 1;
}

public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == D_ANIM_EDIT+1)
	{
	    if(response)
	    {
			switch(listitem)
			{
			    case 0: ShowPlayerDialog(playerid,D_ANIM_EDIT+2,DIALOG_STYLE_INPUT,"LISTED ANIMATION NAME","Type in a new list name for the animation.","Done","Cancel");
				case 1: ShowPlayerDialog(playerid,D_ANIM_EDIT+3,DIALOG_STYLE_INPUT,"ANIMATION LIBRARY","Type in a new library for the animation.\n\nWarning: An invalid animation library will crash the player's game.","Done","Cancel");
				case 2: ShowPlayerDialog(playerid,D_ANIM_EDIT+4,DIALOG_STYLE_INPUT,"ANIMATION NAME","Type in a new name for the animation.","Done","Cancel");
				case 3: ShowPlayerDialog(playerid,D_ANIM_EDIT+5,DIALOG_STYLE_INPUT,"ANIMATION fDELTA","fDelta represents the speed to play the animation.\nThe default is usually 4.0.","Done","Cancel");
				case 4: ShowPlayerDialog(playerid,D_ANIM_EDIT+6,DIALOG_STYLE_MSGBOX,"LOOPING ANIMATION","If set to 'Yes', the animation will loop. If set to 'No', the animation will play once.","Yes","No");
				case 5: ShowPlayerDialog(playerid,D_ANIM_EDIT+7,DIALOG_STYLE_MSGBOX,"LOCK-X ANIMATION","Select 'Yes' to return the actor to their old X coordinate once the animation is complete.\n'No' will not return them to their old position.\n\n\t(For animations that move the actor such as walking).","Yes","No");
				case 6: ShowPlayerDialog(playerid,D_ANIM_EDIT+8,DIALOG_STYLE_MSGBOX,"LOCK-Y ANIMATION","Select 'Yes' to return the actor to their old Y coordinate once the animation is complete.\n'No' will not return them to their old position.\n\n\t(For animations that move the actor such as walking).","Yes","No");
				case 7: ShowPlayerDialog(playerid,D_ANIM_EDIT+9,DIALOG_STYLE_MSGBOX,"ANIMATION FREEZE","Setting this to 'Yes' will freeze an actor at the end of the animation.\n'No' will not.","Yes","No");
				case 8: ShowPlayerDialog(playerid,D_ANIM_EDIT+10,DIALOG_STYLE_INPUT,"ANIMATION TIME","Timer in milliseconds. For a never-ending loop it should be 0.","Done","Cancel");
				case 9: ShowPlayerDialog(playerid,D_ANIM_EDIT+11,DIALOG_STYLE_MSGBOX,"ANIMATION DELETION","This will permanently delete the animation!\n\n\tAre you sure you want to proceed?","Yes","No");
			}
	    }
	}
	
	
	if(dialogid == D_ANIM_EDIT+2 && response)//list name
	{
	    if(strlen(inputtext) > A_NAME)return SCM(playerid,c_warn,"(!) The string introduced exceeds the character limit.");
	    new id = animedit[playerid];
	    format(anim_info[id][name], A_NAME, inputtext);
	    SaveAnimation(id);
	    
	    new msg[128];
	    format(msg,sizeof(msg),"[A] - Animation 'Listing Name' set to '%s' for animation %d.",inputtext,id);
	    SCM(playerid,c_result,msg);
	    
	    AnimationEdit(playerid, id);
	}
	
	
	if(dialogid == D_ANIM_EDIT+3 && response)//lib name
	{
	    if(strlen(inputtext) > A_LENGHT)return SCM(playerid,c_warn,"(!) The string introduced exceeds the character limit.");
	    new id = animedit[playerid];
	    format(anim_info[id][alib], A_LENGHT, inputtext);
	    
	    PreloadAnimLib(playerid,inputtext);
	    
	    SaveAnimation(id);
	    
	    new msg[128];
	    format(msg,sizeof(msg),"[A] - Animation 'Library' set to '%s' for animation %d.",inputtext,id);
	    SCM(playerid,c_result,msg);
	    
	    AnimationEdit(playerid, id);
	}
	
	
	if(dialogid == D_ANIM_EDIT+4 && response)//anim name
	{
	    if(strlen(inputtext) > A_LENGHT)return SCM(playerid,c_warn,"(!) The string introduced exceeds the character limit.");
	    new id = animedit[playerid];
	    format(anim_info[id][aname], A_LENGHT, inputtext);
	    SaveAnimation(id);
	    
	    new msg[128];
	    format(msg,sizeof(msg),"[A] - Animation 'Name' set to '%s' for animation %d.",inputtext,id);
	    SCM(playerid,c_result,msg);
	    
	    AnimationEdit(playerid, id);
	}
	
	
	if(dialogid == D_ANIM_EDIT+5 && response)//fdelta
	{
	    new id = animedit[playerid];
	    anim_info[id][fdelta] = floatstr(inputtext);
	    SaveAnimation(id);

	    new msg[128];
	    format(msg,sizeof(msg),"[A] - Animation 'fDelta' set to '%.02f' for animation %d.",floatstr(inputtext),id);
	    SCM(playerid,c_result,msg);
	    
	    AnimationEdit(playerid, id);
	}
	
	
	if(dialogid == D_ANIM_EDIT+6)//looping
	{
	    new id = animedit[playerid];
	    if(response) anim_info[id][loop] = 1;
	    else anim_info[id][loop] = 0;
	    SaveAnimation(id);
	    
	    SCM(playerid, c_result, "[A] - The 'Looping' setting got updated.");
	    
	    AnimationEdit(playerid, id);
	}
	
	
	if(dialogid == D_ANIM_EDIT+7)//lockx
	{
	    new id = animedit[playerid];
	    if(response) anim_info[id][lockx] = 0;
	    else anim_info[id][lockx] = 1;
	    SaveAnimation(id);
	    
	    SCM(playerid, c_result, "[A] - The 'Lock-X' setting got updated.");
	    
	    AnimationEdit(playerid, id);
	}
	
	
	if(dialogid == D_ANIM_EDIT+8)//locky
	{
	    new id = animedit[playerid];
	    if(response) anim_info[id][locky] = 0;
	    else anim_info[id][locky] = 1;
	    SaveAnimation(id);
	    
	    SCM(playerid, c_result, "[A] - The 'Lock-Y' setting got updated.");
	    
	    AnimationEdit(playerid, id);
	}
	
	
	if(dialogid == D_ANIM_EDIT+9)//freeze
	{
	    new id = animedit[playerid];
	    if(response) anim_info[id][freeze] = 1;
	    else anim_info[id][freeze] = 0;
	    SaveAnimation(id);
	    
	    SCM(playerid, c_result, "[A] - The 'Freeze' setting got updated.");
	    
	    AnimationEdit(playerid, id);
	}
	
	
	if(dialogid == D_ANIM_EDIT+10 && response)//Time
	{
	    if(!IsNumeric(inputtext))return SCM(playerid, c_warn, "(!) The value introduced is not a number!");
	    new id = animedit[playerid];
	    anim_info[id][time] = strval(inputtext);
	    SaveAnimation(id);

	    new msg[128];
	    format(msg,sizeof(msg),"[A] - Animation 'Time' set to '%d' for animation %d.",strval(inputtext),id);
	    SCM(playerid,c_result,msg);
	    
	    AnimationEdit(playerid, id);
	}
	
	
	if(dialogid == D_ANIM_EDIT+11 && response)//Deletion
	{
	    new id = animedit[playerid];
	    
	    DeleteAnimation(id);
	    
	    new msg[128];
	    format(msg,sizeof(msg),"[A] - Animation %d has been deleted.", id);
	    SCM(playerid,c_result,msg);
	}
	
	
	if(dialogid == D_ANIM_EDIT)
	{
	    if(response)
	    {
	        if(listitem == nxtbtn[playerid])
	        {
	            animpage[playerid] ++;
	            aindex[playerid] += 20;
	            AnimEdit(playerid);
	            return 1;
	        }
	        if(listitem == prvbtn[playerid] && animpage[playerid] > 1)
	        {
	            animpage[playerid] --;
				aindex[playerid] -= 20;
             	AnimEdit(playerid);
             	return 1;
	        }
	        if(listitem >= 0 && listitem <= 20)
	        {
	            new id = listitem+aindex[playerid];
	            if(!anim_info[id][valid])return 1;
		        animedit[playerid] = id;

				AnimationEdit(playerid, id);
	        }
	    }
	}
	
	
	if(dialogid == D_ANIM_LIST)
	{
	    if(response)
	    {
	        if(listitem == nxtbtn[playerid])
	        {
	            animpage[playerid] ++;
	            aindex[playerid] += 20;
	            AnimList(playerid,actoredit[playerid]);
	            return 1;
	        }
	        if(listitem == prvbtn[playerid] && animpage[playerid] > 1)
	        {
	            animpage[playerid] --;
				aindex[playerid] -= 20;
             	AnimList(playerid,actoredit[playerid]);
             	return 1;
	        }
	        if(listitem >= 0 && listitem <= 20)
	        {
		        new txt[64];
				if(animpage[playerid] == 1)
				{
				    if(listitem == 0)
				    {
		    			format(txt, sizeof(txt),"[A] - Animations cleared for actor %d.",actoredit[playerid]);
		    			SCM(playerid,c_result,txt);
		    			aInfo[actoredit[playerid]][animation] = 0;
		    			SaveActor(actoredit[playerid]);
		    			ActorAnimation(actoredit[playerid], 0);
		    			return 1;
					}
					listitem --;
					if(!anim_info[listitem+aindex[playerid]][valid])return 1;
					format(txt, sizeof(txt),"[A] - Animation %d.%s applied to actor %d.",listitem+aindex[playerid],anim_info[listitem+aindex[playerid]][name], actoredit[playerid]);
		    		SCM(playerid,c_result,txt);
		    		ActorAnimation(actoredit[playerid], listitem+aindex[playerid]);
		    		
		    		aInfo[actoredit[playerid]][animation] = listitem+aindex[playerid];
	    			SaveActor(actoredit[playerid]);
	    		}
	    		else
	    		{
	    		    if(!anim_info[listitem+aindex[playerid]][valid])return 1;
		    		format(txt, sizeof(txt),"[A] - Animation %d.%s applied to actor %d.",listitem+aindex[playerid],anim_info[listitem+aindex[playerid]][name], actoredit[playerid]);
		    		SCM(playerid,c_result,txt);
		    		ActorAnimation(actoredit[playerid], listitem+aindex[playerid]);
		    		
		    		aInfo[actoredit[playerid]][animation] = listitem+aindex[playerid];
	    			SaveActor(actoredit[playerid]);
				}
	        }
	    }
	}
	return 1;
}

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	if(objectid == aObject) // If this is a global object, sync the position for other players
	{
	    if(!IsValidObject(objectid)) return 1;
	    SetObjectPos(objectid, fX, fY, fZ);
	    SetObjectRot(objectid, fRotX, fRotY, fRotZ);
	    SetDynamicActorPos(actoredit[playerid], fX, fY, fZ);
     	SetDynamicActorFacingAngle(actoredit[playerid], fRotZ);
     	ActorAnimation(actoredit[playerid], aInfo[actoredit[playerid]][animation]);
	}

	if(response == EDIT_RESPONSE_FINAL)
	{
		aInfo[actoredit[playerid]][posx] = fX ,aInfo[actoredit[playerid]][posy] = fY , aInfo[actoredit[playerid]][posz] = fZ;
		aInfo[actoredit[playerid]][rot] = fRotZ;
		SaveActor(actoredit[playerid]);
		RefreshActor(actoredit[playerid]);
		EditMode = false;
	    DestroyObject(aObject);
	    SCM(playerid,c_result,"[A] - Actor edit saved.");
	}

	if(response == EDIT_RESPONSE_CANCEL)
	{
		EditMode = false;
	    DestroyObject(aObject);
	    SCM(playerid,c_result,"[A] - Actor edit canceled.");
	    SetDynamicActorPos(actoredit[playerid], aInfo[actoredit[playerid]][posx],aInfo[actoredit[playerid]][posy],aInfo[actoredit[playerid]][posz]);
     	SetDynamicActorFacingAngle(actoredit[playerid], aInfo[actoredit[playerid]][rot]);
     	ActorAnimation(actoredit[playerid], aInfo[actoredit[playerid]][animation]);
	}
	return 1;
}

