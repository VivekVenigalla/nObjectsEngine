{-# OPTIONS_GHC -fno-warn-orphans #-} --disables warning for a orphan instance(a instance without a class definition)

module Main (main) where

import Math.Vector3
import Test.QuickCheck hiding ((><)) --enables arbitrary and property checks and hides the ><

instance Arbitrary Vector3 where --creates random vector
  arbitrary = do 
    x <- arbitrary
    y <- arbitrary
    z <- arbitrary
    return (vec3 x y z)

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


main :: IO()
main = do
  putStrLn "Testing..."
  quickCheck prop_add_commutative
  quickCheck prop_add_associative
  quickCheck prop_zero_identity
  quickCheck prop_self_magnitude
  quickCheck prop_crossOrth

