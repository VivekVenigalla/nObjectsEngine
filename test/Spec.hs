{-# OPTIONS_GHC -fno-warn-orphans #-} --disables warning for a orphan instance(a instance without a class definition)

module Main (main) where

import Math.Vector3
import Test.QuickCheck hiding ((><)) --enables arbitrary and property checks and hides the ><
import Physics.Types
import Physics.Forces
import Physics.Integrator

--INSTANCE CREATORS
instance Arbitrary Vector3 where --creates random vector
  arbitrary = do 
    x <- arbitrary
    y <- arbitrary
    z <- arbitrary
    return (vec3 x y z)
instance Arbitrary Body where
  arbitrary = do
    b <- arbitrary
    m <- choose (1e-3, 1e24)
    p <- arbitrary
    v <- arbitrary
    return (Body b m p v)

-- VECTOR TESTS

--check commutative property
--since the adding is deterministic between two values, we don't need to check degree like associative property
prop_add_commutative :: Vector3 -> Vector3 -> Bool
prop_add_commutative u v = (u ^+^ v) == (v ^+^ u)

--check associative property
--since the order of three numbers can affect rounding, we need to check the degree of how close they are to validate the test
prop_add_associative :: Vector3 -> Vector3 -> Vector3 -> Bool
prop_add_associative u v w =
  let lhs = (u ^+^ v) ^+^ w
      rhs = u ^+^ (v ^+^ w)
  in vecMag (lhs ^-^ rhs) < 1e-9 --subtract both and check degree of accuracy to prevent any rounding errors

prop_zero_identity :: Vector3 -> Bool
prop_zero_identity u = u^*0 == vec3 0 0 0

--u dot u = |u|^2
prop_self_magnitude :: Vector3 -> Bool
prop_self_magnitude u =
  let dot = u <.> u
      magSq = vecMag u * vecMag u 
  in dot - magSq < 1e-9

-- (u x v) dot u = 0
prop_crossOrth :: Vector3 -> Vector3 -> Bool
prop_crossOrth u v =
  let crossProduct = u><v
  in abs (crossProduct <.> u) < 1e-9 && abs (crossProduct <.> v) < 1e-9

-- PHYSICS TESTS

prop_self_interact :: Body -> Bool --body does not exert a force on itself
prop_self_interact b = calcPairAccel gravitationalConstant defaultSoftening b b == zeroV

prop_newton_third_law :: Body-> Body -> Bool --every force has a equal and opposite reaction
prop_newton_third_law b1 b2 =
  let f1 = mass b1 *^ calcPairAccel gravitationalConstant defaultSoftening b1 b2
      f2 = mass b2 *^ calcPairAccel gravitationalConstant defaultSoftening b2 b1
      diff = f1 ^+^ f2 --since they are equal and opposite, the magnitudes should almost cancel each other out
      magf1 = vecMag f1
      relativeError = if magf1 > 1e-12 
                      then vecMag diff / magf1 
                      else vecMag diff
    in relativeError < 1e-9

prop_softening_limit :: Body->Body->Bool --all acclerations are atleast the defaultSoftening limit
prop_softening_limit b1 b2 = 
  let a = calcPairAccel gravitationalConstant defaultSoftening b1 b2
      maxAccel = (gravitationalConstant * mass b2)/(defaultSoftening * defaultSoftening)
  in vecMag a <= maxAccel + 1e-9

prop_acceleration_length :: [Body] -> Bool
prop_acceleration_length bs =
  (length $ calcAllAccel gravitationalConstant defaultSoftening bs) == length bs

--Integrator Tests
prop_energy_consv :: R --since we are not using any arbitrary values, we only create a bool type func
prop_energy_consv =
  let m1 = 1e30 --central mass
      m2 = 1e24 --orbiting mass
      totalMass = m1+m2
      distance = 1e11

      --get the initial velocity using the centripetal acceleration rule (F gravity = F centripetal force for orbit)
      -- v = sqrt(G(m1+m2)/r)
      initialV = sqrt (gravitationalConstant * (m1 + m2) / distance)

      --create initial body states
      central = Body 1 m1 zeroV zeroV --central mass is in the origin and starts with no velocity
      orb = Body 2 m2 (vec3 distance 0 0) (vec3 0 initialV 0) --orbiting mass is along the x axis and has a initial velocty pointing up

      initialState = SystemState 0.0 [central, orb] --create initial system state
      initialEnergy = totalEnergy gravitationalConstant defaultSoftening (bodies initialState)--obtain initial energy

      period = 2.0 * pi * sqrt ((distance*distance*distance)/(gravitationalConstant*totalMass))
      dt = period/1000 --ensures there is 1000 steps for a orbit

      finalState = iterate (stepSystem gravitationalConstant defaultSoftening dt) initialState !! 1000

      finalEnergy = totalEnergy gravitationalConstant defaultSoftening (bodies finalState)

      relativeError = abs(finalEnergy-initialEnergy) / abs initialEnergy
  in relativeError --large error because of large period of execution





main :: IO()
main = do
  putStrLn "Running Vector Tests..."
  quickCheck prop_add_commutative
  quickCheck prop_add_associative
  quickCheck prop_zero_identity
  quickCheck prop_self_magnitude
  quickCheck prop_crossOrth
  putStrLn "Running Physics Tests..."
  quickCheck prop_self_interact
  quickCheck prop_newton_third_law
  quickCheck prop_softening_limit
  quickCheck prop_acceleration_length
  putStrLn "Running Integrator Tests..."
  --if prop_energy_consv 
    --then putStrLn "+++ OK, passed Kepler Conservation Test "
    --else putStrLn "+++ FAILED, failed Kepler Conservation Test "
  putStrLn ("Kepler Conservation Test " ++ show prop_energy_consv)
  if prop_energy_consv < 1e-3
    then putStrLn ("+++ OK, passed 1 test.")
    else putStrLn ("--- FAILED")
