
module Math.Vector3 where --define the file name and location so the .cabal file can find the module

type R = Double --convert the Double into a new alias for real numbers

--create custom vector operators with their corresponding precedence
-- ^ indicates that that side is a vector
-- the higher the precedence the higher priority it takes overall

infixl 6 ^+^ --addition
infixl 6 ^-^ --subtraction
infixl 7 *^ --multiplication with constant first
infixl 7 ^* --mutiplication with constant last
infixl 7 ^/ --division with vector first
infixl 7 <.> --dot product
infixl 7 >< --cross product


--create function showDouble
showDouble :: R->String --takes a real number and returns a string. if it is a negative number enclose in parantheses
showDouble x = if x <0 then "(" ++ show x ++ ")" else show x

--create Vector3 Data object

data Vector3 = Vector3
 {xComp :: {-# UNPACK #-} !R, --components
  yComp :: {-# UNPACK #-} !R, --unpack and ! enforce strictness on the data so they are not transferred to the heap
  zComp :: {-# UNPACK #-} !R
 }deriving(Eq) --functions deriving for this data type(equals function)

--create a instance of the show class to allow for Vector3 printing

instance Show Vector3 where
 show (Vector3 x y z) = "vec " ++ showDouble x ++ " " ++ showDouble y ++ " " ++ showDouble z

--create function that creates the data object
--NOTE HELPER FUNCTIONS SHOULD BE LOWERCASE
vec3 :: R -> R -> R -> Vector3 --R are all of the components

vec3 = Vector3 --using point free notation to fill in the inputs



--create Vector functions

--create all the hats
iHat :: Vector3
iHat = vec3 1 0 0

jHat :: Vector3
jHat = vec3 0 1 0

kHat :: Vector3
kHat = vec3 0 0 1

zeroV :: Vector3
zeroV = vec3 0 0 0

--create basic operations
(^+^) :: Vector3 -> Vector3 -> Vector3
Vector3 ax ay az ^+^ Vector3 bx by bz = Vector3 (ax+bx) (ay+by) (az+bz)

(^-^) :: Vector3 -> Vector3 -> Vector3
Vector3 ax ay az ^-^ Vector3 bx by bz = Vector3 (ax-bx) (ay-by) (az-bz)

(*^) :: R -> Vector3 -> Vector3
x *^ Vector3 bx by bz = Vector3 (x*bx) (x*by) (x*bz)

(^*) :: Vector3 -> R -> Vector3
Vector3 bx by bz ^* x = Vector3 (x*bx) (x*by) (x*bz)

(^/) :: Vector3 -> R -> Vector3
Vector3 bx by bz ^/ x = Vector3 (bx/x) (by/x) (bz/x)

--dot product
(<.>) :: Vector3 -> Vector3 -> R 
Vector3 ax ay az <.> Vector3 bx by bz = (ax*bx) + (ay*by) + (az*bz)

--cross product(use determinant method)
(><) :: Vector3 -> Vector3 -> Vector3
Vector3 ax ay az >< Vector3 bx by bz = Vector3 (ay*bz - az*by) (az*bx - ax*bz) (ax*by - ay*bx)

--magnitude
vecMag :: Vector3 -> R 
vecMag v = sqrt(v <.> v)

--sum of a list of vectors
sumV :: [Vector3] -> Vector3
sumV = foldr(^+^) zeroV --use the zeroV as a initial value and parse over the list(uses point free notation)

--normalization
vecNorm :: Vector3 -> Vector3
vecNorm v
  | mag == 0 = zeroV
  | otherwise = v^/mag
  where 
    mag = vecMag v





