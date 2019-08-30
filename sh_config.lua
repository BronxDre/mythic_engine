Config = {}

Config.Stages = 3
Config.Base = 5000
Config.LockpickTimers = {
    [0] = 5000,
    [1] = 5000,
    [2] = 8000,
    [3] = 5000,
    [4] = 8000,
    [5] = 8000,
    [6] = 8000,
    [7] = 8000,
    [8] = 5000,
    [9] = 5000,
    [10] = 5000,
    [11] = 5000,
    [12] = 5000,
    [13] = nil,
    [14] = 5000,
    [15] = 11000,
    [16] = 14000,
    [17] = 5000,
    [18] = 11000,
    [19] = 11000,
    [20] = 8000,
    [21] = nil,
}

--  Exporting For The Sake Of Storing These Timers
--  In 1 Place And Using Them For Lockpick Items
function GetLockpickTimers()
    return Config.LockpickTimers
end