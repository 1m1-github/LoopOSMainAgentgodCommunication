module LoopOSMainAgentgodCommunication

using ZMQ
using LoopOS: @whiletrue
using TheoryOfGod
using TheoryOfGodgod: god, ∃!
using TheoryOfGodCommunication

const CREATESOCKET = Ref{Socket}()
const OBSERVESOCKET = Ref{Socket}()

function init(createlocation, observelocation, ω)
    CREATESOCKET[] = Socket(REP)
    OBSERVESOCKET[] = Socket(REP)
    bind(CREATESOCKET[], createlocation)
    bind(OBSERVESOCKET[], observelocation)
    @async @whiletrue create(CREATESOCKET[], ω), @async @whiletrue observe(OBSERVESOCKET[], ω)
end
function create(socket, ω)
    message = recv(socket)
    buffer = IOBuffer(message)
    data = deserialize(buffer)
    try 
        if data isa ∃2d
            ∃!2d(data.g, data.μ, data.ρ, data.ϕ, ω)
        elseif data isa ∃3d
            ∃!3d(data.g, data.μ, data.ρ, data.ϕ, ω)
        elseif data isa ∃Nd
            ∃!(data.d, data.μ, data.ρ, data.∂, data.ϕ, ω)
        else
            throw("unknown data type: $(typeof(data))")
        end
        send(socket, ".")
    catch e
        send(socket, e)
    end
end
function observe(socket, ω)
    message = recv(socket)
    buffer = IOBuffer(message)
    try 
        g::god = deserialize(buffer)
        send(socket, ∃̇(g, ω))
    catch e
        send(socket, e)
    end
end

end
