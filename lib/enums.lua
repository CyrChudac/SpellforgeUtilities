-- RHMOD MIGRATION: legacy numeric enum values retained separately; native API enums must not be overwritten.

--signifies how many seconds the given unit type stays on the same knockout timer
KnockOutDecrease = {
  footSoldier = 2.6,
  chevalry = 0.16,
  civilian = 20,
}

KnockOutThreshold = 30

CampaignValueIndices = {
  InfoTextSeenInSherwood = 0,
  LeicesterFamilyState = 1,
  RelicsSeenInSherwood = 2,
  YorkSecretPassageState = 3,
  YorkBeggarProgress = 4,
  SheriffsCousinRobbed = 5,
  RansomPaid = 6,
  LongshampsDead = 7,
  RobinCapturedState = 10,
  RelicTextSeenInSherwood = 11,
  LittleJohnInjured = 12,
  InterMissionMoney = 13,
}

NPCValueIndices = {
  Group = 0,
  UnlockableAI = 1,
  Killable = 4,
}

SpeakOffset = {
  soldier = 0, -- 0-77
  civilian = 78, -- 78-105
  special = 106, -- 106-115
}

--determines for example the default order of heroes on the bottom bar
PCType = {
  RobinHood = 0,
  LittleJohn = 1,
  FriarTuck = 2,
  Stuteley = 3,
  WillScarlet = 4,
  LadyMarian = 5,
  MerryManA = 6,
  MerryManB = 7,
  MerryManC = 8,
}

ActorPosture = {
  Standing = 0,
  Crouched = 10
}