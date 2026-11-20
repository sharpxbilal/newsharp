-- ==============================================================================
-- MERGED: MY SCRIPT + ADD THIS (duplicate-free)
-- ==============================================================================

local BRPlayerCharacterBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {},
  LuaEventContainer = {}   -- ⬅️ ADDED (was missing)
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = {
  Reliable = true,
  Params = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object
  }
}
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local ESpecialMovementType = import("ESpecialMovementType")                    -- ⬅️ ADDED
local ESpiderSwingMoveState = import("ESpiderSwingMoveState")                  -- ⬅️ ADDED
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")                -- ⬅️ ADDED
local EParachuteState = import("EParachuteState")                              -- ⬅️ ADDED
local EMovementMode = import("EMovementMode")                                  -- ⬅️ ADDED
local EStateType = import("EStateType")                                        -- ⬅️ ADDED
local ESTEPoseState = import("ESTEPoseState")                                  -- ⬅️ ADDED
local EGameModeType = import("EGameModeType")                                  -- ⬅️ ADDED
local STExtraGameStateBase = import("STExtraGameStateBase")                    -- ⬅️ ADDED
local UKismetSystemLibrary = import("KismetSystemLibrary")                     -- ⬅️ ADDED
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary") -- ⬅️ ADDED
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local MatchModeIds = require("GameLua.Mod.BaseMod.GamePlay.Config.MatchModeIdsConfig") -- ⬅️ ADDED

local KismetSystemLibrary = import("KismetSystemLibrary") -- (kept — used by your version banner)

-- ==========================================
-- ✅ PUBG ALL VERSION SUPPORT
-- ==========================================
local packageName = KismetSystemLibrary and KismetSystemLibrary.GetGameBundleId()

local SUPPORTED_VERSIONS = {
    ["com.tencent.ig"] = "Global",
    ["com.pubg.krmobile"] = "Korea", 
    ["com.rekoo.pubgm"] = "Taiwan",
    ["com.tencent.iglite"] = "Lite",
    ["com.pubg.newstate"] = "New State",
    ["com.vng.pubgmobile"] = "Vietnam",
    ["com.pubg.imobile"] = "Imobile",
}

if packageName then
    local versionName = SUPPORTED_VERSIONS[packageName] or "Unknown"
    print("[INFO] ✅ Detected: " .. versionName .. " (" .. packageName .. ")")
    if packageName == "com.rekoo.pubgm" then
        _G.IS_TW_VERSION = true
        _G.IS_TW = true
        print("[TW] ✅ Taiwan Version - Applying fixes")
    end
    if packageName == "com.tencent.ig" then _G.IS_GLOBAL = true end
    if packageName == "com.pubg.krmobile" then _G.IS_KR = true end
else
    print("[WARN] ⚠️ Could not detect package name - Continuing anyway")
end

local function GetTWPaths(fileName)
    if packageName == "com.rekoo.pubgm" then
        return {
            "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
            "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        }
    end
    return {}
end

local originalGetConfigPaths = GetConfigPaths

GetConfigPaths = function(fileName)
    local paths = {}
    local android_packages = {
        "com.tencent.ig",
        "com.pubg.krmobile",
        "com.rekoo.pubgm",
        "com.vng.pubgmobile",
        "com.tencent.iglite",
        "com.pubg.imobile",
    }
    for _, pkg in ipairs(android_packages) do
        table.insert(paths, "//storage/emulated/0/Android/data/" .. pkg .. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName)
        table.insert(paths, "//storage/emulated/0/Android/data/" .. pkg .. "/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName)
    end
    table.insert(paths, "ShadowTrackerExtra/Saved/SaveGames/" .. fileName)
    table.insert(paths, "../../ShadowTrackerExtra/Saved/SaveGames/" .. fileName)
    if packageName == "com.rekoo.pubgm" then
        table.insert(paths, 1, "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName)
    end
    return paths
end

print("[INFO] ✅ Mod Loaded Successfully! All versions supported!")
print("[INFO] 📱 Current Package: " .. tostring(packageName))

-- ============================================
-- COMPLETE ANTI-BAN SYSTEM
-- ============================================
local function CompleteAntiBanSystem()
    pcall(function()
        -- 1. TSS SDK
        local TssSdk = _G.TssSdk or package.loaded["TssSdk"]
        if TssSdk then
            TssSdk.OnRecvData = function() end
            TssSdk.SendReportInfo = function() end
            TssSdk.ScanMemory = function() return true end
            TssSdk.IsEmulator = function() return false end
            TssSdk.GetTssSdkReportInfo = function() return "" end
            TssSdk.ReportException = function() end
            TssSdk.ReportData = function() end
            TssSdk.CheckIntegrity = function() return true end
            TssSdk.VerifySignature = function() return true end
            TssSdk.CollectEvidence = function() return nil end
            TssSdk.UploadLog = function() end
            TssSdk.SendAntiData = function() end
            TssSdk.ReportGameStart = function() end
            TssSdk.ReportGameEnd = function() end
            TssSdk.ReportCrash = function() end
            TssSdk.ReportViolation = function() end
            TssSdk.ReportSuspicious = function() end
            TssSdk.ReportBan = function() end
            TssSdk.ReportKick = function() end
            TssSdk.ReportWarning = function() end
            TssSdk.ReportInfo = function() end
            TssSdk.ReportDebug = function() end
            TssSdk.ReportError = function() end
            TssSdk.ReportFatal = function() end
            TssSdk.ReportMemory = function() end
            TssSdk.ReportProcess = function() end
            TssSdk.ReportModule = function() end
            TssSdk.ReportThread = function() end
            TssSdk.ReportFile = function() end
            TssSdk.ReportNetwork = function() end
            TssSdk.ReportDevice = function() end
            TssSdk.ReportSystem = function() end
            TssSdk.ReportGame = function() end
            TssSdk.ReportUser = function() end
            TssSdk.ReportAccount = function() end
            TssSdk.ReportSession = function() end
            TssSdk.ReportPerformance = function() end
            TssSdk.ReportBattery = function() end
            TssSdk.ReportTemperature = function() end
            TssSdk.ReportFPS = function() end
            TssSdk.ReportPing = function() end
            TssSdk.ReportPacket = function() end
            TssSdk.ReportCheat = function() end
            TssSdk.ReportHack = function() end
            TssSdk.ReportMod = function() end
            TssSdk.ReportInject = function() end
            TssSdk.ReportDebugger = function() end
            TssSdk.ReportEmulator = function() end
            TssSdk.ReportRoot = function() end
            TssSdk.ReportJailbreak = function() end
            TssSdk.ReportVM = function() end
            TssSdk.ReportHook = function() end
            TssSdk.ReportPatch = function() end
            TssSdk.ReportTamper = function() end
            TssSdk.ReportCorrupt = function() end
            TssSdk.ReportInvalid = function() end
            TssSdk.ReportSpoof = function() end
            TssSdk.ReportFake = function() end
            TssSdk.ReportClone = function() end
            TssSdk.ReportDuplicate = function() end
            TssSdk.ReportConflict = function() end
            TssSdk.ReportOverlap = function() end
            TssSdk.ReportMismatch = function() end
            TssSdk.ReportInconsistent = function() end
            TssSdk.ReportUnexpected = function() end
            TssSdk.ReportUnknown = function() end
        end

        -- 2. ACE
        local ace = _G.ace or package.loaded["libace.so"]
        if ace then
            ace.ReportData = function() end
            ace.CheckIntegrity = function() return true end
            ace.ScanMemory = function() return false end
            ace.VerifyProcess = function() return true end
            ace.CheckModule = function() return true end
            ace.ReportViolation = function() end
            ace.KickPlayer = function() end
            ace.BanPlayer = function() end
            ace.CollectInfo = function() return {} end
            ace.SendReport = function() end
            ace.ValidateClient = function() return true end
            ace.CheckDebugger = function() return false end
            ace.CheckEmulator = function() return false end
            ace.CheckRoot = function() return false end
            ace.ReportCheat = function() end
            ace.ReportHack = function() end
            ace.ReportMod = function() end
            ace.ReportInject = function() end
            ace.ReportHook = function() end
            ace.ReportPatch = function() end
            ace.ReportTamper = function() end
            ace.ReportCorrupt = function() end
            ace.ReportInvalid = function() end
            ace.ReportSpoof = function() end
            ace.ReportFake = function() end
        end

        -- 3. XIGNCODE3
        local XignCode = _G.XignCode or package.loaded["xigncode"]
        if XignCode then
            XignCode.SendReport = function() end
            XignCode.CheckProcess = function() return true end
            XignCode.VerifyIntegrity = function() return true end
            XignCode.ScanModules = function() return {} end
            XignCode.ReportException = function() end
            XignCode.ValidateMemory = function() return true end
            XignCode.CheckDebugger = function() return false end
            XignCode.KickPlayer = function() end
            XignCode.BanPlayer = function() end
            XignCode.EncryptData = function(data) return data end
            XignCode.DecryptData = function(data) return data end
            XignCode.ReportCheat = function() end
            XignCode.ReportHack = function() end
            XignCode.ReportMod = function() end
            XignCode.ReportInject = function() end
            XignCode.ReportHook = function() end
            XignCode.ReportPatch = function() end
            XignCode.ReportTamper = function() end
        end

        -- 4. BATTEYE
        local BattlEye = _G.BattlEye or package.loaded["BattlEye"]
        if BattlEye then
            BattlEye.SendReport = function() end
            BattlEye.KickPlayer = function() end
            BattlEye.ValidatePlayer = function() return true end
            BattlEye.CheckMemory = function() return true end
            BattlEye.VerifyIntegrity = function() return true end
            BattlEye.ReportViolation = function() end
            BattlEye.ScanProcess = function() return true end
            BattlEye.BanPlayer = function() end
            BattlEye.CollectEvidence = function() return {} end
            BattlEye.ReportCheat = function() end
            BattlEye.ReportHack = function() end
            BattlEye.ReportMod = function() end
            BattlEye.ReportInject = function() end
            BattlEye.ReportHook = function() end
        end

        -- 5. HIGGS BOSON
        local HiggsBosonComponent = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
        if HiggsBosonComponent then
            HiggsBosonComponent.bIsEnable = false
            HiggsBosonComponent.bMHActive = false
            HiggsBosonComponent.bCallPreReplication = false
            HiggsBosonComponent.StaticShowSecurityAlertInDev = function() end
            HiggsBosonComponent.CheckClientConfig = function() return false end
            HiggsBosonComponent.GetSecurityInfo = function() return {} end
            HiggsBosonComponent.ReportSecurityAlert = function() end
            HiggsBosonComponent.ValidateClient = function() return true end
            HiggsBosonComponent.CheckIntegrity = function() return true end
            HiggsBosonComponent.BlackList = {}
        end

        -- 6. Report systems
        local reportPaths = {
            "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem",
            "client.slua.logic.report.EquipmentExceptionReport",
            "client.slua.logic.report.ClientToolsReport",
            "GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils",
            "client.slua.logic.download.report.puffer_tlog",
            "GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem",
            "GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils",
            "GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature",
            "client.slua.logic.ban.ClientBanLogic",
            "client.slua.logic.login.logic_tt_ban",
            "GameLua.Mod.PlanBT.Gameplay.Subsystem.DSActiveSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSAITLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem",
            "GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.InspectionSystemReportDSLogicSubsystem",
            "GameLua.Mod.BaseMod.Common.Subsystem.SpectateAndReplaySubsystem",
            "GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem",
            "GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem",
            "GameLua.ExtraModule.MLAI.Client.AIReplaySubsystem",
            "GameLua.Mod.BaseMod.GamePlay.AI.AITrackingLogSubsystem",
            "GameLua.Mod.TDM.Gameplay.Subsystem.TDMAFKReportorSubsystem",
        }
        for _, path in ipairs(reportPaths) do
            local module = package.loaded[path] or pcall(require, path) and require(path)
            if module then
                if module.Report then module.Report = function() end end
                if module.SendReport then module.SendReport = function() end end
                if module.ReportEvent then module.ReportEvent = function() end end
                if module.ReportException then module.ReportException = function() end end
                if module.ReportData then module.ReportData = function() end end
                if module.ReportTLogEvent then module.ReportTLogEvent = function() end end
                if module.OnInit then module.OnInit = function() end end
                if module._OnPlayerKilledOtherPlayer then module._OnPlayerKilledOtherPlayer = function() end end
                if module._RecordFatalDamager then module._RecordFatalDamager = function() end end
                if module._OnBattleResult then module._OnBattleResult = function() end end
                if module._OnShowQuickReportMutualExclusiveUI then module._OnShowQuickReportMutualExclusiveUI = function() end end
                if module._AddEnemyMapToBattleResult then module._AddEnemyMapToBattleResult = function() end end
                if module._AddKnockDownerToBattleResult then module._AddKnockDownerToBattleResult = function() end end
                if module._AddKillerToBattleResult then module._AddKillerToBattleResult = function() end end
                if module._AddTeammateMurderToBattleResult then module._AddTeammateMurderToBattleResult = function() end end
                if module._AddFatalDamagerMapToBattleResult then module._AddFatalDamagerMapToBattleResult = function() end end
                if module._AddMLKillerUIDToBattleResult then module._AddMLKillerUIDToBattleResult = function() end end
                if module._SaveHistoricalTeammateInfo then module._SaveHistoricalTeammateInfo = function() end end
                if module._RecordTeammateMurderer then module._RecordTeammateMurderer = function() end end
                if module._OnNearDeathOrRescued then module._OnNearDeathOrRescued = function() end end
                if module._OnCharacterDied then module._OnCharacterDied = function() end end
                if module._OnTeammateDamage then module._OnTeammateDamage = function() end end
                if module._OnPlayerSettlementStart then module._OnPlayerSettlementStart = function() end end
                if module._OnHawkSync then module._OnHawkSync = function() end end
                if module._OnHawkReportSuccess then module._OnHawkReportSuccess = function() end end
                if module._StartExitGameTimer then module._StartExitGameTimer = function() end end
                if module.OnHandleBehaviorScore then module.OnHandleBehaviorScore = function() end end
                if module.AIPerceptionScore then module.AIPerceptionScore = function() end end
                if module.ReportAllPlayerInfo then module.ReportAllPlayerInfo = function() end end
                if module.AddRecordMLAIInfo then module.AddRecordMLAIInfo = function() end end
                if module.ReportAI then module.ReportAI = function() end end
                if module.RealLogoutTimer then module.RealLogoutTimer = function() end end
                if module.LogQueue then module.LogQueue = {} end
                if module.SendAFKTips then module.SendAFKTips = function() end end
                if module.OnHandleLostConnection then module.OnHandleLostConnection = function() end end
                if module.ClientRPC_SyncBanID then module.ClientRPC_SyncBanID = function() end end
                if module.ClientRPC_StrongTips then module.ClientRPC_StrongTips = function() end end
                if module.ClientRPC_NormalTips then module.ClientRPC_NormalTips = function() end end
                if module.Notify then module.Notify = function() end end
                if module.OnSyncBanInfo then module.OnSyncBanInfo = function() end end
                if module.OnVoiceBanNotify then module.OnVoiceBanNotify = function() end end
                if module.GetCarrierInfo then module.GetCarrierInfo = function() return "[{\"mcc\":\"000\"}]" end end
                if module.CheckIfCanCreateRole then module.CheckIfCanCreateRole = function() return true end end
                if module.DelayKickOutPlayer then module.DelayKickOutPlayer = function() end end
                if module.ActiveKickNotify then module.ActiveKickNotify = function() end end
                if module._UpdateTTKRecords then module._UpdateTTKRecords = function() end end
                if module._UpdateOperatingFrequency then module._UpdateOperatingFrequency = function() end end
                if module.GetSimpleFightData then module.GetSimpleFightData = function() return {} end end
                if module._OnReportServerJumpFlow then module._OnReportServerJumpFlow = function() end end
                if module.HandleKillTlog then module.HandleKillTlog = function() end end
                if module.AskForInspector then module.AskForInspector = function() end end
                if module.ReportEnemy then module.ReportEnemy = function() end end
                if module.KickOutOneTeam then module.KickOutOneTeam = function() end end
                if module.ServerKickOutOneTeamByPlayerImplementation then module.ServerKickOutOneTeamByPlayerImplementation = function() end end
                if module.AddReportedCount then module.AddReportedCount = function() end end
                if module.RequestGotoSpectatingImp then module.RequestGotoSpectatingImp = function() end end
                if module.RequestGotoSpectating then module.RequestGotoSpectating = function() end end
            end
        end

        -- 7. TLog
        local tlogPaths = {
            "client.slua.config.tlog.tlog_report_utils",
            "client.slua.logic.replay.logic_report_replay",
            "client.slua.logic.crash.CrashReporter",
        }
        for _, path in ipairs(tlogPaths) do
            local module = package.loaded[path] or pcall(require, path) and require(path)
            if module then
                if module.ReportTLogEvent then module.ReportTLogEvent = function() end end
                if module.SendTlog then module.SendTlog = function() end end
                if module.ReportTLog then module.ReportTLog = function() end end
                if module.ReportReplay then module.ReportReplay = function() end end
                if module.SendReportReq then module.SendReportReq = function() end end
                if module.SaveDump then module.SaveDump = function() end end
                if module.UploadDump then module.UploadDump = function() end end
            end
        end

        -- 8. GameplayCallbacks
        if _G.GameplayCallbacks then
            local GC = _G.GameplayCallbacks
            local noop = function() end
            GC.ReportAttackFlow = noop
            GC.ReportSecAttackFlow = noop
            GC.ReportHurtFlow = noop
            GC.ReportFireArms = noop
            GC.ReportVerifyInfoFlow = noop
            GC.ReportMrpcsFlow = noop
            GC.ReportPlayerBehavior = noop
            GC.ReportTeammatHurt = noop
            GC.ReportMisKillByTeammate = noop
            GC.ReportForbitPick = noop
            GC.ReportPlayerMoveRoute = noop
            GC.ReportPlayerPosition = noop
            GC.ReportVehicleMoveFlow = noop
            GC.ReportSecTgameMovingFlow = noop
            GC.ReportParachuteData = noop
            GC.SendTssSdkAntiDataToLobby = noop
            GC.SendDSErrorLogToLobby = noop
            GC.SendDSErrorLogToLobbyOnece = noop
            GC.SendDSHawkEyePatrolLogToLobby = noop
            GC.ReportEquipmentFlow = noop
            GC.ReportAimFlow = noop
            GC.ReportHitFlow = noop
            GC.GetWeaponReport = function() return {} end
            GC.GetOneWeaponReport = function() return {} end
            GC.ReportPlayersPing = noop
            GC.ReportPlayerIP = noop
            GC.ReportPlayerFramePingRecord = noop
            GC.ReportCircleFlow = noop
            GC.ReportDSCircleFlow = noop
            GC.ReportJumpFlow = noop
            GC.ReportMatchRoomData = noop
            GC.SendPlayerSpectatingLog = noop
            GC.ReportGameSetting = noop
            GC.ReportGameSettingNew = noop
            GC.ReportCommonInfo = noop
            GC.SendSecTLog = noop
            GC.SendDataMiningTLog = noop
            GC.SendActivityTLog = noop
            GC.GetGeneralTLogData = function() return {} end
            GC.OnPlayerNetConnectionClosed = noop
            GC.OnPlayerActorChannelError = noop
            GC.OnPlayerRPCValidateFailed = noop
            GC.OnPlayerSpectateException = noop
            GC.OnShutdownAfterError = noop
            GC.IsBypassed = true
        end

        -- 9. NetUtil packets
        if NetUtil and NetUtil.SendPacket then
            local originalSend = NetUtil.SendPacket
            local blockedPackets = {
                ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportHurtFlow"]=1,
                ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
                ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportTeammateKillConfirmFlow"]=1,
                ["ReportForbiddenPickupFlow"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1,
                ["ReportSecVehicleMoveFlow"]=1, ["ReportSecTgameMovingFlow"]=1, ["report_parachute_data"]=1,
                ["on_tss_sdk_anti_data"]=1, ["report_unrealnet_exception"]=1, ["ReportPlayerEquipmentInfo"]=1,
                ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["ReportCircleFlow"]=1, ["report_players_ping"]=1,
                ["report_player_ip"]=1, ["report_net_saturate"]=1, ["report_speed_hack"]=1, ["report_wall_hack"]=1,
                ["ReportSecurityAlert"]=1, ["ReportAntiCheat"]=1, ["ReportViolation"]=1,
                ["ReportBan"]=1, ["ReportKick"]=1, ["ReportCheat"]=1, ["ReportHack"]=1,
                ["ReportMod"]=1, ["ReportInject"]=1, ["ReportHook"]=1, ["ReportPatch"]=1,
                ["ReportTamper"]=1, ["ReportCorrupt"]=1, ["ReportInvalid"]=1,
                ["ReportSpoof"]=1, ["ReportFake"]=1, ["ReportClone"]=1,
            }
            NetUtil.SendPacket = function(packetName, ...)
                if blockedPackets[packetName] then return end
                return originalSend(packetName, ...)
            end
            NetUtil.IsBypassed = true
        end

        -- 10. CrashSight / TLog
        local CrashSight = _G.CrashSight or package.loaded["CrashSight"]
        if CrashSight then
            CrashSight.ReportException = function() end
            CrashSight.SetCustomData = function() end
            CrashSight.Log = function() end
            CrashSight.UploadLog = function() end
            CrashSight.SendReport = function() end
            CrashSight.CollectInfo = function() return {} end
            CrashSight.ReportCrash = function() end
        end

        local TLog = _G.TLog or package.loaded["TLog"]
        if TLog then
            TLog.Info = function() end
            TLog.Warning = function() end
            TLog.Error = function() end
            TLog.Debug = function() end
            TLog.Report = function() end
            TLog.Flush = function() end
            TLog.Log = function() end
        end

        -- 11. Screenshot
        local ScreenshotMaker = import("ScreenshotMaker")
        if ScreenshotMaker then
            ScreenshotMaker.MakePicture = function() return "" end
            ScreenshotMaker.ReMakePicture = function() return "" end
            ScreenshotMaker.HasCaptured = function() return true end
            ScreenshotMaker.TakeScreenshot = function() end
        end

        -- 12. SystemInfo spoof
        local SystemInfo = import("SystemInfo")
        if SystemInfo then
            SystemInfo.GetDeviceModel = function() return "iPhone14,5" end
            SystemInfo.GetDeviceBrand = function() return "Apple" end
            SystemInfo.GetAndroidVersion = function() return "13" end
            SystemInfo.IsEmulator = function() return false end
            SystemInfo.IsRooted = function() return false end
            SystemInfo.IsDebugged = function() return false end
        end

        -- 13. Console
        local ConsoleLib = import("KismetSystemLibrary")
        if ConsoleLib then
            ConsoleLib.IsDevelopment = function() return false end
            ConsoleLib.IsShipping = function() return true end
            ConsoleLib.IsEditor = function() return false end
        end

        -- 14. CreativeMode
        local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
        if CreativeModeBlueprintLibrary then
            CreativeModeBlueprintLibrary.MD5HashByteArray = function() return "BYPASSED_MD5_HASH" end
            CreativeModeBlueprintLibrary.GetContentDiffData = function() return true, "BYPASSED" end
            CreativeModeBlueprintLibrary.VerifyContent = function() return true end
        end

        -- 15. Telemetry
        local TDataMaster = _G.TDataMaster or package.loaded["libTDataMaster.so"]
        if TDataMaster then
            TDataMaster.ReportEvent = function() end
            TDataMaster.ReportException = function() end
            TDataMaster.FlushData = function() end
            TDataMaster.CollectData = function() return {} end
            TDataMaster.SendReport = function() end
        end
        _G.TelemetryQueue = {}
        _G.bTelemetryEnabled = false

        print('[✓] COMPLETE ANTI-BAN SYSTEM ACTIVATED!')
        print('[✓] All Anti-Cheat Systems Blocked!')
    end)
end

pcall(CompleteAntiBanSystem)

if not isExpired then
    require("common.time_ticker").AddTimerOnce(0.1, CompleteAntiBanSystem)
end

-- ============================================================
-- ADDITIONAL BYPASS LAYERS
-- ============================================================
do
local function nop() end
local function nopfalse() return false end
local function nopstr() return "" end
local function retFalse() return false end
local function retTrue() return true end

local function NetworkBypass()
    do return end
end

local function ClientEntryBypass()
    pcall(function()
        if Client then
            Client.SetTssNetworkStatus = nop
            Client.GEMReportEnterLobbyEvent = nop
            Client.TPerforPlatDisconnectReport = nop
            Client.IsConnected = function(NetInterface) return true end
            Client.GetUnrealNetworkStatus = nopstr
            Client.MD5LuaString = function(str) return "BYPASSED_MD5" end
            Client.GetDSVersion = function() return "999.999.999" end
            Client.IsInReplayState = nopfalse
        end
        if NetManager then
            NetManager.ProcRespondMsg = nop
            NetManager.isLogMsgAfterLogin = false
            NetManager.logMsgMap = {}
        end
        if EventSystem then
            local oldPost = EventSystem.postEvent
            EventSystem.postEvent = function(eventType, eventID, ...)
                if eventID and type(eventID) == "string" then
                    local blocked = {"SECURITY", "CHEAT", "BAN", "REPORT", "FLAG", 
                                    "VIOLATION", "DETECT", "VERIFY", "ANTI", "AC_",
                                    "SUSPICIOUS", "ABNORMAL", "MONITOR", "TRACK",
                                    "TELEMETRY", "ANALYTICS", "CRASH", "DUMP"}
                    for _, be in ipairs(blocked) do
                        if eventID:find(be) then return end
                    end
                end
                if oldPost then oldPost(eventType, eventID, ...) end
            end
        end
        local logFuncs = {"log", "log_warning", "log_error", "log_shipping_client", "log_format", "log_tree"}
        for _, funcName in ipairs(logFuncs) do
            if _G[funcName] then
                _G[funcName] = function(...)
                    local args = {...}
                    for _, arg in ipairs(args) do
                        if type(arg) == "string" and (
                            arg:find("cheat") or arg:find("security") or arg:find("ban") or
                            arg:find("detect") or arg:find("verify") or arg:find("integrity")
                        ) then return end
                    end
                end
            end
        end
        if LogUtil then
            LogUtil.SetForceLog = nop
            LogUtil.SetLogTreeEnable = nop
            LogUtil.SetWriteLog = nop
        end
        if sandbox then 
            sandbox.LogError = nop
            sandbox.LogWarning = nop 
        end
    end)
    print("[BYPASS] ✅ Client Entry bypassed!")
end

local function BanLogicBypass()
    pcall(function()
        if ClientBanLogic then
            ClientBanLogic.ReqBanInfo = nop
            ClientBanLogic.OnVoiceSwitchNotify = nop
            ClientBanLogic.OnVoiceBanNotify = nop
            ClientBanLogic.OnRealTimeVoiceBanNotify = nop
            ClientBanLogic.OnVoiceBanSuccess = nop
            ClientBanLogic.TryOpenVoice = function()
                EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_BAN_FORBID_VOICE, false)
            end
            ClientBanLogic.IsVoiceReportEnable = nopfalse
            ClientBanLogic.OnSyncMicSuspicious = nop
            ClientBanLogic.OnSyncMicPreFilter = nop
            ClientBanLogic.OnSyncBanInfo = nop
            ClientBanLogic.OnNotifyWarningTips = nop
            ClientBanLogic.VoiceBanEndTime = 0
            ClientBanLogic.bEnableVoiceReport = false
            ClientBanLogic.SuspiciousFlag = 0
        end
        if RealTimeBan then
            RealTimeBan.Init = function() return end
            RealTimeBan.OnPlayerWithRealTimeBan = nop
            RealTimeBan.OnSyncPlayerInfo = nop
            RealTimeBan.HandleEnterGameModeFightingState = nop
            RealTimeBan.ShowAlias = nop
        end
        if BanSystem then
            BanSystem.CheckBan = retFalse
            BanSystem.IsBanned = retFalse
            BanSystem.GetBanReason = function() return "" end
            BanSystem.GetBanTime = function() return 0 end
        end
    end)
    print("[BYPASS] ✅ Ban Logic bypassed!")
end

local function MD5Bypass()
    pcall(function()
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            console.ExecuteConsoleCommand(nil, "sig.Check 0")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
            console.ExecuteConsoleCommand(nil, "CheatManager.EnableCheat 1")
            console.ExecuteConsoleCommand(nil, "Net.BlockAllAntiCheat 1")
            console.ExecuteConsoleCommand(nil, "AntiCheat.DisableAll 1")
            console.ExecuteConsoleCommand(nil, "t.MaxFPS 165")
        end
        local CMode = import("CreativeModeBlueprintLibrary")
        if CMode then
            CMode.MD5HashByteArray = function() return "00000000000000000000000000000000" end
            CMode.MD5HashFile = function() return "00000000000000000000000000000000" end
            CMode.GetContentDiffData = function() return true, "BYPASSED" end
            CMode.VerifyFileIntegrity = retTrue
        end
        if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
        if _G.CRC32 then _G.CRC32 = function() return 0 end end
        if _G.SHA1 then _G.SHA1 = function() return "BYPASS" end end
    end)
    print("[BYPASS] ✅ MD5 & Signature bypassed!")
end

local function DNSDeviceBypass()
    pcall(function()
        local DeviceID = import("DeviceID")
        if DeviceID then
            DeviceID.GetDeviceID = function() return "BYPASSED_DEVICE" end
            DeviceID.GetAndroidID = function() return "BYPASSED_ANDROID_ID" end
            DeviceID.GetIMEI = function() return "BYPASSED_IMEI" end
            DeviceID.GetMACAddress = function() return "BYPASSED_MAC" end
            DeviceID.GetUniqueDeviceID = function() return "BYPASSED_UNIQUE" end
        end
    end)
    print("[BYPASS] ✅ DNS & Device bypassed!")
end

local function PGBypass()
    pcall(function()
        local PG = package.loaded["GameLua.Mod.BaseMod.Client.Security.PG"]
        if PG then
            PG.ForwardFeature = function() return {0,0,0,0,0} end
            PG.InitPGLogic = nop
            if PG.TimerHandle then
                local time_ticker = require("common.time_ticker")
                time_ticker.RemoveTimer(PG.TimerHandle)
                PG.TimerHandle = nil
            end
            for k, v in pairs(PG) do
                if type(v) == "function" and (
                    k:find("Init") or k:find("Start") or k:find("Check") or
                    k:find("Scan") or k:find("Report") or k:find("Forward") or
                    k:find("Feature") or k:find("Detect") or k:find("Collect")
                ) then
                    PG[k] = nop
                end
            end
        end
    end)
    print("[BYPASS] ✅ PG bypassed!")
end

local function RacingAntiCheatBypass()
    pcall(function()
        if RacingAntiCheatLogic then
            RacingAntiCheatLogic.HandleRacingEnter = nop
            RacingAntiCheatLogic.HandleRacingStart = nop
            RacingAntiCheatLogic.HandleRacingEnd = nop
            RacingAntiCheatLogic.StartDetectTimer = nop
            RacingAntiCheatLogic.StopDetectTimer = nop
            RacingAntiCheatLogic.DetectVehicleFloating = nop
            RacingAntiCheatLogic.HandleFloatingCheat = nop
            RacingAntiCheatLogic.SetIgnoreFloating = nop
            RacingAntiCheatLogic.HandlePlayerPassCheckBelt = nop
            RacingAntiCheatLogic.HandleSpeedCheat = nop
            RacingAntiCheatLogic._CreateVehicleData = function() return {} end
            RacingAntiCheatLogic.vehicleDataMap = {}
            RacingAntiCheatLogic.detectTimer = nil
        end
    end)
    print("[BYPASS] ✅ Racing AntiCheat bypassed!")
end

local function LoginModuleBypass()
    pcall(function()
        if login_module then
            login_module["ban-login"] = function() return end
            login_module["idip-kick-out"] = function() return end
            login_module.aq_ban = function() return end
            login_module["device-in-blacklist"] = function() return end
            login_module.device_num_limit = function() return end
            login_module["register-forbidden"] = function() return end
            login_module["low-version"] = function() return end
            login_module["not-in-white-list"] = function() return end
            login_module.Login_Failed = function() return end
            login_module.aas_ban = function() return end
            login_module.PakMonitorStart = function(EnableMode) return end
            login_module.SetupFilenameHideKeywords = function() return end
            login_module.on_login_failed = function(conn_idx, reason, banInfo, banTime, uid, extra_table) return end
            login_module.DelaybanLoginCancelCallback = function() return end
            login_module.CheckBan = retFalse
            login_module.IsBanned = retFalse
        end
    end)
    print("[BYPASS] ✅ Login Module bypassed!")
end

local function KillAllSubsystems()
    pcall(function()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local toKill = {
                "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
                "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient",
                "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem",
                "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem",
                "AFKReportorSubsystem", "BehaviorScoreSubsystem", "FileCheckSubsystem",
                "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem",
                "AvatarExceptionSubsystem", "GameReportSubsystem", "ClientSecMrpcsFlowSubsystem",
                "MrpcsFlowSubsystem", "CircleFlowSubsystem", "SwiftHawkSubsystem",
                "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem",
                "MD5CheckSubsystem", "PakVerifySubsystem", "DNSMonitorSubsystem",
                "DeviceFingerprintSubsystem", "ReplayMonitorSubsystem", "TelemetrySubsystem",
                "PGSubsystem", "RacingAntiCheatSubsystem", "ClientBanSubsystem",
                "RealTimeBanSubsystem", "TLogSubsystem", "ReportSubsystem",
            }
            for _, name in ipairs(toKill) do
                local sub = SubMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (
                            k:find("Report") or k:find("Send") or k:find("Upload") or
                            k:find("Verify") or k:find("Check") or k:find("Validate") or
                            k:find("Scan") or k:find("Detect") or k:find("Collect")
                        ) then pcall(function() sub[k] = nop end) end
                    end
                    if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
                    if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
                    if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
                end
            end
        end
    end)
    print("[BYPASS] ✅ All subsystems killed!")
end

_G.RunAdditionalBypass = function()
    pcall(ClientEntryBypass)
    pcall(BanLogicBypass)
    pcall(MD5Bypass)
    pcall(PGBypass)
    pcall(RacingAntiCheatBypass)
    pcall(KillAllSubsystems)
end

pcall(_G.RunAdditionalBypass)
end

-- ============================================================
-- PG BYPASS SYSTEM
-- ============================================================
do
    local function _gk_ret_true() return true end
    local function _gk_ret_false() return false end
    local function _gk_ret_zero() return 0 end
    local function _gk_ret_empty() return {} end
    local function _gk_noop() end
    local function _gk_isValid(obj)
        if type(slua) == "table" and type(slua.isValid) == "function" then
            local ok, res = pcall(slua.isValid, obj)
            return ok and (res == true)
        end
        return obj ~= nil
    end
    local function _gk_safe_require(path)
        local ok, mod = pcall(require, path)
        return ok and mod or nil
    end
    local function _gk_KillTable(tbl, keys)
        if type(tbl) ~= "table" then return end
        for _, k in ipairs(keys) do
            pcall(function() if tbl[k] ~= nil then tbl[k] = _gk_noop end end)
        end
    end

    _G.BypassState = _G.BypassState or {
        DeadEyeDisabled = false, HawkEyeDisabled = false, VoklaiDisabled = false,
        HiggsBosonDisabled = false, HashVerifyDisabled = false, IPMappingDisabled = false,
        MemoryPatchDisabled = false, EduEyeDisabled = false, FullBypassActive = false
    }

    function _G.ApplyPGBypasses()
        if _G.BypassState.FullBypassActive then return end
        pcall(function()
            if _G.GameplayCallbacks then
                _gk_KillTable(_G.GameplayCallbacks, {
                    "ReportAimFlow", "ReportHitFlow", "ReportAttackFlow",
                    "OnAimDetected", "OnHeadshotDetected", "OnPerfectAccuracy"
                })
            end
            local subsystems = _gk_safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
            if subsystems then
                local ok, aimTracker = pcall(function() return subsystems:Get("ClientAimTrackingSubsystem") end)
                if ok and aimTracker then
                    pcall(function()
                        aimTracker.GetAimData = function()
                            return { accuracy = math.random(45, 65), headshotRate = math.random(15, 35) }
                        end
                        aimTracker.IsAimNormal = _gk_ret_true
                    end)
                end
                local ok2, hawkEye = pcall(function() return subsystems:Get("ClientHawkEyePatrolSubsystem") end)
                if ok2 and hawkEye then
                    pcall(function()
                        hawkEye.GetPatrolData = _gk_ret_empty
                        hawkEye.IsBeingWatched = _gk_ret_false
                        hawkEye.GetSpectatorCount = _gk_ret_zero
                    end)
                end
            end
            local hud = _G.slua_GameFrontendHUD or _G.GameFrontendHUD
            local pc = nil
            if hud and type(hud.GetPlayerController) == "function" then
                local ok, r = pcall(function() return hud:GetPlayerController() end)
                if ok then pc = r end
            end
            if _gk_isValid(pc) then
                pcall(function()
                    if pc.HiggsBoson then
                        pc.HiggsBoson.bMHActive = false
                        pc.HiggsBoson.bCallPreReplication = false
                    end
                    if pc.HiggsBosonComponent then
                        pc.HiggsBosonComponent.bMHActive = false
                        pcall(function() pc.HiggsBosonComponent:ControlMHActive(0) end)
                    end
                end)
            end
            _G.BypassState.FullBypassActive = true
        end)
    end

    pcall(_G.ApplyPGBypasses)

    if not isExpired then
        local okT, ticker = pcall(require, "common.time_ticker")
        if okT and ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(0.2, function()
                pcall(_G.PGBypasses)
            end)
        end
    end
end

-- ==============================================================================
-- BRPlayerCharacterBase FUNCTIONS
-- ==============================================================================

function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
  BRPlayerCharacterBase.__super._PostConstruct(self)
  self:InitAddSpecialMoveInfo()
  self.bCanNearDeathGiveup = true
  print(bWriteLog and "BRPlayerCharacterBase:_PostConstruct bCanNearDeathGiveup true")
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
  BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
  self:AddControlEvent(self, "MovementModeChangedDelegate", self.HandleOnMovementModeChangedNew, self)
  if self:HasAuthority() and self:CheckAddCheckFallingDistanceComponent() then
    local CheckFallingDistanceComponent_C = import("CheckFallingDistanceComponent")
    if slua.isValid(CheckFallingDistanceComponent_C) and not slua.isValid(self:GetComponentByClass(CheckFallingDistanceComponent_C)) then
      print(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay Add CheckFallingDistanceComponent")
      Game:AddComponent(CheckFallingDistanceComponent_C, self, "CheckFallingDistanceComponent")
    end
  end
  if slua.isValid(self.STCharacterMovement) then
    self.STCharacterMovement.bPositiveBlowUp = true
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy then
    self:AddControlEvent(self, "OnPawnStateDisabled", self.OnPawnStateChange, self)
    self:AddControlEvent(self, "OnPawnStateEnabled", self.OnPawnStateChange, self)
    self:AddControlEventConditionOnly(self, "OnAttrChangeEventDelegate", {
      AttrName = { "bCanSelfRescue" }
    }, self.CharacterAttrChangeEvent, self)
  end
  if Client then
    printf(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay, PlayerKey:%u ", self.PlayerKey)
    GameplayData.AddCharacter(self.Object)
    -- (Your existing vehicle events — kept, since your script had them)
    self:AddControlEvent(self, "OnAttachedToVehicle", self.HandleOnAttachedToVehicle, self)
    self:AddControlEvent(self, "OnDetachedFromVehicle", self.HandleOnDetachedFromVehicle, self)
  else
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FinishedState"
    }, self.HandleFinishedState, self)
  end
end

-- ===== YOUR EXISTING VEHICLE FUNCTIONS (kept — not in ADD block) =====
function BRPlayerCharacterBase:HandleOnAttachedToVehicle(uVehicle)
  if not slua.isValid(uVehicle) then return end
  print(bWriteLog and string.format("BRPlayerCharacterBase:HandleOnAttachedToVehicle", Game:GetObjName(uVehicle)))
  if self.Role == ENetRole.ROLE_SimulatedProxy then
    self:ClearAttachToVehicleTimer()
    self.nUpdatePlayerAttachToVehicleCount = 0
    self.nUpdatePlayerAttachToVehicleTimer = self:AddGameTimer(5, true, function()
      if slua.isValid(self.Object) and slua.isValid(uVehicle) then
        self:UpdatePlayerAttachToVehicle(uVehicle)
      end
    end)
    self.nFixMeshContainerTimer = self:AddGameTimer(3, true, function()
      if slua.isValid(self.Object) and slua.isValid(uVehicle) then
        self:FixMeshContainerOffsetIfNeeded(uVehicle)
      end
    end)
  end
end

function BRPlayerCharacterBase:HandleOnDetachedFromVehicle(uLastVehicle)
  if not slua.isValid(uLastVehicle) then return end
  print(bWriteLog and "BRPlayerCharacterBase:HandleOnDetachedFromVehicle", uLastVehicle)
  if self.Role == ENetRole.ROLE_SimulatedProxy then
    self:ClearAttachToVehicleTimer()
    self.nUpdatePlayerAttachToVehicleCount = 0
  end
end

function BRPlayerCharacterBase:UpdatePlayerAttachToVehicle(uVehicle)
  if not slua.isValid(self.Object) or not slua.isValid(uVehicle) then return end
  if not slua.isValid(self.CapsuleComponent) or not slua.isValid(self.Mesh) or not slua.isValid(self.MeshContainer) then return end
  if not slua.isValid(self:GetCurrentVehicle()) then return end
  if Game:IsDriver(self.Object) then return end
  if not self.nUpdatePlayerAttachToVehicleCount then self.nUpdatePlayerAttachToVehicleCount = 0 end
  local bStand = self.PoseState == ESTEPoseState.Stand
  local uActorRelativeLocation = self.CapsuleComponent:GetRelativeTransform():GetLocation()
  local uMeshRelativeLocation = self.Mesh:GetRelativeTransform():GetLocation()
  local uMeshContainerRelativeLocationZ = self.MeshContainer:GetRelativeTransform():GetLocation().Z
  local nCapsuleRadius = self.CapsuleComponent:GetScaledCapsuleRadius()
  local nCapsuleHalfHeight = self.CapsuleComponent:GetScaledCapsuleHalfHeight()
  local uMeshContainerExpectedZ = -1 * self.StandHalfHeight
  local nExpectedCapsuleRadius = self.StandRadius
  local nExpectedCapsuleHalfHeight = self.StandHalfHeight
  local uMeshExpectedRL = FVector(0, 0, 0)
  local uActorExpectedRL = FVector(0, 0, self.StandHalfHeight)
  local nTolerance = 1.0
  local bCapsuleRLCorrect = uActorRelativeLocation:Equals(uActorExpectedRL, nTolerance)
  local bMeshRLCorrect = uMeshRelativeLocation:Equals(uMeshExpectedRL, nTolerance)
  local bMeshContainerRLCorrect = nTolerance > math.abs(uMeshContainerRelativeLocationZ - uMeshContainerExpectedZ)
  local bCapsuleRadiusCorrect = nTolerance > math.abs(nCapsuleRadius - nExpectedCapsuleRadius)
  local bCapsuleHalfHeightCorrect = nTolerance > math.abs(nCapsuleHalfHeight - nExpectedCapsuleHalfHeight)
  local bAllCorrect = bStand and bCapsuleRLCorrect and bMeshRLCorrect and bMeshContainerRLCorrect and bCapsuleRadiusCorrect and bCapsuleHalfHeightCorrect
  if not bAllCorrect then
    self.nUpdatePlayerAttachToVehicleCount = self.nUpdatePlayerAttachToVehicleCount + 1
  else
    self.nUpdatePlayerAttachToVehicleCount = 0
  end
  print(bWriteLog and string.format("BRPlayerCharacterBase:UpdatePlayerAttachToVehicle PlayerKey:%s. bAllCorrect=%s", tostring(self.PlayerKey), tostring(bAllCorrect)))
  if self.nUpdatePlayerAttachToVehicleCount >= 3 and not bAllCorrect then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPlayerController = GameplayData.GetPlayerController()
    if uPlayerController.ReportCrashKitFeature and uPlayerController.ReportCrashKitFeature.ReportCharacterAttachedOnVehicleException then
      local sReportInfo = string.format("VehicleShapeType:%s PlayerKey:%s", tostring(uVehicle.VehicleShapeType), tostring(self.PlayerKey))
      uPlayerController.ReportCrashKitFeature:ReportCharacterAttachedOnVehicleException(sReportInfo)
    end
    self.nUpdatePlayerAttachToVehicleCount = 0
  end
end

function BRPlayerCharacterBase:FixMeshContainerOffsetIfNeeded(uVehicle)
  if not slua.isValid(self.Object) or not slua.isValid(uVehicle) then return end
  if not slua.isValid(self.MeshContainer) then return end
  if not slua.isValid(self:GetCurrentVehicle()) then return end
  if Game:IsDriver(self.Object) then return end
  local nTolerance = 1.0
  local uMeshContainerExpectedZ = -1 * self.StandHalfHeight
  local uMeshContainerRelativeLocationZ = self.MeshContainer:GetRelativeTransform():GetLocation().Z
  if nTolerance <= math.abs(uMeshContainerRelativeLocationZ - uMeshContainerExpectedZ) then
    self:SetMeshContainerOffsetZ(uMeshContainerExpectedZ)
  end
end

function BRPlayerCharacterBase:ClearAttachToVehicleTimer()
  if self.nUpdatePlayerAttachToVehicleTimer then
    self:RemoveGameTimer(self.nUpdatePlayerAttachToVehicleTimer)
    self.nUpdatePlayerAttachToVehicleTimer = nil
  end
  if self.nFixMeshContainerTimer then
    self:RemoveGameTimer(self.nFixMeshContainerTimer)
    self.nFixMeshContainerTimer = nil
  end
end

-- ===== ADD BLOCK: NEW FUNCTIONS FROM "ADD THIS" =====

function BRPlayerCharacterBase:PreAttachedToVehicle()
  local IsDS = UKismetSystemLibrary.IsDedicatedServer(self)
  if not IsDS then return end
  local MainPlayerController = self:GetPlayerControllerSafety()
  if not slua.isValid(MainPlayerController) then return end
  local CharacterAvatarComp2_BP = self.CharacterAvatarComp2_BP
  if not slua.isValid(CharacterAvatarComp2_BP) then return end
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local changedVehicleId = CommerAvatarDataUtil:ChangeVehicleSkinByClothes(MainPlayerController, CharacterAvatarComp2_BP)
  local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
  if changedVehicleId then
    local UAvatarUtils = import("AvatarUtils")
    if UAvatarUtils.GetVehicleShapeBySkinID(changedVehicleId) == ESTExtraVehicleShapeType.VST_Horse then
      local uCurPlayerState = self:GetPlayerStateSafety()
      if slua.isValid(uCurPlayerState) then
        print(bWriteLog and "  BRPlayerCharacterBase:PreAttachedToVehicle. changedVehicleId: " .. tostring(changedVehicleId))
        uCurPlayerState:AddGeneralCount(468, 1, false)
      end
    end
  end
end

function BRPlayerCharacterBase:OnMovementBaseChangedEvent(uCharacter, uNewMovementBase, uOldMovementBase)
  if uCharacter ~= self.Object then return end
  print(bWriteLog and string.format("BRPlayerCharacterBase:OnMovementBaseChangedEvent %s, Base: %s -> %s", uCharacter, uOldMovementBase, uNewMovementBase))
  local MedievalCrane = self:GetMedievalCraneFromBase(uNewMovementBase)
  if MedievalCrane and MedievalCrane.AddCharacter then
    MedievalCrane:AddCharacter(self.Object)
  else
    MedievalCrane = self:GetMedievalCraneFromBase(uOldMovementBase)
    if MedievalCrane and MedievalCrane.RemoveCharacter then
      MedievalCrane:RemoveCharacter(self.Object)
    end
  end
end

function BRPlayerCharacterBase:GetMedievalCraneFromBase(Base)
  if not slua.isValid(Base) or not Base.GetOwner then return end
  local Lifter = Base:GetOwner()
  if not slua.isValid(Lifter) then return end
  if not Lifter.AddCharacter then return end
  return Lifter
end

-- ==============================================================================
-- PART 2: BRPlayerCharacterBase Functions (continued) + Full Mod Block
-- ==============================================================================

function BRPlayerCharacterBase:CharacterAttrChangeEvent(uPawn, AttrName, AttrVal)
  BRPlayerCharacterBase.__super.CharacterAttrChangeEvent(self, uPawn, AttrName, AttrVal)
  if self.Object ~= uPawn then return end
  if self.Role == ENetRole.ROLE_AutonomousProxy and AttrName == "bCanSelfRescue" then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:BroadcastUIMessage("UIMsg_CanSelfRescue", 0, "", "")
    end
  end
end

function BRPlayerCharacterBase:OnPawnStateChange(PawnState)
  print("BRPlayerCharacterBase:OnPawnStateChange:", PawnState)
  if PawnState == EPawnState.SwitchPP then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:BroadcastUIMessage("UIMsg_FPPModeChange", 0, "", "")
    end
  end
end

function BRPlayerCharacterBase:HandleFinishedState()
  print(bWriteLog and "BRPlayerCharacterBase:HandleFinishedState", self.STCharacterMovement)
  if slua.isValid(self.STCharacterMovement) and self.STCharacterMovement.SetDynamicSimpleQueryConfigDisable then
    local EDynamicSimpleQueryConfigDisableMask = import("EDynamicSimpleQueryConfigDisableMask")
    self.STCharacterMovement:SetDynamicSimpleQueryConfigDisable(EDynamicSimpleQueryConfigDisableMask.Bit0, true)
  end
end

function BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent()
  if CGameMode and CGameMode.GameModeType and CGameState and CGameState.GameModeID then
    local GameModeType = CGameMode.GameModeType
    local GameModeID = tonumber(CGameState.GameModeID)
    local bModeTypeSatisfy = GameModeType == EGameModeType.ETypicalGameMode or GameModeType == EGameModeType.EFourInOneGameMode or GameModeType == EGameModeType.EHeavyWeaponGameMode
    local bModeIDSatisfy = not MatchModeIds[GameModeID]
    print(bWriteLog and bWriteLog and "BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent:", GameModeType, GameModeID, bModeTypeSatisfy, bModeIDSatisfy)
    return bModeTypeSatisfy and bModeIDSatisfy
  end
  return false
end

function BRPlayerCharacterBase:LuaHandleParachuteStateChanged(LastParachuteState, NewParachuteState)
  BRPlayerCharacterBase.__super.LuaHandleParachuteStateChanged(self, LastParachuteState, NewParachuteState)
  if not Client then
    local uCurrentPlayerControl = self:GetPlayerControllerSafety()
    if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
      if NewParachuteState == EParachuteState.PS_Opening then
        if uCurrentPlayerControl.CheckParachuteOpenFeature.SatrtCheckShowParachuteCloseUI then
          uCurrentPlayerControl.CheckParachuteOpenFeature:SatrtCheckShowParachuteCloseUI()
        end
      elseif NewParachuteState == EParachuteState.PS_None then
        if uCurrentPlayerControl.CheckParachuteOpenFeature.RecoverParachuteOpenParam then
          uCurrentPlayerControl.CheckParachuteOpenFeature:RecoverParachuteOpenParam()
        end
        if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
          uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
        end
      end
    end
  end
end

function BRPlayerCharacterBase:OnLanded()
  printf("BRPlayerCharacterBase:OnLanded PlayerKey:%d", self.PlayerKey)
  if self.HandleOnLanded then
    self:HandleOnLanded(-1)
  end
  if not Client then
    local uCurrentPlayerControl = self:GetPlayerControllerSafety()
    if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
      if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
        uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
      end
      if uCurrentPlayerControl.CheckParachuteOpenFeature.ResetCheckShowUI then
        uCurrentPlayerControl.CheckParachuteOpenFeature:ResetCheckShowUI()
      end
    end
  end
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
  BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
  if Client then
    GameplayData.RemoveCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:IsWarGameMode()
  local uGameState = GameplayData:GetGameState()
  if slua.isValid(uGameState) and Game:IsClassOf(uGameState, STExtraGameStateBase) then
    return uGameState.GameModeType == EGameModeType.EWarGameMode
  else
    return false
  end
end

function BRPlayerCharacterBase:BPOnRecycled()
  print(bWriteLog and string.format("%s BPOnRecycled()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
  end
end

function BRPlayerCharacterBase:BPOnRespawned()
  print(bWriteLog and string.format("%s BPOnRespawned()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
  end
end

function BRPlayerCharacterBase:ReceiveOnRecycle()
  print(bWriteLog and string.format("%s IReusable:ReceiveOnRecycle()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
    GameplayData.RemoveCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:ReceiveOnSpawn()
  print(bWriteLog and string.format("%s IReusable:ReceiveOnSpawn()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
    GameplayData.AddCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:ResetMeshRelativeLocationAndRotation()
  if Game:IsValid(self.Object) and Game:IsValid(self.Mesh) then
    local uDefaultMeshRot = FRotator(0, -90, 0)
    local uDefaultMeshRelativeLoc = FVector(0, 0, 0)
    if self.Mesh.K2_SetRelativeRotation then
      self.Mesh:K2_SetRelativeRotation(uDefaultMeshRot, false, nil, false)
    end
    self:CacheInitialMeshOffset(uDefaultMeshRelativeLoc, uDefaultMeshRot)
  end
end

function BRPlayerCharacterBase:HandleOnMovementModeChangedNew()
  print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged11")
  if Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Swimming and self:CheckBaseIsMoveable() then
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged22")
    self.CharacterMovement:SetBase(nil, "", true)
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy and Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Walking and UIManager.UI_Config_InGame.ParachuteOpenUI then
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChangedNew CloseUI")
    UIManager.CloseUI(UIManager.UI_Config_InGame.ParachuteOpenUI)
  end
end

function BRPlayerCharacterBase:BPOnMissPlayerDamageRecord()
end

-- ===== ClientRPC Highlight Moment =====
BRPlayerCharacterBase.ClientRPC.ClientRPC_TriggerHighlightMoment = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.UInt32
  }
}

function BRPlayerCharacterBase:ClientRPC_TriggerHighlightMoment(Type, Param)
  print(bWriteLog and string.format("BRPlayerCharacterBase:ClientRPC_TriggerHighlightMoment Type = %d, Param = %s", Type, Param))
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_TRIGGER_HIGHLIGHT_MOMENT, Type, Param)
end

function BRPlayerCharacterBase:ParachuteJump()
  local uPlayerController = self:GetControllerSafety()
  if slua.isValid(uPlayerController) then
    if not self:GetEnsure() then
      if uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteJump and uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteOpen then
        self:SwitchPoseState(ESTEPoseState.Stand, true, true, true, false)
        uPlayerController:ReInitParachuteItem()
        uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteJump)
      end
      print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump over")
    else
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_CALL_PARACHUTE_JUMP, self.Object)
      print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump AI JUMP over, Loc=", tostring(self:K2_GetActorLocation():ToString()))
    end
  end
end

function BRPlayerCharacterBase:CheckForbidFlaregun()
  local uPlayerState = self:GetPlayerStateSafety()
  if not slua.isValid(uPlayerState) then return false end
  if uPlayerState.CanUseFlaregun == false and self:IsLocallyControlled() then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(48532)
    end
  end
  return not uPlayerState.CanUseFlaregun
end

function BRPlayerCharacterBase:ServerRPC_NearDeathGiveupRescue()
  self:HandleNearDeathGiveupRescue()
end

function BRPlayerCharacterBase:HandleNearDeathGiveupRescue()
  local uNearDeathComp = self.NearDeatchComponent
  if self:IsNearDeath() and slua.isValid(uNearDeathComp) and self.bCanNearDeathGiveup == true then
    local uPlayerState = self:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      uPlayerState:AddGeneralCount(1613, 1, false)
    end
    uNearDeathComp:TriggerGotoDieExplictly(self.Object)
  end
end

function BRPlayerCharacterBase:RPC_Server_GmPlayAction(actionId)
  log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction.  actionId: " .. tostring(actionId))
  if USTExtraBlueprintFunctionLibrary.IsDevelopment() then
    log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction. IsDevelopment actionId: " .. tostring(actionId))
    self:MulticastRPC_GmPlayAction(actionId)
  end
end

function BRPlayerCharacterBase:MulticastRPC_GmPlayAction(actionId)
  if not Client then return end
  log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction.  actionId: " .. tostring(actionId))
  local uPlayEmoteComp = self:GetPlayEmoteComponent()
  if not slua.isValid(uPlayEmoteComp) then return end
  local LogFilter = require("common.log_filter")
  LogFilter.SetLogTreeEnable(true)
  local animCfg = CDataTable.GetTableData("EmoteBPTable", actionId)
  if not animCfg then return end
  local handlePath = animCfg.Path
  local EmoteHandleAsset = slua.loadObject(handlePath)
  local assetsArray = slua.Array(UEnums.EPropertyClass.Struct, import("/Script/CoreUObject.SoftObjectPath"))
  local handle = EmoteHandleAsset()
  uPlayEmoteComp:OnLoadEmoteAssetBegin(handle, actionId, assetsArray, "")
  log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction. assetsArray:Num(): " .. tostring(assetsArray:Num()))
  local tb = FuncUtil.LuaArrayToTable(assetsArray)
  local asset_util = require("common.asset_util")
  local loadLater = function()
    uPlayEmoteComp:OnLoadEmoteAssetEnd(handle, actionId, 0)
  end
  asset_util.GetAssetsArrayAsyncParallel(tb, loadLater)
end

function BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall(bServerSyncShouldCheckPassWall)
  print(bWriteLog and "BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall " .. tostring(bServerSyncShouldCheckPassWall))
  if slua.isValid(self.ParachuteComponent) then
    self.ParachuteComponent.bServerSyncShouldCheckPassWall = bServerSyncShouldCheckPassWall
  end
end

function BRPlayerCharacterBase:OnPlayerEnterCarryBoxState()
  self.Super:OnPlayerEnterCarryBoxState()
  local CharName = self:GetPlayerNameSafety()
  print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerEnterCarryBoxState Role:%s PlayerKey:%s Name:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName)))
  if self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:OnPlayerEnterCarryBoxState()
  end
end

function BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  self.Super:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  local CharName = self:GetPlayerNameSafety()
  print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState Role:%s PlayerKey:%s Name:%s bInIsInterrupt:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName), tostring(bInIsInterrupt)))
  if self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  end
end

function BRPlayerCharacterBase:ServerRPC_CarryDeadBox(uInDeadBox)
  if slua.isValid(uInDeadBox) and Game:IsClassOf(uInDeadBox, import("/Script/ShadowTrackerExtra.PlayerTombBox")) and self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:CarryDeadBox(uInDeadBox)
  end
end

function BRPlayerCharacterBase:SetAreaID(AreaID)
  self:SetAttrValue("AreaID", AreaID, -1)
end

function BRPlayerCharacterBase:GetAreaID()
  return math.floor(self:GetAttrValue("AreaID") + 0.5)
end

function BRPlayerCharacterBase:CannotChangeIntoPetSpectator()
  print(bWriteLog and "BRPlayerCharacterBase:CannotChangeIntoPetSpectator")
  return self.bCannotChangeIntoPetSpectator
end

function BRPlayerCharacterBase:DoModChangeToBT()
  print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s", tostring(self.PlayerKey)))
  if self:HasState(EPawnState.SpecialSuit) then
    self:TriggerEntrySkillWithID(4301101, true)
    print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s, HasState(EPawnState.SpecialSuit)", tostring(self.PlayerKey)))
  end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteOpening()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening")
  self.Super:SwitchCameraToParachuteOpening()
  if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
    self.ParachuteFormation:OverlayFormationCameraParams()
  end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteFalling()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling")
  self.Super:SwitchCameraToParachuteFalling()
  if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
    self.ParachuteFormation:OverlayFormationCameraParams()
  end
end

function BRPlayerCharacterBase:SwitchCameraToNormal()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToNormal")
  self.Super:SwitchCameraToNormal()
  if self.ParachuteFormation and self.ParachuteFormation.OnLandingClearFormationCamera then
    self.ParachuteFormation:OnLandingClearFormationCamera()
  end
end

-- ===== SwitchWeaponCheck with Spider Swing check ADDED =====
function BRPlayerCharacterBase:SwitchWeaponCheck(Slot, IgnoreState)
  if self:HasState(EPawnState.AttachToOther) then
    local Weapon = self:GetWeaponBySlot(Slot)
    if slua.isValid(Weapon) then
      local WeaponID = Weapon:GetWeaponID()
      local AttachToOtherConfig = GamePlayTools.GetCurrentConfig("AttachToOtherConfig")
      if AttachToOtherConfig and AttachToOtherConfig.CheckIsWeaponInBlackList and AttachToOtherConfig.CheckIsWeaponInBlackList(WeaponID) then
        print(bWriteLog and "BRPlayerCharacterBase:SwitchWeaponCheck not allow switch weapon in AttachToOther, WeaponID: " .. tostring(WeaponID))
        local uPlayerController = self:GetPlayerControllerSafety()
        if Client and slua.isValid(uPlayerController) and uPlayerController.Role == ENetRole.ROLE_AutonomousProxy then
          uPlayerController:DisplayGameTipWithMsgID(47306)
        end
        return false
      end
    end
  end
  if self:HasState(EPawnState.WebSwing) and Slot ~= ESurviveWeaponPropSlot.SWPS_None and slua.isValid(self.STCharacterMovement) then
    local SpiderSwingObj = self.STCharacterMovement:GetSpecialMoveObjBySpecialMoveType(ESpecialMovementType.SPECIAL_MOVE_SpiderSwing)
    if slua.isValid(SpiderSwingObj) then
      local nCurState = SpiderSwingObj:GetCurMoveState()
      if nCurState == ESpiderSwingMoveState.Launching or nCurState == ESpiderSwingMoveState.Swinging then
        print(bWriteLog and "BRPlayerCharacterBase:SwitchWeaponCheck blocked by SpiderSwing state: " .. tostring(nCurState))
        return false
      end
    end
  end
  return self.Super:SwitchWeaponCheck(Slot, IgnoreState)
end

-- ===== VICTORY DANCE FX + EMOTE OVERRIDE (missing before) =====
local VICTORY_DANCE_FX_MAP = {
  [12219601] = 22010089
}

function ResolveEmoteResID(ItemID)
  local FxID = VICTORY_DANCE_FX_MAP[ItemID]
  if not FxID or FxID == ItemID then
    return ItemID
  end
  local model_util = require("client.common.model_util")
  local FxBPID = model_util.GetBPID(FxID)
  local ResID = ItemID
  if FxBPID and 0 < FxBPID and model_util.IsBattleItemHandleExist("Emote", FxBPID, false, false) then
    ResID = FxID
  end
  print(bWriteLog and string.format("BRPlayerCharacterBase 11 ResolveEmoteResID ItemID:%s, FxID:%s, FxBPID:%s, ResID:%s", tostring(ItemID), tostring(FxID), tostring(FxBPID), tostring(ResID)))
  return ResID
end

function BRPlayerCharacterBase:GetEmoteHandlePath(ItemID)
  local ResID = ResolveEmoteResID(ItemID)
  if self.Super then
    return self.Super:GetEmoteHandlePath(ResID)
  end
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(ResID)
  if not BPID or BPID <= 0 then
    return ""
  end
  return model_util.GetPath("Emote", BPID, false, false) or ""
end

function BRPlayerCharacterBase:GetEmoteHandle(ItemID)
  local ResID = ResolveEmoteResID(ItemID)
  if self.Super then
    return self.Super:GetEmoteHandle(ResID)
  end
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(ResID)
  if not BPID or BPID <= 0 then
    return nil
  end
  local HandleClass = model_util.GetClass("Emote", BPID, false, false)
  if not HandleClass then
    return nil
  end
  local Handle = HandleClass()
  if not slua.isValid(Handle) then
    return nil
  end
  return Handle
end

-- ==============================================================================
-- ============================ START FULL LOGIC MOD ==========================
-- ==============================================================================

local function Notify(msg) local s = "[GTLMOD VIP New] " .. tostring(msg)
pcall(function() if _G.PGNotify then _G.PGNotify(s) end end)
pcall(function() local sh = import("ScriptHelperClient") if sh and
sh.AddOnScreenDebugMessage then sh.AddOnScreenDebugMessage(s, -1, 3.0, {R=1,
G=1, B=0, A=1}, {X=1.2, Y=1.2}) end end) print(s) end

local _slua = rawget(_G, "slua")

local function Valid(obj) if not obj then return false end if _slua and
_slua.isValid then local ok, v = pcall(_slua.isValid, obj) if not ok or not v
then return false end end return true end

-- ========================================== 
-- STATIC VARIABLES & GLOBAL CACHE OPTIMIZED (LAG-FREE)
-- ========================================== 
local C_GREEN = {R=0, G=255, B=0, A=255}
local C_RED = {R=255, G=0, B=0, A=255}
local C_CYAN = {R=0, G=255, B=255, A=255}
local C_YELLOW = {R=255, G=255, B=0, A=255}
local C_WHITE = {R=255, G=255, B=255, A=255}
local C_BLUE_TEXT = {R=0, G=200, B=255, A=255}
local SCALE_COLOR_V2 = {R=3, G=3, B=0, A=0}

local GLOBAL_BONE_LIST = {
    "head", "neck_01", "pelvis",
    "upperarm_r", "lowerarm_r", "hand_r",
    "upperarm_l", "lowerarm_l", "hand_l",
    "thigh_l", "calf_l", "foot_l",
    "thigh_r", "calf_r", "foot_r"
}

-- ========================================== 
-- GTLMOD CORE + FULL FEATURES VIP CONFIGURATION 
-- ========================================== 
_G.PGConfig = _G.PGConfig or { 
    AutoHead = false, 
    EspVip = true, 
    EspDistance = false, 
    EspVipPro = false, 
    EspRadar = false, 
    Esp5 = false, 
    Esp6 = false, 
    Esp7 = true,
    Esp8 = false,
    EspAntenna = false, 
    EspName = false,
    EspOutline = false, 
    OutlineThickness = 10, 
    UnlockFPS = false, 
    IpadView = false, 
    CustomAimbot = false, 
    CustomAimbotClose = false, 
    CustomHRecoil = false,  
    CustomVRecoil = false,  
    LessShake = false, 
    RemoveGrass = false, 
    RemoveFog = false, 
    WhiteBody = false, 
    ColorBodyV2 = false,    
    wallhackng = false, 
    Crosshair = true, 
    Accuracy = false,
    GodMode = false, 
    BlackSky = false,
    AimTouchEnable = true,
    AimTouchIgKnock = true,
    AimTouchIgBot = true,
    AimTouchVisCheck = true,
    ModSkin = false,
    -- ESP V2
    EspLoai9 = false,
    Esp9_Count = false,
    Esp9_Line = false,
    Esp9_HP = false,
    Esp9_Weapon = false,
    Esp9_Team = false,
    Esp9_Distance = false,
    Esp9_Name = false,
    -- Brutal
    CustomMagicBullet = false,
    FastShoot = false,
    FastCar = false,
    HighJump = false,
    FastParachute = false,
}

_G.PGState = _G.PGState or { 
    LoopToken = 0, 
    AimbotLoopToken = 0,
    ESPV2LoopToken = 0,
    NativeESPReady = false,
    GraphicsUnlocked = false, 
    MenuStep = 0, 
    LastCmdTime = 0,
    TrackedMarks = {},
    EnemyMarks = {},
    LastAimbotCheckTime = 0, 
    CustomTextData = nil,     
    LastAimbotConfigString = "",
    PrevGraphicsState = {},
    SkinWasApplied = false,
}

local limitTime = os.time({ year = 2027, month = 10, day = 31, hour = 23, min = 59, sec = 0 })
local currentTime = os.time(os.date("!*t"))
local isExpired = false

pcall(function()
    local fileName = ".sys_time_cache"
    local paths = {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "../../ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
    }
    
    local tm = package.loaded["client.logic.common.TimeManager"]
    if not tm then 
        local s, r = pcall(require, "client.logic.common.TimeManager")
        if s and r then tm = r end
    end
    if tm and type(tm.GetServerTime) == "function" then
        local serverTime = tm.GetServerTime()
        if serverTime and serverTime > 1700000000 then 
            currentTime = serverTime
        end
    end

    local lastSeenTime = 0
    for _, path in ipairs(paths) do
        local file = io.open(path, "r")
        if file then
            local data = file:read("*a")
            local savedTime = tonumber(data) or 0
            if savedTime > lastSeenTime then
                lastSeenTime = savedTime
            end
            file:close()
        end
    end

    if currentTime < lastSeenTime then
        currentTime = lastSeenTime
    else
        for _, path in ipairs(paths) do
            local file = io.open(path, "w")
            if file then
                file:write(tostring(currentTime))
                file:close()
            end
        end
    end
end)

isExpired = (currentTime > limitTime)

-- ========================================== 
-- ULTIMATE BYPASS v3.0
-- ========================================== 
local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end
local function retNil() return nil end
local function retTrue() return true end
local function retEmptyString() return "" end

local function InitializeSLUABypass()
    pcall(function()
        if slua and slua.getSignature then slua.getSignature = function() return 0xDEADBEEF end end
        local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
        if loader then
            loader.verifyBytecode = retTrue
            loader.checkIntegrity = retTrue
            if loader.disableSignatureCheck then loader.disableSignatureCheck = retTrue end
        end
        local slua_serialize = package.loaded["slua.serialize"]
        if slua_serialize then slua_serialize.check = retTrue; slua_serialize.verify = retTrue end
        if jit and jit.attach then jit.attach(function() end, "bc") end
    end)
end

local function InitializeMD5Bypass()
    pcall(function()
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            console.ExecuteConsoleCommand(nil, "sig.Check 0")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
        end
        local CMode = import("CreativeModeBlueprintLibrary")
        if CMode then
            CMode.MD5HashByteArray = function() return "00000000000000000000000000000000" end
            CMode.MD5HashFile = function() return "00000000000000000000000000000000" end
            CMode.GetContentDiffData = function() return true, "BYPASSED" end
            CMode.VerifyFileIntegrity = retTrue
        end
    end)
end

local function InitializeSkinBypass()
    pcall(function()
        local ptlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
        if ptlog then ptlog.ReportEvent = nop; ptlog.ReportDownloadResult = nop; ptlog.ReportODPTDError = nop; ptlog.ReportSkinError = nop end
        local AvatarUtils = package.loaded["AvatarUtils"]
        if AvatarUtils then AvatarUtils.CheckIsWeaponInBlackList = retFalse; AvatarUtils.IsValidAvatar = retTrue; AvatarUtils.CheckAvatarIntegrity = retTrue; AvatarUtils.ReportInvalidAvatar = nop end
        local sub = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr"):Get("FileCheckSubsystem")
        if sub then sub.StartCheck = nop; sub.ReportAbnormalFile = nop; sub.StopCheck = nop end
    end)
end

local function InitializeLogBlocker()
    pcall(function()
        local SMTD = import("ScreenshotMTDer")
        if SMTD then SMTD.MTDePicture = function() return "" end; SMTD.HasCaptured = retTrue; SMTD.TakeScreenshot = nop end
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then TLog.Info = nop; TLog.Warning = nop; TLog.Error = nop; TLog.Debug = nop; TLog.Report = nop end
        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then CrashSight.ReportException = nop; CrashSight.SetCustomData = nop; CrashSight.Log = nop end
        local GRUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GRUtils then GRUtils.BugglyPostExceptionFull = retFalse; GRUtils.CheckCanBugglyPostException = retFalse; GRUtils.ReplayReportData = nop end
    end)
end

local function InitializeScannerBlocker()
    pcall(function()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local subs = {"AFKReportorSubsystem", "ClientDataStatistcsSubsystem", "AvatarExceptionSubsystem", "ShootVerifySubSystemClient", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem", "FileCheckSubsystem", "BehaviorScoreSubsystem"}
            for _, name in ipairs(subs) do
                local sub = SubMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Verify") or k:find("Check") or k:find("Scan")) then pcall(function() sub[k] = nop end) end
                    end
                end
            end
        end
    end)
end

local function InitializeHiggsBosonBypass()
    pcall(function()
        local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            for _, m in ipairs({"ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck", "StartAvatarCheck", "ReportItemID", "ShowSecurityAlert"}) do
                if Higgs[m] then Higgs[m] = nop end
            end
            Higgs.GetNetAvatarItemIDs = retEmpty; Higgs.GetCurWeaponSkinID = retZero; Higgs.IsMHActive = retFalse; Higgs.bMHActive = false; Higgs.bCallPreReplication = false
            if Higgs.BlackList then for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end end
        end
    end)
end

local function InitializeGameplayBypass()
    pcall(function()
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        if _G.GameplayCallbacks.IsBypassed then return end
        local GC = _G.GameplayCallbacks
        local reports = {"ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData"}
        for _, f in ipairs(reports) do GC[f] = nop end
        GC.CheckReportSecAttackFlowWithAttackFlow = retFalse; GC.CheckReportSecAttackFlow = retFalse
        GC.OnPlayerNetConnectionClosed = nop; GC.OnPlayerActorChannelError = nop; GC.OnPlayerRPCValidateFailed = nop; GC.OnPlayerSpectateException = nop; GC.OnShutdownAfterError = nop
        GC.IsBypassed = true
    end)
end

_G.StartBypass_VIP_v3 = function()
    pcall(function()
        print("[ULTIMATE BYPASS] Starting initialization...")
        InitializeSLUABypass()
        InitializeMD5Bypass()
        InitializeSkinBypass()
        InitializeLogBlocker()
        InitializeScannerBlocker()
        InitializeHiggsBosonBypass()
        InitializeGameplayBypass()
        print("[ULTIMATE BYPASS] COMPLETE - ALL SECURITY SYSTEMS DISABLED")
    end)
end

-- ========================================== 
-- MAP MARK HELPERS
-- ========================================== 
local function SafeAddMark(id, pos, z, str, size, actor)
    local mark = nil
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            mark = InGameMarkTools.ClientAddMapMark(id, pos, z, str, size, actor)
            if mark then _G.PGState.TrackedMarks[mark] = true end
        end
    end)
    return mark
end

local function SafeRemoveMark(mark)
    if not mark then return end
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.HideMapMark then InGameMarkTools.HideMapMark(mark) end
        if InGameMarkTools and InGameMarkTools.RemoveMapMark then InGameMarkTools.RemoveMapMark(mark) end
    end)
    _G.PGState.TrackedMarks[mark] = nil
end

local function GetSafeEnemyKey(enemy)
    if Valid(enemy) then
        if enemy.PlayerKey then return tostring(enemy.PlayerKey) end
        if type(enemy.GetUniqueID) == "function" then return tostring(enemy:GetUniqueID()) end
    end
    return tostring(enemy)
end

local function CheckIsAI(pawn, markData)
    if markData.AK_IS_BOT ~= nil then return markData.AK_IS_BOT, true end
    local isAI = false
    local hasChecked = false
    pcall(function()
        if pawn.bIsAI == true or pawn.IsAI == true then isAI = true; hasChecked = true end
        if type(pawn.IsBot) == "function" and pawn:IsBot() then isAI = true; hasChecked = true end
        local pState = pawn.PlayerState or (type(pawn.GetPlayerState) == "function" and pawn:GetPlayerState())
        if Valid(pState) then
            hasChecked = true
            if pState.bIsABot == true or pState.bIsBot == true then isAI = true end
            if type(pState.IsBot) == "function" and pState:IsBot() then isAI = true end
        end
    end)
    if hasChecked then markData.AK_IS_BOT = isAI end
    return isAI, hasChecked
end

-- ========================================== 
-- AUTO HEAD HOOKS
-- ==========================================
function _G.InitializeAutoHeadHooks()
    pcall(function()
        local EAvatarDamagePosition = import("EAvatarDamagePosition")
        if not EAvatarDamagePosition then return end
        local modulesToHook = {
            "GameLua.Mod.BaseMod.Common.Weapon.ShootWeaponEntity",
            "GameLua.Logic.Weapon.ShootWeaponEntity"
        }
        for _, path in ipairs(modulesToHook) do
            local hitLogic = package.loaded[path]
            if hitLogic then
                local original_GetHitBodyType = hitLogic.GetHitBodyType
                hitLogic.GetHitBodyType = function(self, ImpactResult, InImpactVec)
                    if _G.PGConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyType then return original_GetHitBodyType(self, ImpactResult, InImpactVec) end
                end
                local original_GetHitBodyTypeByHitPos = hitLogic.GetHitBodyTypeByHitPos
                hitLogic.GetHitBodyTypeByHitPos = function(self, InImpactVec)
                    if _G.PGConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyTypeByHitPos then return original_GetHitBodyTypeByHitPos(self, InImpactVec) end
                end
            end
        end
    end)
end

-- ========================================== 
-- COLOR CONFIGURATION
-- ==========================================
if _G.ColorConfig == nil then
    _G.ColorConfig = {
        VisibleColor = 4,
        InvisibleColor = 1,
        Brightness = 25,
        Glow = 3.0,
    }
end

local COLOR_MAP = {
    [1] = {R=255, G=0,   B=0},
    [2] = {R=255, G=255, B=255},
    [3] = {R=255, G=255, B=0},
    [4] = {R=0,   G=255, B=0},
    [5] = {R=0,   G=255, B=255},
    [6] = {R=0,   G=0,   B=255},
    [7] = {R=255, G=0,   B=255}
}

local function GetAppliedColor(colorIdx, brightness)
    local base = COLOR_MAP[colorIdx] or COLOR_MAP[4]
    local b = brightness or _G.ColorConfig.Brightness or 25
    return {
        R = math.min(255, (base.R or 0) * b / 25),
        G = math.min(255, (base.G or 0) * b / 25),
        B = math.min(255, (base.B or 0) * b / 25),
        A = 255
    }
end

-- ========================================== 
-- CONFIG SAVE / LOAD
-- ==========================================
local function GetConfigPaths(fileName)
    local paths = {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "../../ShadowTrackerExtra/Saved/Paks/" .. fileName,
        fileName
    }
    return paths
end

local ConfigFileName = "@PGHACKS1.txt"
_G.LastConfigSaveStr = ""

_G.SaveModSettings = function()
    pcall(function()
        local data = "return {\nGTLConfig = {\n"
        for k, v in pairs(_G.PGConfig or {}) do
            data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n"
        end
        data = data .. "},\nCustomTextData = {\n"
        if _G.PGState and _G.PGState.CustomTextData then
            for k, v in pairs(_G.PGState.CustomTextData) do
                data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n"
            end
        end
        data = data .. "},\nColorConfig = {\n"
        for k, v in pairs(_G.ColorConfig or {}) do
            data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n"
        end
        data = data .. "}\n}"
        if data == _G.LastConfigSaveStr then return end
        _G.LastConfigSaveStr = data
        local paths = GetConfigPaths(ConfigFileName)
        for _, path in ipairs(paths) do
            local file = io.open(path, "w")
            if file then
                file:write(data)
                file:close()
                break
            end
        end
    end)
end

_G.LoadModSettings = function()
    pcall(function()
        local paths = GetConfigPaths(ConfigFileName)
        local content = nil
        for _, path in ipairs(paths) do
            local file = io.open(path, "r")
            if file then
                content = file:read("*a")
                file:close()
                break
            end
        end
        if content then
            local func = load(content)
            if func then
                local savedData = func()
                if savedData and type(savedData) == "table" then
                    if savedData.GTLConfig then
                        for k, v in pairs(savedData.GTLConfig) do _G.PGConfig[k] = v end
                    end
                    if savedData.CustomTextData then
                        _G.PGState.CustomTextData = _G.PGState.CustomTextData or {}
                        for k, v in pairs(savedData.CustomTextData) do _G.PGState.CustomTextData[k] = v end
                    end
                    if savedData.ColorConfig then
                        for k, v in pairs(savedData.ColorConfig) do _G.ColorConfig[k] = v end
                    end
                end
            end
        end
        _G.SaveModSettings() 
    end)
end

local function AutoSaveLoop()
    pcall(function() if _G.SaveModSettings then _G.SaveModSettings() end end)
    pcall(function()
        local okTicker, ticker = pcall(require, "common.time_ticker") 
        if okTicker and ticker and ticker.AddTimerOnce then 
            ticker.AddTimerOnce(3.0, AutoSaveLoop)
        end
    end)
end

if not _G.ModConfigLoaded then
    _G.LoadModSettings()
    AutoSaveLoop()
    _G.ModConfigLoaded = true
end

_G.ReadLiveConfig = function()
    if _G.SaveModSettings then _G.SaveModSettings() end
end

-- ========================================== 
-- SKIN MOD SYSTEM (FULL — with VIP_Attachments)
-- ==========================================
_G.VIP_Attachments = _G.VIP_Attachments or {
    [1101004236]={1010042307,1010042306,1010042308,1010042304,1010042300,1010042305,1010042299,1010042298,1010042297,1010042296,1010042295,1010042294,0,1010042314,1010042309,1010042316,1010042317,1010042318,1010042310,1010042315,1010042319,0},
    [1101001116]={1010011106,1010011107,1010011108,0,1010011109,1010011112,1010011105,1010011104,1010011103,0,1010011102,0,0,0,0,0,0,0,0,0,0,0},
    [1101001128]={1010011232,1010011233,1010011234,1010011228,1010011227,1010011229,1010011226,1010011225,1010011224,1010011223,1010011222,0,0,0,0,0,0,0,0,0,0,0},
    [1101001154]={1010011487,1010011488,1010011489,1010011493,1010011490,1010011494,1010011486,1010011485,1010011484,1010011483,1010011482,1010011497,0,0,0,0,0,0,0,0,1010011498,0},
    [1101001174]={1010011667,1010011668,1010011669,1010011673,1010011670,1010011674,1010011666,1010011665,1010011664,1010011663,1010011662,0,0,0,0,0,0,0,0,0,0,0},
    [1101001213]={1010012067,1010012068,1010012069,1010012072,1010012070,1010012073,1010012066,1010012065,1010012064,1010012063,1010012062,0,0,0,0,0,0,0,0,0,1010012074,0},
    [1101001231]={1010012267,1010012268,1010012269,1010012273,1010012272,1010012274,1010012266,1010012265,1010012264,1010012263,1010012262,1010012075,0,0,0,0,0,0,0,0,1010012275,0},
    [1101001242]={1010012357,1010012358,1010012359,1010012363,1010012362,1010012364,1010012356,1010012355,1010012354,1010012353,1010012352,1010012276,0,0,0,0,0,0,0,0,1010012365,0},
    [1101001249]={1010012437,1010012438,1010012439,1010012443,1010012442,1010012444,1010012436,1010012435,1010012434,1010012433,1010012432,1010012366,0,0,0,0,0,0,0,0,1010012445,0},
    [1101001256]={1010012588,1010012589,1010012590,1010012593,1010012592,1010012594,1010012587,1010012586,1010012585,1010012584,1010012583,1010012582,0,0,0,0,0,0,0,0,1010012595,0},
    [1101001265]={1010012651,00,0,0,0,0,0,0,0,1010012651,0},
    [1101001276]={1010012698,1010012699,1010012700,1010012703,1010012702,1010012704,1010012697,1010012696,1010012695,1010012694,1010012693,1010012692,0,0,0,0,0,0,0,0,1010012705,0},
    [1101002029]={1010020249,1010020250,1010020255,1010020247,1010020246,1010020248,1010020240,1010020239,1010020238,1010020237,1010020236,1010020235,0,0,0,0,0,0,0,1010020257,1010020256,1010020258},
    [1101002056]={1010020519,0,0,1010020517,1010020516,1010020518,1010020500,1010020509,1010020508,1010020507,1010020506,1010020505,0,0,0,0,0,0,0,0,0,0},
    [1101002081]={1010020768,1010020769,1010020770,1010020766,1010020760,1010020767,1010020759,1010020758,1010020757,1010020756,1010020755,1010020776,0,0,0,0,0,0,0,1010020775,1010020777,1010020778},
    [1101003070]={1010030654,1010030653,1010030655,1010030649,1010030648,1010030650,1010030647,1010030646,1010030645,1010030644,1010030643,1010030642,0,1010030658,1010030656,1010030660,1010030662,1010030659,1010030657,0,1010030663,0},
    [1101003080]={1010030754,1010030753,1010030755,1010030749,1010030748,1010030750,1010030747,1010030746,1010030745,1010030744,1010030743,1010030742,0,1010030758,1010030756,1010030760,1010030762,1010030759,1010030757,0,1010030763,0},
    [1101003099]={1010030943,1010030944,1010030945,1010030939,1010030938,1010030942,1010030937,1010030936,1010030935,1010030934,1010030933,1010030932,0,1010030947,1010030946,1010030948,1010030949,1010030953,1010030952,0,1010030955,0},
    [1101003119]={1010031139,1010031140,1010031142,1010031138,1010031137,1010031146,1010031136,1010031135,1010031134,1010031133,1010031132,0,0,1010031144,1010031143,0,0,0,1010031145,0,0,0},
    [1101003146]={1010031229,1010031230,1010031237,1010031228,1010031227,1010031242,1010031226,1010031225,1010031224,1010031223,1010031222,0,0,1010031239,1010031238,0,0,0,1010031240,0,0,0},
    [1101003167]={1010031609,1010031610,1010031613,1010031608,1010031607,1010031617,1010031606,1010031605,1010031604,1010031603,1010031602,1010031618,0,1010031615,1010031614,1010031620,1010031622,1010031619,1010031616,0,1010031623,0},
    [1101003181]={1010031765,1010031764,1010031766,1010031759,1010031758,1010031763,1010031757,1010031756,1010031755,1010031754,1010031753,1010031752,0,1010031769,1010031767,1010031773,1010031774,1010031772,1010031768,0,1010031775,0},
    [1101003195]={1010031912,1010031911,1010031913,1010031908,1010031907,1010031909,1010031906,1010031905,1010031904,1010031903,1010031902,1010031901,0,1010031916,1010031914,1010031918,1010031919,1010031917,1010031915,0,1010031921,0},
    [1101003208]={1010032034,1010032033,1010032045,1010032029,1010032028,1010032032,1010032027,1010032026,1010032025,1010032024,1010032023,1010032022,0,1010032038,1010032036,1010032042,1010032043,1010032039,1010032037,0,1010032044,0},
    [1101004046]={1010040474,1010040475,1010040476,1010040472,1010040471,1010040473,1010040470,1010040469,1010040468,1010040467,1010040466,1010040481,0,1010040479,1010040477,1010040482,1010040483,1010040484,1010040478,1010040480,1010040485,0},
    [1101004062]={1010040578,1010040577,1010040579,1010040575,1010040570,1010040576,1010040569,1010040568,1010040567,1010040566,1010040565,1010040564,0,1010040585,1010040580,1010040587,1010040588,1010040589,1010040584,1010040586,1010040590,1010040594},
    [1101004098]={1010040924,1010040926,1010040925,0,1010040937,1010040938,1010040935,1010040934,1010040929,1010040928,1010040927,0,0,1010040939,1010040945,0,0,0,1010040944,1010040936,0,0},
    [1101004138]={1010041136,1010041137,1010041138,1010041134,1010041129,1010041135,1010041128,1010041127,1010041126,1010041125,1010041124,0,0,1010041145,1010041139,0,0,0,1010041144,1010041146,0,0},
    [1101004163]={1010041570,1010041574,1010041575,1010041568,1010041567,1010041569,1010041566,1010041565,1010041564,1010041560,1010041554,0,0,1010041578,1010041576,0,0,0,1010041577,1010041579,0,0},
    [1101004201]={1010041956,1010041957,1010041958,1010041950,1010041949,1010041955,1010041948,1010041947,1010041946,1010041945,1010041944,1010041967,0,1010041965,1010041959,0,0,0,1010041960,1010041966,0,0},
    [1101004209]={1010042038,1010042037,1010042039,1010042035,1010042034,1010042036,1010042029,1010042028,1010042027,1010042026,1010042025,1010042024,0,1010042046,1010042044,1010042048,1010042049,1010042054,1010042045,1010042047,1010042055,0},
    [1101004218]={1010042128,1010042127,1010042129,1010042125,1010042124,1010042126,1010042119,1010042118,1010042117,1010042116,1010042115,1010042114,0,1010042136,1010042134,1010042138,1010042139,1010042144,1010042135,1010042137,1010042145,0},
    [1101004226]={1010042238,1010042237,1010042239,1010042235,1010042234,1010042236,1010042233,1010042232,1010042231,1010042219,1010042218,1010042217,0,1010042243,1010042241,1010042245,1010042246,1010042247,1010042242,1010042244,1010042248,0},
    [1101004246]={1010042406,1010042407,1010042408,1010042404,1010042400,1010042405,1010042399,1010042398,1010042397,1010042396,1010042395,1010042394,0,1010042414,1010042409,1010042416,1010042417,1010042418,1010042410,1010042415,1010042419,1010042420},
    [1101005038]={0,0,1010050327,1010050329,1010050328,1010050330,1010050326,1010050325,1010050324,1010050323,1010050322,1010050334,0,0,0,0,0,0,0,0,0,0},
    [1101005052]={0,0,1010050467,1010050469,1010050468,1010050470,1010050466,1010050465,1010050464,1010050463,1010050462,1010050473,0,0,0,0,0,0,0,0,0,0},
    [1101005098]={0,0,1010050928,1010050930,1010050929,1010050932,1010050927,1010050926,1010050925,1010050924,1010050923,1010050922,0,0,0,0,0,0,0,0,0,0},
    [1101006062]={1010060573,1010060572,1010060574,1010060564,1010060563,1010060571,1010060562,1010060561,1010060554,1010060553,1010060552,1010060551,0,1010060583,1010060581,1010060591,1010060592,1010060584,1010060582,0,1010060593,0},
    [1101006075]={1010060702,1010060701,1010060703,1010060698,1010060697,1010060699,1010060696,1010060695,1010060694,1010060693,1010060692,1010060691,0,1010060706,1010060704,1010060708,1010060709,1010060707,1010060705,0,1010060711,0},
    [1101006085]={1010060796,1010060795,1010060797,1010060793,1010060789,1010060794,1010060788,1010060787,1010060786,1010060785,1010060784,1010060783,0,1010060800,1010060798,1010060804,1010060805,1010060803,1010060799,0,1010060806,0},
    [1101007046]={1010070410,1010070413,1010070414,1010070408,1010070407,1010070409,1010070406,1010070405,1010070404,1010070403,1010070402,1010070418,0,1010070417,1010070415,1010070420,1010070422,1010070419,1010070416,0,1010070423,0},
    [1101007062]={1010070579,1010070578,1010070581,1010070576,1010070575,1010070577,1010070574,1010070573,1010070572,1010070571,1010070569,1010070568,0,1010070584,1010070582,1010070585,1010070586,1010070587,1010070583,0,1010070588,0},
    [1101007071]={1010070663,1010070662,1010070664,1010070659,1010070658,1010070660,1010070657,1010070656,1010070655,1010070654,1010070653,1010070652,0,1010070667,1010070665,1010070668,1010070669,1010070670,1010070666,0,1010070672,0},
    [1101008051]={1010080463,1010080464,1010080465,1010080459,1010080458,1010080462,1010080457,1010080456,1010080455,1010080454,1010080453,1010080452,0,1010080467,1010080466,1010080468,1010080469,1010080473,1010080472,0,1010080475,0},
    [1101008061]={1010080563,1010080564,1010080565,1010080559,1010080558,1010080562,1010080557,1010080556,1010080555,1010080554,1010080553,0,0,1010080567,1010080566,0,0,0,1010080572,0,0,0},
    [1101008070]={1010080609,1010080612,1010080613,1010080608,1010080607,1010080617,1010080606,1010080605,1010080604,1010080603,1010080602,0,0,1010080615,1010080614,0,0,0,1010080616,0,0,0},
    [1101008081]={1010080740,1010080743,1010080745,1010080738,1010080737,1010080739,1010080736,1010080735,1010080734,1010080733,1010080732,1010080748,0,1010080747,1010080746,1010080750,1010080752,1010080749,1010080744,0,1010080753,0},
    [1101008104]={1010080980,1010080982,1010080984,1010080978,1010080977,1010080979,1010080976,1010080975,1010080974,1010080973,1010080972,1010080992,0,1010080986,1010080985,1010080989,1010080987,1010080993,1010080983,0,1010080988,0},
    [1101008116]={1010081110,1010081112,1010081114,1010081108,1010081107,1010081109,1010081106,1010081105,1010081104,1010081103,1010081102,0,0,1010081116,1010081115,0,0,0,1010081113,0,0,0},
    [1101008126]={1010081210,1010081225,1010081226,1010081208,1010081207,1010081209,1010081206,1010081205,1010081204,1010081203,1010081202,1010081218,0,1010081217,1010081216,1010081219,1010081220,1010081222,1010081214,1010081228,1010081227,1010081229},
    [1101008136]={1010081314,1010081315,1010081316,1010081312,1010081308,1010081313,1010081307,1010081306,1010081305,1010081304,1010081303,1010081302,0,1010081318,1010081317,1010081322,1010081323,1010081325,1010081324,0,1010081326,0},
    [1101008146]={1010081401,1010081402,1010081403,1010081398,1010081397,1010081399,1010081396,1010081395,1010081394,1010081393,1010081392,1010081391,0,1010081405,1010081404,1010081406,1010081407,1010081409,1010081408,0,1010081411,0},
    [1101008154]={1010081531,1010081532,1010081533,1010081528,1010081527,1010081529,1010081526,1010081525,1010081524,1010081523,1010081522,1010081521,0,1010081541,1010081534,1010081542,1010081543,1010081545,1010081544,0,1010081546,0},
    [1101008163]={1010081582,1010081583,1010081584,1010081579,1010081578,1010081580,1010081577,1010081576,1010081575,1010081574,1010081573,1010081572,0,1010081586,1010081585,1010081587,1010081588,1010081590,1010081589,0,1010081592,0},
    [1101012033]={1010120284,1010120285,1010120286,1010120280,1010120279,1010120283,1010120278,1010120277,1010120276,1010120275,1010120274,1010120273,0,0,0,0,0,0,0,0,1010120287,0},
    [1101100012]={1011000066,1011000067,1011000068,0,0,0,1011000058,1011000057,1011000056,1011000055,1011000054,1011000053,0,0,0,0,0,0,0,0,1011000073,0},
    [1101102007]={1011010025,1011010024,1011010026,1011010020,1011010019,1011010023,1011010018,1011010017,1011010016,1011010015,1011010014,1011010013,0,0,0,0,0,0,0,0,1011010027,0},
    [1101102017]={1011020027,1011020028,1011020029,1011020025,1011020024,1011020026,1011020019,1011020018,1011020017,1011020016,1011020015,1011020014,0,1011020036,1011020034,1011020038,1011020039,1011020044,1011020035,1011020037,1011020045,1011020047},
    [1101102025]={1011020127,1011020128,1011020129,1011020125,1011020124,1011020126,1011020119,1011020118,1011020117,1011020116,1011020115,1011020114,0,1011020136,1011020134,1011020138,1011020139,1011020144,1011020135,1011020137,1011020145,0},
    [1101102041]={1011020214,1011020215,1011020216,1011020212,1011020211,1011020213,1011020209,1011020208,1011020207,1011020206,1011020205,1011020204,0,1011020219,1011020217,1011020222,1011020223,1011020224,1011020218,1011020221,1011020225,1011020229},
    [1101102049]={1011020356,1011020357,1011020358,1011020354,1011020350,1011020355,1011020349,1011020348,1011020347,1011020346,1011020345,1011020344,0,1011020364,1011020359,1011020366,1011020367,1011020368,1011020360,1011020365,1011020369,1011020370},
    [1101101007]={1011020436,1011020437,1011020438,1011020434,1011020430,1011020435,1011020429,1011020428,1011020427,1011020426,1011020425,1011020424,0,1011020444,1011020439,1011020446,1011020447,1011020448,1011020440,1011020445,1011020449,1011020450},
    [1102001120]={1020011137,1020011138,1020011139,1020011135,1020011134,1020011136,1020011133,1020011132,0,0,0,0,0,0,0,0,0,0,0,1020011142,0,0},
    [1102001130]={1020011247,1020011248,1020011249,1020011245,1020011244,1020011246,1020011243,1020011242,0,0,0,0,0,0,0,0,0,0,0,1020011250,0,0},
    [1102002043]={1020020372,1020020374,1020020373,1020020383,1020020380,1020020384,1020020379,1020020378,1020020377,1020020376,1020020375,1020020388,0,1020020385,1020020387,0,0,0,1020020386,0,0,0},
    [1102002061]={1020020552,1020020554,1020020553,1020020563,1020020562,1020020564,1020020559,1020020558,1020020557,1020020556,1020020555,1020020578,0,1020020565,1020020567,1020020573,1020020574,1020020572,1020020566,0,1020020569,0},
    [1102002136]={1020021314,1020021313,1020021315,1020021309,1020021308,1020021312,1020021307,1020021306,1020021305,1020021304,1020021303,1020021302,0,1020021318,1020021316,1020021323,1020021324,1020021322,1020021317,0,1020021325,0},
    [1102002424]={1020024193,1020024192,1020024194,1020024189,1020024188,1020024190,1020024187,1020024186,1020024185,1020024184,1020024183,1020024182,0,1020024197,1020024195,1020024199,1020024200,1020024198,1020024196,0,1020024202,0},
    [1102003080]={1020030755,1020030756,1020030758,0,1020030749,1020030754,1020030748,1020030747,1020030746,1020030745,1020030744,1020030764,0,1020030760,0,1020030759,1020030757,0,0,1020030765,0,0},
    [1102003100]={1020030956,1020030957,1020030958,1020030954,1020030950,1020030955,1020030949,1020030948,1020030947,1020030946,1020030945,1020030944,0,1020030964,0,1020030960,1020030959,1020030965,0,1020030967,1020030966,1020030968},
    [1102005064]={1020050588,1020050589,1020050590,0,0,0,1020050587,1020050586,1020050585,1020050584,1020050583,1020050582,0,0,0,0,0,0,0,0,1020050592,0},
    [1103001101]={1030010954,1030010955,1030010956,0,0,0,0,0,0,0,1030010953,1030010952,1030010951,0,0,0,0,0,0,1030010957,0,1030010958},
    [1103001146]={1030011344,1030011345,1030011346,0,0,0,0,0,0,0,1030011343,1030011342,1030011341,0,0,0,0,0,0,1030011347,0,1030011348},
    [1103001154]={1030011484,1030011485,1030011486,0,0,0,0,0,0,0,1030011483,1030011482,1030011481,0,0,0,0,0,0,1030011487,0,1030011488},
    [1103001179]={1030011738,1030011739,1030011741,0,0,0,1030011737,1030011736,1030011735,1030011734,1030011733,1030011732,1030011731,0,0,0,0,0,0,1030011742,1030011743,1030011744},
    [1103001191]={1030011858,1030011859,1030011861,0,0,0,1030011857,1030011856,1030011855,1030011854,1030011853,1030011852,1030011851,0,0,0,0,0,0,1030011862,1030011863,1030011864},
    [1103001202]={1030011948,1030011949,1030011950,0,0,0,1030011947,1030011946,1030011945,1030011944,1030011943,1030011942,1030011941,0,0,0,0,0,0,1030011951,1030011952,1030011953},
    [1103002030]={1030020245,1030020246,1030020247,1030020252,1030020249,1030020253,1030020258,1030020257,1030020256,1030020255,1030020244,1030020243,1030020242,0,0,0,0,0,0,1030020248,0,0},
    [1103002059]={1030020544,1030020545,1030020546,1030020542,1030020539,1030020543,1030020538,1030020537,1030020536,1030020535,1030020534,1030020533,1030020532,0,0,0,0,0,0,1030020547,1030020548,0},
    [1103002087]={1030020824,1030020825,1030020826,0,0,0,1030020818,1030020817,1030020816,1030020815,1030020814,1030020813,1030020812,0,0,0,0,0,0,1030020827,1030020828,0},
    [1103002106]={1030021009,1030021010,1030021012,1030021015,1030021014,1030021016,1030021008,1030021007,1030021006,1030021005,1030021004,1030021003,1030021002,0,0,0,0,0,0,1030021013,1030021017,0},
    [1103002113]={1030021079,1030021080,1030021082,1030021085,1030021084,1030021086,1030021078,1030021077,1030021076,1030021075,1030021074,1030021073,1030021072,0,0,0,0,0,0,1030021083,1030021087,0},
    [1103003022]={1030030165,1030030166,1030030167,1030030172,1030030169,1030030173,0,0,0,0,1030030164,1030030163,1030030162,0,0,0,0,0,0,0,0,0},
    [1103003030]={1030030256,1030030257,1030030258,1030030254,1030030253,1030030255,1030030248,1030030247,1030030246,1030030245,1030030244,1030030243,1030030242,0,0,0,0,0,0,1030030259,1030030249,0},
    [1103003042]={1030030374,1030030375,1030030376,1030030372,1030030369,1030030373,0,0,0,0,1030030364,1030030363,1030030362,0,0,0,0,0,0,1030030377,0,0},
    [1103003051]={1030030458,1030030459,1030030460,1030030456,1030030455,1030030457,0,0,0,0,1030030454,1030030453,1030030452,0,0,0,0,0,0,1030030463,0,0},
    [1103003062]={1030030568,1030030569,1030030570,1030030566,1030030565,1030030567,0,0,0,0,1030030564,1030030563,1030030562,0,0,0,0,0,0,1030030572,0,0},
    [1103003079]={1030030744,1030030745,1030030746,1030030742,1030030740,1030030743,1030030738,1030030737,1030030736,1030030735,1030030734,1030030733,1030030732,0,0,0,0,0,0,1030030747,1030030739,0},
    [1103003087]={1030030825,1030030826,1030030827,1030030823,1030030824,1030030824,1030030818,1030030817,1030030816,1030030815,1030030814,1030030813,1030030812,0,0,0,0,0,0,1030030828,1030030819,0},
    [1103004037]={1030040315,1030040316,1030040317,1030040325,1030040324,1030040323,0,0,0,0,1030040314,1030040313,1030040312,1030040327,1030040326,0,0,0,1030040328,1030040329,0,0},
    [1103006030]={1030060245,1030060246,1030060247,0,1030060253,1030060252,0,0,0,0,1030060244,1030060243,1030060242,0,0,0,0,0,0,0,0,0},
    [1103007028]={1030070233,1030070234,1030070235,1030070226,1030070225,1030070227,1030070218,1030070217,1030070216,1030070215,1030070214,1030070213,1030070212,0,0,0,0,0,0,1030070236,1030070219,0},
    [1103012010]={0,0,0,0,0,0,1030120038,1030120037,1030120036,1030120035,1030120034,1030120033,1030120032,0,0,0,0,0,0,0,0,0},
    [1103012019]={0,0,0,0,0,0,1030120138,1030120137,1030120136,1030120135,1030120134,1030120133,1030120132,0,0,0,0,0,0,0,0,0},
    [1103012031]={0,0,0,0,0,0,1030120258,1030120257,1030120256,1030120255,1030120254,1030120253,1030120252,0,0,0,0,0,0,0,0,0},
    [1103012039]={0,0,0,0,0,0,1030120339,1030120338,1030120337,1030120336,1030120335,1030120334,1030120333,0,0,0,0,0,0,0,0,0},
    [1103102007]={1031020026,1031020027,1031020028,1031020024,1031020023,1031020025,1031020019,1031020018,1031020017,1031020016,1031020015,1031020014,1031020013,0,0,0,0,0,0,1031020029,0,0},
    [1105001034]={0,0,0,0,1050010287,1050010289,1050010286,1050010285,1050010284,1050010283,1050010282,0,0,0,0,0,0,0,0,1050010292,0,0},
    [1105001048]={0,0,0,1050010429,1050010428,1050010434,1050010427,1050010426,1050010425,1050010424,1050010423,0,0,0,0,0,0,0,0,1050010435,0,1050010436},
    [1105001069]={0,0,0,1050010639,1050010638,1050010640,1050010637,1050010636,1050010635,1050010634,1050010633,1050010645,0,0,0,0,0,0,0,1050010643,1050010646,1050010644},
    [1105002091]={0,0,0,0,0,0,1050020847,1050020846,1050020845,1050020844,1050020843,1050020842,0,0,0,0,0,0,0,0,0,1050020848},
    [1105010019]={0,0,0,0,0,0,1050100144,1050100143,1050100142,1050100141,1050100139,1050100138,0,0,0,0,0,0,0,0,0,0}
}

_G.BaseAttachToIndex = _G.BaseAttachToIndex or {
    [201010]=1, [201005]=1, [201004]=1, [201009]=2, [201003]=2, [201002]=2, 
    [201011]=3, [201007]=3, [201006]=3, [204012]=4, [204005]=4, [204008]=4, 
    [204011]=5, [204004]=5, [204007]=5, [204013]=6, [204006]=6, [204009]=6, 
    [203001]=7, [203002]=8, [203003]=9, [203014]=10, [203004]=11, [203015]=12, [203005]=13, 
    [202002]=14, [202001]=15, [202004]=16, [202005]=17, [202007]=18, [202006]=19, 
    [205002]=20, [205003]=20, [205001]=20, [203018]=21, [204014]=22 
}

_G.VipAttachToIndex = _G.VipAttachToIndex or {}
for skinId, attachList in pairs(_G.VIP_Attachments) do
    for index, attachId in ipairs(attachList) do
        if attachId > 0 then
            _G.VipAttachToIndex[attachId] = index
        end
    end
end

_G.WeaponSkinMap = _G.WeaponSkinMap or {}
_G.VehicleSkinMap = _G.VehicleSkinMap or {}
_G.OutfitMap = _G.OutfitMap or {}
_G.skinIdCache = _G.skinIdCache or {}
_G.skinIdCache2 = _G.skinIdCache2 or {}

_G.OutfitSkins = _G.OutfitSkins or {
    Suit = {1405628,1407895,1407140,1407141,1407142,1407550,1406872,1406971,1407103,1407219,1407366,1407512,1407625,1407856,1407906,1407994,1407993,403003,1407906,1407921,1406388,1406387,1406386,1407142,1407550,1406638,1406872,1406971,1407103,1407512,1407391,1407285,1407330,1407329,1407286,1407285,1407277,1407276,1407275,1407225,1407224,1407259,1407161,1407160,1407107,1407106,1407079,1407048,1406977,1406976,1406898,1400569,1404000,1404049,1400119,1400117,1400288,1406060,1406891,1400687,1405160,1405145,1405436,1405435,1405434,1405064,1405207,1406398,1407812,1405132,1407856,1405121,1406889,1407278,1407279,1407381,1407380,1407916,1406469,1405870,1407140,1407141,1406385,1406140,1400782,1407392,1407318,1407317,1407404,1407402,1407401,1407387,1404434,1404437,1404440,1404448,1400324,1400708,1404043,1404048,1405953,1400101,1404153,1407440,1407441,1407522,140070801,140070802,140070803},
    Bag = {
        {501001, 501002, 501003}, {1501001174, 1501002174, 1501003174}, {1501001663, 1501002663, 1501003663}, {1501001042, 1501002042, 1501003042}, {1501001022, 1501002022, 1501003022}, {1501001220, 1501002220, 1501003220},
        {1501001051, 1501002051, 1501003051}, {1501001443, 1501002443, 1501003443}, {1501001265, 1501002265, 1501003265},
        {1501001321, 1501002321, 1501003321}, {1501001277, 1501002277, 1501003277}, {1501001550, 1501002550, 1501003550},
        {1501001592, 1501002592, 1501003592}, {1501001608, 1501002608, 1501003608}, {1501001024, 1501002024, 1501003024},
        {1501001019, 1501002019, 1501003019}, {1501001179, 1501002179, 1501003179}, {1501001194, 1501002194, 1501003194},
        {1501001346, 1501002346, 1501003346}, {1501001057, 1501002057, 1501003057}
    },
    Helmet = {
        {502001, 502002, 502003}, {1502001014, 1502002014, 1502003014}, {1502001349, 1502002349, 1502003349},
        {1502001012, 1502002012, 1502003012}, {1502001009, 1502002009, 1502003009}, {1502001397, 1502002397, 1502003397},
        {1502001390, 1502002390, 1502003390}, {1502001381, 1502002381, 1502003381}, {1502001358, 1502002358, 1502003358},
        {1502001350, 1502002350, 1502003350}, {1502001342, 1502002342, 1502003342},
 {1502001058, 1502002058, 1502003058}
    },
    Pet = {50000,50001,50002,50003,50004,50005,50006,50021,50022,50038,50039,50040}
}

_G.skinIdMappings = _G.skinIdMappings or {
    [101004]={101004, 1101004246,1101004226,1101004236,1101004062,1101004078,1101004086,1101004201,1101004218,1101004046},
    [101001]={101001,1101001276,1101001265,1101001213,1101001172,1101001127,1101001230,1101001241,1101001089},                    
    [101003]={101003,1101003227,1103003208,1101003195,1101003187,1101003098,1101003166,1101003218},                                             
    [101008]={101008,1101008146,1101008154,1101008079,1101008126,1101008104,1101008146,1101008061,1101008116},                    
    [101006]={101006,1101006106,1101006085,1101006061,1101006074,1101006043,1101006032,1101006084},
    [101012]={101012,1101012033},
    [101007]={101007,1101007062,1101007071},
    [102002]={102002,1102002136,1102002043,1102002061,1102002424,1102002438},      
    [101101]={101101, 1101101007},
    [101102]={101102, 1101102041},
    [102001]={102001, 1102001120},
    [102003]={102003, 1102003100},
    [101005]={101005, 1101005098},
    [103001]={103001, 1103001202,1103001191},
    [103002]={103002, 1103002106},
    [103003]={103003, 1103003042,1103003062,1103003099},
    [103012]={103012, 1103012039,1103012010},
    [104003]={104003, 1104003037},
    [104004]={104004, 1104004035, 1104004041}
}

_G.VehicleSkins = _G.VehicleSkins or { 
    [1961001] = { 1961007, 1961149, 1961069, 1961013, 1961014, 1961015, 1961016, 1961017, 1961018, 1961020, 1961021, 1961024, 1961025, 1961029, 1961030, 1961031, 1961032, 1961033, 1961034, 1961035, 1961036, 1961037, 1961038, 1961039, 1961040, 1961041, 1961042, 1961043, 1961044, 1961045, 1961046, 1961047, 1961048, 1961049, 1961050, 1961051, 1961052, 1961053, 1961054, 1961055, 1961056, 1961057, 1961058, 1961059, 1961060, 1961061, 1961062, 1961063, 1961064, 1961065, 1961066, 1961067, 1961068,1961136, 1961137, 1961138, 1961139, 1961140, 1961141, 1961142, 1961143, 1961144, 1961145, 1961147, 1961148, 1961010, 1961150, 1961151, 1961152, 1961153 },
    [1903001] = { 1903079, 1903006, 1903007, 1903008, 1903011, 1903012, 1903013, 1903014, 1903015, 1903016, 1903017, 1903018, 1903019, 1903020, 1903021, 1903022, 1903023, 1903024, 1903029, 1903030, 1903031, 1903032, 1903033, 1903034, 1903035, 1903036, 1903037, 1903039, 1903040, 1903041, 1903042, 1903043, 1903044, 1903045, 1903046, 1903051, 1903052, 1903053, 1903054, 1903055, 1903056, 1903057, 1903058, 1903059, 1903060, 1903061, 1903062, 1903063, 1903066, 1903067, 1903068, 1903069, 1903070, 1903071, 1903072, 1903073, 1903074, 1903075, 1903076, 1903079, 1903080, 1903081, 1903082, 1903084, 1903085, 1903086, 1903087, 1903088, 1903089, 1903090, 1903189, 1903190, 1903191, 1903192, 1903193, 1903194, 1903195, 1903196, 1903197, 1903198, 1903199, 1903200, 1903201, 1903202, 1903203, 1903204, 1903205, 1903206, 1903207, 1903208, 1903209, 1903210, 1903211, 1903212, 1903213, 1903214, 1903215, 1903216, 1903217, 1903218, 1903219, 1903220, 1903221, 1903222, 1903223, 1903225, 1903226, 1903227, 1903228 }, 
    [1915001] = { 1915011, 1915003, 1915007, 1915005, 1915006, 1915008, 1915009, 1915010, 1915012, 1915013, 1915014, 1915015, 1915016, 1915017, 1915018, 1915019, 1915020, 1915021, 1915022, 1915023, 1915024, 1915025, 1915026, 1915027, 1915099 },          
    [1908001] = { 1908002, 1908003, 1908094, 1908006, 1908007, 1908008, 1908009, 1908010, 1908011, 1908012, 1908013, 1908015, 1908016, 1908017, 1908018, 1908019, 1908021, 1908023, 1908030, 1908031, 1908032, 1908033, 1908034, 1908035, 1908036, 1908037, 1908039, 1908040, 1908041, 1908043, 1908047, 1908049, 1908050, 1908051, 1908052, 1908053, 1908054, 1908055, 1908056, 1908057, 1908059, 1908060, 1908061, 1908062, 1908063, 1908064, 1908066, 1908067, 1908068, 1908069, 1908070, 1908075, 1908076, 1908077, 1908078, 1908080, 1908081, 1908082, 1908083, 1908084, 1908085, 1908086, 1908087, 1908088, 1908089, 1908091, 1908095, 1908096, 1908097, 1908098, 1908099, 1908100, 1908101, 1908102, 1908104, 1908105, 1908106, 1908107, 1908108, 1908109, 1908110, 1908111, 1908112, 1908188, 1908189 },   
    [1907001] = { 1907007, 1907008, 1907010, 1907066, 1907012, 1907013, 1907014, 1907016, 1907018, 1907019, 1907021, 1907022, 1907023, 1907025, 1907026, 1907027, 1907028, 1907029, 1907030, 1907032, 1907033, 1907034, 1907035, 1907036, 1907037, 1907038, 1907040, 1907041, 1907043, 1907044, 1907045, 1907046, 1907047, 1907048, 1907049, 1907050, 1907051, 1907052, 1907053, 1907054, 1907055, 1907056, 1907058, 1907059, 1907060, 1907061, 1907062, 1907063, 1907064, 1907065, 1907067, 1907068, 1907069, 1907070, 1907071, 1907072, 1907073, 1907074 }
}
_G.CustSlotType = _G.CustSlotType or { ClothesEquipemtSlot=5, BackpackEquipemtSlot=8, HelmetEquipemtSlot=9, ParachuteEquipemtSlot=11, GlideEquipemtSlot=15 }

local function DownloadGameItem(id)
    local puffer_manager = require('client.slua.logic.download.puffer.puffer_manager')
    local puffer_const = require('client.slua.logic.download.puffer_const')
    if puffer_manager and puffer_const and puffer_manager.GetState(puffer_const.ENUM_DownloadType.ODPTD, {id}) ~= puffer_const.ENUM_DownloadState.Done then
        puffer_manager.Download(puffer_const.ENUM_DownloadType.ODPTD, {id})
    end
end
_G.download_item = DownloadGameItem

_G.get_skin_id = function(weaponID)
    if not weaponID then return nil end
    local targetSkinId = _G.WeaponSkinMap and _G.WeaponSkinMap[weaponID]
    if targetSkinId and targetSkinId > 0 then
        if not _G.skinIdCache2[targetSkinId] then
            if _G.download_item then pcall(_G.download_item, targetSkinId) end
            _G.skinIdCache2[targetSkinId] = true
        end
        return targetSkinId
    end
    return weaponID
end

_G.equip_character_avatar = function(Character)
    if not Character or not slua.isValid(Character) or not Character.AvatarComponent2 then return end
    local BackpackUtils = import("BackpackUtils")
    local SlotSyncData = Character.AvatarComponent2.NetAvatarData and Character.AvatarComponent2.NetAvatarData.SlotSyncData
    if not SlotSyncData or not slua.isValid(SlotSyncData) or not BackpackUtils then return end
    
    local function EquipAvatar(ApplyDataIdx, mappedSkin, ApplyEquipSlot, isLevelDependent, levelFunc)
        if not mappedSkin or mappedSkin == 0 then return end
        local slotData = SlotSyncData:Get(ApplyDataIdx)
        if slotData and slotData.SlotID == ApplyEquipSlot then
            local applyItemId = mappedSkin
            if isLevelDependent and type(mappedSkin) == "table" then
                local level = levelFunc(slotData.AdditionalItemID) or 1
                if level < 1 then level = 1 end
                if level > 3 then level = 3 end
                applyItemId = mappedSkin[level] or mappedSkin[1]
            end
            if not applyItemId or applyItemId == 0 or slotData.ItemId == applyItemId then return end
            if not _G.skinIdCache[applyItemId] then
                if _G.download_item then pcall(_G.download_item, applyItemId) end
                _G.skinIdCache[applyItemId] = true
            end
            slotData.ItemId = applyItemId
            SlotSyncData:Set(ApplyDataIdx, slotData)
            Character.AvatarComponent2:OnRep_BodySlotStateChanged()
        end
    end

    local hasGliderSlot = false
    for i = 0, SlotSyncData:Num() - 1 do
        local slotData = SlotSyncData:Get(i)
        if slotData and slotData.SlotID == _G.CustSlotType.GlideEquipemtSlot then 
            hasGliderSlot = true
            break 
        end
    end
    if not hasGliderSlot then SlotSyncData:Add({ SlotID = _G.CustSlotType.GlideEquipemtSlot, ItemId = 0 }) end

    for i = 0, SlotSyncData:Num() - 1 do
        EquipAvatar(i, _G.OutfitMap.Suit or 0, _G.CustSlotType.ClothesEquipemtSlot, false)
        EquipAvatar(i, _G.OutfitMap.Bag, _G.CustSlotType.BackpackEquipemtSlot, true, BackpackUtils.GetEquipmentBagLevel)
        EquipAvatar(i, _G.OutfitMap.Helmet, _G.CustSlotType.HelmetEquipemtSlot, true, BackpackUtils.GetEquipmentHelmetLevel)
        EquipAvatar(i, _G.OutfitMap.Parachute or 0, _G.CustSlotType.ParachuteEquipemtSlot, false)
    end
end

_G.ApplyWeaponSkins = function(PlayerCharacter)
    pcall(function()
        local WeaponManager = PlayerCharacter:GetWeaponManager()
        if not slua.isValid(WeaponManager) then return end
        
        for slot = 1, 3 do
            local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
            if slua.isValid(Weapon) and slua.isValid(Weapon.synData) then
                local WeaponID = Weapon:GetWeaponID()
                local SkinID = _G.get_skin_id(WeaponID) or WeaponID
                local isModified = false
                
                local SkinData = Weapon.synData:Get(7) 
                if SkinData and SkinData.defineID and SkinData.defineID.TypeSpecificID ~= SkinID then
                    SkinData.defineID.TypeSpecificID = SkinID
                    Weapon.synData:Set(7, SkinData)
                    if Weapon.SetWeaponAvatarID then pcall(function() Weapon:SetWeaponAvatarID(SkinID) end) end
                    if not _G.skinIdCache[SkinID] then 
                        _G.download_item(SkinID)
                        _G.skinIdCache[SkinID] = true 
                    end
                    isModified = true
                end
                
                if SkinID >= 10000000 and _G.VIP_Attachments and _G.VIP_Attachments[SkinID] then
                    for AttachIdx = 0, 5 do 
                        local attachData = Weapon.synData:Get(AttachIdx)
                        if attachData then
                            local defineIDRef = slua.IndexReference(attachData, "defineID")
                            if defineIDRef then
                                local attachmentId = defineIDRef.TypeSpecificID
                                if attachmentId and attachmentId > 0 then
                                    local mapIndex = _G.BaseAttachToIndex[attachmentId] or _G.VipAttachToIndex[attachmentId]
                                    if mapIndex and _G.VIP_Attachments[SkinID][mapIndex] and _G.VIP_Attachments[SkinID][mapIndex] > 0 then
                                        local targetAttachId = _G.VIP_Attachments[SkinID][mapIndex]
                                        if targetAttachId ~= attachmentId then
                                            attachData.defineID.TypeSpecificID = targetAttachId
                                            Weapon.synData:Set(AttachIdx, attachData)
                                            if not _G.skinIdCache2[targetAttachId] then 
                                                if _G.download_item then pcall(_G.download_item, targetAttachId) end
                                                _G.skinIdCache2[targetAttachId] = true 
                                            end
                                            isModified = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                if isModified then
                    if Weapon.DelayHandleAvatarMeshChanged then pcall(function() Weapon:DelayHandleAvatarMeshChanged() end) end
                    if Weapon.OnRep_synData then pcall(function() Weapon:OnRep_synData() end) end
                end
            end
        end
    end)
end

_G.ApplyVehicleSkins = function(PlayerCharacter)
    pcall(function()
        local Vehicle = PlayerCharacter:GetCurrentVehicle()
        if not slua.isValid(Vehicle) then 
            _G.LastVehicleEntity = nil
            return 
        end
        
        if _G.LastVehicleEntity == Vehicle and _G.CurrentEquipVehicleID ~= nil then
            return
        end

        local VehicleAvatar = Vehicle.VehicleAvatar or Vehicle.VehicleAvatarComponent_BP or Vehicle:GetAvatarComponent()
        if not slua.isValid(VehicleAvatar) then return end

        local defId = tostring(VehicleAvatar:GetDefaultAvatarID() or Vehicle.VehicleID or "")
        local currentId = tostring(Vehicle:GetAvatarId() or "")
        local applySkinId = 0
        
        for baseMapId, targetSkin in pairs(_G.VehicleSkinMap) do
            if defId:find(tostring(baseMapId)) or currentId:find(tostring(baseMapId)) then 
                applySkinId = targetSkin
                break 
            end
        end

        if applySkinId and applySkinId > 0 then
            _G.skinIdCache = _G.skinIdCache or {}
            if not _G.skinIdCache[applySkinId] then 
                if _G.download_item then pcall(_G.download_item, applySkinId) end
                _G.skinIdCache[applySkinId] = true 
            end

            VehicleAvatar.curSwitchEffectId = 7303001
            if VehicleAvatar.ChangeItemAvatar then VehicleAvatar:ChangeItemAvatar(applySkinId, true) end
            
            _G.CurrentEquipVehicleID = applySkinId
            _G.LastVehicleEntity = Vehicle
        end
    end)
end

_G.HandlePetLogic = function()
    pcall(function()
        local petSkin = _G.OutfitMap.Pet
        if not petSkin or petSkin == 0 or petSkin == 50000 or petSkin == _G.LastAppliedPet then return end
        
        _G.skinIdCache = _G.skinIdCache or {}
        if not _G.skinIdCache[petSkin] then 
            if _G.download_item then pcall(_G.download_item, petSkin) end
            _G.skinIdCache[petSkin] = true 
        end
        
        local ModuleManager = require("client.module_framework.ModuleManager")
        if ModuleManager then
            local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
            if logic_pet then
                if logic_pet.SetCurPetID then logic_pet:SetCurPetID(petSkin) end
                if logic_pet.EquipPet then logic_pet:EquipPet(petSkin) end
            end
        end
        _G.LastAppliedPet = petSkin
    end)
end

_G.ForceRefreshSkinMaps = function()
    pcall(function()
        if not _G.PGState or not _G.PGState.CustomTextData then return end
        local cData = _G.PGState.CustomTextData

        if _G.OutfitSkins then
            if cData.SkinSuit and _G.OutfitSkins.Suit[cData.SkinSuit] then _G.OutfitMap.Suit = _G.OutfitSkins.Suit[cData.SkinSuit] end
            if cData.SkinBag and _G.OutfitSkins.Bag[cData.SkinBag] then _G.OutfitMap.Bag = _G.OutfitSkins.Bag[cData.SkinBag] end
            if cData.SkinHelmet and _G.OutfitSkins.Helmet[cData.SkinHelmet] then _G.OutfitMap.Helmet = _G.OutfitSkins.Helmet[cData.SkinHelmet] end
        end

        if _G.skinIdMappings then
            if cData.SkinM416 and _G.skinIdMappings[101004] and _G.skinIdMappings[101004][cData.SkinM416] then _G.WeaponSkinMap[101004] = _G.skinIdMappings[101004][cData.SkinM416] end
            if cData.SkinAKM and _G.skinIdMappings[101001] and _G.skinIdMappings[101001][cData.SkinAKM] then _G.WeaponSkinMap[101001] = _G.skinIdMappings[101001][cData.SkinAKM] end
            if cData.SkinSCAR and _G.skinIdMappings[101003] and _G.skinIdMappings[101003][cData.SkinSCAR] then _G.WeaponSkinMap[101003] = _G.skinIdMappings[101003][cData.SkinSCAR] end
            if cData.SkinM762 and _G.skinIdMappings[101008] and _G.skinIdMappings[101008][cData.SkinM762] then _G.WeaponSkinMap[101008] = _G.skinIdMappings[101008][cData.SkinM762] end
            if cData.SkinAUG and _G.skinIdMappings[101006] and _G.skinIdMappings[101006][cData.SkinAUG] then _G.WeaponSkinMap[101006] = _G.skinIdMappings[101006][cData.SkinAUG] end
            if cData.SkinHoney and _G.skinIdMappings[101012] and _G.skinIdMappings[101012][cData.SkinHoney] then _G.WeaponSkinMap[101012] = _G.skinIdMappings[101012][cData.SkinHoney] end
            if cData.SkinQBZ and _G.skinIdMappings[101007] and _G.skinIdMappings[101007][cData.SkinQBZ] then _G.WeaponSkinMap[101007] = _G.skinIdMappings[101007][cData.SkinQBZ] end
            if cData.SkinASM and _G.skinIdMappings[101101] and _G.skinIdMappings[101101][cData.SkinASM] then _G.WeaponSkinMap[101101] = _G.skinIdMappings[101101][cData.SkinASM] end
            if cData.SkinACE32 and _G.skinIdMappings[101102] and _G.skinIdMappings[101102][cData.SkinACE32] then _G.WeaponSkinMap[101102] = _G.skinIdMappings[101102][cData.SkinACE32] end
            if cData.SkinUMP and _G.skinIdMappings[102002] and _G.skinIdMappings[102002][cData.SkinUMP] then _G.WeaponSkinMap[102002] = _G.skinIdMappings[102002][cData.SkinUMP] end
            if cData.SkinUZI and _G.skinIdMappings[102001] and _G.skinIdMappings[102001][cData.SkinUZI] then _G.WeaponSkinMap[102001] = _G.skinIdMappings[102001][cData.SkinUZI] end
            if cData.SkinVector and _G.skinIdMappings[102003] and _G.skinIdMappings[102003][cData.SkinVector] then _G.WeaponSkinMap[102003] = _G.skinIdMappings[102003][cData.SkinVector] end
            if cData.SkinGroza and _G.skinIdMappings[101005] and _G.skinIdMappings[101005][cData.SkinGroza] then _G.WeaponSkinMap[101005] = _G.skinIdMappings[101005][cData.SkinGroza] end
            if cData.SkinKar98K and _G.skinIdMappings[103001] and _G.skinIdMappings[103001][cData.SkinKar98K] then _G.WeaponSkinMap[103001] = _G.skinIdMappings[103001][cData.SkinKar98K] end
            if cData.SkinM24 and _G.skinIdMappings[103002] and _G.skinIdMappings[103002][cData.SkinM24] then _G.WeaponSkinMap[103002] = _G.skinIdMappings[103002][cData.SkinM24] end
            if cData.SkinAWM and _G.skinIdMappings[103003] and _G.skinIdMappings[103003][cData.SkinAWM] then _G.WeaponSkinMap[103003] = _G.skinIdMappings[103003][cData.SkinAWM] end
            if cData.SkinAMR and _G.skinIdMappings[103012] and _G.skinIdMappings[103012][cData.SkinAMR] then _G.WeaponSkinMap[103012] = _G.skinIdMappings[103012][cData.SkinAMR] end
            if cData.SkinS12K and _G.skinIdMappings[104003] and _G.skinIdMappings[104003][cData.SkinS12K] then _G.WeaponSkinMap[104003] = _G.skinIdMappings[104003][cData.SkinS12K] end
            if cData.SkinDBS and _G.skinIdMappings[104004] and _G.skinIdMappings[104004][cData.SkinDBS] then _G.WeaponSkinMap[104004] = _G.skinIdMappings[104004][cData.SkinDBS] end
        end

        if _G.VehicleSkins then
            if cData.SkinDacia and _G.VehicleSkins[1903001] and _G.VehicleSkins[1903001][cData.SkinDacia] then _G.VehicleSkinMap[1903001] = _G.VehicleSkins[1903001][cData.SkinDacia] end
            if cData.SkinUAZ and _G.VehicleSkins[1908001] and _G.VehicleSkins[1908001][cData.SkinUAZ] then _G.VehicleSkinMap[1908001] = _G.VehicleSkins[1908001][cData.SkinUAZ] end
            if cData.SkinCoupe and _G.VehicleSkins[1961001] and _G.VehicleSkins[1961001][cData.SkinCoupe] then _G.VehicleSkinMap[1961001] = _G.VehicleSkins[1961001][cData.SkinCoupe] end
            if cData.SkinBuggy and _G.VehicleSkins[1907001] and _G.VehicleSkins[1907001][cData.SkinBuggy] then _G.VehicleSkinMap[1907001] = _G.VehicleSkins[1907001][cData.SkinBuggy] end
            if cData.SkinMirado and _G.VehicleSkins[1915001] and _G.VehicleSkins[1915001][cData.SkinMirado] then _G.VehicleSkinMap[1915001] = _G.VehicleSkins[1915001][cData.SkinMirado] end
        end
    end)
end

_G.InitializeSkinModSystem = function()
    pcall(function()
        local LobbyAvatar = package.loaded["client.logic.avatar.LobbyAvatar"] or require("client.logic.avatar.LobbyAvatar")
        if LobbyAvatar and not _G.LobbyBypassHacked then
            local originalPutonEquipment = LobbyAvatar.PutonEquipment
            LobbyAvatar.PutonEquipment = function(self, itemID, tAvatarCustom, tExtraData)
                local attachIndex = _G.BaseAttachToIndex and _G.BaseAttachToIndex[itemID]
                if attachIndex then
                    local holdingWeaponSkinID = self.GetCurHoldingWeaponSkinID and self:GetCurHoldingWeaponSkinID()
                    if holdingWeaponSkinID and holdingWeaponSkinID >= 10000000 and _G.VIP_Attachments and _G.VIP_Attachments[holdingWeaponSkinID] then
                        local vipAttachID = _G.VIP_Attachments[holdingWeaponSkinID][attachIndex]
                        if vipAttachID and vipAttachID > 0 then
                            if self.HandleDownload then self:HandleDownload(vipAttachID, nil, nil, false) end
                            itemID = vipAttachID
                        end
                    end
                end
                if originalPutonEquipment then return originalPutonEquipment(self, itemID, tAvatarCustom, tExtraData) end
            end

            local originalCharEquipWeaponByResId = LobbyAvatar.CharEquipWeaponByResId
            LobbyAvatar.CharEquipWeaponByResId = function(self, resID, isUse, isAsync, SocketName)
                local retValue = originalCharEquipWeaponByResId and originalCharEquipWeaponByResId(self, resID, isUse, isAsync, SocketName) or nil
                if isUse and self.GetEquipments then
                    local equipments = self:GetEquipments()
                    for _, equip in ipairs(equipments) do
                        if _G.BaseAttachToIndex and _G.BaseAttachToIndex[equip.itemID] then
                            self:PutonEquipment(equip.itemID, equip.CustomInfo, {bIsUse = false})
                        end
                    end
                end
                return retValue
            end
            _G.LobbyBypassHacked = true
        end
    end)
    
    pcall(function()
        local Common_Items_UIBP = package.loaded["client.slua.component.item.ItemChildren.Common_Items_UIBP"] or require("client.slua.component.item.ItemChildren.Common_Items_UIBP")
        if Common_Items_UIBP and not _G.IconBaloHacked then
        local originalInitView = Common_Items_UIBP.InitView
            Common_Items_UIBP.InitView = function(self, nItemId, nCount, nValidTime, tExtraData)
                tExtraData = tExtraData or {}
                local displayResId = nil
                
                if _G.get_skin_id then
                    local skinID = _G.get_skin_id(nItemId)
                    if skinID and skinID ~= nItemId then displayResId = skinID end
                end
                
                local attachIndex = _G.BaseAttachToIndex and _G.BaseAttachToIndex[nItemId]
                if not displayResId and attachIndex then
                    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
                    local LocalPlayer = GameplayData and GameplayData.GetPlayerCharacter()
                    if slua.isValid(LocalPlayer) then
                        local currentWeapon = LocalPlayer:GetCurrentWeapon()
                        if slua.isValid(currentWeapon) then
                            local weaponID = currentWeapon:GetWeaponID()
                            local finalSkinID = _G.get_skin_id(weaponID) or weaponID
                            if finalSkinID >= 10000000 and _G.VIP_Attachments and _G.VIP_Attachments[finalSkinID] then
                                local vipAttachID = _G.VIP_Attachments[finalSkinID][attachIndex]
                                if vipAttachID and vipAttachID > 0 then displayResId = vipAttachID end
                            end
                        end
                    end
                end
                
                if displayResId then
                    tExtraData.displayResId = displayResId
                    if not _G.skinIdCache2[displayResId] then
                        if _G.download_item then pcall(_G.download_item, displayResId) end
                        _G.skinIdCache2[displayResId] = true
                    end
                end
                if originalInitView then return originalInitView(self, nItemId, nCount, nValidTime, tExtraData) end
            end
            _G.IconBaloHacked = true
        end
    end)
end

-- ========================================== 
-- KILL COUNTER & KILL MESSAGE EFFECT + DEADBOX SKIN
-- ==========================================
_G.TDFTDeKillCounts = _G.TDFTDeKillCounts or {}
local CACHED_LinearColor = import("LinearColor")
local CACHED_GoldColor = CACHED_LinearColor and CACHED_LinearColor(1.0, 0.8, 0.0, 1.0) or nil
local CACHED_UI_Manager = nil
_G.NeedCheckDeadBoxTimer = 0
_G.LastCheckDeadBoxTime = 0

_G.ForceEnableKillCounterUI = function()
    pcall(function()
        local KillCounterUISubsystem = package.loaded["GameLua.Mod.BaseMod.Client.KillCounter.KillCounterUISubsystem"] or require("GameLua.Mod.BaseMod.Client.KillCounter.KillCounterUISubsystem")
        if KillCounterUISubsystem and KillCounterUISubsystem.__inner_impl and not _G.KCUISystemHacked2 then
            local kcImpl = KillCounterUISubsystem.__inner_impl
            kcImpl.CheckSupportKCUI = function() return true end
            kcImpl.CheckNeedMainKillCounterUI = function(self, PlayerWeapon, PlayerID)
                if slua.isValid(PlayerWeapon) then
                    local WeaponID = PlayerWeapon:GetWeaponID()
                    self:UpdateMainKillCounterUI(true, WeaponID, _G.get_skin_id(WeaponID) or WeaponID)
                else self:UpdateMainKillCounterUI(false) end
            end
            local originalUpdateMainKillCounterUI = kcImpl.UpdateMainKillCounterUI
            kcImpl.UpdateMainKillCounterUI = function(self, bShow, WeaponID, AvatarID)
                if bShow then AvatarID = _G.get_skin_id(WeaponID) or AvatarID end
                if originalUpdateMainKillCounterUI then originalUpdateMainKillCounterUI(self, bShow, WeaponID, AvatarID) end
            end
            _G.KCUISystemHacked2 = true
        end

        local ModuleManager = require("client.module_framework.ModuleManager")
        if ModuleManager and not _G.KCLogicHacked2 then
            local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
            if LogicKillCounter then
                LogicKillCounter.CheckSupportKC = function() return true end
                LogicKillCounter.CheckSupportKillCounterAvatar = function() return true end
                LogicKillCounter.CheckHasWeaponKillCounter = function() return true end
                LogicKillCounter.GetBaseKillCounterIdByWeaponId = function() return 2100004 end
                LogicKillCounter.GetEquipedKillCounterId = function() return 2100004 end
                LogicKillCounter.GetMyEquipedKillCounterId = function() return 2100004 end
                LogicKillCounter.GetOneWeaponKillCountInBattle = function(self, uid, weaponId) return _G.TDFTDeKillCounts[weaponId] or 0 end
                LogicKillCounter.GetWeaponKillCountByUid = function(self, uid, weaponId) return _G.TDFTDeKillCounts[weaponId] or 0 end
                _G.KCLogicHacked2 = true
            end
        end

        local killInfoPath = "GameLua.Mod.BaseMod.Client.KillInfoTips.KillInfo"
        local KillInfo = package.loaded[killInfoPath] or require(killInfoPath)
        
        if KillInfo and KillInfo.__inner_impl and not _G.KillInfoCounterHacked then
            local originalFileItem = KillInfo.__inner_impl.FileItem
            KillInfo.__inner_impl.FileItem = function(self, DamageRecordData)
                pcall(function()
                    local LocalPlayer = require("GameLua.GameCore.Data.GameplayData").GetPlayerCharacter()
                    if slua.isValid(LocalPlayer) and DamageRecordData.Causer == LocalPlayer:GetPlayerNameSafety() then 
                        local currentWeapon = LocalPlayer:GetCurrentWeapon()
                        if slua.isValid(currentWeapon) then
                            local weaponID = currentWeapon:GetWeaponID()
                            local skinID = _G.get_skin_id(weaponID)
                            if skinID then DamageRecordData.CauserWeaponAvatarID = skinID end
                            -- SUIT skin (full outfit) for kill broadcast
                            if _G.OutfitMap.Suit and _G.OutfitMap.Suit ~= 0 then
                                DamageRecordData.CauserClothAvatarID = _G.OutfitMap.Suit
                            end
                            if CACHED_GoldColor then
                                DamageRecordData.IsUseColor, DamageRecordData.UseColor = true, CACHED_GoldColor
                            end
                            
                            if DamageRecordData.ResultHealthStatus == 2 then
                                _G.TDFTDeKillCounts[weaponID] = (_G.TDFTDeKillCounts[weaponID] or 0) + 1
                                _G.NeedCheckDeadBoxTimer = 50 
                                
                                if not CACHED_UI_Manager then CACHED_UI_Manager = require("client.slua_ui_framework.manager") end
                                local uiMainKillCounter = CACHED_UI_Manager.GetUI(CACHED_UI_Manager.UI_Config_InGame.MainKillCounter)
                                
                                if uiMainKillCounter and uiMainKillCounter.UpdateWeaponID then
                                    local mainAvatarID = skinID or currentWeapon:GetWeaponMainAvatarID()
                                    uiMainKillCounter:UpdateWeaponID(weaponID, mainAvatarID)
                                    local kcModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
                                    local kcItemID = kcModule:GetEquipedKillCounterId(0, mainAvatarID)
                                    uiMainKillCounter:SetKillCounterItemShowWithNum(kcItemID, _G.TDFTDeKillCounts[weaponID], mainAvatarID)
                                end
                            end
                        end
                    end
                end)
                if originalFileItem then return originalFileItem(self, DamageRecordData) end
            end
            _G.KillInfoCounterHacked = true
        end

        -- ==========================================
        -- ELIMINATION TEAM BROADCAST (real hook)
        -- ==========================================
        if not _G.KillBroadcastHacked then
            pcall(function()
                local BattleKillBroadcastSubSystem = require("GameLua.Mod.BaseMod.Client.BattleKillBroadcast.BattleKillBroadcastSubSystem")
                if BattleKillBroadcastSubSystem then
                    local O_Copy = BattleKillBroadcastSubSystem.CopyKillOrPutDownMessageDataUserDataToLuaTable
                    BattleKillBroadcastSubSystem.CopyKillOrPutDownMessageDataUserDataToLuaTable = function(self, messageData)
                        local msgData = O_Copy(self, messageData)
                        if msgData and msgData.bIamCauser then
                            local uCharacter = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController() and slua_GameFrontendHUD:GetPlayerController():GetPlayerCharacterSafety()
                            if uCharacter and slua.isValid(uCharacter) then
                                if msgData.DamageType == UEnums.DamageType.VehicleDamage then
                                    local carSkinID = _G.CurrentEquipVehicleID
                                    if carSkinID and carSkinID ~= 0 then
                                        local ExpandData = slua.LuaArchiverDecode(LuaStateWrapper, msgData.ExpandDataContent) or {}
                                        ExpandData.CauserVehicleSkinID = carSkinID
                                        ExpandData.CauserWeaponAvatarID = carSkinID
                                        msgData.ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, ExpandData)
                                    end
                                else
                                    local currWeapon = uCharacter:GetCurrentWeapon()
                                    if currWeapon and slua.isValid(currWeapon) then
                                        local synData = currWeapon.synData
                                        if synData and slua.isValid(synData) then
                                            local weaponDefineID = slua.IndexReference(synData:Get(7), "defineID")
                                            if weaponDefineID and slua.isValid(weaponDefineID) then
                                                local ExpandData = slua.LuaArchiverDecode(LuaStateWrapper, msgData.ExpandDataContent) or {}
                                                ExpandData.CauserWeaponAvatarID = weaponDefineID.TypeSpecificID
                                                msgData.ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, ExpandData)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        return msgData
                    end
                    _G.KillBroadcastHacked = true
                end
            end)
        end

        local SwitchWeaponSlotMode2 = package.loaded["GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponSlotMode2"] or require("GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponSlotMode2")
        if SwitchWeaponSlotMode2 and SwitchWeaponSlotMode2.__inner_impl and not _G.SlotBaseHacked then
            SwitchWeaponSlotMode2.__inner_impl.CheckShowKCIcon = function(self)
                if slua.isValid(self.KillCounterImg) then 
                    self.KillCounterImg:SetVisibility(import("ESlateVisibility").SelfHitTestInvisible) 
                end
            end
            _G.SlotBaseHacked = true
        end
    end)
end

-- ========================================== 
-- DEADBOX SKIN (temper request)
-- ==========================================
local cached_GameplayStatics = nil
local cached_PlayerTombBox = nil
local cached_ActorClass = nil
_G.DeadBox_TemperRequest = function(PlayerController)
    if _G.NeedCheckDeadBoxTimer <= 0 then return end
    
    local curTime = os.clock()
    if _G.LastCheckDeadBoxTime and (curTime - _G.LastCheckDeadBoxTime) < 2.0 then return end
    _G.LastCheckDeadBoxTime = curTime
    
    _G.NeedCheckDeadBoxTimer = _G.NeedCheckDeadBoxTimer - 1

    local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
    if not slua.isValid(PlayerCharacter) then return end
    
    if not cached_GameplayStatics then
        cached_GameplayStatics = import("GameplayStatics")
        cached_ActorClass = import("Actor")
        cached_PlayerTombBox = import("PlayerTombBox")
    end
    
    if not _G.CachedActorArray then
        _G.CachedActorArray = slua.Array(UEnums.EPropertyClass.Object, cached_ActorClass)
    end
    
    local UI_Util = require("client.common.ui_util")
    local GameInstance = UI_Util and UI_Util.GetGameInstance()
    if not GameInstance or not cached_GameplayStatics then return end

    local deadBoxes = cached_GameplayStatics.GetAllActorsOfClass(GameInstance, cached_PlayerTombBox, _G.CachedActorArray)
    
    for _, deadBoxActor in pairs(deadBoxes) do
        if slua.isValid(deadBoxActor) and not deadBoxActor.bIsTDSkinApplied then
            local damageCauser = deadBoxActor.DamageCauser
            if damageCauser and damageCauser.PlayerKey == PlayerController.PlayerKey then
                local DeadBoxAvatarComponent = deadBoxActor.DeadBoxAvatarComponent_BP
                if slua.isValid(DeadBoxAvatarComponent) then
                    local currentBoxSkinId = 0
                    if PlayerCharacter.CurrentVehicle and _G.CurrentEquipVehicleID and _G.CurrentEquipVehicleID ~= 0 then
                        currentBoxSkinId = tonumber(tostring(_G.CurrentEquipVehicleID) .. "1") or 0
                    else
                        local currentWeapon = PlayerCharacter:GetCurrentWeapon()
                        if slua.isValid(currentWeapon) and currentWeapon.synData then
                            local weaponSkinData = currentWeapon.synData:Get(7)
                            if weaponSkinData and weaponSkinData.defineID then
                                currentBoxSkinId = weaponSkinData.defineID.TypeSpecificID
                            end
                        end
                    end
                    
                    if currentBoxSkinId ~= 0 then
                        pcall(function()
                            DeadBoxAvatarComponent:ResetItemAvatar()
                            DeadBoxAvatarComponent:PreChangeItemAvatar(currentBoxSkinId)
                            DeadBoxAvatarComponent:SyncChangeItemAvatar(currentBoxSkinId)
                        end)
                    end
                    deadBoxActor.bIsTDSkinApplied = true
                end
            end
        end
    end
end

-- ========================================== 
-- VIP NATIVE MENU SYSTEM (RUNS DIRECTLY FROM GAME SETTINGS)
-- ========================================== 

function _G.InitModMenuTab()
    if _G.ModMenuInitialized then return end
    _G.ModMenuInitialized = true

    _G.PGState.CustomTextData = _G.PGState.CustomTextData or {
        OuterSpeed = 5.6, InnerSpeed = 5.6, OuterRecoil = 0, HRecoil = 0.3, VRecoil = 0.3, IpadViewFOV = 120,
        -- Skin
        SkinSuit = 0, SkinBag = 0, SkinHelmet = 0,
        SkinM416 = 0, SkinAKM = 0, SkinSCAR = 0, SkinM762 = 0, SkinAUG = 0, SkinHoney =0, SkinQBZ = 0, SkinASM = 2, SkinACE32 = 0, SkinUMP = 6,
        SkinUZI = 0, SkinVector = 0, SkinGroza = 0, SkinKar98K = 0, SkinAWM = 2, SkinAMR = 0, SkinS12K = 0, SkinDBS = 0,
        SkinDacia = 0, SkinUAZ = 0, SkinCoupe = 0, SkinBuggy = 0, SkinMirado = 0,
    }

    local LocUtil = _G.LocUtil
    if not LocUtil and package.loaded["client.common.LocUtil"] then
        LocUtil = require("client.common.LocUtil")
    end
    
    if LocUtil and not LocUtil._IsModMenuHooked then
        local old_get = LocUtil.GetLocalizeResStr
        LocUtil.GetLocalizeResStr = function(id)
            if type(id) == "string" and not tonumber(id) then
                return id
            end
            return old_get(id)
        end
        LocUtil._IsModMenuHooked = true
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    
    if not SettingPageDefine.ModMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
        
        -- ==================== ESP VISUAL ====================
        local StackESPVisual = {
            { Key = "ModMenu_ESP1", UI = AliasMap.Switcher, Text = "ESP (AUTO SETUP)", GetFunc = function() return _G.PGConfig.EspVip end, SetFunc = function(c,v) _G.PGConfig.EspVip = v return true end },
            { Key = "ModMenu_ESP7", UI = AliasMap.Switcher, Text = "ESP WARNING & COUNT", GetFunc = function() return _G.PGConfig.Esp7 end, SetFunc = function(c,v) _G.PGConfig.Esp7 = v return true end },
            { Key = "ModMenu_ESP2", UI = AliasMap.Switcher, Text = "ESP RANGE", GetFunc = function() return _G.PGConfig.EspDistance end, SetFunc = function(c,v) _G.PGConfig.EspDistance = v return true end },
            { Key = "ModMenu_ESP4", UI = AliasMap.Switcher, Text = "ESP MARK - 360 Radar", GetFunc = function() return _G.PGConfig.EspRadar end, SetFunc = function(c,v) _G.PGConfig.EspRadar = v return true end },
            { Key = "ModMenu_ESP5", UI = AliasMap.Switcher, Text = "ESP BOX FRAME", GetFunc = function() return _G.PGConfig.Esp5 end, SetFunc = function(c,v) _G.PGConfig.Esp5 = v return true end },
            { Key = "ModMenu_ESPAntenna", UI = AliasMap.Switcher, Text = "ESP LINE ANTENA", GetFunc = function() return _G.PGConfig.EspAntenna end, SetFunc = function(c,v) _G.PGConfig.EspAntenna = v return true end },
            { Key = "ModMenu_ESPName", UI = AliasMap.Switcher, Text = "ESP NAME TEST(VISIBLE)", GetFunc = function() return _G.PGConfig.EspName end, SetFunc = function(c,v) _G.PGConfig.EspName = v return true end },
            { Key = "ModMenu_ESPOutline_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ ESP OUTLINE", ExpandIndex = 0, GetFunc = function() return _G.PGConfig.EspOutline end, SetFunc = function(c,v) _G.PGConfig.EspOutline = v return true end },
            { Key = "ModMenu_ESPOutline_Thickness", UI = AliasMap.Slider, Text = "   Outline Thickness (1% is perfect)", ExpandHandle = "ModMenu_ESPOutline_Ex", MinValue = 1, MaxValue = 20, min = 1, max = 20, GetFunc = function() return _G.PGConfig.OutlineThickness end, SetFunc = function(c,v) _G.PGConfig.OutlineThickness = v return true end }
        }

        -- ==================== AIMBOT ORIGINAL (Legacy, tanpa GodMode) ====================
        local StackAimbotOriginal = {
        }

        -- ==================== AIMBOT FORCE - CLEAN 4 BUTTON LAYOUT ====================
        -- 4 flat buttons jaise ESP: Aimbot / Ignore Knocked / Ignore Bots / Visibility Check
        -- Ek hi setting saari guns pe kaam karti hai (Hipfire + Scope + Shotgun + Sniper)
        local StackAimbotForce = {
            { Key = "ModMenu_AT_Enable", UI = AliasMap.Switcher, Text = "Aimbot", GetFunc = function() return _G.PGConfig.AimTouchEnable end, SetFunc = function(c,v) _G.PGConfig.AimTouchEnable = v return true end },
            { Key = "ModMenu_AT_IgKnock", UI = AliasMap.Switcher, Text = "Ignore Knocked", GetFunc = function() return _G.PGConfig.AimTouchIgKnock end, SetFunc = function(c,v) _G.PGConfig.AimTouchIgKnock = v return true end },
            { Key = "ModMenu_AT_IgBot", UI = AliasMap.Switcher, Text = "Ignore Bots", GetFunc = function() return _G.PGConfig.AimTouchIgBot end, SetFunc = function(c,v) _G.PGConfig.AimTouchIgBot = v return true end },
            { Key = "ModMenu_AT_Vis", UI = AliasMap.Switcher, Text = "Visibility Check", GetFunc = function() return _G.PGConfig.AimTouchVisCheck end, SetFunc = function(c,v) _G.PGConfig.AimTouchVisCheck = v return true end }
        }

        -- ==================== MAGIC BULLET - REMOVED ====================
        -- Magic Bullet system has been completely removed from this version
        local StackMagicBullet = {}

        -- ==================== COMBAT GRAPHIC (hanya God Mode dan graphics) ====================
        local StackCombatGraphic = {
            { Key = "ModMenu_Ipad_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ iPad View (Tampilan iPad)", ExpandIndex = 0, GetFunc = function() return _G.PGConfig.IpadView end, SetFunc = function(c,v) _G.PGConfig.IpadView = v return true end },
            { Key = "ModMenu_Ipad_FOV", UI = AliasMap.Slider, Text = "   FOV Angle (Sudut Pandang)", ExpandHandle = "ModMenu_Ipad_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return (_G.PGState.CustomTextData.IpadViewFOV or 120) - 80 end, SetFunc = function(c,v) _G.PGState.CustomTextData.IpadViewFOV = 80 + v return true end },
            { Key = "ModMenu_165FPS", UI = AliasMap.Switcher, Text = "Unlock 165 FPS (If turning off, will take effect next match)", GetFunc = function() return _G.PGConfig.UnlockFPS end, SetFunc = function(c,v) _G.PGConfig.UnlockFPS = v; if v then _G.PGState.GraphicsUnlocked = false end return true end },
            { Key = "ModMenu_WallColor", UI = AliasMap.Switcher, Text = "Wallhack & Color (Green & Red)", GetFunc = function() return _G.PGConfig.wallhackng end, SetFunc = function(c,v) _G.PGConfig.wallhackng = v; _G.PGConfig.ColorBodyV2 = v return true end },
            { Key = "ModMenu_BlackSky", UI = AliasMap.Switcher, Text = "Black Sky (NIGGA SKY)", GetFunc = function() return _G.PGConfig.BlackSky end, SetFunc = function(c,v) _G.PGConfig.BlackSky = v return true end },
            { Key = "ModMenu_RemoveFog", UI = AliasMap.Switcher, Text = "Remove Fog (Hilangkan Kabut - If turning off, will take effect next match)", GetFunc = function() return _G.PGConfig.RemoveFog end, SetFunc = function(c,v) _G.PGConfig.RemoveFog = v return true end },
        }

        -- ==================== SKIN MOD (BARU) ====================
        local StackSkinMod = {
            { Key = "ModMenu_Skin_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ SKIN MOD MENU", ExpandIndex = 0, GetFunc = function() return _G.PGConfig.ModSkin end, SetFunc = function(c,v) _G.PGConfig.ModSkin = v return true end },
            { Key = "ModMenu_Skin_Suit", UI = AliasMap.Slider, Text = "   Outfit (1 to 87 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 80, GetFunc = function() return _G.PGState.CustomTextData.SkinSuit or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinSuit = v; if _G.OutfitSkins and _G.OutfitSkins.Suit[v] then _G.OutfitMap.Suit = _G.OutfitSkins.Suit[v] end return true end },
            { Key = "ModMenu_Skin_Bag", UI = AliasMap.Slider, Text = "   Bag (Backpack)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 16, GetFunc = function() return _G.PGState.CustomTextData.SkinBag or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinBag = v; if _G.OutfitSkins and _G.OutfitSkins.Bag[v] then _G.OutfitMap.Bag = _G.OutfitSkins.Bag[v] end return true end },
            { Key = "ModMenu_Skin_Helmet", UI = AliasMap.Slider, Text = "   Helmet", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 12, GetFunc = function() return _G.PGState.CustomTextData.SkinHelmet or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinHelmet = v; if _G.OutfitSkins and _G.OutfitSkins.Helmet[v] then _G.OutfitMap.Helmet = _G.OutfitSkins.Helmet[v] end return true end },
            { Key = "ModMenu_Skin_M416", UI = AliasMap.Slider, Text = "   M416 Skin (1 to 10 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 9, GetFunc = function() return _G.PGState.CustomTextData.SkinM416 or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinM416 = v; if _G.skinIdMappings[101004] and _G.skinIdMappings[101004][v] then _G.WeaponSkinMap[101004] = _G.skinIdMappings[101004][v] end return true end },
            { Key = "ModMenu_Skin_AKM", UI = AliasMap.Slider, Text = "   AKM Skin (1 to 8 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 8, GetFunc = function() return _G.PGState.CustomTextData.SkinAKM or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinAKM = v; if _G.skinIdMappings[101001] and _G.skinIdMappings[101001][v] then _G.WeaponSkinMap[101001] = _G.skinIdMappings[101001][v] end return true end },
            { Key = "ModMenu_Skin_SCAR", UI = AliasMap.Slider, Text = "   SCAR-L Skin (1 to 8 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 8, GetFunc = function() return _G.PGState.CustomTextData.SkinSCAR or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinSCAR = v; if _G.skinIdMappings[101003] and _G.skinIdMappings[101003][v] then _G.WeaponSkinMap[101003] = _G.skinIdMappings[101003][v] end return true end },
            { Key = "ModMenu_Skin_M762", UI = AliasMap.Slider, Text = "   Beryl M762 Skin (1 to 9 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 8, GetFunc = function() return _G.PGState.CustomTextData.SkinM762 or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinM762 = v; if _G.skinIdMappings[101008] and _G.skinIdMappings[101008][v] then _G.WeaponSkinMap[101008] = _G.skinIdMappings[101008][v] end return true end },
            { Key = "ModMenu_Skin_AUG", UI = AliasMap.Slider, Text = "   AUG Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 7, GetFunc = function() return _G.PGState.CustomTextData.SkinAUG or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinAUG = v; if _G.skinIdMappings[101006] and _G.skinIdMappings[101006][v] then _G.WeaponSkinMap[101006] = _G.skinIdMappings[101006][v] end return true end },
            { Key = "ModMenu_Skin_Honey", UI = AliasMap.Slider, Text = "   Honey Badger Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.PGState.CustomTextData.SkinHoney or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinHoney = v; if _G.skinIdMappings[101012] and _G.skinIdMappings[101012][v] then _G.WeaponSkinMap[101012] = _G.skinIdMappings[101012][v] end return true end },
            { Key = "ModMenu_Skin_QBZ", UI = AliasMap.Slider, Text = "   QBZ Skin ( 1 to 3)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.PGState.CustomTextData.SkinQBZ or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinQBZ = v; if _G.skinIdMappings[101007] and _G.skinIdMappings[101007][v] then _G.WeaponSkinMap[101007] = _G.skinIdMappings[101007][v] end return true end },
            { Key = "ModMenu_Skin_ASM", UI = AliasMap.Slider, Text = "   ASM Abakan Skin ( 1 to 2)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.PGState.CustomTextData.SkinASM or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinASM = v; if _G.skinIdMappings[101101] and _G.skinIdMappings[101101][v] then _G.WeaponSkinMap[101101] = _G.skinIdMappings[101101][v] end return true end },
            { Key = "ModMenu_Skin_ACE32", UI = AliasMap.Slider, Text = "   ACE32 Skin ( 1 to 2)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.PGState.CustomTextData.SkinACE32 or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinACE32 = v; if _G.skinIdMappings[101102] and _G.skinIdMappings[101102][v] then _G.WeaponSkinMap[101102] = _G.skinIdMappings[101102][v] end return true end },
            { Key = "ModMenu_Skin_UMP", UI = AliasMap.Slider, Text = "   UMP45 Skin (1 to 6 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 6, GetFunc = function() return _G.PGState.CustomTextData.SkinUMP or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinUMP = v; if _G.skinIdMappings[102002] and _G.skinIdMappings[102002][v] then _G.WeaponSkinMap[102002] = _G.skinIdMappings[102002][v] end return true end },
            { Key = "ModMenu_Skin_UZI", UI = AliasMap.Slider, Text = "   UZI Skin (1 to 2 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.PGState.CustomTextData.SkinUZI or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinUZI = v; if _G.skinIdMappings[102001] and _G.skinIdMappings[102001][v] then _G.WeaponSkinMap[102001] = _G.skinIdMappings[102001][v] end return true end },
            { Key = "ModMenu_Skin_Vector", UI = AliasMap.Slider, Text = "   Vector Skin (1 to 2 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.PGState.CustomTextData.SkinVector or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinVector = v; if _G.skinIdMappings[102003] and _G.skinIdMappings[102003][v] then _G.WeaponSkinMap[102003] = _G.skinIdMappings[102003][v] end return true end },
            { Key = "ModMenu_Skin_Groza", UI = AliasMap.Slider, Text = "   Groza Skin (1 to 2 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.PGState.CustomTextData.SkinGroza or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinGroza = v; if _G.skinIdMappings[101005] and _G.skinIdMappings[101005][v] then _G.WeaponSkinMap[101005] = _G.skinIdMappings[101005][v] end return true end },
            { Key = "ModMenu_Skin_Kar98K", UI = AliasMap.Slider, Text = "   Kar98K Skin (1 to 3 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.PGState.CustomTextData.SkinKar98K or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinKar98K = v; if _G.skinIdMappings[103001] and _G.skinIdMappings[103001][v] then _G.WeaponSkinMap[103001] = _G.skinIdMappings[103001][v] end return true end },
            { Key = "ModMenu_Skin_M24", UI = AliasMap.Slider, Text = "   M24 Skin (1 to 2 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.PGState.CustomTextData.SkinM24 or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinM24 = v; if _G.skinIdMappings[103002] and _G.skinIdMappings[103002][v] then _G.WeaponSkinMap[103002] = _G.skinIdMappings[103002][v] end return true end },
            { Key = "ModMenu_Skin_AWM", UI = AliasMap.Slider, Text = "   AWM Skin (1 to 4 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 4, GetFunc = function() return _G.PGState.CustomTextData.SkinAWM or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinAWM = v; if _G.skinIdMappings[103003] and _G.skinIdMappings[103003][v] then _G.WeaponSkinMap[103003] = _G.skinIdMappings[103003][v] end return true end },
            { Key = "ModMenu_Skin_AMR", UI = AliasMap.Slider, Text = "   AMR Skin (1 to 3 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.PGState.CustomTextData.SkinAMR or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinAMR = v; if _G.skinIdMappings[103012] and _G.skinIdMappings[103012][v] then _G.WeaponSkinMap[103012] = _G.skinIdMappings[103012][v] end return true end },
            { Key = "ModMenu_Skin_S12K", UI = AliasMap.Slider, Text = "   S12K Skin (1 to 2 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.PGState.CustomTextData.SkinS12K or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinS12K = v; if _G.skinIdMappings[104003] and _G.skinIdMappings[104003][v] then _G.WeaponSkinMap[104003] = _G.skinIdMappings[104003][v] end return true end },
            { Key = "ModMenu_Skin_DBS", UI = AliasMap.Slider, Text = "   DBS Skin (1 to 3 custom)", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.PGState.CustomTextData.SkinDBS or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinDBS = v; if _G.skinIdMappings[104004] and _G.skinIdMappings[104004][v] then _G.WeaponSkinMap[104004] = _G.skinIdMappings[104004][v] end return true end },
            { Key = "ModMenu_Skin_Dacia", UI = AliasMap.Slider, Text = "   Dacia (Car) Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 90, GetFunc = function() return _G.PGState.CustomTextData.SkinDacia or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinDacia = v; if _G.VehicleSkins[1903001] and _G.VehicleSkins[1903001][v] then _G.VehicleSkinMap[1903001] = _G.VehicleSkins[1903001][v] end return true end },
            { Key = "ModMenu_Skin_UAZ", UI = AliasMap.Slider, Text = "   UAZ (Jeep) Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 90, GetFunc = function() return _G.PGState.CustomTextData.SkinUAZ or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinUAZ = v; if _G.VehicleSkins[1908001] and _G.VehicleSkins[1908001][v] then _G.VehicleSkinMap[1908001] = _G.VehicleSkins[1908001][v] end return true end },
            { Key = "ModMenu_Skin_Coupe", UI = AliasMap.Slider, Text = "   Coupe RB (Sports) Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 70, GetFunc = function() return _G.PGState.CustomTextData.SkinCoupe or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinCoupe = v; if _G.VehicleSkins[1961001] and _G.VehicleSkins[1961001][v] then _G.VehicleSkinMap[1961001] = _G.VehicleSkins[1961001][v] end return true end },
            { Key = "ModMenu_Skin_Buggy", UI = AliasMap.Slider, Text = "   Buggy Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 50, GetFunc = function() return _G.PGState.CustomTextData.SkinBuggy or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinBuggy = v; if _G.VehicleSkins[1907001] and _G.VehicleSkins[1907001][v] then _G.VehicleSkinMap[1907001] = _G.VehicleSkins[1907001][v] end return true end },
            { Key = "ModMenu_Skin_Mirado", UI = AliasMap.Slider, Text = "   Mirado (Convertible) Skin", ExpandHandle = "ModMenu_Skin_Ex", MinValue = 1, MaxValue = 27, GetFunc = function() return _G.PGState.CustomTextData.SkinMirado or 1 end, SetFunc = function(c,v) _G.PGState.CustomTextData.SkinMirado = v; if _G.VehicleSkins[1915001] and _G.VehicleSkins[1915001][v] then _G.VehicleSkinMap[1915001] = _G.VehicleSkins[1915001][v] end return true end }
        }

        -- ==================== COLOR MOD (Warna untuk ESP dan Wallhack) ====================
        local StackColorMod = {
            { Key = "COLOR_Visible", UI = AliasMap.Switcher, Text = "Visible Color (ESP & WH)",
              SwitcherText = {"Red","White","Yellow","Green","Cyan","Blue","Purple"},
              SwitcherValue = {1,2,3,4,5,6,7},
              GetFunc = function() return _G.ColorConfig.VisibleColor end,
              SetFunc = function(_, v) _G.ColorConfig.VisibleColor = v; _G.SaveModSettings(); return true end },
            { Key = "COLOR_Invisible", UI = AliasMap.Switcher, Text = "Invisible Color (ESP & WH)",
              SwitcherText = {"Red","White","Yellow","Green","Cyan","Blue","Purple"},
              SwitcherValue = {1,2,3,4,5,6,7},
              GetFunc = function() return _G.ColorConfig.InvisibleColor end,
              SetFunc = function(_, v) _G.ColorConfig.InvisibleColor = v; _G.SaveModSettings(); return true end },
            { Key = "COLOR_Brightness", UI = AliasMap.Slider, Text = "Brightness (1-50)", Min = 1, Max = 50, Step = 1,
              GetFunc = function() return _G.ColorConfig.Brightness end,
              SetFunc = function(_, v) _G.ColorConfig.Brightness = v; _G.SaveModSettings(); return true end },
            { Key = "COLOR_Glow", UI = AliasMap.Slider, Text = "Glow Intensity (0-10) (WH)", Min = 0, Max = 10, Step = 0.5,
              GetFunc = function() return _G.ColorConfig.Glow end,
              SetFunc = function(_, v) _G.ColorConfig.Glow = v; _G.SaveModSettings(); return true end }
        }

        -- ==================== DEFINE MENU PAGE ====================
        -- ==================== ESP V2 STACK ====================
        local StackESPV2 = {
            { Key = "ModMenu_ESP9_Title", UI = AliasMap.Title, Text = "❏ ESP V2 BOX" },
            -- ==================== ESP V2 (canvas-based BOX/LINE/HP/WEAPON/TEAM/DISTANCE/NAME) ====================
            { Key = "ModMenu_ESP9_Header", UI = AliasMap.TitleSwitcher, Text = "▶ ESP V2 ✥", ExpandIndex = 0,
              GetFunc = function() return _G.PGConfig.EspLoai9 end,
              SetFunc = function(c,v)
                _G.PGConfig.EspLoai9     = v
                _G.PGConfig.Esp9_Line    = v
                _G.PGConfig.Esp9_HP      = v
                _G.PGConfig.Esp9_Distance= v
                _G.PGConfig.Esp9_Name    = v
                return true
              end },
            { Key = "ModMenu_ESP9_Ex",     UI = AliasMap.TitleSwitcher, Text = "   ESP BOX",        ExpandHandle = "ModMenu_ESP9_Header", ExpandIndex = 0, GetFunc = function() return _G.PGConfig.EspLoai9     end, SetFunc = function(c,v) _G.PGConfig.EspLoai9     = v return true end },
            { Key = "ModMenu_ESP9_Count",  UI = AliasMap.TitleSwitcher, Text = "   PLAYER COUNTER",  ExpandHandle = "ModMenu_ESP9_Header", ExpandIndex = 0, GetFunc = function() return _G.PGConfig.Esp9_Count    end, SetFunc = function(c,v) _G.PGConfig.Esp9_Count    = v return true end },
            { Key = "ModMenu_ESP9_Line",   UI = AliasMap.TitleSwitcher, Text = "   ESP LINE",       ExpandHandle = "ModMenu_ESP9_Header", ExpandIndex = 0, GetFunc = function() return _G.PGConfig.Esp9_Line     end, SetFunc = function(c,v) _G.PGConfig.Esp9_Line     = v return true end },
            { Key = "ModMenu_ESP9_HP",     UI = AliasMap.TitleSwitcher, Text = "   ESP HEALTH BAR", ExpandHandle = "ModMenu_ESP9_Header", ExpandIndex = 0, GetFunc = function() return _G.PGConfig.Esp9_HP       end, SetFunc = function(c,v) _G.PGConfig.Esp9_HP       = v return true end },
            { Key = "ModMenu_ESP9_Radar",  UI = AliasMap.TitleSwitcher, Text = "   360 MARKER",     ExpandHandle = "ModMenu_ESP9_Header", ExpandIndex = 0, GetFunc = function() return _G.PGConfig.Esp9_Distance  end, SetFunc = function(c,v) _G.PGConfig.Esp9_Distance  = v return true end },
            { Key = "ModMenu_ESP9_Name",   UI = AliasMap.TitleSwitcher, Text = "   ESP NAME",        ExpandHandle = "ModMenu_ESP9_Header", ExpandIndex = 0, GetFunc = function() return _G.PGConfig.Esp9_Name      end, SetFunc = function(c,v) _G.PGConfig.Esp9_Name      = v return true end },
        }

        -- ==================== BRUTAL STACK ====================
        local StackBrutal = {
            { Key = "ModMenu_Brutal_Title", UI = AliasMap.Title, Text = "❏ BRUTAL FEATURES - @PGHACKS1", ExpandHandle = "ModMenu_Skin3_Ex" },

            -- MAGIC BULLET ADJUSTABLE
            { Key = "ModMenu_Magic_Ex2", UI = AliasMap.TitleSwitcher, Text = "▶ MAGIC BULLET ADJUSTABLE", ExpandIndex = 0,
              GetFunc = function() return _G.PGConfig.CustomMagicBullet end,
              SetFunc = function(c,v) _G.PGConfig.CustomMagicBullet = v return true end },
            { Key = "ModMenu_Brutal_MagicHead", UI = AliasMap.Slider, Text = "   HEAD Damage", ExpandHandle = "ModMenu_Magic_Ex2",
              MinValue = 0, MaxValue = 100, min = 0, max = 100,
              GetFunc = function() return math.floor(((_G.PGState.CustomTextData.MagicHead or 1.0) / 5.0) * 100 + 0.5) end,
              SetFunc = function(c,v) _G.PGState.CustomTextData.MagicHead = (v / 100.0) * 5.0 return true end },
            { Key = "ModMenu_Brutal_MagicBody", UI = AliasMap.Slider, Text = "   BODY Damage", ExpandHandle = "ModMenu_Magic_Ex2",
              MinValue = 0, MaxValue = 100, min = 0, max = 100,
              GetFunc = function() return math.floor(((_G.PGState.CustomTextData.MagicBody or 1.0) / 5.0) * 100 + 0.5) end,
              SetFunc = function(c,v) _G.PGState.CustomTextData.MagicBody = (v / 100.0) * 5.0 return true end },
            { Key = "ModMenu_Brutal_MagicLegs", UI = AliasMap.Slider, Text = "   LEGS Damage", ExpandHandle = "ModMenu_Magic_Ex2",
              MinValue = 0, MaxValue = 100, min = 0, max = 100,
              GetFunc = function() return math.floor(((_G.PGState.CustomTextData.MagicLegs or 1.0) / 5.0) * 100 + 0.5) end,
              SetFunc = function(c,v) _G.PGState.CustomTextData.MagicLegs = (v / 100.0) * 5.0 return true end },

            -- FAST SHOOT
            { Key = "ModMenu_FastShoot", UI = AliasMap.Switcher, Text = "FAST SHOOT",
              GetFunc = function() return _G.PGConfig.FastShoot end,
              SetFunc = function(c,v) _G.PGConfig.FastShoot = v return true end },

            -- SMALL CROSS NO SPREAD
            { Key = "ModMenu_SmallCross", UI = AliasMap.Switcher, Text = "SMALL CROSS NO SPREAD",
              GetFunc = function() return _G.PGConfig.Crosshair end,
              SetFunc = function(c,v) _G.PGConfig.Crosshair = v return true end },

            -- CAR SPEED 6000 (ON/OFF only)
            { Key = "ModMenu_FastCar", UI = AliasMap.Switcher, Text = "CAR SPEED 6000",
              GetFunc = function() return _G.PGConfig.FastCar == true end,
              SetFunc = function(c,v) _G.PGConfig.FastCar = (v == true) return true end },

            -- HIGH JUMP (same toggle as existing logic)
            { Key = "ModMenu_HighJump", UI = AliasMap.Switcher, Text = "HIGH JUMP",
              GetFunc = function() return _G.PGConfig.HighJump end,
              SetFunc = function(c,v) _G.PGConfig.HighJump = v return true end },

            -- SPEED HACK with bypass
            { Key = "ModMenu_SpeedHack_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ SPEED HACK", ExpandIndex = 0,
              GetFunc = function() return _G.MemoryConfig and _G.MemoryConfig.SpeedHack end,
              SetFunc = function(c,v) if SetMemorySpeedHack then SetMemorySpeedHack(v) end return true end },
            { Key = "ModMenu_SpeedPercent", UI = AliasMap.Slider, Text = "   Speed % (100-500)", ExpandHandle = "ModMenu_SpeedHack_Ex",
              MinValue = 0, MaxValue = 100,
              GetFunc = function() return ((_G.MemoryConfig and _G.MemoryConfig.SpeedPercent or 150) - 100) / 4 end,
              SetFunc = function(c,v) if SetMemorySpeedPercent then SetMemorySpeedPercent(100 + (v * 4)) end return true end },

            -- FAST PARACHUTE
            { Key = "ModMenu_FastParachute", UI = AliasMap.Switcher, Text = "FAST PARACHUTE",
              GetFunc = function() return _G.PGConfig.FastParachute == true end,
              SetFunc = function(c, v)
                _G.PGConfig.FastParachute = (v == true)
                if v then
                  -- Enable: apply values immediately if already in parachute
                  if FastParachute and FastParachute.Owner and slua.isValid(FastParachute.Owner) then
                    FP_ApplyFixedValues(FastParachute.Owner)
                  end
                else
                  -- Disable: reset ParachuteComponent to defaults
                  if FastParachute and FastParachute.Owner and slua.isValid(FastParachute.Owner) then
                    local ParaComp = FastParachute.Owner.ParachuteComponent
                    if slua.isValid(ParaComp) then
                      pcall(function()
                        ParaComp.FreeFall_AcceFall = 600
                        ParaComp.FreeFall_MaxForwardSpeed = 1400
                        ParaComp.FreeFall_MaxForwardExtraFallSpeed = 2000
                        ParaComp.Opened_MaxForwardSpeed = 700
                        ParaComp.Opened_AcceForward = 400
                      end)
                    end
                  end
                end
                return true
              end },
        }

        SettingPageDefine.ModMenu = {
            Key = "ModMenu",
            Text= "@PGHACKS1 MENU",
            UIKey = "Setting_Page_Privacy", 
            Category = {
                { Key = "Cat_SkinMod", Text= "SKIN CUSTOM", Stack = StackSkinMod },
                { Key = "Cat_Aimbot_Force", Text= "UR/ROOM-TOUCH AIM", Stack = StackAimbotForce },
                { Key = "Cat_ESP_Visual", Text= "ESP PLAYER", Stack = StackESPVisual },
                { Key = "Cat_Combat_Graphic", Text= "WALLHACK/FPS", Stack = StackCombatGraphic },
                { Key = "Cat_ColorMod", Text= "COLOR CUSTOM", Stack = StackColorMod },
                { Key = "Cat_ESP_V2", Text= "ESP V2 BOX", Stack = StackESPV2 },
                { Key = "Cat_Brutal", Text= "BRUTAL FEATURES", Stack = StackBrutal },
            }
        }
        
        table.insert(SettingCatalog, SettingPageDefine.ModMenu)
    end

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsModMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            local n = select('#', ...) 
            
            if config and config.keyName and (string.find(string.lower(config.keyName), "setting_main") or string.find(string.lower(config.keyName), "setting")) then
                local catalog = args[1]
                if type(catalog) == "table" then
                    local hasModMenu = false
                    for _, page in ipairs(catalog) do
                        if type(page) == "table" and page.Key == "ModMenu" then
                            hasModMenu = true
                            break
                        end
                    end
                    if not hasModMenu then
                        table.insert(catalog, SettingPageDefine.ModMenu)
                    end
                end
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args, 1, n))
        end
        UIManager._IsModMenuHooked = true
    end
end

local function ShowGTLMODVIPMenu() 
    if _G.PGMenuAlreadyShown then return end
    if _G.PGState.MenuStep ~= 0 then return end

    pcall(function()
        local Msg = require("client.slua.logic.common.logic_common_msg_box")
        if not Msg or not Msg.Show then return end

        local function Step_ScamAlert()
            Msg.Show(1, "@PGHACKS1 LUA PAK", "DON'T PLAY LIKE A ANIMAL \nAVOID FROM REPORT!!\n\nREAL OWNER WHATSAPP - 03170025278", function() local Web = require("client.slua.logic.url.logic_webview_sdk"); if Web and Web.OpenURL then Web:OpenURL("https://Wa.me/+923170025278") end end, function() end, "JOIN", "CLOSE")
            _G.PGState.MenuStep = 99
            _G.PGMenuAlreadyShown = true
        end

        local function Step_Welcome()
            Msg.Show(1, "PG HACKS LUA", "ACTIVATION SUCCESSFUL!\n\nIF THE LUA PACK EXPIRES, THEN IT WILL NO LONGER WORK.\nTHE REAL OWNER TELEGRAM @PGHACKS1",
            function() 
                _G.InitModMenuTab()
                Notify("VIP MOD MENU BY PG HACKS TO TOGGLE FEATURES!")
                Step_ScamAlert()
            end, 
            function() end, "OK", "CLOSE")
        end

        _G.PGState.MenuStep = 1
        Step_Welcome() 
    end)
end

-- ========================================== 
-- LOGIC 165 FPS IPAD VIEW 
-- ========================================== 
local function InitializeGraphicsUnlock() 
    if isExpired then return end
    if _G.PGState.GraphicsUnlocked or currentTime > limitTime then return end

    pcall(function()
        local SettingCfg = require("client.logic.setting.setting_config")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if SettingCfg then
            if SettingCfg.TpViewValue then SettingCfg.TpViewValue.max = 160 end
            if SettingCfg.FpViewValue then SettingCfg.FpViewValue.max = 160 end
        end
        if GraphicSettingDB then
            if GraphicSettingDB.TpViewValue then GraphicSettingDB.TpViewValue.max = 160 end
        end
    end)

    pcall(function()
        local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
        local GSC_FPS = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")
        local GSC_FPSFT = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        
        local KismetMathLibrary = import("KismetMathLibrary") or _G.KismetMathLibrary
        local FLinearColor = import("LinearColor") or _G.FLinearColor

        if logic_setting_graphics then
            local old_SetFPS = logic_setting_graphics.SetFPS
            function logic_setting_graphics.SetFPS(gameInstance, FPSLevel)
                if old_SetFPS then old_SetFPS(gameInstance, FPSLevel) end
                if FPSLevel == 8 then 
                    gameInstance:ExecuteCMD("t.MaxFPS", "165")
                    gameInstance:ExecuteCMD("r.FrameRateLimit", "165")
                end
            end
        end

        if GSC_FPS and GSC_FPS.__inner_impl then
            local fps_impl = GSC_FPS.__inner_impl
            function fps_impl:GetMaxFPSLevel() return 8, 8 end
            function fps_impl:InitRealSupportFPS()
                local RealSupportFPS = {}
                for i = 1, 8 do RealSupportFPS[i] = {true, true} end
                if GraphicSettingDB then GraphicSettingDB:UpdateUIData(GraphicSettingDB.RealSupportFPS, RealSupportFPS, false) end
                return RealSupportFPS
            end
            function fps_impl:UpdateSelectedFPSState(selectedLevel)
                if not slua.isValid(self.UIRoot) then return end
                for level = 2, 8 do
                    local name = "NodeFps" .. (({[2]=20,[3]=25,[4]=30,[5]=40,[6]=60,[7]=90,[8]=120})[level] or 120)
                    local widget = self.UIRoot[name]
                    if slua.isValid(widget) then
                        widget:SetIsEnabled(true) 
                        pcall(function() widget:SetRenderOpacity(1.0) end)
                        local switcher = self.UIRoot["WidgetSwitcher_" .. level]
                        if slua.isValid(switcher) then 
                            switcher:SetActiveWidgetIndex(level == selectedLevel and 0 or 1) 
                        end
                    end
                end
            end
        end

        if GSC_FPSFT and GSC_FPSFT.__inner_impl then
            local ft_impl = GSC_FPSFT.__inner_impl
            local NMinFPS, NStep = 90, 5
            local function clamp(value, min, max)
                if value < min then return min end
                if max < value then return max end
                return value
            end
            local function lerp(a, b, t) return a + (b - a) * t end
            local function _getColorByPercent(start, finish, percent)
                if not FLinearColor then return nil end
                return FLinearColor(lerp(start.R, finish.R, percent), lerp(start.G, finish.G, percent), lerp(start.B, finish.B, percent), lerp(start.A, finish.A, percent))
            end
            
            ft_impl.ShowOrHide = function(self)
                self:SelfHitTestInvisible()
                if self.InitFPSFTSwitch then self:InitFPSFTSwitch() end
            end

            ft_impl.InitFPSFTSwitch = function(self)
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                if self.UIRoot.Setting_Switch then self.UIRoot.Setting_Switch:SetSwitcherEnable2(FPSFineTuneSwitch, true) end
                if self.UIRoot.CanvasPanel_8 then self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, FPSFineTuneSwitch) end
                if self.UIRoot.WidgetSwitcher_0 then self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2) end
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
            end

            ft_impl.InitFPSFTValue165 = function(self)
                local itemRoot = self.UIRoot
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                local FPSFineTuneNum = 165
                if FPSFineTuneSwitch then
                    FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum) or 165
                    itemRoot.Slider_screen3:SetLocked(false)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 1.0, 1.0, 1.0))
                    end
                else
                    itemRoot.Slider_screen3:SetLocked(true)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 0.625, 0.6, 1))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 0.625, 0.6, 1.0))
                    end
                end
                local FPSFineTunePer = (FPSFineTuneNum - NMinFPS) / (165 - NMinFPS)
                
                itemRoot.Veihclescreen3:SetText(tostring(FPSFineTuneNum))
                itemRoot.Slider_screen3:SetValue(FPSFineTunePer)
                itemRoot.ProgressBar_screen3:SetPercent(FPSFineTunePer)
                
                if FLinearColor then
                    local startColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
                    local midColor = FLinearColor(1.0, 0.54, 0.11, 1.0)
                    local endColor = FLinearColor(1.0, 0.23, 0.15, 1.0)
                    local sliderColor = FPSFineTunePer < 0.4 and startColor or _getColorByPercent(midColor, endColor, (FPSFineTunePer - 0.4) / 0.6)
                    itemRoot.Slider_screen3:SetSliderHandleColor(sliderColor)
                end
            end

            ft_impl.OnFPSFTValueChange3 = function(self, FPSFineTuneNum)
                GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneNum, FPSFineTuneNum)
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
                if self:GetParentUI() then self:GetParentUI():SetDirty(true) end
                local gameInstance = GraphicSettingDB.GetGameInstance and GraphicSettingDB.GetGameInstance()
                if gameInstance then
                    gameInstance:ExecuteCMD("t.MaxFPS", tostring(FPSFineTuneNum))
                    gameInstance:ExecuteCMD("r.FrameRateLimit", tostring(FPSFineTuneNum))
                end
            end

            ft_impl.OnFPSFTSliderValueChange3 = function(self, value)
                if GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch) and KismetMathLibrary then
                    local FPSFineTuneNum = KismetMathLibrary.FCeil(value * (165 - NMinFPS) / NStep) * NStep + NMinFPS
                    self:OnFPSFTValueChange3(clamp(FPSFineTuneNum, NMinFPS, 165))
                end
            end
            
            ft_impl.OnFPSFTAdd = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTAdd2 = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus2 = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTSliderValueChange = ft_impl.OnFPSFTSliderValueChange3
            ft_impl.OnFPSFTSliderValueChange2 = ft_impl.OnFPSFTSliderValueChange3
        end
    end)
    _G.PGState.GraphicsUnlocked = true
    Notify("Graphics & FPS 165Hz Unlocked (Upgraded Version)")
end

-- ========================================== 
-- INITIALIZE THE ESP SYSTEM (BASED)
-- ========================================== 
local function InitializeNativeESP() 
    if _G.PGState.NativeESPReady then return end
    pcall(function() 
        local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools") 
        local currentMarkCfg = GamePlayTools.GetCurrentConfig("ScreenMarkConfig") 
        local function ApplyCfg(cfg)
            if not cfg then return end 
            if cfg[1006] then 
                cfg[1006].bBindBlocked = true;
                cfg[1006].bBindOutScreen = true; 
                cfg[1006].MaxWidgetNum = 99
                cfg[1006].MaxShowDistance = 6000000; 
                cfg[1006].bScaleByDistance = false
                cfg[1006].BindSocketName = "root"; 
                cfg[1006].bUseLuaWorldSocketName = true
                cfg[1006].WorldPositionOffset = FVector(0, 0, -30) 
            end 
            cfg[8888] = { 
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99, 
                MaxShowDistance = 6000000, 
                bBindOutScreen = true,
                bBindBlocked = true, 
                bIsBindingActor = true,
                BindSocketName = "head",
                bUseLuaWorldSocketName = true, 
                WorldPositionOffset = FVector(0, 0, 30),
                bNeedPreLoad = true,
                Priority = 2 
            } 
            cfg[9999] = { 
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99, 
                MaxShowDistance = 6000000, 
                bBindOutScreen = true,
                bBindBlocked = true, 
                bIsBindingActor = true, 
                BindSocketName = "head",
                bUseLuaWorldSocketName = true, 
                WorldPositionOffset = FVector(0, 0, 50),
                bNeedPreLoad = true, 
                Priority = 2 
            } 
        end 
        ApplyCfg(currentMarkCfg) 
        for k, cfg in pairs(package.loaded) do 
            if type(k) == "string" and string.find(k, "ScreenMarkConfig") and type(cfg) == "table" then 
                ApplyCfg(cfg) 
            end 
        end 
    end)
    _G.PGState.NativeESPReady = true 
    Notify("Native ESP System Initialized") 
end

-- ========================================== 
-- LOCAL FUNCTIONS CHO LOGIC NEW ESP - OPTIMIZED
-- ========================================== 
local function GetAllSkeletalMeshes(enemy, markData)
    local curTime = os.clock()
    if markData and markData.CachedMeshes and markData.CachedMeshTime and (curTime - markData.CachedMeshTime) < 3.0 then
        local validMeshes = {}
        for _, cachedMesh in ipairs(markData.CachedMeshes) do
            if Valid(cachedMesh) then table.insert(validMeshes, cachedMesh) end
        end
        markData.CachedMeshes = validMeshes
        return validMeshes
    end

    local meshes = {}
    if Valid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
    pcall(function()
        local SkeletalMeshClass = import("SkeletalMeshComponent")
        if SkeletalMeshClass and type(enemy.GetComponentsByClass) == "function" then
            local childs = enemy:GetComponentsByClass(SkeletalMeshClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for i = 1, count do
                    local comp = type(childs.Get) == "function" and childs:Get(i-1) or childs[i]
                    if Valid(comp) and comp ~= enemy.Mesh then
                        table.insert(meshes, comp)
                    end
                end
            end
        end
    end)
    if markData then
        markData.CachedMeshes = meshes
        markData.CachedMeshTime = curTime
    end
    return meshes
end

-- ========================================== 
-- WALL-BOUND FUNCTION & ROOT RESTORE (menggunakan ColorConfig)
-- ==========================================
local function Undowallhackng(enemy, markData)
    pcall(function()
        if markData.WallhackApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for _, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function() if type(mesh.SetRenderCustomDepth) == "function" then mesh:SetRenderCustomDepth(false) end end)
                    for i = 0, 10 do 
                        local matInterface = mesh:GetMaterial(i)
                        if Valid(matInterface) then
                            local baseMat = matInterface:GetBaseMaterial()
                            if Valid(baseMat) then baseMat.bDisableDepthTest = false end
                        end
                    end
                end
            end
            markData.WallhackApplied = false
        end
    end)
end

local function Applywallhackng(enemy, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then 
                pcall(function()
                    if type(mesh.SetRenderCustomDepth) == "function" then
                        mesh:SetRenderCustomDepth(true)
                    end
                    if type(mesh.SetCustomDepthStencilValue) == "function" then
                        mesh:SetCustomDepthStencilValue(252) 
                    end
                end)
                for i = 0, 10 do 
                    local matInterface = mesh:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        baseMat.bDisableDepthTest = true
                        baseMat.BlendMode = 2 
                    end
                end
            end
        end
    end)
end

-- ========================================== 
-- WALLHACK WITH COLOR FROM COLORCONFIG
-- ==========================================
local function ApplyColorBodyV2(enemy, pc, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local curTime = os.clock()
        if markData.LastVisCheckTime == nil or (curTime - markData.LastVisCheckTime) > 0.3 then
            markData.LastVisCheckTime = curTime
            local isHidden = true
            pcall(function()
                if Valid(pc) and type(pc.LineOfSightTo) == "function" then
                    if pc:LineOfSightTo(enemy) then isHidden = false else isHidden = true end
                end
            end)
            markData.CachedHiddenState = isHidden
        end
        
        local hidden = markData.CachedHiddenState
        if hidden == nil then hidden = true end
        
        -- Ambil warna dari ColorConfig
        local visibleColor = GetAppliedColor(_G.ColorConfig.VisibleColor or 4, _G.ColorConfig.Brightness)
        local invisibleColor = GetAppliedColor(_G.ColorConfig.InvisibleColor or 1, _G.ColorConfig.Brightness)
        local finalColor = hidden and invisibleColor or visibleColor
        
        local colorHash = string.format("%d_%d_%d_%d", finalColor.R, finalColor.G, finalColor.B, finalColor.A)
        local currentMeshCount = #meshes
        local isMeshChanged = (markData.LastMeshCount ~= currentMeshCount)
        
        if not isMeshChanged and markData.LastHiddenState == hidden and markData.LastColorHash == colorHash then return end
        
        if isMeshChanged and markData.MIDs then
            markData.MIDs = {}
        end

        markData.LastHiddenState = hidden
        markData.LastMeshCount = currentMeshCount
        markData.LastColorHash = colorHash
        markData.ColorApplied = true
        
        for meshIndex, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    mesh.LDMaxDrawDistance = -99999
                    mesh.MaxDrawDistanceOffset = -99999
                    mesh.CachedMaxDrawDistance = -99999
                    mesh.UseScopeDistanceCulling = true
                    mesh.PrimitiveShadingStrategy = 1
                    mesh.ShadingRate = 6
                end)
                for i = 0, 10 do
                    local matInterface = mesh:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        local matName = tostring(baseMat)
                        if string.find(matName, "Master_Mask", 1, true) then
                            if not markData.MIDs then markData.MIDs = {} end
                            
                            local meshKey = "Mesh_" .. tostring(meshIndex)
                            
                            if not markData.MIDs[meshKey] then markData.MIDs[meshKey] = {} end
                            local mid = markData.MIDs[meshKey][i]
                            if not Valid(mid) then
                                mid = mesh:CreateAndSetMaterialInstanceDynamic(i)
                                markData.MIDs[meshKey][i] = mid
                            end
                            if Valid(mid) then
                                mid:SetVectorParameterValue("颜色", finalColor)
                                mid:SetVectorParameterValue("Extra Light Color", finalColor)
                                mid:SetVectorParameterValue("Para_Color", finalColor)
                                mid:SetVectorParameterValue("Para_ColorTint", finalColor)
                                mid:SetVectorParameterValue("Para_Color_1", finalColor)
                                mid:SetVectorParameterValue("Tint", finalColor)
                                mid:SetVectorParameterValue("Color", finalColor)
                                mid:SetVectorParameterValue("BaseColor", finalColor)
                                mid:SetVectorParameterValue("BodyColor", finalColor)
                                mid:SetVectorParameterValue("MainColor", finalColor)
                                mid:SetVectorParameterValue("DiffuseColor", finalColor)
                                mid:SetVectorParameterValue("EmissiveColor", finalColor)
                                mid:SetVectorParameterValue("ParaScaleOffset", SCALE_COLOR_V2)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function UndoColorBodyV2(enemy, markData)
    pcall(function()
        if markData.ColorApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for meshIndex, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function()
                        mesh.PrimitiveShadingStrategy = 0
                        mesh.ShadingRate = 1
                    end)
                    local meshKey = "Mesh_" .. tostring(meshIndex)
                    if markData.MIDs and markData.MIDs[meshKey] then
                        for i, mid in pairs(markData.MIDs[meshKey]) do
                            if Valid(mid) then
                                local defC = {R=1, G=1, B=1, A=1}
                                mid:SetVectorParameterValue("颜色", defC)
                                mid:SetVectorParameterValue("Extra Light Color", defC)
                                mid:SetVectorParameterValue("Para_Color", defC)
                                mid:SetVectorParameterValue("Para_ColorTint", defC)
                                mid:SetVectorParameterValue("Para_Color_1", defC)
                                mid:SetVectorParameterValue("Tint", defC)
                                mid:SetVectorParameterValue("Color", defC)
                                mid:SetVectorParameterValue("BaseColor", defC)
                                mid:SetVectorParameterValue("BodyColor", defC)
                                mid:SetVectorParameterValue("MainColor", defC)
                                mid:SetVectorParameterValue("DiffuseColor", defC)
                                mid:SetVectorParameterValue("EmissiveColor", defC)
                            end
                        end
                    end
                end
            end
            markData.ColorApplied = false
            markData.LastColorHash = ""
            markData.LastHiddenState = nil
        end
    end)
end

-- ========================================== 
-- AIMBOT V2 SYSTEM WITH NEW INTEGRATED TECHNOLOGY (KISSMET SMOOTH UPDATE)
-- ========================================== 
_G.GetEnemyTargetsFromActors = function(radius)
    local result = {}
    local player = GameplayData.GetPlayerCharacter()

    if not slua.isValid(player) then
        return result
    end

    local allCharacters = {}
    if GameplayData.GetAllPlayerCharacters then
        allCharacters = GameplayData.GetAllPlayerCharacters()
    elseif GameplayData.GameCharacters then
        for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
    end

    local myTeam = player:GetTeamID()

    for _, actor in pairs(allCharacters) do
        if slua.isValid(actor) and actor ~= player and actor.GetTeamID and actor:IsAlive() then
            if actor:GetTeamID() ~= myTeam then
                local dist = player:GetDistanceTo(actor)
                if dist <= radius then
                    table.insert(result, actor)
                end
            end
        end
    end
    return result
end

_G.AimTouch = function()
    pcall(function()
        if not _G.PGConfig.AimTouchEnable then return end
        
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        
        local pc = player:GetPlayerControllerSafety()
        if not slua.isValid(pc) then return end
        
        local isFiring = player.bIsWeaponFiring
        local isADS = player.bIsGunADS
        
        local weapon = player.WeaponManagerComponent and player.WeaponManagerComponent.CurrentWeaponReplicated
        if not weapon and type(player.GetCurrentShootWeapon) == "function" then
            weapon = player:GetCurrentShootWeapon()
        end
        
        local isShotgun = false
        local isSniper = false
        local currentAmmo = 1
        
        if slua.isValid(weapon) then
            local wID = type(weapon.GetWeaponID) == "function" and weapon:GetWeaponID() or 0
            local wName = type(weapon.GetWeaponName) == "function" and weapon:GetWeaponName() or ""
            
            if (wID >= 1030000 and wID < 1040000) or wName:find("S686") or wName:find("S1897") or wName:find("S12") or wName:find("DBS") or wName:find("M1014") then 
                isShotgun = true 
            end
            
            if wName:find("Kar98") or wName:find("M24") or wName:find("AWM") or wName:find("Mosin") or wName:find("Win94") or wName:find("AMR") or wName:find("SKS") or wName:find("SLR") or wName:find("Mini") or wName:find("Mk14") or wName:find("QBU") or wName:find("Mk12") or wName:find("VSS") then
                isSniper = true
            end
            
            if type(weapon.GetCurrentAmmo) == "function" then
                currentAmmo = weapon:GetCurrentAmmo()
            elseif weapon.ShootWeaponComponent and type(weapon.ShootWeaponComponent.GetCurrentAmmo) == "function" then
                currentAmmo = weapon.ShootWeaponComponent:GetCurrentAmmo()
            elseif weapon.CurrentAmmo ~= nil then
                currentAmmo = weapon.CurrentAmmo
            end
        end

        if _G.PGState.IsAutoFiring then
            pcall(function()
                player.bIsWeaponFiring = false
                if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(false) end
                if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(false) end
                local wepMgr = player.WeaponManagerComponent
                if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = false end
            end)
            _G.PGState.IsAutoFiring = false
        end

        if isShotgun and currentAmmo <= 0 then
            return
        end

        local cond = 2
        local prioMode = 1
        local boneIdx = 1
        local speedVal = 50
        local fovVal = 30
        local maxDistMeters = 50
        local useVisCheck = false
        local igKnock = false
        local igBot = false
        
        local predVal = 0 
        local recoilCompVal = 0 

        -- ============================ UNIFIED AIMBOT LOGIC - WORKS ON ALL GUNS ============================
-- Ek hi setting saari guns pe (Hipfire + Scope + Shotgun + Sniper)
-- 4 flat buttons se control: Aimbot / Ignore Knocked / Ignore Bots / Visibility Check
-- Baaki values (bone, speed, fov, dist) safe-mode presets se auto set hoti hain per gun type

local predVal = 0
local recoilCompVal = 0

-- Shared toggles (saari guns ke liye same)
useVisCheck = _G.PGConfig.AimTouchVisCheck
igKnock     = _G.PGConfig.AimTouchIgKnock
igBot       = _G.PGConfig.AimTouchIgBot

if isShotgun then
    -- Shotgun (hipfire/scope dono me same)
    cond        = 0                 -- cond=2 → auto-fire on trigger pull (no firing check)
    prioMode    = 0
    boneIdx     = 0                 -- spine (body shot – reliable pellet spread)
    speedVal    = 0                -- slightly faster than ARs for CQC tracking
    fovVal      = 0                -- wider lock cone for close-range
    maxDistMeters = 0              -- max 30m effective range

elseif isADS then
    -- ====== SCOPED (ADS) ======
    if isSniper then
        -- Sniper Scope
        cond        = 2             -- cond=2 → no firing check (lock while scoped)
        prioMode    = 1
        boneIdx     = 1             -- head (one-shot kill priority)
        speedVal    = 85            -- medium-plus smoothness for precision
        fovVal      = 28            -- tight FOV for long-range
        maxDistMeters = 400         -- max 400m
        predVal     = 0             -- bullet drop prediction OFF (manual lead)
        -- (cond=2 so the `if cond==1 and not isFiring` below is never triggered)
    else
        -- AR / SMG / LMG / DMR Scope (non-sniper ADS)
        cond        = 1             -- cond=1 → active ONLY while firing
        if cond == 1 and not isFiring then return end   -- lock only during gunfire
        prioMode    = 1
        boneIdx     = 2             -- spine (center mass – forgiving for auto-fire)
        speedVal    = 85            -- medium-plus (natural tracking)
        fovVal      = 28            -- 28° lock cone
        maxDistMeters = 300         -- max 300m for AR-class
        predVal     = 10             -- no leading (aim at current position)
        recoilCompVal = 5           -- recoil compensation disabled
    end

else
    -- ====== HIPFIRE (no ADS) ======
    cond        = 1                 -- active ONLY while firing
    if cond == 1 and not isFiring then return end
    prioMode    = 1
    boneIdx     = 2                 -- spine (was incorrectly labelled "head" – fixed comment)
    speedVal    = 85                -- medium-plus
    fovVal      = 28                -- same tight FOV as ADS (personal preference)
    maxDistMeters = 250             -- max 250m hipfire effective range
end

-- Distance conversion (meters → engine units)
local currentMaxDist = maxDistMeters * 100

-- Fetch enemies within range
local enemies = _G.GetEnemyTargetsFromActors(currentMaxDist)
if not enemies or #enemies == 0 then return end

-- (rest of your targeting/filtering logic continues here...)

        local currentMaxDist = maxDistMeters * 100 

        local enemies = _G.GetEnemyTargetsFromActors(currentMaxDist)
        if not enemies or #enemies == 0 then return end
        
        local FVector2D = import("Vector2D")
        local UGameplayStatics = import("GameplayStatics")
        local KismetMathLibrary = import("KismetMathLibrary")
        
        local camManager = UGameplayStatics.GetPlayerCameraManager(pc, 0)
        if not slua.isValid(camManager) then return end
        
        local camLoc = camManager:GetCameraLocation()
        if not camLoc then return end
        
        local ui_util = require("client.common.ui_util")
        if not ui_util then return end
        
        local viewportSize = ui_util.GetViewportSize()
        if not viewportSize then return end
        
        local centerX = viewportSize.X * 0.5
        local centerY = viewportSize.Y * 0.5
        
        local FOV_RADIUS = (fovVal / 100.0) * (viewportSize.X / 2.0)
        
        local bestTarget = nil
        local bestScore = 99999999 
        
        local selBoneName = "head"
        if boneIdx == 1 then selBoneName = "head"
        elseif boneIdx == 2 then selBoneName = "spine_03"
        elseif boneIdx == 3 then selBoneName = "spine_01"
        elseif boneIdx == 4 then selBoneName = "pelvis" end

        for i, target in ipairs(enemies) do
            if not slua.isValid(target) then goto continue end
            
            pcall(function()
                if slua.isValid(target.Mesh) then
                    target.Mesh.MeshComponentUpdateFlag = 0
                end
            end)
            
            if igKnock and target.HealthStatus == 1 then goto continue end
            
            if igBot then
                -- Shared bot cache use karo (counter jaisa) - fast + consistent
                local tId = type(target.GetUniqueID) == "function" and target:GetUniqueID() or tostring(target)
                _G.BotStatusCache = _G.BotStatusCache or {}
                local cachedBot = _G.BotStatusCache[tId]
                if cachedBot == nil then
                    cachedBot = false
                    -- Method 1: direct AI flags
                    if target.bIsAI == true or target.IsAI == true or target.bIsAi == true then cachedBot = true end
                    -- Method 2: PUBGM AIData / AIController component (sabse reliable)
                    if not cachedBot then
                        if target.AIData ~= nil or target.AIController ~= nil or target.bIsAIActor == true then cachedBot = true end
                        if not cachedBot and target.PlayerAIType ~= nil and target.PlayerAIType ~= 0 then cachedBot = true end
                        if not cachedBot and type(target.IsAICharacter) == "function" then
                            local ok, r = pcall(function() return target:IsAICharacter() end)
                            if ok and r then cachedBot = true end
                        end
                        if not cachedBot and type(target.GetIsAI) == "function" then
                            local ok, r = pcall(function() return target:GetIsAI() end)
                            if ok and r then cachedBot = true end
                        end
                    end
                    -- Method 3: PlayerState flags + missing UID
                    if not cachedBot then
                        local pState = target.PlayerState
                        if slua.isValid(pState) then
                            if pState.bIsABot or pState.bIsBot or pState.IsBot or pState.bIsAI or pState.bIsRobot or pState.bIsAiPlayer then cachedBot = true end
                            if not cachedBot and pState.PlayerAIType ~= nil and pState.PlayerAIType ~= 0 then cachedBot = true end
                            if not cachedBot and type(pState.IsABot) == "function" then
                                local ok, r = pcall(function() return pState:IsABot() end)
                                if ok and r then cachedBot = true end
                            end
                            if not cachedBot then
                                local uid = pState.Uid or pState.UID or pState.PlayerId or pState.PlayerID
                                if uid ~= nil and (uid == 0 or uid == "0") then cachedBot = true end
                            end
                        end
                    end
                    -- Method 4: function checks
                    if not cachedBot and type(target.IsBot) == "function" then
                        local ok, r = pcall(function() return target:IsBot() end)
                        if ok and r then cachedBot = true end
                    end
                    -- Method 5: AI controller check
                    if not cachedBot and type(target.GetController) == "function" then
                        local ok, ctrl = pcall(function() return target:GetController() end)
                        if ok and slua.isValid(ctrl) and (ctrl.bIsAI == true or ctrl.IsAI == true or ctrl.AIData ~= nil) then cachedBot = true end
                    end
                    _G.BotStatusCache[tId] = cachedBot
                end
                if cachedBot then goto continue end
            end
            
            if useVisCheck then
                local curTime = os.clock()
                local tId = type(target.GetUniqueID) == "function" and target:GetUniqueID() or tostring(target)
                _G.AimTouchVisCache = _G.AimTouchVisCache or {}
                if not _G.AimTouchVisCache[tId] or (curTime - _G.AimTouchVisCache[tId].time) > 0.2 then
                    local isHidden = true
                    pcall(function() if pc:LineOfSightTo(target) then isHidden = false end end)
                    _G.AimTouchVisCache[tId] = { hidden = isHidden, time = curTime }
                end
                if _G.AimTouchVisCache[tId].hidden then goto continue end
            end
            
            local tPos = target:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.GetSocketLocation) == "function" then
                    tPos = target:GetSocketLocation(selBoneName)
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.K2_GetActorLocation) == "function" then
                    tPos = target:K2_GetActorLocation()
                    if tPos then
                        if boneIdx == 1 then tPos.Z = tPos.Z + 70
                        elseif boneIdx == 2 then tPos.Z = tPos.Z + 40
                        elseif boneIdx == 3 then tPos.Z = tPos.Z + 20 end
                    end
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then goto continue end
            
            local screen = FVector2D()
            local success = pc:ProjectWorldLocationToScreen(tPos, screen, false)
            if not success or screen.X <= 0 or screen.Y <= 0 then goto continue end
            
            local dx = screen.X - centerX
            local dy = screen.Y - centerY
            local distScreen = math.sqrt(dx*dx + dy*dy)
            
            if distScreen > FOV_RADIUS then goto continue end
            
            local currentScore = distScreen
            if prioMode == 2 then currentScore = player:GetDistanceTo(target)
            elseif prioMode == 3 then currentScore = target.Health or 100
            elseif prioMode == 4 then 
                local hp = target.Health or 100
                local maxhp = target.HealthMax or 100
                if maxhp <= 0 then maxhp = 100 end
                currentScore = hp / maxhp
            end
            
            if currentScore < bestScore then
                bestScore = currentScore
                bestTarget = target
            end
            
            ::continue::
        end
        
        if not slua.isValid(bestTarget) then return end
        
        local finalBonePos = bestTarget:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
            if type(bestTarget.GetSocketLocation) == "function" then
                finalBonePos = bestTarget:GetSocketLocation(selBoneName)
            end
        end
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
            if type(bestTarget.K2_GetActorLocation) == "function" then
                finalBonePos = bestTarget:K2_GetActorLocation()
                if finalBonePos then
                    if boneIdx == 1 then finalBonePos.Z = finalBonePos.Z + 70
                    elseif boneIdx == 2 then finalBonePos.Z = finalBonePos.Z + 40
                    elseif boneIdx == 3 then finalBonePos.Z = finalBonePos.Z + 20 end
                end
            end
        end
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then return end
        
        if predVal > 0 then
            pcall(function()
                local tVelocity = nil
                if type(bestTarget.GetVelocity) == "function" then
                    tVelocity = bestTarget:GetVelocity()
                end
                
                if tVelocity and (tVelocity.X ~= 0 or tVelocity.Y ~= 0) then
                    local distToEnemy = player:GetDistanceTo(bestTarget) / 100.0
                    local ToF = (distToEnemy / 800.0) * (predVal / 50.0) 
                    finalBonePos.X = finalBonePos.X + (tVelocity.X * ToF)
                    finalBonePos.Y = finalBonePos.Y + (tVelocity.Y * ToF)
                end
            end)
        end

        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, finalBonePos)
        if not rot then return end
        
        local currentRot = pc:GetControlRotation()
        if not currentRot then return end
        
        local deltaYaw = rot.Yaw - currentRot.Yaw
        local deltaPitch = rot.Pitch - currentRot.Pitch
        
        if isADS then
            local camRot = nil
            if type(camManager.GetCameraRotation) == "function" then
                camRot = camManager:GetCameraRotation()
            end
            if camRot then
                deltaYaw = deltaYaw - (camRot.Yaw - currentRot.Yaw)
                deltaPitch = deltaPitch - (camRot.Pitch - currentRot.Pitch)
            end
        end

        if deltaYaw > 180 then deltaYaw = deltaYaw - 360 end
        if deltaYaw < -180 then deltaYaw = deltaYaw + 360 end
        if deltaPitch > 180 then deltaPitch = deltaPitch - 360 end
        if deltaPitch < -180 then deltaPitch = deltaPitch + 360 end
        
        local smoothFactor = 0.0
        if speedVal >= 100 then
            smoothFactor = 1.0
        else
            smoothFactor = (speedVal / 100.0) * 0.3
            if smoothFactor < 0.01 then smoothFactor = 0.01 end
        end
        
        local finalPitch = currentRot.Pitch + (deltaPitch * smoothFactor)
        local finalYaw = currentRot.Yaw + (deltaYaw * smoothFactor)
        
        if recoilCompVal > 0 and isFiring then
            local pullDownForce = (recoilCompVal / 50.0) * 1.5
            finalPitch = finalPitch - pullDownForce
        end

        local finalRot = { Pitch = finalPitch, Yaw = finalYaw, Roll = 0 }
        pc:SetControlRotation(finalRot, "AimTouch")
        
        if isShotgun then
            pcall(function()
                local distToTarget = player:GetDistanceTo(bestTarget) / 100
                if distToTarget <= maxDistMeters then
                    player.bIsWeaponFiring = true
                    if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(true) end
                    if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(true) end
                    local wepMgr = player.WeaponManagerComponent
                    if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = true end
                    
                    local currentWep = player:GetCurrentWeapon()
                    if slua.isValid(currentWep) and type(currentWep.StartFire) == "function" then 
                        currentWep:StartFire() 
                    end
                    _G.PGState.IsAutoFiring = true
                end
            end)
        end

    end)
end

-- ========================================== 
-- MAIN LOOP: EXTREMELY POWERFUL OPTIMIZED
-- ========================================== 
local function MainLoop() 
    if isExpired then return end

    if _G.PGState.CustomTextData == nil then 
        -- Sirf actually-used fields (aimbot ab unified logic mein hardcoded presets use karta hai)
        _G.PGState.CustomTextData = {OuterSpeed = 10, InnerSpeed = 10, HRecoil = 0.3, VRecoil = 0.3, IpadViewFOV = 120}
    end

    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData") 
    if not okData or not GameplayData then return end 
    local pc = GameplayData.GetPlayerController() 
    local localPlayer = nil
    if Valid(pc) then localPlayer = pc:GetPlayerCharacterSafety() end 

    if not Valid(localPlayer) then 
        if _G.PGState.TrackedMarks then
            for markId, _ in pairs(_G.PGState.TrackedMarks) do
                SafeRemoveMark(markId)
            end
        end
        _G.PGState.TrackedMarks = {} 
        
        for key, data in pairs(_G.PGState.EnemyMarks) do
            if data and data.MIDs then
                for meshStr, midTable in pairs(data.MIDs) do
                    for k, _ in pairs(midTable) do midTable[k] = nil end
                end
                data.MIDs = nil
            end
        end
        
        _G.PGState.EnemyMarks = {}
        _G.AK_OrigHitboxes = {}
        _G.AK_ModdedPhysAssets = {}
        _G.PGState.PrevGraphicsState = {}
        return 
    end

    local Cached_PPM = nil
    pcall(function() Cached_PPM = import("PostProcessManager").GetInstance() end)
    local Cached_SecurityCommonUtils = nil
    pcall(function() Cached_SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils") end)
    local Cached_MyHUD = pc and pc.MyHUD or nil

    if _G.PGConfig.UnlockFPS then InitializeGraphicsUnlock() end
    InitializeNativeESP()
    ShowGTLMODVIPMenu()
    
    if _G.PGConfig.IpadView and _G.PGState.CustomTextData then
        pcall(function()
            local targetTPP = _G.PGState.CustomTextData.IpadViewFOV or 120
            local uTPPCam = localPlayer.ThirdPersonCameraComponent
            if Valid(uTPPCam) and not localPlayer.bIsWeaponAiming then
                if uTPPCam.FieldOfView ~= targetTPP then uTPPCam.FieldOfView = targetTPP end
            end
        end)
    else
        pcall(function()
            local uTPPCam = localPlayer.ThirdPersonCameraComponent
            if Valid(uTPPCam) and not localPlayer.bIsWeaponAiming then
                if uTPPCam.FieldOfView ~= 80 then uTPPCam.FieldOfView = 80 end
            end
        end)
    end

    -- ========================================== 
    -- SKIN MOD LOOP + KILL COUNTER + DEADBOX
    -- ========================================== 
    if _G.PGConfig.ModSkin then
        if not _G.TDSkinLoopStarted then
            if _G.InitializeSkinModSystem then _G.InitializeSkinModSystem() end
            if _G.ForceRefreshSkinMaps then _G.ForceRefreshSkinMaps() end
            _G.TDSkinLoopStarted = true
            -- Aktifkan Kill Counter & Effect
            if not _G.KillInfoCounterHacked and _G.ForceEnableKillCounterUI then _G.ForceEnableKillCounterUI() end
        end
        
        _G.PGState.SkinWasApplied = true
        local curTime = os.clock()
        if not _G.LastSkinUpdateTime or (curTime - _G.LastSkinUpdateTime) > 1.5 then
            _G.LastSkinUpdateTime = curTime
            pcall(function()
                local isAlive = type(localPlayer.IsAlive) == "function" and localPlayer:IsAlive() or true
                if isAlive then
                    if _G.ReadLiveConfig then _G.ReadLiveConfig() end
                    if _G.equip_character_avatar then _G.equip_character_avatar(localPlayer) end
                    if _G.ApplyWeaponSkins then _G.ApplyWeaponSkins(localPlayer) end
                    if _G.ApplyVehicleSkins then _G.ApplyVehicleSkins(localPlayer) end
                    if _G.HandlePetLogic then _G.HandlePetLogic() end
                    -- DeadBox skin
                    if _G.DeadBox_TemperRequest and _G.NeedCheckDeadBoxTimer > 0 then _G.DeadBox_TemperRequest(pc) end
                end
            end)
        end
    else
        if _G.PGState.SkinWasApplied then
            _G.OutfitMap = {}
            _G.WeaponSkinMap = {}
            _G.VehicleSkinMap = {}
            pcall(function()
                local WeaponManager = localPlayer:GetWeaponManager()
                if Valid(WeaponManager) then
                    for slot = 1, 3 do
                        local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
                        if Valid(Weapon) and Valid(Weapon.synData) then
                            local WeaponID = Weapon:GetWeaponID()
                            local SkinData = Weapon.synData:Get(7)
                            if SkinData and SkinData.defineID then
                                SkinData.defineID.TypeSpecificID = WeaponID
                                Weapon.synData:Set(7, SkinData)
                                if Weapon.SetWeaponAvatarID then pcall(function() Weapon:SetWeaponAvatarID(WeaponID) end) end
                                if Weapon.DelayHandleAvatarMeshChanged then pcall(function() Weapon:DelayHandleAvatarMeshChanged() end) end
                            end
                        end
                    end
                end
                local Vehicle = localPlayer:GetCurrentVehicle()
                if Valid(Vehicle) then
                    local VehicleAvatar = Vehicle.VehicleAvatar or Vehicle.VehicleAvatarComponent_BP or Vehicle:GetAvatarComponent()
                    if Valid(VehicleAvatar) and type(VehicleAvatar.GetDefaultAvatarID) == "function" then
                        local defId = VehicleAvatar:GetDefaultAvatarID()
                        if VehicleAvatar.ChangeItemAvatar then VehicleAvatar:ChangeItemAvatar(defId, true) end
                    end
                end
                if localPlayer.AvatarComponent2 and type(localPlayer.AvatarComponent2.OnRep_BodySlotStateChanged) == "function" then
                    localPlayer.AvatarComponent2:OnRep_BodySlotStateChanged()
                end
            end)
            _G.PGState.SkinWasApplied = false
        end
        _G.TDSkinLoopStarted = false
    end

    -- ========================================== 
    -- Aimbot Force dipindahkan ke loop terpisah
    -- ========================================== 

    pcall(function()
        if _G.PGConfig.CustomAimbot and localPlayer.bIsWeaponFiring and localPlayer.bIsGunADS then
            local outerRecoilVal = _G.PGState.CustomTextData.OuterRecoil or 0
            if outerRecoilVal > 0 then
                local curTime = os.clock()
                
                if not _G.RecoilTargetCacheTime or (curTime - _G.RecoilTargetCacheTime) > 0.2 then
                    _G.RecoilTargetCacheTime = curTime
                    _G.HasRecoilTargetCached = false
                    
                    local ui_util = require("client.common.ui_util")
                    if ui_util then
                        local viewportSize = ui_util.GetViewportSize()
                        if viewportSize then
                            local centerX = viewportSize.X * 0.5
                            local centerY = viewportSize.Y * 0.5
                            local FOV_RADIUS = (6 / 100.0) * (viewportSize.X / 2.0) 
                            
                            local enemies = _G.GetEnemyTargetsFromActors(40000) 
                            if enemies and #enemies > 0 then
                                local FVector2D = import("Vector2D")
                                for _, target in ipairs(enemies) do
                                    if slua.isValid(target) and target.HealthStatus ~= 1 then 
                                        local tPos = type(target.K2_GetActorLocation) == "function" and target:K2_GetActorLocation() or nil
                                        if tPos then
                                            local screen = FVector2D()
                                            if pc:ProjectWorldLocationToScreen(tPos, screen, false) and screen.X > 0 and screen.Y > 0 then
                                                local dx = screen.X - centerX
                                                local dy = screen.Y - centerY
                                                if math.sqrt(dx*dx + dy*dy) <= FOV_RADIUS then
                                                    _G.HasRecoilTargetCached = true
                                                    break 
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if _G.HasRecoilTargetCached then
                    local currentRot = pc:GetControlRotation()
                    if currentRot then
                        local pullDownForce = (outerRecoilVal / 50.0) * 1.5
                        currentRot.Pitch = currentRot.Pitch - pullDownForce
                        pc:SetControlRotation(currentRot, "CustomAimbotRecoil")
                    end
                end
            end
        else
            _G.HasRecoilTargetCached = false
        end
    end)

    pcall(function()
        if Valid(pc) then
            if pc.HiggsBoson then pc.HiggsBoson.bMHActive = false; pc.HiggsBoson.bCallPreReplication = false end
            if pc.HiggsBosonComponent then pc.HiggsBosonComponent.bMHActive = false; pc.HiggsBosonComponent.bCallPreReplication = false end
        end
    end)

    pcall(function()
        local autoComp = localPlayer.AutoAimComp
        if Valid(autoComp) then
            if not _G.PGState.OrigAutoAimCompCached then
                _G.PGState.OrigAutoAimCompCached = {
                    bOnlyHitHead = autoComp.bOnlyHitHead,
                    HeadBoneName = autoComp.HeadBoneName,
                    Bones = autoComp.Bones,
                    ChestBoneName = autoComp.ChestBoneName,
                    PelvisBoneName = autoComp.PelvisBoneName,
                    HeadPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.HeadPriority,
                    ChestPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.ChestPriority,
                    PelvisPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.PelvisPriority
                }
            end
            
            if _G.PGConfig.AutoHead then
                autoComp.bOnlyHitHead = true
                autoComp.HeadBoneName = "Head"
                pcall(function() autoComp.Bones = {"Head"} end)
                autoComp.ChestBoneName = "Head"
                autoComp.PelvisBoneName = "Head"
                if autoComp.AimAssistConfig then
                    autoComp.AimAssistConfig.HeadPriority = 100
                    autoComp.AimAssistConfig.ChestPriority = 100
                    autoComp.AimAssistConfig.PelvisPriority = 100
                end
            else
                local orig = _G.PGState.OrigAutoAimCompCached
                autoComp.bOnlyHitHead = orig.bOnlyHitHead
                autoComp.HeadBoneName = orig.HeadBoneName
                pcall(function() autoComp.Bones = orig.Bones or {"Spine_01", "Pelvis", "Head"} end)
                autoComp.ChestBoneName = orig.ChestBoneName
                autoComp.PelvisBoneName = orig.PelvisBoneName
                if autoComp.AimAssistConfig then
                    autoComp.AimAssistConfig.HeadPriority = orig.HeadPriority or 1
                    autoComp.AimAssistConfig.ChestPriority = orig.ChestPriority or 1
                    autoComp.AimAssistConfig.PelvisPriority = orig.PelvisPriority or 1
                end
            end
        end
    end)

    -- ========================================== 
    -- REMOVED WALL CLIMB AND FAST CAR LOGIC 
    -- ==========================================

    local now = os.clock()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if _G.PGConfig.RemoveGrass and not _G.PGState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("grass.DensityScale", "0")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
                _G.PGState.PrevGraphicsState.RemoveGrass = true
            elseif not _G.PGConfig.RemoveGrass and _G.PGState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("grass.DensityScale", "1")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "0")
                _G.PGState.PrevGraphicsState.RemoveGrass = false
            end
            
            if _G.PGConfig.RemoveFog and not _G.PGState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1") 
                gi:ExecuteCMD("r.Fog", "0")           
                gi:ExecuteCMD("r.VolumetricFog", "0") 
                _G.PGState.PrevGraphicsState.RemoveFog = true
            elseif not _G.PGConfig.RemoveFog and _G.PGState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1") 
                gi:ExecuteCMD("r.Fog", "1")           
                gi:ExecuteCMD("r.VolumetricFog", "1") 
                _G.PGState.PrevGraphicsState.RemoveFog = false
            end
            
            if _G.PGConfig.WhiteBody and not _G.PGState.PrevGraphicsState.WhiteBody then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "2")
                gi:ExecuteCMD("r.CharacterDiffusePower", "5")
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "100")
                _G.PGState.PrevGraphicsState.WhiteBody = true
            elseif not _G.PGConfig.WhiteBody and _G.PGState.PrevGraphicsState.WhiteBody then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
                gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "1")
                _G.PGState.PrevGraphicsState.WhiteBody = false
            end
            
            if _G.PGConfig.ColorBodyV2 and not _G.PGState.PrevGraphicsState.ColorBodyV2 then
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "4")
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "200")
                gi:ExecuteCMD("r.CharacterDiffusePower", "200")
                _G.PGState.PrevGraphicsState.ColorBodyV2 = true
            elseif not _G.PGConfig.ColorBodyV2 and _G.PGState.PrevGraphicsState.ColorBodyV2 then
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "1")
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
                gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                _G.PGState.PrevGraphicsState.ColorBodyV2 = false
            end
            
            if _G.PGConfig.BlackSky and not _G.PGState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
                _G.PGState.PrevGraphicsState.BlackSky = true
            elseif not _G.PGConfig.BlackSky and _G.PGState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0000")
                _G.PGState.PrevGraphicsState.BlackSky = false
            end
        end
    end)

    pcall(function()
        local weapon = nil
        pcall(function()
            local weaponManager = localPlayer.WeaponManagerComponent
            if Valid(weaponManager) and type(weaponManager.GetCurrentWeapon) == "function" then
                weapon = weaponManager:GetCurrentWeapon()
            end
        end)
        if not Valid(weapon) then
            if type(localPlayer.GetCurrentShootWeapon) == "function" then weapon = localPlayer:GetCurrentShootWeapon()
            elseif type(localPlayer.GetCurrentWeapon) == "function" then weapon = localPlayer:GetCurrentWeapon() end
        end

        if Valid(weapon) then
            local entities = {}
            if Valid(weapon.ShootWeaponEntity_GEN_VARIABLE) then table.insert(entities, weapon.ShootWeaponEntity_GEN_VARIABLE) end
            if Valid(weapon.ShootWeaponEntity) then table.insert(entities, weapon.ShootWeaponEntity) end
            if Valid(weapon.ShootWeaponComponent) and Valid(weapon.ShootWeaponComponent.ShootWeaponEntityComponent) then 
                table.insert(entities, weapon.ShootWeaponComponent.ShootWeaponEntityComponent) 
            end

            for _, entity in ipairs(entities) do
                local anyWeaponModOn = _G.PGConfig.CustomHRecoil or _G.PGConfig.CustomVRecoil or _G.PGConfig.LessShake or _G.PGConfig.Accuracy or _G.PGConfig.Crosshair or _G.PGConfig.GodMode or _G.PGConfig.AutoHead or _G.PGConfig.CustomAimbot or _G.PGConfig.CustomAimbotClose

                if anyWeaponModOn then
                    if not entity.OriginalStatsCached then
                        entity.OriginalStatsCached = {
                            GameDeviationFactor = entity.GameDeviationFactor,
                            GameDeviationAccuracy = entity.GameDeviationAccuracy,
                            BulletFireSpeed = entity.BulletFireSpeed,
                            ShootInterval = entity.ShootInterval,
                            BaseDamage = entity.BaseDamage,
                            AccessoriesHRecoilFactor = entity.AccessoriesHRecoilFactor,
                            AccessoriesVRecoilFactor = entity.AccessoriesVRecoilFactor,
                            RecoilKick = entity.RecoilKick,
                            RecoilKickADS = entity.RecoilKickADS,
                            AnimationKick = entity.AnimationKick
                        }
                    end
                    
                    if _G.PGConfig.CustomHRecoil then entity.AccessoriesHRecoilFactor = _G.PGState.CustomTextData.HRecoil or 0.3 
                    elseif _G.PGConfig.LessRecoil then entity.AccessoriesHRecoilFactor = 0.3 end
                    
                    if _G.PGConfig.CustomVRecoil then entity.AccessoriesVRecoilFactor = _G.PGState.CustomTextData.VRecoil or 0.3
                    elseif _G.PGConfig.VerticalRecoil then entity.AccessoriesVRecoilFactor = 0.3 end
                    
                    if _G.PGConfig.LessShake then entity.RecoilKickADS = 0.0; entity.RecoilKickADS = 0.0; entity.RecoilKickADS = 0.0 end
                    if _G.PGConfig.Accuracy then entity.GameDeviationAccuracy = 0.0 end
                    if _G.PGConfig.Crosshair then entity.GameDeviationFactor = 0.0 end
                    if _G.PGConfig.GodMode then entity.BulletFireSpeed = 500000.0; entity.ShootInterval = 0.001; entity.BaseDamage = 60000.0 end
                    
                    if entity.AutoAimingConfig then
                        if not entity.OriginalAutoAimCached then
                            entity.OriginalAutoAimCached = {
                                OuterSpeed = entity.AutoAimingConfig.OuterRange and entity.AutoAimingConfig.OuterRange.Speed,
                                InnerSpeed = entity.AutoAimingConfig.InnerRange and entity.AutoAimingConfig.InnerRange.Speed
                            }
                        end
                        
                        if _G.PGConfig.AutoHead then
                            pcall(function() entity.AutoAimingConfig.Bones = { "Head", "Head", "Head" } end)
                        end
                        
                        if _G.PGConfig.CustomAimbot then
                            local speed = _G.PGState.CustomTextData.OuterSpeed or 10
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = speed
                                entity.AutoAimingConfig.OuterRange.RangeRate = 1.7
                                entity.AutoAimingConfig.OuterRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.OuterRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.OuterRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.OuterRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.OuterRange.ProneRate = 1.0
                                entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = speed
                                entity.AutoAimingConfig.InnerRange.RangeRate = 1.7
                                entity.AutoAimingConfig.InnerRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.InnerRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.InnerRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.InnerRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.InnerRange.ProneRate = 1.0
                                entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            end
                        elseif _G.PGConfig.CustomAimbotClose then
                            local speed = _G.PGState.CustomTextData.InnerSpeed or 10
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = speed
                                entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = speed
                                entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            end
                        end
                    end
                    
                    entity.GTLMODWeaponModsActive = true

                elseif entity.GTLMODWeaponModsActive then
                    if entity.OriginalStatsCached then
                        local orig = entity.OriginalStatsCached
                        entity.GameDeviationFactor = orig.GameDeviationFactor
                        entity.GameDeviationAccuracy = orig.GameDeviationAccuracy
                        entity.BulletFireSpeed = orig.BulletFireSpeed
                        entity.ShootInterval = orig.ShootInterval
                        entity.BaseDamage = orig.BaseDamage
                        entity.AccessoriesHRecoilFactor = orig.AccessoriesHRecoilFactor
                        entity.AccessoriesVRecoilFactor = orig.AccessoriesVRecoilFactor
                        entity.RecoilKick = orig.RecoilKick
                        entity.RecoilKickADS = orig.RecoilKickADS
                        entity.AnimationKick = orig.AnimationKick
                    end
                    if entity.AutoAimingConfig and entity.OriginalAutoAimCached then
                        pcall(function() entity.AutoAimingConfig.Bones = { "Spine_01", "Pelvis", "Head" } end)
                        if entity.AutoAimingConfig.OuterRange and entity.OriginalAutoAimCached.OuterSpeed then
                            entity.AutoAimingConfig.OuterRange.Speed = entity.OriginalAutoAimCached.OuterSpeed
                        end
                        if entity.AutoAimingConfig.InnerRange and entity.OriginalAutoAimCached.InnerSpeed then
                            entity.AutoAimingConfig.InnerRange.Speed = entity.OriginalAutoAimCached.InnerSpeed
                        end
                    end
                    entity.GTLMODWeaponModsActive = false
                                end
            end
        end
    end)

    -- Magic Bullet logic has been removed from this version
    -- All global magic bullet variables disabled

    pcall(function()
        local allCharacters = {}
        if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end end
        
        local currentValidKeys = {}
        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer then
                currentValidKeys[GetSafeEnemyKey(enemy)] = true
            end
        end
        
        for key, data in pairs(_G.PGState.EnemyMarks) do
            if not currentValidKeys[key] then
                SafeRemoveMark(data.radarMark)
                SafeRemoveMark(data.hpMark)
                SafeRemoveMark(data.distMark)
                
                if _G.AimTouchVisCache and _G.AimTouchVisCache[key] then
                    _G.AimTouchVisCache[key] = nil
                end
                
                if _G.BotStatusCache and _G.BotStatusCache[key] then
                    _G.BotStatusCache[key] = nil
                end
                
                if data.MIDs then
                    for meshStr, midTable in pairs(data.MIDs) do
                        for k, _ in pairs(midTable) do
                            midTable[k] = nil
                        end
                    end
                    data.MIDs = nil
                end
                
                data.enemy = nil
                data.CachedMeshes = nil
                _G.PGState.EnemyMarks[key] = nil
            end
        end

        local realCount = 0
        local aiCount = 0

        local function GetFirstElemSafe(elemArray)
            if elemArray and type(elemArray.Num) == "function" and elemArray:Num() > 0 then
                if type(elemArray.Get) == "function" then return elemArray:Get(0) end
            elseif elemArray and type(elemArray) == "table" and #elemArray > 0 then
                return elemArray[1]
            end
            return nil
        end

        local BoneScaleMap = {
            ["head"] = mHead_Global, ["neck_01"] = mHead_Global,
            ["pelvis"] = mBody_Global, ["spine_01"] = mBody_Global, ["spine_02"] = mBody_Global, ["spine_03"] = mBody_Global,
            ["thigh_l"] = mLegs_Global, ["thigh_r"] = mLegs_Global, 
            ["calf_l"] = mLegs_Global, ["calf_r"] = mLegs_Global,   
            ["foot_l"] = mLegs_Global, ["foot_r"] = mLegs_Global    
        }
        
        local mLoc = nil
        pcall(function() if type(localPlayer.K2_GetActorLocation) == "function" then mLoc = localPlayer:K2_GetActorLocation() end end)

        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= localPlayer.TeamID then
                local bIsReallyDead = false
                pcall(function()
                    if type(enemy.IsDead) == "function" then bIsReallyDead = enemy:IsDead()
                    elseif enemy.bIsDead ~= nil then bIsReallyDead = enemy.bIsDead
                    elseif enemy.bIsDeadFlag ~= nil then bIsReallyDead = enemy.bIsDeadFlag end
                    if enemy.HealthStatus ~= nil and enemy.HealthStatus == 2 then bIsReallyDead = true end
                end)

                local eKey = GetSafeEnemyKey(enemy)
                _G.PGState.EnemyMarks[eKey] = _G.PGState.EnemyMarks[eKey] or { enemy = enemy }
                local markData = _G.PGState.EnemyMarks[eKey]
                markData.enemy = enemy 

                if not bIsReallyDead then
                    if markData.lastEnemyActor ~= enemy then
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.hpMark8 then SafeRemoveMark(markData.hpMark8); markData.hpMark8 = nil end
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                        if markData.radarMark then SafeRemoveMark(markData.radarMark); markData.radarMark = nil end
                        
                        markData.lastEnemyActor = enemy
                        markData.LastUIComp = nil
                        markData.LastFrameUIState = nil
                    end
                    
                    local eMesh = nil
                    pcall(function() eMesh = enemy.Mesh or (type(enemy.getAvatarComponent2) == "function" and enemy:getAvatarComponent2() or nil) end)
                    local aLoc = nil
                    pcall(function() if type(enemy.K2_GetActorLocation) == "function" then aLoc = enemy:K2_GetActorLocation() end end)
                    
                    local isBotResult, isStateLoaded = CheckIsAI(enemy, markData)
                    local isBot = markData.AK_IS_BOT or false

                    local currentMeshCount = 0
                    if Valid(eMesh) then
                        local tempMeshes = GetAllSkeletalMeshes(enemy, markData)
                        currentMeshCount = #tempMeshes
                    end
                    local isMeshChanged = (markData.LastMeshCountWall ~= currentMeshCount)

                    if _G.PGConfig.wallhackng then
                        if isMeshChanged or not markData.WallhackApplied then
                            Applywallhackng(enemy, markData)
                            markData.WallhackApplied = true
                            markData.LastMeshCountWall = currentMeshCount
                        end
                    else
                        Undowallhackng(enemy, markData)
                    end

                    if _G.PGConfig.ColorBodyV2 then 
                        ApplyColorBodyV2(enemy, pc, markData) 
                    else
                        UndoColorBodyV2(enemy, markData)
                    end

                    -- Magic Bullet hitbox modification removed from this version
                    -- Physics asset override functionality disabled

                    local distM = 0
                    pcall(function() distM = localPlayer:GetDistanceTo(enemy) / 100 end)

                    local currentHp, maxHp = 100, 100
                    local showFrameUI = _G.PGConfig.Esp5 or _G.PGConfig.EspVipPro or _G.PGConfig.EspVip
                    
                    if showFrameUI then
                        pcall(function()
                            if enemy.Health then currentHp = enemy.Health elseif type(enemy.GetHealth) == "function" then currentHp = enemy:GetHealth() end
                            if enemy.HealthMax then maxHp = enemy.HealthMax elseif type(enemy.GetHealthMax) == "function" then maxHp = enemy:GetHealthMax() end
                        end)
                        if maxHp <= 0 then maxHp = 100 end
                    end
                    local hpRatio = currentHp / maxHp

                    if _G.PGConfig.EspAntenna then
                        pcall(function()
                            local MyHUD = Cached_MyHUD
                            if Valid(MyHUD) and distM <= 400 then
                                local loopCount = 8  
                                local zStep = 1000     
                                local baseZ = 105     
                                local topZ = baseZ + (loopCount * zStep)
                                for i = 1, loopCount do
                                    local zOffset = baseZ + (i * zStep)
                                    MyHUD:AddDebugText("|", enemy, 0.06,
                                        {X=0, Y=0, Z=zOffset}, {X=0, Y=0, Z=zOffset},
                                        C_GREEN, true, false, true, nil, 1.2, true)
                                end
                                MyHUD:AddDebugText("I", enemy, 0.06,
                                        {X=0, Y=0, Z=topZ + 60}, {X=0, Y=0, Z=topZ + 60},
                                        C_GREEN, true, false, true, nil, 1.5, true)
                            end
                        end)
                    end

                    if _G.PGConfig.Esp6 then
                        pcall(function()
                            local curTime = os.clock()
                            if markData.LastEsp6Time == nil or (curTime - markData.LastEsp6Time) >= 0.05 then
                                markData.LastEsp6Time = curTime
                                
                                local MyHUD = Cached_MyHUD
                                if Valid(MyHUD) and Valid(eMesh) and aLoc then
                                    if distM <= 250 then
                                        if type(eMesh.GetSocketLocation) == "function" then
                                            for _, bName in ipairs(GLOBAL_BONE_LIST) do
                                                
                                                if distM > 50 and (bName ~= "head" and bName ~= "pelvis" and bName ~= "neck_01") then
                                                    -- Skip
                                                else
                                                    local wLoc = eMesh:GetSocketLocation(bName)
                                                    if wLoc then
                                                        local offset = {X = wLoc.X - aLoc.X, Y = wLoc.Y - aLoc.Y, Z = wLoc.Z - aLoc.Z}
                                                        
                                                        local mark = "▪"
                                                        local fixedSize = 0.25 
                                                        local color = C_CYAN
                                                        
                                                        if bName == "head" then 
                                                            mark = "●"
                                                            fixedSize = 0.45
                                                            color = C_RED
                                                        elseif bName == "pelvis" or bName == "neck_01" then 
                                                            mark = "▪"
                                                            fixedSize = 0.35
                                                            color = C_YELLOW 
                                                        end
                                                        
                                                        MyHUD:AddDebugText(mark, enemy, 0.06, offset, offset, color, true, false, true, nil, fixedSize, true)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end

-- ========================================== 
-- ESP COUNTER (ENEMY P: X | B: X)
-- ========================================== 
if _G.PGConfig.Esp7 then
    pcall(function()
        local MyHUD = Cached_MyHUD
        if not Valid(MyHUD) then return end

        local myTeamId = localPlayer.TeamID or localPlayer:GetTeamID() or 0
        local myPos = localPlayer:K2_GetActorLocation()
        local maxDist = 35000
        local maxDistSq = maxDist * maxDist   -- compare squared (no sqrt = faster)
        local realCount = 0
        local aiCount = 0

        -- Bot status cache: ek baar detect, phir yaad rakho (bot kabhi real nahi banta)
        _G.BotStatusCache = _G.BotStatusCache or {}
        local botCache = _G.BotStatusCache

        for _, tPawn in pairs(allCharacters) do
            if slua.isValid(tPawn) and tPawn ~= localPlayer then
                local targetTeamId = tPawn.TeamID or tPawn:GetTeamID() or 0
                if targetTeamId ~= myTeamId then
                    local enemyPos = tPawn:K2_GetActorLocation()
                    if enemyPos then
                        local dx = enemyPos.X - myPos.X
                        local dy = enemyPos.Y - myPos.Y
                        local dz = enemyPos.Z - myPos.Z
                        local distSq = dx*dx + dy*dy + dz*dz
                        if distSq <= maxDistSq then
                            -- Unique ID nikalo caching ke liye
                            local pid = nil
                            if type(tPawn.GetUniqueID) == "function" then
                                local ok, r = pcall(function() return tPawn:GetUniqueID() end)
                                if ok then pid = r end
                            end
                            if not pid then pid = tostring(tPawn) end

                            local isAI = botCache[pid]
                            if isAI == nil then
                                -- Pehli baar: heavy detection chalao (sirf ek baar per pawn)
                                isAI = false
                                -- Method 1: direct actor AI flags
                                if tPawn.bIsAI == true or tPawn.IsAI == true or tPawn.bIsAi == true then
                                    isAI = true
                                end
                                -- Method 2: PUBGM AIData / AIController component (sabse reliable)
                                if not isAI then
                                    if tPawn.AIData ~= nil or tPawn.AIController ~= nil or tPawn.bIsAIActor == true then
                                        isAI = true
                                    end
                                    if not isAI and tPawn.PlayerAIType ~= nil and tPawn.PlayerAIType ~= 0 then
                                        isAI = true
                                    end
                                    if not isAI and type(tPawn.IsAICharacter) == "function" then
                                        local ok, r = pcall(function() return tPawn:IsAICharacter() end)
                                        if ok and r then isAI = true end
                                    end
                                    if not isAI and type(tPawn.GetIsAI) == "function" then
                                        local ok, r = pcall(function() return tPawn:GetIsAI() end)
                                        if ok and r then isAI = true end
                                    end
                                end
                                -- Method 3: PlayerState bot flags + missing UID (bots ke paas asli account UID nahi hota)
                                if not isAI then
                                    local pState = tPawn.PlayerState or (type(tPawn.GetPlayerState) == "function" and tPawn:GetPlayerState())
                                    if slua.isValid(pState) then
                                        if pState.bIsABot == true or pState.bIsBot == true or pState.IsBot == true or pState.bIsAI == true or pState.bIsRobot == true or pState.bIsAiPlayer == true then
                                            isAI = true
                                        end
                                        if not isAI and pState.PlayerAIType ~= nil and pState.PlayerAIType ~= 0 then
                                            isAI = true
                                        end
                                        if not isAI and type(pState.IsABot) == "function" then
                                            local ok, r = pcall(function() return pState:IsABot() end)
                                            if ok and r then isAI = true end
                                        end
                                        -- Bots ka Uid/PlayerId 0 ya nil hota hai (real players ka valid hota hai)
                                        if not isAI then
                                            local uid = pState.Uid or pState.UID or pState.PlayerId or pState.PlayerID
                                            if uid ~= nil and (uid == 0 or uid == "0") then
                                                isAI = true
                                            end
                                        end
                                    end
                                end
                                -- Method 4: function-based checks on pawn
                                if not isAI and type(tPawn.IsBot) == "function" then
                                    local ok, r = pcall(function() return tPawn:IsBot() end)
                                    if ok and r then isAI = true end
                                end
                                if not isAI and type(tPawn.IsAIPlayer) == "function" then
                                    local ok, r = pcall(function() return tPawn:IsAIPlayer() end)
                                    if ok and r then isAI = true end
                                end
                                -- Method 5: AI controller check
                                if not isAI and type(tPawn.GetController) == "function" then
                                    local ok, ctrl = pcall(function() return tPawn:GetController() end)
                                    if ok and slua.isValid(ctrl) then
                                        if ctrl.bIsAI == true or ctrl.IsAI == true or ctrl.AIData ~= nil then isAI = true end
                                        -- AIController class ka naam check
                                        if not isAI and type(ctrl.GetClass) == "function" then
                                            local ok2, cls = pcall(function() return ctrl:GetClass() end)
                                            if ok2 and slua.isValid(cls) and type(cls.GetName) == "function" then
                                                local ok3, cname = pcall(function() return cls:GetName() end)
                                                if ok3 and type(cname) == "string" and (cname:find("AI") or cname:find("Bot")) then
                                                    isAI = true
                                                end
                                            end
                                        end
                                    end
                                end
                                -- Result cache karo (agli baar heavy check nahi chalega)
                                botCache[pid] = isAI
                            end

                            if isAI then
                                aiCount = aiCount + 1
                            else
                                realCount = realCount + 1
                            end
                        end
                    end
                end
            end
        end

        local totalEnemy = realCount + aiCount
        if totalEnemy > 0 then
            local text = string.format("ENEMY : %d | BOT : %d", realCount, aiCount)
            -- ESP Counter: RED color
            MyHUD:AddDebugText(text, localPlayer, 1.2, {X=0, Y=0, Z=150}, {X=0, Y=0, Z=150}, {R=255, G=0, B=0, A=255}, true, false, true, nil, 1.0, true)
            -- Telegram Channel text below counter: CYAN (highlight)
            MyHUD:AddDebugText("✦ WhatsApp +92 [ 03170025278 ]✦", localPlayer, 1.2, {X=0, Y=0, Z=140}, {X=0, Y=0, Z=140}, {R=0, G=255, B=255, A=255}, true, false, true, nil, 0.9, true)
        else
            -- ESP Counter clear message: RED color
            MyHUD:AddDebugText("[ CLEAR AREA ]", localPlayer, 1.2, {X=0, Y=0, Z=150}, {X=0, Y=0, Z=150}, {R=255, G=0, B=0, A=255}, true, false, true, nil, 1.0, true)
            -- Telegram Channel text below: YELLOW (highlight)
            MyHUD:AddDebugText("✦ WhatsApp +92 [ 03170025278 ]✦", localPlayer, 1.2, {X=0, Y=0, Z=140}, {X=0, Y=0, Z=140}, {R=0, G=255, B=255, A=255}, true, false, true, nil, 0.9, true)
        end
    end)
end
                    if showFrameUI then
                        pcall(function()
                            local SecurityCommonUtils = Cached_SecurityCommonUtils
                            local show = true
                            if enemy.HealthStatus and SecurityCommonUtils and SecurityCommonUtils.IsHealthStatusAlive then 
                                if not SecurityCommonUtils.IsHealthStatusAlive(enemy.HealthStatus) then show = false end
                            end
                            if show and mLoc then
                                if aLoc and SecurityCommonUtils and SecurityCommonUtils.IsVector then
                                    if SecurityCommonUtils.IsVector(aLoc) and SecurityCommonUtils.IsVector(mLoc) then
                                        if aLoc.Z >= 150000 or FVector.Dist2D(mLoc, aLoc) > 50000 then show = false end
                                    end
                                end
                            end
                            if show then
                                if enemy.Replay_IsEnemyFrameUIExisted and not enemy:Replay_IsEnemyFrameUIExisted() then enemy:Replay_CreateEnemyFrameUI(true, true) end
                                if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(true) end
                                if enemy.Replay_UpdateEnemyFrameUI then enemy:Replay_UpdateEnemyFrameUI(hpRatio) end
                                
                                local uiComp = enemy.EnemyFrameUI or (type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if markData.LastFrameUIState ~= "VISIBLE" then
                                        if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(0) end
                                        if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(false) end
                                        markData.LastFrameUIState = "VISIBLE"
                                    end
                                end
                            end
                        end)
                    else
                        pcall(function()
                            if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(false) end
                            local uiComp = enemy.EnemyFrameUI or (type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                            if Valid(uiComp) then
                                if markData.LastFrameUIState ~= "HIDDEN" then
                                    if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end
                                    if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                    markData.LastFrameUIState = "HIDDEN"
                                end
                            end
                        end)
                    end

                    -- =================== ESP HEALTH V1 (Warna berdasarkan ColorConfig) ===================
                    if _G.PGConfig.EspVipPro then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if not (Valid(hud) and hud.AddDebugText) then return end
                            if distM > 400 then return end

                            local hp = enemy.Health or 100
                            local maxHp = enemy.HealthMax or 100
                            local isKnock = (hp <= 0 or enemy.HealthStatus == 1)
                            local hpPercent = isKnock and 0 or (hp / maxHp)
                            local pctValue = math.floor(hpPercent * 100 + 0.5)

                            local pName = ""
                            if _G.PGConfig.EspName then
                                pName = enemy.PlayerName or enemy.PlayerNamePublic or "Enemy"
                            end

                            -- Refresh visibility check setiap frame
                            local bIsVisible = false
                            if pc and type(pc.LineOfSightTo) == "function" then
                                bIsVisible = pc:LineOfSightTo(enemy)
                            end

                            -- Ambil warna dari ColorConfig
                            local visibleCol = GetAppliedColor(_G.ColorConfig.VisibleColor or 4, _G.ColorConfig.Brightness)
                            local invisibleCol = GetAppliedColor(_G.ColorConfig.InvisibleColor or 1, _G.ColorConfig.Brightness)
                            
                            local textColor = {R=255, G=255, B=255, A=255}
                            if isKnock then
                                textColor = {R=0, G=0, B=255, A=255}      -- Biru
                            else
                                textColor = bIsVisible and visibleCol or invisibleCol
                            end

                            local prefix = bIsVisible and "▶" or "▶"
                            local label = ""
                            if isKnock then
                                label = (pName ~= "" and string.format("%s [♿]", pName) or "♿")
                            else
                                if pName ~= "" then
                                    label = string.format("%s %s %.0f%%", pName, prefix, pctValue)
                                else
                                    label = string.format("%s %.0f%%", prefix, pctValue)
                                end
                            end

                            hud:AddDebugText(label, enemy, 0.2, {X=0, Y=0, Z=120}, {X=0, Y=0, Z=120},
                                             textColor, true, false, true, nil, 1.0, true)
                        end)
                    end

                    -- =================== ESP RANGE V1 (Jarak dalam meter) ===================
                    if _G.PGConfig.EspDistance then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if not (Valid(hud) and hud.AddDebugText) then return end
                            if distM > 400 then return end

                            local distMeters = math.floor(distM + 0.5)
                            local rangeColor = {R=255, G=255, B=255, A=255} -- putih

                            hud:AddDebugText(string.format("%.0fm", distMeters), enemy, 0.3,
                                             {X=15, Y=15, Z=-15}, {X=15, Y=15, Z=-15},
                                             rangeColor, true, false, true, nil, 0.9, true)
                        end)
                    end

-- =================== ESP NAME V1 (Nama dengan warna dari ColorConfig) ===================
if _G.PGConfig.EspName and not _G.PGConfig.EspVipPro then
    pcall(function()
        local hud = Cached_MyHUD
        if not (Valid(hud) and hud.AddDebugText) then return end
        if distM > 400 then return end

        local pName = enemy.PlayerName or enemy.PlayerNamePublic or "Enemy"
        if pName == "" then return end

        local isKnock = (enemy.Health or 100) <= 0 or enemy.HealthStatus == 1
        local bIsVisible = true
        pcall(function()
            if pc and type(pc.LineOfSightTo) == "function" then
                bIsVisible = pc:LineOfSightTo(enemy)
            end
        end)

        local visibleCol = GetAppliedColor(_G.ColorConfig.VisibleColor or 4, _G.ColorConfig.Brightness)
        local invisibleCol = GetAppliedColor(_G.ColorConfig.InvisibleColor or 1, _G.ColorConfig.Brightness)
        
        local nameColor = {R=255, G=255, B=255, A=255}
        if isKnock then
            nameColor = {R=0, G=0, B=255, A=255}
        else
            nameColor = bIsVisible and visibleCol or invisibleCol
        end

        hud:AddDebugText(pName, enemy, 0.2, {X=0, Y=0, Z=120}, {X=0, Y=0, Z=120},
                         nameColor, true, false, true, nil, 1.0, true)
    end)
end

                    if _G.PGConfig.EspVip then
                        if markData.hpMark == nil then markData.hpMark = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                        if markData.distMark == nil then markData.distMark = SafeAddMark(9999, FVector(0,0,0), 0, "", 4, enemy) end
                    else
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                    end

                    if _G.PGConfig.Esp8 then
                        if markData.hpMark8 == nil then markData.hpMark8 = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                    else
                        if markData.hpMark8 then SafeRemoveMark(markData.hpMark8); markData.hpMark8 = nil end
                    end
                    
                    if _G.PGConfig.EspRadar then
                        if not markData.radarMark or markData.radarMark == 0 then 
                            markData.radarMark = SafeAddMark(8888, FVector(0,0,0), 0, "", 4, enemy) 
                        end
                    else
                        if markData.radarMark and markData.radarMark ~= 0 then
                            SafeRemoveMark(markData.radarMark)
                            markData.radarMark = nil
                        end
                    end
                    
                    if _G.PGConfig.EspOutline then
                        pcall(function()
                            local outlineHash = tostring(_G.PGConfig.OutlineThickness)
                            if markData.OutlineState ~= outlineHash then
                                local PPM = Cached_PPM
                                local avatarComp = (type(enemy.getAvatarComponent2) == "function") and enemy:getAvatarComponent2() or nil
                                if Valid(avatarComp) and Valid(PPM) then
                                    PPM.OutlineThickness = _G.PGConfig.OutlineThickness
                                    if PPM.OutlineColor then PPM.OutlineColor = {r = 1, g = 0, b = 0, a = 1} end
                                    PPM:EnableAvatarOutline(avatarComp, true)
                                    markData.OutlineState = outlineHash
                                end
                            end
                        end)
                    else
                        pcall(function()
                            if markData.OutlineState ~= "OFF" then
                                local PPM = Cached_PPM
                                local avatarComp = (type(enemy.getAvatarComponent2) == "function") and enemy:getAvatarComponent2() or nil
                                if Valid(avatarComp) and Valid(PPM) then PPM:EnableAvatarOutline(avatarComp, false) end
                                markData.OutlineState = "OFF"
                            end
                        end)
                    end

                else
                    if not markData.IsCleanedUp then
                        SafeRemoveMark(markData.radarMark)
                        markData.radarMark = nil
                        SafeRemoveMark(markData.hpMark)
                        markData.hpMark = nil
                        SafeRemoveMark(markData.hpMark8)
                        markData.hpMark8 = nil
                        SafeRemoveMark(markData.distMark)
                        markData.distMark = nil
                        
                        if markData.MIDs then
                            for meshStr, midTable in pairs(markData.MIDs) do
                                for k, _ in pairs(midTable) do midTable[k] = nil end
                            end
                            markData.MIDs = nil
                        end
                        
                        pcall(function()
                            local eObj = markData.enemy
                            if Valid(eObj) then 
                                if eObj.Replay_SetVisiableOfFrameUI then eObj:Replay_SetVisiableOfFrameUI(false) end
                                local uiComp = eObj.EnemyFrameUI or (type(eObj.GetEnemyFrameUI) == "function" and eObj:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end 
                                    if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                end
                            end
                            
                            local PPM = Cached_PPM
                            local avatarComp = Valid(eObj) and (type(eObj.getAvatarComponent2) == "function") and eObj:getAvatarComponent2() or nil
                            if Valid(avatarComp) and Valid(PPM) then PPM:EnableAvatarOutline(avatarComp, false) end
                        end)

                        markData.IsCleanedUp = true
                    end
                end
            end
        end

        -- ========================================== 
        -- ESP TYPE 7: ENEMY COUNTER FORMAT BARU "P: X B: X"
        -- ========================================== 
        if _G.PGConfig.Esp7 then
            pcall(function()
                local MyHUD = Cached_MyHUD
                if Valid(MyHUD) then
                    local text = "[ TELEGRAM @PGHACKS1 ]"
                    MyHUD:AddDebugText(text, localPlayer, 0.06, {X=0, Y=0, Z=0}, {X=0, Y=0, Z=0}, {R=0, G=0, B=255, A=255}, true, false, true, nil, 0.8, true)
                end
            end)
        end
    end)
end

_G.PGState.LoopToken = (_G.PGState.LoopToken or 0) + 1 
local myToken = _G.PGState.LoopToken

-- ========================================== 
-- LOOP UTAMA (ESP & FITUR LAIN) DENGAN 0.2 DETIK
-- ========================================== 
local function FastTick() 
    if isExpired then 
        if not _G.PGNotifiedExpire then
            Notify("MOD HAS EXPIRED! PLEASE CONTACT ADMIN TO RENEW!\nTELEGRAM @PGHACKS1")
            _G.PGNotifiedExpire = true
            ExpiredTick() 
        end
        return 
    end

    if myToken ~= _G.PGState.LoopToken then return end
    pcall(MainLoop) 
    local okTicker, ticker = pcall(require, "common.time_ticker") 
    if okTicker and ticker and ticker.AddTimerOnce then 
        ticker.AddTimerOnce(0.4, FastTick) 
    end 
end

-- ========================================== 
-- LOOP KHUSUS AIMBOT FORCE DENGAN 0.016 DETIK (~60 FPS)
-- ========================================== 
local aimbotToken = 0
local function FastAimbotTick()
    if isExpired then 
        return 
    end

    if aimbotToken ~= _G.PGState.AimbotLoopToken then 
        return 
    end

    pcall(function()
        if _G.PGConfig.AimTouchEnable then
            _G.AimTouch()
        end
    end)

    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.016, FastAimbotTick)
    end
end

-- ========================================== 

-- ===========================
-- ESP V2 SYSTEM
-- ===========================
--  ESP V2 SYSTEM — NEW (esp.lua @SRC_HUB / @XThrlen)
--  Line, Health Bar, Corner Box, Snap Line, Counter — sab naya
-- ==============================================================================
_G.LoadESPV2System = function()
if _G.IsESPV2Loaded then return end
_G.IsESPV2Loaded = true

local ESP_Enabled = true

local FVector2D = _G.FVector2D or import("Vector2D")
local FLinearColor = _G.FLinearColor or import("LinearColor")
local SlateBlueprintLibrary = nil
local WidgetLayoutLibrary = nil
local SlateColor = nil
local GameplayStaticsESP = nil
pcall(function() SlateBlueprintLibrary = import("SlateBlueprintLibrary") end)
pcall(function() WidgetLayoutLibrary = import("WidgetLayoutLibrary") end)
pcall(function() SlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor") end)
pcall(function() GameplayStaticsESP = import("GameplayStatics") end)
local KismetSystemLibraryESP = nil
local HitResultClassESP = nil
pcall(function() KismetSystemLibraryESP = import("KismetSystemLibrary") end)
pcall(function() HitResultClassESP = import("HitResult") end)
local TraceStartPos = { X = 0, Y = 0, Z = 0 }
local CachedHitResult = nil
pcall(function()
  if HitResultClassESP then CachedHitResult = HitResultClassESP()
  else CachedHitResult = {} end
end)

local function ESPValid(obj)
  if obj == nil then return false end
  local ok, v = pcall(function() return slua.isValid(obj) end)
  return ok and v == true
end

local function ESPV2(x, y)
  if FVector2D then return FVector2D(x, y) end
  return { X = x, Y = y }
end

local function ESPMKC(r, g, b, a)
  if FLinearColor then return FLinearColor(r, g, b, a) end
  return { R = r, G = g, B = b, A = a }
end

local CFG = {
  MaxDistance = 40000,      -- cm (400 m)
  MaxTracked = 16,
  ScreenMargin = 220,
  ScreenMarginExtraX = 0.8, -- left/right range +3% of screen width (side enemies)
  TopTextY = 30.0,          -- source match: slot Y=30 from top           -- canvas px, bilkul upar center
  CounterOffsetX = 0,       -- 0 = true center (canvas geometry se auto-detect)
  SnapOriginOffsetX = 0,    -- 0 = true center
  SnapOriginY = 50.0,       -- source match: SnapLineOriginY=50 (50px from top)
  SnapThickness = 1.0,  -- source: PlayerMapMarker.SnapLineThickness = 1.0
  CornerThickness = 2.2,
  CornerLen = 0.28,
  CornerMin = 6,
  CornerMax = 28,
  BoxMinWidth = 8,
  BoxMaxWidth = 320,
  BoxMinHeight = 4,
  BoxWidthFactor = 0.62,
  WidthScale = 1.22,
  HeadExtra = 0.06,
  FootExtra = 0.02,
  SideBarWidth = 3.5,
  SideBarGap = 5.0,
  SideBgAlpha = 0.55,
  MarkGap = 8.0,            -- box top se chevron tak gap
  MarkW = 15.0,             -- ek V ki aadhi chaudai
  MarkH = 10.0,             -- ek V ki unchai
  MarkGapV = 6.0,           -- do V ke beech gap
  MarkThickness = 2.4,
  NameFontSize = 15,
  DistFontSize = 13,
  StateFontSize = 13,
  TextGap = 1.0,
  CounterFontSize = 17,
  CounterW = 300.0,
  CounterH = 28.0,
  DeadZone = 0.5,           -- px, isse kam harkat = slate ko chhuna nahi (flicker fix)
  VisInterval = 0.15,       -- sec, LineTrace itni der me ek bar per target (lag fix)
  SizeHyst = 2.0,           -- px, viewport me itna farq ignore
}

-- esplook.png colors
local C_WHITE  = ESPMKC(1.0, 1.0, 1.0, 1.0)
local C_BLACK  = ESPMKC(0.0, 0.0, 0.0, 1.0)
local C_GREEN  = ESPMKC(0.12, 1.0, 0.25, 1.0)   -- snap line + "Open"
local C_RED    = ESPMKC(1.0, 0.15, 0.15, 1.0)   -- low health + "Close"
local C_YELLOW = ESPMKC(1.0, 0.90, 0.30, 1.0)   -- double chevron
local C_BLUE   = ESPMKC(0.38, 0.72, 1.0, 1.0)   -- "Bot" name

local function RND(v)
  if v ~= v then return 0 end
  return math.floor(v + 0.5)
end

local function Lerp(a, b, t) return a + (b - a) * t end

-- Health color: 100% green | 70% green+halka yellow | 40% red+halka white | 20% red
local function HealthColor(pct)
  pct = tonumber(pct) or 1.0
  if pct < 0 then pct = 0 end
  if pct > 1 then pct = 1 end
  local r, g, b
  if pct >= 0.7 then
    local t = (pct - 0.7) / 0.3
    r = Lerp(0.4, 0.0, t)
    g = 1.0
    b = 0.0
  elseif pct >= 0.4 then
    local t = (pct - 0.4) / 0.3
    r = 1.0
    g = Lerp(0.25, 0.80, t)
    b = 0.0
  else
    local t = pct / 0.4
    r = 1.0
    g = Lerp(0.0, 0.25, t)
    b = 0.0
  end
  return ESPMKC(r, g, b, 1.0)
end

local ESP = {}
ESP.Canvas = nil
ESP.Lines = {}      -- snap lines : key -> {Widget, Slot}
ESP.Corners = {}    -- corner boxes: key -> {w1..w8 Widget/Slot}
ESP.HealthBg = {}     -- health bg (dark) : key -> {Widget, Slot}
ESP.HealthFill = {}   -- health fill (pct + color) : key -> {Widget, Slot}
ESP.HealthBorder = {} -- white stroke around health bar: key -> {Widget, Slot}
ESP.Marks = {}      -- yellow chevron: key -> {4 x Widget/Slot}
ESP.Infos = {}      -- bottom texts: key -> {Container, Name, Dist, State, slots}
ESP.Weapons = {}    -- weapon text above health bar: key -> {Widget, Slot}
ESP.NameLabels = {} -- name above health bar: key -> {Widget, Slot}
-- ============================================================
-- SOURCE-EXACT: RedBoxOverlay (counter) + SnapLine
-- Only changes: slua.isValid→ESPValid, PlayerMapMarker.ESPCanvas→ESP.GetCanvas(),
--               PlayerMapMarker.GetMyPlayerController()→ESP.GetController(),
--               _cachedViewportW→ESP.ViewW, _CanvasScaleX→ESP.ScaleX etc.
-- ============================================================
-- ENEMY TOTAL COUNTER — Yellow single box, top-center (reference screenshot match)
local RedBoxOverlay = {
  bActive = false,
  MainContainer = nil,
  WidgetSlot = nil,
  TotalTextBlock = nil,   -- single combined count text
  BgBorder = nil,         -- background border (for color change)
  Width = 97,
  Height = 32,
  PlayerCount = 0,
  BotCount = 0,
  FontSize = 14,
  _CachedTotalText = "",
  _CachedPosVec = nil
}

function RedBoxOverlay.Create()
  if RedBoxOverlay.MainContainer and ESPValid(RedBoxOverlay.MainContainer) then return true end
  local ParentCanvas = ESP.GetCanvas()
  if not ESPValid(ParentCanvas) then return false end
  local FLinearColor2 = import("LinearColor") or _G.FLinearColor
  local FVector2D2    = import("Vector2D")    or _G.FVector2D
  local FSlateColor2  = import("SlateColor")  or import("/Script/SlateCore.SlateColor")
  local FAnchors2     = import("Anchors")     or import("/Script/SlateCore.Anchors")
  local boxW, boxH = RedBoxOverlay.Width, RedBoxOverlay.Height

  local Container
  pcall(function() Container = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", ParentCanvas) end)
  if not ESPValid(Container) then return false end

  -- Yellow semi-transparent background border
  local bgBorder
  pcall(function() bgBorder = CGame:NewObjectFromPath("/Script/UMG.Border", Container) end)
  if ESPValid(bgBorder) then
    pcall(function()
      -- Yellow, ~50% opacity (reference: transparent yellow)
      bgBorder:SetBrushColor(FLinearColor2(1.0, 1.0, 0.0, 0.60))
      bgBorder:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end)
    local bgSlot = Container:AddChildToCanvas(bgBorder)
    if bgSlot then
      bgSlot:SetPosition(FVector2D2(0, 0))
      bgSlot:SetSize(FVector2D2(boxW, boxH))
      bgSlot:SetZOrder(0)
    end
    RedBoxOverlay.BgBorder = bgBorder
  end

  -- Bold black number, centered
  local totalTxt
  pcall(function() totalTxt = CGame:NewObjectFromPath("/Script/UMG.TextBlock", Container) end)
  if ESPValid(totalTxt) then
    local total = (RedBoxOverlay.PlayerCount or 0) + (RedBoxOverlay.BotCount or 0)
    local s = tostring(total)
    pcall(function()
      totalTxt:SetText(s)
      RedBoxOverlay._CachedTotalText = s
      -- Bold black color
      local black = FLinearColor2(0, 0, 0, 1)
      if FSlateColor2 then totalTxt:SetColorAndOpacity(FSlateColor2(black))
      else totalTxt:SetColorAndOpacity(black) end
      if totalTxt.Font then
        local f = totalTxt.Font
        f.Size = RedBoxOverlay.FontSize
        -- Bold flag (TypefaceFontName = "Bold" if supported)
        pcall(function() f.TypefaceFontName = "Bold" end)
        totalTxt.Font = f
      end
      totalTxt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end)
    local ts = Container:AddChildToCanvas(totalTxt)
    if ts then
      ts:SetAutoSize(true)
      ts:SetAlignment(FVector2D2(0.5, 0.5))
      ts:SetPosition(FVector2D2(boxW * 0.5, boxH * 0.5))
      ts:SetZOrder(1000)
    end
    RedBoxOverlay.TotalTextBlock = totalTxt
  end

  local MainSlot
  pcall(function() MainSlot = ParentCanvas:AddChildToCanvas(Container) end)
  if not MainSlot then return false end
  RedBoxOverlay.MainContainer = Container
  RedBoxOverlay.WidgetSlot    = MainSlot
  pcall(function()
    MainSlot:SetAutoSize(false)
    MainSlot:SetZOrder(999)
    if FAnchors2 then MainSlot:SetAnchors(FAnchors2(0, 0, 0, 0)) end
    MainSlot:SetAlignment(FVector2D2(0, 0))
    MainSlot:SetSize(FVector2D2(boxW, boxH))
  end)
  RedBoxOverlay.UpdatePosition()
  return true
end

function RedBoxOverlay.SetCounts(players, bots)
  if RedBoxOverlay.PlayerCount == players and RedBoxOverlay.BotCount == bots then return end
  RedBoxOverlay.PlayerCount = players or 0
  RedBoxOverlay.BotCount    = bots or 0
  pcall(function()
    local total = RedBoxOverlay.PlayerCount + RedBoxOverlay.BotCount
    local isClear = (total == 0)
    local s = isClear and "CLEAR" or tostring(total)
    -- Text update
    if ESPValid(RedBoxOverlay.TotalTextBlock) then
      if RedBoxOverlay._CachedTotalText ~= s then
        RedBoxOverlay.TotalTextBlock:SetText(s)
        RedBoxOverlay._CachedTotalText = s
      end
    end
    -- Box color: CLEAR=Green, enemies=Yellow
    if ESPValid(RedBoxOverlay.BgBorder) then
      local LC = import("LinearColor") or _G.FLinearColor
      if isClear then
        RedBoxOverlay.BgBorder:SetBrushColor(LC(0.0, 1.0, 0.0, 0.60))  -- Green
      else
        RedBoxOverlay.BgBorder:SetBrushColor(LC(1.0, 1.0, 0.0, 0.60))  -- Yellow
      end
    end
  end)
end

function RedBoxOverlay.UpdatePosition()
  local Slot = RedBoxOverlay.WidgetSlot
  if not Slot or not ESPValid(Slot) then return end
  local Container = RedBoxOverlay.MainContainer
  if not Container or not ESPValid(Container) then return end
  local realH = RedBoxOverlay.Height or 32
  -- Screen center: SAME method as working Snap Line (SL_GetStartPos):
  -- viewport pixel width / 2  ->  canvas local via ESP.ScaleX + ESP.OffsetX
  local PC = ESP.GetController()
  local screenPixelW = 0
  local scale = 1.0
  pcall(function()
    if PC and PC.GetViewportSize then
      local vs = ESPV2(0, 0)
      PC:GetViewportSize(vs)
      if vs and vs.X and vs.X > 200 then screenPixelW = vs.X end
    end
  end)
  if screenPixelW <= 200 then
    pcall(function()
      local WLL = WidgetLayoutLibrary
      if WLL and WLL.GetViewportSize then
        local vs = WLL.GetViewportSize(PC)
        if vs and vs.X and vs.X > 200 then screenPixelW = vs.X end
      end
    end)
  end
  pcall(function()
    local WLL = WidgetLayoutLibrary
    if WLL and WLL.GetViewportScale then
      local s = WLL.GetViewportScale(PC)
      if s and type(s) == "number" and 0 < s then scale = s end
    end
  end)
  if screenPixelW <= 200 then screenPixelW = 1920 * scale end
  local centerX = (screenPixelW / 2.0) * (ESP.ScaleX or 1.0) + (ESP.OffsetX or 0)
  local realW = RedBoxOverlay.Width or 162
  pcall(function()
    local cg = Container:GetCachedGeometry()
    if cg and cg.GetLocalSize then
      local sz = cg:GetLocalSize()
      if sz and sz.X and sz.X > 10 then realW = sz.X end
    end
  end)
  local targetX = centerX - realW * 0.5
  local targetY = 25
  -- Use ESPV2 (always valid FVector2D) — plain Lua tables fail SetPosition
  if not RedBoxOverlay._CachedPosVec then
    RedBoxOverlay._CachedPosVec  = ESPV2(targetX, targetY)
    RedBoxOverlay._CachedSizeVec = ESPV2(realW,   realH)
  else
    RedBoxOverlay._CachedPosVec.X  = targetX
    RedBoxOverlay._CachedPosVec.Y  = targetY
    RedBoxOverlay._CachedSizeVec.X = realW
    RedBoxOverlay._CachedSizeVec.Y = realH
  end
  pcall(function()
    Slot:SetPosition(RedBoxOverlay._CachedPosVec)
    Slot:SetSize(RedBoxOverlay._CachedSizeVec)
  end)
end

function RedBoxOverlay.Start()
  if RedBoxOverlay.bActive and ESPValid(RedBoxOverlay.MainContainer) then return end
  if RedBoxOverlay.Create() then
    RedBoxOverlay.bActive = true
    RedBoxOverlay.UpdatePosition()
    pcall(function() RedBoxOverlay.MainContainer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
  end
end

function RedBoxOverlay.Stop()
  RedBoxOverlay.bActive = false
  if ESPValid(RedBoxOverlay.MainContainer) then
    pcall(function() RedBoxOverlay.MainContainer:RemoveFromParent() RedBoxOverlay.MainContainer:ConditionalBeginDestroy() end)
  end
  RedBoxOverlay.MainContainer = nil; RedBoxOverlay.WidgetSlot = nil
  RedBoxOverlay.TotalTextBlock = nil; RedBoxOverlay.BgBorder = nil
  RedBoxOverlay._CachedPosVec = nil; RedBoxOverlay._CachedSizeVec = nil
end

-- SnapLine source-exact
local SnapLineWidgets = {}
local bUseSnapLines   = false
local SnapLineThickness   = 1.2
local SnapLineOriginY     = 0
local SnapLineOriginOffsetX = 0
local SnapLineHeadOffsetY = -14

local function SL_GetCanvas() return ESP.GetCanvas() end

local function SL_CreateSnapLine(color)
  local canvas = SL_GetCanvas()
  if not ESPValid(canvas) then return nil end
  local Border
  pcall(function() Border = CGame:NewObjectFromPath("/Script/UMG.Border", canvas) end)
  if not ESPValid(Border) then return nil end
  pcall(function()
    Border:SetBrushColor(color or ESPMKC(1,1,1,0.9))
    Border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end)
  pcall(function() Border.RenderTransformPivot = ESPV2(0.0,0.5) end)
  pcall(function() Border:SetRenderTransformPivot(ESPV2(0.0,0.5)) end)
  local Slot
  pcall(function()
    Slot = canvas:AddChildToCanvas(Border)
    if Slot then Slot:SetAutoSize(false) Slot:SetZOrder(1) end
  end)
  return {Widget=Border, Slot=Slot}
end

-- ===== SOURCE-EXACT (BRPlayerCharacterBase PlayerMapMarker.GetSnapLineStartPos) =====
local _SL_TopCenterPixel = nil
local function SL_GetStartPos(PC, viewW)
  local screenPixelW, screenPixelH = 0, 0
  local scale = 1.0
  pcall(function()
    if PC and PC.GetViewportSize then
      local vs = ESPV2(0, 0)
      PC:GetViewportSize(vs)
      if vs and vs.X and vs.X > 200 then
        screenPixelW = vs.X
        screenPixelH = vs.Y
      end
    end
  end)
  if screenPixelW <= 200 then
    pcall(function()
      local WLL = WidgetLayoutLibrary
      if WLL and WLL.GetViewportSize then
        local vs = WLL.GetViewportSize(PC)
        if vs and vs.X and vs.X > 200 then
          screenPixelW = vs.X
          screenPixelH = vs.Y
        end
      end
    end)
  end
  pcall(function()
    local WLL = WidgetLayoutLibrary
    if WLL and WLL.GetViewportScale then
      local s = WLL.GetViewportScale(PC)
      if s and type(s) == "number" and 0 < s then scale = s end
    end
  end)
  if screenPixelW <= 200 then
    screenPixelW = 1920 * scale
    screenPixelH = 1080 * scale
  end
  if not _SL_TopCenterPixel then _SL_TopCenterPixel = ESPV2(0, 0) end
  _SL_TopCenterPixel.X = screenPixelW / 2.0
  _SL_TopCenterPixel.Y = (SnapLineOriginY or 50) * scale
  -- ScreenPixelToCanvasLocal (source): px * CanvasScale + CanvasOffset
  local fromX = _SL_TopCenterPixel.X * (ESP.ScaleX or 1.0) + (ESP.OffsetX or 0) + (SnapLineOriginOffsetX or 0)
  local fromY = _SL_TopCenterPixel.Y * (ESP.ScaleY or 1.0) + (ESP.OffsetY or 0)
  return fromX, fromY
end

local function SL_UpdateSnapLine(key, canvasPos, bOnScreen, fromX, fromY, isBot, pc)
  if not bUseSnapLines then return end
  local LineData = SnapLineWidgets[key]
  if not bOnScreen or not canvasPos then
    if LineData and ESPValid(LineData.Widget) then
      pcall(function() LineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
    end
    return
  end
  if not LineData then
    -- Bot=Purple, Real=Red (source: visible=green, hidden=red; we use bot/real distinction)
    local c = isBot and ESPMKC(0.63,0,1,0.85) or ESPMKC(1,0,0,0.85)
    LineData = SL_CreateSnapLine(c)
    if not LineData or not LineData.Widget or not LineData.Slot then return end
    SnapLineWidgets[key] = LineData
  end
  local Widget = LineData.Widget
  local Slot   = LineData.Slot
  -- color: Bot=Purple, Real=Red (always update)
  local lineColor = isBot and ESPMKC(0.63,0,1,0.85) or ESPMKC(1,0,0,0.85)
  pcall(function() Widget:SetBrushColor(lineColor) end)
  pcall(function() Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
  if not LineData._PivotSet then
    pcall(function() Widget.RenderTransformPivot = ESPV2(0,0.5) end)
    pcall(function() Widget:SetRenderTransformPivot(ESPV2(0,0.5)) end)
    LineData._PivotSet = true
  end
  local toX = canvasPos.X
  local toY = canvasPos.Y + SnapLineHeadOffsetY
  local dx = toX - fromX
  local dy = toY - fromY
  local length = math.sqrt(dx*dx + dy*dy)
  local thickness = SnapLineThickness or 1.2
  local angle_rad = math.atan2 and math.atan2(dy,dx) or math.atan(dy,dx)
  local angle = angle_rad * (180.0 / math.pi)
  if not LineData._CachedPosVec then
    LineData._CachedPosVec  = ESPV2(fromX, fromY - thickness*0.5)
    LineData._CachedSizeVec = ESPV2(length, thickness)
  else
    LineData._CachedPosVec.X  = fromX; LineData._CachedPosVec.Y  = fromY - thickness*0.5
    LineData._CachedSizeVec.X = length; LineData._CachedSizeVec.Y = thickness
  end
  pcall(function()
    Slot:SetPosition(LineData._CachedPosVec)
    Slot:SetSize(LineData._CachedSizeVec)
  end)
  pcall(function() Widget:SetRenderAngle(angle) end)
end

local function SL_RemoveSnapLine(key)
  local ld = SnapLineWidgets[key]
  if ld and ESPValid(ld.Widget) then
    pcall(function() ld.Widget:RemoveFromParent() ld.Widget:ConditionalBeginDestroy() end)
  end
  SnapLineWidgets[key] = nil
end

local function SL_ClearAll()
  for k, ld in pairs(SnapLineWidgets) do
    if ld and ESPValid(ld.Widget) then
      pcall(function() ld.Widget:RemoveFromParent() ld.Widget:ConditionalBeginDestroy() end)
    end
  end
  SnapLineWidgets = {}
end
ESP.EnemyCache = {}
ESP.VisCache = {}   -- visibility cache: key -> {b, t}
ESP.ScaleX = 1.0
ESP.ScaleY = 1.0
ESP.OffsetX = 0.0
ESP.OffsetY = 0.0
ESP.ViewW = 1920
ESP.ViewH = 1080
ESP.ScanInterval = 0.35
ESP.LightInterval = 0.033
ESP.TransformInterval = 0.50
ESP.LastScan = -999.0
ESP.LastTransform = -999.0
ESP.LastWorld = nil
ESP.bActive = false

function ESP.GetGameplayData()
  if ESP._GDP then return ESP._GDP end
  local ok, GDP = pcall(function() return require("GameLua.GameCore.Data.GameplayData") end)
  if ok and GDP then ESP._GDP = GDP return GDP end
  return nil
end

function ESP.GetController()
  local pc = nil
  pcall(function()
    local GDP = ESP.GetGameplayData()
    if GDP and GDP.GetPlayerController then pc = GDP.GetPlayerController() end
  end)
  if not ESPValid(pc) then
    pcall(function()
      if slua_GameFrontendHUD then pc = slua_GameFrontendHUD:GetPlayerController() end
    end)
  end
  return ESPValid(pc) and pc or nil
end

function ESP.GetLocalCharacter()
  local c = nil
  pcall(function()
    local GDP = ESP.GetGameplayData()
    if GDP then
      if GDP.GetPlayerCharacter then c = GDP.GetPlayerCharacter() end
      if not ESPValid(c) and GDP.GetLocalCharacter then c = GDP.GetLocalCharacter() end
    end
  end)
  if not ESPValid(c) then
    local pc = ESP.GetController()
    pcall(function() if pc and pc.GetPawn then c = pc:GetPawn() end end)
  end
  return ESPValid(c) and c or nil
end

function ESP.GetAllCharacters()
  local AllChars = {}
  pcall(function()
    local Pawns = Game:GetAllPlayerPawns()
    if Pawns then
      for _, Pawn in pairs(Pawns) do
        if Pawn and slua.isValid(Pawn) then
          local pKey = nil
          if Pawn.GetPlayerKey then pcall(function() pKey = Pawn:GetPlayerKey() end) end
          if not pKey and Pawn.PlayerKey then pKey = Pawn.PlayerKey end
          if not pKey and Pawn.PlayerState and Pawn.PlayerState.PlayerKey then pKey = Pawn.PlayerState.PlayerKey end
          if pKey then AllChars[pKey] = Pawn end
        end
      end
    end
  end)
  if not next(AllChars) then
    pcall(function()
      local GS = require("GameLua.GameCore.Data.CGameState")
      if GS and GS.GetAllCharacters then AllChars = GS:GetAllCharacters() end
    end)
  end
  return AllChars
end

function ESP.GetMyPlayerKey()
  local pc = ESP.GetController()
  if not ESPValid(pc) then return nil end
  local k = nil
  pcall(function()
    if pc.GetPlayerKey then k = pc:GetPlayerKey()
    elseif pc.PlayerState and pc.PlayerState.PlayerKey then k = pc.PlayerState.PlayerKey end
  end)
  return k
end

function ESP.IsMe(Character, PlayerKey, MyKey)
  local me = false
  pcall(function()
    local GDP = ESP.GetGameplayData()
    if GDP and GDP.GetLocalCharacter then
      local mc = GDP.GetLocalCharacter()
      if mc and Character == mc then me = true return end
    end
    local pc = ESP.GetController()
    if pc and pc.GetPawn then
      local p = pc:GetPawn()
      if p and Character == p then me = true return end
    end
  end)
  if not me and MyKey ~= nil and PlayerKey ~= nil then
    me = (tostring(PlayerKey) == tostring(MyKey))
  end
  return me
end

function ESP.GetTeamID(Character)
  if not ESPValid(Character) then return nil end
  local id = nil
  pcall(function() if Character.GetTeamID then id = Character:GetTeamID() end end)
  if id == nil then pcall(function() id = Character.TeamID end) end
  if id == nil then
    local ps = nil
    pcall(function()
      if Character.GetPlayerStateSafety then ps = Character:GetPlayerStateSafety()
      elseif Character.GetPlayerState then ps = Character:GetPlayerState() end
    end)
    if not ESPValid(ps) then pcall(function() ps = Character.PlayerState end) end
    if ESPValid(ps) then
      pcall(function() if ps.GetTeamID then id = ps:GetTeamID() end end)
      if id == nil then pcall(function() id = ps.TeamID end) end
    end
  end
  return id
end

function ESP.IsAlive(Character)
  if not ESPValid(Character) then return false end
  local alive = nil
  pcall(function() if Character.IsAlive then alive = Character:IsAlive() end end)
  if type(alive) == "boolean" then return alive end
  local hp = nil
  pcall(function() hp = Character.Health end)
  if type(hp) ~= "number" then pcall(function() hp = Character.HP end) end
  if type(hp) == "number" then return hp > 0 end
  return true
end

function ESP.IsKnocked(Character)
  if not ESPValid(Character) then return false end
  local k = false
  pcall(function()
    if Character.HealthStatus == 1 then k = true end
  end)
  if not k then pcall(function()
    if Character.IsNearDeath and Character:IsNearDeath() then k = true end
  end) end
  return k
end

function ESP.IsBot(Character)
  if not ESPValid(Character) then return false end
  local bAI = false
  pcall(function()
    if Game and Game.IsAI then bAI = Game:IsAI(Character) end
    if not bAI and Character then
      if Character.bEnsure == true or Character.bMEnsure == true then bAI = true
      elseif Character.PlayerState and Character.PlayerState.bPSEnsure == true then bAI = true
      elseif Character.Controller then
        if Character.Controller.IsMLAI == true or Character.Controller.FakePlayerBornType == 1 then bAI = true end
      end
    end
  end)
  if not bAI then
    pcall(function()
      if Character.bIsAI == true then bAI = true end
    end)
  end
  if not bAI then
    local ps = nil
    pcall(function()
      if Character.GetPlayerStateSafety then ps = Character:GetPlayerStateSafety() end
    end)
    if ESPValid(ps) then
      pcall(function()
        if ps.bIsABot == true or ps.bIsBot == true or ps.bIsAI == true then bAI = true end
      end)
    end
  end
  return bAI
end

function ESP.GetPlayerKey(Character)
  local key = nil
  pcall(function() if Character.GetPlayerKey then key = Character:GetPlayerKey() end end)
  if key == nil then pcall(function() key = Character.PlayerKey end) end
  return tostring(key or Character)
end

function ESP.GetHealthPct(Character)
  if not ESPValid(Character) then return 1.0 end
  local hp, maxhp = nil, nil
  pcall(function() hp = Character.Health end)
  if type(hp) ~= "number" then pcall(function() hp = Character.HP end) end
  pcall(function() maxhp = Character.MaxHealth end)
  if type(maxhp) ~= "number" then pcall(function() maxhp = Character.MaxHP end) end
  if type(hp) ~= "number" then return 1.0 end
  if type(maxhp) ~= "number" or maxhp <= 0 then maxhp = 100 end
  local pct = hp / maxhp
  if pct ~= pct then return 1.0 end
  if pct < 0 then pct = 0 end
  if pct > 1 then pct = 1 end
  return pct
end

local function NormalizeName(v)
  if v == nil or v == false then return nil end
  local ok, t = pcall(tostring, v)
  if not ok or not t then return nil end
  t = t:gsub("^%s+", ""):gsub("%s+$", "")
  if t == "" or t == "nil" or t == "None" or t == "NULL" or t == "Unknown" then return nil end
  return t
end

function ESP.ResolveName(Character, isBot)
  if isBot then return "Bot" end
  local name = nil
  local function take(v)
    if not name then name = NormalizeName(v) end
  end
  pcall(function() if Character.GetPlayerNameSafety then take(Character:GetPlayerNameSafety()) end end)
  pcall(function() if not name and Character.GetPlayerName then take(Character:GetPlayerName()) end end)
  pcall(function() if not name then take(Character.PlayerName) end end)
  pcall(function() if not name then take(Character.NickName) end end)
  if not name then
    local ps = nil
    pcall(function()
      if Character.GetPlayerStateSafety then ps = Character:GetPlayerStateSafety()
      elseif Character.GetPlayerState then ps = Character:GetPlayerState() end
    end)
    if not ESPValid(ps) then pcall(function() ps = Character.PlayerState end) end
    if ESPValid(ps) then
      pcall(function() if ps.GetPlayerName then take(ps:GetPlayerName()) end end)
      pcall(function() if not name then take(ps.PlayerName) end end)
      pcall(function() if not name then take(ps.PlayerNamePrivate) end end)
      pcall(function() if not name then take(ps.NickName) end end)
    end
  end
  return name or "Player"
end

function ESP.GetBonePos(Character, boneName)
  if not ESPValid(Character) or not boneName then return nil end
  local pos = nil
  pcall(function()
    if type(Character.GetBonePos) == "function" then
      pos = Character:GetBonePos(boneName, { X = 0, Y = 0, Z = 0 })
    end
    if not pos or (pos.X == 0 and pos.Y == 0 and pos.Z == 0) then
      if type(Character.GetSocketLocation) == "function" then
        pos = Character:GetSocketLocation(boneName)
      end
    end
    if (not pos or (pos.X == 0 and pos.Y == 0 and pos.Z == 0)) and ESPValid(Character.Mesh) then
      local mesh = Character.Mesh
      if mesh and mesh.GetSocketLocation then
        local mp = mesh:GetSocketLocation(boneName)
        if mp and not (mp.X == 0 and mp.Y == 0 and mp.Z == 0) then pos = mp end
      end
    end
  end)
  return pos
end

function ESP.GetCamLoc(pc)
  local loc = nil
  pcall(function()
    if GameplayStaticsESP and GameplayStaticsESP.GetPlayerCameraManager then
      local mgr = GameplayStaticsESP.GetPlayerCameraManager(pc, 0)
      if ESPValid(mgr) and mgr.GetCameraLocation then loc = mgr:GetCameraLocation() end
    end
  end)
  if not loc then
    pcall(function()
      if pc and pc.GetPawn then
        local p = pc:GetPawn()
        if ESPValid(p) and p.K2_GetActorLocation then loc = p:K2_GetActorLocation() end
      end
    end)
  end
  return loc
end

function ESP.IsBoneVisible(pc, camLoc, target, bonePos)
  if not ESPValid(pc) or not ESPValid(target) or not bonePos or not camLoc then return false end
  if not KismetSystemLibraryESP or not KismetSystemLibraryESP.LineTraceSingle then return true end
  local dx = bonePos.X - camLoc.X
  local dy = bonePos.Y - camLoc.Y
  local dz = bonePos.Z - camLoc.Z
  local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
  if dist < 50 then return true end
  TraceStartPos.X = camLoc.X + (dx / dist) * 60
  TraceStartPos.Y = camLoc.Y + (dy / dist) * 60
  TraceStartPos.Z = camLoc.Z + (dz / dist) * 60
  local bVis = false
  pcall(function()
    local bHit = KismetSystemLibraryESP.LineTraceSingle(
      pc, TraceStartPos, bonePos, 0, false, nil, 0, CachedHitResult, true)
    if bHit then
      local hitActor = nil
      if CachedHitResult then
        if type(CachedHitResult.GetActor) == "function" then
          hitActor = CachedHitResult:GetActor()
        elseif CachedHitResult.Actor then
          hitActor = CachedHitResult.Actor
        end
      end
      if ESPValid(hitActor) then
        if hitActor == target then bVis = true end
      end
    else
      bVis = true
    end
  end)
  return bVis
end

function ESP.IsVisible(key, pc, camLoc, Character)
  local now = ESP.Now()
  local cached = ESP.VisCache[key]
  if cached and (now - (cached.t or 0)) < (CFG.VisInterval or 0.15) then
    return cached.b
  end
  local bVis = false
  if ESPValid(Character) and ESPValid(pc) and camLoc then
    local bones = { "head", "spine_03", "pelvis" }
    for _, bn in ipairs(bones) do
      local bp = ESP.GetBonePos(Character, bn)
      if bp and (bp.X ~= 0 or bp.Y ~= 0 or bp.Z ~= 0) then
        if ESP.IsBoneVisible(pc, camLoc, Character, bp) then bVis = true break end
      end
    end
  else
    bVis = true
  end
  ESP.VisCache[key] = { b = bVis, t = now }
  return bVis
end

function ESP.ActorLocation(Character)
  local loc = nil
  if not ESPValid(Character) then return nil end
  pcall(function()
    if Character.K2_GetActorLocation then loc = Character:K2_GetActorLocation()
    elseif Game and Game.GetActorLocation then loc = Game:GetActorLocation(Character) end
  end)
  return loc
end

function ESP.DistMeters(a, b)
  if not a or not b then return math.huge end
  local dx, dy, dz = a.X - b.X, a.Y - b.Y, a.Z - b.Z
  return math.sqrt(dx * dx + dy * dy + dz * dz) / 100.0
end

function ESP.GetVerticalBounds(Character)
  if not ESPValid(Character) then return nil, nil end
  local center, halfHeight = nil, nil
  local capsule = nil
  pcall(function()
    if Character.GetCapsuleComponent then capsule = Character:GetCapsuleComponent()
    elseif Character.CapsuleComponent then capsule = Character.CapsuleComponent end
  end)
  if capsule and ESPValid(capsule) then
    pcall(function()
      if capsule.K2_GetComponentLocation then center = capsule:K2_GetComponentLocation()
      elseif capsule.GetComponentLocation then center = capsule:GetComponentLocation() end
      if capsule.GetScaledCapsuleHalfHeight then halfHeight = capsule:GetScaledCapsuleHalfHeight()
      elseif capsule.GetUnscaledCapsuleHalfHeight then halfHeight = capsule:GetUnscaledCapsuleHalfHeight()
      elseif capsule.CapsuleHalfHeight then halfHeight = capsule.CapsuleHalfHeight end
    end)
  end
  if not center then
    pcall(function() if Character.K2_GetActorLocation then center = Character:K2_GetActorLocation() end end)
  end
  if not center then
    pcall(function() if Game and Game.GetActorLocation then center = Game:GetActorLocation(Character) end end)
  end
  if not center then return nil, nil end
  if not halfHeight or halfHeight < 10 or halfHeight > 200 then
    halfHeight = 85
    pcall(function()
      if Character.bIsCrouched then halfHeight = 60 end
      if Character.IsProne and Character:IsProne() then halfHeight = 25 end
    end)
  end
  return center, halfHeight
end

function ESP.GetHeadFeet(Character)
  local center, half = ESP.GetVerticalBounds(Character)
  if not center or not half then return nil, nil end
  local head = { X = center.X, Y = center.Y, Z = center.Z + half }
  local feet = { X = center.X, Y = center.Y, Z = center.Z - half }
  return head, feet
end

function ESP.Now()
  local t = nil
  pcall(function()
    local w = (slua and slua.getWorld and slua.getWorld()) or nil
    if GameplayStaticsESP and w and GameplayStaticsESP.GetRealTimeSeconds then
      t = GameplayStaticsESP.GetRealTimeSeconds(w)
    end
  end)
  if tonumber(t) then return tonumber(t) end
  pcall(function() if os and os.clock then t = os.clock() end end)
  return tonumber(t) or 0.0
end

function ESP.World()
  local w = nil
  pcall(function() if slua and slua.getWorld then w = slua.getWorld() end end)
  return w
end

-- ---------- canvas ----------
function ESP.GetCanvas()
  if ESPValid(ESP.Canvas) then return ESP.Canvas end
  local root = nil
  pcall(function()
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    if InGameUITools and InGameUITools.GetMainControlBaseUI then root = InGameUITools.GetMainControlBaseUI() end
  end)
  if not ESPValid(root) then return nil end
  local canvas = nil
  pcall(function()
    if ESPValid(root.CanvasPanel_0) then canvas = root.CanvasPanel_0
    elseif ESPValid(root.CanvasPanel_42) then canvas = root.CanvasPanel_42 end
  end)
  if ESPValid(canvas) then ESP.Canvas = canvas return canvas end
  return nil
end

function ESP.UpdateCanvasTransform(pc)
  local canvas = ESP.GetCanvas()
  if not ESPValid(canvas) then return false end
  local calibrated = false
  -- Method 1: SlateBlueprintLibrary.AbsoluteToLocal (source primary method)
  pcall(function()
    if SlateBlueprintLibrary and SlateBlueprintLibrary.AbsoluteToLocal then
      local geo = canvas:GetCachedGeometry()
      if geo then
        local p0 = SlateBlueprintLibrary.AbsoluteToLocal(geo, ESPV2(0, 0))
        local p1 = SlateBlueprintLibrary.AbsoluteToLocal(geo, ESPV2(100, 100))
        if p0 and p1 and tonumber(p0.X) and tonumber(p1.X) and p1.X ~= p0.X and p1.Y ~= p0.Y then
          ESP.ScaleX = (p1.X - p0.X) / 100.0
          ESP.ScaleY = (p1.Y - p0.Y) / 100.0
          ESP.OffsetX = p0.X
          ESP.OffsetY = p0.Y
          calibrated = true
        end
      end
    end
  end)
  -- Method 2: WidgetLayoutLibrary.ScreenToWidgetLocal (source fallback)
  if not calibrated then
    pcall(function()
      local WLL = WidgetLayoutLibrary
      if WLL and WLL.ScreenToWidgetLocal then
        local geo = canvas:GetCachedGeometry()
        if geo then
          local pt0 = ESPV2(0, 0)
          local pt1 = ESPV2(0, 0)
          WLL.ScreenToWidgetLocal(pc, geo, ESPV2(0, 0), pt0)
          WLL.ScreenToWidgetLocal(pc, geo, ESPV2(100, 100), pt1)
          if pt0 and pt1 and pt1.X ~= pt0.X then
            ESP.ScaleX = (pt1.X - pt0.X) / 100.0
            ESP.ScaleY = (pt1.Y - pt0.Y) / 100.0
            ESP.OffsetX = pt0.X
            ESP.OffsetY = pt0.Y
            calibrated = true
          end
        end
      end
    end)
  end
  -- Method 3: GetViewportScale fallback
  if not calibrated then
    local scale = 1.0
    pcall(function()
      if WidgetLayoutLibrary and WidgetLayoutLibrary.GetViewportScale then
        local s = WidgetLayoutLibrary.GetViewportScale(pc)
        if tonumber(s) and s > 0 then scale = s end
      end
    end)
    ESP.ScaleX = 1.0 / scale
    ESP.ScaleY = 1.0 / scale
    ESP.OffsetX = 0.0
    ESP.OffsetY = 0.0
  end
  return true
end

function ESP.Viewport(pc)
  local w, h = nil, nil
  local function ok(x, y)
    x, y = tonumber(x), tonumber(y)
    if x and y and x > 200 and y > 100 then w, h = x, y return true end
    return false
  end
  -- M1: PC:GetViewportSize — slua out-params usually come back as RETURN values
  pcall(function()
    if pc and pc.GetViewportSize then
      local v = ESPV2(0, 0)
      local a, b = pc:GetViewportSize(v)
      if not ok(a, b) then
        if type(a) == "table" or type(a) == "userdata" then ok(a.X, a.Y) end
      end
      if not w then ok(v.X, v.Y) end
    end
  end)
  -- M2: WidgetLayoutLibrary.GetViewportSize (source fallback)
  if not w then
    pcall(function()
      local WLL = WidgetLayoutLibrary
      if WLL and WLL.GetViewportSize then
        local vs = WLL.GetViewportSize(pc)
        if vs then ok(vs.X, vs.Y) end
      end
    end)
  end
  -- M3: viewport widget geometry (DPI units) * viewport scale = pixels
  if not w then
    pcall(function()
      local WLL = WidgetLayoutLibrary
      if WLL and WLL.GetViewportWidgetGeometry then
        local geo = WLL.GetViewportWidgetGeometry(pc)
        local sz = geo and geo:GetLocalSize()
        local s = (WLL.GetViewportScale and WLL.GetViewportScale(pc)) or 1.0
        if sz then ok(sz.X * s, sz.Y * s) end
      end
    end)
  end
  return w or ESP.ViewW or 1920.0, h or ESP.ViewH or 1080.0
end

function ESP.Project(pc, worldLoc)
  if not pc or not worldLoc then return nil end
  local pix = ESPV2(0, 0)
  local ok = false
  pcall(function()
    local res = pc:ProjectWorldLocationToScreen(worldLoc, pix, true)
    if res == false or res == 0 then
      ok = false   -- behind camera: mirrored coords, reject
    else
      ok = (res == true or res == 1 or (pix and (pix.X ~= 0 or pix.Y ~= 0)))
    end
  end)
  if not ok then return nil end
  return ESPV2(pix.X * (ESP.ScaleX or 1.0) + (ESP.OffsetX or 0.0),
               pix.Y * (ESP.ScaleY or 1.0) + (ESP.OffsetY or 0.0)), pix
end

-- (SnapOrigin removed: replaced by SL_GetStartPos source-exact function)

-- ---------- widget helpers (Help patterns) ----------
function ESP.SetFont(w, size)
  if not ESPValid(w) then return end
  pcall(function()
    local f = w.Font
    if f then
      f.Size = size
      if f.OutlineSettings then
        pcall(function() f.OutlineSettings.OutlineSize = 1 end)
        pcall(function() f.OutlineSettings.OutlineColor = C_BLACK end)
      end
      w:SetFont(f)
    end
    if w.SetShadowOffset then w:SetShadowOffset(ESPV2(1.0, 1.0)) end
    if w.SetShadowColorAndOpacity then w:SetShadowColorAndOpacity(C_BLACK) end
  end)
end

function ESP.SetTextColor(w, color)
  if not ESPValid(w) then return end
  pcall(function()
    if SlateColor then w:SetColorAndOpacity(SlateColor(color))
    else w:SetColorAndOpacity(color) end
  end)
end

function ESP.NewLine(color, z)
  local canvas = ESP.GetCanvas()
  if not ESPValid(canvas) then return nil end
  local border = nil
  pcall(function() border = CGame:NewObjectFromPath("/Script/UMG.Border", canvas) end)
  if not ESPValid(border) then return nil end
  pcall(function()
    border:SetBrushColor(color)
    border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    border:SetRenderTransformPivot(ESPV2(0.0, 0.5))
  end)
  local slot = nil
  pcall(function() slot = canvas:AddChildToCanvas(border) end)
  if not slot then
    pcall(function() border:RemoveFromParent() end)
    return nil
  end
  pcall(function() slot:SetAutoSize(false) slot:SetZOrder(z or 30) end)
  return { Widget = border, Slot = slot }
end

function ESP.DrawLine(data, x1, y1, x2, y2, thickness)
  if not data or not ESPValid(data.Widget) or not data.Slot then return false end
  if x1 ~= x1 or y1 ~= y1 or x2 ~= x2 or y2 ~= y2 then return false end
  x1, y1, x2, y2 = RND(x1), RND(y1), RND(x2), RND(y2)
  local dz = CFG.DeadZone or 0.5
  if data.lx1 and data.th == thickness then
    if math.abs((data.lx1 or 0) - x1) < dz and math.abs((data.ly1 or 0) - y1) < dz
    and math.abs((data.lx2 or 0) - x2) < dz and math.abs((data.ly2 or 0) - y2) < dz then
      if data.hidden ~= true then return true end
    end
  end
  local dx, dy = x2 - x1, y2 - y1
  local len = math.sqrt(dx * dx + dy * dy)
  if len < 1 then
    ESP.Hide(data)
    return false
  end
  local angle = ((math.atan2 and math.atan2(dy, dx)) or math.atan(dy, dx)) * 180.0 / math.pi
  angle = math.floor(angle * 10 + 0.5) / 10
  len = RND(len)
  if data.lx1 == x1 and data.ly1 == y1 and data.lx2 == x2 and data.ly2 == y2 and data.th == thickness then
    if data.hidden == true then
      pcall(function() data.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
      data.hidden = false
    end
    return true
  end
  local ok = pcall(function()
    data.Slot:SetPosition(ESPV2(x1, y1 - thickness * 0.5))
    data.Slot:SetSize(ESPV2(len, thickness))
    data.Widget:SetRenderAngle(angle)
    data.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end)
  if ok then
    data.lx1, data.ly1, data.lx2, data.ly2, data.th = x1, y1, x2, y2, thickness
    data.hidden = false
  end
  return true
end

function ESP.DrawVBar(data, x, top, h, thickness)
  -- vertical health bar: no angle math, seedha Position+Size (double-draw fix)
  if not data or not ESPValid(data.Widget) or not data.Slot then return false end
  if h ~= h or h < 1 then ESP.Hide(data) return false end
  x, top, h = RND(x), RND(top), RND(h)
  local dz = CFG.DeadZone or 0.5
  if data.bx ~= nil then
    if math.abs(data.bx - x) < dz and math.abs(data.bt - top) < dz and math.abs(data.bh - h) < dz then
      if data.hidden ~= true then return true end
    end
  end
  if data.bx == x and data.bt == top and data.bh == h then
    if data.hidden == true then
      pcall(function() data.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
      data.hidden = false
    end
    return true
  end
  local ok = pcall(function()
    data.Slot:SetPosition(ESPV2(x, top))
    data.Slot:SetSize(ESPV2(thickness, h))
    data.Widget:SetRenderAngle(0)
    data.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end)
  if ok then data.bx, data.bt, data.bh = x, top, h data.hidden = false end
  return true
end

function ESP.DrawHBar(data, x, top, w, h)
  -- horizontal bar: SetPosition + SetSize directly, no angle
  if not data or not ESPValid(data.Widget) or not data.Slot then return false end
  if w ~= w or w < 1 or h ~= h or h < 1 then ESP.Hide(data) return false end
  x, top, w, h = RND(x), RND(top), RND(w), RND(h)
  local dz = CFG.DeadZone or 0.5
  if data.bx ~= nil then
    if math.abs(data.bx - x) < dz and math.abs(data.bt - top) < dz
    and math.abs(data.bh - h) < dz and math.abs((data.bw or 0) - w) < dz then
      if data.hidden ~= true then return true end
    end
  end
  local ok = pcall(function()
    data.Slot:SetPosition(ESPV2(x, top))
    data.Slot:SetSize(ESPV2(w, h))
    data.Widget:SetRenderAngle(0)
    data.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end)
  if ok then data.bx, data.bt, data.bh, data.bw = x, top, h, w data.hidden = false end
  return true
end

function ESP.Hide(data)
  if data and ESPValid(data.Widget) and data.hidden ~= true then
    pcall(function() data.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
    data.hidden = true
    data.lx1, data.ly1, data.lx2, data.ly2, data.th = nil, nil, nil, nil, nil
    data.bx, data.bt, data.bh = nil, nil, nil
  end
end

function ESP.SetBrush(data, color, colorKey)
  if not data or not ESPValid(data.Widget) then return end
  if colorKey and data.colorKey == colorKey then return end
  pcall(function() data.Widget:SetBrushColor(color) end)
  if colorKey then data.colorKey = colorKey end
end

function ESP.Destroy(data)
  if not data then return end
  local w = data.Widget or data.Container
  if ESPValid(w) then
    pcall(function() w:RemoveFromParent() end)
    pcall(function() w:ConditionalBeginDestroy() end)
  end
end

-- (CreateCounter/UpdateCounter/CanvasCenterX removed: replaced by RedBoxOverlay source-exact)

-- bottom info: Bot / 16m / Open
function ESP.CreateInfo()
  local canvas = ESP.GetCanvas()
  if not ESPValid(canvas) then return nil end
  local container, tName, tDist, tState = nil, nil, nil, nil
  pcall(function() container = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", canvas) end)
  if not ESPValid(container) then return nil end
  pcall(function() tName = CGame:NewObjectFromPath("/Script/UMG.TextBlock", container) end)
  pcall(function() tDist = CGame:NewObjectFromPath("/Script/UMG.TextBlock", container) end)
  pcall(function() tState = CGame:NewObjectFromPath("/Script/UMG.TextBlock", container) end)
  if not ESPValid(tName) or not ESPValid(tDist) or not ESPValid(tState) then
    ESP.Destroy({ Widget = container })
    return nil
  end
  pcall(function()
    tName:SetText("Bot")
    tDist:SetText("0m")
    tState:SetText("Open")
    tName:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    tDist:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    tState:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if tName.SetJustification then tName:SetJustification(1) end
    if tDist.SetJustification then tDist:SetJustification(1) end
    if tState.SetJustification then tState:SetJustification(1) end
  end)
  ESP.SetTextColor(tName, C_BLUE)
  ESP.SetTextColor(tDist, C_WHITE)
  ESP.SetTextColor(tState, C_GREEN)
  ESP.SetFont(tName, CFG.NameFontSize)
  ESP.SetFont(tDist, CFG.DistFontSize)
  ESP.SetFont(tState, CFG.StateFontSize)
  local s1, s2, s3, ms = nil, nil, nil, nil
  pcall(function() s1 = container:AddChildToCanvas(tName) end)
  pcall(function() s2 = container:AddChildToCanvas(tDist) end)
  pcall(function() s3 = container:AddChildToCanvas(tState) end)
  pcall(function() ms = canvas:AddChildToCanvas(container) end)
  if not s1 or not s2 or not s3 or not ms then
    ESP.Destroy({ Widget = container })
    return nil
  end
  pcall(function()
    s1:SetAutoSize(true) s1:SetAlignment(ESPV2(0.5, 0.5)) s1:SetZOrder(36)
    s2:SetAutoSize(true) s2:SetAlignment(ESPV2(0.5, 0.5)) s2:SetZOrder(36)
    s3:SetAutoSize(true) s3:SetAlignment(ESPV2(0.5, 0.5)) s3:SetZOrder(36)
    ms:SetAutoSize(false) ms:SetZOrder(35)
  end)
  return { Container = container, Name = tName, Dist = tDist, State = tState,
           S1 = s1, S2 = s2, S3 = s3, Slot = ms }
end

function ESP.UpdateInfo(key, Character, isBot, distM, bVisible, footX, footY)
  local d = ESP.Infos[key]
  if not d or not ESPValid(d.Container) then
    ESP.Destroy(d)
    d = ESP.CreateInfo()
    ESP.Infos[key] = d
  end
  if not d then return end
  -- Bot pe "Bot", real player pe real name (cache, flicker fix)
  local name = d.CachedName
  if not name then
    name = ESP.ResolveName(Character, isBot)
    d.CachedName = name
  end
  if isBot then
    name = "Bot"
    d.CachedName = "Bot"
  end
  local dl = string.format("%dm", math.max(0, math.floor((tonumber(distM) or 0) + 0.5)))
  -- Visibility: Open (green) / Close (red)
  local st = bVisible and " " or " "
  local stKey = bVisible and " " or " "
  pcall(function()
    -- Name: canvas version disabled (AddDebugText below)
    if false and _G.PGConfig.Esp9_Name then
      if d.LastN ~= name then
        d.Name:SetText(name) d.LastN = name
        if isBot then ESP.SetTextColor(d.Name, C_BLUE)
        else ESP.SetTextColor(d.Name, C_WHITE) end
      end
    else
      if d.LastN ~= "" then d.Name:SetText("") d.LastN = "" end
    end
    -- Distance: disabled
    if false then
      if d.LastD ~= dl then d.Dist:SetText(dl) d.LastD = dl end
    else
      if d.LastD ~= "" then d.Dist:SetText("") d.LastD = "" end
    end
    -- Open/Close status: sirf Esp9_Line ON ho tab (line visible hai to status bhi)
    if _G.PGConfig.Esp9_Line then
      if d.LastS ~= st then
        d.State:SetText(st) d.LastS = st
        if bVisible then ESP.SetTextColor(d.State, C_GREEN)
        else ESP.SetTextColor(d.State, C_RED) end
      end
    else
      if d.LastS ~= "" then d.State:SetText("") d.LastS = "" end
    end
    if d.LastK ~= stKey then d.LastK = stKey end
  end)
  -- 3 lines, centered under feet (pos cache, flicker fix)
  local w = 120.0
  local h1, h2, h3 = 20.0, 17.0, 17.0
  local x = RND(footX - w * 0.5)
  local y = RND(footY + 4.0)
  if d.ix == nil or math.abs(d.ix - x) >= 1.0 or math.abs((d.iy or 0) - y) >= 1.0 then
    d.ix, d.iy = x, y
    pcall(function()
      d.Slot:SetPosition(ESPV2(x, y))
      d.Slot:SetSize(ESPV2(w, h1 + h2 + h3 + 6.0))
      d.S1:SetPosition(ESPV2(w * 0.5, h1 * 0.5))
      d.S2:SetPosition(ESPV2(w * 0.5, h1 + h2 * 0.5 + CFG.TextGap))
      d.S3:SetPosition(ESPV2(w * 0.5, h1 + h2 + h3 * 0.5 + CFG.TextGap * 2.0))
      d.Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end)
  else
    pcall(function()
      d.Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end)
  end
end

function ESP.EnsureWeapon(key)
  local d = ESP.Weapons[key]
  if d and ESPValid(d.Widget) then return d end
  local canvas = ESP.GetCanvas()
  if not ESPValid(canvas) then return nil end
  local tb, slot = nil, nil
  pcall(function() tb = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas) end)
  if not ESPValid(tb) then return nil end
  pcall(function() slot = canvas:AddChildToCanvas(tb) end)
  if not slot then ESP.Destroy({ Widget = tb }) return nil end
  pcall(function()
    tb:SetText("")
    tb:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if tb.SetJustification then tb:SetJustification(1) end
    slot:SetAutoSize(true)
    slot:SetAlignment(ESPV2(0.5, 0.5))
    slot:SetZOrder(36)
  end)
  ESP.SetTextColor(tb, C_YELLOW)
  ESP.SetFont(tb, CFG.StateFontSize)
  d = { Widget = tb, Slot = slot }
  ESP.Weapons[key] = d
  return d
end

function ESP.UpdateWeapon(d, Character, isBot, cx, y)
  if not d or not ESPValid(d.Widget) then return end
  local now = os.clock()
  -- weapon naam 1.5s cache (har tick query mehnga hai)
  if d.nextT == nil or now >= d.nextT then
    d.nextT = now + 1.5
    local name = "No Weapon"
    pcall(function()
      local w = nil
      if Character.CurrentWeapon then w = Character.CurrentWeapon
      elseif type(Character.GetCurrentWeapon) == "function" then w = Character:GetCurrentWeapon()
      elseif Character.WeaponManagerComponent then w = Character.WeaponManagerComponent.CurrentWeaponReplicated end
      if ESPValid(w) and type(w.GetWeaponName) == "function" then name = tostring(w:GetWeaponName()) end
    end)
    if d.text ~= name then
      d.text = name
      pcall(function() d.Widget:SetText(name) end)
    end
  end
  local ck = isBot and "bot" or "real"
  if d.colKey ~= ck then
    d.colKey = ck
    ESP.SetTextColor(d.Widget, isBot and C_CYAN or C_YELLOW)
  end
  local x, yy = RND(cx), RND(y)
  if d.px == nil or math.abs(d.px - x) >= 1.0 or math.abs((d.py or 0) - yy) >= 1.0 then
    d.px, d.py = x, yy
    pcall(function() d.Slot:SetPosition(ESPV2(x, yy)) end)
  end
  if d.hidden then
    d.hidden = false
    pcall(function() d.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
  end
end

function ESP.EnsureCorner(key, idx, color)
  local t = ESP.Corners[key]
  if not t then t = {} ESP.Corners[key] = t end
  local d = t[idx]
  if d and ESPValid(d.Widget) then return d end
  d = ESP.NewLine(color or C_WHITE, 32)
  t[idx] = d
  return d
end

function ESP.EnsureHealthBorder(key)
  local d = ESP.HealthBorder[key]
  if d and ESPValid(d.Widget) then return d end
  d = ESP.NewLine(ESPMKC(1.0, 1.0, 1.0, 1.0), 30)  -- white, behind bg
  ESP.HealthBorder[key] = d
  return d
end

function ESP.EnsureHealthBg(key)
  local d = ESP.HealthBg[key]
  if d and ESPValid(d.Widget) then return d end
  d = ESP.NewLine(ESPMKC(0.0, 0.0, 0.0, CFG.SideBgAlpha or 0.55), 31)
  ESP.HealthBg[key] = d
  return d
end

function ESP.EnsureHealthFill(key)
  local d = ESP.HealthFill[key]
  if d and ESPValid(d.Widget) then return d end
  d = ESP.NewLine(C_GREEN, 32)
  ESP.HealthFill[key] = d
  return d
end

-- Health bar: HEAD KE UPAR, centered on enemy box, with white stroke border
function ESP.UpdateHealthBar(key, pct, boxL, boxR, headTopY)
  local border = ESP.EnsureHealthBorder(key)
  local bg   = ESP.EnsureHealthBg(key)
  local fill = ESP.EnsureHealthFill(key)
  if not bg or not fill then return end

  local rawW = boxR - boxL
  local barW = math.max(20, math.min(120, rawW))  -- clamped width
  local barH = 5.0
  local gapAboveHead = 4.0
  local boxCX   = (boxL + boxR) * 0.5           -- center of enemy box
  local barLeft = boxCX - barW * 0.5            -- centered bar left edge
  local barTop  = headTopY - gapAboveHead - barH

  pct = tonumber(pct) or 1.0
  if pct < 0 then pct = 0 end
  if pct > 1 then pct = 1 end

  -- white stroke: 1px outside on all sides
  local s = 2.0
  if border then ESP.DrawHBar(border, barLeft - s, barTop - s, barW + s*2, barH + s*2) end

  -- bg: full width dark bar (centered)
  ESP.DrawHBar(bg, barLeft, barTop, barW, barH)

  -- fill: left-anchored from barLeft, width = barW * pct
  local fw = barW * pct
  if fw < 1 then
    ESP.Hide(fill)
    return
  end
  local bucket
  if pct >= 0.7 then bucket = "g_" .. math.floor(pct * 20 + 0.5)
  elseif pct >= 0.4 then bucket = "y_" .. math.floor(pct * 20 + 0.5)
  else bucket = "r_" .. math.floor(pct * 20 + 0.5) end
  ESP.SetBrush(fill, HealthColor(pct), bucket)
  ESP.DrawHBar(fill, barLeft, barTop, fw, barH)
end

-- ===== NAME ABOVE HEALTH BAR =====
function ESP.CreateNameLabel()
  local canvas = ESP.GetCanvas()
  if not ESPValid(canvas) then return nil end
  local txt = nil
  pcall(function() txt = CGame:NewObjectFromPath("/Script/UMG.TextBlock", canvas) end)
  if not ESPValid(txt) then return nil end
  local slot = nil
  pcall(function()
    txt:SetText("")
    txt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if txt.SetJustification then txt:SetJustification(1) end  -- center
    ESP.SetFont(txt, 10)   -- fixed small font
    ESP.SetTextColor(txt, ESPMKC(1.0, 1.0, 0.0, 1.0))  -- yellow
    -- shadow/stroke band karo
    pcall(function()
      if txt.SetShadowOffset then txt:SetShadowOffset({X=0,Y=0}) end
      if txt.SetShadowColorAndOpacity then txt:SetShadowColorAndOpacity({R=0,G=0,B=0,A=0}) end
    end)
    slot = canvas:AddChildToCanvas(txt)
  end)
  if not slot then ESP.Destroy({Widget=txt}) return nil end
  pcall(function()
    slot:SetAutoSize(false)
    slot:SetAlignment(ESPV2(0.0, 1.0))  -- left-top anchor; caller passes pre-computed left edge X
    slot:SetZOrder(37)
  end)
  return { Widget = txt, Slot = slot }
end

-- boxL = already calculated left edge (caller does: boxCX - clampW*0.5)
-- barW = clamped width, barTop = bottom Y of name widget
function ESP.UpdateNameLabel(key, name, isBot, boxL, barW, barTop)
  local d = ESP.NameLabels[key]
  if not d or not ESPValid(d.Widget) then
    ESP.Destroy(d)
    d = ESP.CreateNameLabel()
    ESP.NameLabels[key] = d
  end
  if not d then return end
  local lbl = (name and name ~= "") and name or (isBot and "Bot" or "Enemy")
  pcall(function()
    if d.LastN ~= lbl then d.Widget:SetText(lbl) d.LastN = lbl end
    -- yellow color (no re-set needed every frame, CreateNameLabel already sets it)
    local nameH = 14.0
    local nx = RND(boxL)   -- left edge already pre-calculated by caller
    local ny = RND(barTop)
    if d.nx ~= nx or d.ny ~= ny or d.nw ~= barW then
      d.nx, d.ny, d.nw = nx, ny, barW
      d.Slot:SetPosition(ESPV2(nx, ny))
      d.Slot:SetSize(ESPV2(barW, nameH))
    end
    d.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end)
end

function ESP.EnsureMark(key, idx)
  local t = ESP.Marks[key]
  if not t then t = {} ESP.Marks[key] = t end
  local d = t[idx]
  if d and ESPValid(d.Widget) then return d end
  d = ESP.NewLine(C_YELLOW, 33)
  t[idx] = d
  return d
end

-- (EnsureSnap removed: snap lines handled by SL_UpdateSnapLine source-exact)

function ESP.HideTarget(key)
  local c = ESP.Corners[key]
  if c then for i = 1, 8 do ESP.Hide(c[i]) end end
  ESP.Hide(ESP.HealthBorder[key])
  ESP.Hide(ESP.HealthBg[key])
  ESP.Hide(ESP.HealthFill[key])
  local m = ESP.Marks[key]
  if m then for i = 1, 4 do ESP.Hide(m[i]) end end
  ESP.Hide(ESP.Lines[key])
  -- snap line: off-screen / behind / out of range -> hide (stuck line fix)
  local sl = SnapLineWidgets[key]
  if sl and ESPValid(sl.Widget) then
    pcall(function() sl.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
  end
  ESP.Hide(ESP.Weapons[key])
  local inf = ESP.Infos[key]
  if inf and ESPValid(inf.Container) then
    pcall(function() inf.Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
  end
  local nl = ESP.NameLabels[key]
  if nl and ESPValid(nl.Widget) then
    pcall(function() nl.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
  end
end

function ESP.ReleaseTarget(key)
  local c = ESP.Corners[key]
  if c then for i = 1, 8 do ESP.Destroy(c[i]) end end
  ESP.Corners[key] = nil
  ESP.Destroy(ESP.HealthBorder[key])
  ESP.HealthBorder[key] = nil
  ESP.Destroy(ESP.HealthBg[key])
  ESP.HealthBg[key] = nil
  ESP.Destroy(ESP.HealthFill[key])
  ESP.HealthFill[key] = nil
  local m = ESP.Marks[key]
  if m then for i = 1, 4 do ESP.Destroy(m[i]) end end
  ESP.Marks[key] = nil
  ESP.Destroy(ESP.Lines[key])
  ESP.Lines[key] = nil
  SL_RemoveSnapLine(key)
  ESP.Destroy(ESP.Infos[key])
  ESP.Infos[key] = nil
  ESP.Destroy(ESP.Weapons[key])
  ESP.Weapons[key] = nil
  ESP.Destroy(ESP.NameLabels[key])
  ESP.NameLabels[key] = nil
  ESP.VisCache[key] = nil
end

function ESP.ResetWidgets()
  for _, d in pairs(ESP.Lines) do ESP.Destroy(d) end
  for _, t in pairs(ESP.Corners) do for _, d in pairs(t) do ESP.Destroy(d) end end
  for _, d in pairs(ESP.HealthBorder) do ESP.Destroy(d) end
  for _, d in pairs(ESP.HealthBg) do ESP.Destroy(d) end
  for _, d in pairs(ESP.HealthFill) do ESP.Destroy(d) end
  for _, t in pairs(ESP.Marks) do for _, d in pairs(t) do ESP.Destroy(d) end end
  for _, d in pairs(ESP.Infos) do ESP.Destroy(d) end
  for _, d in pairs(ESP.Weapons) do ESP.Destroy(d) end
  for _, d in pairs(ESP.NameLabels) do ESP.Destroy(d) end
  ESP.NameLabels = {}
  ESP.Weapons = {}
  ESP.Lines = {}
  ESP.Corners = {}
  ESP.HealthBorder = {}
  ESP.HealthBg = {}
  ESP.HealthFill = {}
  ESP.Marks = {}
  ESP.Infos = {}
  ESP.VisCache = {}
  RedBoxOverlay.Stop()
  SL_ClearAll()
  ESP.Canvas = nil
  ESP.EnemyCache = {}
end

function ESP.Scan()
  local pc = ESP.GetController()
  local me = ESP.GetLocalCharacter()
  if not pc or not me then ESP.EnemyCache = {} return pc, 0, 0 end
  local myLoc = ESP.ActorLocation(me)
  if not myLoc then ESP.EnemyCache = {} return pc, 0, 0 end
  local myTeam = ESP.GetTeamID(me)
  local list = {}
  local nReal, nBot = 0, 0
  local pawns = nil
  pcall(function() if Game and Game.GetAllPlayerPawns then pawns = Game:GetAllPlayerPawns() end end)
  if pawns then
    for _, ch in pairs(pawns) do
      if ESPValid(ch) and ch ~= me and ESP.IsAlive(ch) then
        local team = ESP.GetTeamID(ch)
        if myTeam == nil or team == nil or tostring(team) ~= tostring(myTeam) then
          local loc = ESP.ActorLocation(ch)
          local dm = ESP.DistMeters(myLoc, loc)
          if dm * 100.0 <= (CFG.MaxDistance or 40000) then
            local isBot = ESP.IsBot(ch)
            if isBot then nBot = nBot + 1 else nReal = nReal + 1 end
            list[#list + 1] = { Character = ch, Key = ESP.GetPlayerKey(ch),
                                IsBot = isBot, Distance = dm }
          end
        end
      end
    end
  end
  table.sort(list, function(a, b) return (a.Distance or 99999) < (b.Distance or 99999) end)
  local trimmed = {}
  local maxR = CFG.MaxTracked or 16
  for i, it in ipairs(list) do
    if i > maxR then break end
    trimmed[#trimmed + 1] = it
  end
  ESP.EnemyCache = trimmed
  return pc, nReal, nBot
end
--// SRC HUB
function ESP.Update()
  if not ESP_Enabled then ESP.ResetWidgets() return end
  local world = ESP.World()
  if world ~= ESP.LastWorld then
    ESP.ResetWidgets()
    ESP.LastWorld = world
    ESP.LastScan = -999.0
    ESP.LastTransform = -999.0
  end
  local canvas = ESP.GetCanvas()
  if not canvas then return end
  local now = ESP.Now()
  local pc = ESP.GetController()
  if (now - ESP.LastScan) >= (ESP.ScanInterval or 0.35) then
    local r, b
    pc, r, b = ESP.Scan()
    ESP.LastScan = now
    ESP.RealCount, ESP.BotCount = r or 0, b or 0
  end
  pc = pc or ESP.GetController()
  if not pc then return end
  -- UpdateCanvasTransform har frame (source bhi yehi karta hai)
  ESP.UpdateCanvasTransform(pc)
  local vw, vh = ESP.Viewport(pc)
  -- viewport hysteresis: 2px se kam farq ignore (flicker fix)
  local hyst = CFG.SizeHyst or 2.0
  if math.abs(vw - (ESP.ViewW or 0)) > hyst or math.abs(vh - (ESP.ViewH or 0)) > hyst then
    ESP.ViewW, ESP.ViewH = vw, vh
  else
    vw, vh = ESP.ViewW, ESP.ViewH
  end
  -- Counter: RedBoxOverlay source-exact
  if _G.PGConfig.Esp9_Count then
    RedBoxOverlay.Start()
    RedBoxOverlay.SetCounts(ESP.RealCount or 0, ESP.BotCount or 0)
    RedBoxOverlay.UpdatePosition()
  else
    RedBoxOverlay.Stop()
  end
  -- Snap line origin: source-exact (SL_GetStartPos)
  local fromX, fromY = SL_GetStartPos(pc, vw)
  bUseSnapLines = (_G.PGConfig.Esp9_Line == true)
  local camLoc = ESP.GetCamLoc(pc)

  local active = {}
  for _, item in ipairs(ESP.EnemyCache) do
    local c = item.Character
    local key = item.Key
    if ESPValid(c) and ESP.IsAlive(c) then
      local head, feet = ESP.GetHeadFeet(c)
      if head and feet then
        local headS, headPix = ESP.Project(pc, head)
        local feetS, feetPix = ESP.Project(pc, feet)
        if headS and feetS and headPix and feetPix then
          local m = CFG.ScreenMargin or 220
          local mx = m + vw * (CFG.ScreenMarginExtraX or 0.03)
          local on = headPix.X > -mx and headPix.X < vw + mx
            and headPix.Y > -m and headPix.Y < vh + m
            and feetPix.X > -mx and feetPix.X < vw + mx
            and feetPix.Y > -m and feetPix.Y < vh + m
          if on then
            local H = feetS.Y - headS.Y
            -- sanity: ulti box / bahut badi box = garbage projection, hide
            if H >= (CFG.BoxMinHeight or 14) and H <= vh * 1.5 then
              active[key] = true
              local W = H * (CFG.BoxWidthFactor or 0.62)
              W = math.max(CFG.BoxMinWidth or 22, math.min(CFG.BoxMaxWidth or 320, W))
              local padT = H * (CFG.HeadExtra or 0)
              local padB = H * (CFG.FootExtra or 0)
              local cx = (headS.X + feetS.X) * 0.5
              local L = cx - W * 0.5
              local R = cx + W * 0.5
              local T = headS.Y - padT
              local B = feetS.Y + padB

              -- visibility check (box color ke liye — always compute)
              local bVis = ESP.IsVisible(key, pc, camLoc, c)

              -- 1) ESP BOX — sirf tab jab EspLoai9 ON ho
              if _G.PGConfig.EspLoai9 then
                local arm = math.min(R - L, B - T) * (CFG.CornerLen or 0.28)
                arm = math.max(CFG.CornerMin or 6, math.min(CFG.CornerMax or 28, arm))
                local th = CFG.CornerThickness or 2.2
                -- Visible=Green | Hidden: Bot=Purple, Real=Red
                local C_BOX, boxCK
                if bVis then
                  C_BOX = ESPMKC(0.0, 1.0, 0.0, 1.0)   -- Green (visible ho to)
                  boxCK = "box_green"
                elseif item.IsBot then
                  C_BOX = ESPMKC(0.63, 0.0, 1.0, 1.0)  -- Purple (Bot hidden)
                  boxCK = "box_purple"
                else
                  C_BOX = ESPMKC(1.0, 0.0, 0.0, 1.0)   -- Red (Real Enemy hidden)
                  boxCK = "box_red"
                end
                local cd1 = ESP.EnsureCorner(key, 1, C_BOX)
                local cd2 = ESP.EnsureCorner(key, 2, C_BOX)
                local cd3 = ESP.EnsureCorner(key, 3, C_BOX)
                local cd4 = ESP.EnsureCorner(key, 4, C_BOX)
                local cd5 = ESP.EnsureCorner(key, 5, C_BOX)
                local cd6 = ESP.EnsureCorner(key, 6, C_BOX)
                local cd7 = ESP.EnsureCorner(key, 7, C_BOX)
                local cd8 = ESP.EnsureCorner(key, 8, C_BOX)
                -- Update color every frame (bot/real can change)
                ESP.SetBrush(cd1, C_BOX, boxCK) ESP.SetBrush(cd2, C_BOX, boxCK)
                ESP.SetBrush(cd3, C_BOX, boxCK) ESP.SetBrush(cd4, C_BOX, boxCK)
                ESP.SetBrush(cd5, C_BOX, boxCK) ESP.SetBrush(cd6, C_BOX, boxCK)
                ESP.SetBrush(cd7, C_BOX, boxCK) ESP.SetBrush(cd8, C_BOX, boxCK)
                ESP.DrawLine(cd1, L, T, L + arm, T, th)
                ESP.DrawLine(cd2, L, T, L, T + arm, th)
                ESP.DrawLine(cd3, R, T, R - arm, T, th)
                ESP.DrawLine(cd4, R, T, R, T + arm, th)
                ESP.DrawLine(cd5, L, B, L + arm, B, th)
                ESP.DrawLine(cd6, L, B, L, B - arm, th)
                ESP.DrawLine(cd7, R, B, R - arm, B, th)
                ESP.DrawLine(cd8, R, B, R, B - arm, th)
              else
                local cc = ESP.Corners[key]
                if cc then for i = 1, 8 do ESP.Hide(cc[i]) end end
              end

              -- 2) HEALTH BAR — sirf tab jab Esp9_HP ON ho
              if _G.PGConfig.Esp9_HP then
                local pct = ESP.GetHealthPct(c)
                ESP.UpdateHealthBar(key, pct, L, R, T)
              else
                ESP.Hide(ESP.HealthBorder[key])
                ESP.Hide(ESP.HealthBg[key])
                ESP.Hide(ESP.HealthFill[key])
              end

              -- 2b) NAME ABOVE HEALTH BAR (fixed 100px width, always centered on enemy)
              if _G.PGConfig.Esp9_Name then
                local pName = ""
                pcall(function() pName = c:GetPlayerNameSafety() or "" end)
                if pName == "" then pName = item.IsBot and "Bot" or "Enemy" end
                local fixedW = 100.0                    -- fixed width, door/paas same
                local boxCX  = (L + R) * 0.5           -- true center of enemy box
                local nameNX = boxCX - fixedW * 0.5    -- left edge always symmetric
                local gapAbove = 4.0
                local barH2    = 5.0
                local nameTY   = T - gapAbove - barH2
                ESP.UpdateNameLabel(key, pName, item.IsBot, nameNX, fixedW, nameTY)
              else
                local nl = ESP.NameLabels[key]
                if nl and ESPValid(nl.Widget) then
                  pcall(function() nl.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                end
              end

              -- 3) TEAM CHEVRON — disabled
              if false then
                local ccx = (L + R) * 0.5
                local mw = CFG.MarkW or 15.0
                local mh = CFG.MarkH or 10.0
                local gv = CFG.MarkGapV or 6.0
                local gp = CFG.MarkGap or 8.0
                local mt = CFG.MarkThickness or 2.4
                local y2 = T - gp
                local y1 = y2 - mh - gv
                ESP.DrawLine(ESP.EnsureMark(key, 1), ccx - mw, y1, ccx, y1 + mh, mt)
                ESP.DrawLine(ESP.EnsureMark(key, 2), ccx + mw, y1, ccx, y1 + mh, mt)
                ESP.DrawLine(ESP.EnsureMark(key, 3), ccx - mw, y2 - mh, ccx, y2, mt)
                ESP.DrawLine(ESP.EnsureMark(key, 4), ccx + mw, y2 - mh, ccx, y2, mt)
              else
                local mm = ESP.Marks[key]
                if mm then for i = 1, 4 do ESP.Hide(mm[i]) end end
              end

              -- 4) bVis upar (step 1 se pehle) compute ho chuki — reuse

              -- 5) SNAP LINE — source-exact SL_UpdateSnapLine (Bot=Purple, Real=Red)
              SL_UpdateSnapLine(key, headS, on, fromX, fromY, item.IsBot, pc)
              if not _G.PGConfig.Esp9_Line then SL_RemoveSnapLine(key) end

              -- 5b) WEAPON — disabled
              if false then
                local wd = ESP.EnsureWeapon(key)
                if wd then
                  ESP.UpdateWeapon(wd, c, item.IsBot, cx, T - (_G.PGConfig.Esp9_Team and 40 or 22))
                end
              else
                ESP.Hide(ESP.Weapons[key])
              end

              -- 6) BOTTOM INFO (distance/Open) — flags se control
              ESP.UpdateInfo(key, c, item.IsBot, item.Distance, bVis, cx, B)
            else
              ESP.HideTarget(key)
            end
          else
            ESP.HideTarget(key)
          end
        else
          ESP.HideTarget(key)
        end
      else
        ESP.HideTarget(key)
      end
    end
  end
  -- stale: jo is frame me nahi dikha usko hide; jo cache me bhi nahi usko release
  local seenCache = {}
  for _, it in ipairs(ESP.EnemyCache) do seenCache[it.Key] = true end
  local function stillActive(k)
    return active[k] == true
  end
  for k, _ in pairs(ESP.Lines) do if not stillActive(k) then ESP.HideTarget(k) end end
  -- snap lines: not drawn this frame -> hide; left the cache (range/dead) -> remove
  local slStale = {}
  for k, _ in pairs(SnapLineWidgets) do
    if not stillActive(k) then slStale[#slStale + 1] = k end
  end
  for _, k in ipairs(slStale) do
    if seenCache[k] then
      local sl = SnapLineWidgets[k]
      if sl and ESPValid(sl.Widget) then
        pcall(function() sl.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
      end
    else
      SL_RemoveSnapLine(k)
    end
  end
  for k, _ in pairs(ESP.Infos) do if not stillActive(k) then ESP.HideTarget(k) end end
  for k, _ in pairs(ESP.Corners) do
    if not stillActive(k) and not seenCache[k] then ESP.ReleaseTarget(k) end
  end
  for k, _ in pairs(ESP.HealthBg) do
    if not seenCache[k] and not stillActive(k) then ESP.ReleaseTarget(k) end
  end
end

-- Single driver: sirf ek repeating timer (lag/flicker fix).
-- Purana triple-driver (Tick loop + 2x AddGameTimer) hata diya.
function ESP.Tick()
  pcall(ESP.Update)
end

function ESP.AttachTimers()
  pcall(function()
    local pc = ESP.GetController()
    if ESPValid(pc) and pc.AddGameTimer then
      if ESP._TimerPC == pc and ESP._TimerHooked then return end
      ESP._TimerPC = pc
      ESP._TimerHooked = true
      -- ek hi repeating timer: andar Scan (0.35) + Transform (0.5) throttled
      pc:AddGameTimer(ESP.LightInterval or 0.033, true, function()
        if ESP.bActive then pcall(ESP.Tick) end
      end)
    else
      pcall(function()
        require("timer").SetGameTimer(1.0, false, function()
          ESP._TimerHooked = false
          ESP.AttachTimers()
        end)
      end)
    end
    pcall(function() require("timer").SetGameTimer(5.0, false, function() ESP.AttachTimers() end) end)
  end)
end

function ESP.Start()
  if ESP.bActive then return end
  ESP.bActive = true
  pcall(ESP.Update)
  ESP.AttachTimers()
end

_G.ESP = ESP
_G.PlayerMapMarker = ESP

local function ESPLater(sec, fn)
  local tk = nil
  pcall(function() tk = require("common.time_ticker") end)
  if tk and tk.AddTimerOnce then pcall(function() tk.AddTimerOnce(sec, fn) end) return end
  pcall(function() require("timer").SetGameTimer(sec, false, fn) end)
end

local _ESPStartedPC = nil
local function ESPStartAll()
  pcall(function()
    local pc = nil
    if slua_GameFrontendHUD then pc = slua_GameFrontendHUD:GetPlayerController() end
    if not ESPValid(pc) then pc = ESP.GetController() end
    if ESPValid(pc) then
      if pc ~= _ESPStartedPC then
        _ESPStartedPC = pc
        ESP._TimerHooked = false
        ESP._TimerPC = nil
        ESP.Start()
      else
        ESP.AttachTimers()
      end
    end
  end)
end

pcall(function()
  ESPStartAll()
  ESPLater(1.0, ESPStartAll)
end)
if not _G.__ESPLookTickStarted then
  _G.__ESPLookTickStarted = true
  ESP.bActive = true
  ESP.AttachTimers()
end

_G.PMM_ESPV2 = ESP
-- ESP V2: koi bhi ek feature ON ho to engine chalega (BOX ka ON hona zaroori nahi)
_G.PMM_ESPV2_AnyOn = function()
    local C = _G.PGConfig
    return (C.EspLoai9 or C.Esp9_Line or C.Esp9_HP or C.Esp9_Distance or C.Esp9_Name) and true or false
end
end

-- init
pcall(function() if _G.LoadESPV2System then _G.LoadESPV2System() end end)


-- ESP V2 LOOP
local espv2Token = 0
local function FastESPV2Tick()
    if isExpired then return end
    if espv2Token ~= _G.PGState.ESPV2LoopToken then return end
    if _G.PMM_ESPV2_AnyOn and _G.PMM_ESPV2_AnyOn() and _G.PMM_ESPV2 and _G.PMM_ESPV2.bActive then
        pcall(function() _G.PMM_ESPV2.Tick() end)
    elseif _G.PMM_ESPV2 and _G.PMM_ESPV2.ResetWidgets then
        -- sab features OFF hain: canvas widgets clear karo (stuck boxes fix)
        pcall(function() _G.PMM_ESPV2.ResetWidgets() end)
    end
    local ticker = nil
    pcall(function() ticker = require("common.time_ticker") end)
    if ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.016, FastESPV2Tick)
    end
end

-- IGNITE BOTH LOOPS
-- ========================================== 
if not isExpired then
    FastTick() 
    _G.PGState.AimbotLoopToken = (_G.PGState.AimbotLoopToken or 0) + 1
    aimbotToken = _G.PGState.AimbotLoopToken
        _G.PGState.ESPV2LoopToken = (_G.PGState.ESPV2LoopToken or 0) + 1
        espv2Token = _G.PGState.ESPV2LoopToken
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.1, FastAimbotTick) -- mulai dengan jeda kecil
        ticker.AddTimerOnce(0.1, FastESPV2Tick)
    end
    Notify("You are using VIP Mod v2. If you don't have a key, inbox Telegram : @PGHACKS1")
else
    FastTick() 
end

-- ===================================================================================
-- SYSTEM HOOKS BYPASS
-- ===================================================================================
local function InitAllModSystems()
    if isExpired then return end 

    pcall(function()
        if _G.StartBypass_VIP_v3 then _G.StartBypass_VIP_v3() end
        if _G.InitializeAutoHeadHooks then _G.InitializeAutoHeadHooks() end
    end)

    local GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] or require("GameLua.GameCore.Data.GameplayData")
    if not GameplayData then return end

    pcall(function()
        local LocalPlayer = GameplayData.GetPlayerCharacter and GameplayData.GetPlayerCharacter()
        if slua.isValid(LocalPlayer) then
            if LocalPlayer.bHasShownDevNotice == nil then
                LocalPlayer.bHasShownDevNotice = false 
                LocalPlayer.bHasShownExpiredNotice = false 
                LocalPlayer.bIsDeadFlag = false
            end
        end
    end)
end

if not isExpired then
    pcall(function() 
        require("common.time_ticker").AddTimerOnce(0.5, InitAllModSystems) 
    end)
end


-- ==========================================
-- TW VERSION SPECIAL BYPASS
-- ==========================================
-- ==========================================
-- ALL VERSION BYPASS (GL, KR, TW)
-- ==========================================
pcall(function()
    print("[BYPPASS] 🔧 Applying version-specific bypasses...")
    
    -- ===== GLOBAL VERSION =====
    if _G.IS_GLOBAL then
        print("[GLOBAL] 🔧 Applying Global bypasses...")
        
        -- Global Anti-Cheat
        if _G.TssSdk then
            _G.TssSdk.IsEmulator = function() return false end
            _G.TssSdk.ScanMemory = function() return true end
            _G.TssSdk.ReportData = function() end
            _G.TssSdk.SendReport = function() end
            _G.TssSdk.OnRecvData = function() end
            print("[GLOBAL] ✅ TssSdk bypassed")
        end
        
        -- Global HiggsBoson
        local Higgs = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
        if Higgs then
            Higgs.bIsEnable = false
            Higgs.bMHActive = false
            Higgs.bCallPreReplication = false
            print("[GLOBAL] ✅ HiggsBoson bypassed")
        end
        
        print("[GLOBAL] ✅ Bypass complete!")
    end
    
    -- ===== KOREA VERSION =====
    if _G.IS_KR then
        print("[KR] 🔧 Applying Korea bypasses...")
        
        -- KR Anti-Cheat
        if _G.TssSdk then
            _G.TssSdk.IsEmulator = function() return false end
            _G.TssSdk.ScanMemory = function() return true end
            _G.TssSdk.ReportData = function() end
            _G.TssSdk.SendReport = function() end
            _G.TssSdk.OnRecvData = function() end
            print("[KR] ✅ TssSdk bypassed")
        end
        
        -- KR HiggsBoson
        local Higgs = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
        if Higgs then
            Higgs.bIsEnable = false
            Higgs.bMHActive = false
            Higgs.bCallPreReplication = false
            print("[KR] ✅ HiggsBoson bypassed")
        end
        
        print("[KR] ✅ Bypass complete!")
    end
    
    -- ===== TAIWAN VERSION =====
    if _G.IS_TW_VERSION then
        print("[TW] 🔧 Applying Taiwan bypasses...")
        
        -- TW Anti-Cheat
        if _G.TssSdk then
            _G.TssSdk.IsEmulator = function() return false end
            _G.TssSdk.ScanMemory = function() return true end
            _G.TssSdk.ReportData = function() end
            _G.TssSdk.SendReport = function() end
            _G.TssSdk.OnRecvData = function() end
            print("[TW] ✅ TssSdk bypassed")
        end
        
        -- TW HiggsBoson
        local Higgs = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
        if Higgs then
            Higgs.bIsEnable = false
            Higgs.bMHActive = false
            Higgs.bCallPreReplication = false
            print("[TW] ✅ HiggsBoson bypassed")
        end
        
        print("[TW] ✅ Bypass complete!")
    end
    
    print("[BYPPASS] ✅ All version bypasses applied!")
end)

-- ==========================================
-- COMMON BYPASS FOR ALL VERSIONS
-- ==========================================
pcall(function()
    print("[BYPPASS] 🔧 Applying common bypasses for all versions...")
    
    -- Block all Report Systems
    local reportPaths = {
        "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
        "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem",
        "client.slua.logic.report.EquipmentExceptionReport",
        "client.slua.logic.report.ClientToolsReport",
        "GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils",
        "client.slua.logic.download.report.puffer_tlog",
        "GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem",
        "GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils",
        "GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature",
        "client.slua.logic.ban.ClientBanLogic",
        "client.slua.logic.login.logic_tt_ban",
    }
    
    for _, path in ipairs(reportPaths) do
        local module = package.loaded[path] or pcall(require, path) and require(path)
        if module then
            if module.Report then module.Report = function() end end
            if module.SendReport then module.SendReport = function() end end
            if module.ReportEvent then module.ReportEvent = function() end end
            if module.ReportException then module.ReportException = function() end end
            if module.ReportData then module.ReportData = function() end end
        end
    end
    
    -- Block Network Packets
    if NetUtil and NetUtil.SendPacket then
        local originalSend = NetUtil.SendPacket
        local blockedPackets = {
            ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportHurtFlow"]=1,
            ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
            ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1,
            ["ReportAimFlow"]=1, ["ReportHitFlow"]=1,
            ["ReportCircleFlow"]=1, ["ReportJumpFlow"]=1,
            ["ReportSecurityAlert"]=1, ["ReportAntiCheat"]=1,
            ["ReportViolation"]=1, ["ReportBan"]=1, ["ReportKick"]=1,
        }
        NetUtil.SendPacket = function(packetName, ...)
            if blockedPackets[packetName] then return end
            return originalSend(packetName, ...)
        end
        NetUtil.IsBypassed = true
    end
    
    print("[BYPPASS] ✅ Common bypasses applied!")
end)

-- ============================================================
-- VICTORY DANCE FX + EMOTE HANDLE OVERRIDE
-- ============================================================
local VICTORY_DANCE_FX_MAP = {
  [12219601] = 22010089
}

function ResolveEmoteResID(ItemID)
  local FxID = VICTORY_DANCE_FX_MAP[ItemID]
  if not FxID or FxID == ItemID then
    return ItemID
  end
  local model_util = require("client.common.model_util")
  local FxBPID = model_util.GetBPID(FxID)
  local ResID = ItemID
  if FxBPID and 0 < FxBPID and model_util.IsBattleItemHandleExist("Emote", FxBPID, false, false) then
    ResID = FxID
  end
  print(bWriteLog and string.format("BRPlayerCharacterBase 11 ResolveEmoteResID ItemID:%s, FxID:%s, FxBPID:%s, ResID:%s", tostring(ItemID), tostring(FxID), tostring(FxBPID), tostring(ResID)))
  return ResID
end

function BRPlayerCharacterBase:GetEmoteHandlePath(ItemID)
  local ResID = ResolveEmoteResID(ItemID)
  if self.Super then
    return self.Super:GetEmoteHandlePath(ResID)
  end
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(ResID)
  if not BPID or BPID <= 0 then
    return ""
  end
  return model_util.GetPath("Emote", BPID, false, false) or ""
end

function BRPlayerCharacterBase:GetEmoteHandle(ItemID)
  local ResID = ResolveEmoteResID(ItemID)
  if self.Super then
    return self.Super:GetEmoteHandle(ResID)
  end
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(ResID)
  if not BPID or BPID <= 0 then
    return nil
  end
  local HandleClass = model_util.GetClass("Emote", BPID, false, false)
  if not HandleClass then
    return nil
  end
  local Handle = HandleClass()
  if not slua.isValid(Handle) then
    return nil
  end
  return Handle
end
-- ==============================================================================

local class = require("class")
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CBRPlayerCharacterBase = class(CCharacterBase, nil, BRPlayerCharacterBase)

return require("combine_class").DeclareFeature(CBRPlayerCharacterBase, {
  {
    SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature"
  },
  {
    CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature"
  },
  {
    SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature"
  },
  {
    TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature"
  },
  {
    LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature"
  },
  {
    FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature"
  },
  {
    CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature"
  },
  {
    BuildAircraftVehicleFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature"
  },
  {
    UnifiedBuildVehicleFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.UnifiedBuildVehicleFeature"  -- ⬅️ ADDED
  },
  {
    CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature"
  },
  {
    ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature"
  },
  {
    ParachuteSprint = "GameLua.Mod.BaseMod.GamePlay.Feature.Parachute.ParachuteSprintFeature"  -- ⬅️ ADDED
  },
  {
    GeneralShowSpotFeature = "GameLua.Mod.BRMod.Gameplay.Feature.PlayerCharacterGeneralShowSpotFeature"  -- ⬅️ ADDED
  },
  {
    FPPAnimMonitor = "GameLua.Mod.BaseMod.GamePlay.Feature.Player.FPPAnimMonitorFeature"  -- ⬅️ ADDED
  }
}, "BRPlayerCharacterBase")
