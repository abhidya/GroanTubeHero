local ClientState = {
    snapshot = nil,
    session = nil,
    ui = nil,
}

function ClientState.SetSnapshot(snapshot)
    ClientState.snapshot = snapshot
end

function ClientState.GetSnapshot()
    return ClientState.snapshot
end

function ClientState.SetSession(session)
    ClientState.session = session
end

function ClientState.GetSession()
    return ClientState.session
end

function ClientState.SetUi(ui)
    ClientState.ui = ui
end

function ClientState.GetUi()
    return ClientState.ui
end

return ClientState
