
module Physics.Forces where

import Math.Vector3
import Physics.Types

--set constants
gravitationalConstant::R --gravitational constant
gravitationalConstant = 6.6743e-11
defaultSoftening::R 
defaultSoftening = 1e-4 --softening length to prevent r=0 collapsing the engine

--get displacement between two Bodies

calcPairAccel::R->R->Body->Body->Vector3 --R values are constants, first body is target and second is source
calcPairAccel gConstant epsConstant target source =
  | bodyID target == bodyID source = zeroV --if the ids are the same, return the zero vector
  | otherwise =
        let rVector = pos source ^-^ pos target --subtract source and target vector so there is a vector pointing to the source indicating gravitational pull
            rSq = rVector <.> rVector --obtain ||r||^2
            rSoft = rSq + (epsConstant*epsConstant)
            denominator = rSoft * sqrt rSoft
            ratio = (gConstant * mass target)/denominator
        in ratio *^ rVector

calcBodyAccel::R->R->Body->[Body]->Vector3 --calculate the acceleration on a body
calcBodyAccel gConstant epsConstant target allBodies = sumV $ map (calcPairAccel gConstant epsConstant target) allBodies --use sumV and map to get all of the pair accelerations and add them up

calcAllAccel::R->R->[Body]->[Vector3] --get all of the acceleration vectors
calcAllAccel gConstant epsConstant allBodies = map (calcAllAccel gConstant epsConstant) allBodies
