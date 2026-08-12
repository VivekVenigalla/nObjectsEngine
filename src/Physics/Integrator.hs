module Physics.Integrator where

import Math.Vector3
import Physics.Forces
import Physics.Types

--step one body
stepBody::R->Body->Vector3->Body --step dt with a body and acceleration vector
--this step function utilizes euler-cromer integration
stepBody dt b acc =
    let velNext = vel b ^+^ (acc ^* dt)
        posNext = pos b ^+^ (velNext ^* dt)
    in b {pos = posNext, vel = velNext}

--step entire system
stepSystem::R-> R-> R->SystemState->SystemState
stepSystem g eps dt (SystemState t bodiesList) = 
    let accList = calcAllAccel g eps bodiesList
        steppedBodies = zipWith (stepBody t) bodiesList accList --since bodieslist and accList are the same size, we use zipWith to use stepBody for each pair of body and acceleration vector
    in SystemState(t+dt) steppedBodies




