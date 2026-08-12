module Physics.Simulator where

import Math.Vector3
import Physics.Forces
import Physics.Types
import Physics.Integrator

simulate :: R->R->R->Int->SystemState->[SystemState]
simulate g eps dt timesteps initial=
	take (timesteps+1) $ iterate (stepSystem g eps dt) initialState --take grabs the n-1 items from a inifinte list generated from iterate

--format -- time, bodyID, mass, posX, posY, posZ, velX, velY, velZ
csvHeader::String
csvHeader = "time,id,mass,posX,posY,posZ,velX,velY,velZ"

--convert body state into a csv row
--for now this function creates a string that contains the necessary values
bodyToCSV :: R->Body->String
bodyToCSV t b =
	printf "%.6f, %d, %.6e, %.6e, %.6e, %.6e, %.6e, %.6e, %.6e" --printf returns a string that can be formatted either as a float, int, or in scientific notation
		t
		(bodyID b)
		(mass b)
		(xComp $ pos b) (yComp $ pos b) (zComp $ pos b)
		(xComp $ vel b) (yComp $ vel b) (zComp $ vel b)

systemToCSV::SystemState->String
systemToCSV SystemState(t bs) =
	unlines $ map (t) bs --unlines adds all lines together into one string with \n seperating

