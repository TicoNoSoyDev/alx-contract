CFG = {}

CFG.Reward = {800, 1020}
CFG.Blip = 'yes' -- yes if u want activate the blip or not if u don't want use a blip

CFG.Points = {
    Point = {
        vector3(983.95764, -1531.512, 29.807304)
    },
    Locations = {
        vector3(-676.4061, -2466.429, 12.944396),
        vector3(2780.1459, -710.528, 4.3267655),
        vector3(-813.8896, 872.79821, 202.1229)
    },
}

CFG.FirearmWeapons = {
    "WEAPON_PISTOL",
    "WEAPON_COMBATPISTOL",
    "WEAPON_SMG",
    "WEAPON_ASSAULTRIFLE",
    -- Add more weapons if needed
}

CFG.Notifications = {
    MissionStarted = "Mission already started!",
    NoNPCNearby = "No NPC found nearby",
    DroppedBody = "You dropped the body",
    PickedUpBody = "You picked up the body",
    WaitForNextMission = "Wait %s minutes for the next mission",
    CantStartMission = "You can't start a mission right now",
    KilledWithFirearm = "You killed it with a firearm, you won't get a reward",
    RewardReceived = "Thanks kid, here's your cut: $%s",
    GoGetTargets = "Go get those bastards and bring him to me"
}

CFG.TargetTexts = {
    StartMission = "Start Mission",
    FinishMission = "Finish Mission",
    PickUpNPC = "Pick up NPC"
}