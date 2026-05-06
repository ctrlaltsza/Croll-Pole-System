Config = {}

Config.UseProps = true

Config.JobLock = {
    enabled = true,
    jobs = {'stripper', 'vanilla', 'bahama'}
}

Config.PropModel = `prop_strip_pole_01`

Config.PropLocations = {
    {
        coords = vec3(108.71, -1289.35, 29.86),
        heading = 30.0
    },
    {
        coords = vec3(110.71, -1289.35, 29.86),
        heading = 30.0
    }
}

Config.Poles = {
    [1] = { coords = vec3(108.71, -1289.35, 29.86), radius = 1.5 },
    [2] = { coords = vec3(110.71, -1289.35, 29.86), radius = 1.5 }
}

Config.Anim = {
    dict = 'mini@strip_club@pole_dance@pole_dance1',
    anim = 'pd_dance_01'
}

Config.Items = {
    cashroll = 'cashrolls',
    cashband = 'cashband',
    cleanMoney = 'money'
}

Config.RollCleaningProgression = {
    [1] = 60,
    [2] = 65,
    [3] = 75,
    [4] = 80
}

Config.BandWorth = 1000