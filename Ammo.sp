// Copyright (C) 2023 Katsute | Licensed under CC BY-NC-SA 4.0

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

float time;

ConVar timeCV;

public Plugin myinfo = {
    name        = "Ammo Box Despawn",
    author      = "Katsute",
    description = "Set ammo box despawn time",
    version     = "1.0",
    url         = "https://github.com/KatsuteTF/Ammo-Box-Despawn"
}

public void OnPluginStart(){
    timeCV = CreateConVar("tf_dropped_ammo_lifetime", "30", "How long dropped ammo should remain on the map", 0, true, 0.0, true, 30.0);
    timeCV.AddChangeHook(OnConvarChanged);

    time = timeCV.FloatValue;

    HookEvent("player_death", OnPlayerDeath);
}

public void OnConvarChanged(const ConVar convar, const char[] oldValue, const char[] newValue){
	if(convar == timeCV)
        time = StringToFloat(newValue);
}

public void OnPlayerDeath(const Event event, const char[] name, const bool dontBroadcast){
    int client = GetClientOfUserId(event.GetInt("userid"));

    if(time == 30)
        return;

    int ent = -1;
    while((ent = FindEntityByClassname(ent, "tf_ammo_pack")) != -1)
        if(GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == client)
            if(time == 0)
                AcceptEntityInput(ent, "Kill");
            else
                CreateTimer(time, OnPlayerDeathDelayed, ent, TIMER_FLAG_NO_MAPCHANGE);
}

public Action OnPlayerDeathDelayed(const Handle timer, const int ent){
    if(IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Continue;
}