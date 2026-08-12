module Physics.Simulator where

import Math.Vector3
import Physics.Forces
import Physics.Types
import Physics.Integrator

simulate :: R->R->R->Int->SystemState->[SystemState]
simulate g eps dt timesteps initial=
	take (timesteps+1) $ iterate (stepSystem g eps dt) initialState --take grabs the n-1 items from a inifinte list generated from iterate

