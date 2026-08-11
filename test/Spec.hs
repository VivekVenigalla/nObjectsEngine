{-# OPTIONS_GHC -fno-warn-orphans #-} --disables warning for a orphan instance(a instance without a class definition)

module Main (main) where

import Math.Vector3
import Test.QuickCheck hiding ((><)) --enables arbitrary and property checks and hides the ><
import Physics.Types
import Physics.Forces


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

